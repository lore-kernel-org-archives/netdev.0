From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH v4 4/5] skb: add tracepoints to freeing skb
Date: Fri, 27 Aug 2010 08:38:33 -0400
Message-ID: <20100827123833.GD17607@hmsreliant.think-freely.org>
References: <4C4FCDA1.3000803@jp.fujitsu.com>
 <4C4FCF55.5020600@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	rostedt@goodmis.org, eric.dumazet@gmail.com, fweisbec@gmail.com,
	mathieu.desnoyers@polymtl.ca
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41417 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752922Ab0H0Mix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 08:38:53 -0400
Content-Disposition: inline
In-Reply-To: <4C4FCF55.5020600@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 28, 2010 at 03:33:57PM +0900, Koki Sanagi wrote:
> CHANGE-LOG since v3:
>   -remove tracepoint of dev_kfree_skb_irq and skb_free_datagram_locked.
>    Insead of them, add trace_kfree_skb before __kfree_skb in net_tx_action and
>    skb_free_datagram_locked. And there is no change of about the location of
>    trace_consume_skb to keep a symmetry against trace_kfree_skb.
> 
> This patch adds tracepoint to consume_skb and add trace_kfree_skb before
> __kfree_skb in skb_free_datagram_locked and net_tx_action.
> Combinating with tracepoint on dev_hard_start_xmit, we can check how long it
> takes to free transmited packets. And using it, we can calculate how many
> packets driver had at that time. It is useful when a drop of transmited packet
> is a problem.
> 
>             sshd-6828  [000] 112689.258154: consume_skb: skbaddr=f2d99bb8
> 
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>

> ---
>  include/trace/events/skb.h |   17 +++++++++++++++++
>  net/core/datagram.c        |    1 +
>  net/core/dev.c             |    2 ++
>  net/core/skbuff.c          |    1 +
>  4 files changed, 21 insertions(+), 0 deletions(-)
> 
> diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
> index 4b2be6d..75ce9d5 100644
> --- a/include/trace/events/skb.h
> +++ b/include/trace/events/skb.h
> @@ -35,6 +35,23 @@ TRACE_EVENT(kfree_skb,
>  		__entry->skbaddr, __entry->protocol, __entry->location)
>  );
>  
> +TRACE_EVENT(consume_skb,
> +
> +	TP_PROTO(struct sk_buff *skb),
> +
> +	TP_ARGS(skb),
> +
> +	TP_STRUCT__entry(
> +		__field(	void *,	skbaddr	)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->skbaddr = skb;
> +	),
> +
> +	TP_printk("skbaddr=%p", __entry->skbaddr)
> +);
> +
>  TRACE_EVENT(skb_copy_datagram_iovec,
>  
>  	TP_PROTO(const struct sk_buff *skb, int len),
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index 251997a..282806b 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -243,6 +243,7 @@ void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
>  	unlock_sock_fast(sk, slow);
>  
>  	/* skb is now orphaned, can be freed outside of locked section */
> +	trace_kfree_skb(skb, skb_free_datagram_locked);
>  	__kfree_skb(skb);
>  }
>  EXPORT_SYMBOL(skb_free_datagram_locked);
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 9ea9c1e..92d79bf 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -131,6 +131,7 @@
>  #include <linux/random.h>
>  #include <trace/events/napi.h>
>  #include <trace/events/net.h>
> +#include <trace/events/skb.h>
>  #include <linux/pci.h>
>  
>  #include "net-sysfs.h"
> @@ -2577,6 +2578,7 @@ static void net_tx_action(struct softirq_action *h)
>  			clist = clist->next;
>  
>  			WARN_ON(atomic_read(&skb->users));
> +			trace_kfree_skb(skb, net_tx_action);
>  			__kfree_skb(skb);
>  		}
>  	}
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 7da58a2..9cb91a5 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -466,6 +466,7 @@ void consume_skb(struct sk_buff *skb)
>  		smp_rmb();
>  	else if (likely(!atomic_dec_and_test(&skb->users)))
>  		return;
> +	trace_consume_skb(skb);
>  	__kfree_skb(skb);
>  }
>  EXPORT_SYMBOL(consume_skb);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
