From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Sat, 6 Mar 2010 09:17:18 +0800
Message-ID: <20100306011718.GA12812@gondor.apana.org.au>
References: <20100228054012.GA7583@gondor.apana.org.au> <E1NlbuT-00021C-0b@gondolin.me.apana.org.au> <20100305234327.GJ6764@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40513 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751899Ab0CFBR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 20:17:26 -0500
Content-Disposition: inline
In-Reply-To: <20100305234327.GJ6764@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 05, 2010 at 03:43:27PM -0800, Paul E. McKenney wrote:
> 
> Cool!!!  You use a pair of list_head structures, so that a given
> element can be in both the old and the new hash table simultaneously.
> Of course, an RCU grace period must elapse between consecutive resizings.
> Which appears to be addressed.

Thanks :) I will try to extend this to other existing hash tables
where the number of updates can be limited like it is here.

> The teardown needs an rcu_barrier_bh() rather than the current
> synchronize_rcu_bh(), please see below.

All the call_rcu_bh's are done under multicast_lock.  The first
check taken after taking the multicast_lock is whether we've
started the tear-down.  So where it currently calls synchronize()
it should already be the case that no call_rcu_bh's are still
running.

> Also, I don't see how the teardown code is preventing new readers from
> finding the data structures before they are being passed to call_rcu_bh().
> You can't safely start the RCU grace period until -after- all new readers
> have been excluded.  (But I could easily be missing something here.)

I understand.  However, AFAICS whatever it is that we are destroying
is taken off the reader's visible data structure before call_rcu_bh.
Do you have a particular case in mind where this is not the case?

> The br_multicast_del_pg() looks to need rcu_read_lock_bh() and
> rcu_read_unlock_bh() around its loop, if I understand the pointer-walking
> scheme correctly.

Any function that modifies the data structure is done under the
multicast_lock, including br_multicast_del_pg.
 
> Hmmm...  Where is the read-side code?  Wherever it is, it cannot safely
> dereference the ->old pointer.

Right, the old pointer is merely there to limit rehashings to one
per window.  So it isn't used by the read-side.

The read-side is the data path (non-IGMP multicast packets).  The
sole entry point is br_mdb_get().

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
