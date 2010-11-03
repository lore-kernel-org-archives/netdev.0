From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH] xfrm: use gre key as flow upper protocol info
Date: Wed,  3 Nov 2010 16:41:38 +0200
Message-ID: <1288795298-323-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61319 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280Ab0KCOly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 10:41:54 -0400
Received: by eye27 with SMTP id 27so281419eye.19
        for <netdev@vger.kernel.org>; Wed, 03 Nov 2010 07:41:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The GRE Key field is intended to be used for identifying an individual
traffic flow within a tunnel. It is useful to be able to have XFRM
policy selector matches to have different policies for different
GRE tunnels.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
Basic testing done, but more knowledgeable should check that I did
not miss anything essential.

 include/net/flow.h      |    2 ++
 include/net/xfrm.h      |    6 ++++++
 net/ipv4/ip_gre.c       |   12 +++++++-----
 net/ipv4/xfrm4_policy.c |   15 +++++++++++++++
 4 files changed, 30 insertions(+), 5 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 0ac3fb5..7196e68 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -67,6 +67,7 @@ struct flowi {
 		} dnports;
=20
 		__be32		spi;
+		__be32		gre_key;
=20
 		struct {
 			__u8	type;
@@ -78,6 +79,7 @@ struct flowi {
 #define fl_icmp_code	uli_u.icmpt.code
 #define fl_ipsec_spi	uli_u.spi
 #define fl_mh_type	uli_u.mht.type
+#define fl_gre_key	uli_u.gre_key
 	__u32           secid;	/* used by xfrm; see secid.txt */
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
=20
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bcfb6b2..54b2832 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -805,6 +805,9 @@ __be16 xfrm_flowi_sport(struct flowi *fl)
 	case IPPROTO_MH:
 		port =3D htons(fl->fl_mh_type);
 		break;
+	case IPPROTO_GRE:
+		port =3D htonl(fl->fl_gre_key) >> 16;
+		break;
 	default:
 		port =3D 0;	/*XXX*/
 	}
@@ -826,6 +829,9 @@ __be16 xfrm_flowi_dport(struct flowi *fl)
 	case IPPROTO_ICMPV6:
 		port =3D htons(fl->fl_icmp_code);
 		break;
+	case IPPROTO_GRE:
+		port =3D htonl(fl->fl_gre_key) & 0xffff;
+		break;
 	default:
 		port =3D 0;	/*XXX*/
 	}
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 70ff77f..ffc78e8 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -779,9 +779,9 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff=
 *skb, struct net_device *dev
 					.tos =3D RT_TOS(tos)
 				}
 			},
-			.proto =3D IPPROTO_GRE
-		}
-;
+			.proto =3D IPPROTO_GRE,
+			.fl_gre_key =3D tunnel->parms.o_key
+		};
 		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
 			dev->stats.tx_carrier_errors++;
 			goto tx_error;
@@ -958,7 +958,8 @@ static int ipgre_tunnel_bind_dev(struct net_device =
*dev)
 					.tos =3D RT_TOS(iph->tos)
 				}
 			},
-			.proto =3D IPPROTO_GRE
+			.proto =3D IPPROTO_GRE,
+			.fl_gre_key =3D tunnel->parms.o_key
 		};
 		struct rtable *rt;
=20
@@ -1223,7 +1224,8 @@ static int ipgre_open(struct net_device *dev)
 					.tos =3D RT_TOS(t->parms.iph.tos)
 				}
 			},
-			.proto =3D IPPROTO_GRE
+			.proto =3D IPPROTO_GRE,
+			.fl_gre_key =3D t->parms.o_key
 		};
 		struct rtable *rt;
=20
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 4464f3b..57af4bd 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -11,6 +11,7 @@
 #include <linux/err.h>
 #include <linux/kernel.h>
 #include <linux/inetdevice.h>
+#include <linux/if_tunnel.h>
 #include <net/dst.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
@@ -158,6 +159,20 @@ _decode_session4(struct sk_buff *skb, struct flowi=
 *fl, int reverse)
 				fl->fl_ipsec_spi =3D htonl(ntohs(ipcomp_hdr[1]));
 			}
 			break;
+
+		case IPPROTO_GRE:
+			if (pskb_may_pull(skb, xprth + 12 - skb->data)) {
+				__be16 *greflags =3D (__be16 *)xprth;
+				__be32 *gre_hdr =3D (__be32 *)xprth;
+
+				if (greflags[0] & GRE_KEY) {
+					if (greflags[0] & GRE_CSUM)
+						gre_hdr++;
+					fl->fl_gre_key =3D gre_hdr[1];
+				}
+			}
+			break;
+
 		default:
 			fl->fl_ipsec_spi =3D 0;
 			break;
--=20
1.7.1

