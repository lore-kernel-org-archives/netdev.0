From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 3/10] rhashtable: Allow hashfn to be unset
Date: Sun, 22 Mar 2015 11:55:05 +0000
Message-ID: <20150322115505.GD1185@casper.infradead.org>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZarZ-0000v8-7e@gondolin.me.apana.org.au>
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
Received: from casper.infradead.org ([85.118.1.10]:50159 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661AbbCVLzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 07:55:07 -0400
Content-Disposition: inline
In-Reply-To: <E1YZarZ-0000v8-7e@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/15 at 07:04pm, Herbert Xu wrote:
> @@ -134,6 +136,7 @@ struct rhashtable {
>  	struct bucket_table __rcu	*tbl;
>  	atomic_t			nelems;
>  	bool                            being_destroyed;
> +	unsigned int			key_len;

Why is this needed? It looks like you're always initializing this
with ht->p.key_len

>  	struct rhashtable_params	p;
>  	struct work_struct		run_work;
>  	struct mutex                    mutex;
> @@ -199,12 +202,30 @@ static inline unsigned int rht_key_hashfn(
>  	struct rhashtable *ht, const struct bucket_table *tbl,
>  	const void *key, const struct rhashtable_params params)
>  {
> -	unsigned key_len = __builtin_constant_p(params.key_len) ?
> -			   (params.key_len ?: ht->p.key_len) :
> -			   params.key_len;
> +	unsigned hash;

unsigned int

In several places as well

> +	if (!__builtin_constant_p(params.key_len))
> +		hash = ht->p.hashfn(key, ht->key_len, tbl->hash_rnd);

I don't understand this. It looks like you only consider
params->key_len if it's constant.

> +	else if (params.key_len) {
> +		unsigned key_len = params.key_len;
> +
> +		if (params.hashfn)
> +			hash = params.hashfn(key, key_len, tbl->hash_rnd);
> +		else if (key_len & (sizeof(u32) - 1))
> +			hash = jhash(key, key_len, tbl->hash_rnd);
> +		else
> +			hash = jhash2(key, key_len / sizeof(u32),
> +				      tbl->hash_rnd);
> +	} else {
> +		unsigned key_len = ht->p.key_len;
> +
> +		if (params.hashfn)
> +			hash = params.hashfn(key, key_len, tbl->hash_rnd);
> +		else
> +			hash = jhash(key, key_len, tbl->hash_rnd);

Why don't we opt-in to jhash2 in this case?
