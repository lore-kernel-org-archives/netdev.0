From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/1] sched: add head drop fifo queue
Date: Mon, 18 Jan 2010 20:25:17 +0100
Message-ID: <4B54B59D.5010108@gmail.com>
References: <4B548DAE.3000205@trash.net> <1263833050-11635-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:38477 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283Ab0ARTZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 14:25:22 -0500
Received: by fxm25 with SMTP id 25so815475fxm.21
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 11:25:21 -0800 (PST)
In-Reply-To: <1263833050-11635-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hagen Paul Pfeifer wrote, On 01/18/2010 05:44 PM:

> This add an additional queuing strategy, called pfifo_head_drop,

"This adds"...

> to remove the oldest skb in the case of an overflow within the queue -
> the head element - instead of the last skb (tail). To remove the oldest
> skb in a congested situations is useful for sensor network environments

"skb in congested situations"...

> where newer packets reflects the superior information.

"where newer packets reflect"...

> 
> Reviewed-by: Florian Westphal <fw@strlen.de>
> Acked-by: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> ---
>  include/net/pkt_sched.h |    1 +
>  net/sched/sch_api.c     |    1 +
>  net/sched/sch_fifo.c    |   36 ++++++++++++++++++++++++++++++++++++
>  3 files changed, 38 insertions(+), 0 deletions(-)

...

> +static int pfifo_front_enqueue(struct sk_buff *skb, struct Qdisc* sch)

Why do you call it "front_enqueue" if always does "enqueue_tail"?
Btw, usually these methods take name from the qdisc.

> +{
> +	struct sk_buff *skb_head;
> +	struct fifo_sched_data *q = qdisc_priv(sch);
> +
> +	if (likely(skb_queue_len(&sch->q) < q->limit))
> +		return qdisc_enqueue_tail(skb, sch);
> +
> +	/* queue full, remove one skb to fulfill the limit */
> +	skb_head = qdisc_dequeue_head(sch);
> +	sch->bstats.bytes -= qdisc_pkt_len(skb_head);
> +	sch->bstats.packets--;
> +	sch->q.qlen--;

I don't think this is needed; qdisc_dequeue_head() updated it already.

> +	sch->qstats.drops++;
> +	kfree_skb(skb_head);
> +
> +	qdisc_enqueue_tail(skb, sch);
> +
> +	return NET_XMIT_CN;
> +}
> +
> +
>  static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
>  {
>  	struct fifo_sched_data *q = qdisc_priv(sch);
> @@ -108,6 +130,20 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
>  };
>  EXPORT_SYMBOL(bfifo_qdisc_ops);
>  
> +struct Qdisc_ops pfifo_head_drop_qdisc_ops __read_mostly = {
> +	.id		=	"pfifo_head_drop",
> +	.priv_size	=	sizeof(struct fifo_sched_data),
> +	.enqueue	=	pfifo_front_enqueue,
> +	.dequeue	=	qdisc_dequeue_head,
> +	.peek		=	qdisc_peek_head,
> +	.drop		=	qdisc_queue_drop,

Probably it isn't used much, but it seems for consistency this drop
should be implemented as a head drop.

Jarek P.
