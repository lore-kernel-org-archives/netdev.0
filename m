From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH v7 0/5] bpf: Introduce the new ability of eBPF programs to access hardware PMU counter
Date: Thu, 6 Aug 2015 07:02:31 +0000
Message-ID: <1438844556-27064-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xiakaixu@huawei.com>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: <ast@plumgrid.com>, <davem@davemloft.net>, <acme@kernel.org>,
	<mingo@redhat.com>, <a.p.zijlstra@chello.nl>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset is base on the net-next:
 git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
commit 9dc20a649609c95ce7c5ac4282656ba627b67d49.

Previous patch v6 url:
https://lkml.org/lkml/2015/8/4/188

changes in V7:
 - rebase the whole patch set to net-next tree(9dc20a64);
 - split out the core perf APIs into Patch 1/5;
 - change the return value of function perf_event_attrs()
   from struct perf_event * to const struct perf_event * in
   Patch 1/5;
 - rename the function perf_event_read_internal() to perf_event_
   read_local() and rewrite it in Patch 1/5;
 - rename the function check_func_limit() to check_map_func
   _compatibility() and remove the unnecessary pass pointer to
   a pointer in Patch 4/5;

changes in V6: 
 - make the Patch 1/4 commit message more meaning and readable;
 - remove the unnecessary comment in Patch 2/4 and make it clean;
 - declare the function perf_event_release_kernel() in include/
   linux/perf_event.h to fix the build error when CONFIG_PERF_EVENTS
   isn't configured in Patch 2/4;
 - add function perf_event_attrs() to get the struct perf_event_attr
   in Patch 2/4. 
 - move the related code from kernel/trace/bpf_trace.c to kernel/
   events/core.c and add function perf_event_read_internal() to
   avoid poking inside of the event outside of perf code in Patch 3/4;
 - generial the func & map match-pair with an array in Patch 3/4;

changes in V5: 
 - move struct fd_array_map_ops* fd_ops to bpf_map;
 - move array perf event decrement refcnt function to
   map_free;
 - fix the NULL ptr of perf_event_get();
 - move bpf_perf_event_read() to kernel/bpf/bpf_trace.c;
 - get rid of the remaining struct bpf_prog;
 - move the unnecessay cast on void *;

changes in V4: 
 - make the bpf_prog_array_map more generic;
 - fix the bug of event refcnt leak;
 - use more useful errno in bpf_perf_event_read();

changes in V3: 
 - collapse V2 patches 1-3 into one;
 - drop the function map->ops->map_traverse_elem() and release
   the struct perf_event in map_free;
 - only allow to access bpf_perf_event_read() from programs;
 - update the perf_event_array_map elem via xchg();
 - pass index directly to bpf_perf_event_read() instead of
   MAP_KEY;

changes in V2:
 - put atomic_long_inc_not_zero() between fdget() and fdput();
 - limit the event type to PERF_TYPE_RAW and PERF_TYPE_HARDWARE;
 - Only read the event counter on current CPU or on current
   process;
 - add new map type BPF_MAP_TYPE_PERF_EVENT_ARRAY to store the
   pointer to the struct perf_event;
 - according to the perf_event_map_fd and key, the function
   bpf_perf_event_read() can get the Hardware PMU counter value;

Patch 5/5 is a simple example and shows how to use this new eBPF
programs ability. The PMU counter data can be found in
/sys/kernel/debug/tracing/trace(trace_pipe).(the cycles PMU
value when 'kprobe/sys_write' sampling)

  $ cat /sys/kernel/debug/tracing/trace_pipe
  $ ./tracex6
       ...
       syslog-ng-548   [000] d..1    76.905673: : CPU-0   681765271
       syslog-ng-548   [000] d..1    76.905690: : CPU-0   681787855
       syslog-ng-548   [000] d..1    76.905707: : CPU-0   681810504
       syslog-ng-548   [000] d..1    76.905725: : CPU-0   681834771
       syslog-ng-548   [000] d..1    76.905745: : CPU-0   681859519
       syslog-ng-548   [000] d..1    76.905766: : CPU-0   681890419
       syslog-ng-548   [000] d..1    76.905783: : CPU-0   681914045
       syslog-ng-548   [000] d..1    76.905800: : CPU-0   681935950
       syslog-ng-548   [000] d..1    76.905816: : CPU-0   681958299
              ls-690   [005] d..1    82.241308: : CPU-5   3138451
              sh-691   [004] d..1    82.244570: : CPU-4   7324988
           <...>-699   [007] d..1    99.961387: : CPU-7   3194027
           <...>-695   [003] d..1    99.961474: : CPU-3   288901
           <...>-695   [003] d..1    99.961541: : CPU-3   383145
           <...>-695   [003] d..1    99.961591: : CPU-3   450365
           <...>-695   [003] d..1    99.961639: : CPU-3   515751
           <...>-695   [003] d..1    99.961686: : CPU-3   579047
       ...

The detail of patches is as follow:

Patch 1/5 add the necessary core perf APIs perf_event_attrs(),
perf_event_get(),perf_event_read_local() when accessing events
counters in eBPF programs

Patch 2/5 rewrites part of the bpf_prog_array map code and make it
more generic;

Patch 3/5 introduces a new bpf map type. This map only stores the
pointer to struct perf_event;

Patch 4/5 implements function bpf_perf_event_read() that get the
selected hardware PMU conuter;

Patch 5/5 gives a simple example.

Kaixu Xia (4):
  perf: add the necessary core perf APIs when accessing events counters
    in eBPF programs
  bpf: Add new bpf map type to store the pointer to struct perf_event
  bpf: Implement function bpf_perf_event_read() that get the selected
    hardware PMU conuter
  samples/bpf: example of get selected PMU counter value

Wang Nan (1):
  bpf: Make the bpf_prog_array_map more generic

 arch/x86/net/bpf_jit_comp.c |   6 +-
 include/linux/bpf.h         |  10 +++-
 include/linux/perf_event.h  |  10 ++++
 include/uapi/linux/bpf.h    |   2 +
 kernel/bpf/arraymap.c       | 137 ++++++++++++++++++++++++++++++++++----------
 kernel/bpf/core.c           |   2 +-
 kernel/bpf/syscall.c        |   2 +-
 kernel/bpf/verifier.c       |  48 +++++++++++-----
 kernel/events/core.c        |  78 +++++++++++++++++++++++++
 kernel/trace/bpf_trace.c    |  31 ++++++++++
 samples/bpf/Makefile        |   4 ++
 samples/bpf/bpf_helpers.h   |   2 +
 samples/bpf/tracex6_kern.c  |  26 +++++++++
 samples/bpf/tracex6_user.c  |  68 ++++++++++++++++++++++
 14 files changed, 373 insertions(+), 53 deletions(-)
 create mode 100644 samples/bpf/tracex6_kern.c
 create mode 100644 samples/bpf/tracex6_user.c

-- 
1.8.3.4
