From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] NET: [UPDATED] Multiqueue network device support
 implementation.
Date: Fri, 13 Apr 2007 02:15:56 +0200
Message-ID: <461ECBBC.3040400@trash.net>
References: <20070413001630.18763.41107.stgit@gitlost.site> <20070413001955.18763.35268.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com, cramerj@intel.com,
	auke-jan.h.kok@intel.com, christopher.leech@intel.com
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57040 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938AbXDMAQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 20:16:14 -0400
In-Reply-To: <20070413001955.18763.35268.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter P Waskiewicz Jr wrote:
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 219a57f..3ce449e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1471,6 +1471,8 @@ gso:
>  		q = dev->qdisc;
>  		if (q->enqueue) {
>  			rc = q->enqueue(skb, q);
> +			/* reset queue_mapping to zero */
> +			skb->queue_mapping = 0;


This must be done before enqueueing. At this point you don't even have
a valid reference to the skb anymore.

> @@ -3326,12 +3330,23 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
>  	if (sizeof_priv)
>  		dev->priv = netdev_priv(dev);
>  
> + 	alloc_size = (sizeof(struct net_device_subqueue) * queue_count);
> + 
> + 	p = kzalloc(alloc_size, GFP_KERNEL);
> + 	if (!p) {
> + 		printk(KERN_ERR "alloc_netdev: Unable to allocate queues.\n");
> + 		return NULL;


Still leaks the device

> diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
> index 5cfe60b..6a38905 100644
> --- a/net/sched/sch_prio.c
> +++ b/net/sched/sch_prio.c
> @@ -144,11 +152,17 @@ prio_dequeue(struct Qdisc* sch)
>  	struct Qdisc *qdisc;
>  
>  	for (prio = 0; prio < q->bands; prio++) {
> -		qdisc = q->queues[prio];
> -		skb = qdisc->dequeue(qdisc);
> -		if (skb) {
> -			sch->q.qlen--;
> -			return skb;
> +		/* Check if the target subqueue is available before
> +		 * pulling an skb.  This way we avoid excessive requeues
> +		 * for slower queues.
> +		 */
> +		if (!netif_subqueue_stopped(sch->dev, q->band2queue[prio])) {
> +			qdisc = q->queues[prio];
> +			skb = qdisc->dequeue(qdisc);
> +			if (skb) {
> +				sch->q.qlen--;
> +				return skb;
> +			}
>  		}
>  	}
>  	return NULL;
> @@ -200,6 +214,10 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
>  	struct prio_sched_data *q = qdisc_priv(sch);
>  	struct tc_prio_qopt *qopt = RTA_DATA(opt);
>  	int i;
> +	int queue;
> +	int qmapoffset;
> +	int offset;
> +	int mod;
>  
>  	if (opt->rta_len < RTA_LENGTH(sizeof(*qopt)))
>  		return -EINVAL;
> @@ -242,6 +260,30 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
>  			}
>  		}
>  	}
> +	/* setup queue to band mapping */
> +	if (q->bands < sch->dev->egress_subqueue_count) {
> +		qmapoffset = 1;
> +		mod = sch->dev->egress_subqueue_count;
> +	} else {
> +		mod = q->bands % sch->dev->egress_subqueue_count;
> +		qmapoffset = q->bands / sch->dev->egress_subqueue_count +
> +				((mod) ? 1 : 0);
> +	}
> +
> +	queue = 0;
> +	offset = 0;
> +	for (i = 0; i < q->bands; i++) {
> +		q->band2queue[i] = queue;
> +		if ( ((i + 1) - offset) == qmapoffset) {
> +			queue++;
> +			offset += qmapoffset;
> +			if (mod)
> +				mod--;
> +			qmapoffset = q->bands /
> +				sch->dev->egress_subqueue_count +
> +				((mod) ? 1 : 0);
> +		}
> +	}
>  	return 0;
>  }


I stand by my point, this needs to be explicitly enabled by the
user since it changes the behaviour of prio on multiqueue capable
device.
