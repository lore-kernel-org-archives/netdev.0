From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/31]: Final set of TX multiqueue changes.
Date: Thu, 17 Jul 2008 05:15:26 -0700 (PDT)
Message-ID: <20080717.051526.193688049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51603
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755477AbYGQMP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 08:15:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'd like to first thank Patrick McHardy for pointing out the need for
shared qdisc handling, even though it meant that I had to essentially
toss out the 10,000 lines of code I wrote last weekend and start all
over again :-)

I'd also like to thank Johannes for help he has provided on the
wireless front.

Johannes, I did everything except move the wireless mac80211 requeue
work into a workqueue and then add the synchronize_net() call.  If you
could hack up that patch and test it I'd really appreciate it.

Next, I'd like to thank Eric Dumazet for his great feedback as well.
I still have to think about how I want to make the hash modulus
cheaper.

And finally I'd like to thank Jeff Kirsher for sending me the IGB
multiqueue patches.  He's the only person who sent me any driver work
for this new infrastructure.

With these changesets, a single qdisc shared as the root of several TX
queues is implemented.  It is all refreshed and present in:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-tx-2.6.git

which is a clone of current net-next-2.6 as usual.

The default qdisc has changed to one that is simple enough to not
require sharing.  It's a completely dumb fifo, and pfifo_fast is gone.
We can look at borrowing the sch_fifo.c code for this, but that would
require a few changes, for example we'd need to build it in even when
NET_SCHED is not set.

The locking is now completely refreshed.  This was the largest hurdle
in the new work of allowing shared qdiscs.  It basically comes down to
three things:

1) RCU is used more aggressively for qdisc destruction.  We can queue
   into a qdisc after qdisc_destroy() is called, up until the RCU
   handler is invoked.

   This allows us to relax several things tremendously.  It means that
   dev_queue->qdisc can be accessed purely with RCU locking and then
   we continue to use that sampled qdisc pointer as long as preemption
   is disabled (via BH's etc.) or when we have some other reason to
   know the qdisc isn't going away.

   As a result, and the intended main consequence, is that the we are
   divorced from having to spinlock in order to synchronize with root
   qdisc changes in the packet processing paths.

2) qdisc_lock_tree() and all of that crap is now gone.

   Instead, we lock qdisc roots of the tree we wish to operate on.

   Someone anticipated this kind of change, which is why we had these
   sch_tree_lock and tbf_tree_lock macros already.  This allowed these
   changes to be smaller than they otherwise would have been.

3) We schedule qdiscs, not netdev_queues.  So when a TX queue wakes
   up, we signal it's attached qdisc.  The qdisc we sample is used
   consistently all the way down into qdisc_restart() so all of that
   "resample the qdisc after grabbing lock" code is no longer
   necessary.

Initially all TX queues get the simple FIFO qdisc.

But once any qdisc root change operation is performed, we use one
shared qdisc amongst the queues until the root qdisc is deleted, at
which point we go back to the default.

Note that this new setup means that we can add funky things like have
qdiscs, classifiers, meta match, and tc actions that modify the SKB TX
queue mapping.

Unless I hear a huge objection, I intend to pull this work into
net-next-2.6 tomorrow so I can toss it all to Linus this coming
Sunday.
