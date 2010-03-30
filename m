From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC] inetpeer: Support ipv6 addresses.
Date: Tue, 30 Mar 2010 20:34:15 +0800
Message-ID: <20100330123414.GA6174@gondor.apana.org.au>
References: <20100328.064012.193708716.davem@davemloft.net> <20100328135931.GA16430@gondor.apana.org.au> <20100328143235.GA16694@gondor.apana.org.au> <20100329.151539.216335891.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:60671 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755073Ab0C3MeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 08:34:19 -0400
Content-Disposition: inline
In-Reply-To: <20100329.151539.216335891.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 03:15:39PM -0700, David Miller wrote:
>
> Interesting idea, but there is the issue of how to fill in
> new metrics cache entries when these requests come in later.

You just perform an rt lookup as usual.  That'll give you the
metrics either from the route cache, or from scratch if we get
a cache miss.

> We'd have to retain a pointer to the routing table fib entry.
> This is because the fib entry states what the initial metric
> values need to be for cached routes.

We can keep the static metrics in the dst/rt entry.  For me
shrinking the dst entry isn't such a big deal, but avoiding touching
global state when constructing a new rt entry is the deal-breaker.

But if you're really into dieting then we can have that fib
pointer :)

> So we'd need a pointer to the fib_info in the routing cache entry, and
> this pointer would need to grab a reference to the fib_info.  And this
> subsequently leads to the question of what to do for route changes
> (f.e. hold the fib_info around until all the route cache entries drop
> their references and have a dead state in the fib_info struct that can
> be checked, and if we find it dead what can we even do as the route
> we're working with might be cached in a socket or similar)

AFAIK on route changes we always flush the route cache.

> The other option is to relookup the FIB, but we'd then have to
> validate that the route cache entry we're working with matches
> precisely still, and also this lookup alone going to have non-trivial
> cost :-)
> 
> It's really depressing how hard it is to untangle the way we have
> things currently setup, isn't it. :-)

Yeah it's like the Gordian Knot :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
