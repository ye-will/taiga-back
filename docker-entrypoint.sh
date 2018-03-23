#!/bin/bash

taiga::init() {
  python manage.py migrate --noinput
  python manage.py loaddata initial_user
  python manage.py loaddata initial_project_templates
  python manage.py compilemessages
  python manage.py collectstatic --noinput
}

taiga::start() {
  if [ ! -f /tmp/taiga-init.lock ]; then
    taiga::init >> /tmp/taiga-init.lock
  fi
  chown -R taiga:taiga /taiga
  su taiga << EOF
    gunicorn -w 3 -t 60 --pythonpath=. -b 0.0.0.0:8000 taiga.wsgi
EOF
}

main() {
  case "X$1" in
    "Xinit" )
      taiga::init
      ;;
    "X" )
      taiga::start
      ;;
    * )
      echo "hello from taiga-back"
      ;;
  esac
}

main
