From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ESP trailer_len calculation
Date: Sat, 25 Sep 2010 14:23:17 +0800
Message-ID: <20100925062317.GA15565@gondor.apana.org.au>
References: <20100924.144044.179940003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:36222 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175Ab0IYGX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Sep 2010 02:23:27 -0400
Content-Disposition: inline
In-Reply-To: <20100924.144044.179940003.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 24, 2010 at 02:40:44PM -0700, David Miller wrote:
> 
> Eric Dumazet and I recently were looking into a strange artifact in
> ESP ->trailer_len calculations.
> 
> Eric was seeing values like "17" which looked strange.
> 
> He foudn that it's because of this line in esp4.c:esp_init_state()
> 
> 	x->props.trailer_len = align + 1 + crypto_aead_authsize(esp->aead);
> 
> which comes from commit:
> 
> commit c5c2523893747f88a83376abad310c8ad13f7197
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Mon Apr 9 11:47:18 2007 -0700
> 
>     [XFRM]: Optimize MTU calculation
> 
> which is based upon discussion threads:
> 
> http://marc.info/?l=linux-netdev&m=115468159401118&w=2
> 
> and
> 
> http://marc.info/?l=linux-netdev&m=117561805827241&w=2
> 
> Even more strange, in the orignal version of this patch the
> calcaluation is actually:
> 
> 	x->props.trailer_len = align - 1 + esp->auth.icv_trunc_len;
> 
> (ie. 'align - 1' instead of 'align + 1')
> 
> It seems that this "- 1 " or "+ 1" term can be completely eliminated,
> unless there are some funny semantics wrt. the padding area of ESP.
> 
> Patrick and Herbert, what do you guys think?

The number 17 does look very strange, however, after going through
the logic it does seem correct.

To calculate the minimum safe trailer length we need to consider
the worst-case scenario, and that is a packet where the payload
just happens to be one byte less than the cipher block size.

ESP always adds two bytes, then pads to at least the cipher
block size, follwed by the authentication value.  So in the
worst case we need to add

	2 + (blocksize - 1) + authlen	=
	blocksize + 1 + authlen

which is exactly what Patrick's patch does.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
