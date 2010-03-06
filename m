From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Fri, 5 Mar 2010 21:06:56 -0800
Message-ID: <20100306050656.GA6812@linux.vnet.ibm.com>
References: <20100228054012.GA7583@gondor.apana.org.au> <E1NlbuT-00021C-0b@gondolin.me.apana.org.au> <20100305234327.GJ6764@linux.vnet.ibm.com> <20100306011718.GA12812@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:58050 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750783Ab0CFFG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Mar 2010 00:06:59 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o264uZTW010343
	for <netdev@vger.kernel.org>; Fri, 5 Mar 2010 23:56:35 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2656wwo176336
	for <netdev@vger.kernel.org>; Sat, 6 Mar 2010 00:06:58 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2656vfx031798
	for <netdev@vger.kernel.org>; Sat, 6 Mar 2010 00:06:57 -0500
Content-Disposition: inline
In-Reply-To: <20100306011718.GA12812@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 06, 2010 at 09:17:18AM +0800, Herbert Xu wrote:
> On Fri, Mar 05, 2010 at 03:43:27PM -0800, Paul E. McKenney wrote:
> > 
> > Cool!!!  You use a pair of list_head structures, so that a given
> > element can be in both the old and the new hash table simultaneously.
> > Of course, an RCU grace period must elapse between consecutive resizings.
> > Which appears to be addressed.
> 
> Thanks :) I will try to extend this to other existing hash tables
> where the number of updates can be limited like it is here.
> 
> > The teardown needs an rcu_barrier_bh() rather than the current
> > synchronize_rcu_bh(), please see below.
> 
> All the call_rcu_bh's are done under multicast_lock.  The first
> check taken after taking the multicast_lock is whether we've
> started the tear-down.  So where it currently calls synchronize()
> it should already be the case that no call_rcu_bh's are still
> running.

Agreed, but the callbacks registered by the call_rcu_bh() might run
at any time, possibly quite some time after the synchronize_rcu_bh()
completes.  For example, the last call_rcu_bh() might register on
one CPU, and the synchronize_rcu_bh() on another CPU.  Then there
is no guarantee that the call_rcu_bh()'s callback will execute before
the synchronize_rcu_bh() returns.

In contrast, rcu_barrier_bh() is guaranteed not to return until all
pending RCU-bh callbacks have executed.

> > Also, I don't see how the teardown code is preventing new readers from
> > finding the data structures before they are being passed to call_rcu_bh().
> > You can't safely start the RCU grace period until -after- all new readers
> > have been excluded.  (But I could easily be missing something here.)
> 
> I understand.  However, AFAICS whatever it is that we are destroying
> is taken off the reader's visible data structure before call_rcu_bh.
> Do you have a particular case in mind where this is not the case?

I might simply have missed the operation that removed reader
visibility, looking again...

Ah, I see it.  The "br->mdb = NULL" in br_multicast_stop() makes
it impossible for the readers to get to any of the data.  Right?

If so, my confusion, you are right, this one is OK.

> > The br_multicast_del_pg() looks to need rcu_read_lock_bh() and
> > rcu_read_unlock_bh() around its loop, if I understand the pointer-walking
> > scheme correctly.
> 
> Any function that modifies the data structure is done under the
> multicast_lock, including br_multicast_del_pg.

But spin_lock() does not take the place of rcu_read_lock_bh().
And so, in theory, the RCU-bh grace period could complete between
the time that br_multicast_del_pg() does its call_rcu_bh() and the
"*pp = p->next;" at the top of the next loop iteration.  If so,
then br_multicast_free_pg()'s kfree() will possibly have clobbered
"p->next".  Low probability, yes, but a long-running interrupt
could do the trick.

Or is there something I am missing that is preventing an RCU-bh
grace period from completing near the bottom of br_multicast_del_pg()'s
"for" loop?

> > Hmmm...  Where is the read-side code?  Wherever it is, it cannot safely
> > dereference the ->old pointer.
> 
> Right, the old pointer is merely there to limit rehashings to one
> per window.  So it isn't used by the read-side.

Good!

> The read-side is the data path (non-IGMP multicast packets).  The
> sole entry point is br_mdb_get().

Hmmm...  So the caller is responsible for rcu_read_lock_bh()?

Shouldn't the br_mdb_get() code path be using hlist_for_each_entry_rcu()
in __br_mdb_ip_get(), then?  Or is something else going on here?

							Thanx, Paul

> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
