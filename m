From: kaber@trash.net
Subject: [PATCH 70/84] netfilter: ipv6: move xfrm_lookup at end of ip6_route_me_harder
Date: Mon, 10 May 2010 22:18:41 +0200
Message-ID: <1273522735-24672-71-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Weber <uweber@astaro.com>

xfrm_lookup should be called after ip6_route_output skb_dst_set,
otherwise skb_dst_set of xfrm_lookup is pointless

Signed-off-by: Ulrich Weber <uweber@astaro.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter.c |   25 +++++++++++--------------
 1 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index d5ed92b..a74951c 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -25,20 +25,6 @@ int ip6_route_me_harder(struct sk_buff *skb)
 	};
 
 	dst = ip6_route_output(net, skb->sk, &fl);
-
-#ifdef CONFIG_XFRM
-	if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
-	    xfrm_decode_session(skb, &fl, AF_INET6) == 0) {
-		struct dst_entry *dst2 = skb_dst(skb);
-
-		if (xfrm_lookup(net, &dst2, &fl, skb->sk, 0)) {
-			skb_dst_set(skb, NULL);
-			return -1;
-		}
-		skb_dst_set(skb, dst2);
-	}
-#endif
-
 	if (dst->error) {
 		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 		LIMIT_NETDEBUG(KERN_DEBUG "ip6_route_me_harder: No more route.\n");
@@ -50,6 +36,17 @@ int ip6_route_me_harder(struct sk_buff *skb)
 	skb_dst_drop(skb);
 
 	skb_dst_set(skb, dst);
+
+#ifdef CONFIG_XFRM
+	if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
+	    xfrm_decode_session(skb, &fl, AF_INET6) == 0) {
+		skb_dst_set(skb, NULL);
+		if (xfrm_lookup(net, &dst, &fl, skb->sk, 0))
+			return -1;
+		skb_dst_set(skb, dst);
+	}
+#endif
+
 	return 0;
 }
 EXPORT_SYMBOL(ip6_route_me_harder);
-- 
1.7.0.4

