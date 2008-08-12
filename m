From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Tue, 12 Aug 2008 13:18:58 -0700
Message-ID: <20080812201858.GD6819@linux.vnet.ibm.com>
References: <20080810190458.GA7279@ami.dom.local> <20080811100126.GA6401@ff.dom.local> <20080811232657.GQ6762@linux.vnet.ibm.com> <20080812063622.GA5066@ff.dom.local> <20080812134224.GC6909@linux.vnet.ibm.com> <20080812180927.GA3180@ami.dom.local>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, emil.s.tantilov@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:57088 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750857AbYHLUZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2008 16:25:30 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7CKRoES006481
	for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 16:27:50 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7CKP2Ql729282
	for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 16:25:03 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7CKOx6d030427
	for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 14:25:02 -0600
Content-Disposition: inline
In-Reply-To: <20080812180927.GA3180@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 08:09:27PM +0200, Jarek Poplawski wrote:
> On Tue, Aug 12, 2008 at 06:42:24AM -0700, Paul E. McKenney wrote:
> > On Tue, Aug 12, 2008 at 06:36:22AM +0000, Jarek Poplawski wrote:
> ...
> > > >From net/sched/sch_generic.c:
> > > 
> > > void __qdisc_run(struct Qdisc *q)
> > > {
> > >         unsigned long start_time = jiffies;
> > > 
> > >         while (qdisc_restart(q)) {
> > >                 /*
> > >                  * Postpone processing if
> > >                  * 1. another process needs the CPU;
> > >                  * 2. we've been doing it for too long.
> > >                  */
> > >                 if (need_resched() || jiffies != start_time) {
> > >                         __netif_schedule(q);
> > > 
> > > This function is run from dev_queue_xmit() (net/core/dev.c) under
> > > rcu_read_lock_bh(), and this "q" pointer is passed here for later use
> > > (reading) by softirq run net_tx_action(). Alas in net/ RCU primitives
> > > are probably omitted in a few places...
> > 
> > If I understand this code, one way to handle it would be to increment
> > q->refcnt before passing to netif_schedule(), then decrementing it
> > (within an RCU read-side critical section) in the softirq handler.
> > 
> > There are probably other ways to handle this as well.
> 
> I understand this similarly (but I'm still trying to find out what's
> wrong with reading this again in a separate read-side section).

The usual problem with re-reading in a separate read-side critical section
is that someone might have removed/destroyed it in the meantime.
Consider the following example:

Task 0:

	rcu_read_lock();
	p = rcu_dereference(global_pointer);
	if (p == NULL) {
		rcu_read_unlock();
		goto somewhere_else;
	}
	do_something_with(p);
	rcu_read_unlock();

	do_some_unrelated_stuff();

	rcu_read_lock();
	do_something_else_with(p);	/* BUG!!! */
	rcu_read_unlock();

	somewhere_else:

Task 1:

	spin_lock(&mylock);
	p = global_pointer;
	global_pointer = NULL;
	spin_unlock(&mylock);
	synchronize_rcu();
	kfree(p);

Suppose task 0 picks up the global_pointer just before task 1 NULLs it.
Then Task 1's synchronize_rcu() is within its rights to return as soon
as task 0 executes its first rcu_read_unlock().  This means that task
1's kfree(p) might happen before task 0's do_something_else_with(p),
which could cause general death and destruction.

> David gave some additional explanations (which BTW don't look to me
> like very "orthodox" RCU) in this thread:
> http://marc.info/?l=linux-netdev&m=121851847805942&w=2

It looks to me like Dave believes that there is in fact a problem:
http://marc.info/?l=linux-netdev&m=121851965707714&w=2

	But if it gets postponed into ksoftirqd... the RCU will pass
	too early.

	I'm still thinking about how to fix this without avoiding RCU
	and without adding new synchronization primitives.

The only change to Dave's comment that I would make is to his first
paragraph:

	But if it gets postponed into ksoftirqd or if the kernel has
	been built with CONFIG_PREEMPT_RCU... the RCU will pass too early.

My thought would be to use a reference count as noted earlier, on the
grounds that postponing to softirq should be relatively rare.  But again
I really cannot claim to understand this code.

Or am I missing something here?

							Thanx, Paul

> Thanks,
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
