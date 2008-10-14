From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 04/14] sch_netem: Use requeue list instead of
 ops->requeue()
Date: Tue, 14 Oct 2008 08:22:35 -0700
Message-ID: <20081014082235.10b46637@extreme>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
	<20081014095349.GE10804@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45491 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276AbYJNPWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2008 11:22:40 -0400
In-Reply-To: <20081014095349.GE10804@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Oct 2008 09:53:49 +0000
Jarek Poplawski <jarkao2@gmail.com> wrote:

> -------- Original Message --------
> Subject: [PATCH 5/9]: sch_netem: Use requeue list instead of ops->requeue()
> Date: Mon, 18 Aug 2008 01:37:02 -0700 (PDT)
> From: David Miller <davem@davemloft.net>
> 
> --------------->
> From: David Miller <davem@davemloft.net>
> sch_netem: Use requeue list instead of ops->requeue()
> 
> This code just wants to make this packet the "front" one, and that's
> just as simply done by queueing to the ->requeue list.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> ---
>  net/sched/sch_netem.c |   11 +++--------
>  1 files changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
> index cc4d057..5ca92d9 100644
> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
> @@ -233,7 +233,8 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  		 */
>  		cb->time_to_send = psched_get_time();
>  		q->counter = 0;
> -		ret = q->qdisc->ops->requeue(skb, q->qdisc);
> +		__skb_queue_tail(&q->qdisc->requeue, skb);
> +		ret = NET_XMIT_SUCCESS;
>  	}
>  
>  	if (likely(ret == NET_XMIT_SUCCESS)) {
> @@ -295,13 +296,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
>  			return skb;
>  		}
>  
> -		if (unlikely(q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS)) {
> -			qdisc_tree_decrease_qlen(q->qdisc, 1);
> -			sch->qstats.drops++;
> -			printk(KERN_ERR "netem: %s could not requeue\n",
> -			       q->qdisc->ops->id);
> -		}
> -
> +		__skb_queue_tail(&q->qdisc->requeue, skb);
>  		qdisc_watchdog_schedule(&q->watchdog, cb->time_to_send);
>  	}
>  

This won't work for the case where time based reordering changes the packet
sent.  The current code works like this:

    Packet marked to be sent at some time (+101ms)
    new packet is queued and the random delay computes smaller delta (+87ms)
    new packet will go out in first.

This was done for compatibility with NISTnet, so research that wanted to reproduce
NISTnet results could use netem.

