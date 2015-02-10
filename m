From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v3 linux-trace 0/8] tracing: attach eBPF programs to tracepoints/syscalls/kprobe
Date: Mon,  9 Feb 2015 19:45:53 -0800
Message-ID: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Steven,

This patch set is for linux-trace/for-next
It adds ability to attach eBPF programs to tracepoints, syscalls and kprobes.
Obviously too late for 3.20, but please review. I'll rebase and repost when
merge window closes.

Main difference in V3 is different attaching mechanism:
- load program via bpf() syscall and receive prog_fd
- event_fd = perf_event_open()
- ioctl(event_fd, PERF_EVENT_IOC_SET_BPF, prog_fd) to attach program to event
- close(event_fd) will destroy event and detach the program
kernel diff became smaller and in general this approach is cleaner
(thanks to Masami and Namhyung for suggesting it)

The programs are run before ring buffer is allocated to have minimal
impact on a system, which can be demonstrated by
'dd if=/dev/zero of=/dev/null count=20000000' test:
4.80074 s, 2.1 GB/s - no tracing (raw base line)
5.62705 s, 1.8 GB/s - attached bpf program does 'map[log2(count)]++' without JIT
5.05963 s, 2.0 GB/s - attached bpf program does 'map[log2(count)]++' with JIT
4.91715 s, 2.1 GB/s - attached bpf program does 'return 0'

perf record -e skb:sys_write dd if=/dev/zero of=/dev/null count=20000000
8.75686 s, 1.2 GB/s
Warning: Processed 20355236 events and lost 44 chunks!

perf record -e skb:sys_write --filter cnt==1234 dd if=/dev/zero of=/dev/null count=20000000
5.69732 s, 1.8 GB/s

6.13730 s, 1.7 GB/s - echo 1 > /sys/../events/skb/sys_write/enable
6.50091 s, 1.6 GB/s - echo 'cnt == 1234' > /sys/../events/skb/sys_write/filter

(skb:sys_write is a temporary tracepoint in write() syscall)

So the overhead of realistic bpf program is 5.05963/4.80074 = ~5%
which is faster than perf_event filtering: 5.69732/4.80074 = ~18%
or ftrace filtering: 6.50091/4.80074 = ~35%

V2->V3:
- changed program attach interface from tracefs into perf_event ioctl
- rewrote user space helpers to use perf_events
- rewrote tracex1 example to use mmap-ed ring_buffer instead of trace_pipe
- as suggested by Arnaldo renamed bpf_memcmp to bpf_probe_memcmp to better
  indicate function logic
- added ifdefs to make bpf check a nop when CONFIG_BPF_SYSCALL is not set

V1->V2:
- dropped bpf_dump_stack() and bpf_printk() helpers
- disabled running programs in_nmi
- other minor cleanups

Program attach point and input arguments:
- programs attached to kprobes receive 'struct pt_regs *' as an input.
  See tracex4_kern.c that demonstrates how users can write a C program like:
  SEC("events/kprobes/sys_write")
  int bpf_prog4(struct pt_regs *regs)
  {
     long write_size = regs->dx; 
     // here user need to know the proto of sys_write() from kernel
     // sources and x64 calling convention to know that register $rdx
     // contains 3rd argument to sys_write() which is 'size_t count'

  it's obviously architecture dependent, but allows building sophisticated
  user tools on top, that can see from debug info of vmlinux which variables
  are in which registers or stack locations and fetch it from there.
  'perf probe' can potentialy use this hook to generate programs in user space
  and insert them instead of letting kernel parse string during kprobe creation.

- programs attached to tracepoints and syscalls receive 'struct bpf_context *':
  u64 arg1, arg2, ..., arg6;
  for syscalls they match syscall arguments.
  for tracepoints these args match arguments passed to tracepoint.
  For example:
  trace_sched_migrate_task(p, new_cpu); from sched/core.c
  arg1 <- p        which is 'struct task_struct *'
  arg2 <- new_cpu  which is 'unsigned int'
  arg3..arg6 = 0
  the program can use bpf_fetch_u8/16/32/64/ptr() helpers to walk 'task_struct'
  or any other kernel data structures.
  These helpers are using probe_kernel_read() similar to 'perf probe' which is
  not 100% safe in both cases, but good enough.
  To access task_struct's pid inside 'sched_migrate_task' tracepoint
  the program can do:
  struct task_struct *task = (struct task_struct *)ctx->arg1;
  u32 pid = bpf_fetch_u32(&task->pid);
  Since struct layout is kernel configuration specific such programs are not
  portable and require access to kernel headers to be compiled,
  but in this case we don't need debug info.
  llvm with bpf backend will statically compute task->pid offset as a constant
  based on kernel headers only.
  The example of this arbitrary pointer walking is tracex1_kern.c
  which does skb->dev->name == "lo" filtering.

In all cases the programs are called before ring buffer is allocated to
minimize the overhead, since we want to filter huge number of events, but
perf_trace_buf_prepare/submit and argument copy for every event is too costly.

Note, tracepoint/syscall and kprobe programs are two different types:
BPF_PROG_TYPE_TRACEPOINT and BPF_PROG_TYPE_KPROBE,
since they expect different input.
Both use the same set of helper functions:
- map access (lookup/update/delete)
- fetch (probe_kernel_read wrappers)
- probe_memcmp (probe_kernel_read + memcmp)

Portability:
- kprobe programs are architecture dependent and need user scripting
  language like ktap/stap/dtrace/perf that will dynamically generate
  them based on debug info in vmlinux
- tracepoint programs are architecture independent, but if arbitrary pointer
  walking (with fetch() helpers) is used, they need data struct layout to match.
  Debug info is not necessary
- for networking use case we need to access 'struct sk_buff' fields in portable
  way (user space needs to fetch packet length without knowing layout of sk_buff),
  so for some frequently used data structures there will be a way to access them
  effeciently without bpf_fetch* helpers. Once it's ready tracepoint programs
  that access common data structs will be kernel independent.

Program return value:
- programs return 0 to discard an event
- and return non-zero to proceed with event (get ring buffer, copy
  arguments there and pass to user space via mmap-ed area)

Examples:
- dropmon.c - simple kfree_skb() accounting in eBPF assembler, similar
  to dropmon tool
- tracex1_kern.c - does net/netif_receive_skb event filtering
  for dev->skb->name == "lo" condition
  trace1_user.c - receives PERF_SAMPLE_RAW events into mmap-ed buffer and
  prints them
- tracex2_kern.c - same kfree_skb() accounting like dropmon, but now in C
  plus computes histogram of all write sizes from sys_write syscall
  and prints the histogram in userspace
- tracex3_kern.c - most sophisticated example that computes IO latency
  between block/block_rq_issue and block/block_rq_complete events
  and prints 'heatmap' using gray shades of text terminal.
  Useful to analyze disk performance.
- tracex4_kern.c - computes histogram of write sizes from sys_write syscall
  using kprobe mechanism instead of syscall. Since kprobe is optimized into
  ftrace the overhead of instrumentation is smaller than in example 2.

The user space tools like ktap/dtrace/systemptap/perf that has access
to debug info would probably want to use kprobe attachment point, since kprobe
can be inserted anywhere and all registers are avaiable in the program.
tracepoint attachments are useful without debug info, so standalone tools
like iosnoop will use them.

The main difference vs existing perf_probe/ftrace infra is in kernel aggregation
and conditional walking of arbitrary data structures.

Thanks!

Alexei Starovoitov (8):
  tracing: attach eBPF programs to tracepoints and syscalls
  tracing: allow eBPF programs to call ktime_get_ns()
  samples: bpf: simple tracing example in eBPF assembler
  samples: bpf: simple tracing example in C
  samples: bpf: counting example for kfree_skb tracepoint and write
    syscall
  samples: bpf: IO latency analysis (iosnoop/heatmap)
  tracing: attach eBPF programs to kprobe/kretprobe
  samples: bpf: simple kprobe example

 include/linux/bpf.h             |    6 +-
 include/linux/ftrace_event.h    |   14 +++
 include/trace/bpf_trace.h       |   25 +++++
 include/trace/ftrace.h          |   31 +++++++
 include/uapi/linux/bpf.h        |    9 ++
 include/uapi/linux/perf_event.h |    1 +
 kernel/events/core.c            |   58 ++++++++++++
 kernel/trace/Makefile           |    1 +
 kernel/trace/bpf_trace.c        |  194 +++++++++++++++++++++++++++++++++++++++
 kernel/trace/trace_kprobe.c     |   10 +-
 kernel/trace/trace_syscalls.c   |   35 +++++++
 samples/bpf/Makefile            |   18 ++++
 samples/bpf/bpf_helpers.h       |   14 +++
 samples/bpf/bpf_load.c          |  136 +++++++++++++++++++++++++--
 samples/bpf/bpf_load.h          |   12 +++
 samples/bpf/dropmon.c           |  143 +++++++++++++++++++++++++++++
 samples/bpf/libbpf.c            |    7 ++
 samples/bpf/libbpf.h            |    4 +
 samples/bpf/tracex1_kern.c      |   28 ++++++
 samples/bpf/tracex1_user.c      |   50 ++++++++++
 samples/bpf/tracex2_kern.c      |   71 ++++++++++++++
 samples/bpf/tracex2_user.c      |   95 +++++++++++++++++++
 samples/bpf/tracex3_kern.c      |   98 ++++++++++++++++++++
 samples/bpf/tracex3_user.c      |  152 ++++++++++++++++++++++++++++++
 samples/bpf/tracex4_kern.c      |   36 ++++++++
 samples/bpf/tracex4_user.c      |   83 +++++++++++++++++
 26 files changed, 1321 insertions(+), 10 deletions(-)
 create mode 100644 include/trace/bpf_trace.h
 create mode 100644 kernel/trace/bpf_trace.c
 create mode 100644 samples/bpf/dropmon.c
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
