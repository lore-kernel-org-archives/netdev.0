From: roy.qing.li@gmail.com
Subject: [PATCH 1/2] xfrm: fix a potential use after free in xfrm4_policy.c
Date: Mon, 20 Oct 2014 16:49:13 +0800
Message-ID: <1413794954-16967-1-git-send-email-roy.qing.li@gmail.com>
Cc: steffen.klassert@secunet.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:42312 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113AbaJTItR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 04:49:17 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so4762429pab.2
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 01:49:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

pskb_may_pull() maybe change skb->data and make xprth pointer oboslete,
so recompute the xprth

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv4/xfrm4_policy.c |   19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 6156f68..a4d8177 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -98,11 +98,14 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	return 0;
 }
 
+#define NEXT_HEAD(skb) (skb_network_header(skb) + ihl)
+
 static void
 _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	u8 *xprth = skb_network_header(skb) + iph->ihl * 4;
+	int ihl = iph->ihl * 4;
+	u8 *xprth = NEXT_HEAD(skb);
 	struct flowi4 *fl4 = &fl->u.ip4;
 	int oif = 0;
 
@@ -122,7 +125,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_DCCP:
 			if (xprth + 4 < skb->data ||
 			    pskb_may_pull(skb, xprth + 4 - skb->data)) {
-				__be16 *ports = (__be16 *)xprth;
+				__be16 *ports = (__be16 *)NEXT_HEAD(skb);
 
 				fl4->fl4_sport = ports[!!reverse];
 				fl4->fl4_dport = ports[!reverse];
@@ -131,7 +134,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 		case IPPROTO_ICMP:
 			if (pskb_may_pull(skb, xprth + 2 - skb->data)) {
-				u8 *icmp = xprth;
+				u8 *icmp = NEXT_HEAD(skb);
 
 				fl4->fl4_icmp_type = icmp[0];
 				fl4->fl4_icmp_code = icmp[1];
@@ -140,7 +143,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 		case IPPROTO_ESP:
 			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
-				__be32 *ehdr = (__be32 *)xprth;
+				__be32 *ehdr = (__be32 *)NEXT_HEAD(skb);
 
 				fl4->fl4_ipsec_spi = ehdr[0];
 			}
@@ -148,7 +151,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 		case IPPROTO_AH:
 			if (pskb_may_pull(skb, xprth + 8 - skb->data)) {
-				__be32 *ah_hdr = (__be32 *)xprth;
+				__be32 *ah_hdr = (__be32 *)NEXT_HEAD(skb);
 
 				fl4->fl4_ipsec_spi = ah_hdr[1];
 			}
@@ -156,7 +159,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 		case IPPROTO_COMP:
 			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
-				__be16 *ipcomp_hdr = (__be16 *)xprth;
+				__be16 *ipcomp_hdr = (__be16 *)NEXT_HEAD(skb);
 
 				fl4->fl4_ipsec_spi = htonl(ntohs(ipcomp_hdr[1]));
 			}
@@ -164,8 +167,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 		case IPPROTO_GRE:
 			if (pskb_may_pull(skb, xprth + 12 - skb->data)) {
-				__be16 *greflags = (__be16 *)xprth;
-				__be32 *gre_hdr = (__be32 *)xprth;
+				__be16 *greflags = (__be16 *)NEXT_HEAD(skb);
+				__be32 *gre_hdr = (__be32 *)NEXT_HEAD(skb);
 
 				if (greflags[0] & GRE_KEY) {
 					if (greflags[0] & GRE_CSUM)
-- 
1.7.10.4
