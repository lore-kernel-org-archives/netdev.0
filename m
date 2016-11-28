From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [RFC PATCH net-next] ipv6: implement consistent hashing for equal-cost
 multipath routing
Date: Mon, 28 Nov 2016 21:16:19 +0100
Message-ID: <583C9093.7060404@uclouvain.be>
References: <1480017556-25988-1-git-send-email-david.lebrun@uclouvain.be> <20161128.112248.2198395724649783009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="0jNgHjluglLHQTRiC5txg2IrwsuvSLn7P"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:35120 "EHLO
        smtp3.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755060AbcK1UQV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:16:21 -0500
In-Reply-To: <20161128.112248.2198395724649783009.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0jNgHjluglLHQTRiC5txg2IrwsuvSLn7P
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 11/28/2016 05:22 PM, David Miller wrote:
> Thanks for trying to solve this problem.
>=20
> But we really don't want this to be Kconfig gated.  If we decide to
> support this it should be a run-time selectable option.  Every
> distribution on the planet is going to turn your Kconfig option on, so
> whatever you think we might be saving by putting this behind Kconfig
> checks won't be realized for large swaths of the userbase.
>=20

OK for that

> I also question how necessary %100 consistent hashing of ECMP really
> is.
>=20
> If we can do something at extremely low cost and arrive at a very low
> disruption rate, honestly that's probably good enough.
>=20
> I assume you've looked over RFC2992.  A low disrutpion algorithm is
> described there and if we could just get rid of the divide it might
> be extremely desirable.

I wanted a solution that has very low disruption for both scale up and
scale down. When a next-hop is added, only 1/N flows should be disrupted
(i.e. in this case, reaffected to the new next-hop). When a next-hop is
removed, only the flows that were handled by this particular next-hop
should be disrupted, and those flows should be equally rebalanced across
the remaining next-hops. Although the solution presented in RFC2992 has
a "reasonably" low disruption (looks like it can get up to 1/2
disruption though), I'm not sure if the equal-rebalancing part holds.

The advantage of my solution over RFC2992 is lowest possible disruption
and equal rebalancing of affected flows. The disadvantage is the lookup
complexity of O(log n) vs O(1). Although from a theoretical viewpoint
O(1) is obviously better, would O(log n) have an effectively measurable
negative impact on scalability ? If we consider 32 next-hops for a route
and 100 pseudo-random numbers generated per next-hop, the lookup
algorithm would have to perform in the worst case log2 3200 =3D 11
comparisons to select a next-hop for that route.

For my part I prefer the minimal disruption over constant time lookup.
I'll try to come up with some measurements to see the actual impact.

David


--0jNgHjluglLHQTRiC5txg2IrwsuvSLn7P
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlg8kJYACgkQjbzn67sZ6ANJxQCcDNthM5x6iA1xrYTLH96cgxz6
hPsAn3i0rT+mNt3zowZfXy17MOSqFymE
=mvSI
-----END PGP SIGNATURE-----

--0jNgHjluglLHQTRiC5txg2IrwsuvSLn7P--
