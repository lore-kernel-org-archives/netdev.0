From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: GRO after RPS?
Date: Mon, 26 Apr 2010 09:41:12 +0800
Message-ID: <20100426014112.GA19870@gondor.apana.org.au>
References: <20100425.170933.190068177.davem@davemloft.net> <20100426004934.GA12525@gondor.apana.org.au> <20100425.181757.10149105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:51428 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753747Ab0DZBlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 21:41:15 -0400
Content-Disposition: inline
In-Reply-To: <20100425.181757.10149105.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 25, 2010 at 06:17:57PM -0700, David Miller wrote:
>
> Either GRO walks the skb->rxhash values one by one, or GRO does, the
> cost is going to be roughly equivalent I think.

(I presume one of those GROs is meant to be RPS).
Right, in fact if we could combine the two it would be even better.

> And when the packets do match, you can't just trust the ->rxhash in
> the GRO code, since a hash match only indicates that the packets might
> have the same flow.  So you're going to have to touch the packet
> headers in that case on the pre-RPS cpu.

Yes, if the rxhash matches then we need to examine the packet
header.  However, in that case the packet will most likely turn
out to be a GRO candidate, meaning that you have to do one fewer
RPS lookup/redirection.

Besides, the place where you need GRO most is where the hardware
doesn't do it directly.  That same hardware is probably not going
to give you a hash either.  When if we have to touch the packet
header, it would be beneficial to do GRO while it's still hot.

> The goal is to eliminate all packet header references from the pre-RPS
> path, and let the post-RPS cpu do it.

So if we changed GRO to use hardware hashes, then the only case
where it would touch the packet header unnecessarily is when we
get a hash collision.

In all other cases the header would only be touched in case we
have a hash match, which will most likely result in a merging.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
