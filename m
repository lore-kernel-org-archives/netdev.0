From: Dan Siemon <dan@coverfire.com>
Subject: Flow classifier proto-dst and TOS (and proto-src)
Date: Sat, 15 Oct 2011 12:51:02 -0400
Message-ID: <1318697463.7169.21.camel@ganymede>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-5IPKBjVSSoD1Gqv+A6bG"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.coverfire.com ([69.41.199.58]:44295 "EHLO
	alpha.coverfire.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929Ab1JORBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2011 13:01:50 -0400
Received: from [192.168.88.98] (ganymede [192.168.88.98])
	(authenticated bits=0)
	by alpha.coverfire.com (8.14.4/8.14.4) with ESMTP id p9FGp3Jp023889
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 15 Oct 2011 12:51:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5IPKBjVSSoD1Gqv+A6bG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

cls_flow.c: flow_get_proto_dst()

The proto-dst key returns the destination port for UDP, TCP and a few
other protocols [see proto_ports_offset()]. For ICMP and IPIP it falls
back to:

return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;

Since Linux maintains a dst_entry for each TOS value this causes the
returned value to be affected by the TOS which is unexpected and
probably broken.

Is there a reason why this doesn't return 0 for protocols that don't
have a notion of source and destination ports? It seems very odd to me
that a value which is not at all related to the traffic on the wire is
returned for this key.

There is a somewhat similar situation with flow_get_proto_src(). Here
the fallback value is:

return addr_fold(skb->sk);

It looks like this is 0 when the traffic doesn't originate locally and
even for local traffic I don't understand why the use of a effectively
random number here is useful.

For a long winded explanation of how I discovered this see:
http://www.coverfire.com/archives/2011/10/15/linux-flow-classifier-proto-ds=
t-and-tos/

Below is a simple patch which makes these functions fallback to
returning 0 when the protocol doesn't have the notion of ports.

Signed-off-by: Dan Siemon <dan@coverfire.com>
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 6994214..7527e61 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -150,7 +150,7 @@ static u32 flow_get_proto_src(struct sk_buff *skb)
 	}
 	}
=20
-	return addr_fold(skb->sk);
+	return 0;
 }
=20
 static u32 flow_get_proto_dst(struct sk_buff *skb)
@@ -192,7 +192,7 @@ static u32 flow_get_proto_dst(struct sk_buff *skb)
 	}
 	}
=20
-	return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
+	return 0;
 }
=20
static u32 flow_get_iif(const struct sk_buff *skb)


--=-5IPKBjVSSoD1Gqv+A6bG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCAAGBQJOmbn2AAoJEJKXGLoTP2w+JWMP/2o9CqEPjIvMpVt5CdODWLpv
8on3KZNOIkKAqAhbzVbQW+SJyggnuhBiedtXWu8Uadeb2y7w1V9HItaTDLkOTM4O
H3Vr4Gc6EOf+2rK24bnCPi2tI3JuooiUEl7K6sx4DvOZ70wamHxaWU9R06FzsU3n
hD5GgjhiIkC1UH4cw9UG32CgzS11iMddbpoDcyhxslQmI9c6v9g7iqWjHBGlxzEL
7yw02/M4Pkt5qQoTYzpzUIWLUG32kvGMQ+iunawtfS/M2k1k50vDT2oLW6k+wEeN
2ab7yitVrMKwvDKTnczNGsUQ/uufeuz6VgOFHWNJ+EjawfxNaOsJjZwjOlz8FqLj
cZoc71f/BH2w+Egcz2BRZxfPhSqcN481Vp1ND3Ei69DleHleoXMyG2kPdA7ojg48
MVBN2o03/DAoHG3UQGA/gIMitlVSf1dQAO5PKKkYv9iLoKv/bfRQ8pC2//X2hY9F
oMfEW1GU/Aum6owejzc8R1GHXimkqj0Pipf/vckd5CnHGHiqdwUjKF9K2LB59VRF
XiC5dRPCZ5UBHOix6W0x+TE/kvptUnh2aE8WAUPDr/TbVDHxAkgxuSTePWkSaQ1j
OmPUFh8MXXYXBLs1h1WL+VVKQzj5ftzSSpTXoX8+3HuDj8w0Mp5lZeLxXcuIRIUQ
JFEix/Ti+Fl9oWr8nh16
=j9Xm
-----END PGP SIGNATURE-----

--=-5IPKBjVSSoD1Gqv+A6bG--
