From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH RFC] lib/rhashtable: allow users to set the minimum
 shifts of shrinking
Date: Wed, 27 Aug 2014 11:34:12 +0100
Message-ID: <20140827103412.GC13116@casper.infradead.org>
References: <1409129851-11630-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56188 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933556AbaH0KeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 06:34:15 -0400
Content-Disposition: inline
In-Reply-To: <1409129851-11630-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/14 at 04:57pm, Ying Xue wrote:
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index a2c7881..1466e2d 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -293,12 +293,15 @@ EXPORT_SYMBOL_GPL(rhashtable_expand);
>  int rhashtable_shrink(struct rhashtable *ht, gfp_t flags)
>  {
>  	struct bucket_table *ntbl, *tbl = rht_dereference(ht->tbl, ht);
> +	size_t min_shift = ilog2(HASH_MIN_SIZE);
>  	struct rhash_head __rcu **pprev;
>  	unsigned int i;
>  
>  	ASSERT_RHT_MUTEX(ht);
>  
> -	if (tbl->size <= HASH_MIN_SIZE)
> +	if (ht->p.min_shift)
> +		min_shift = max(ht->p.min_shift, min_shift);
> +	if (ht->shift <= min_shift)
>  		return 0;

I like it. Can you translate HASH_MIN_SIZE to .minshift in
rhashtable_init()? That way we only have to deal with .min_shift in
rhashtable_shrink().

Note that shrinking can also be disabled by not providing a
.shrink_decision function in rhashtable_params if the shrinking is
too expensive for your case.

> -static size_t rounded_hashtable_size(unsigned int nelem)
> +static size_t rounded_hashtable_size(struct rhashtable_params *params)
>  {
> -	return max(roundup_pow_of_two(nelem * 4 / 3), HASH_MIN_SIZE);
> +	size_t size = HASH_MIN_SIZE;
> +
> +	if (params->min_shift)
> +		size = max((1UL << params->min_shift), HASH_MIN_SIZE);
> +
> +	return max(roundup_pow_of_two(params->nelem_hint * 4 / 3), size);
>  }

Same here. If you merge the provided .min_shift with HASH_MIN_SIZE
in rhashtable_init() before calculating the size, the above logic
can be simplified a lot.
