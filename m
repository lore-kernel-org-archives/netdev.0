From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 4/6] net neighbour: convert to RCU
Date: Tue, 29 Aug 2006 14:46:08 -0700
Message-ID: <20060829144608.012f0d60@dxpl.pdx.osdl.net>
References: <20060828230748.827712918@localhost.localdomain>
	<20060828230915.587544687@localhost.localdomain>
	<20060829152816.GA24283@ms2.inr.ac.ru>
	<20060829112204.0cf5e866@localhost.localdomain>
	<20060829211722.GA27855@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63975 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965429AbWH2Vqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 17:46:39 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060829211722.GA27855@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Aug 2006 01:17:22 +0400
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

> Hello!
> 
> > atomic_inc_and_test is true iff result is zero, so that won't work.
> 
> I meant atomic_inc_not_zero(), as Martin noticed.
> 
> 
> > But the following should work:
> > 
> > 	hlist_for_each_entry_rcu(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
> > 		if (dev == n->dev && !memcmp(n->primary_key, pkey, key_len)) {
> > 			if (unlikely(&atomic_inc_return(&n->refcnt) == 1)) {
> > 				neigh_release(n);
> 
> I do not think it will work. It has exactly the same race condition.
> 
> Yes, atomic_inc_not_zero() is expensive. But it looks like it is the cheapest
> variant, which works correctly without more work.
> 
> Another variant would be rework use of refcnt. It can be done like rt cache:
> when release of the last reference does not mean anything.
> 
> Also, probably, it makes sense to add neigh_lookup_light(), which does
> not take refcnt, but required to call
> neigh_release_light() (which is just rcu_read_unlock_bh()).

Which code paths would that make sense on?
	fib_detect_death (ok)
	infiniband (ok)
	wireless/strip (ok) -- hey, this code is crap it has
		a refcount leak already!
	arp_req_get (ok)
	ndisc (ok)

Perhaps killing the refcount all together, and just changing
everybody to neigh_lookup_rcu(). Nobody holds a long term reference
to the entries.

> 
> Alexey

Or using the existing dead flag?

@@ -346,17 +359,24 @@ struct neighbour *neigh_lookup(struct ne
 	
 	NEIGH_CACHE_STAT_INC(tbl, lookups);
 
-	read_lock_bh(&tbl->lock);
-	hlist_for_each_entry(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
 		if (dev == n->dev && !memcmp(n->primary_key, pkey, key_len)) {
 			neigh_hold(n);
+			/* Don't rescuitate dead entries */
+			if (unlikely(n->dead)) {
+				neigh_release(n);
+				continue;
+			}
+
 			NEIGH_CACHE_STAT_INC(tbl, hits);
 			goto found;
 		}
 	}
 	n = NULL;
 found:
-	read_unlock_bh(&tbl->lock);
+	rcu_read_unlock();
 	return n;
 }
 
