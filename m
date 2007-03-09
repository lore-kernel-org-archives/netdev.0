From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2] NET: Multiple queue network device support
Date: Sat, 10 Mar 2007 00:01:43 +0100
Message-ID: <20070309230143.GI521@postel.suug.ch>
References: <20070309134037.GH521@postel.suug.ch> <D5C1322C3E673F459512FB59E0DDC329026E9C45@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	David Miller <davem@davemloft.net>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:35375 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767606AbXCIXBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 18:01:23 -0500
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329026E9C45@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> 2007-03-09 11:25
> > > +			}
> > > +		} else {
> > > +			/* We're not a multi-queue device. */
> > > +			spin_lock(&dev->queue_lock);
> > > +			q = dev->qdisc;
> > > +			if (q->enqueue) {
> > > +				rc = q->enqueue(skb, q);
> > > +				qdisc_run(dev);
> > > +				spin_unlock(&dev->queue_lock);
> > > +				rc = rc == NET_XMIT_BYPASS
> > > +				           ? NET_XMIT_SUCCESS : rc;
> > > +				goto out;
> > > +			}
> > > +			spin_unlock(&dev->queue_lock);
> > 
> > Please don't duplicate already existing code.
> 
> I don't want to mix multiqueue and non-multiqueue code in the transmit
> path.  This was an attempt to allow MQ and non-MQ devices to coexist in
> a machine having separate code paths.  Are you suggesting to combine
> them?  That would get very messy trying to determine what type of lock
> to grab (subqueue lock or dev->queue_lock), not to mention grabbing the
> dev->queue_lock would block multiqueue devices in that same codepath.

The piece of code I quoted above is the branch executed if multi queue
is not enabled. The code you added is 100% identical to the already
existing enqueue logic. Just execute the existing branch if multi queue
is not enabled.

> This is another attempt to keep the two codepaths separate.  The only
> way I see of combining them is to check netif_is_multiqueue() everytime
> I need to grab a lock, which I think would be excessive.

The code added is 100% identical to the existing code, just be a little
smarter on how you do the ifdefs.

> > >  	}
> > >  
> > >  	return NULL;
> > > @@ -141,18 +174,53 @@ prio_dequeue(struct Qdisc* sch)
> > >  	struct sk_buff *skb;
> > >  	struct prio_sched_data *q = qdisc_priv(sch);
> > >  	int prio;
> > > +#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
> > > +	int queue;
> > > +#endif
> > >  	struct Qdisc *qdisc;
> > >  
> > > +	/*
> > > +	 * If we're multiqueue, the basic approach is try the 
> > lock on each
> > > +	 * queue.  If it's locked, either we're already 
> > dequeuing, or enqueue
> > > +	 * is doing something.  Go to the next band if we're 
> > locked.  Once we
> > > +	 * have a packet, unlock the queue.  NOTE: the 
> > underlying qdisc CANNOT
> > > +	 * be a PRIO qdisc, otherwise we will deadlock.  FIXME
> > > +	 */
> > >  	for (prio = 0; prio < q->bands; prio++) {
> > > +#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
> > > +		if (netif_is_multiqueue(sch->dev)) {
> > > +			queue = q->band2queue[prio];
> > > +			if 
> > (spin_trylock(&sch->dev->egress_subqueue[queue].queue_lock)) {
> > > +				qdisc = q->queues[prio];
> > > +				skb = qdisc->dequeue(qdisc);
> > > +				if (skb) {
> > > +					sch->q.qlen--;
> > > +					skb->priority = prio;
> > > +					
> > spin_unlock(&sch->dev->egress_subqueue[queue].queue_lock);
> > > +					return skb;
> > > +				}
> > > +				
> > spin_unlock(&sch->dev->egress_subqueue[queue].queue_lock);
> > > +			}
> > 
> > Your modified qdisc_restart() expects the queue_lock to be 
> > locked, how can this work?
> 
> No, it doesn't expect the lock to be held.  Because of the multiple
> queues, enqueueing and dequeueing are now asynchronous, since I can
> enqueue to queue 0 while dequeuing from queue 1.  dev->queue_lock isn't
> held, so this can happen.  Therefore the spin_trylock() is used in this
> dequeue because I don't want to wait for someone to finish with that
> queue in question (e.g. enqueue working), since that will block all
> other bands/queues after the band in question.  So if the lock isn't
> available to grab, we move to the next band.  If I were to wait for the
> lock, I'd serialize the enqueue/dequeue completely, and block other
> traffic flows in other queues waiting for the lock.

The first thing you do in qdisc_restart() after dequeue()ing is unlock
the sub queue lock. You explicitely unlock it before calling qdisc_run()
so I assume dequeue() is expected to keep it locked. Something doesn't
add up.

BTW, which lock serializes your write access to qdisc->q.qlen? It used
to be dev->queue_lock but that is apparently not true for multi queue.
