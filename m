From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ipv6: dont cache cloned routes
Date: Thu, 13 Sep 2012 17:02:46 -0400 (EDT)
Message-ID: <20120913.170246.810763209248388292.davem@davemloft.net>
References: <1347451307.13103.885.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, lorenzo@google.com, maze@google.com,
	therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758828Ab2IMVCs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 17:02:48 -0400
In-Reply-To: <1347451307.13103.885.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 12 Sep 2012 14:01:47 +0200

> From: Eric Dumazet <edumazet@google.com>
>=20
> We can now destroy cloned routes immediately from dst_release() inste=
ad
> of depending on garbage collection.
>=20
> Set DST_NOCACHE in rt6_alloc_clone() so that :
>=20
> 1) we avoid calling ip6_ins_rt() on such routes
>=20
> 2) dst_release() can call destroy when refcount becomes 0
>=20
> This allows machines to resist to DDOS.
>=20
> Reported-by: Lorenzo Colitti <lorenzo@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Maciej =AFenczykowski <maze@google.com>
> Cc: Tom Herbert <therbert@google.com>

This current behavior is very much intentional and cannot be removed
so trivially.  The scope of this change is much wider than some DDOS
test.

This change is the moral equivalent of the ipv4 routing cache removal,
but we have not done anything to compensate for the resulting ipv6
performance loss as the routing cache removal changes did.

The insertion of ipv6 route clones into the tree is how the ipv6 code
caches routes.

The only legitimate way to make this change is to revamp ipv6 route
handling properly like we did for ipv4.

This means making it such that, when legitimate, prefixed routes found
directly into the route tree are used directly.

To achieve this you need to:

1) Convert ipv6 to do ref-count-less neighbour handling and not cache
   neighbours in the ipv6 routes, instead doing the lookup on demand
   in ip6_output as we do on the ipv4 side.

2) Stop caching inetpeers in the ipv6 routes.

3) Make ipv6 in-route metrics read-only, again as we already do in
   ipv4.

And so on and so forth, until direct use of prefixed ipv6 routes is
possible.

I really can't even remotely entertain applying this patch, sorry.
