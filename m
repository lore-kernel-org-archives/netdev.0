From: Florian Westphal <fw@strlen.de>
Subject: Re: rhashtable - Cap total number of entries to 2^31
Date: Thu, 27 Apr 2017 12:11:34 +0200
Message-ID: <20170427101134.GB448@breakpoint.cc>
References: <20170425112356.GB11322@breakpoint.cc>
 <20170425132837.GA25657@gondor.apana.org.au>
 <20170425141749.GD11322@breakpoint.cc>
 <20170425.104822.1395000926293799711.davem@davemloft.net>
 <20170427054451.GA529@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
        netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:58836 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753996AbdD0KLq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 06:11:46 -0400
Content-Disposition: inline
In-Reply-To: <20170427054451.GA529@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Tue, Apr 25, 2017 at 10:48:22AM -0400, David Miller wrote:
> > From: Florian Westphal <fw@strlen.de>
> > Date: Tue, 25 Apr 2017 16:17:49 +0200
> > 
> > > I'd have less of an issue with this if we'd be talking about
> > > something computationally expensive, but this is about storing
> > > an extra value inside a struct just to avoid one "shr" in insert path...
> > 
> > Agreed, this shift is probably filling an available cpu cycle :-)
> 
> OK, but we need to have an extra field for another reason anyway.
> The problem is that we're not capping the total number of elements
> in the hashtable when max_size is not set, this means that nelems
> can overflow which will cause havoc with the automatic shrinking
> when it tries to fit 2^32 entries into a minimum-sized table.

Right, good catch.

I guess eventually we should get rid of min_size and max_size
completely as parameters and keep actual sizing/bucket count internal to
rhashtable.

In fact I would not be surprised if some existing users did set
max_size under assumption it is a 'max element count'.

> ---8<---
> When max_size is not set or if it set to a sufficiently large
> value, the nelems counter can overflow.  This would cause havoc
> with the automatic shrinking as it would then attempt to fit a
> huge number of entries into a tiny hash table.
> 
> This patch fixes this by adding max_elems to struct rhashtable
> to cap the number of elements.  This is set to 2^31 as nelems is
> not a precise count.  This is sufficiently smaller than UINT_MAX
> that it should be safe.
> 
> When max_size is set max_elems will be lowered to at most twice
> max_size as is the status quo.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

[..]

> diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
> @@ -165,6 +166,7 @@ struct rhashtable {
>  	atomic_t			nelems;
>  	unsigned int			key_len;
>  	struct rhashtable_params	p;
> +	unsigned int			max_elems;
>  	bool				rhlist;
>  	struct work_struct		run_work;
>  	struct mutex                    mutex;
> @@ -327,8 +329,7 @@ static inline bool rht_grow_above_100(const struct rhashtable *ht,
>  static inline bool rht_grow_above_max(const struct rhashtable *ht,
>  				      const struct bucket_table *tbl)
>  {
> -	return ht->p.max_size &&
> -	       (atomic_read(&ht->nelems) / 2u) >= ht->p.max_size;
> +	return atomic_read(&ht->nelems) >= ht->max_elems;
>  }
>  
>  /* The bucket lock is selected based on the hash and protects mutations
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index f3b82e0..751630b 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -961,6 +961,11 @@ int rhashtable_init(struct rhashtable *ht,
>  	if (params->max_size)
>  		ht->p.max_size = rounddown_pow_of_two(params->max_size);
>  
> +	/* Cap total entries at 2^31 to avoid nelems overflow. */
> +	ht->max_elems = 1u << 31;
> +	if (ht->p.max_size < ht->max_elems / 2)
> +		ht->max_elems = ht->p.max_size * 2;
> +

Looks like instead of adding this max_elems you could instead have fixed this via

if (!ht->p.max_size)
	ht->p.max_size = INT_MAX / 2;

if (ht->p.max_size > INT_MAX / 2)
	return -EINVAL;
