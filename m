From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [Patch net-next] tcp: add a tracepoint for tcp_retransmit_skb()
Date: Tue, 10 Oct 2017 10:38:23 -0700
Message-ID: <20171010173821.6djxyvrggvaivqec@ast-mbp.dhcp.thefacebook.com>
References: <20171010053547.21162-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Brendan Gregg <brendan.d.gregg@gmail.com>,
        hannes@stressinduktion.org, Song Liu <songliubraving@fb.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36680 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756037AbdJJRi2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 13:38:28 -0400
Received: by mail-pf0-f195.google.com with SMTP id z11so19845968pfk.3
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 10:38:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171010053547.21162-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 09, 2017 at 10:35:47PM -0700, Cong Wang wrote:
> We need a real-time notification for tcp retransmission
> for monitoring.
> 
> Of course we could use ftrace to dynamically instrument this
> kernel function too, however we can't retrieve the connection
> information at the same time, for example perf-tools [1] reads
> /proc/net/tcp for socket details, which is slow when we have
> a lots of connections.
> 
> Therefore, this patch adds a tracepoint for tcp_retransmit_skb()
> and exposes src/dst IP addresses and ports of the connection.
> This also makes it easier to integrate into perf.
> 
> Note, I expose both IPv4 and IPv6 addresses at the same time:
> for a IPv4 socket, v4 mapped address is used as IPv6 addresses,
> for a IPv6 socket, LOOPBACK4_IPV6 is already filled by kernel.
> 
> Perhaps there are other interfaces to use (for example netlink),
> but tracepoint is the quickest way I can think of.
> 
> 1. https://github.com/brendangregg/perf-tools/blob/master/net/tcpretrans
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  include/trace/events/tcp.h | 63 ++++++++++++++++++++++++++++++++++++++++++++++
>  net/core/net-traces.c      |  1 +
>  net/ipv4/tcp_output.c      |  3 +++
>  3 files changed, 67 insertions(+)
>  create mode 100644 include/trace/events/tcp.h
> 
> diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
> new file mode 100644
> index 000000000000..cb22acc8aacd
> --- /dev/null
> +++ b/include/trace/events/tcp.h
> @@ -0,0 +1,63 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM tcp
> +
> +#if !defined(_TRACE_TCP_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_TCP_H
> +
> +#include <linux/ipv6.h>
> +#include <linux/tcp.h>
> +#include <linux/tracepoint.h>
> +#include <net/ipv6.h>
> +
> +TRACE_EVENT(tcp_retransmit_skb,
> +
> +	TP_PROTO(const struct sock *sk, struct sk_buff *skb, int segs),
> +
> +	TP_ARGS(sk, skb, segs),
> +
> +	TP_STRUCT__entry(
> +		__field(__u16, sport)
> +		__field(__u16, dport)
> +		__array(__u8, saddr, 4)
> +		__array(__u8, daddr, 4)
> +		__array(__u8, saddr_v6, 16)
> +		__array(__u8, daddr_v6, 16)
> +	),
> +
> +	TP_fast_assign(
> +		struct ipv6_pinfo *np = inet6_sk(sk);
> +		struct inet_sock *inet = inet_sk(sk);
> +		struct in6_addr *pin6;
> +		__be32 *p32;
> +
> +		__entry->sport = ntohs(inet->inet_sport);
> +		__entry->dport = ntohs(inet->inet_dport);
> +
> +		p32 = (__be32 *) __entry->saddr;
> +		*p32 = inet->inet_saddr;
> +
> +		p32 = (__be32 *) __entry->daddr;
> +		*p32 =  inet->inet_daddr;
> +
> +		if (np) {
> +			pin6 = (struct in6_addr *)__entry->saddr_v6;
> +			*pin6 = np->saddr;
> +			pin6 = (struct in6_addr *)__entry->daddr_v6;
> +			*pin6 = *(np->daddr_cache);
> +		} else {
> +			pin6 = (struct in6_addr *)__entry->saddr_v6;
> +			ipv6_addr_set_v4mapped(inet->inet_saddr, pin6);
> +			pin6 = (struct in6_addr *)__entry->daddr_v6;
> +			ipv6_addr_set_v4mapped(inet->inet_daddr, pin6);
> +		}
> +	),
> +
> +	TP_printk("sport=%hu, dport=%hu, saddr=%pI4, daddr=%pI4, saddrv6=%pI6, daddrv6=%pI6",
> +		  __entry->sport, __entry->dport, __entry->saddr, __entry->daddr,
> +		  __entry->saddr_v6, __entry->daddr_v6)
> +);
> +
> +#endif /* _TRACE_TCP_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> diff --git a/net/core/net-traces.c b/net/core/net-traces.c
> index 1132820c8e62..f4e4fa2db505 100644
> --- a/net/core/net-traces.c
> +++ b/net/core/net-traces.c
> @@ -31,6 +31,7 @@
>  #include <trace/events/napi.h>
>  #include <trace/events/sock.h>
>  #include <trace/events/udp.h>
> +#include <trace/events/tcp.h>
>  #include <trace/events/fib.h>
>  #include <trace/events/qdisc.h>
>  #if IS_ENABLED(CONFIG_IPV6)
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 696b0a168f16..e6d6e1393578 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -42,6 +42,8 @@
>  #include <linux/gfp.h>
>  #include <linux/module.h>
>  
> +#include <trace/events/tcp.h>
> +
>  /* People can turn this off for buggy TCP's found in printers etc. */
>  int sysctl_tcp_retrans_collapse __read_mostly = 1;
>  
> @@ -2899,6 +2901,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs)
>  		if (!tp->retrans_stamp)
>  			tp->retrans_stamp = tcp_skb_timestamp(skb);
>  
> +		trace_tcp_retransmit_skb(sk, skb, segs);

I'm happy to see new tracepoints being added to tcp stack, but I'm concerned
with practical usability of them.
Like the above tracepoint definition makes it not very useful from bpf point of view,
since 'sk' pointer is not recored by as part of the tracepoint.
In bpf/tracing world we prefer tracepoints to have raw pointers recorded
in TP_STRUCT__entry() and _not_ printed in TP_printk()
(since pointers are useless for userspace).
Like trace_kfree_skb() tracepoint records raw 'skb' pointer and we can
walk whatever sk_buff fields we need inside the program.
Such approach allows tracepoint to be usable in many more scenarios, since
bpf program can examine kernel datastructures.
Over the last few years we've been running tcp statistics framework (similar to web10g)
using 8 kprobes in tcp stack with bpf programs extracting the data and now we're
ready to share this experience with the community. Right now we're working on a set
of tracepoints for tcp stack to make the interface more accurate, faster and more stable.
We're planning to send an RFC patch with these new tracepoints in the comming weeks.

More concrete, if you can make this trace_tcp_retransmit_skb() to record
sk, skb pointers and err code at the end of __tcp_retransmit_skb() it will solve
our need as well.

So far our list of kprobes is:
int kprobe__tcp_validate_incoming
int kprobe__tcp_send_active_reset
int kprobe__tcp_v4_send_reset
int kprobe__tcp_v6_send_reset
int kprobe__tcp_v4_destroy_sock
int kprobe__tcp_set_state
int kprobe__tcp_retransmit_skb
int kprobe__tcp_rtx_synack

with tracepoints we can consolidate two of them into one and drop
another one for sure. Notice that tcp_retransmit_skb is on our list too
and currently we're doing extra work inside the program to make it more
accurate which will be unnecessary if this tracepoint is at the end
of __tcp_retransmit_skb().

Thanks
