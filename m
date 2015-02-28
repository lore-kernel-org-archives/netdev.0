From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 tip 0/7] tracing: attach eBPF programs to kprobes
Date: Fri, 27 Feb 2015 16:25:57 -0800
Message-ID: <CAMEtUuz2CAwbjLzs01GMzfc4u=fdifK94_PaWqJg0Oj+Qrtu3A@mail.gmail.com>
References: <1425082135-11967-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
To: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1425082135-11967-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 27, 2015 at 4:08 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> Hi All,
>
> This is targeting 'tip' tree, since most of the changes are perf_event related.
>
> V3 discussion:
> https://lkml.org/lkml/2015/2/9/738
>
> V3->V4:
> - since the boundary of stable ABI in bpf+tracepoints is not clear yet,
>   I've dropped them for now.
> - bpf+syscalls are ok from stable ABI point of view, but bpf+seccomp
>   would want to do very similar analysis of syscalls, so I've dropped
>   them as well to take time and define common bpf+syscalls and bpf+seccomp
>   infra in the future.
> - so only bpf+kprobes left. kprobes by definition is not a stable ABI,
>   so bpf+kprobe is not stable ABI either. To stress on that point added
>   kernel version attribute that user space must pass along with the program
>   and kernel will reject programs when version code doesn't match.
>   So bpf+kprobe is very similar to kernel modules, but unlike modules
>   version check is not used for safety, but for enforcing 'non-ABI-ness'.
>   (version check doesn't apply to bpf+sockets which are stable)
>
> 1st patch of this set is going to be shared between net-next and tip trees, since
> patch 2 depends on it.
>
> Patch 2 actually adds bpf+kprobe infra:
> programs receive 'struct pt_regs' on input and can walk data structures
> using bpf_probe_read() helper which is a wrapper of probe_kernel_read()
>
> Programs are attached to kprobe events via API:
>
> prog_fd = bpf_prog_load(...);
> struct perf_event_attr attr = {
>   .type = PERF_TYPE_TRACEPOINT,
>   .config = event_id, /* ID of just created kprobe event */
> };
> event_fd = perf_event_open(&attr,...);
> ioctl(event_fd, PERF_EVENT_IOC_SET_BPF, prog_fd);
>
> Patch 3 adds bpf_ktime_get_ns() helper function, so that bpf programs can
> measure time delta between events to compute disk io latency, etc.
>
> Patch 4 adds bpf_trace_printk() helper that is used to debug programs.
> When bpf verifier sees that program is calling bpf_trace_printk() it inits
> trace_printk buffers which emits nasty 'this is debug only' banner.
> That's exactly what we want. bpf_trace_printk() is for debugging only.
>
> Patch 5 sample code that shows how to use bpf_probe_read/bpf_trace_printk
>
> Patch 6 sample code - combination of kfree_skb and sys_write tracing.
>
> Patch 7 sample code that computes disk io latency and prints it as 'heatmap'
>
> Interesting bit is that patch 6 has log2() function implemented in C
> and patch 7 has another log2() function using different algorithm in C.
> In the future if 'log2' usage becomes common, we can add it as in-kernel
> helper function, but for now bpf programs can implement them on bpf side.
>
> Another interesting bit from patch 7 is that it does approximation of
> floating point log10(X)*10 using integer arithmetic, which demonstrates
> the power of C->BPF vs traditional tracing language alternatives,
> where one would need to introduce new helper functions to add functionality,
> whereas bpf can just implement such things in C as part of the program.
>
> Next step is to prototype TCP stack instrumentation (like web10g) using
> bpf+kprobe, but without adding any new code tcp stack.
> Though kprobes are slow comparing to tracepoints, they are good enough
> for prototyping and trace_marker/debug_tracepoint ideas can accelerate
> them in the future.
>
> Alexei Starovoitov (6):
>   tracing: attach BPF programs to kprobes
>   tracing: allow BPF programs to call ktime_get_ns()
>   tracing: allow BPF programs to call bpf_trace_printk()
>   samples: bpf: simple non-portable kprobe filter example
>   samples: bpf: counting example for kfree_skb and write syscall
>   samples: bpf: IO latency analysis (iosnoop/heatmap)
>
> Daniel Borkmann (1):
>   bpf: make internal bpf API independent of CONFIG_BPF_SYSCALL ifdefs
>
>  include/linux/bpf.h             |   20 ++++-
>  include/linux/ftrace_event.h    |   14 ++++
>  include/uapi/linux/bpf.h        |    5 ++
>  include/uapi/linux/perf_event.h |    1 +
>  kernel/bpf/syscall.c            |    7 +-
>  kernel/events/core.c            |   59 +++++++++++++
>  kernel/trace/Makefile           |    1 +
>  kernel/trace/bpf_trace.c        |  177 +++++++++++++++++++++++++++++++++++++++
>  kernel/trace/trace_kprobe.c     |   10 ++-
>  samples/bpf/Makefile            |   12 +++
>  samples/bpf/bpf_helpers.h       |    6 ++
>  samples/bpf/bpf_load.c          |  112 +++++++++++++++++++++++--
>  samples/bpf/bpf_load.h          |    3 +
>  samples/bpf/libbpf.c            |   10 ++-
>  samples/bpf/libbpf.h            |    5 +-
>  samples/bpf/sock_example.c      |    2 +-
>  samples/bpf/test_verifier.c     |    2 +-
>  samples/bpf/tracex1_kern.c      |   50 +++++++++++
>  samples/bpf/tracex1_user.c      |   25 ++++++
>  samples/bpf/tracex2_kern.c      |   86 +++++++++++++++++++
>  samples/bpf/tracex2_user.c      |   95 +++++++++++++++++++++
>  samples/bpf/tracex3_kern.c      |   89 ++++++++++++++++++++
>  samples/bpf/tracex3_user.c      |  150 +++++++++++++++++++++++++++++++++
>  23 files changed, 925 insertions(+), 16 deletions(-)
>  create mode 100644 kernel/trace/bpf_trace.c
>  create mode 100644 samples/bpf/tracex1_kern.c
>  create mode 100644 samples/bpf/tracex1_user.c
>  create mode 100644 samples/bpf/tracex2_kern.c
>  create mode 100644 samples/bpf/tracex2_user.c
>  create mode 100644 samples/bpf/tracex3_kern.c
>  create mode 100644 samples/bpf/tracex3_user.c
>
> --
> 1.7.9.5
>

my macros had old Daniel's email. now cc-ed correct one.
