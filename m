From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 6/8] xfrm: revert ipv4 mtu determination to dst_mtu
Date: Wed, 28 Aug 2013 13:04:53 +0200
Message-ID: <1377687895-5780-7-git-send-email-steffen.klassert@secunet.com>
References: <1377687895-5780-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56739 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753527Ab3H1LFH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 07:05:07 -0400
In-Reply-To: <1377687895-5780-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>

In commit 0ea9d5e3e0e03a63b11392f5613378977dae7eca ("xfrm: introduce
helper for safe determination of mtu") I switched the determination of
ipv4 mtus from dst_mtu to ip_skb_dst_mtu. This was an error because in
case of IP_PMTUDISC_PROBE we fall back to the interface mtu, which is
never correct for ipv4 ipsec.

This patch partly reverts 0ea9d5e3e0e03a63b11392f5613378977dae7eca
("xfrm: introduce helper for safe determination of mtu").

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h      |   12 ------------
 net/ipv4/xfrm4_output.c |    2 +-
 net/ipv6/xfrm6_output.c |    8 +++++---
 3 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ac5b025..e823786 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -20,7 +20,6 @@
 #include <net/route.h>
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
-#include <net/ip6_route.h>
 #include <net/flow.h>
 
 #include <linux/interrupt.h>
@@ -1724,15 +1723,4 @@ static inline int xfrm_mark_put(struct sk_buff *skb, const struct xfrm_mark *m)
 	return ret;
 }
 
-static inline int xfrm_skb_dst_mtu(struct sk_buff *skb)
-{
-	struct sock *sk = skb->sk;
-
-	if (sk && skb->protocol == htons(ETH_P_IPV6))
-		return ip6_skb_dst_mtu(skb);
-	else if (sk && skb->protocol == htons(ETH_P_IP))
-		return ip_skb_dst_mtu(skb);
-	return dst_mtu(skb_dst(skb));
-}
-
 #endif	/* _NET_XFRM_H */
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 80baf4a..baa0f63 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -28,7 +28,7 @@ static int xfrm4_tunnel_check_size(struct sk_buff *skb)
 	if (!(ip_hdr(skb)->frag_off & htons(IP_DF)) || skb->local_df)
 		goto out;
 
-	mtu = xfrm_skb_dst_mtu(skb);
+	mtu = dst_mtu(skb_dst(skb));
 	if (skb->len > mtu) {
 		if (skb->sk)
 			xfrm_local_error(skb, mtu);
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index e092e30..6cd625e 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -140,10 +140,12 @@ static int __xfrm6_output(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct xfrm_state *x = dst->xfrm;
-	int mtu = xfrm_skb_dst_mtu(skb);
+	int mtu;
 
-	if (mtu < IPV6_MIN_MTU)
-		mtu = IPV6_MIN_MTU;
+	if (skb->protocol == htons(ETH_P_IPV6))
+		mtu = ip6_skb_dst_mtu(skb);
+	else
+		mtu = dst_mtu(skb_dst(skb));
 
 	if (skb->len > mtu && xfrm6_local_dontfrag(skb)) {
 		xfrm6_local_rxpmtu(skb, mtu);
-- 
1.7.9.5
