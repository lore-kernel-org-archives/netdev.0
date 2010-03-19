From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Fri, 19 Mar 2010 15:20:53 +0800
Message-ID: <20100319072053.GA22913@gondor.apana.org.au>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43116 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750966Ab0CSHU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 03:20:58 -0400
Content-Disposition: inline
In-Reply-To: <1268655610-7845-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 15, 2010 at 02:20:10PM +0200, Timo Teras wrote:
>
> -		policy = flow_cache_lookup(net, fl, dst_orig->ops->family,
> -					   dir, xfrm_policy_lookup);
> -		err = PTR_ERR(policy);
> -		if (IS_ERR(policy)) {
> -			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
> -			goto dropdst;
> +		fce = flow_cache_lookup(&net->xfrm.flow_cache,
> +					fl, family, dir);
> +		if (fce == NULL)
> +			goto no_cache;
> +
> +		xf = container_of(fce, struct xfrm_flow_cache_entry, fce);
> +		xfrm_flow_cache_entry_validate(&net->xfrm.flow_cache, fce);

This doesn't work.

The flow cache operates without locking as it is a per-cpu cache.
To make this work you must ensure that you stay on the same CPU
or use some other form of synchronoisation if you write to the
object returned.

AFAICS there is no synchronisation here and you're writing to fce.

So you'll need to disable preemption around the bit that touches
fce.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
