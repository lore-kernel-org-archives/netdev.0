From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC] inetpeer: Support ipv6 addresses.
Date: Sun, 28 Mar 2010 22:32:35 +0800
Message-ID: <20100328143235.GA16694@gondor.apana.org.au>
References: <20100328082250.GA14053@gondor.apana.org.au> <20100328.055312.58421329.davem@davemloft.net> <20100328131112.GA15984@gondor.apana.org.au> <20100328.064012.193708716.davem@davemloft.net> <20100328135931.GA16430@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:51862 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754657Ab0C1Ocj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 10:32:39 -0400
Content-Disposition: inline
In-Reply-To: <20100328135931.GA16430@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 28, 2010 at 09:59:31PM +0800, Herbert Xu wrote:
> 
> I don't think they are quite the same.  The TCP time stamp is
> an attribute of the destination host, it doesn't vary depending
> on which route you take to reach the host.  The MTU on the other
> hand is an attribute of the route that reaches the host.

Here's a convoluted scheme that I just thought up as a compromise
between your wish to expel the metrics and maintaining the policy
routing semantics.

Instead of placing the metrics into the inetpeer, we create a new
global cache for them (let's call it the metrics cache for now).
However, we don't actually populate this cache every time we create
an rt object.  Instead, we only create an entry in this cache
when an event requires it, e.g., when we receive a PMTU message.

In order for this to then propagate to the rt objects, we increment
a genid in the inetpeer cache for the corresponding host.  This
genid is then checked by the rt object every time.  When it is
out of step, the rt object can perform a lookup in the metrics cache
to get the latest data.

Of course once an rt object has a pointer to an entry in the metrics
cache it doesn't need to check the genid anymore, until the metrics
data expires at which point this process can be repeated.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
