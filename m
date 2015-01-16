From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH tip 0/9] tracing: attach eBPF programs to
 tracepoints/syscalls/kprobe
Date: Fri, 16 Jan 2015 10:02:07 -0500
Message-ID: <20150116100207.581e6901@gandalf.local.home>
References: <1421381770-4866-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421381770-4866-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Jan 2015 20:16:01 -0800
Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:

> Hi Ingo, Steven,
> 
> This patch set is based on tip/master.

Note, the tracing code isn't maintained in tip/master, but perf code is.

Using the latest 3.19-rc is probably sufficient for now.

Do you have a git repo somewhere that I can look at? It makes it easier
than loading in 9 patches ;-)

> It adds ability to attach eBPF programs to tracepoints, syscalls and kprobes.
> 
> Mechanism of attaching:
> - load program via bpf() syscall and receive program_fd
> - event_fd = open("/sys/kernel/debug/tracing/events/.../filter")
> - write 'bpf-123' to event_fd where 123 is program_fd
> - program will be attached to particular event and event automatically enabled
> - close(event_fd) will detach bpf program from event and event disabled
> 
> Program attach point and input arguments:
> - programs attached to kprobes receive 'struct pt_regs *' as an input.
>   See tracex4_kern.c that demonstrates how users can write a C program like:
>   SEC("events/kprobes/sys_write")
>   int bpf_prog4(struct pt_regs *regs)
>   {
>      long write_size = regs->dx; 
>      // here user need to know the proto of sys_write() from kernel
>      // sources and x64 calling convention to know that register $rdx
>      // contains 3rd argument to sys_write() which is 'size_t count'
> 
>   it's obviously architecture dependent, but allows building sophisticated
>   user tools on top, that can see from debug info of vmlinux which variables
>   are in which registers or stack locations and fetch it from there.
>   'perf probe' can potentialy use this hook to generate programs in user space
>   and insert them instead of letting kernel parse string during kprobe creation.
> 
> - programs attached to tracepoints and syscalls receive 'struct bpf_context *':
>   u64 arg1, arg2, ..., arg6;
>   for syscalls they match syscall arguments.
>   for tracepoints these args match arguments passed to tracepoint.
>   For example:
>   trace_sched_migrate_task(p, new_cpu); from sched/core.c
>   arg1 <- p        which is 'struct task_struct *'
>   arg2 <- new_cpu  which is 'unsigned int'
>   arg3..arg6 = 0
>   the program can use bpf_fetch_u8/16/32/64/ptr() helpers to walk 'task_struct'
>   or any other kernel data structures.
>   These helpers are using probe_kernel_read() similar to 'perf probe' which is
>   not 100% safe in both cases, but good enough.
>   To access task_struct's pid inside 'sched_migrate_task' tracepoint
>   the program can do:
>   struct task_struct *task = (struct task_struct *)ctx->arg1;
>   u32 pid = bpf_fetch_u32(&task->pid);
>   Since struct layout is kernel configuration specific such programs are not
>   portable and require access to kernel headers to be compiled,
>   but in this case we don't need debug info.
>   llvm with bpf backend will statically compute task->pid offset as a constant
>   based on kernel headers only.
>   The example of this arbitrary pointer walking is tracex1_kern.c
>   which does skb->dev->name == "lo" filtering.
> 
> In all cases the programs are called before trace buffer is allocated to
> minimize the overhead, since we want to filter huge number of events, but
> buffer alloc/free and argument copy for every event is too costly.

For syscalls this is fine as the parameters are usually set. But
there's a lot of tracepoints that we need to know the result of the
copied data to decide to filter or not, where the result happens at the
TP_fast_assign() part which requires allocating the buffers.

Maybe we should have a way to do the program before and/or after the
buffering depending on what to filter on. There's no way to know what
the parameters of the tracepoint are without looking at the source.



> Theoretically we can invoke programs after buffer is allocated, but it
> doesn't seem needed, since above approach is faster and achieves the same.

Again, for syscalls it may not be a problem, but for other tracepoints,
I'm not sure we can do that. How do you handle sched_switch for
example? The tracepoint only gets two pointers to task structs, you
need to then dereference them to get the pid, prio, state and other
data.

> 
> Note, tracepoint/syscall and kprobe programs are two different types:
> BPF_PROG_TYPE_TRACING_FILTER and BPF_PROG_TYPE_KPROBE_FILTER,
> since they expect different input.
> Both use the same set of helper functions:
> - map access (lookup/update/delete)
> - fetch (probe_kernel_read wrappers)
> - memcmp (probe_kernel_read + memcmp)
> - dump_stack
> - trace_printk
> The last two are mainly to debug the programs and to print data for user
> space consumptions.

I have to look at the code, but currently trace_printk() isn't made to
be used in production systems.

> 
> Portability:
> - kprobe programs are architecture dependent and need user scripting
>   language like ktap/stap/dtrace/perf that will dynamically generate
>   them based on debug info in vmlinux
> - tracepoint programs are architecture independent, but if arbitrary pointer
>   walking (with fetch() helpers) is used, they need data struct layout to match.
>   Debug info is not necessary

If the program runs after the buffers are allocated, it could still be
architecture independent because ftrace gives the information on how to
retrieve the fields.

One last thing. If the ebpf is used for anything but filtering, it
should go into the trigger file. The filtering is only a way to say if
the event should be recorded or not. But the trigger could do something
else (a printk, a stacktrace, etc).

-- Steve


> - for networking use case we need to access 'struct sk_buff' fields in portable
>   way (user space needs to fetch packet length without knowing skb->len offset),
>   so for some frequently used data structures we will add helper functions
>   or pseudo instructions to access them. I've hacked few ways specifically
>   for skb, but abandoned them in favor of more generic type/field infra.
>   That work is still wip. Not part of this set.
>   Once it's ready tracepoint programs that access common data structs
>   will be kernel independent.
> 
> Program return value:
> - programs return 0 to discard an event
> - and return non-zero to proceed with event (allocate trace buffer, copy
>   arguments there and print it eventually in trace_pipe in traditional way)
> 
> Examples:
> - dropmon.c - simple kfree_skb() accounting in eBPF assembler, similar
>   to dropmon tool
> - tracex1_kern.c - does net/netif_receive_skb event filtering
>   for dev->skb->name == "lo" condition
> - tracex2_kern.c - same kfree_skb() accounting like dropmon, but now in C
>   plus computes histogram of all write sizes from sys_write syscall
>   and prints the histogram in userspace
> - tracex3_kern.c - most sophisticated example that computes IO latency
>   between block/block_rq_issue and block/block_rq_complete events
>   and prints 'heatmap' using gray shades of text terminal.
>   Useful to analyze disk performance.
> - tracex4_kern.c - computes histogram of write sizes from sys_write syscall
>   using kprobe mechanism instead of syscall. Since kprobe is optimized into
>   ftrace the overhead of instrumentation is smaller than in example 2.
> 
> The user space tools like ktap/dtrace/systemptap/perf that has access
> to debug info would probably want to use kprobe attachment point, since kprobe
> can be inserted anywhere and all registers are avaiable in the program.
> tracepoint attachments are useful without debug info, so standalone tools
> like iosnoop will use them.
> 
> The main difference vs existing perf_probe/ftrace infra is in kernel aggregation
> and conditional walking of arbitrary data structures.
> 
> Thanks!
> 
> Alexei Starovoitov (9):
>   tracing: attach eBPF programs to tracepoints and syscalls
>   tracing: allow eBPF programs to call bpf_printk()
>   tracing: allow eBPF programs to call ktime_get_ns()
>   samples: bpf: simple tracing example in eBPF assembler
>   samples: bpf: simple tracing example in C
>   samples: bpf: counting example for kfree_skb tracepoint and write
>     syscall
>   samples: bpf: IO latency analysis (iosnoop/heatmap)
>   tracing: attach eBPF programs to kprobe/kretprobe
>   samples: bpf: simple kprobe example
> 
>  include/linux/ftrace_event.h       |    6 +
>  include/trace/bpf_trace.h          |   25 ++++
>  include/trace/ftrace.h             |   30 +++++
>  include/uapi/linux/bpf.h           |   11 ++
>  kernel/trace/Kconfig               |    1 +
>  kernel/trace/Makefile              |    1 +
>  kernel/trace/bpf_trace.c           |  250 ++++++++++++++++++++++++++++++++++++
>  kernel/trace/trace.h               |    3 +
>  kernel/trace/trace_events.c        |   41 +++++-
>  kernel/trace/trace_events_filter.c |   80 +++++++++++-
>  kernel/trace/trace_kprobe.c        |   11 +-
>  kernel/trace/trace_syscalls.c      |   31 +++++
>  samples/bpf/Makefile               |   18 +++
>  samples/bpf/bpf_helpers.h          |   18 +++
>  samples/bpf/bpf_load.c             |   62 ++++++++-
>  samples/bpf/bpf_load.h             |    3 +
>  samples/bpf/dropmon.c              |  129 +++++++++++++++++++
>  samples/bpf/tracex1_kern.c         |   28 ++++
>  samples/bpf/tracex1_user.c         |   24 ++++
>  samples/bpf/tracex2_kern.c         |   71 ++++++++++
>  samples/bpf/tracex2_user.c         |   95 ++++++++++++++
>  samples/bpf/tracex3_kern.c         |   96 ++++++++++++++
>  samples/bpf/tracex3_user.c         |  146 +++++++++++++++++++++
>  samples/bpf/tracex4_kern.c         |   36 ++++++
>  samples/bpf/tracex4_user.c         |   83 ++++++++++++
>  25 files changed, 1290 insertions(+), 9 deletions(-)
>  create mode 100644 include/trace/bpf_trace.h
>  create mode 100644 kernel/trace/bpf_trace.c
>  create mode 100644 samples/bpf/dropmon.c
>  create mode 100644 samples/bpf/tracex1_kern.c
>  create mode 100644 samples/bpf/tracex1_user.c
>  create mode 100644 samples/bpf/tracex2_kern.c
>  create mode 100644 samples/bpf/tracex2_user.c
>  create mode 100644 samples/bpf/tracex3_kern.c
>  create mode 100644 samples/bpf/tracex3_user.c
>  create mode 100644 samples/bpf/tracex4_kern.c
>  create mode 100644 samples/bpf/tracex4_user.c
> 
