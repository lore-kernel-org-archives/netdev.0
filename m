From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1] sched: add head drop fifo queue
Date: Mon, 18 Jan 2010 15:24:36 +0100
Message-ID: <4B546F24.6070404@trash.net>
References: <1263820875-7240-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55723 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119Ab0AROYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 09:24:40 -0500
In-Reply-To: <1263820875-7240-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hagen Paul Pfeifer wrote:
> diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
> index 69188e8..8286882 100644
> --- a/net/sched/sch_fifo.c
> +++ b/net/sched/sch_fifo.c
> @@ -43,6 +43,50 @@ static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
>  	return qdisc_reshape_fail(skb, sch);
>  }
>  
> +static int bfifo_front_enqueue(struct sk_buff *skb, struct Qdisc* sch)
> +{
> +	struct fifo_sched_data *q = qdisc_priv(sch);
> +	const unsigned int skb_len = qdisc_pkt_len(skb);
> +
> +	if (likely(sch->qstats.backlog + qdisc_pkt_len(skb) <= q->limit))
> +		return qdisc_enqueue_tail(skb, sch);
> +
> +	/* queue full -> remove skb's from the queue head until we
> +	 * undershoot the queue limit in bytes */
> +	do {
> +		struct sk_buff *skb_head = qdisc_dequeue_head(sch);
> +		if (skb_head == NULL)
> +			return qdisc_reshape_fail(skb, sch);
> +		sch->bstats.bytes -= qdisc_pkt_len(skb_head);
> +		sch->bstats.packets--;
> +		sch->q.qlen--;

This won't work if the qdisc is used as leaf qdisc. The upper qdisc
will increment q.qlen by one when the skb was successfully enqueued,
so it will differ from the real queue length, which is not allowed.
You need to call qdisc_tree_decrease_qlen() to adjust all qlen values
in the hierarchy. Additionally you might want to consider returning
NET_XMIT_CN in this case to inform the upper layers of congestion.
Be aware though that in this case, the upper qdisc won't increment
its q.qlen, so qdisc_tree_decrease_qlen() needs to use one less that
the actual number of dropped packets.

If you don't actually need the bfifo, I'd suggest to only add the
pfifo head drop qdisc since qdisc_tree_decrease_qlen() is kind of
expensive and mainly meant for exceptional cases.

> +		sch->qstats.drops++;
> +		kfree_skb(skb_head);
> +	} while (sch->qstats.backlog + skb_len > q->limit);
> +
> +	return qdisc_enqueue_tail(skb, sch);
> +}
> +
> +static int pfifo_front_enqueue(struct sk_buff *skb, struct Qdisc* sch)
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

Same problem here. Returning NET_XMIT_CN will fix this case.

> +	sch->qstats.drops++;
> +	kfree_skb(skb_head);
> +
> +	return qdisc_enqueue_tail(skb, sch);
> +}
> +
> +
>  static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
>  {
>  	struct fifo_sched_data *q = qdisc_priv(sch);
> @@ -50,7 +94,8 @@ static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
>  	if (opt == NULL) {
>  		u32 limit = qdisc_dev(sch)->tx_queue_len ? : 1;
>  
> -		if (sch->ops == &bfifo_qdisc_ops)
> +		if ((sch->ops == &bfifo_qdisc_ops) ||
> +			(sch->ops == &bfifo_head_drop_qdisc_ops))

No need for the extra parentheses, also please align the beginning
of both lines.

>  			limit *= psched_mtu(qdisc_dev(sch));
>  
>  		q->limit = limit;
> @@ -108,6 +153,37 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
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
> +	.init		=	fifo_init,
> +	.reset		=	qdisc_reset_queue,
> +	.change		=	fifo_init,
> +	.dump		=	fifo_dump,
> +	.owner		=	THIS_MODULE,
> +};
> +EXPORT_SYMBOL(pfifo_head_drop_qdisc_ops);
> +
> +struct Qdisc_ops bfifo_head_drop_qdisc_ops __read_mostly = {
> +	.id		=	"bfifo_head_drop",
> +	.priv_size	=	sizeof(struct fifo_sched_data),
> +	.enqueue	=	bfifo_front_enqueue,
> +	.dequeue	=	qdisc_dequeue_head,
> +	.peek		=	qdisc_peek_head,
> +	.drop		=	qdisc_queue_drop,
> +	.init		=	fifo_init,
> +	.reset		=	qdisc_reset_queue,
> +	.change		=	fifo_init,
> +	.dump		=	fifo_dump,
> +	.owner		=	THIS_MODULE,
> +};
> +EXPORT_SYMBOL(bfifo_head_drop_qdisc_ops);
> +
> +
>  /* Pass size change message down to embedded FIFO */
>  int fifo_set_limit(struct Qdisc *q, unsigned int limit)
>  {

