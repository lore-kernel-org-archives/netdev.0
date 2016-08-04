From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Hitting WARN_ON_ONCE on skb_try_coalesce
Date: Thu, 04 Aug 2016 18:56:14 +0200
Message-ID: <1470329774.13693.39.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160803233605.GF2967@localhost.localdomain>
	 <1470290142.13693.11.camel@edumazet-glaptop3.roam.corp.google.com>
	 <215693ed-3873-428d-3258-a0684f1e4015@gmail.com>
	 <20160804164848.GA2966@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36199 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933989AbcHDQ4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 12:56:19 -0400
Received: by mail-io0-f182.google.com with SMTP id b62so276259015iod.3
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 09:56:18 -0700 (PDT)
In-Reply-To: <20160804164848.GA2966@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-04 at 13:48 -0300, Marcelo Ricardo Leitner wrote:

> If we pack the struct, we have enough space to save the original
> truesize and restore it when dequeing it.
> This way the skb won't be charging sender buf too much while sitting on
> netem queue and will allow proper accouting on rx buf if it's
> reinjected.
> 
> The check on skb->sk in the last chunk is for handling duplicated
> packets.
> 
> This patch makes it not trigger the Warn for this test. Wdyt?
> 
> ---8<---
> 
> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
> @@ -147,7 +147,8 @@ struct netem_sched_data {
>  struct netem_skb_cb {
>  	psched_time_t	time_to_send;
>  	ktime_t		tstamp_save;
> -};
> +	unsigned int	truesize;
> +} __attribute__ ((packed));


>  
> 
>  static struct sk_buff *netem_rb_to_skb(struct rb_node *rb)
> @@ -428,6 +429,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch,
>  	struct sk_buff *skb2;
>  	struct sk_buff *segs = NULL;
>  	unsigned int len = 0, last_len, prev_len = qdisc_pkt_len(skb);
> +	unsigned int truesize;
>  	int nb = 0;
>  	int count = 1;
>  	int rc = NET_XMIT_SUCCESS;
> @@ -452,8 +454,10 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch,
>  	/* If a delay is expected, orphan the skb. (orphaning usually takes
>  	 * place at TX completion time, so _before_ the link transit delay)
>  	 */
> -	if (q->latency || q->jitter)
> +	if (q->latency || q->jitter) {
> +		truesize = skb->truesize;
>  		skb_orphan_partial(skb);
> +	}
>  
>  	/*
>  	 * If we need to duplicate packet, then re-insert at top of the
> @@ -508,6 +512,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch,
>  	qdisc_qstats_backlog_inc(sch, skb);
>  
>  	cb = netem_skb_cb(skb);
> +	cb->truesize = truesize;
>  	if (q->gap == 0 ||		/* not doing reordering */
>  	    q->counter < q->gap - 1 ||	/* inside last reordering gap */
>  	    q->reorder < get_crandom(&q->reorder_cor)) {
> @@ -591,6 +596,10 @@ tfifo_dequeue:
>  	if (skb) {
>  		qdisc_qstats_backlog_dec(sch, skb);
>  deliver:
> +		if (skb->sk && skb->truesize == 1) {
> +			skb->truesize = netem_skb_cb(skb)->truesize;
> +			atomic_add(skb->truesize - 1, &skb->sk->sk_wmem_alloc);
> +		}
>  		qdisc_bstats_update(sch, skb);
>  		return skb;
>  	}


It is probably more complicated.

netem can have a child qdisc that could mess skb->truesize and/or
segment it (check tbf for example)

So I would make sure that the skb->truesize changes are only around the
queue/dequeue of skb in netem tfifo, not after ->queue()/dequeue() on
the child.

Thanks.
