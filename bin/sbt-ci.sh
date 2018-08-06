#!/usr/bin/env bash
set -o nounset


# I don't trust $DRONE_COMMIT_MESSAGE here, it's had problems in the future
if git log -1 --pretty=%B --no-merges | grep DOCS > /dev/null 2>&1; then
  echo "Found DOCS in commit message, the CI will only update the docs site."
  if [[ "$DRONE_BUILD_EVENT" != "pull_request" && "$DRONE_BRANCH" == "master" ]]; then
    echo "Updating website with the docs (tag or push to master detected)"
    ls -l /drone/.sbt/ghpages
    rm -rf /drone/.sbt/ghpages
    if ! sbt -sbt-dir /drone/.sbt/1.0 -sbt-boot /drone/.sbt/boot docs/ghpagesPushSite; then
      exit 1
    fi
  else 
    echo "Making docs... (pull request detected)"
    # If publish docs is not set, just build them
    if ! sbt -sbt-dir /drone/.sbt/1.0 -sbt-boot /drone/.sbt/boot docs/makeSite; then
      exit 1
    fi
  fi
else
  if ! sbt -sbt-dir /drone/.sbt/1.0 -sbt-boot /drone/.sbt/boot "$@"; then
    exit 1
  fi
  find "/root/.ivy2/cache"     -name "ivydata-*.properties" -print -delete
  find "/root/.coursier"       -name "ivydata-*.properties" -print -delete
  find "/root/.sbt"            -name "*.lock"               -print -delete
fi