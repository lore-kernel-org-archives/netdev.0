From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [net-next PATCH 2/3] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Tue, 02 Sep 2014 18:14:36 +0200
Message-ID: <5405ECEC.601@redhat.com>
References: <20140902143254.1918.8419.stgit@dragon> <20140902143538.1918.82870.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50215 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754182AbaIBQO7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 12:14:59 -0400
In-Reply-To: <20140902143538.1918.82870.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2014 04:35 PM, Jesper Dangaard Brouer wrote:
> Based on DaveM's recent API work on dev_hard_start_xmit(), that allows
> sending/processing an entire skb list.
>
> This patch implements qdisc bulk dequeue, by allowing multiple packets
> to be dequeued in dequeue_skb().
>
> One restriction of the new API is that every SKB must belong to the
> same TXQ.  This patch takes the easy way out, by restricting bulk
> dequeue to qdisc's with the TCQ_F_ONETXQUEUE flag, that specifies the
> qdisc only have attached a single TXQ.
>
> Testing if this have the desired effect is the challenging part.
> Generating enough packets for a backlog queue to form at the qdisc is
> a challenge (because overhead else-where is a limiting factor
> e.g. I've measured the pure skb_alloc/free cycle to cost 80ns).
>
> After trying many qdisc setups, I figured out that, the easiest way to
> make a backlog form is to fully load the system, all CPUs.  And I can
> even demonstrate this with the default MQ disc.
>
> This is a 12 core CPU (without HT) running trafgen on all 12 cores,
> via qdisc-path using sendto():
>   * trafgen --cpp --dev $DEV --conf udp_example02_const.trafgen --qdisc-path -t0 --cpus 12
>
> Measuring TX pps:
>   * Baseline  : 12,815,925 pps
>   * This patch: 14,892,001 pps

I'm curious about *_RR tests and *_STREAM results e.g. from super_netperf.

One thing we might want to be careful about when comparing before and
after numbers though is that now we still have the old quota limit, but
don't adjust it here. It probably depends on how you interpret quota,
but we now do more work within our quota than before.

> This is crazy fast. This measurement is actually "too-high" as
> 10Gbit/s wirespeed is 14,880,952 (11049 pps too fast).
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
...
>   net/sched/sch_generic.c |   23 ++++++++++++++++++++++-
>   1 files changed, 22 insertions(+), 1 deletions(-)
>
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 5b261e9..30814ef 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -56,6 +56,9 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
>   	return 0;
>   }
>
> +/* Note that dequeue_skb can possibly return a SKB list (via skb->next).
> + * A requeued skb (via q->gso_skb) can also be a SKB list.
> + */
>   static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
>   {
>   	struct sk_buff *skb = q->gso_skb;
> @@ -70,10 +73,28 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
>   		} else
>   			skb = NULL;
>   	} else {
> -		if (!(q->flags & TCQ_F_ONETXQUEUE) || !netif_xmit_frozen_or_stopped(txq)) {
> +		if (!(q->flags & TCQ_F_ONETXQUEUE)
> +		    || !netif_xmit_frozen_or_stopped(txq)) {
>   			skb = q->dequeue(q);
>   			if (skb)
>   				skb = validate_xmit_skb(skb, qdisc_dev(q));
> +			/* bulk dequeue */
> +			if (skb && !skb->next && (q->flags & TCQ_F_ONETXQUEUE)) {

This check should better be an inline for sch_generic.h, e.g. ...

static inline bool qdisc_may_bulk(const struct Qdisc *qdisc,
				  const struct sk_buff *skb)
{
	return (qdisc->flags & TCQ_F_ONETXQUEUE) && !skb->next;
}

> +				struct sk_buff *new, *head = skb;
> +				int limit = 7;
> +
> +				do {
> +					new = q->dequeue(q);
> +					if (new)
> +						new = validate_xmit_skb(
> +							new, qdisc_dev(q));

This and above dequeue() + validate_xmit_skb() code should probably also go
into a helper if you're at it, e.g. ...

static inline struct sk_buff *qdisc_dequeue_validate(struct Qdisc *qdisc)
{
	struct sk_buff *skb = qdisc->dequeue(qdisc);

	if (skb != NULL)
		skb = validate_xmit_skb(skb, qdisc_dev(qdisc));

	return skb;
}

> +					if (new) {
> +						skb->next = new;
> +						skb = new;
> +					}
> +				} while (new && --limit);
> +				skb = head;
> +			}
>   		}
>   	}
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
