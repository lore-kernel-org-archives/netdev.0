From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/2] NET: Multiple queue network device support
Date: Tue, 27 Feb 2007 11:38:36 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC329025C211F@orsmsx414.amr.corp.intel.com>
References: <20070226.170317.41636240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <jgarzik@pobox.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	<auke@foo-projects.org>, "Ronciak, John" <john.ronciak@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:29501 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933054AbXB0Tir convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 14:38:47 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20070226.170317.41636240.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,
	Thanks for the feedback.  Please see below for my comments /
questions.

PJ Waskiewicz
Intel Corporation

> > From: Peter Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > 
> > Added an API and associated supporting routines for 
> multiqueue network 
> > devices.  This allows network devices supporting multiple 
> TX queues to 
> > configure each queue within the netdevice and manage each queue 
> > independantly.  Changes to the PRIO Qdisc also allow a user to map 
> > multiple flows to individual TX queues, taking advantage of 
> each queue 
> > on the device.
> > 
> > Signed-off-by: Peter Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> 
> Thanks for posting this.
> 
> I was wonding if it would be better to have the ->enqueue() 
> perform the mapping operation, store the queue index selected 
> inside of the skb, and just use the normal 
> ->hard_start_xmit() to send the packet out?

One of the reasons I chose to add more functions is for the queue
management itself.  Specifically, I needed the ability to lock queues,
stop queues (netif_stop_queue), and wake them up, independent of the
global queue_lock in the netdevice.  At first I did think about storing
the queue index in the skb, but that won't help with the queue locking,
since only netdevice is passed to them outside of the context of the
skb.  As for adding the additional multiqueue version of
hard_start_subqueue_xmit(), I did that so non-MQ devices would have a
clean, untouched path in dev_queue_xmit(), and only MQ devices would
touch a new codepath.  This also removes the need for the device driver
to inspect the queue index in the skb for which Tx ring to place the
packet in, which is good for performance.

For having ->enqueue() take care of the mapping, I thought for awhile
about this.  Originally, I had ->enqueue() doing just that, until I
realized I was not locking the individual subqueues correctly.  The
thought process was once I receive an skb for Tx, I need to lock a
queue, enqueue the skb, call qdisc_run(), then unlock.  That grew into
lock a queue, enqueue, unlock the queue, have dequeue decide which queue
to pull an skb from (since the queue an skb comes from can be different
than the one just enqueued to), lock it, dequeue, unlock, and return the
skb.  The whole issue came down to needing to know what queue to lock
before enqueuing.  If I called enqueue, I would be going in unlocked.  I
suppose this would be ok if the lock is done inside the ->enqueue(), and
unlock is done before exiting; let me look at that possibility.

> 
> The only thing to take care of is the per-queue locking, but 
> that should be easily doable.
> 
> We might be able to do this even without making sk_buff any larger.
> For example, I suppose skb->priority might be deducable down 
> to a u16.  After a quick audit I really cannot see any 
> legitimate use of anything larger than 16-bit values, but a 
> more thorough audit would be necessary to validate this.

The skb->priority field right now is used to determine the PRIO /
pfifo_fast band to place the skb in on enqueue.  I still need to think
about if storing the queue index in the skb would help, due to the queue
management functions outside of the skb context.

Again, thanks for the feedback.  I'll respond once I've looked at moving
locks into ->enqueue() and removing ->map_queue().  Please note that the
PRIO band to queue mapping in this patch has a problem when the number
of bands is <= the number of Tx queues on the NIC.  I have a fix, and
will include that in a repost.
