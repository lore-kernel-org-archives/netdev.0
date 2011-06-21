From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] udp:  add tracepoints for queueing skb to rcvbuf
Date: Tue, 21 Jun 2011 06:47:43 -0400
Message-ID: <20110621104742.GA16311@hmsreliant.think-freely.org>
References: <65795E11DBF1E645A09CEC7EAEE94B9C402B96E4@USINDEVS02.corp.hds.com>
 <65795E11DBF1E645A09CEC7EAEE94B9C402B96E5@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"dle-develop@lists.sourceforge.net"
	<dle-develop@lists.sourceforge.net>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: Satoru Moriya <satoru.moriya@hds.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33052 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753738Ab1FUKr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 06:47:56 -0400
Content-Disposition: inline
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C402B96E5@USINDEVS02.corp.hds.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2011 at 05:58:39PM -0400, Satoru Moriya wrote:
> This patch adds a tracepoint to __udp_queue_rcv_skb to get the
> return value of ip_queue_rcv_skb. It indicates why kernel drops
> a packet at this point.
> 
> ip_queue_rcv_skb returns following values in the packet drop case:
> 
> rcvbuf is full                 : -ENOMEM
> sk_filter returns error        : -EINVAL, -EACCESS, -ENOMEM, etc.
> __sk_mem_schedule returns error: -ENOBUF
> 
> 
> Signed-off-by: Satoru Moriya <satoru.moriya@hds.com>
> ---
>  include/trace/events/udp.h |   32 ++++++++++++++++++++++++++++++++
>  net/core/net-traces.c      |    1 +
>  net/ipv4/udp.c             |    2 ++
>  3 files changed, 35 insertions(+), 0 deletions(-)
>  create mode 100644 include/trace/events/udp.h
> 
> diff --git a/include/trace/events/udp.h b/include/trace/events/udp.h
> new file mode 100644
> index 0000000..a664bb9
> --- /dev/null
> +++ b/include/trace/events/udp.h
> @@ -0,0 +1,32 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM udp
> +
> +#if !defined(_TRACE_UDP_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_UDP_H
> +
> +#include <linux/udp.h>
> +#include <linux/tracepoint.h>
> +
> +TRACE_EVENT(udp_fail_queue_rcv_skb,
> +
> +	TP_PROTO(int rc, struct sock *sk),
> +
> +	TP_ARGS(rc, sk),
> +
> +	TP_STRUCT__entry(
> +		__field(int, rc)
> +		__field(__u16, lport)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->rc = rc;
> +		__entry->lport = inet_sk(sk)->inet_num;
> +	),
> +
> +	TP_printk("rc=%d port=%hu", __entry->rc, __entry->lport)
> +);
> +
> +#endif /* _TRACE_UDP_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> diff --git a/net/core/net-traces.c b/net/core/net-traces.c
> index 7f1bb2a..13aab64 100644
> --- a/net/core/net-traces.c
> +++ b/net/core/net-traces.c
> @@ -28,6 +28,7 @@
>  #include <trace/events/skb.h>
>  #include <trace/events/net.h>
>  #include <trace/events/napi.h>
> +#include <trace/events/udp.h>
>  
>  EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
>  
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index abca870..37aa9bf 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -105,6 +105,7 @@
>  #include <net/route.h>
>  #include <net/checksum.h>
>  #include <net/xfrm.h>
> +#include <trace/events/udp.h>
>  #include "udp_impl.h"
>  
>  struct udp_table udp_table __read_mostly;
> @@ -1363,6 +1364,7 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  					 is_udplite);
>  		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
>  		kfree_skb(skb);
> +		trace_udp_fail_queue_rcv_skb(rc, sk);
>  		return -1;
>  	}
>  
> -- 
> 1.7.1
> 
I was thinking you could just trace callers of __sk_mem_schedule, but looking at
it this works as well
Acked-by: Neil Horman <nhorman@tuxdriver.com>

> 
> 
