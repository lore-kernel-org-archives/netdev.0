From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix IPv6 PMTU disc. w/ asymmetric routes
Date: Thu, 30 Sep 2010 00:41:36 -0700 (PDT)
Message-ID: <20100930.004136.91329579.davem@davemloft.net>
References: <1285581957-30694-1-git-send-email-zenczykowski@gmail.com>
	<20100928.135800.39205209.davem@davemloft.net>
	<AANLkTi=9THOcD9FieK3uy635C1kNDc=uEdtDe4qm1WU6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40689
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754587Ab0I3HlQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 03:41:16 -0400
In-Reply-To: <AANLkTi=9THOcD9FieK3uy635C1kNDc=uEdtDe4qm1WU6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Tue, 28 Sep 2010 15:37:26 -0700

> * I still think that handling the saddr =3D=3D NULL ie. INADDR_ANY ca=
se is
> entirely superfluous, since it doesn't actually iterate through all
> possible source addresses.  With IPv6 there can be many, many possibl=
e
> source addresses (just think of link local vs global public vs privac=
y
> addresses and then tack on 6to4 and mobility, etc... for example I se=
e
> 13 ipv6 addresses on eth0 on my desktop at home, 12 of them globally
> reachable).

I only have %100 confidence in the reasoning behind why ipv4 handles
things this way, so I'll discuss this in those terms and then try
to tie it into the ipv6 side.

When we are looking up an ipv4 output route, there are 2 "source
address" objects.

1) The one specified in the "struct flowi" for the lookup
   (the flp->fl4_src passed into ip_route_output_flow) which
   is also the one that ends up in the routing cache entry's
   ->fl.fl4_src member.

2) The one contained in the routing cache entry's specification.
   Ie. rth->rt_src

These are distinct.  #1 is what is used to hash and find a matching
routing cache entry.

Since a source address of INADDR_ANY is allowed for routing lookups,
routing cache entries for the same daddr/saddr pair can exist in more
than one hash chains.

Therefore, if we didn't iterate over INADDR_ANY and the specific
address in the icmp PMTU message, we'd miss some routing cache
entries.

Look at the PMTU loops in ipv4 ip_rt_frag_needed():

	for (k =3D 0; k < 2; k++) {
		for (i =3D 0; i < 2; i++) {
			unsigned hash =3D rt_hash(daddr, skeys[i], ikeys[k],
						rt_genid(net));

("ANY vs. specific" ifindex and saddr are used for the hash
 computation)

				if (rth->fl.fl4_dst !=3D daddr ||
				    rth->fl.fl4_src !=3D skeys[i] ||
				    rth->rt_dst !=3D daddr ||
				    rth->rt_src !=3D iph->saddr ||
				    rth->fl.oif !=3D ikeys[k] ||
				    rth->fl.iif !=3D 0 ||

(and for the routing cache entry flow member comparisons)

But the routing cache entry "rt_src" member is compared always to
"iph->saddr", it doesn't use the "ANY vs. specific" skey[] value.

Unless ipv6 does not allow INADDR_ANY source address specifications
during route lookups, it ought to have the same issue too.

My understanding is that ipv6 uses a two-layered tree based scheme,
one layer to key off of the source address and one layer to key off
of the destination address.

So it seems to me that the lookups would have the same aliasing issue
that ipv4 does, and thus require checking both the specific saddr
and also the saddr INADDR_ANY.

Maybe the problem is that the ipv6 side uses the same saddr for both
the lookup and the entry comparison in these PMTU code paths?  Does it
not allow specifying them seperately as the ipv4 PMTU (and incidently
the RT redirect) code paths do?

Or is this not an issue on the ipv6 side for some reason?
