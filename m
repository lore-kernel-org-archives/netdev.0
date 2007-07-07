From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: [PATCH] Fix handling of IPv6 RH with 0 segments left
Date: Sat, 7 Jul 2007 17:34:59 +0300
Message-ID: <200707071735.00366@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poy.chewa.net ([194.242.114.73]:4013 "EHLO poy.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921AbXGGOfE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2007 10:35:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ix handling of IPv6 Routing Headers with zero segments left.
In that case, we should ignore the extension header and continue with
the next one, rather than return a Paramater Problem.

This is more consistent with RFC2461 (=C2=A74.4) and=20
draft-ietf-ipv6-deprecate-rh0.

Signed-off-by: R=C3=A9mi Denis-Courmont <rdenis@simphalempin.com>
---
 net/ipv6/exthdrs.c |   45 +++++++++++++++++++-------------------------=
-
 1 files changed, 19 insertions(+), 26 deletions(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 14be0b9..7c8fc06 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -398,32 +398,6 @@ static int ipv6_rthdr_rcv(struct sk_buff **skbp)
=20
 	hdr =3D (struct ipv6_rt_hdr *)skb_transport_header(skb);
=20
-	switch (hdr->type) {
-#ifdef CONFIG_IPV6_MIP6
-	case IPV6_SRCRT_TYPE_2:
-		break;
-#endif
-	case IPV6_SRCRT_TYPE_0:
-		if (accept_source_route > 0)
-			break;
-		kfree_skb(skb);
-		return -1;
-	default:
-		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
-				 IPSTATS_MIB_INHDRERRORS);
-		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
-				  (&hdr->type) - skb_network_header(skb));
-		return -1;
-	}
-
-	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr) ||
-	    skb->pkt_type !=3D PACKET_HOST) {
-		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
-				 IPSTATS_MIB_INADDRERRORS);
-		kfree_skb(skb);
-		return -1;
-	}
-
 looped_back:
 	if (hdr->segments_left =3D=3D 0) {
 		switch (hdr->type) {
@@ -454,6 +428,11 @@ looped_back:
=20
 	switch (hdr->type) {
 	case IPV6_SRCRT_TYPE_0:
+		/* Silently discard RH0 by default */
+		if (accept_source_route <=3D 0) {
+			kfree_skb(skb);
+			return -1;
+		}
 		if (hdr->hdrlen & 0x01) {
 			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
 					 IPSTATS_MIB_INHDRERRORS);
@@ -474,6 +453,20 @@ looped_back:
 		}
 		break;
 #endif
+	default:
+		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+				 IPSTATS_MIB_INHDRERRORS);
+		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
+				  (&hdr->type) - skb_network_header(skb));
+		return -1;
+	}
+
+	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr) ||
+	    skb->pkt_type !=3D PACKET_HOST) {
+		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+				 IPSTATS_MIB_INADDRERRORS);
+		kfree_skb(skb);
+		return -1;
 	}
=20
 	/*
--=20
1.5.2.3


--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
