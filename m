From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/5] xfrm4: Fix header checks in _decode_session4.
Date: Fri, 30 Oct 2015 07:16:28 +0100
Message-ID: <1446185790-24214-4-git-send-email-steffen.klassert@secunet.com>
References: <1446185790-24214-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39794 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751355AbbJ3GQm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2015 02:16:42 -0400
In-Reply-To: <1446185790-24214-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We skip the header informations if the data pointer points
already behind the header in question for some protocols.
This is because we call pskb_may_pull with a negative value
converted to unsigened int from pskb_may_pull in this case.
Skipping the header informations can lead to incorrect policy
lookups, so fix it by a check of the data pointer position
before we call pskb_may_pull.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_policy.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 75e8d48..e4d533c 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -137,7 +137,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			break;
 
 		case IPPROTO_ICMP:
-			if (pskb_may_pull(skb, xprth + 2 - skb->data)) {
+			if (xprth + 2 < skb->data ||
+			    pskb_may_pull(skb, xprth + 2 - skb->data)) {
 				u8 *icmp = xprth;
 
 				fl4->fl4_icmp_type = icmp[0];
@@ -146,7 +147,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			break;
 
 		case IPPROTO_ESP:
-			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
+			if (xprth + 4 < skb->data ||
+			    pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				__be32 *ehdr = (__be32 *)xprth;
 
 				fl4->fl4_ipsec_spi = ehdr[0];
@@ -154,7 +156,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			break;
 
 		case IPPROTO_AH:
-			if (pskb_may_pull(skb, xprth + 8 - skb->data)) {
+			if (xprth + 8 < skb->data ||
+			    pskb_may_pull(skb, xprth + 8 - skb->data)) {
 				__be32 *ah_hdr = (__be32 *)xprth;
 
 				fl4->fl4_ipsec_spi = ah_hdr[1];
@@ -162,7 +165,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			break;
 
 		case IPPROTO_COMP:
-			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
+			if (xprth + 4 < skb->data ||
+			    pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				__be16 *ipcomp_hdr = (__be16 *)xprth;
 
 				fl4->fl4_ipsec_spi = htonl(ntohs(ipcomp_hdr[1]));
@@ -170,7 +174,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			break;
 
 		case IPPROTO_GRE:
-			if (pskb_may_pull(skb, xprth + 12 - skb->data)) {
+			if (xprth + 12 < skb->data ||
+			    pskb_may_pull(skb, xprth + 12 - skb->data)) {
 				__be16 *greflags = (__be16 *)xprth;
 				__be32 *gre_hdr = (__be32 *)xprth;
 
-- 
1.9.1
