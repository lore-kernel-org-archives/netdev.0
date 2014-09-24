From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Wed, 24 Sep 2014 10:23:15 -0700
Message-ID: <1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140924160932.9721.56450.stgit@localhost>
	 <20140924161047.9721.43080.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>, toke@toke.dk,
	Florian Westphal <fw@strlen.de>, jhs@mojatatu.com,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:63631 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883AbaIXRXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 13:23:11 -0400
Received: by mail-pa0-f44.google.com with SMTP id eu11so8119075pac.17
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 10:23:10 -0700 (PDT)
In-Reply-To: <20140924161047.9721.43080.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-24 at 18:12 +0200, Jesper Dangaard Brouer wrote:
> Based on DaveM's recent API work on dev_hard_start_xmit(), that allows
> sending/processing an entire skb list.
> 
> This patch implements qdisc bulk dequeue, by allowing multiple packets
> to be dequeued in dequeue_skb().
> 
> The optimization principle for this is two fold, (1) to amortize
> locking cost and (2) avoid expensive tailptr update for notifying HW.
>  (1) Several packets are dequeued while holding the qdisc root_lock,
> amortizing locking cost over several packet.  The dequeued SKB list is
> processed under the TXQ lock in dev_hard_start_xmit(), thus also
> amortizing the cost of the TXQ lock.
>  (2) Further more, dev_hard_start_xmit() will utilize the skb->xmit_more
> API to delay HW tailptr update, which also reduces the cost per
> packet.
> 
> One restriction of the new API is that every SKB must belong to the
> same TXQ.  This patch takes the easy way out, by restricting bulk
> dequeue to qdisc's with the TCQ_F_ONETXQUEUE flag, that specifies the
> qdisc only have attached a single TXQ.
> 
> Some detail about the flow; dev_hard_start_xmit() will process the skb
> list, and transmit packets individually towards the driver (see
> xmit_one()).  In case the driver stops midway in the list, the
> remaining skb list is returned by dev_hard_start_xmit().  In
> sch_direct_xmit() this returned list is requeued by dev_requeue_skb().
> 
> To avoid overshooting the HW limits, which results in requeuing, the
> patch limits the amount of bytes dequeued, based on the drivers BQL
> limits.  In-effect bulking will only happen for BQL enabled drivers.
> Besides the bytelimit from BQL, also limit bulking to maximum 8
> packets to avoid any issues with available descriptor in HW.
> 
> For now, as a conservative approach, don't bulk dequeue GSO and
> segmented GSO packets, because testing showed requeuing occuring
> with segmented GSO packets.
> 
> Jointed work with Hannes, Daniel and Florian.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> 
> ---
> V4:
> - Patch rewritten in the Red Hat Neuchatel office jointed work with
>   Hannes, Daniel and Florian.
> - Conservative approach of only using on BQL enabled drivers
> - No user tunable parameter, but limit bulking to 8 packets.
> - For now, avoid bulking GSO packets packets.
> 
> V3:
>  - Correct use of BQL
>  - Some minor adjustments based on feedback.
>  - Default setting only bulk dequeue 1 extra packet (2 packets).
> 
> V2:
>  - Restruct functions, split out functionality
>  - Use BQL bytelimit to avoid overshooting driver limits
> ---
>  include/net/sch_generic.h |   16 +++++++++++++++
>  net/sched/sch_generic.c   |   47 +++++++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 61 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index a3cfb8e..4e39a3e 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -6,6 +6,7 @@
>  #include <linux/rcupdate.h>
>  #include <linux/pkt_sched.h>
>  #include <linux/pkt_cls.h>
> +#include <linux/dynamic_queue_limits.h>
>  #include <net/gen_stats.h>
>  #include <net/rtnetlink.h>
>  
> @@ -111,6 +112,21 @@ static inline void qdisc_run_end(struct Qdisc *qdisc)
>  	qdisc->__state &= ~__QDISC___STATE_RUNNING;
>  }
>  
> +static inline bool qdisc_may_bulk(const struct Qdisc *qdisc)
> +{
> +	return qdisc->flags & TCQ_F_ONETXQUEUE;
> +}
> +
> +static inline int qdisc_avail_bulklimit(const struct netdev_queue *txq)
> +{
> +#ifdef CONFIG_BQL
> +	/* Non-BQL migrated drivers will return 0, too. */
> +	return dql_avail(&txq->dql);
> +#else
> +	return 0;
> +#endif
> +}
> +
>  static inline bool qdisc_is_throttled(const struct Qdisc *qdisc)
>  {
>  	return test_bit(__QDISC_STATE_THROTTLED, &qdisc->state) ? true : false;
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 19696eb..6fba089 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -56,6 +56,42 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
>  	return 0;
>  }
>  
> +static struct sk_buff *try_bulk_dequeue_skb(struct Qdisc *q,
> +					    struct sk_buff *head_skb,
> +					    int bytelimit)
> +{
> +	struct sk_buff *skb, *tail_skb = head_skb;
> +	int budget = 8; /* Arbitrary, but conservatively choosen limit */
> +
> +	while (bytelimit > 0 && --budget > 0) {
> +		/* For now, don't bulk dequeue GSO (or GSO segmented) pkts */

Hmm... this is a serious limitation.

> +		if (tail_skb->next || skb_is_gso(tail_skb))
> +			break;
> +
> +		skb = q->dequeue(q);
> +		if (!skb)
> +			break;
> +
> +		bytelimit -= skb->len; /* covers GSO len */

Not really, use qdisc_pkt_len(skb) instead, to have a better byte count.

> +		skb = validate_xmit_skb(skb, qdisc_dev(q));
> +		if (!skb)
> +			break;
> +
> +		/* "skb" can be a skb list after validate call above
> +		 * (GSO segmented), but it is okay to append it to
> +		 * current tail_skb->next, because next round will exit
> +		 * in-case "tail_skb->next" is a skb list.
> +		 */

It would be trivial to change validate_xmit_skb() to return the head and
tail of the chain. Walking the chain would hit hot cache lines, but it
is better not having to walk it.

> +		tail_skb->next = skb;
> +		tail_skb = skb;

So that here we do : tail_skb = tail;

> +	}
> +
> +	return head_skb;
> +}
> +
> +/* Note that dequeue_skb can possibly return a SKB list (via skb->next).
> + * A requeued skb (via q->gso_skb) can also be a SKB list.
> + */
>  static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
>  {
>  	struct sk_buff *skb = q->gso_skb;
> @@ -70,10 +106,17 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
>  		} else
>  			skb = NULL;
>  	} else {
> -		if (!(q->flags & TCQ_F_ONETXQUEUE) || !netif_xmit_frozen_or_stopped(txq)) {
> +		if (!(q->flags & TCQ_F_ONETXQUEUE) ||
> +		    !netif_xmit_frozen_or_stopped(txq)) {
> +			int bytelimit = qdisc_avail_bulklimit(txq);
> +
>  			skb = q->dequeue(q);
> -			if (skb)
> +			if (skb) {
> +				bytelimit -= skb->len;

  qdisc_pkt_len(skb)

>  				skb = validate_xmit_skb(skb, qdisc_dev(q));
> +			}
> +			if (skb && qdisc_may_bulk(q))
> +				skb = try_bulk_dequeue_skb(q, skb, bytelimit);
>  		}
>  	}
>  

It looks good, but we really need to take care of TSO packets.

pktgen is nice, but do not represent the majority of the traffic we send
from high performance host where we want this bulk dequeue thing ;)

Thanks guys !
