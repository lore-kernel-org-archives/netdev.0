From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] sch_sfq: allow big packets and be fair
Date: Tue, 21 Dec 2010 10:15:06 +0000
Message-ID: <20101221101506.GA8149@ff.dom.local>
References: <1292886976.2627.146.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:34716 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933556Ab0LUKPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 05:15:15 -0500
Received: by fxm18 with SMTP id 18so4106896fxm.2
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 02:15:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292886976.2627.146.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-12-21 00:16, Eric Dumazet wrote:
> SFQ is currently 'limited' to small packets, because it uses a 16bit
> allotment number per flow. Switch it to 18bit, and use appropriate
> handling to make sure this allotment is in [1 .. quantum] range before a
> new packet is dequeued, so that fairness is respected.

Well, such two important changes should be in separate patches.

The change of allotment limit looks OK (but I would try scaling, e.g.
in 16-byte chunks, btw).

The change in fair treatment looks dubious. A flow which uses exactly
it's quantum in one round will be skipped in the next round. A flow
which uses a bit more than its quantum in one round, will be skipped
too, while we should only give it less this time to keep the sum up to
2 quantums. (The usual algorithm is to check if a flow has enough
"tickets" for sending its next packet.)

Jarek P.

> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jarek Poplawski <jarkao2@gmail.com>
> Cc: Patrick McHardy <kaber@trash.net>
> ---
>  net/sched/sch_sfq.c |   24 ++++++++++++++++--------
>  1 file changed, 16 insertions(+), 8 deletions(-)
> 
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index c474b4b..878704a 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -67,7 +67,7 @@
>  
>  	IMPLEMENTATION:
>  	This implementation limits maximal queue length to 128;
> -	maximal mtu to 2^15-1; max 128 flows, number of hash buckets to 1024.
> +	maximal mtu to 2^16-1; max 128 flows, number of hash buckets to 1024.
>  	The only goal of this restrictions was that all data
>  	fit into one 4K page on 32bit arches.
>  
> @@ -99,9 +99,10 @@ struct sfq_slot {
>  	sfq_index	qlen; /* number of skbs in skblist */
>  	sfq_index	next; /* next slot in sfq chain */
>  	struct sfq_head dep; /* anchor in dep[] chains */
> -	unsigned short	hash; /* hash value (index in ht[]) */
> -	short		allot; /* credit for this slot */
> +	unsigned int	hash:14; /* hash value (index in ht[]) */
> +	unsigned int	allot:18; /* credit for this slot */
>  };
> +#define ALLOT_ZERO (1 << 16)
>  
>  struct sfq_sched_data
>  {
> @@ -394,7 +395,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  			q->tail->next = x;
>  		}
>  		q->tail = slot;
> -		slot->allot = q->quantum;
> +		slot->allot = ALLOT_ZERO + q->quantum;
>  	}
>  	if (++sch->q.qlen <= q->limit) {
>  		sch->bstats.bytes += qdisc_pkt_len(skb);
> @@ -430,8 +431,14 @@ sfq_dequeue(struct Qdisc *sch)
>  	if (q->tail == NULL)
>  		return NULL;
>  
> +next:
>  	a = q->tail->next;
>  	slot = &q->slots[a];
> +	if (slot->allot <= ALLOT_ZERO) {
> +		q->tail = slot;
> +		slot->allot += q->quantum;
> +		goto next;
> +	}
>  	skb = slot_dequeue_head(slot);
>  	sfq_dec(q, a);
>  	sch->q.qlen--;
> @@ -446,9 +453,8 @@ sfq_dequeue(struct Qdisc *sch)
>  			return skb;
>  		}
>  		q->tail->next = next_a;
> -	} else if ((slot->allot -= qdisc_pkt_len(skb)) <= 0) {
> -		q->tail = slot;
> -		slot->allot += q->quantum;
> +	} else {
> +		slot->allot -= qdisc_pkt_len(skb);
>  	}
>  	return skb;
>  }
> @@ -610,7 +616,9 @@ static int sfq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
>  	struct sfq_sched_data *q = qdisc_priv(sch);
>  	const struct sfq_slot *slot = &q->slots[q->ht[cl - 1]];
>  	struct gnet_stats_queue qs = { .qlen = slot->qlen };
> -	struct tc_sfq_xstats xstats = { .allot = slot->allot };
> +	struct tc_sfq_xstats xstats = {
> +		.allot = slot->allot - ALLOT_ZERO
> +	};
>  	struct sk_buff *skb;
>  
>  	slot_queue_walk(slot, skb)
> 
> 
> --
