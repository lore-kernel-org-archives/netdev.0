From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Tue, 12 Aug 2008 15:33:49 -0700
Message-ID: <20080812223349.GG6819@linux.vnet.ibm.com>
References: <20080810190458.GA7279@ami.dom.local> <20080811100126.GA6401@ff.dom.local> <20080811232657.GQ6762@linux.vnet.ibm.com> <20080812063622.GA5066@ff.dom.local> <20080812134224.GC6909@linux.vnet.ibm.com> <20080812180927.GA3180@ami.dom.local> <20080812201858.GD6819@linux.vnet.ibm.com> <20080812211521.GA3742@ami.dom.local>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, emil.s.tantilov@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:59929 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123AbYHLWdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 18:33:51 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7CMXorL015760
	for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 18:33:50 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7CMXoSY172856
	for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 16:33:50 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7CMXnRM007892
	for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 16:33:50 -0600
Content-Disposition: inline
In-Reply-To: <20080812211521.GA3742@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 11:15:21PM +0200, Jarek Poplawski wrote:
> On Tue, Aug 12, 2008 at 01:18:58PM -0700, Paul E. McKenney wrote:
> > On Tue, Aug 12, 2008 at 08:09:27PM +0200, Jarek Poplawski wrote:
> ...
> > > I understand this similarly (but I'm still trying to find out what's
> > > wrong with reading this again in a separate read-side section).
> > 
> > The usual problem with re-reading in a separate read-side critical section
> > is that someone might have removed/destroyed it in the meantime.
> > Consider the following example:
> > 
> > Task 0:
> > 
> > 	rcu_read_lock();
> > 	p = rcu_dereference(global_pointer);
> > 	if (p == NULL) {
> > 		rcu_read_unlock();
> > 		goto somewhere_else;
> > 	}
> > 	do_something_with(p);
> > 	rcu_read_unlock();
> > 
> > 	do_some_unrelated_stuff();
> > 
> > 	rcu_read_lock();
> > 	do_something_else_with(p);	/* BUG!!! */
> > 	rcu_read_unlock();
> > 
> > 	somewhere_else:
> > 
> > Task 1:
> > 
> > 	spin_lock(&mylock);
> > 	p = global_pointer;
> > 	global_pointer = NULL;
> > 	spin_unlock(&mylock);
> > 	synchronize_rcu();
> > 	kfree(p);
> > 
> > Suppose task 0 picks up the global_pointer just before task 1 NULLs it.
> > Then Task 1's synchronize_rcu() is within its rights to return as soon
> > as task 0 executes its first rcu_read_unlock().  This means that task
> > 1's kfree(p) might happen before task 0's do_something_else_with(p),
> > which could cause general death and destruction.
> 
> Of course, I've considered here only re-reading with a separate
> rcu_dereference(). BTW, in "our" code we can't have a NULL dereference:
> in the "worst" case it points to a noop_qdisc, which is a static
> structure with some basic callbacks used during deactivation.

OK, in that case you would not need the NULL check and goto, but
the example would remain the same otherwise.

> > > David gave some additional explanations (which BTW don't look to me
> > > like very "orthodox" RCU) in this thread:
> > > http://marc.info/?l=linux-netdev&m=121851847805942&w=2
> > 
> > It looks to me like Dave believes that there is in fact a problem:
> > http://marc.info/?l=linux-netdev&m=121851965707714&w=2
> > 
> > 	But if it gets postponed into ksoftirqd... the RCU will pass
> > 	too early.
> > 
> > 	I'm still thinking about how to fix this without avoiding RCU
> > 	and without adding new synchronization primitives.
> > 
> > The only change to Dave's comment that I would make is to his first
> > paragraph:
> > 
> > 	But if it gets postponed into ksoftirqd or if the kernel has
> > 	been built with CONFIG_PREEMPT_RCU... the RCU will pass too early.
> 
> As a matter of fact I wonder if it's 100% safe even without ksoftiqd
> or PREEMPT_RCU? Considering that such a softirq handler would be
> triggered after rcu_read_unlock_bh(), and maybe after some additional
> hard or soft irq handlers, isn't it possible some RCU reclaiming code
> running on another cpu could manage to start kfreeing in between?

Good point -- even if it were impossible in the current implementation,
RCU is certainly within its rights to do the kfreeing in between.  So
the code is at best an accident waiting to happen.

> > My thought would be to use a reference count as noted earlier, on the
> > grounds that postponing to softirq should be relatively rare.  But again
> > I really cannot claim to understand this code.
> > 
> > Or am I missing something here?
> 
> I don't think so. I guess David've considered this all too, but he
> probably wants to re-check for any possible optimizations.

Fair enough!

							Thanx, Paul
