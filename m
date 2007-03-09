From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/2] NET: Multiple queue network device support
Date: Fri, 9 Mar 2007 11:25:55 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC329026E9C45@orsmsx414.amr.corp.intel.com>
References: <20070309134037.GH521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	"Garzik, Jeff" <jgarzik@pobox.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Thomas Graf" <tgraf@suug.ch>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1767509AbXCIT0E@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20070309134037.GH521@postel.suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Thomas Graf [mailto:tgraf@suug.ch] 
> Sent: Friday, March 09, 2007 5:41 AM
> To: Kok, Auke-jan H
> Cc: David Miller; Garzik, Jeff; netdev@vger.kernel.org; 
> linux-kernel@vger.kernel.org; Waskiewicz Jr, Peter P; 
> Brandeburg, Jesse; Kok, Auke; Ronciak, John
> Subject: Re: [PATCH 1/2] NET: Multiple queue network device support
> 
> * Kok, Auke <auke-jan.h.kok@intel.com> 2007-02-08 16:09
> > diff --git a/net/core/dev.c b/net/core/dev.c index 455d589..42b635c 
> > 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -1477,6 +1477,49 @@ gso:
> >  	skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
> >  #endif
> >  	if (q->enqueue) {
> > +#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
> > +		int queue_index;
> > +		/* If we're a multi-queue device, get a queue 
> index to lock */
> > +		if (netif_is_multiqueue(dev))
> > +		{
> > +			/* Get the queue index and lock it. */
> > +			if (likely(q->ops->map_queue)) {
> > +				queue_index = q->ops->map_queue(skb, q);
> > +				
> spin_lock(&dev->egress_subqueue[queue_index].queue_lock);
> > +				rc = q->enqueue(skb, q);
> > +				/*
> > +				 * Unlock because the underlying qdisc
> > +				 * may queue and send a packet from a
> > +				 * different queue.
> > +				 */
> > +				
> spin_unlock(&dev->egress_subqueue[queue_index].queue_lock);
> > +				qdisc_run(dev);
> 
> I really dislike this asymmetric locking logic, while 
> enqueue() is called with queue_lock held dequeue() is 
> repsonsible to acquire the lock for qdisc_restart().

I don't see how I can make this symmetrical when dealing with more than
one queue.  If an skb is classified to band 2 which maps to queue 1, we
lock queue 1, and enqueue the packet.  That queue will not be the first
queue checked in dequeue for an skb, so I cannot rely on that lock
protecting queue 0 in dequeue.  Therefore I need to map the skb, lock,
enqueue, unlock, then go into dequeue and lock the correct queue there.
If I were to make this symmetrical, then the process of enqueuing and
dequeuing would be serialized completely, and we'd be back to where we
started without multiqueue.

Also, in the multiqueue code path, dev->queue_lock isn't held anywhere,
it's the subqueue lock.

> 
> > +				rc = rc == NET_XMIT_BYPASS
> > +				           ? NET_XMIT_SUCCESS : rc;
> > +				goto out;
> > +			} else {
> > +				printk(KERN_CRIT "Device %s is "
> > +					"multiqueue, but map_queue is "
> > +					"undefined in the qdisc!!\n",
> > +					dev->name);
> > +				kfree_skb(skb);
> 
> Move this check to tc_modify_qdisc(), it's useless to check 
> this for every packet being delivered.

The patches I sent yesterday modified the non-multiqueue qdiscs to not
load if the device is multiqueue, so this check can be removed
altogether.

> 
> > +			}
> > +		} else {
> > +			/* We're not a multi-queue device. */
> > +			spin_lock(&dev->queue_lock);
> > +			q = dev->qdisc;
> > +			if (q->enqueue) {
> > +				rc = q->enqueue(skb, q);
> > +				qdisc_run(dev);
> > +				spin_unlock(&dev->queue_lock);
> > +				rc = rc == NET_XMIT_BYPASS
> > +				           ? NET_XMIT_SUCCESS : rc;
> > +				goto out;
> > +			}
> > +			spin_unlock(&dev->queue_lock);
> 
> Please don't duplicate already existing code.

I don't want to mix multiqueue and non-multiqueue code in the transmit
path.  This was an attempt to allow MQ and non-MQ devices to coexist in
a machine having separate code paths.  Are you suggesting to combine
them?  That would get very messy trying to determine what type of lock
to grab (subqueue lock or dev->queue_lock), not to mention grabbing the
dev->queue_lock would block multiqueue devices in that same codepath.

> 
> > @@ -130,6 +140,72 @@ static inline int qdisc_restart(struct 
> net_device *dev)
> >  		}
> >  		
> >  		{
> > +#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
> > +			if (netif_is_multiqueue(dev)) {
> > +				if (likely(q->ops->map_queue)) {
> > +					queue_index = 
> q->ops->map_queue(skb, q);
> > +				} else {
> > +					printk(KERN_CRIT "Device %s is "
> > +						"multiqueue, 
> but map_queue is "
> > +						"undefined in 
> the qdisc!!\n",
> > +						dev->name);
> > +					goto requeue;
> > +				}
> 
> Yet another condition completely useless for every transmission.

Yep, this will be removed.  Thanks.

> 
> > +				
> spin_unlock(&dev->egress_subqueue[queue_index].queue_lock);
> > +				/* Check top level device, and 
> any sub-device */
> > +				if ((!netif_queue_stopped(dev)) &&
> > +				  (!netif_subqueue_stopped(dev, 
> queue_index))) {
> > +					int ret;
> > +					ret = 
> dev->hard_start_subqueue_xmit(skb, dev, queue_index);
> > +					if (ret == NETDEV_TX_OK) {
> > +						if (!nolock) {
> > +							
> netif_tx_unlock(dev);
> > +						}
> > +						return -1;
> > +					}
> > +					if (ret == 
> NETDEV_TX_LOCKED && nolock) {
> > +						
> spin_lock(&dev->egress_subqueue[queue_index].queue_lock);
> > +						goto collision;
> > +					}
> > +				}
> > +				/* NETDEV_TX_BUSY - we need to 
> requeue */
> > +				/* Release the driver */
> > +				if (!nolock) {
> > +					netif_tx_unlock(dev);
> > +				}
> > +				
> spin_lock(&dev->egress_subqueue[queue_index].queue_lock);
> > +				q = dev->qdisc;
> 
> This is identical to the existing logic except for the 
> different lock, the additional to check subqueue state and a 
> different hard_start_xmit call. Share the logic.

Not necessarily.  How we got here and how the locks are working are
logically different due to the different queues.  I'm working on storing
the queue index in the skb now from Dave's suggestion, so there will be
one hard_start_xmit, but the logic is different since the queue lock
we're grabbing will be different than non-multiqueue.  Perhaps I'm
missing something here.

> 
> > +			}
> > +			else
> > +			{
> > +				/* We're a single-queue device */
> > +				/* And release queue */
> > +				spin_unlock(&dev->queue_lock);
> > +				if (!netif_queue_stopped(dev)) {
> > +					int ret;
> > +
> > +					ret = 
> dev->hard_start_xmit(skb, dev);
> > +					if (ret == NETDEV_TX_OK) {
> > +						if (!nolock) {
> > +							
> netif_tx_unlock(dev);
> > +						}
> > +						
> spin_lock(&dev->queue_lock);
> > +						return -1;
> > +					}
> > +					if (ret == 
> NETDEV_TX_LOCKED && nolock) {
> > +						
> spin_lock(&dev->queue_lock);
> > +						goto collision;
> > +					}
> > +				}
> > +				/* NETDEV_TX_BUSY - we need to 
> requeue */
> > +				/* Release the driver */
> > +				if (!nolock) {
> > +					netif_tx_unlock(dev);
> > +				}
> > +				spin_lock(&dev->queue_lock);
> > +				q = dev->qdisc;
> 
> Again, you just copied the existing code into a separate 
> branch, fix the branching logic!

This is another attempt to keep the two codepaths separate.  The only
way I see of combining them is to check netif_is_multiqueue() everytime
I need to grab a lock, which I think would be excessive.

> 
> > @@ -356,10 +454,18 @@ static struct sk_buff 
> *pfifo_fast_dequeue(struct Qdisc* qdisc)
> >  	struct sk_buff_head *list = qdisc_priv(qdisc);
> >  
> >  	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++) {
> > +#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
> > +		if (netif_is_multiqueue(qdisc->dev))
> > +			
> spin_lock(&qdisc->dev->egress_subqueue[0].queue_lock);
> > +#endif
> >  		if (!skb_queue_empty(list + prio)) {
> >  			qdisc->q.qlen--;
> >  			return __qdisc_dequeue_head(qdisc, list + prio);
> >  		}
> > +#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
> > +		if (netif_is_multiqueue(qdisc->dev))
> > +			
> spin_unlock(&qdisc->dev->egress_subqueue[0].queue_lock);
> > +#endif
> 
> This lock/unlock for every band definitely screws performance.
> 

I will move the lock out of the for() loop since every band in
pfifo_fast maps to queue 0.  Thanks.

> >  	}
> >  
> >  	return NULL;
> > @@ -141,18 +174,53 @@ prio_dequeue(struct Qdisc* sch)
> >  	struct sk_buff *skb;
> >  	struct prio_sched_data *q = qdisc_priv(sch);
> >  	int prio;
> > +#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
> > +	int queue;
> > +#endif
> >  	struct Qdisc *qdisc;
> >  
> > +	/*
> > +	 * If we're multiqueue, the basic approach is try the 
> lock on each
> > +	 * queue.  If it's locked, either we're already 
> dequeuing, or enqueue
> > +	 * is doing something.  Go to the next band if we're 
> locked.  Once we
> > +	 * have a packet, unlock the queue.  NOTE: the 
> underlying qdisc CANNOT
> > +	 * be a PRIO qdisc, otherwise we will deadlock.  FIXME
> > +	 */
> >  	for (prio = 0; prio < q->bands; prio++) {
> > +#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
> > +		if (netif_is_multiqueue(sch->dev)) {
> > +			queue = q->band2queue[prio];
> > +			if 
> (spin_trylock(&sch->dev->egress_subqueue[queue].queue_lock)) {
> > +				qdisc = q->queues[prio];
> > +				skb = qdisc->dequeue(qdisc);
> > +				if (skb) {
> > +					sch->q.qlen--;
> > +					skb->priority = prio;
> > +					
> spin_unlock(&sch->dev->egress_subqueue[queue].queue_lock);
> > +					return skb;
> > +				}
> > +				
> spin_unlock(&sch->dev->egress_subqueue[queue].queue_lock);
> > +			}
> 
> Your modified qdisc_restart() expects the queue_lock to be 
> locked, how can this work?

No, it doesn't expect the lock to be held.  Because of the multiple
queues, enqueueing and dequeueing are now asynchronous, since I can
enqueue to queue 0 while dequeuing from queue 1.  dev->queue_lock isn't
held, so this can happen.  Therefore the spin_trylock() is used in this
dequeue because I don't want to wait for someone to finish with that
queue in question (e.g. enqueue working), since that will block all
other bands/queues after the band in question.  So if the lock isn't
available to grab, we move to the next band.  If I were to wait for the
lock, I'd serialize the enqueue/dequeue completely, and block other
traffic flows in other queues waiting for the lock.

> 
> > +		} else {
> > +			qdisc = q->queues[prio];
> > +			skb = qdisc->dequeue(qdisc);
> > +			if (skb) {
> > +				sch->q.qlen--;
> > +				skb->priority = prio;
> > +				return skb;
> > +			}
> > +		}
> > +#else
> >  		qdisc = q->queues[prio];
> >  		skb = qdisc->dequeue(qdisc);
> >  		if (skb) {
> >  			sch->q.qlen--;
> > +			skb->priority = prio;
> >  			return skb;
> >  		}
> > +#endif
> >  	}
> >  	return NULL;
> > -
> >  }
> >  
> >  static unsigned int prio_drop(struct Qdisc* sch)
> 
