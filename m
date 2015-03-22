From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 7/10] rhashtable: Disable automatic shrinking
Date: Sun, 22 Mar 2015 12:17:55 +0000
Message-ID: <20150322121755.GH1185@casper.infradead.org>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZard-0000wE-Se@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50259 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbbCVMR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 08:17:57 -0400
Content-Disposition: inline
In-Reply-To: <E1YZard-0000wE-Se@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/15 at 07:04pm, Herbert Xu wrote:
> Automatic shrinking is dangerous because it provides an easy
> way for an adversary to cause us to do unnecessary work.  Thus
> making the resizable hashtable a poor data structure.
> 
> This patch disables automatic shrinking but retains a manual
> shrink function for those cases where insertions and removals
> are overseen by a trusted entity, e.g., nft_hash.

This is misleading. I agree that unconditional shrinking is dangerous.
Shrinking was an optional feature disabled by default before. The
inlining enabled it by default for all users. What is the benefit of
requiring this logic outside of rhashtable over just adding a flag to
enable shrinking at 30% utilization?

> The shrink function will now also shrink to fit rather than halve
> the size of the table.

I like this part a lot

>  int rhashtable_shrink(struct rhashtable *ht)
>  {
> -	struct bucket_table *new_tbl, *old_tbl = rht_dereference(ht->tbl, ht);
> +	unsigned size = roundup_pow_of_two(atomic_read(&ht->nelems) * 4 / 3);

If rhashtable_shrink() is called near the 75% border it will cause an
immediate expansion again. Maybe make this * 3 / 2 so we shrink near
30% utilization as before?

> +	struct bucket_table *new_tbl;
> +	struct bucket_table *tbl;
> +	int err;
>  
> -	ASSERT_RHT_MUTEX(ht);
> +	if (size < ht->p.min_size)
> +		size = ht->p.min_size;

We should only shrink if size < old_tbl->size

> -	new_tbl = bucket_table_alloc(ht, old_tbl->size / 2);
> +	new_tbl = bucket_table_alloc(ht, size);
>  	if (new_tbl == NULL)
>  		return -ENOMEM;
