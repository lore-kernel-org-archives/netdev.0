From: Ben Hutchings <ben@decadent.org.uk>
Subject: TSOv6 broken in atl1e
Date: Tue, 01 Dec 2009 03:19:39 +0000
Message-ID: <1259637579.3709.196.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-7WLBrDJKKGWS03NR6gOf"
Cc: 558426@bugs.debian.org, netdev <netdev@vger.kernel.org>
To: Jie Yang <jie.yang@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39873 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751724AbZLADTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 22:19:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7WLBrDJKKGWS03NR6gOf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I received a bug report <http://bugs.debian.org/558426> that shows atl1e
corrupting IPv6 packets.  I have reproduced this on an Eee PC 901 and
found that it is linked to TSO.  The most obvious thing wrong with the
driver code is that it calculates the super-packet length incorrectly.
However, fixing that:

--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1667,6 +1667,7 @@ static int atl1e_tso_csum(struct atl1e_adapter *adapt=
er,
=20
 		if (offload_type & SKB_GSO_TCPV6) {
 			real_len =3D (((unsigned char *)ipv6_hdr(skb) - skb->data)
+					+ sizeof(struct ipv6hdr)
 					+ ntohs(ipv6_hdr(skb)->payload_len));
 			if (real_len < skb->len)
 				pskb_trim(skb, real_len);
--- END ---

does not solve the problem.  Presumably this function is not
constructing correct DMA descriptors for TSOv6.

Please fix this, or I will submit a patch to remove this feature from
the driver.

Ben.

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-7WLBrDJKKGWS03NR6gOf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASxSLRue/yOyVhhEJAQK2SxAAm7sUDEivggH2WaAdr4Cfe/S6/z0afr/v
XiC22naaQeUfy6xg3EHqoBRVcb1QweW98EAOQQPgYtt4uihR6+CxXPEBVUoJtiwO
aCQDpH3j597KxtP/Yt7QLaH/zKJggcD0ibK0o+QNqzot4gBXPc10k9OE02sFUIn4
2T8c5n9W7yzmk6O04OwHiI4odtTj04NoRiGmr/QdOJdMsA/iyLmu5Ut7vOSAIhEV
RrAl5M5UyEka0gs4jvY2TMDTx1/NsMQP5defiMnSSumtD4CgHUJMamu6ulmrltBT
htLiRXmqpqkPU86CLceVuPKQEf0WG/OZRzTDeIleVGadRm65gqO+fg0lBMiZhCJd
V8kitHmmyoQTAWjvHChCUtTjvdLr0W2pmsKw/SXM2V4fHLtLNXmax5QaCYveDer4
G1TM8v+rmk6irXXjBQXvc+Y4RH5GCbv1NqkAXc4sR2OUtY2ZNvA9/5Gi7bHfoTQI
Tmvzr+OYRSSBZIHtNrSjDK/vDkr/4XJt3FbGob96/IWPZHV4zKHVhM/1rmozAU8i
+bLtgBNGITl36mxgcI3M01efxEnCEvlPYmPFaEWtiZlTA9GD2h6A0iumElKOJEuc
dZQoyOSzINfcvTwO6uycyL9N0BCRBZ4a4Pifv4B2xGw2zT8IPKcGnOU326wOgzBu
R9m22fD8kEU=
=yJV4
-----END PGP SIGNATURE-----

--=-7WLBrDJKKGWS03NR6gOf--
