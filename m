From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 4/6] net neighbour: convert to RCU
Date: Wed, 30 Aug 2006 01:17:22 +0400
Message-ID: <20060829211722.GA27855@ms2.inr.ac.ru>
References: <20060828230748.827712918@localhost.localdomain> <20060828230915.587544687@localhost.localdomain> <20060829152816.GA24283@ms2.inr.ac.ru> <20060829112204.0cf5e866@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:37303 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S965413AbWH2VRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 17:17:41 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060829112204.0cf5e866@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> atomic_inc_and_test is true iff result is zero, so that won't work.

I meant atomic_inc_not_zero(), as Martin noticed.


> But the following should work:
> 
> 	hlist_for_each_entry_rcu(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
> 		if (dev == n->dev && !memcmp(n->primary_key, pkey, key_len)) {
> 			if (unlikely(&atomic_inc_return(&n->refcnt) == 1)) {
> 				neigh_release(n);

I do not think it will work. It has exactly the same race condition.

Yes, atomic_inc_not_zero() is expensive. But it looks like it is the cheapest
variant, which works correctly without more work.

Another variant would be rework use of refcnt. It can be done like rt cache:
when release of the last reference does not mean anything.

Also, probably, it makes sense to add neigh_lookup_light(), which does
not take refcnt, but required to call
neigh_release_light() (which is just rcu_read_unlock_bh()).

Alexey
