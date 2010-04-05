From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Mon, 5 Apr 2010 16:33:02 +0800
Message-ID: <20100405083302.GA16636@gondor.apana.org.au>
References: <1270450824-2928-1-git-send-email-timo.teras@iki.fi> <1270450824-2928-2-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44761 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750930Ab0DEIdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 04:33:11 -0400
Content-Disposition: inline
In-Reply-To: <1270450824-2928-2-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 05, 2010 at 10:00:21AM +0300, Timo Teras wrote:
>
> @@ -219,33 +222,32 @@ void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family, u8 dir,
>  			fle->object = NULL;
>  			fcp->hash_count++;
>  		}
> +	} else if (fle->genid == atomic_read(&flow_cache_genid)) {
> +		flo = fle->object;
> +		if (!flo)
> +			goto ret_object;
> +		flo = flo->ops->get(flo);
> +		if (flo)
> +			goto ret_object;
>  	}
>  
>  nocache:
> -	{
> -		int err;
> -		void *obj;
> -		atomic_t *obj_ref;
> -
> -		err = resolver(net, key, family, dir, &obj, &obj_ref);
> -
> -		if (fle && !err) {
> -			fle->genid = atomic_read(&flow_cache_genid);
> -
> -			if (fle->object)
> -				atomic_dec(fle->object_ref);
> -
> -			fle->object = obj;
> -			fle->object_ref = obj_ref;
> -			if (obj)
> -				atomic_inc(fle->object_ref);
> +	flo = resolver(net, key, family, dir, fle ? fle->object : NULL, ctx);
> +	if (fle) {
> +		fle->genid = atomic_read(&flow_cache_genid);
> +		if (IS_ERR(flo)) {
> +			fle->genid--;
> +			fle->object = NULL;

Shouldn't we call fle->object->ops->delete here?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
