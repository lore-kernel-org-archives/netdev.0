From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/5] xfrm4: Reload skb header pointers after calling pskb_may_pull.
Date: Fri, 30 Oct 2015 07:16:29 +0100
Message-ID: <1446185790-24214-5-git-send-email-steffen.klassert@secunet.com>
References: <1446185790-24214-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39777 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758526AbbJ3GQl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2015 02:16:41 -0400
In-Reply-To: <1446185790-24214-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A call to pskb_may_pull may change the pointers into the packet,
so reload the pointers after the call.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_policy.c | 33 ++++++++++++++++++++++++++-------
 1 file changed, 26 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index e4d533c..269b137 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -129,7 +129,10 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_DCCP:
 			if (xprth + 4 < skb->data ||
 			    pskb_may_pull(skb, xprth + 4 - skb->data)) {
-				__be16 *ports = (__be16 *)xprth;
+				__be16 *ports;
+
+				xprth = skb_network_header(skb) + iph->ihl * 4;
+				ports = (__be16 *)xprth;
 
 				fl4->fl4_sport = ports[!!reverse];
 				fl4->fl4_dport = ports[!reverse];
@@ -139,7 +142,10 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_ICMP:
 			if (xprth + 2 < skb->data ||
 			    pskb_may_pull(skb, xprth + 2 - skb->data)) {
-				u8 *icmp = xprth;
+				u8 *icmp;
+
+				xprth = skb_network_header(skb) + iph->ihl * 4;
+				icmp = xprth;
 
 				fl4->fl4_icmp_type = icmp[0];
 				fl4->fl4_icmp_code = icmp[1];
@@ -149,7 +155,10 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_ESP:
 			if (xprth + 4 < skb->data ||
 			    pskb_may_pull(skb, xprth + 4 - skb->data)) {
-				__be32 *ehdr = (__be32 *)xprth;
+				__be32 *ehdr;
+
+				xprth = skb_network_header(skb) + iph->ihl * 4;
+				ehdr = (__be32 *)xprth;
 
 				fl4->fl4_ipsec_spi = ehdr[0];
 			}
@@ -158,7 +167,10 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_AH:
 			if (xprth + 8 < skb->data ||
 			    pskb_may_pull(skb, xprth + 8 - skb->data)) {
-				__be32 *ah_hdr = (__be32 *)xprth;
+				__be32 *ah_hdr;
+
+				xprth = skb_network_header(skb) + iph->ihl * 4;
+				ah_hdr = (__be32 *)xprth;
 
 				fl4->fl4_ipsec_spi = ah_hdr[1];
 			}
@@ -167,7 +179,10 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_COMP:
 			if (xprth + 4 < skb->data ||
 			    pskb_may_pull(skb, xprth + 4 - skb->data)) {
-				__be16 *ipcomp_hdr = (__be16 *)xprth;
+				__be16 *ipcomp_hdr;
+
+				xprth = skb_network_header(skb) + iph->ihl * 4;
+				ipcomp_hdr = (__be16 *)xprth;
 
 				fl4->fl4_ipsec_spi = htonl(ntohs(ipcomp_hdr[1]));
 			}
@@ -176,8 +191,12 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_GRE:
 			if (xprth + 12 < skb->data ||
 			    pskb_may_pull(skb, xprth + 12 - skb->data)) {
-				__be16 *greflags = (__be16 *)xprth;
-				__be32 *gre_hdr = (__be32 *)xprth;
+				__be16 *greflags;
+				__be32 *gre_hdr;
+
+				xprth = skb_network_header(skb) + iph->ihl * 4;
+				greflags = (__be16 *)xprth;
+				gre_hdr = (__be32 *)xprth;
 
 				if (greflags[0] & GRE_KEY) {
 					if (greflags[0] & GRE_CSUM)
-- 
1.9.1
