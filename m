From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [v1 PATCH 9/10] rhashtable: Allow GFP_ATOMIC bucket table
 allocation
Date: Mon, 23 Mar 2015 12:53:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB077F0@AcuExch.aculab.com>
References: <20150322075300.GA2441@gondor.apana.org.au>
 <E1YZahk-0000jW-Ry@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Herbert Xu' <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:51488 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbbCWMyw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 08:54:52 -0400
In-Reply-To: <E1YZahk-0000jW-Ry@gondolin.me.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu
> This patch adds the ability to allocate bucket table with GFP_ATOMIC
> instead of GFP_KERNEL.  This is needed when we perform an immediate
> rehash during insertion.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> 
>  lib/rhashtable.c |   24 ++++++++++++++----------
>  1 file changed, 14 insertions(+), 10 deletions(-)
> 
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index c284099..59078ed 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -58,7 +58,8 @@ EXPORT_SYMBOL_GPL(lockdep_rht_bucket_is_held);
>  #endif
> 
> 
> -static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl)
> +static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl,
> +			      gfp_t gfp)
>  {
>  	unsigned int i, size;
>  #if defined(CONFIG_PROVE_LOCKING)
> @@ -75,12 +76,13 @@ static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl)
> 
>  	if (sizeof(spinlock_t) != 0) {
>  #ifdef CONFIG_NUMA
> -		if (size * sizeof(spinlock_t) > PAGE_SIZE)
> +		if (size * sizeof(spinlock_t) > PAGE_SIZE &&
> +		    gfp == GFP_KERNEL)
>  			tbl->locks = vmalloc(size * sizeof(spinlock_t));
>  		else
>  #endif
>  		tbl->locks = kmalloc_array(size, sizeof(spinlock_t),
> -					   GFP_KERNEL);
> +					   gfp);
>  		if (!tbl->locks)
>  			return -ENOMEM;
>  		for (i = 0; i < size; i++)
...

If the lock array can't be allocated, then it is probably best to use
a lock array that is half the size rather than failing the expand.

I'm not sure your current version would allow the old lock array be used.

Does linux have any architectures where someone has decided to make a
spinlock consume an entire cache line rather than just a single word?
If so then the lock array can be gigantic.

Given the lock is only used for insert and delete, I'm also not at
all clear why you allocate 128 locks per cpu for very large tables.
With the locks in their own array I don't think there can be 'false
sharing', the worst than can happen is two cpus spinning on locks
in the same cache line.

It isn't as though the locks are likely to be held for any length
of time either.

	David
