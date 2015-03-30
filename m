From: Jovi Zhangwei <jovi.zhangwei@gmail.com>
Subject: Re: [PATCH v11 tip 6/9] samples: bpf: simple non-portable kprobe
 filter example
Date: Sun, 29 Mar 2015 17:34:06 -0700
Message-ID: <CAGdX0WESZ8kb7R3U38ciJambE_qBPnf3MiKiKa2wR-50H6_NyQ@mail.gmail.com>
References: <1427312966-8434-1-git-send-email-ast@plumgrid.com>
	<1427312966-8434-7-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33620 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbbC3AeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 20:34:08 -0400
In-Reply-To: <1427312966-8434-7-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2015 at 12:49 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> tracex1_kern.c - C program compiled into BPF.
> It attaches to kprobe:netif_receive_skb
> When skb->dev->name == "lo", it prints sample debug message into trace_pipe
> via bpf_trace_printk() helper function.
>
> tracex1_user.c - corresponding user space component that:
> - loads bpf program via bpf() syscall
> - opens kprobes:netif_receive_skb event via perf_event_open() syscall
> - attaches the program to event via ioctl(event_fd, PERF_EVENT_IOC_SET_BPF, prog_fd);
> - prints from trace_pipe
>
> Note, this bpf program is non-portable. It must be recompiled with current
> kernel headers. kprobe is not a stable ABI and bpf+kprobe scripts
> may no longer be meaningful when kernel internals change.
>
> No matter in what way the kernel changes, neither the kprobe, nor the bpf
> program can ever crash or corrupt the kernel, assuming the kprobes, perf and
> bpf subsystem has no bugs.
>
> The verifier will detect that the program is using bpf_trace_printk() and
> the kernel will print 'this is a DEBUG kernel' warning banner, which means that
> bpf_trace_printk() should be used for debugging of the bpf program only.
>
> Usage:
> $ sudo tracex1
>             ping-19826 [000] d.s2 63103.382648: : skb ffff880466b1ca00 len 84
>             ping-19826 [000] d.s2 63103.382684: : skb ffff880466b1d300 len 84
>
>             ping-19826 [000] d.s2 63104.382533: : skb ffff880466b1ca00 len 84
>             ping-19826 [000] d.s2 63104.382594: : skb ffff880466b1d300 len 84
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
>  samples/bpf/Makefile        |    4 ++
>  samples/bpf/bpf_helpers.h   |    6 +++
>  samples/bpf/bpf_load.c      |  125 ++++++++++++++++++++++++++++++++++++++++---
>  samples/bpf/bpf_load.h      |    3 ++
>  samples/bpf/libbpf.c        |   14 ++++-
>  samples/bpf/libbpf.h        |    5 +-
>  samples/bpf/sock_example.c  |    2 +-
>  samples/bpf/test_verifier.c |    2 +-
>  samples/bpf/tracex1_kern.c  |   50 +++++++++++++++++
>  samples/bpf/tracex1_user.c  |   25 +++++++++
>  10 files changed, 224 insertions(+), 12 deletions(-)
>  create mode 100644 samples/bpf/tracex1_kern.c
>  create mode 100644 samples/bpf/tracex1_user.c
>
> diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> index b5b3600dcdf5..51f6f01e5a3a 100644
> --- a/samples/bpf/Makefile
> +++ b/samples/bpf/Makefile
> @@ -6,23 +6,27 @@ hostprogs-y := test_verifier test_maps
>  hostprogs-y += sock_example
>  hostprogs-y += sockex1
>  hostprogs-y += sockex2
> +hostprogs-y += tracex1
>
>  test_verifier-objs := test_verifier.o libbpf.o
>  test_maps-objs := test_maps.o libbpf.o
>  sock_example-objs := sock_example.o libbpf.o
>  sockex1-objs := bpf_load.o libbpf.o sockex1_user.o
>  sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
> +tracex1-objs := bpf_load.o libbpf.o tracex1_user.o
>
>  # Tell kbuild to always build the programs
>  always := $(hostprogs-y)
>  always += sockex1_kern.o
>  always += sockex2_kern.o
> +always += tracex1_kern.o
>
>  HOSTCFLAGS += -I$(objtree)/usr/include
>
>  HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
>  HOSTLOADLIBES_sockex1 += -lelf
>  HOSTLOADLIBES_sockex2 += -lelf
> +HOSTLOADLIBES_tracex1 += -lelf
>
>  # point this to your LLVM backend with bpf support
>  LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
> diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
> index ca0333146006..1c872bcf5a80 100644
> --- a/samples/bpf/bpf_helpers.h
> +++ b/samples/bpf/bpf_helpers.h
> @@ -15,6 +15,12 @@ static int (*bpf_map_update_elem)(void *map, void *key, void *value,
>         (void *) BPF_FUNC_map_update_elem;
>  static int (*bpf_map_delete_elem)(void *map, void *key) =
>         (void *) BPF_FUNC_map_delete_elem;
> +static int (*bpf_probe_read)(void *dst, int size, void *unsafe_ptr) =
> +       (void *) BPF_FUNC_probe_read;
> +static unsigned long long (*bpf_ktime_get_ns)(void) =
> +       (void *) BPF_FUNC_ktime_get_ns;
> +static int (*bpf_trace_printk)(const char *fmt, int fmt_size, ...) =
> +       (void *) BPF_FUNC_trace_printk;
>
>  /* llvm builtin functions that eBPF C program may use to
>   * emit BPF_LD_ABS and BPF_LD_IND instructions
> diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
> index 1831d236382b..38dac5a53b51 100644
> --- a/samples/bpf/bpf_load.c
> +++ b/samples/bpf/bpf_load.c
> @@ -8,29 +8,70 @@
>  #include <unistd.h>
>  #include <string.h>
>  #include <stdbool.h>
> +#include <stdlib.h>
>  #include <linux/bpf.h>
>  #include <linux/filter.h>
> +#include <linux/perf_event.h>
> +#include <sys/syscall.h>
> +#include <sys/ioctl.h>
> +#include <sys/mman.h>
> +#include <poll.h>
>  #include "libbpf.h"
>  #include "bpf_helpers.h"
>  #include "bpf_load.h"
>
> +#define DEBUGFS "/sys/kernel/debug/tracing/"
> +
>  static char license[128];
> +static int kern_version;
>  static bool processed_sec[128];
>  int map_fd[MAX_MAPS];
>  int prog_fd[MAX_PROGS];
> +int event_fd[MAX_PROGS];
>  int prog_cnt;
>
>  static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
>  {
> -       int fd;
>         bool is_socket = strncmp(event, "socket", 6) == 0;
> -
> -       if (!is_socket)
> -               /* tracing events tbd */
> +       bool is_kprobe = strncmp(event, "kprobe/", 7) == 0;
> +       bool is_kretprobe = strncmp(event, "kretprobe/", 10) == 0;
> +       enum bpf_prog_type prog_type;
> +       char buf[256];
> +       int fd, efd, err, id;
> +       struct perf_event_attr attr = {};
> +
> +       attr.type = PERF_TYPE_TRACEPOINT;
> +       attr.sample_type = PERF_SAMPLE_RAW;
> +       attr.sample_period = 1;
> +       attr.wakeup_events = 1;
> +
> +       if (is_socket) {
> +               prog_type = BPF_PROG_TYPE_SOCKET_FILTER;
> +       } else if (is_kprobe || is_kretprobe) {
> +               prog_type = BPF_PROG_TYPE_KPROBE;
> +       } else {
> +               printf("Unknown event '%s'\n", event);
>                 return -1;
> +       }
> +
> +       if (is_kprobe || is_kretprobe) {
> +               if (is_kprobe)
> +                       event += 7;
> +               else
> +                       event += 10;
> +
> +               snprintf(buf, sizeof(buf),
> +                        "echo '%c:%s %s' >> /sys/kernel/debug/tracing/kprobe_events",
> +                        is_kprobe ? 'p' : 'r', event, event);
> +               err = system(buf);

Maybe we need to remember cleanup the kprobe_events in debugfs?
