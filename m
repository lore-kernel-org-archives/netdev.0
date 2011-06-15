From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC][PATCH] add tracepoint to __sk_mem_schedule
Date: Wed, 15 Jun 2011 07:07:23 -0400
Message-ID: <20110615110723.GA23380@hmsreliant.think-freely.org>
References: <65795E11DBF1E645A09CEC7EAEE94B9C3FBC0707@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"dle-develop@lists.sourceforge.net"
	<dle-develop@lists.sourceforge.net>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: Satoru Moriya <satoru.moriya@hds.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36528 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173Ab1FOLHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 07:07:36 -0400
Content-Disposition: inline
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C3FBC0707@USINDEVS02.corp.hds.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2011 at 03:24:14PM -0400, Satoru Moriya wrote:
> Hi,
> 
> kernel drops packets when the amount of memory which is used for socket buffer
> exceeds limitations such as /proc/sys/net/ipv4/udp_mem. But currently we can't
> catch that event and know why packets are dropped. And also it is difficult to
> configure sysctl knob appropriately because we don't know when/why packets
> dropped.
> 
There are several ways to do this already.  Every drop that occurs in the stack
should have a corresponding statistical counter exposed for it, and we also have
a tracepoint in kfree_skb that the dropwatch system monitors to inform us of
dropped packets in a certralized fashion.  Not saying this tracepoint isn't
worthwhile, only that it covers already covered ground.

> This patch adds tracepoint to __sk_mem_schedule(), which is called each time
> the socket memory usage exceeds limitations and kernel drops a packet.
> It allows us to hook in and examine when and why it happens.
> 
> Note that this patch only collects information which is needed for udp
> because it's a RFC patch to show its concept and acutually we need it(*).
> If you guys need to get other parameters, please let me know. I'll add it.
> 
> (*) Reason why we need this tracepoint for UDP
> Transaction data is sent by UDP multicast in finance systems because of its
> low overhead characteristics. UDP itself does not guarantee reliability,
> ordering and data integrity, but the system is designed not to drop any packets
> even when it is high load situation. And in that system if kernel drops packets,
> we need to find a root cause to avoid it next time.
> 
Again, this is why dropwatch exists.  UDP gets into this path from:
__udp_queue_rcv_skb
 ip_queue_rcv_skb
  sock_queue_rcv_skb
   sk_rmem_schedule
    __sk_mem_schedule

If ip_queue_rcv_skb fails we increment the UDP_MIB_RCVBUFERRORS counter as well
as the UDP_MIB_INERRORS counter, and on the kfree_skb call after those
increments, dropwatch will report the frame loss and the fact that it occured in
__udp_queue_rcv_skb

I still think its an interesting tracepoint, just because it might be nice to
know which sockets are expanding their snd/rcv buffer space, but why not modify
the tracepoint so that it accepts the return code of __sk_mem_schedule and call
it from both sk_rmem_schedule and sk_wmem_schedule.   That way you can use the
tracepoint to record both successfull expansion and failed expansions.
Neil
 
> Any comments are welcome.
> 
> Signed-off-by: Satoru Moriya <satoru.moriya@hds.com>
> ---
>  include/trace/events/sock.h |   46 +++++++++++++++++++++++++++++++++++++++++++
>  net/core/net-traces.c       |    1 +
>  net/core/sock.c             |    4 +++
>  3 files changed, 51 insertions(+), 0 deletions(-)
>  create mode 100644 include/trace/events/sock.h
> 
> diff --git a/include/trace/events/sock.h b/include/trace/events/sock.h
> new file mode 100644
> index 0000000..409735a
> --- /dev/null
> +++ b/include/trace/events/sock.h
> @@ -0,0 +1,46 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM sock
> +
> +#if !defined(_TRACE_SOCK_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_SOCK_H
> +
> +#include <net/sock.h>
> +#include <linux/tracepoint.h>
> +
> +TRACE_EVENT(sock_exceed_buf_limit,
> +
> +	TP_PROTO(struct sock *sk, struct proto *prot, long allocated),
> +
> +	TP_ARGS(sk, prot, allocated),
> +
> +	TP_STRUCT__entry(
> +		__array(char, name, 32)
> +		__field(long *, sysctl_mem)
> +		__field(long, allocated)
> +		__field(int, sysctl_rmem)
> +		__field(int, rmem_alloc)
> +	),
> +
> +	TP_fast_assign(
> +		strncpy(__entry->name, prot->name, 32);
> +		__entry->sysctl_mem = prot->sysctl_mem;
> +		__entry->allocated = allocated;
> +		__entry->sysctl_rmem = atomic_read(&sk->sk_rmem_alloc);
> +		__entry->rmem_alloc = prot->sysctl_rmem[0];
> +	),
> +
> +	TP_printk("proto:%s sysctl_mem=%ld,%ld,%ld allocated=%ld "
> +		"sysctl_rmem=%d rmem_alloc=%d",
> +		__entry->name,
> +		__entry->sysctl_mem[0],
> +		__entry->sysctl_mem[1],
> +		__entry->sysctl_mem[2],
> +		__entry->allocated,
> +		__entry->sysctl_rmem,
> +		__entry->rmem_alloc)
> +);
> +
> +#endif /* _TRACE_SOCK_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> diff --git a/net/core/net-traces.c b/net/core/net-traces.c
> index 7f1bb2a..b9756f5 100644
> --- a/net/core/net-traces.c
> +++ b/net/core/net-traces.c
> @@ -28,6 +28,7 @@
>  #include <trace/events/skb.h>
>  #include <trace/events/net.h>
>  #include <trace/events/napi.h>
> +#include <trace/events/sock.h>
>  
>  EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
>  
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 6e81978..8389032 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -128,6 +128,8 @@
>  
>  #include <linux/filter.h>
>  
> +#include <trace/events/sock.h>
> +
>  #ifdef CONFIG_INET
>  #include <net/tcp.h>
>  #endif
> @@ -1736,6 +1738,8 @@ suppress_allocation:
>  			return 1;
>  	}
>  
> +	trace_sock_exceed_buf_limit(sk, prot, allocated);
> +
>  	/* Alas. Undo changes. */
>  	sk->sk_forward_alloc -= amt * SK_MEM_QUANTUM;
>  	atomic_long_sub(amt, prot->memory_allocated);
> -- 
> 1.7.1
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
