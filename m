From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2] NET: Multiple queue network device support
Date: Fri, 9 Mar 2007 14:40:37 +0100
Message-ID: <20070309134037.GH521@postel.suug.ch>
References: <20070209000942.5155.78998.stgit@gitlost.site> <20070209000950.5155.24763.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:32845 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767286AbXCINkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 08:40:17 -0500
Content-Disposition: inline
In-Reply-To: <20070209000950.5155.24763.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Kok, Auke <auke-jan.h.kok@intel.com> 2007-02-08 16:09
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 455d589..42b635c 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1477,6 +1477,49 @@ gso:
>  	skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
>  #endif
>  	if (q->enqueue) {
> +#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
> +		int queue_index;
> +		/* If we're a multi-queue device, get a queue index to lock */
> +		if (netif_is_multiqueue(dev))
> +		{
> +			/* Get the queue index and lock it. */
> +			if (likely(q->ops->map_queue)) {
> +				queue_index = q->ops->map_queue(skb, q);
> +				spin_lock(&dev->egress_subqueue[queue_index].queue_lock);
> +				rc = q->enqueue(skb, q);
> +				/*
> +				 * Unlock because the underlying qdisc
> +				 * may queue and send a packet from a
> +				 * different queue.
> +				 */
> +				spin_unlock(&dev->egress_subqueue[queue_index].queue_lock);
> +				qdisc_run(dev);

I really dislike this asymmetric locking logic, while enqueue() is called
with queue_lock held dequeue() is repsonsible to acquire the lock for
qdisc_restart().

> +				rc = rc == NET_XMIT_BYPASS
> +				           ? NET_XMIT_SUCCESS : rc;
> +				goto out;
> +			} else {
> +				printk(KERN_CRIT "Device %s is "
> +					"multiqueue, but map_queue is "
> +					"undefined in the qdisc!!\n",
> +					dev->name);
> +				kfree_skb(skb);

Move this check to tc_modify_qdisc(), it's useless to check this for
every packet being delivered.

> +			}
> +		} else {
> +			/* We're not a multi-queue device. */
> +			spin_lock(&dev->queue_lock);
> +			q = dev->qdisc;
> +			if (q->enqueue) {
> +				rc = q->enqueue(skb, q);
> +				qdisc_run(dev);
> +				spin_unlock(&dev->queue_lock);
> +				rc = rc == NET_XMIT_BYPASS
> +				           ? NET_XMIT_SUCCESS : rc;
> +				goto out;
> +			}
> +			spin_unlock(&dev->queue_lock);

Please don't duplicate already existing code.

> @@ -130,6 +140,72 @@ static inline int qdisc_restart(struct net_device *dev)
>  		}
>  		
>  		{
> +#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
> +			if (netif_is_multiqueue(dev)) {
> +				if (likely(q->ops->map_queue)) {
> +					queue_index = q->ops->map_queue(skb, q);
> +				} else {
> +					printk(KERN_CRIT "Device %s is "
> +						"multiqueue, but map_queue is "
> +						"undefined in the qdisc!!\n",
> +						dev->name);
> +					goto requeue;
> +				}

Yet another condition completely useless for every transmission.

> +				spin_unlock(&dev->egress_subqueue[queue_index].queue_lock);
> +				/* Check top level device, and any sub-device */
> +				if ((!netif_queue_stopped(dev)) &&
> +				  (!netif_subqueue_stopped(dev, queue_index))) {
> +					int ret;
> +					ret = dev->hard_start_subqueue_xmit(skb, dev, queue_index);
> +					if (ret == NETDEV_TX_OK) {
> +						if (!nolock) {
> +							netif_tx_unlock(dev);
> +						}
> +						return -1;
> +					}
> +					if (ret == NETDEV_TX_LOCKED && nolock) {
> +						spin_lock(&dev->egress_subqueue[queue_index].queue_lock);
> +						goto collision;
> +					}
> +				}
> +				/* NETDEV_TX_BUSY - we need to requeue */
> +				/* Release the driver */
> +				if (!nolock) {
> +					netif_tx_unlock(dev);
> +				}
> +				spin_lock(&dev->egress_subqueue[queue_index].queue_lock);
> +				q = dev->qdisc;

This is identical to the existing logic except for the different lock,
the additional to check subqueue state and a different hard_start_xmit
call. Share the logic.

> +			}
> +			else
> +			{
> +				/* We're a single-queue device */
> +				/* And release queue */
> +				spin_unlock(&dev->queue_lock);
> +				if (!netif_queue_stopped(dev)) {
> +					int ret;
> +
> +					ret = dev->hard_start_xmit(skb, dev);
> +					if (ret == NETDEV_TX_OK) {
> +						if (!nolock) {
> +							netif_tx_unlock(dev);
> +						}
> +						spin_lock(&dev->queue_lock);
> +						return -1;
> +					}
> +					if (ret == NETDEV_TX_LOCKED && nolock) {
> +						spin_lock(&dev->queue_lock);
> +						goto collision;
> +					}
> +				}
> +				/* NETDEV_TX_BUSY - we need to requeue */
> +				/* Release the driver */
> +				if (!nolock) {
> +					netif_tx_unlock(dev);
> +				}
> +				spin_lock(&dev->queue_lock);
> +				q = dev->qdisc;

Again, you just copied the existing code into a separate branch, fix the
branching logic!

> @@ -356,10 +454,18 @@ static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
>  	struct sk_buff_head *list = qdisc_priv(qdisc);
>  
>  	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++) {
> +#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
> +		if (netif_is_multiqueue(qdisc->dev))
> +			spin_lock(&qdisc->dev->egress_subqueue[0].queue_lock);
> +#endif
>  		if (!skb_queue_empty(list + prio)) {
>  			qdisc->q.qlen--;
>  			return __qdisc_dequeue_head(qdisc, list + prio);
>  		}
> +#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
> +		if (netif_is_multiqueue(qdisc->dev))
> +			spin_unlock(&qdisc->dev->egress_subqueue[0].queue_lock);
> +#endif

This lock/unlock for every band definitely screws performance.

>  	}
>  
>  	return NULL;
> @@ -141,18 +174,53 @@ prio_dequeue(struct Qdisc* sch)
>  	struct sk_buff *skb;
>  	struct prio_sched_data *q = qdisc_priv(sch);
>  	int prio;
> +#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
> +	int queue;
> +#endif
>  	struct Qdisc *qdisc;
>  
> +	/*
> +	 * If we're multiqueue, the basic approach is try the lock on each
> +	 * queue.  If it's locked, either we're already dequeuing, or enqueue
> +	 * is doing something.  Go to the next band if we're locked.  Once we
> +	 * have a packet, unlock the queue.  NOTE: the underlying qdisc CANNOT
> +	 * be a PRIO qdisc, otherwise we will deadlock.  FIXME
> +	 */
>  	for (prio = 0; prio < q->bands; prio++) {
> +#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
> +		if (netif_is_multiqueue(sch->dev)) {
> +			queue = q->band2queue[prio];
> +			if (spin_trylock(&sch->dev->egress_subqueue[queue].queue_lock)) {
> +				qdisc = q->queues[prio];
> +				skb = qdisc->dequeue(qdisc);
> +				if (skb) {
> +					sch->q.qlen--;
> +					skb->priority = prio;
> +					spin_unlock(&sch->dev->egress_subqueue[queue].queue_lock);
> +					return skb;
> +				}
> +				spin_unlock(&sch->dev->egress_subqueue[queue].queue_lock);
> +			}

Your modified qdisc_restart() expects the queue_lock to be locked, how
can this work?

> +		} else {
> +			qdisc = q->queues[prio];
> +			skb = qdisc->dequeue(qdisc);
> +			if (skb) {
> +				sch->q.qlen--;
> +				skb->priority = prio;
> +				return skb;
> +			}
> +		}
> +#else
>  		qdisc = q->queues[prio];
>  		skb = qdisc->dequeue(qdisc);
>  		if (skb) {
>  			sch->q.qlen--;
> +			skb->priority = prio;
>  			return skb;
>  		}
> +#endif
>  	}
>  	return NULL;
> -
>  }
>  
>  static unsigned int prio_drop(struct Qdisc* sch)
