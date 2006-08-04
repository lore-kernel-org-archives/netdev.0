From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Improve MTU estimation
Date: Fri, 4 Aug 2006 20:01:21 +1000
Message-ID: <20060804100121.GA17239@gondor.apana.org.au>
References: <44D30A48.4050403@trash.net> <44D312EF.8010202@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35601 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030217AbWHDKBY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 06:01:24 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44D312EF.8010202@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 04, 2006 at 11:27:11AM +0200, Patrick McHardy wrote:
>
> [XFRM]: Improve MTU estimation
> 
> Replace the probing based MTU estimation, which usually takes 2-3
> iterations to find a fitting value and may underestimate the MTU,
> by an exact calculation.

Thanks Patrick, this is definitely the better way to do it.
  
> -static u32 esp4_get_max_size(struct xfrm_state *x, int mtu)
> +static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
>  {
>  	struct esp_data *esp = x->data;
> -	u32 blksize = ALIGN(crypto_tfm_alg_blocksize(esp->conf.tfm), 4);
> +	u32 align = ALIGN(crypto_tfm_alg_blocksize(esp->conf.tfm), 4);
>  
> -	if (x->props.mode) {
> -		mtu = ALIGN(mtu + 2, blksize);
> -	} else {
> -		/* The worst case. */
> -		mtu = ALIGN(mtu + 2, 4) + blksize - 4;
> -	}
> -	if (esp->conf.padlen)
> -		mtu = ALIGN(mtu, esp->conf.padlen);
> +	if (esp->conf.padlen > align)
> +		align = esp->conf.padlen;
>  
> -	return mtu + x->props.header_len + esp->auth.icv_trunc_len;
> +	mtu -= x->props.header_len + esp->auth.icv_trunc_len;
> +	mtu &= ~(align - 1);
> +	mtu -= 2;
> +
> +	return mtu;

I haven't actually done the math, but I don't think this can be right
from a quick look.  The reason is that transport mode is fundamentally
different from tunnel mode in that the IP options are not encrypted and
therefore do not contribute to the encryption block padding.

So as the code doesn't distinguish between transport mode and tunnel
mode, you might be producing an overestimate for transport mode.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
