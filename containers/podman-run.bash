#! /bin/bash

sudo podman rm --force postgis pgadmin4 rstats
sudo docker rm --force postgis pgadmin4 rstats

# podman doesn't have "networks" in the same sense as "docker network". It comes with a single
# default CNI network: 10.88.0.0/16.

# So for the other two containers to refer to the "postgis" container by name, we have to party
# like it's 1982 - assign it a static IP address and create an "/etc/hosts" file pointing to it
# in the other two containers. See "man podman-run" for details.

sudo podman run --detach --env-file .env \
  --hostname postgis --name postgis --ip 10.88.64.128 --publish 5439:5432 \
  --add-host postgis:10.88.64.128 --add-host pgadmin4:10.88.64.130 --add-host rstats:10.88.64.129 \
  localhost/postgis:latest
sudo podman run --detach --env-file .env \
  --hostname rstats --name rstats --ip 10.88.64.129 --publish 8004:8004 \
  --add-host postgis:10.88.64.128 --add-host pgadmin4:10.88.64.130 --add-host rstats:10.88.64.129 \
  localhost/rstats:latest
sudo podman run --detach --env-file .env \
  --hostname pgadmin4 --name pgadmin4 --ip 10.88.64.130 --publish 8686:80 \
  --add-host postgis:10.88.64.128 --add-host pgadmin4:10.88.64.130 --add-host rstats:10.88.64.129 \
  docker.io/dpage/pgadmin4:latest
sudo podman ps
sudo podman exec -u rstats rstats /home/rstats/scripts/is_postgis_there.R
