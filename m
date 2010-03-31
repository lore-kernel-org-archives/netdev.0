From: Jan Engelhardt <jengelh@medozas.de>
Subject: [PATCH 1/5] netfilter: ipv6: move POSTROUTING invocation before fragmentation
Date: Wed, 31 Mar 2010 12:38:49 +0200
Message-ID: <1270031934-15940-2-git-send-email-jengelh@medozas.de>
References: <1270031934-15940-1-git-send-email-jengelh@medozas.de>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1270031934-15940-1-git-send-email-jengelh@medozas.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy notes: "We used to invoke IPv4 POST_ROUTING after
fragmentation as well just to defragment the packets in conntrack
immediately afterwards, but that got changed during the
netfilter-ipsec integration. Ideally IPv6 would behave like IPv4."

This patch makes it so. Sending an oversized frame (e.g. `ping6
-s64000 -c1 ::1`) will now show up in POSTROUTING as a single skb
rather than multiple ones.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/ipv6/ip6_output.c |   49 +++++++++++++++++++++++--------------------------
 1 files changed, 23 insertions(+), 26 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 4535b7a..f314ba4 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -82,22 +82,6 @@ int ip6_local_out(struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(ip6_local_out);
 
-static int ip6_output_finish(struct sk_buff *skb)
-{
-	struct dst_entry *dst = skb_dst(skb);
-
-	if (dst->hh)
-		return neigh_hh_output(dst->hh, skb);
-	else if (dst->neighbour)
-		return dst->neighbour->output(skb);
-
-	IP6_INC_STATS_BH(dev_net(dst->dev),
-			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
-	kfree_skb(skb);
-	return -EINVAL;
-
-}
-
 /* dev_loopback_xmit for use with netfilter. */
 static int ip6_dev_loopback_xmit(struct sk_buff *newskb)
 {
@@ -111,8 +95,7 @@ static int ip6_dev_loopback_xmit(struct sk_buff *newskb)
 	return 0;
 }
 
-
-static int ip6_output2(struct sk_buff *skb)
+static int ip6_finish_output2(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *dev = dst->dev;
@@ -150,8 +133,15 @@ static int ip6_output2(struct sk_buff *skb)
 				skb->len);
 	}
 
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb, NULL, skb->dev,
-		       ip6_output_finish);
+	if (dst->hh)
+		return neigh_hh_output(dst->hh, skb);
+	else if (dst->neighbour)
+		return dst->neighbour->output(skb);
+
+	IP6_INC_STATS_BH(dev_net(dst->dev),
+			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
+	kfree_skb(skb);
+	return -EINVAL;
 }
 
 static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
@@ -162,21 +152,28 @@ static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
 	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
 }
 
+static int ip6_finish_output(struct sk_buff *skb)
+{
+	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
+				dst_allfrag(skb_dst(skb)))
+		return ip6_fragment(skb, ip6_finish_output2);
+	else
+		return ip6_finish_output2(skb);
+}
+
 int ip6_output(struct sk_buff *skb)
 {
+	struct net_device *dev = skb_dst(skb)->dev;
 	struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 	if (unlikely(idev->cnf.disable_ipv6)) {
-		IP6_INC_STATS(dev_net(skb_dst(skb)->dev), idev,
+		IP6_INC_STATS(dev_net(dev), idev,
 			      IPSTATS_MIB_OUTDISCARDS);
 		kfree_skb(skb);
 		return 0;
 	}
 
-	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
-				dst_allfrag(skb_dst(skb)))
-		return ip6_fragment(skb, ip6_output2);
-	else
-		return ip6_output2(skb);
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb, NULL, dev,
+		       ip6_finish_output);
 }
 
 /*
-- 
1.7.0.2

