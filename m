From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 3.2-3.12] skbuff: skb_segment: orphan frags before copying
Date: Sun, 13 Apr 2014 23:57:40 +0100
Message-ID: <1397429860.10849.86.camel@deadeye.wl.decadent.org.uk>
References: <20140410.215420.576903689381200176.davem@davemloft.net>
	 <1397392513.10849.75.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Pe7weeNSQFQooSV+nhDQ"
Cc: stable@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1397392513.10849.75.camel@deadeye.wl.decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Pe7weeNSQFQooSV+nhDQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

From: "Michael S. Tsirkin" <mst@redhat.com>

commit 1fd819ecb90cc9b822cd84d3056ddba315d3340f upstream.

skb_segment copies frags around, so we need
to copy them carefully to avoid accessing
user memory after reporting completion to userspace
through a callback.

skb_segment doesn't normally happen on datapath:
TSO needs to be disabled - so disabling zero copy
in this case does not look like a big deal.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
[bwh: Backported to 3.2.  As skb_segment() only supports page-frags *or* a
 frag list, there is no need for the additional frag_skb pointer or the
 preparatory renaming.]
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
For branches older than 3.6, commit a353e0ce0fd4 ('skbuff: add an api to
orphan frags') is needed before this.  This is untested and I would
appreciate a review.

Ben.
---
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2699,6 +2699,9 @@ struct sk_buff *skb_segment(struct sk_bu
 						 skb_put(nskb, hsize), hsize);
=20
 		while (pos < offset + len && i < nfrags) {
+			if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+				goto err;
+
 			*frag =3D skb_shinfo(skb)->frags[i];
 			__skb_frag_ref(frag);
 			size =3D skb_frag_size(frag);


--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.

--=-Pe7weeNSQFQooSV+nhDQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU0sWZOe/yOyVhhEJAQrYIg/9Gcsn1yRpCpXGxrb/31+GjOJ6cGCU8HRQ
3XQRMJWsgHFem+Hk1nbYBA8ecWdmiXvnTUsN9b+TTUQ+LBOXwjZ4UWwV10Gn/ODc
H32C+lv6Q42s6n2ELYTVwKkmtadM9W9gmrrykx66FBzkfI3zxThptYzP7G6munMu
sR2QlSXuJW0fCDaZzc9weeDEVruf0HO8zYOegyb8YvdsY7cvpUGL9vtly2jG/NL1
AgMefB1pL+GAOyoY1Q4VTtxIm+tuHZzkZqdVhVSKh34uhu3yidOUHllOg/UnDsnr
Bed2vgeb6Qe5Lk3X2jyrVNgXknG403jx+AYQ7jbnbJLsN2awFu3VCJOgzUDwIUPO
12ipX5i+Zv5F6eyb3sanNIm3KTDo1Gk1wD95nVnUvFOEcuUF7wHt95k2XNJbkZMX
aA1j5XPA2d/SOXgZepI6oigVcOz7Xf6QOr9YBkFwHWwCF92LdFvHYdZNDooH69i9
h2QbyEB+h3EwfG7/WsNSJeReuz6iixpcytaKbSLSnsC/k7Uq8VdVhDCRwf3aX+aq
XhRIelbnXaj6kk46NBi8NDvoRB7jg9rpp2NZD62A9eOBhkAbZGU14tiBVOiEqsA7
i/DrHCbId0lp2zPgdJ+nMpSCxBEbeHuMJeDfXJ/QPijYQFQBoN2OivIrTdWqamXQ
EOPUOipDph0=
=Chlx
-----END PGP SIGNATURE-----

--=-Pe7weeNSQFQooSV+nhDQ--
