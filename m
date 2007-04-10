From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: [UPDATED] Multiqueue network device support implementation.
Date: Tue, 10 Apr 2007 11:48:41 +0200
Message-ID: <461B5D79.9040307@trash.net>
References: <20070410003243.32106.98266.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com, cramerj@intel.com,
	auke-jan.h.kok@intel.com, christopher.leech@intel.com
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56104 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314AbXDJJtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 05:49:13 -0400
In-Reply-To: <20070410003243.32106.98266.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter P Waskiewicz Jr wrote:
> +	/* To retrieve statistics per subqueue - FOR FUTURE USE */
> +	struct net_device_stats* (*get_subqueue_stats)(struct net_device *dev,
> +							int queue_index);


Please no future use stuff, just add it when you need it.

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 219a57f..c11c8fa 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3326,12 +3328,23 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
>  	if (sizeof_priv)
>  		dev->priv = netdev_priv(dev);
>  
> + 	alloc_size = (sizeof(struct net_device_subqueue) * queue_count);
> + 
> + 	p = kzalloc(alloc_size, GFP_KERNEL);
> + 	if (!p) {
> + 		printk(KERN_ERR "alloc_netdev: Unable to allocate queues.\n");
> + 		return NULL;


This leaks the device. You treat every single-queue device as having
a single subqueue. If it doesn't get too ugly it would be nice to avoid
this and only allocate the subqueue states for real multiqueue devices.

> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -133,7 +133,8 @@ static inline int qdisc_restart(struct net_device *dev)
>  			/* And release queue */
>  			spin_unlock(&dev->queue_lock);
>  
> -			if (!netif_queue_stopped(dev)) {
> +			if (!netif_queue_stopped(dev) &&
> +			    !netif_subqueue_stopped(dev, skb->queue_mapping)) {
>  				int ret;
>  
>  				ret = dev_hard_start_xmit(skb, dev);
> @@ -149,7 +150,6 @@ static inline int qdisc_restart(struct net_device *dev)
>  					goto collision;
>  				}
>  			}
> -


Unrelated whitespace change.

>  			/* NETDEV_TX_BUSY - we need to requeue */
>  			/* Release the driver */
>  			if (!nolock) {
> diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
> index 5cfe60b..7365621 100644
> --- a/net/sched/sch_prio.c
> +++ b/net/sched/sch_prio.c
> @@ -43,6 +43,7 @@ struct prio_sched_data
>  	struct tcf_proto *filter_list;
>  	u8  prio2band[TC_PRIO_MAX+1];
>  	struct Qdisc *queues[TCQ_PRIO_BANDS];
> +	u16 band2queue[TC_PRIO_MAX + 1];
>  };
>  
>  
> @@ -63,20 +64,26 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
>  		case TC_ACT_SHOT:
>  			return NULL;
>  		};
> -

Same here

>  		if (!q->filter_list ) {
>  #else
>  		if (!q->filter_list || tc_classify(skb, q->filter_list, &res)) {
>  #endif
>  			if (TC_H_MAJ(band))
>  				band = 0;
> +			skb->queue_mapping =
> +				  q->prio2band[q->band2queue[band&TC_PRIO_MAX]];
> +


Does this needs to be cleared at some point again? TC actions might
redirect or mirror packets to other (multiqueue) devices.

> @@ -242,6 +259,30 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
>  			}
>  		}
>  	}
> +	/* setup queue to band mapping */
> +	if (q->bands < sch->dev->egress_subqueue_count) {
> +		qmapoffset = 1;
> +		mod = 0;
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


Besides being quite ugly, I don't think this does what you want.
For bands < queues we get band2queue[0] = 0, all others map to 1.
