From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 linux-trace 0/8] tracing: attach eBPF programs to tracepoints/syscalls/kprobe
Date: Tue, 27 Jan 2015 20:06:05 -0800
Message-ID: <1422417973-10195-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Steven,

This patch set is for linux-trace/for-next
It adds ability to attach eBPF programs to tracepoints, syscalls and kprobes.

The programs are run after soft_disabled() check, but before trace_buffer
is allocated to have minimal impact on a system, which can be demonstrated
by 'dd if=/dev/zero of=/dev/null count=5000000' test:
1.19343 s, 2.1 GB/s - no tracing (raw base line)
1.53301 s, 1.7 GB/s - echo 1 > enable
1.62742 s, 1.6 GB/s - echo cnt==1234 > filter
1.23418 s, 2.1 GB/s - attached bpf program does 'return 0'
1.25890 s, 2.0 GB/s - attached bpf program does 'map[log2(count)]++'

Though tracex1 example is an example of event/filter equivalent logic,
should we create a new file '/sys/.../tracing/events/.../bpf' and use
that for attaching instead of overloading 'filter' file meaning?
That will move bpf related logic out of trace_events_filter.c into new
file and we'll be able to use both bpf program as a 'pre filter' and
existing filter code that runs on allocated trace_buffer at the same time.
In this patch set bpf programs co-exist with TP_printk and triggers.

Anyway, resending with accumulated fixes:
V1->V2:
- dropped bpf_dump_stack() and bpf_printk() helpers,
  trigger 'stacktrace' can be used instead of bpf_dump_stack()
- disabled running programs in_nmi
- other minor cleanups

V1 cover letter:
----------------
Mechanism of attaching:
- load program via bpf() syscall and receive program_fd
- event_fd = open("/sys/kernel/debug/tracing/events/.../filter")
- write 'bpf-123' to event_fd where 123 is program_fd
- program will be attached to particular event and event automatically enabled
- close(event_fd) will detach bpf program from event and event disabled

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

In all cases the programs are called before trace buffer is allocated to
minimize the overhead, since we want to filter huge number of events, but
buffer alloc/free and argument copy for every event is too costly.
Theoretically we can invoke programs after buffer is allocated, but it
doesn't seem needed, since above approach is faster and achieves the same.

Note, tracepoint/syscall and kprobe programs are two different types:
BPF_PROG_TYPE_TRACING_FILTER and BPF_PROG_TYPE_KPROBE_FILTER,
since they expect different input.
Both use the same set of helper functions:
- map access (lookup/update/delete)
- fetch (probe_kernel_read wrappers)
- memcmp (probe_kernel_read + memcmp)

Portability:
- kprobe programs are architecture dependent and need user scripting
  language like ktap/stap/dtrace/perf that will dynamically generate
  them based on debug info in vmlinux
- tracepoint programs are architecture independent, but if arbitrary pointer
  walking (with fetch() helpers) is used, they need data struct layout to match.
  Debug info is not necessary
- for networking use case we need to access 'struct sk_buff' fields in portable
  way (user space needs to fetch packet length without knowing skb->len offset),
  so for some frequently used data structures we will add helper functions
  or pseudo instructions to access them. I've hacked few ways specifically
  for skb, but abandoned them in favor of more generic type/field infra.
  That work is still wip. Not part of this set.
  Once it's ready tracepoint programs that access common data structs
  will be kernel independent.

Program return value:
- programs return 0 to discard an event
- and return non-zero to proceed with event (allocate trace buffer, copy
  arguments there and print it eventually in trace_pipe in traditional way)

Examples:
- dropmon.c - simple kfree_skb() accounting in eBPF assembler, similar
  to dropmon tool
- tracex1_kern.c - does net/netif_receive_skb event filtering
  for dev->skb->name == "lo" condition
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

 include/linux/ftrace_event.h       |    6 ++
 include/trace/bpf_trace.h          |   25 +++++
 include/trace/ftrace.h             |   29 ++++++
 include/uapi/linux/bpf.h           |    9 ++
 kernel/trace/Kconfig               |    1 +
 kernel/trace/Makefile              |    1 +
 kernel/trace/bpf_trace.c           |  178 ++++++++++++++++++++++++++++++++++++
 kernel/trace/trace.h               |    3 +
 kernel/trace/trace_events.c        |   33 ++++++-
 kernel/trace/trace_events_filter.c |   83 ++++++++++++++++-
 kernel/trace/trace_kprobe.c        |   11 ++-
 kernel/trace/trace_syscalls.c      |   31 +++++++
 samples/bpf/Makefile               |   18 ++++
 samples/bpf/bpf_helpers.h          |   14 +++
 samples/bpf/bpf_load.c             |   62 +++++++++++--
 samples/bpf/bpf_load.h             |    3 +
 samples/bpf/dropmon.c              |  129 ++++++++++++++++++++++++++
 samples/bpf/tracex1_kern.c         |   28 ++++++
 samples/bpf/tracex1_user.c         |   24 +++++
 samples/bpf/tracex2_kern.c         |   71 ++++++++++++++
 samples/bpf/tracex2_user.c         |   95 +++++++++++++++++++
 samples/bpf/tracex3_kern.c         |   92 +++++++++++++++++++
 samples/bpf/tracex3_user.c         |  150 ++++++++++++++++++++++++++++++
 samples/bpf/tracex4_kern.c         |   36 ++++++++
 samples/bpf/tracex4_user.c         |   83 +++++++++++++++++
 25 files changed, 1206 insertions(+), 9 deletions(-)
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
