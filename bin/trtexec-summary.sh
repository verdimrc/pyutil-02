#!/bin/bash

set -euo pipefail

declare -a HELP=(
    "[-h|--help]"
    "[-H|--header]"
    "[-s|--space]"
    "FILE_PATH"
)

HEADER=0
SEP=,
declare -a FILES=()
parse_args() {
    local key
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
        -h|--help)
            echo "Extract some of the performance summary of trtexec>=10.x."
            echo "Usage: $(basename ${BASH_SOURCE[0]}) ${HELP[@]}"
            exit 0
            ;;
        -H|--header)
            HEADER=1
            shift
            ;;
        -s|--space)
            SEP=" "
            shift
            ;;
        *)
            FILES+=("$key")
            shift
            ;;
        esac
    done
}

parse_args "$@"
# echo "${FILES[@]}"
# echo "$SEP" $HEADER

if [[ $HEADER == 1 ]]; then
    [[ "${#FILES[@]}" -gt 1 ]] \
        && echo file qps ms_min ms_max ms_mean ms_median ms_pct90 ms_pct95 ms_pct99 | tr ' ' "$SEP" \
        || echo qps ms_min ms_max ms_mean ms_median ms_pct90 ms_pct95 ms_pct99 | tr ' ' "$SEP"
fi

if [[ "${#FILES[@]}" -lt 1 ]]; then
    grep '=== Performance summary ===' -A2  -m 1 | tail -2 | cut -d' ' --complement -f1,2 | grep -o '[0-9]*\.[0-9]*' | xargs echo | tr ' ' "$SEP"
elif [[ "${#FILES[@]}" -eq 1 ]]; then
    grep '=== Performance summary ===' -A2  -m 1 "${FILES[@]}" | tail -2 | cut -d' ' --complement -f1,2 | grep -o '[0-9]*\.[0-9]*' | xargs echo | tr ' ' "$SEP"
else
    for i in "${FILES[@]}"; do
        echo -n "$i${SEP}"
        grep '=== Performance summary ===' -A2  -m 1 "${FILES[@]}" | tail -2 | cut -d' ' --complement -f1,2 | grep -o '[0-9]*\.[0-9]*' | xargs echo | tr ' ' "$SEP"
    done
fi

exit $?


########
# Below are documentation. May contain invalid bash syntax.

```console
$ grep
[10/15/2024-03:18:08] [I] === Performance summary ===
[10/15/2024-03:18:08] [I] Throughput: 1211.26 qps
[10/15/2024-03:18:08] [I] Latency: min = 0.806946 ms, max = 0.840698 ms, mean = 0.823402 ms, median = 0.823364 ms, percentile(90%) = 0.830322 ms, percentile(95%) = 0.83252 ms, percentile(99%) = 0.835587 ms

$ grep | tail
[10/15/2024-03:18:08] [I] Throughput: 1211.26 qps
[10/15/2024-03:18:08] [I] Latency: min = 0.806946 ms, max = 0.840698 ms, mean = 0.823402 ms, median = 0.823364 ms, percentile(90%) = 0.830322 ms, percentile(95%) = 0.83252 ms, percentile(99%) = 0.835587 ms

$ grep | tail | cut
Throughput: 1211.26 qps
Latency: min = 0.806946 ms, max = 0.840698 ms, mean = 0.823402 ms, median = 0.823364 ms, percentile(90%) = 0.830322 ms, percentile(95%) = 0.83252 ms, percentile(99%) = 0.835587 ms

$ grep | tail | cut | grep
1211.26
0.806946
0.840698
0.823402
0.823364
0.830322
0.83252
0.835587

$ grep | tail | cut | grep | echo
1211.26 0.806946 0.840698 0.823402 0.823364 0.830322 0.83252 0.835587
```
