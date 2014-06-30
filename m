From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH RFC net-next 00/14] BPF syscall, maps, verifier, samples
Date: Mon, 30 Jun 2014 16:09:06 -0700
Message-ID: <CAGXu5jK9Bwocjz8y26=GEk0qg5ru1Mu7j9FVuu20KfTDUrSkuQ@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1403913966-4927-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 27, 2014 at 5:05 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> Hi All,
>
> this patch set demonstrates the potential of eBPF.
>
> First patch "net: filter: split filter.c into two files" splits eBPF interpreter
> out of networking into kernel/bpf/. The goal for BPF subsystem is to be usable
> in NET-less configuration. Though the whole set is marked is RFC, the 1st patch
> is good to go. Similar version of the patch that was posted few weeks ago, but
> was deferred. I'm assuming due to lack of forward visibility. I hope that this
> patch set shows what eBPF is capable of and where it's heading.
>
> Other patches expose eBPF instruction set to user space and introduce concepts
> of maps and programs accessible via syscall.
>
> 'maps' is a generic storage of different types for sharing data between kernel
> and userspace. Maps are referrenced by global id. Root can create multiple
> maps of different types where key/value are opaque bytes of data. It's up to
> user space and eBPF program to decide what they store in the maps.
>
> eBPF programs are similar to kernel modules. They live in global space and
> have unique prog_id. Each program is a safe run-to-completion set of
> instructions. eBPF verifier statically determines that the program terminates
> and safe to execute. During verification the program takes a hold of maps
> that it intends to use, so selected maps cannot be removed until program is
> unloaded. The program can be attached to different events. These events can
> be packets, tracepoint events and other types in the future. New event triggers
> execution of the program which may store information about the event in the maps.
> Beyond storing data the programs may call into in-kernel helper functions
> which may, for example, dump stack, do trace_printk or other forms of live
> kernel debugging. Same program can be attached to multiple events. Different
> programs can access the same map:
>
>   tracepoint  tracepoint  tracepoint    sk_buff    sk_buff
>    event A     event B     event C      on eth0    on eth1
>     |             |          |            |          |
>     |             |          |            |          |
>     --> tracing <--      tracing       socket      socket
>          prog_1           prog_2       prog_3      prog_4
>          |  |               |            |
>       |---  -----|  |-------|           map_3
>     map_1       map_2
>
> User space (via syscall) and eBPF programs access maps concurrently.
>
> Last two patches are sample code. 1st demonstrates stateful packet inspection.
> It counts tcp and udp packets on eth0. Should be easy to see how this eBPF
> framework can be used for network analytics.
> 2nd sample does simple 'drop monitor'. It attaches to kfree_skb tracepoint
> event and counts number of packet drops at particular $pc location.
> User space periodically summarizes what eBPF programs recorded.
> In these two samples the eBPF programs are tiny and written in 'assembler'
> with macroses. More complex programs can be written C (llvm backend is not
> part of this diff to reduce 'huge' perception).
> Since eBPF is fully JITed on x64, the cost of running eBPF program is very
> small even for high frequency events. Here are the numbers comparing
> flow_dissector in C vs eBPF:
>   x86_64 skb_flow_dissect() same skb (all cached)         -  42 nsec per call
>   x86_64 skb_flow_dissect() different skbs (cache misses) - 141 nsec per call
> eBPF+jit skb_flow_dissect() same skb (all cached)         -  51 nsec per call
> eBPF+jit skb_flow_dissect() different skbs (cache misses) - 135 nsec per call
>
> Detailed explanation on eBPF verifier and safety is in patch 08/14

This is very exciting! Thanks for working on it. :)

Between the new eBPF syscall and the new seccomp syscall, I'm really
looking forward to using lookup tables for seccomp filters. Under
certain types of filters, we'll likely see some non-trivial
performance improvements.

-Kees

-- 
Kees Cook
Chrome OS Security
