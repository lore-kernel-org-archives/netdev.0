From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/4] xfrm6: Fix IPv6 ECN decapsulation
Date: Mon, 17 Aug 2015 21:58:18 +0200
Message-ID: <1439841501-20990-2-git-send-email-steffen.klassert@secunet.com>
References: <1439841501-20990-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55658 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751403AbbHQT6f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 15:58:35 -0400
In-Reply-To: <1439841501-20990-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Egerer <thomas.egerer@secunet.com>

Using ipv6_get_dsfield on the outer IP header implies that inner and
outer header are of the the same address family. For interfamily
tunnels, particularly 646, the code reading the DSCP field obtains the
wrong values (IHL and the upper four bits of the DSCP field).
This can cause the code to detect a congestion encoutered state in the
outer header and enable the corresponding bits in the inner header, too.

Since the DSCP field is stored in the xfrm mode common buffer
independently from the IP version of the outer header, it's safe (and
correct) to take this value from there.

Signed-off-by: Thomas Egerer <thomas.egerer@secunet.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_mode_tunnel.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 901ef6f..f7fbdba 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -20,10 +20,9 @@
 
 static inline void ipip6_ecn_decapsulate(struct sk_buff *skb)
 {
-	const struct ipv6hdr *outer_iph = ipv6_hdr(skb);
 	struct ipv6hdr *inner_iph = ipipv6_hdr(skb);
 
-	if (INET_ECN_is_ce(ipv6_get_dsfield(outer_iph)))
+	if (INET_ECN_is_ce(XFRM_MODE_SKB_CB(skb)->tos))
 		IP6_ECN_set_ce(inner_iph);
 }
 
-- 
1.9.1
