From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 4/6] net neighbour: convert to RCU
Date: Tue, 29 Aug 2006 11:22:04 -0700
Message-ID: <20060829112204.0cf5e866@localhost.localdomain>
References: <20060828230748.827712918@localhost.localdomain>
	<20060828230915.587544687@localhost.localdomain>
	<20060829152816.GA24283@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:58795 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965020AbWH2SXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 14:23:16 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060829152816.GA24283@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Aug 2006 19:28:16 +0400
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

> Hello!
> 
> > @@ -346,8 +354,8 @@ struct neighbour *neigh_lookup(struct ne
> >  	
> >  	NEIGH_CACHE_STAT_INC(tbl, lookups);
> >  
> > -	read_lock_bh(&tbl->lock);
> > -	hlist_for_each_entry(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
> > +	rcu_read_lock();
> > +	hlist_for_each_entry_rcu(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
> >  		if (dev == n->dev && !memcmp(n->primary_key, pkey, key_len)) {
> >  			neigh_hold(n);
> >  			NEIGH_CACHE_STAT_INC(tbl, hits);
> 
> Sure? Seems, you cannot grab refcnt here, the entry can be already
> released.
> 
> Probably, you should do atomic_inc_and_test() here and restart lookup,
> if it fails.
> 
> Alexey

atomic_inc_and_test is true iff result is zero, so that won't work.
But the following should work:

	hlist_for_each_entry_rcu(n, tmp, &tbl->hash_buckets[hash_val], hlist) {
		if (dev == n->dev && !memcmp(n->primary_key, pkey, key_len)) {
			if (unlikely(&atomic_inc_return(&n->refcnt) == 1)) {
				neigh_release(n);
				continue;
			}
 			NEIGH_CACHE_STAT_INC(tbl, hits);

I'll wrap the atomic_inc_return inside neigh_hold_return()


-- 
Stephen Hemminger <shemminger@osdl.org>
