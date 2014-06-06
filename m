From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 3.2-3.12] skbuff: skb_segment: orphan frags before copying
Date: Fri, 06 Jun 2014 17:09:28 +0100
Message-ID: <1402070968.23860.9.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+yb7l5og1/mlZ4s4cqjz"
Cc: netdev <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, stable <stable@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-+yb7l5og1/mlZ4s4cqjz
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
This is what I used in Debian for 3.2, and I believe it applies to all
stable branches up to 3.12 inclusive.

For branches older than 3.6, this requires cherry-picking commit
a353e0ce0fd4 ('skbuff: add an api to orphan frags').  To avoid breaking
OOT builds of openvswitch, which will use skb_orphan_frags() if
available, it is also necessary to cherry-pick commit dcc0fb782b3a
('skbuff: export skb_copy_ubufs').

Ben.

--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2701,6 +2701,9 @@ struct sk_buff *skb_segment(struct sk_bu
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
You can't have everything.  Where would you put it?

--=-+yb7l5og1/mlZ4s4cqjz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU5Hnvue/yOyVhhEJAQolaA/9HRM5BGo7HTFqQu+Z+S/jZWVDikJv6G19
BNJxaM1CC3xIn8wcnc9tQk4X8fGBT94rt4Xjm43WCU2INVVAMFldfX2Bh9tbJaYr
jRGgpsUrB5PpNEYStIj6kCzRZ90O6HN3vBxCWkCeHnOCAWKM9q1cvLygy9SQ/A/z
ydY2mA9WcfxixOigXI3nVFUpfIpdu0EqfJ8Fe6CDtYxJxY6BV8G2BrGPkhFCrxYJ
PCtR347tnaTSL9d4K6rJJM3bQYUpPfUBsrXBlSil8KDShdqdKTZhRWpsP/PhmHev
fWUyLyzNIiUEPvLzPvQU3swrNAFPAjPk/HD/kRaGCwklId4SZMIhwcotT7yYUCIN
sV0Y2iX+3gRuLZSEPOVG3WF2+BzOuEbRx5Tn340CZp6YmVV3M/odTG1iksp2GRrL
+82unSzd2OWULl1hJ3bIHLjMFYa6w97ItAaktJUdoHbLKxZAuK/qlW/9HDIBe73f
6BGSHBIdV9FXPtZ9qXxXBPMscb3hEIJaS1jLumxwGKMJKzuvG7jvcJiY/77KwS2S
CFiDp42XY0ExOQyjRdbmvS5rSVbRHCIguIf9DjQZEQwHNnlAk1L7Oj0L+eppne61
BY8pnyJ8RaPSjwt20UDnf2PdDioFT/uB44OmbVk2QG02wh+GvmwpdcFI3YlmBeSG
G9SUVyQrRwg=
=suXB
-----END PGP SIGNATURE-----

--=-+yb7l5og1/mlZ4s4cqjz--
