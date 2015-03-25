From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v11 tip 0/9] tracing: attach eBPF programs to kprobes
Date: Wed, 25 Mar 2015 12:49:17 -0700
Message-ID: <1427312966-8434-1-git-send-email-ast@plumgrid.com>
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Ingo,

Patch 1 is already in net-next. Patch 3 depends on it.
I'm assuming it's not going to be a problem during merge window.
Patch 3 will have a minor conflict in uapi/linux/bpf.h in linux-next,
since net-next has added new lines to the bpf_prog_type and bpf_func_id enums.
I'm assuming it's not a problem either.

V10->V11:
- added Masami's Reviewed-by to main patch 3. Thanks Masami!
- fixed sz>0 in samples
- reworded few comments and fixed typos
- rebased

V9->V10:
- prettified formatting of struct intializers in kernel
- added Masami's Reviewed-by. Thanks Masami!

V8->V9:
- fixed comment style and allowed ispunct after %p
- added Steven's Reviewed-by. Thanks Steven!

V7->V8:
- split addition of kprobe flag into separate patch
- switched to __this_cpu_inc in now documented trace_call_bpf()
- converted array into standalone bpf_func_proto and switch statement
  (this apporach looks cleanest, especially considering patch 5)
- refactored patch 5 bpf_trace_printk to do strict checking

V6->V7:
- rebase and remove confusing _notrace suffix from preempt_disable/enable
  everything else unchanged

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

Programs are attached to kprobe events via API:

prog_fd = bpf_prog_load(...);
struct perf_event_attr attr = {
  .type = PERF_TYPE_TRACEPOINT,
  .config = event_id, /* ID of just created kprobe event */
};
event_fd = perf_event_open(&attr,...);
ioctl(event_fd, PERF_EVENT_IOC_SET_BPF, prog_fd);

Next step is to prototype TCP stack instrumentation (like web10g) using
bpf+kprobe, but without adding any new code tcp stack.
Though kprobes are slow comparing to tracepoints, they are good enough
for prototyping and trace_marker/debug_tracepoint ideas can accelerate
them in the future.

Alexei Starovoitov (8):
  tracing: add kprobe flag
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
 kernel/events/core.c            |   59 +++++++++++
 kernel/trace/Makefile           |    1 +
 kernel/trace/bpf_trace.c        |  222 +++++++++++++++++++++++++++++++++++++++
 kernel/trace/trace_kprobe.c     |   10 +-
 samples/bpf/Makefile            |   16 +++
 samples/bpf/bpf_helpers.h       |    6 ++
 samples/bpf/bpf_load.c          |  125 ++++++++++++++++++++--
 samples/bpf/bpf_load.h          |    3 +
 samples/bpf/libbpf.c            |   14 ++-
 samples/bpf/libbpf.h            |    5 +-
 samples/bpf/sock_example.c      |    2 +-
 samples/bpf/test_verifier.c     |    2 +-
 samples/bpf/tracex1_kern.c      |   50 +++++++++
 samples/bpf/tracex1_user.c      |   25 +++++
 samples/bpf/tracex2_kern.c      |   86 +++++++++++++++
 samples/bpf/tracex2_user.c      |   95 +++++++++++++++++
 samples/bpf/tracex3_kern.c      |   89 ++++++++++++++++
 samples/bpf/tracex3_user.c      |  150 ++++++++++++++++++++++++++
 samples/bpf/tracex4_kern.c      |   54 ++++++++++
 samples/bpf/tracex4_user.c      |   69 ++++++++++++
 25 files changed, 1112 insertions(+), 18 deletions(-)
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
