From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Sat, 6 Mar 2010 19:11:52 -0800
Message-ID: <20100307031151.GA7546@linux.vnet.ibm.com>
References: <20100228054012.GA7583@gondor.apana.org.au> <E1NlbuT-00021C-0b@gondolin.me.apana.org.au> <20100305234327.GJ6764@linux.vnet.ibm.com> <20100306011718.GA12812@gondor.apana.org.au> <20100306050656.GA6812@linux.vnet.ibm.com> <20100306065655.GA14326@gondor.apana.org.au> <20100306151933.GD6812@linux.vnet.ibm.com> <20100306190000.GA24445@linux.vnet.ibm.com> <20100307024500.GA20126@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>, arnd@arndb.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:60949 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751587Ab0CGDLy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Mar 2010 22:11:54 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2731dKq022368
	for <netdev@vger.kernel.org>; Sat, 6 Mar 2010 22:01:39 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o273Brve167712
	for <netdev@vger.kernel.org>; Sat, 6 Mar 2010 22:11:53 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o273BqRR009747
	for <netdev@vger.kernel.org>; Sat, 6 Mar 2010 22:11:53 -0500
Content-Disposition: inline
In-Reply-To: <20100307024500.GA20126@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 07, 2010 at 10:45:00AM +0800, Herbert Xu wrote:
> On Sat, Mar 06, 2010 at 11:00:00AM -0800, Paul E. McKenney wrote:
> >
> > > Hmmm...  rcu_barrier() definitely does -not- imply rcu_barrier_bh(),
> > > because there are separate sets of callbacks whose execution can
> > > be throttled separately.  So, while you would expect RCU-bh grace
> > > periods to complete more quickly, if there was a large number of
> > > RCU-bh callbacks on a given CPU but very few RCU callbacks, it might
> > > well take longer for the RCU-bh callbacks to be invoked.
> > > 
> > > With TREE_PREEMPT_RCU, if there were no RCU readers but one long-running
> > > RCU-bh reader, then synchronize_rcu_bh() could return before
> > > synchronize_rcu() does.
> 
> OK, then we definitely do have some issues under net/ with respect
> to the two types of RCU usage.  As you can see, we use the RCU-BH
> variant on the read-side in various places, and call_rcu_bh on the
> write-side too, but we only ever use the non-BH version of the
> functions rcu_barrier and synchronize_rcu.
> 
> Now there is a possibility that the places where we use synchronize
> and rcu_barrier don't really care about the BH variant, but an
> audit wouldn't hurt.
> 
> > You really are talking about code like the following, correct?
> > 
> > 	rcu_read_lock();
> > 	p = rcu_dereference(global_p);
> > 	do_something_with(p);
> > 	rcu_read_unlock();
> > 
> > 	. . .
> > 
> > 	rcu_read_lock_bh();
> > 	p = rcu_dereference(global_p);
> > 	do_something_else_with(p);
> > 	rcu_read_unlock_bh();
> > 
> > 	. . . 
> > 
> > 	spin_lock(&my_lock);
> > 	p = global_p;
> > 	rcu_assign_pointer(global_p, NULL);
> > 	synchronize_rcu();  /* BUG -- also need synchronize_rcu_bh(). */
> > 	kfree(p);
> > 	spin_unlock(&my_lock);
> > 
> > In other words, different readers traversing the same data structure
> > under different flavors of RCU protection, but then using only one
> > flavor of RCU grace period during the update?
> 
> We usually don't use synchronize_rcu/rcu_barrier on the update side,
> but rather they are used in the tear-down process.
> 
> But otherwise yes this is exactly my concern.
> 
> Note that we may have a problem on the update side too if we used
> the wrong call_rcu variant, but it would require a thorough audit
> to reveal those.

OK, just re-checked your patch, and it looks OK.

Also adding Arnd to CC.

Arnd, would it be reasonable to extend your RCU-sparse changes to have
four different pointer namespaces, one for each flavor of RCU?  (RCU,
RCU-bh, RCU-sched, and SRCU)?  Always a fan of making the computer do
the auditing where reasonable.  ;-)

This could potentially catch the mismatched call_rcu()s, at least if the
rcu_head could be labeled.

Other thoughts?

							Thanx, Paul
