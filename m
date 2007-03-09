From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/2] NET: Multiple queue network device support
Date: Fri, 9 Mar 2007 15:27:53 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC329026E9F85@orsmsx414.amr.corp.intel.com>
References: <20070309230143.GI521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"David Miller" <davem@davemloft.net>,
	"Garzik, Jeff" <jgarzik@pobox.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:5205 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767642AbXCIX16 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 18:27:58 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20070309230143.GI521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> * Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> 
> 2007-03-09 11:25
> > > > +			}
> > > > +		} else {
> > > > +			/* We're not a multi-queue device. */
> > > > +			spin_lock(&dev->queue_lock);
> > > > +			q = dev->qdisc;
> > > > +			if (q->enqueue) {
> > > > +				rc = q->enqueue(skb, q);
> > > > +				qdisc_run(dev);
> > > > +				spin_unlock(&dev->queue_lock);
> > > > +				rc = rc == NET_XMIT_BYPASS
> > > > +				           ? 
> NET_XMIT_SUCCESS : rc;
> > > > +				goto out;
> > > > +			}
> > > > +			spin_unlock(&dev->queue_lock);
> > > 
> > > Please don't duplicate already existing code.
> > 
> > I don't want to mix multiqueue and non-multiqueue code in 
> the transmit 
> > path.  This was an attempt to allow MQ and non-MQ devices 
> to coexist 
> > in a machine having separate code paths.  Are you suggesting to 
> > combine them?  That would get very messy trying to 
> determine what type 
> > of lock to grab (subqueue lock or dev->queue_lock), not to mention 
> > grabbing the
> > dev->queue_lock would block multiqueue devices in that same 
> codepath.
> 
> The piece of code I quoted above is the branch executed if 
> multi queue is not enabled. The code you added is 100% 
> identical to the already existing enqueue logic. Just execute 
> the existing branch if multi queue is not enabled.
> 

I totally agree this is identical code if multiqueue isn't enabled.
However, when multiqueue is enabled, I don't want to make all network
drivers implement the subqueue API just to be able to lock the queues.
So the first thing I check is netif_is_multiqueue(dev), and if it
*isn't* multiqueue, it will run the existing code.  This way both
non-multiqueue devices don't have to have any knowledge of the MQ API.

> > This is another attempt to keep the two codepaths separate. 
>  The only 
> > way I see of combining them is to check netif_is_multiqueue() 
> > everytime I need to grab a lock, which I think would be excessive.
> 
> The code added is 100% identical to the existing code, just 
> be a little smarter on how you do the ifdefs.

An example could be an on-board adapter isn't multiqueue, and an
expansion card you have in your system is.  If I handle multiqueue being
on with just ifdef's, then I could use the expansion card, but not the
on-board adapter as-is.  The on-board driver would need to be updated to
have 1 queue in the multiqueue context, which is what I tried to avoid.

> > > Your modified qdisc_restart() expects the queue_lock to 
> be locked, 
> > > how can this work?
> > 
> > No, it doesn't expect the lock to be held.  Because of the multiple 
> > queues, enqueueing and dequeueing are now asynchronous, since I can 
> > enqueue to queue 0 while dequeuing from queue 1.  dev->queue_lock 
> > isn't held, so this can happen.  Therefore the 
> spin_trylock() is used 
> > in this dequeue because I don't want to wait for someone to finish 
> > with that queue in question (e.g. enqueue working), since that will 
> > block all other bands/queues after the band in question.  So if the 
> > lock isn't available to grab, we move to the next band.  If 
> I were to 
> > wait for the lock, I'd serialize the enqueue/dequeue 
> completely, and 
> > block other traffic flows in other queues waiting for the lock.
> 
> The first thing you do in qdisc_restart() after dequeue()ing 
> is unlock the sub queue lock. You explicitely unlock it 
> before calling qdisc_run() so I assume dequeue() is expected 
> to keep it locked. Something doesn't add up.

That's the entire point of this extra locking.  enqueue() is going to
put an skb into a band somewhere that maps to some queue, and there is
no way to guarantee the skb I retrieve from dequeue() is headed for the
same queue.  Therefore, I need to unlock the queue after I finish
enqueuing, since having that lock makes little sense to dequeue().
dequeue() will then grab *a* lock on a queue; it may be the same one we
had during enqueue(), but it may not be.  And the placement of the
unlock of that queue is exactly where it happens in non-multiqueue,
which is right before the hard_start_xmit().

I concede that the locking model is complex and seems really nasty, but
to truly separate queue functionality from one another, I see no other
feasible option than to run locking like this.  I am very open to
suggestions.

> 
> BTW, which lock serializes your write access to 
> qdisc->q.qlen? It used to be dev->queue_lock but that is 
> apparently not true for multi queue.
> 

This is a very good catch, because it isn't being protected on the
entire qdisc right now for PRIO.  However, Chris Leech pointed out the
LINK_STATE_QDISC_RUNNING bit is serializing things at the qdisc_run()
level, so that's probably protecting this counter right now.  I'm
looking at pushing that down into the qdisc, but at the same time I can
think of something to serialize these stats containers for the qdisc.
