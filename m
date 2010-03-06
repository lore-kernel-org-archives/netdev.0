From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Sat, 6 Mar 2010 07:19:34 -0800
Message-ID: <20100306151933.GD6812@linux.vnet.ibm.com>
References: <20100228054012.GA7583@gondor.apana.org.au> <E1NlbuT-00021C-0b@gondolin.me.apana.org.au> <20100305234327.GJ6764@linux.vnet.ibm.com> <20100306011718.GA12812@gondor.apana.org.au> <20100306050656.GA6812@linux.vnet.ibm.com> <20100306065655.GA14326@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:45406 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751473Ab0CFPTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Mar 2010 10:19:35 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o26F8e8n025124
	for <netdev@vger.kernel.org>; Sat, 6 Mar 2010 10:08:40 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o26FJX0E056564
	for <netdev@vger.kernel.org>; Sat, 6 Mar 2010 10:19:33 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o26FJXUp020197
	for <netdev@vger.kernel.org>; Sat, 6 Mar 2010 10:19:33 -0500
Content-Disposition: inline
In-Reply-To: <20100306065655.GA14326@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 06, 2010 at 02:56:55PM +0800, Herbert Xu wrote:
> On Fri, Mar 05, 2010 at 09:06:56PM -0800, Paul E. McKenney wrote:
> > 
> > Agreed, but the callbacks registered by the call_rcu_bh() might run
> > at any time, possibly quite some time after the synchronize_rcu_bh()
> > completes.  For example, the last call_rcu_bh() might register on
> > one CPU, and the synchronize_rcu_bh() on another CPU.  Then there
> > is no guarantee that the call_rcu_bh()'s callback will execute before
> > the synchronize_rcu_bh() returns.
> > 
> > In contrast, rcu_barrier_bh() is guaranteed not to return until all
> > pending RCU-bh callbacks have executed.
> 
> You're absolutely right.  I'll send a patch to fix this.
> 
> Incidentally, does rcu_barrier imply rcu_barrier_bh? What about
> synchronize_rcu and synchronize_rcu_bh? The reason I'm asking is
> that we use a mixture of rcu_read_lock_bh and rcu_read_lock all
> over the place but only ever use rcu_barrier and synchronize_rcu.

Hmmm...  rcu_barrier() definitely does -not- imply rcu_barrier_bh(),
because there are separate sets of callbacks whose execution can
be throttled separately.  So, while you would expect RCU-bh grace
periods to complete more quickly, if there was a large number of
RCU-bh callbacks on a given CPU but very few RCU callbacks, it might
well take longer for the RCU-bh callbacks to be invoked.

With TREE_PREEMPT_RCU, if there were no RCU readers but one long-running
RCU-bh reader, then synchronize_rcu_bh() could return before
synchronize_rcu() does.

The simple approach would be to do something like:

	synchronize_rcu();
	synchronize_rcu_bh();

on the one hand, and:

	rcu_barrier();
	rcu_barrier_bh();

on the other.  However, this is not so good for update-side latency.

Perhaps we need a primitive that waits for both RCU and RCU-bh in
parallel?  This is pretty easy for synchronize_rcu() and
synchronize_rcu_bh(), and probably not too hard for rcu_barrier()
and rcu_barrier_bh().

Hmmm...  Do we have the same issue with call_rcu() and call_rcu_bh()?

						Thanx, Paul

> > > I understand.  However, AFAICS whatever it is that we are destroying
> > > is taken off the reader's visible data structure before call_rcu_bh.
> > > Do you have a particular case in mind where this is not the case?
> > 
> > I might simply have missed the operation that removed reader
> > visibility, looking again...
> > 
> > Ah, I see it.  The "br->mdb = NULL" in br_multicast_stop() makes
> > it impossible for the readers to get to any of the data.  Right?
> 
> Yes.  The read-side will see it and get nothing, while all write-side
> paths will see that netif_running is false and exit.
> 
> > > > The br_multicast_del_pg() looks to need rcu_read_lock_bh() and
> > > > rcu_read_unlock_bh() around its loop, if I understand the pointer-walking
> > > > scheme correctly.
> > > 
> > > Any function that modifies the data structure is done under the
> > > multicast_lock, including br_multicast_del_pg.
> > 
> > But spin_lock() does not take the place of rcu_read_lock_bh().
> > And so, in theory, the RCU-bh grace period could complete between
> > the time that br_multicast_del_pg() does its call_rcu_bh() and the
> > "*pp = p->next;" at the top of the next loop iteration.  If so,
> > then br_multicast_free_pg()'s kfree() will possibly have clobbered
> > "p->next".  Low probability, yes, but a long-running interrupt
> > could do the trick.
> > 
> > Or is there something I am missing that is preventing an RCU-bh
> > grace period from completing near the bottom of br_multicast_del_pg()'s
> > "for" loop?
> 
> Well all the locks are taken with BH disabled, this should prevent
> this problem, no?
> 
> > > The read-side is the data path (non-IGMP multicast packets).  The
> > > sole entry point is br_mdb_get().
> > 
> > Hmmm...  So the caller is responsible for rcu_read_lock_bh()?
> 
> Yes, all data paths through the bridge operate with BH disabled.
> 
> > Shouldn't the br_mdb_get() code path be using hlist_for_each_entry_rcu()
> > in __br_mdb_ip_get(), then?  Or is something else going on here?
> 
> Indeed it should, I'll fix this up too.
> 
> Thanks for reviewing Paul!
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
