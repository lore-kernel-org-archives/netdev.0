From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/8] xfrm: introduce helper for safe determination of mtu
Date: Wed, 28 Aug 2013 13:04:49 +0200
Message-ID: <1377687895-5780-3-git-send-email-steffen.klassert@secunet.com>
References: <1377687895-5780-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56716 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753718Ab3H1LFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 07:05:04 -0400
In-Reply-To: <1377687895-5780-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>

skb->sk socket can be of AF_INET or AF_INET6 address family. Thus we
always have to make sure we a referring to the correct interpretation
of skb->sk.

We only depend on header defines to query the mtu, so we don't introduce
a new dependency to ipv6 by this change.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/route.h     |    8 ++++++++
 include/net/xfrm.h      |   12 ++++++++++++
 net/ipv4/ip_output.c    |    8 --------
 net/ipv4/xfrm4_output.c |    4 +---
 net/ipv6/xfrm6_output.c |    5 ++++-
 5 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 2ea40c1..afdeeb5 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -317,4 +317,12 @@ static inline int ip4_dst_hoplimit(const struct dst_entry *dst)
 	return hoplimit;
 }
 
+static inline int ip_skb_dst_mtu(struct sk_buff *skb)
+{
+	struct inet_sock *inet = skb->sk ? inet_sk(skb->sk) : NULL;
+
+	return (inet && inet->pmtudisc == IP_PMTUDISC_PROBE) ?
+	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
+}
+
 #endif	/* _ROUTE_H */
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e823786..b41d2d1 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -20,6 +20,7 @@
 #include <net/route.h>
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
+#include <net/ip6_route.h>
 #include <net/flow.h>
 
 #include <linux/interrupt.h>
@@ -1723,4 +1724,15 @@ static inline int xfrm_mark_put(struct sk_buff *skb, const struct xfrm_mark *m)
 	return ret;
 }
 
+static inline int xfrm_skb_dst_mtu(struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+
+	if (sk && sk->sk_family == AF_INET6)
+		return ip6_skb_dst_mtu(skb);
+	else if (sk && sk->sk_family == AF_INET)
+		return ip_skb_dst_mtu(skb);
+	return dst_mtu(skb_dst(skb));
+}
+
 #endif	/* _NET_XFRM_H */
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4bcabf3..9ee17e3 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -211,14 +211,6 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	return -EINVAL;
 }
 
-static inline int ip_skb_dst_mtu(struct sk_buff *skb)
-{
-	struct inet_sock *inet = skb->sk ? inet_sk(skb->sk) : NULL;
-
-	return (inet && inet->pmtudisc == IP_PMTUDISC_PROBE) ?
-	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
-}
-
 static int ip_finish_output(struct sk_buff *skb)
 {
 #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 7a5491f..80baf4a 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -21,7 +21,6 @@
 static int xfrm4_tunnel_check_size(struct sk_buff *skb)
 {
 	int mtu, ret = 0;
-	struct dst_entry *dst;
 
 	if (IPCB(skb)->flags & IPSKB_XFRM_TUNNEL_SIZE)
 		goto out;
@@ -29,8 +28,7 @@ static int xfrm4_tunnel_check_size(struct sk_buff *skb)
 	if (!(ip_hdr(skb)->frag_off & htons(IP_DF)) || skb->local_df)
 		goto out;
 
-	dst = skb_dst(skb);
-	mtu = dst_mtu(dst);
+	mtu = xfrm_skb_dst_mtu(skb);
 	if (skb->len > mtu) {
 		if (skb->sk)
 			xfrm_local_error(skb, mtu);
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index b64fff3..3ac5ab2 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -138,7 +138,10 @@ static int __xfrm6_output(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct xfrm_state *x = dst->xfrm;
-	int mtu = ip6_skb_dst_mtu(skb);
+	int mtu = xfrm_skb_dst_mtu(skb);
+
+	if (mtu < IPV6_MIN_MTU)
+		mtu = IPV6_MIN_MTU;
 
 	if (skb->len > mtu && xfrm6_local_dontfrag(skb)) {
 		xfrm6_local_rxpmtu(skb, mtu);
-- 
1.7.9.5
