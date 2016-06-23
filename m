From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 4/4] net_sched: generalize bulk dequeue
Date: Thu, 23 Jun 2016 09:26:47 +0200
Message-ID: <1466666807.4910.4.camel@redhat.com>
References: <1466576212-15012-1-git-send-email-edumazet@google.com>
	 <1466576212-15012-5-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52901 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353AbcFWH04 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2016 03:26:56 -0400
In-Reply-To: <1466576212-15012-5-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-06-21 at 23:16 -0700, Eric Dumazet wrote:
> When qdisc bulk dequeue was added in linux-3.18 (commit
> 5772e9a3463b "qdisc: bulk dequeue support for qdiscs
> with TCQ_F_ONETXQUEUE"), it was constrained to some
> specific qdiscs.
> 
> With some extra care, we can extend this to all qdiscs,
> so that typical traffic shaping solutions can benefit from
> small batches (8 packets in this patch).
> 
> For example, HTB is often used on some multi queue device.
> And bonding/team are multi queue devices...
> 
> Idea is to bulk-dequeue packets mapping to the same transmit queue.
> 
> This brings between 35 and 80 % performance increase in HTB setup
> under pressure on a bonding setup :
> 
> 1) NUMA node contention :   610,000 pps -> 1,110,000 pps
> 2) No node contention   : 1,380,000 pps -> 1,930,000 pps
> 
> Now we should work to add batches on the enqueue() side ;)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Florian Westphal <fw@strlen.de>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  include/net/sch_generic.h |  7 ++---
>  net/sched/sch_generic.c   | 68 ++++++++++++++++++++++++++++++++++++++++-------
>  2 files changed, 62 insertions(+), 13 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 04e84c07c94f..909aff2db2b3 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -75,13 +75,14 @@ struct Qdisc {
>  	/*
>  	 * For performance sake on SMP, we put highly modified fields at the end
>  	 */
> -	struct Qdisc		*next_sched ____cacheline_aligned_in_smp;
> -	struct sk_buff		*gso_skb;
> -	unsigned long		state;
> +	struct sk_buff		*gso_skb ____cacheline_aligned_in_smp;
>  	struct sk_buff_head	q;
>  	struct gnet_stats_basic_packed bstats;
>  	seqcount_t		running;
>  	struct gnet_stats_queue	qstats;
> +	unsigned long		state;
> +	struct Qdisc            *next_sched;
> +	struct sk_buff		*skb_bad_txq;
>  	struct rcu_head		rcu_head;
>  	int			padded;
>  	atomic_t		refcnt;
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index ff86606954f2..e95b67cd5718 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -77,6 +77,34 @@ static void try_bulk_dequeue_skb(struct Qdisc *q,
>  	skb->next = NULL;
>  }
>  
> +/* This variant of try_bulk_dequeue_skb() makes sure
> + * all skbs in the chain are for the same txq
> + */
> +static void try_bulk_dequeue_skb_slow(struct Qdisc *q,
> +				      struct sk_buff *skb,
> +				      int *packets)
> +{
> +	int mapping = skb_get_queue_mapping(skb);
> +	struct sk_buff *nskb;
> +	int cnt = 0;
> +
> +	do {
> +		nskb = q->dequeue(q);
> +		if (!nskb)
> +			break;
> +		if (unlikely(skb_get_queue_mapping(nskb) != mapping)) {
> +			q->skb_bad_txq = nskb;
> +			qdisc_qstats_backlog_inc(q, nskb);
> +			q->q.qlen++;
> +			break;
> +		}
> +		skb->next = nskb;
> +		skb = nskb;
> +	} while (++cnt < 8);
> +	(*packets) += cnt;
> +	skb->next = NULL;
> +}
> +
>  /* Note that dequeue_skb can possibly return a SKB list (via skb->next).
>   * A requeued skb (via q->gso_skb) can also be a SKB list.
>   */
> @@ -87,8 +115,9 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
>  	const struct netdev_queue *txq = q->dev_queue;
>  
>  	*packets = 1;
> -	*validate = true;
>  	if (unlikely(skb)) {
> +		/* skb in gso_skb were already validated */
> +		*validate = false;
>  		/* check the reason of requeuing without tx lock first */
>  		txq = skb_get_tx_queue(txq->dev, skb);
>  		if (!netif_xmit_frozen_or_stopped(txq)) {
> @@ -97,15 +126,30 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
>  			q->q.qlen--;
>  		} else
>  			skb = NULL;
> -		/* skb in gso_skb were already validated */
> -		*validate = false;
> -	} else {
> -		if (!(q->flags & TCQ_F_ONETXQUEUE) ||
> -		    !netif_xmit_frozen_or_stopped(txq)) {
> -			skb = q->dequeue(q);
> -			if (skb && qdisc_may_bulk(q))
> -				try_bulk_dequeue_skb(q, skb, txq, packets);
> +		return skb;
> +	}
> +	*validate = true;
> +	skb = q->skb_bad_txq;
> +	if (unlikely(skb)) {
> +		/* check the reason of requeuing without tx lock first */
> +		txq = skb_get_tx_queue(txq->dev, skb);
> +		if (!netif_xmit_frozen_or_stopped(txq)) {
> +			q->skb_bad_txq = NULL;
> +			qdisc_qstats_backlog_dec(q, skb);
> +			q->q.qlen--;
> +			goto bulk;
>  		}
> +		return NULL;
> +	}
> +	if (!(q->flags & TCQ_F_ONETXQUEUE) ||
               
You can use qdisc_may_bulk() here, I guess. Not a functional change,
just to improve readability.

Paolo
