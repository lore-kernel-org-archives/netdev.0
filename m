From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Sat, 6 Mar 2010 14:56:55 +0800
Message-ID: <20100306065655.GA14326@gondor.apana.org.au>
References: <20100228054012.GA7583@gondor.apana.org.au> <E1NlbuT-00021C-0b@gondolin.me.apana.org.au> <20100305234327.GJ6764@linux.vnet.ibm.com> <20100306011718.GA12812@gondor.apana.org.au> <20100306050656.GA6812@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42841 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751199Ab0CFG5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Mar 2010 01:57:06 -0500
Content-Disposition: inline
In-Reply-To: <20100306050656.GA6812@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 05, 2010 at 09:06:56PM -0800, Paul E. McKenney wrote:
> 
> Agreed, but the callbacks registered by the call_rcu_bh() might run
> at any time, possibly quite some time after the synchronize_rcu_bh()
> completes.  For example, the last call_rcu_bh() might register on
> one CPU, and the synchronize_rcu_bh() on another CPU.  Then there
> is no guarantee that the call_rcu_bh()'s callback will execute before
> the synchronize_rcu_bh() returns.
> 
> In contrast, rcu_barrier_bh() is guaranteed not to return until all
> pending RCU-bh callbacks have executed.

You're absolutely right.  I'll send a patch to fix this.

Incidentally, does rcu_barrier imply rcu_barrier_bh? What about
synchronize_rcu and synchronize_rcu_bh? The reason I'm asking is
that we use a mixture of rcu_read_lock_bh and rcu_read_lock all
over the place but only ever use rcu_barrier and synchronize_rcu.

> > I understand.  However, AFAICS whatever it is that we are destroying
> > is taken off the reader's visible data structure before call_rcu_bh.
> > Do you have a particular case in mind where this is not the case?
> 
> I might simply have missed the operation that removed reader
> visibility, looking again...
> 
> Ah, I see it.  The "br->mdb = NULL" in br_multicast_stop() makes
> it impossible for the readers to get to any of the data.  Right?

Yes.  The read-side will see it and get nothing, while all write-side
paths will see that netif_running is false and exit.

> > > The br_multicast_del_pg() looks to need rcu_read_lock_bh() and
> > > rcu_read_unlock_bh() around its loop, if I understand the pointer-walking
> > > scheme correctly.
> > 
> > Any function that modifies the data structure is done under the
> > multicast_lock, including br_multicast_del_pg.
> 
> But spin_lock() does not take the place of rcu_read_lock_bh().
> And so, in theory, the RCU-bh grace period could complete between
> the time that br_multicast_del_pg() does its call_rcu_bh() and the
> "*pp = p->next;" at the top of the next loop iteration.  If so,
> then br_multicast_free_pg()'s kfree() will possibly have clobbered
> "p->next".  Low probability, yes, but a long-running interrupt
> could do the trick.
> 
> Or is there something I am missing that is preventing an RCU-bh
> grace period from completing near the bottom of br_multicast_del_pg()'s
> "for" loop?

Well all the locks are taken with BH disabled, this should prevent
this problem, no?

> > The read-side is the data path (non-IGMP multicast packets).  The
> > sole entry point is br_mdb_get().
> 
> Hmmm...  So the caller is responsible for rcu_read_lock_bh()?

Yes, all data paths through the bridge operate with BH disabled.

> Shouldn't the br_mdb_get() code path be using hlist_for_each_entry_rcu()
> in __br_mdb_ip_get(), then?  Or is something else going on here?

Indeed it should, I'll fix this up too.

Thanks for reviewing Paul!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
