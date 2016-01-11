From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 00/53] perf tools: Bugfix, BPF improvement and perf record flight record mode
Date: Mon, 11 Jan 2016 13:47:51 +0000
Message-ID: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnaldo,

   This patch set is based on today's perf/core. It contains 3 parts:

   1. Bugfix in my local tree. Most of them are resent (patch 1 - 17).

   2. BPF related improvement. Also, you should have read them last
      year. Nearly no change (18 - 26).

   3. The most exciting feature I'd like to introduce to you and others:
      perf record overwrite mode support:

      This feature is based on a patch which is discussed but not merged
      yet [1]. I also send it in this series as patch 27. In this patch,
      kernel appends the size of an event at the end of the event data
      in the ring buffer, which enables us reading as much data as
      possible from a overwrite ring buffer, so it works like a flight
      recorder. Patch 28 - 53 add support of it. This is an example:

 # perf record -a -e cycles/overwrite/ \
	          -e raw_syscalls:sys_enter/overwrite/ \
	          -e raw_syscalls:sys_exit/overwrite/ \
	          -e sched:sched_switch/overwrite/ \
                  --switch-output --tail-tracking

 Then send 3 SIGUSR2 to 'perf' in another console:

 # kill -s SIGUSR2 `ps -e | grep 'pts.*perf' | awk '{print $1}'`

 [ perf record: dump data: Woken up 1 times ]
 [ perf record: Dump perf.data.2016011205392208 ]
 [ perf record: dump data: Woken up 1 times ]
 [ perf record: Dump perf.data.2016011205392597 ]
 [ perf record: dump data: Woken up 1 times ]
 [ perf record: Dump perf.data.2016011205392906 ]
 ^C[ perf record: Woken up 1 times to write data ]
 [ perf record: Dump perf.data.2016011205393040 

 Here's the result:

 # ls -l ./perf.data.* 
  -rw------- 1 root root 4284861 Jan 12 05:39
  ./perf.data.2016011205392208
  -rw------- 1 root root 4578477 Jan 12 05:39
  ./perf.data.2016011205392597
  -rw------- 1 root root 4602757 Jan 12 05:39
  ./perf.data.2016011205392906
  -rw------- 1 root root 5655429 Jan 12 05:39
  ./perf.data.2016011205393040

In each perf.data output, we get about 4M events before it receives
signal.

This should be useful if we have a extra monitor checks performance
metrics. When it found something unusual, it can send a SIGUSR2 to
perf to collect data near the bad things happen.

My next step is trying to trigger event dumping using eBPF. Then we can
triggeer a perf.data output immediately after a system call takes too
long or when we detect a losting of a display update.

Patch 28 - 40 add a switch-output mode, make perf dump a new perf.data
when it receive a SIGUSR2.

Patch 41 - 45 introduce a concept called 'channel', which allows perf to
collect data through more than one group of mmaped ring buffer with different
configurations.

Patch 46 - 53 are the core of flight record mode. Patch 51 does real
reading from flight recorder ring buffer.

[1] http://lkml.kernel.org/g/1452518653-1794-1-git-send-email-wangnan0@huawei.com

He Kuang (1):
  perf tools: Support perf event alias name

Jiri Olsa (1):
  perf tools: Add missing sources in perf's MANIFEST

Naveen N. Rao (1):
  perf: bpf: Fix build breakage due to libbpf

Wang Nan (50):
  perf tools: Add -lutil in python lib list for broken python-config
  perf tools: Fix phony build target for build-test
  perf tools: Set parallel making options build-test
  perf tools: Pass O option to Makefile.perf in build-test
  perf tools: Test correct path of perf in build-test
  perf tools: Fix PowerPC native building
  tools: Move Makefile.arch from perf/config to tools/scripts
  tools build: Add BPF feature check to test-all
  perf test: Fix false TEST_OK result for 'perf test hist'
  perf test: Reset err after using it hold errcode in hist testcases
  perf tools: Prevent calling machine__delete() on non-allocated machine
  perf test: Check environment before start real BPF test
  perf tools: Fix symbols searching for offline module in buildid-cache
  perf tools: Fix mmap2 event allocation in synthesize code
  perf test: Improve bp_signal
  perf tools: Add API to config maps in bpf object
  perf tools: Enable BPF object configure syntax
  perf record: Apply config to BPF objects before recording
  perf tools: Enable passing event to BPF object
  perf tools: Support setting different slots in a BPF map separately
  perf tools: Enable indices setting syntax for BPF maps
  perf tools: Introduce bpf-output event
  perf data: Support converting data from bpf_perf_event_output()
  perf/core: Put size of a sample at the end of it by
    PERF_SAMPLE_TAILSIZE
  perf tools: Move timestamp creation to util
  perf tools: Make ordered_events reusable
  perf record: Extract synthesize code to record__synthesize()
  perf tools: Add perf_data_file__switch() helper
  perf record: Turns auxtrace_snapshot_enable into 3 states
  perf record: Introduce record__finish_output() to finish a perf.data
  perf record: Use OPT_BOOLEAN_SET for buildid cache related options
  perf record: Add '--timestamp-filename' option to append timestamp to
    output filename
  perf record: Split output into multiple files via '--switch-output'
  perf record: Force enable --timestamp-filename when --switch-output is
    provided
  perf record: Disable buildid cache options by default in switch output
    mode
  perf record: Re-synthesize tracking events after output switching
  perf record: Generate tracking events for process forked by perf
  perf record: Ensure return non-zero rc when mmap fail
  perf record: Prevent reading invalid data in record__mmap_read
  perf tools: Add evlist channel helpers
  perf tools: Automatically add new channel according to evlist
  perf tools: Operate multiple channels
  perf tools: Squash overwrite setting into channel
  perf record: Don't read from and poll overwrite channel
  perf tools: Enable overwrite settings
  perf tools: Consider TAILSIZE bit when caclulate is_pos
  perf tools: Set tailsize attribut bit for overwrite events
  perf record: Read from tailsize ring buffer
  perf record: Toggle tailsize ring buffer for reading
  perf record: Allow generate tracking events at the end of output

 include/linux/perf_event.h                   |  17 +-
 include/uapi/linux/perf_event.h              |   3 +-
 kernel/events/core.c                         |  82 +++-
 kernel/events/ring_buffer.c                  |   7 +-
 tools/build/feature/test-all.c               |   5 +
 tools/build/feature/test-bpf.c               |  20 +-
 tools/lib/bpf/Makefile                       |  16 +-
 tools/lib/bpf/bpf.c                          |   4 +-
 tools/perf/MANIFEST                          |   2 +
 tools/perf/builtin-buildid-cache.c           |  14 +-
 tools/perf/builtin-record.c                  | 549 +++++++++++++++++----
 tools/perf/config/Makefile                   |   4 +-
 tools/perf/perf.h                            |   1 +
 tools/perf/tests/bp_signal.c                 | 140 +++++-
 tools/perf/tests/bpf.c                       |  37 ++
 tools/perf/tests/hists_common.c              |   5 -
 tools/perf/tests/hists_cumulate.c            |   1 +
 tools/perf/tests/hists_filter.c              |   1 +
 tools/perf/tests/hists_link.c                |   1 +
 tools/perf/tests/hists_output.c              |   1 +
 tools/perf/tests/make                        |  72 ++-
 tools/perf/tests/vmlinux-kallsyms.c          |   4 +-
 tools/perf/util/bpf-loader.c                 | 699 +++++++++++++++++++++++++++
 tools/perf/util/bpf-loader.h                 |  59 +++
 tools/perf/util/build-id.c                   |  44 ++
 tools/perf/util/build-id.h                   |   1 +
 tools/perf/util/data-convert-bt.c            | 112 ++++-
 tools/perf/util/data.c                       |  36 ++
 tools/perf/util/data.h                       |  11 +-
 tools/perf/util/event.c                      |  28 +-
 tools/perf/util/evlist.c                     | 307 ++++++++++--
 tools/perf/util/evlist.h                     |  67 ++-
 tools/perf/util/evsel.c                      |  42 +-
 tools/perf/util/evsel.h                      |  13 +
 tools/perf/util/machine.c                    |  13 +-
 tools/perf/util/machine.h                    |   3 +-
 tools/perf/util/ordered-events.c             |   9 +
 tools/perf/util/ordered-events.h             |   1 +
 tools/perf/util/parse-events.c               | 139 +++++-
 tools/perf/util/parse-events.h               |  24 +-
 tools/perf/util/parse-events.l               |  18 +-
 tools/perf/util/parse-events.y               | 123 ++++-
 tools/perf/util/session.c                    |   4 +-
 tools/perf/util/symbol.c                     |   4 +
 tools/perf/util/util.c                       |  17 +
 tools/perf/util/util.h                       |   1 +
 tools/{perf/config => scripts}/Makefile.arch |   0
 47 files changed, 2482 insertions(+), 279 deletions(-)
 rename tools/{perf/config => scripts}/Makefile.arch (100%)

-- 
1.8.3.4
