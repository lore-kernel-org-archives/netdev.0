From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] XCBC support with new crypto framework
Date: Wed, 9 Aug 2006 20:23:00 +1000
Message-ID: <20060809102300.GA23593@gondor.apana.org.au>
References: <20060809191451.f36b558c.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41233 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030653AbWHIKXQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 06:23:16 -0400
To: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Content-Disposition: inline
In-Reply-To: <20060809191451.f36b558c.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 07:14:51PM +0900, Kazunori MIYAZAWA wrote:
> 
> I make a patch set of introducing XCBC with your new crypto framework.
> I checked the patches work well with the tcrypt module.
> However I can not make sure that I completely understand the API.
> 
> So I would appreciate if you would give me some comments.

It looks great to me!

> +void crypto_xcbc_digest_final(struct crypto_tfm *parent, u8 *out)
> +{
> +	int bs = crypto_tfm_alg_blocksize(parent);
> +	u8 *prev = crypto_tfm_ctx_aligned(parent);
> +	u8 *key = prev + bs;
> +	u8 *consts = key + bs;
> +	struct crypto_xcbc_ctx *ctx = (struct crypto_xcbc_ctx*)(prev + bs * 5);
> +	struct crypto_tfm *tfm = ctx->child;
> +
> +	if (ctx->len == bs) {
> +		u8 key2[bs];
> +
> +		if ((crypto_cipher_setkey(tfm, key, ctx->keylen)) != 0)

Setkey is a relatively expensive operation so it's best to not do
it for every digest operation.  How about keeping two child tfm's,
one for each key?

> +	ctx->child = crypto_spawn_tfm(spawn, CRYPTO_TFM_MODE_CBC);

The mode can go away as soon as I get the parameterised CBC patches
out (i.e., you'd allocate "cbc(aes)" instead of "aes").
  
> diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
> index 2783d4e..6c48292 100644
> --- a/net/xfrm/xfrm_algo.c
> +++ b/net/xfrm/xfrm_algo.c
> @@ -119,6 +119,24 @@ static struct xfrm_algo_desc aalg_list[]
>  		.sadb_alg_maxbits = 160
>  	}
>  },
> +{
> +	.name = "xcbc(aes)",
> +	.compat = "aes_xcbc_128",

No need for a compat name since this never existed before.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
