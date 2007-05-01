From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Tue, 1 May 2007 16:04:50 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902C3DC46@orsmsx414.amr.corp.intel.com>
References: <1178057518.4078.41.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>, <jgarzik@pobox.com>,
	"cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	<davem@davemloft.net>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:57607 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754794AbXEAXEw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 19:04:52 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1178057518.4078.41.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > If that queue is stopped, the qdisc will never get called to run and
> > ->dequeue(), and hard_start_xmit() will never be called. 
> 
> yes, that is true (and the desired intent)

That intent is not what we want with our approach.  The desired intent
is to have independent network flows from the kernel, through the qdisc
layer, into the NIC, and onto the wire.  No flow should have the ability
to interfere with another flow's operation unless the device itself
shuts down, or a link-based flow control event occurs.  I see little to
no benefit of enabling multiqueue in a driver when all you'll get is
essentially one pipe of traffic, since the granularity of the management
of those queues is rough to the kernel.  I guess this is the source of
our differing views.

> The kernel is already multiqueue capable. Thats what qdiscs do.

The kernel is multiqueue capable to enqueue in software.  It is not
multiqueue capable when dequeuing to a NIC with multiple queues.  They
dequeue based on dev->state, which is single-threaded.  These patches
are the glue to make the multiple queues in software hook to the
multiple queues in the driver directly.

> Heres what i see the differences to be:
> 
> 1) You want to change the core code; i dont see a need for that.
> The packet is received by the driver and netif stop works as 
> before, with zero changes; the driver shuts down on the first 
> ring full.
> The only work is mostly driver specific.

To me, this doesn't buy you anything to do multiqueue only in the
driver.  I agree the driver needs work to manage the queues in the
hardware, but if a single feeder from the kernel is handing it packets,
you gain nothing in my opinion without granularity of stopping/starting
each queue in the kernel.

> 2) You want to change qdiscs to make them multi-queue specific.
> I only see a need for adding missing schedulers (if they are 
> missing) and not having some that work with multiqueues and 
> other that dont.
> The assumption is that you have mappings between qdisc and hw-rings.

The changes to PRIO are an initial example of getting my multiqueue
approach working.  This is the only qdisc I see being a logical change
for multiqueue; other qdiscs can certainly be added in the future, which
I plan on once multiqueue device support is in the kernel in some form.

> 3) For me: It is a driver change mostly. A new qdisc may be 
> needed - but thats about it. 

I guess this is a fundamental difference in our thinking.  I think of
multiqueue as the multiple paths out of the kernel, being managed by
per-queue states.  If that is the case, the core code has to be changed
at some level, specifically in dev_queue_xmit(), so it can check the
state of the subqueue your skb has been associated with
(skb->queue_mapping in my patchset).  The qdisc needs to comprehend how
to classify the skb (using TOS or TC) and assign the queue on the NIC to
transmit on.

My question to you is this: can you explain the benefit of not allowing
the kernel to know of and be able to manage the queues on the NIC?  This
seems to be the heart of our disagreement; I view the ability to manage
these queues from the kernel as being true multiqueue, and view doing
the queue management solely in the driver as something that doesn't give
any benefit.

> 4) You counter-argue that theres no need for QoS at the qdisc 
> if the hardware does it; i am counter-counter-arguing if you 
> need to write a new scheduler, it will benefit the other 
> single-hwqueue devices.

Not sure I completely understand this, but this an external argument to
the core discussion; let's leave this until we can agree on the actual
multiqueue network device support implementation.

> These emails are getting too long - typically people loose 
> interest sooner. In your response, can you perhaps restrict 
> it to just that last part and add anything you deem important?

Yes, long emails are bad.  I appreciate your efforts to come up to speed
on what we've done here, and offering your viewpoints.  Hopefully we can
come to an agreement of some sort soon, since this work has been going
on for some time to be halted after quite a bit of engineering and
community feedback.

Thanks Jamal,

-PJ Waskiewicz
