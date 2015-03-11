From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v6 tip 0/8] tracing: attach eBPF programs to kprobes
Date: Tue, 10 Mar 2015 21:18:46 -0700
Message-ID: <1426047534-8148-1-git-send-email-ast@plumgrid.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:42218 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbbCKETI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 00:19:08 -0400
Received: by padfa1 with SMTP id fa1so7920674pad.9
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 21:19:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ingo, Steven, Peter,

Please review/ack. Thanks!

V5->V6:
- added simple recursion check to trace_call_bpf()
- added tracex4 example that does kmem_cache_alloc/free tracking.
  It remembers every allocated object in a map and user space periodically
  prints a set of old objects. With more work in can be made into
  simple kmemleak detector.
  It was used as a test of recursive kmalloc/kfree: attached to
  kprobe/__kmalloc and let program to call kmalloc again.

V4->V5:
- switched to ktime_get_mono_fast_ns() as suggested by Peter
- in libbpf.c fixed zero init of 'union bpf_attr' padding
- fresh rebase on tip/master

This is targeting 'tip' tree, since most of the changes are perf_event related.
There will be a small conflict between net-next and tip, since they both
add new bpf_prog_type (BPF_PROG_TYPE_SCHED_CLS and BPF_PROG_TYPE_KPROBE).

V3 discussion:
https://lkml.org/lkml/2015/2/9/738

V3->V4:
- since the boundary of stable ABI in bpf+tracepoints is not clear yet,
  I've dropped them for now.
- bpf+syscalls are ok from stable ABI point of view, but bpf+seccomp
  would want to do very similar analysis of syscalls, so I've dropped
  them as well to take time and define common bpf+syscalls and bpf+seccomp
  infra in the future.
- so only bpf+kprobes left. kprobes by definition is not a stable ABI,
  so bpf+kprobe is not stable ABI either. To stress on that point added
  kernel version attribute that user space must pass along with the program
  and kernel will reject programs when version code doesn't match.
  So bpf+kprobe is very similar to kernel modules, but unlike modules
  version check is not used for safety, but for enforcing 'non-ABI-ness'.
  (version check doesn't apply to bpf+sockets which are stable)

Patch 1 is in net-next and needs to be in tip too, since patch 2 depends on it.

Patch 2 actually adds bpf+kprobe infra:
programs receive 'struct pt_regs' on input and can walk data structures
using bpf_probe_read() helper which is a wrapper of probe_kernel_read()

Programs are attached to kprobe events via API:

prog_fd = bpf_prog_load(...);
struct perf_event_attr attr = {
  .type = PERF_TYPE_TRACEPOINT,
  .config = event_id, /* ID of just created kprobe event */
};
event_fd = perf_event_open(&attr,...);
ioctl(event_fd, PERF_EVENT_IOC_SET_BPF, prog_fd);

Patch 3 adds bpf_ktime_get_ns() helper function, so that bpf programs can
measure time delta between events to compute disk io latency, etc.

Patch 4 adds bpf_trace_printk() helper that is used to debug programs.
When bpf verifier sees that program is calling bpf_trace_printk() it inits
trace_printk buffers which emits nasty 'this is debug only' banner.
That's exactly what we want. bpf_trace_printk() is for debugging only.

Patch 5 sample code that shows how to use bpf_probe_read/bpf_trace_printk

Patch 6 sample code - combination of kfree_skb and sys_write tracing.

Patch 7 sample code that computes disk io latency and prints it as 'heatmap'

Interesting bit is that patch 6 has log2() function implemented in C
and patch 7 has another log2() function using different algorithm in C.
In the future if 'log2' usage becomes common, we can add it as in-kernel
helper function, but for now bpf programs can implement them on bpf side.

Another interesting bit from patch 7 is that it does approximation of
floating point log10(X)*10 using integer arithmetic, which demonstrates
the power of C->BPF vs traditional tracing language alternatives,
where one would need to introduce new helper functions to add functionality,
whereas bpf can just implement such things in C as part of the program.

Next step is to prototype TCP stack instrumentation (like web10g) using
bpf+kprobe, but without adding any new code tcp stack.
Though kprobes are slow comparing to tracepoints, they are good enough
for prototyping and trace_marker/debug_tracepoint ideas can accelerate
them in the future.

Alexei Starovoitov (7):
  tracing: attach BPF programs to kprobes
  tracing: allow BPF programs to call bpf_ktime_get_ns()
  tracing: allow BPF programs to call bpf_trace_printk()
  samples: bpf: simple non-portable kprobe filter example
  samples: bpf: counting example for kfree_skb and write syscall
  samples: bpf: IO latency analysis (iosnoop/heatmap)
  samples: bpf: kmem_alloc/free tracker

Daniel Borkmann (1):
  bpf: make internal bpf API independent of CONFIG_BPF_SYSCALL ifdefs

 include/linux/bpf.h             |   20 +++-
 include/linux/ftrace_event.h    |   14 +++
 include/uapi/linux/bpf.h        |    5 +
 include/uapi/linux/perf_event.h |    1 +
 kernel/bpf/syscall.c            |    7 +-
 kernel/events/core.c            |   59 ++++++++++++
 kernel/trace/Makefile           |    1 +
 kernel/trace/bpf_trace.c        |  198 +++++++++++++++++++++++++++++++++++++++
 kernel/trace/trace_kprobe.c     |   10 +-
 samples/bpf/Makefile            |   16 ++++
 samples/bpf/bpf_helpers.h       |    6 ++
 samples/bpf/bpf_load.c          |  125 ++++++++++++++++++++++--
 samples/bpf/bpf_load.h          |    3 +
 samples/bpf/libbpf.c            |   14 ++-
 samples/bpf/libbpf.h            |    5 +-
 samples/bpf/sock_example.c      |    2 +-
 samples/bpf/test_verifier.c     |    2 +-
 samples/bpf/tracex1_kern.c      |   50 ++++++++++
 samples/bpf/tracex1_user.c      |   25 +++++
 samples/bpf/tracex2_kern.c      |   86 +++++++++++++++++
 samples/bpf/tracex2_user.c      |   95 +++++++++++++++++++
 samples/bpf/tracex3_kern.c      |   89 ++++++++++++++++++
 samples/bpf/tracex3_user.c      |  150 +++++++++++++++++++++++++++++
 samples/bpf/tracex4_kern.c      |   54 +++++++++++
 samples/bpf/tracex4_user.c      |   69 ++++++++++++++
 25 files changed, 1088 insertions(+), 18 deletions(-)
 create mode 100644 kernel/trace/bpf_trace.c
 create mode 100644 samples/bpf/tracex1_kern.c
 create mode 100644 samples/bpf/tracex1_user.c
 create mode 100644 samples/bpf/tracex2_kern.c
 create mode 100644 samples/bpf/tracex2_user.c
 create mode 100644 samples/bpf/tracex3_kern.c
 create mode 100644 samples/bpf/tracex3_user.c
 create mode 100644 samples/bpf/tracex4_kern.c
 create mode 100644 samples/bpf/tracex4_user.c

-- 
1.7.9.5
