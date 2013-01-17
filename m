From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next (V4) 10/11] ipv6: Do not depend on rt->n in ip6_finish_output2().
Date: Fri, 18 Jan 2013 07:54:00 +0900
Message-ID: <50F88108.3020401@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:44784 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752229Ab3AQWyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 17:54:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If neigh is not found, create new one.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ip6_output.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 7c00edb..b0895f5 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -88,7 +88,8 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *dev = dst->dev;
 	struct neighbour *neigh;
-	struct rt6_info *rt;
+	struct in6_addr *nexthop;
+	int ret;
 
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->dev = dev;
@@ -123,10 +124,17 @@ static int ip6_finish_output2(struct sk_buff *skb)
 				skb->len);
 	}
 
-	rt = (struct rt6_info *) dst;
-	neigh = rt->n;
-	if (neigh)
-		return dst_neigh_output(dst, neigh, skb);
+	rcu_read_lock_bh();
+	nexthop = rt6_nexthop((struct rt6_info *)dst, &ipv6_hdr(skb)->daddr);
+	neigh = __ipv6_neigh_lookup_noref(dst->dev, nexthop);
+	if (unlikely(!neigh))
+		neigh = __neigh_create(&nd_tbl, nexthop, dst->dev, false);
+	if (!IS_ERR(neigh)) {
+		ret = dst_neigh_output(dst, neigh, skb);
+		rcu_read_unlock_bh();
+		return ret;
+	}
+	rcu_read_unlock_bh();
 
 	IP6_INC_STATS_BH(dev_net(dst->dev),
 			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
-- 
1.7.9.5
