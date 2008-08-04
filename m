From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] Interfamily IPSec BEET
Date: Tue, 5 Aug 2008 00:20:46 +0800
Message-ID: <20080804162046.GA12969@gondor.apana.org.au>
References: <200808041619.42562.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yoshfuji@wide.ad.jp
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41030 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753931AbYHDQUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 12:20:50 -0400
Content-Disposition: inline
In-Reply-To: <200808041619.42562.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 04, 2008 at 04:19:42PM +0300, Joakim Koskela wrote:
> This fixes the ipv4-inner, ipv6-outer mode.  This one is a bit more
> complex as not only do we need to take into account the difference
> between ipv4/ipv6 headers when adjusting the sk_buff network header,
> we also need to reserve extra room for the new ipv6 header.  This
> extra room, here got by adding it to the props.header_len, is needed
> to accomodate the new & larger ipv6 header (the kernel is currently
> panicing because of this).
> 
> The BEET ipv4 pseudo-header construction was also missing from the
> ipv6 output.
> 
> Signed-off-by: Joakim Koskela <jookos@gmail.com>

Thanks for tracking this down Joakim! I'm sorry for not spending
any time on this earlier.

> diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
> index c6bb4c6..f09fcb9 100644
> --- a/net/ipv6/esp6.c
> +++ b/net/ipv6/esp6.c
> @@ -521,6 +521,10 @@ static int esp6_init_state(struct xfrm_state *x)
>  			      crypto_aead_ivsize(aead);
>  	switch (x->props.mode) {
>  	case XFRM_MODE_BEET:
> +		x->props.header_len += IPV4_BEET_PHMAXLEN;
> +		if (x->sel.family == AF_INET)
> +			x->props.header_len += (sizeof(struct ipv6hdr) - sizeof(struct iphdr));

This is still going to break with the new any family (i.e., v4
or v6) SA.  So perhaps that should be x->sel.family != AF_INET6.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
