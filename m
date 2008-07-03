From: David Miller <davem@davemloft.net>
Subject: [PATCH 00/39]: New multiqueue TX implementation.
Date: Thu, 03 Jul 2008 00:01:46 -0700 (PDT)
Message-ID: <20080703.000146.168093325.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47412
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756341AbYGCHBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:01:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm finally at the point where I can post a patch series that actually
does something and I know works for at least one card :-)

The backlog and batching bits are sidelined for the time being.
Don't worry, we'll get back to that soon enough :)

This can all be found in:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-tx-2.6.git

which uses net-next-2.6 as it's origin.

The summarized state is:

1) Everything in the transmit path is multiqueue aware.

2) Qdisc and classification is not.  We hook up default
   qdiscs to each TX queue when the device comes up,
   but the configuration infrastructure still hardcodes
   it's operations to TX queue zero.  This is a temporary
   situation.

3) I rewrote the mac80211 QoS support using the new
   netdev hook added for TX hashing.  I know it is broken
   and not as fully functional as the qdisc implementation.
   It can and will be fixed to match existing functionality.
   The broken parts are:

   a) It no longer does dropping.
   b) Requeueing is not implemented.

   Dropping is easy to add, and we need to investigate
   whether the requeueing is really even useful.

I have tested basic TCP stream functionality on the NIU
driver multiqueue support.  I verified that different
TCP streams end up on different TX queues.

I went through the existing multiqueue capable drivers and
made sure they use the new interfaces properly.  I anticipate
that they will largely still work properly.

For the qdisc/cls issues, I intend to simply use replication as a
first step.  So if a qdisc or classifier config change comes in,
we just replicate that change to all of the TX queues.  The biggest
pain in the butt will be rolling things back if the first few
queues succeed but then one fails.

The observant will note that egress and ingress qdisc handling is now
more consolidated than ever.  I expect many more simplications in this
area.

Some of these config changes make non-trivial things happen, so what I
might do is split qdisc/cls config into two passes.  The first pass
implements the allocation of resources (memory, etc.), the second
pass commits the changes and cannot fail.  So if anything in the
first pass fails, we simply release everything, cleanup, and return
an error.

Quick 'n dirty multiqueue driver port:

1) alloc_etherdev() --> alloc_etherdev_mq().  Specify the maximum
   number of TX queues that the device might be using.

2) Once you know how many TX queues will be in use, set
   netdev->real_num_tx_queues to that value.

   Do not modify this value when the device is up.  It may only be
   changed while the device is down.

3) In ->hard_start_xmit(), skb_get_queue_mapping() tells you which
   TX queue to use.  It will always be in the range 0 --> real_num_tx_queue

4) When operating on a specific TX queue, use netif_tx_{start,stop,wake}_queue()

5) When you want to operate on all queues (bringing the device down,
   bringing it up, resetting, changing some MAC configuration that
   requires full device quiesce) use netif_tx_{start,stop,wake}_all_queues().

And then you're done.  Really, it's as simply as that.  The final
patch in this series that implements TX multiqueue for NIU is a good
guide for other driver authors.

net/core/dev.c:simple_tx_hash() implements the current hashing
algorithm.  This is just to get things going, and will in the end be
augmented with a user-configurable algorithm selection.

There is a lot to clean up, fix up, and flesh out.  But at least
we're this far along.  More details are in the commit log messages.

You'll notice that a lot of it is just moving things around, making
interfaces work with queue objects instead of net devices, and
finally deciding at each spot "what does this operation mean in
a TX multiqueue setting?"
