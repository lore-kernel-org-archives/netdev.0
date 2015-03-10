From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/2] rhashtable: Add arbitrary rehash function
Date: Tue, 10 Mar 2015 18:17:20 +0000
Message-ID: <20150310181720.GB13155@casper.infradead.org>
References: <20150309222631.GA12221@gondor.apana.org.au>
 <E1YV69U-0003Dq-HS@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	josh@joshtriplett.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39676 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858AbbCJSRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 14:17:22 -0400
Content-Disposition: inline
In-Reply-To: <E1YV69U-0003Dq-HS@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/15 at 09:27am, Herbert Xu wrote:
> This patch adds a rehash function that supports the use of any
> hash function for the new table.  This is needed to support changing
> the random seed value during the lifetime of the hash table.
> 
> However for now the random seed value is still constant and the
> rehash function is simply used to replace the existing expand/shrink
> functions.
> 
> Signed-off-by: Herbert Xu <herbert.xu@redhat.com>

> +static int rhashtable_rehash_one(struct rhashtable *ht, unsigned old_hash)
> +	struct bucket_table *new_tbl = rht_dereference(ht->future_tbl, ht);
> +	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
> +	struct rhash_head __rcu **pprev = &old_tbl->buckets[old_hash];

[...]

I absolutely love the simplification this brings. Looks great. I now
also understand what you meant with entry for entry rehashing.

> +static void rhashtable_rehash(struct rhashtable *ht,
> +			      struct bucket_table *new_tbl)
>  {
> -	ASSERT_BUCKET_LOCK(ht, new_tbl, new_hash);
> +	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
> +	unsigned old_hash;
> +
> +	get_random_bytes(&new_tbl->hash_rnd, sizeof(new_tbl->hash_rnd));
> +
> +	/* Make insertions go into the new, empty table right away. Deletions
> +	 * and lookups will be attempted in both tables until we synchronize.
> +	 * The synchronize_rcu() guarantees for the new table to be picked up
> +	 * so no new additions go into the old table while we relink.
> +	 */
> +	rcu_assign_pointer(ht->future_tbl, new_tbl);

I think you need an rcu_synchronize() here. rhashtable_remove() must
be guaranteed to either see tbl != old_tbl and thus consider both
tables or the rehashing must be guaranteed to not start for an already
started removal. 

> -static void __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
> -				struct bucket_table *tbl,
> -				const struct bucket_table *old_tbl, u32 hash)
> +bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
> +			 bool (*compare)(void *, void *), void *arg)

Why make this non-static? We already have rhashtable_lookup_compare_insert()
exported.

> +bool __rhashtable_remove(struct rhashtable *ht, struct bucket_table *tbl,
> +			 struct rhash_head *obj)

Same here.
