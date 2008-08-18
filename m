From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 8/9]: sch_hfsc: Use ->requeue queue instead of ops.
Date: Mon, 18 Aug 2008 16:11:57 +0200
Message-ID: <48A9832D.7030402@trash.net>
References: <20080818.013715.51438108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55694 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629AbYHROL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 10:11:59 -0400
In-Reply-To: <20080818.013715.51438108.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> sch_hfsc: Use ->requeue queue instead of ops.
> 
> In fact this "peek head SKB for len" sequence could be
> optimized even further.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/sched/sch_hfsc.c |    7 +------
>  1 files changed, 1 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
> index ea46760..bed4fd2 100644
> --- a/net/sched/sch_hfsc.c
> +++ b/net/sched/sch_hfsc.c
> @@ -896,12 +896,7 @@ qdisc_peek_len(struct Qdisc *sch)
>  		return 0;
>  	}
>  	len = qdisc_pkt_len(skb);
> -	if (unlikely(sch->ops->requeue(skb, sch) != NET_XMIT_SUCCESS)) {
> -		if (net_ratelimit())
> -			printk("qdisc_peek_len: failed to requeue\n");
> -		qdisc_tree_decrease_qlen(sch, 1);
> -		return 0;
> -	}
> +	__skb_queue_head(&sch->requeue, skb);

Sorry for the late response, I didn't follow netdev very closely the
past days. This change does not work properly I'm afraid, it breaks
priorization on two levels:

- when a new packet is enqueued to a higher prioritized class within
HFSC (or a different qdisc), the class peeked at will still be served
on dequeue regardless, increasing worst case latency by a full packet
transmission time.

- when a packet is enqueued to the same class and inner qdisc after
peeking, the inner qdisc can decide to prioritize that packet and
hand it out on the next ->dequeue, but the upper qdisc will serve
the packet peeked at regardless. This results in the same effect,
the worst case latency increases by a full packet transmission time.

I think we really need either ->requeue or a real ->peek operation.

