From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: rhashtable: Move hash_rnd into bucket_table
Date: Mon, 09 Mar 2015 17:26:52 +0100
Message-ID: <54FDC9CC.6080709@iogearbox.net>
References: <20150131102150.GA29498@gondor.apana.org.au> <20150202.191956.404010205495035337.davem@davemloft.net> <20150202.192634.1792206005008667377.davem@davemloft.net> <20150203201750.GA22474@gondor.apana.org.au> <20150309095833.GA4028@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46828 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932416AbbCIQ1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 12:27:02 -0400
In-Reply-To: <20150309095833.GA4028@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/2015 10:58 AM, Herbert Xu wrote:
> Currently hash_rnd is a parameter that users can set.  However,
> no existing users set this parameter.  It is also something that
> people are unlikely to want to set directly since it's just a
> random number.

I believe the original purpose was to have reproduceability, but
yeah, there are no users of it currently.

> In preparation for allowing the reseeding/rehashing of rhashtable,
> this patch moves hash_rnd into bucket_table so that it's now an
> internal state rather than a parameter.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
> index d438eeb..5ef8ea5 100644
> --- a/include/linux/rhashtable.h
> +++ b/include/linux/rhashtable.h
> @@ -49,12 +49,14 @@ struct rhash_head {
>   /**
>    * struct bucket_table - Table of hash buckets
>    * @size: Number of hash buckets
> + * @hash_rnd: Random seed to fold into hash
>    * @locks_mask: Mask to apply before accessing locks[]
>    * @locks: Array of spinlocks protecting individual buckets
>    * @buckets: size * hash buckets
>    */
>   struct bucket_table {
>   	size_t			size;
> +	u32			hash_rnd;
>   	unsigned int		locks_mask;
>   	spinlock_t		*locks;
>
> @@ -72,7 +74,6 @@ struct rhashtable;
>    * @key_len: Length of key
>    * @key_offset: Offset of key in struct to be hashed
>    * @head_offset: Offset of rhash_head in struct to be hashed
> - * @hash_rnd: Seed to use while hashing
>    * @max_shift: Maximum number of shifts while expanding
>    * @min_shift: Minimum number of shifts while shrinking
>    * @nulls_base: Base value to generate nulls marker
> @@ -85,7 +86,6 @@ struct rhashtable_params {
>   	size_t			key_len;
>   	size_t			key_offset;
>   	size_t			head_offset;
> -	u32			hash_rnd;
>   	size_t			max_shift;
>   	size_t			min_shift;
>   	u32			nulls_base;
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index b5344ef..4ce267f 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -66,25 +66,28 @@ static u32 rht_bucket_index(const struct bucket_table *tbl, u32 hash)
>   	return hash & (tbl->size - 1);
>   }
>
> -static u32 obj_raw_hashfn(const struct rhashtable *ht, const void *ptr)
> +static u32 obj_raw_hashfn(struct rhashtable *ht, const void *ptr)
>   {
> +	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);

const

>   	u32 hash;
>
>   	if (unlikely(!ht->p.key_len))
> -		hash = ht->p.obj_hashfn(ptr, ht->p.hash_rnd);
> +		hash = ht->p.obj_hashfn(ptr, tbl->hash_rnd);
>   	else
>   		hash = ht->p.hashfn(ptr + ht->p.key_offset, ht->p.key_len,
> -				    ht->p.hash_rnd);
> +				    tbl->hash_rnd);
>
>   	return hash >> HASH_RESERVED_SPACE;
>   }
>
>   static u32 key_hashfn(struct rhashtable *ht, const void *key, u32 len)
>   {
> -	return ht->p.hashfn(key, len, ht->p.hash_rnd) >> HASH_RESERVED_SPACE;
> +	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
> +

const

> +	return ht->p.hashfn(key, len, tbl->hash_rnd) >> HASH_RESERVED_SPACE;
>   }
>
> -static u32 head_hashfn(const struct rhashtable *ht,
> +static u32 head_hashfn(struct rhashtable *ht,
>   		       const struct bucket_table *tbl,
>   		       const struct rhash_head *he)
>   {
> @@ -92,7 +95,7 @@ static u32 head_hashfn(const struct rhashtable *ht,
>   }
>
>   #ifdef CONFIG_PROVE_LOCKING
> -static void debug_dump_buckets(const struct rhashtable *ht,
> +static void debug_dump_buckets(struct rhashtable *ht,
>   			       const struct bucket_table *tbl)
>   {
>   	struct rhash_head *he;
> @@ -1099,14 +1102,13 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
>   	if (tbl == NULL)
>   		return -ENOMEM;
>
> +	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
> +

Have you tested this patch? ;-)

If I see this correctly, the first time you shrink or expand, your hash_rnd
from then onwards will constantly be 0.

You need to copy over the above old hash_rnd to the new one from the newly
allocated tbl. So, bucket_table_alloc() needs a change as well. Of course,
with rehashing, the get_random_bytes() would directly move there.

>   	atomic_set(&ht->nelems, 0);
>   	atomic_set(&ht->shift, ilog2(tbl->size));
>   	RCU_INIT_POINTER(ht->tbl, tbl);
>   	RCU_INIT_POINTER(ht->future_tbl, tbl);
>
> -	if (!ht->p.hash_rnd)
> -		get_random_bytes(&ht->p.hash_rnd, sizeof(ht->p.hash_rnd));
> -
>   	INIT_WORK(&ht->run_work, rht_deferred_worker);
>
>   	return 0;
>
