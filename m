From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 18 Aug 2008 16:54:11 -0700 (PDT)
Message-ID: <20080818.165411.255925269.davem@davemloft.net>
References: <20080817.153218.178334822.davem@davemloft.net>
	<20080818201236.GA3366@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57227
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753832AbYHRXyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 19:54:11 -0400
In-Reply-To: <20080818201236.GA3366@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 18 Aug 2008 22:12:36 +0200

> David Miller wrote, On 08/18/2008 12:32 AM:
> > 1) Only under RTNL can qdisc roots change.
> > 
> > 2) Therefore, sch_tree_lock() and tcf_tree_lock() are fully valid
> >    and lock the entire qdisc tree state, if and only if used under
> >    RTNL lock.
> > 
> > 3) Before modifying a qdisc, we dev_deactivate(), which synchronizes
> >    with asynchronous TX/RX packet handling contexts.
> > 
> > 4) The qdisc root and all children are protected by the root qdiscs
> >    lock, which is taken when asynchonous contexts need to blocked
> >    while modifying some root or inner qdisc's state.
> > 
> > Yes, of course, if you apply a hammer and add a bit lock at the
> > top of all of this it will fix whatever bugs remain, but as you
> > know I don't think that's the solution.
> 
> I don't think it's true. What matters here is the qdisc lock. And
> within the qdisc's tree only one such lock can matter because current
> code doesn't use qdisc locks on lower levels. So we need to take this
> one top lock. But as we have seen in notify_and_destroy() or
> qdisc_watchdog() it's easy to do this wrong because you've always
> analyze the tree plus activated/deactivated state. My proposal is to
> simply have still this one lock but easy accessible at some well
> known place (actually, with an exception for builtin qdiscs).

It sounds good in theory, but you cannot make this place be netdev_queue,
because multiple netdev_queue objects can point to the same qdisc.

That's why the lock isn't in netdev_queue any more, there is no longer
a 1 to 1 relationship.

> Actually, after partly fixing this we have currently messed this up
> again. We can't destroy a qdisc without RCU or some other delayed
> method while we're holding a lock inside this - and this is a case
> of root qdiscs... It's quite simple too, but why we've missed this
> so easily?

Yep, and that's the lock debugging thing which is triggering now.
Likely what I'll do is simply reinstate RCU but only for the freeing
of the memory, nothing more.

This keeps everything doing destruction under RTNL as desired,
yet fixes the "we're holding lock that's being freed" problem.

> As mentioned there was also this tricky qdisc_watchdog (or other
> direct __netif_scheduling), but this is not all. Try to look at
> qdisc_create() and gen_new_estimator() call. It passes
> qdisc_root_lock(sch) somewhere. This is similar to qdisc_watchdog()
> problem, but are you really sure we always save the right spinlock
> here? I don't think so.

If RTNL is held, we must be saving the correct lock.

Root qdisc and other aspects of qdisc configuration cannot be changing
when RTNL is held.  That is why I put RTNL assertion in
qdisc_root_lock() as this is the only valid situation where it may be
used.

-------------------- sch_generic.h --------------------
static inline spinlock_t *qdisc_root_lock(struct Qdisc *qdisc)
{
	struct Qdisc *root = qdisc_root(qdisc);

	ASSERT_RTNL();
	return qdisc_lock(root);
}
