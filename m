From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] rhashtable: Add arbitrary rehash function
Date: Wed, 11 Mar 2015 09:01:57 +1100
Message-ID: <20150310220157.GA28974@gondor.apana.org.au>
References: <20150309222631.GA12221@gondor.apana.org.au>
 <E1YV69U-0003Dq-HS@gondolin.me.apana.org.au>
 <20150310181720.GB13155@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	josh@joshtriplett.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:37911 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753624AbbCJWCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 18:02:01 -0400
Content-Disposition: inline
In-Reply-To: <20150310181720.GB13155@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2015 at 06:17:20PM +0000, Thomas Graf wrote:
> 
> > +static void rhashtable_rehash(struct rhashtable *ht,
> > +			      struct bucket_table *new_tbl)
> >  {
> > -	ASSERT_BUCKET_LOCK(ht, new_tbl, new_hash);
> > +	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
> > +	unsigned old_hash;
> > +
> > +	get_random_bytes(&new_tbl->hash_rnd, sizeof(new_tbl->hash_rnd));
> > +
> > +	/* Make insertions go into the new, empty table right away. Deletions
> > +	 * and lookups will be attempted in both tables until we synchronize.
> > +	 * The synchronize_rcu() guarantees for the new table to be picked up
> > +	 * so no new additions go into the old table while we relink.
> > +	 */
> > +	rcu_assign_pointer(ht->future_tbl, new_tbl);
> 
> I think you need an rcu_synchronize() here. rhashtable_remove() must
> be guaranteed to either see tbl != old_tbl and thus consider both
> tables or the rehashing must be guaranteed to not start for an already
> started removal. 

You are right that there is a bug with respect to removal here.
But we don't need a complete synchronize.  I just need to move
the future_tbl read in rhashtable_remove so that it occurs after
__rhashtable_remove.

Because __rhashtable_remove would have already taken a spinlock
in the old table, this means that if future_tbl is not yet visible,
then the rehashing thread has yet to process that bucket (since it
takes every single bucket lock while processing) so the entry must
be visible there (if it exists).

BTW there is also a similar bug in rhashtable_lookup_compare_insert
which I will fix in the next update.

> > -static void __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
> > -				struct bucket_table *tbl,
> > -				const struct bucket_table *old_tbl, u32 hash)
> > +bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
> > +			 bool (*compare)(void *, void *), void *arg)
> 
> Why make this non-static? We already have rhashtable_lookup_compare_insert()
> exported.

Good catch.  Cut-n-paste error.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
