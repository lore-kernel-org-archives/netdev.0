From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] inetpeer: Support ipv6 addresses.
Date: Mon, 29 Mar 2010 15:15:39 -0700 (PDT)
Message-ID: <20100329.151539.216335891.davem@davemloft.net>
References: <20100328.064012.193708716.davem@davemloft.net>
	<20100328135931.GA16430@gondor.apana.org.au>
	<20100328143235.GA16694@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43228
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751312Ab0C2WPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 18:15:39 -0400
In-Reply-To: <20100328143235.GA16694@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 28 Mar 2010 22:32:35 +0800

> Instead of placing the metrics into the inetpeer, we create a new
> global cache for them (let's call it the metrics cache for now).
> However, we don't actually populate this cache every time we create
> an rt object.  Instead, we only create an entry in this cache
> when an event requires it, e.g., when we receive a PMTU message.
> 
> In order for this to then propagate to the rt objects, we increment
> a genid in the inetpeer cache for the corresponding host.  This
> genid is then checked by the rt object every time.  When it is
> out of step, the rt object can perform a lookup in the metrics cache
> to get the latest data.
> 
> Of course once an rt object has a pointer to an entry in the metrics
> cache it doesn't need to check the genid anymore, until the metrics
> data expires at which point this process can be repeated.

Interesting idea, but there is the issue of how to fill in
new metrics cache entries when these requests come in later.

We'd have to retain a pointer to the routing table fib entry.
This is because the fib entry states what the initial metric
values need to be for cached routes.

So we'd need a pointer to the fib_info in the routing cache entry, and
this pointer would need to grab a reference to the fib_info.  And this
subsequently leads to the question of what to do for route changes
(f.e. hold the fib_info around until all the route cache entries drop
their references and have a dead state in the fib_info struct that can
be checked, and if we find it dead what can we even do as the route
we're working with might be cached in a socket or similar)

The other option is to relookup the FIB, but we'd then have to
validate that the route cache entry we're working with matches
precisely still, and also this lookup alone going to have non-trivial
cost :-)

It's really depressing how hard it is to untangle the way we have
things currently setup, isn't it. :-)

