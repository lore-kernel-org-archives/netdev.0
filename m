From: =?utf-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] ipv6: udp: make short packet logging consistent with ipv4
Date: Thu,  6 May 2010 15:44:35 +0200
Message-ID: <1273153475-32363-2-git-send-email-bjorn@mork.no>
References: <1273153475-32363-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:56638 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752770Ab0EFOCI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 10:02:08 -0400
In-Reply-To: <1273153475-32363-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding addresses and ports to the short packet log message,
like ipv4/udp.c does it, makes these messages a lot more useful:

[  822.182450] UDPv6: short packet: From [2001:db8:ffb4:3::1]:47839 237=
15/178 to [2001:db8:ffb4:3:5054:ff:feff:200]:1234

This requires us to drop logging in case pskb_may_pull() fails,
which also is consistent with ipv4/udp.c

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 net/ipv6/udp.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 9082485..d799244 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -692,7 +692,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_=
table *udptable,
 	u32 ulen =3D 0;
=20
 	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
-		goto short_packet;
+		goto discard;
=20
 	saddr =3D &ipv6_hdr(skb)->saddr;
 	daddr =3D &ipv6_hdr(skb)->daddr;
@@ -770,9 +770,14 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp=
_table *udptable,
 	return 0;
=20
 short_packet:
-	LIMIT_NETDEBUG(KERN_DEBUG "UDP%sv6: short packet: %d/%u\n",
+	LIMIT_NETDEBUG(KERN_DEBUG "UDP%sv6: short packet: From [%pI6c]:%u %d/=
%d to [%pI6c]:%u\n",
 		       proto =3D=3D IPPROTO_UDPLITE ? "-Lite" : "",
-		       ulen, skb->len);
+		       saddr,
+		       ntohs(uh->source),
+		       ulen,
+		       skb->len,
+		       daddr,
+		       ntohs(uh->dest));
=20
 discard:
 	UDP6_INC_STATS_BH(net, UDP_MIB_INERRORS, proto =3D=3D IPPROTO_UDPLITE=
);
--=20
1.5.6.5

