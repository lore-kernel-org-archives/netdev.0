From: David Miller <davem@davemloft.net>
Subject: [PATCH 02/16] ipv4: Kill ip_route_input_noref().
Date: Thu, 19 Jul 2012 14:34:23 -0700 (PDT)
Message-ID: <20120719.143423.187928336972748201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763Ab2GSVeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 17:34:24 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id D5E105845A0
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 14:34:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The "noref" argument to ip_route_input_common() is now always ignored
because we do not cache routes, and in that case we must always grab
a reference to the resulting 'dst'.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h    |   16 ++--------------
 net/ipv4/arp.c         |    2 +-
 net/ipv4/ip_fragment.c |    4 ++--
 net/ipv4/ip_input.c    |    4 ++--
 net/ipv4/route.c       |    6 +++---
 net/ipv4/xfrm4_input.c |    4 ++--
 6 files changed, 12 insertions(+), 24 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 5dcfeb6..5c86c47 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -160,20 +160,8 @@ static inline struct rtable *ip_route_output_gre(struct net *net, struct flowi4
 	return ip_route_output_key(net, fl4);
 }
 
-extern int ip_route_input_common(struct sk_buff *skb, __be32 dst, __be32 src,
-				 u8 tos, struct net_device *devin, bool noref);
-
-static inline int ip_route_input(struct sk_buff *skb, __be32 dst, __be32 src,
-				 u8 tos, struct net_device *devin)
-{
-	return ip_route_input_common(skb, dst, src, tos, devin, false);
-}
-
-static inline int ip_route_input_noref(struct sk_buff *skb, __be32 dst, __be32 src,
-				       u8 tos, struct net_device *devin)
-{
-	return ip_route_input_common(skb, dst, src, tos, devin, true);
-}
+extern int ip_route_input(struct sk_buff *skb, __be32 dst, __be32 src,
+			  u8 tos, struct net_device *devin);
 
 extern void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
 			     int oif, u32 mark, u8 protocol, int flow_flags);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 2e560f0..c38293f 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -828,7 +828,7 @@ static int arp_process(struct sk_buff *skb)
 	}
 
 	if (arp->ar_op == htons(ARPOP_REQUEST) &&
-	    ip_route_input_noref(skb, tip, sip, 0, dev) == 0) {
+	    ip_route_input(skb, tip, sip, 0, dev) == 0) {
 
 		rt = skb_rtable(skb);
 		addr_type = rt->rt_type;
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 8d07c97..7ad88e5 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -258,8 +258,8 @@ static void ip_expire(unsigned long arg)
 		/* skb dst is stale, drop it, and perform route lookup again */
 		skb_dst_drop(head);
 		iph = ip_hdr(head);
-		err = ip_route_input_noref(head, iph->daddr, iph->saddr,
-					   iph->tos, head->dev);
+		err = ip_route_input(head, iph->daddr, iph->saddr,
+				     iph->tos, head->dev);
 		if (err)
 			goto out_rcu_unlock;
 
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index b27d444..4ebc6fe 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -336,8 +336,8 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	 *	how the packet travels inside Linux networking.
 	 */
 	if (!skb_dst(skb)) {
-		int err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
-					       iph->tos, skb->dev);
+		int err = ip_route_input(skb, iph->daddr, iph->saddr,
+					 iph->tos, skb->dev);
 		if (unlikely(err)) {
 			if (err == -EXDEV)
 				NET_INC_STATS_BH(dev_net(skb->dev),
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f35d0f0..ba628e6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1620,8 +1620,8 @@ martian_source_keep_err:
 	goto out;
 }
 
-int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-			   u8 tos, struct net_device *dev, bool noref)
+int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
+		   u8 tos, struct net_device *dev)
 {
 	int res;
 
@@ -1664,7 +1664,7 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rcu_read_unlock();
 	return res;
 }
-EXPORT_SYMBOL(ip_route_input_common);
+EXPORT_SYMBOL(ip_route_input);
 
 /* called with rcu_read_lock() */
 static struct rtable *__mkroute_output(const struct fib_result *res,
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 06814b6..58d23a5 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -27,8 +27,8 @@ static inline int xfrm4_rcv_encap_finish(struct sk_buff *skb)
 	if (skb_dst(skb) == NULL) {
 		const struct iphdr *iph = ip_hdr(skb);
 
-		if (ip_route_input_noref(skb, iph->daddr, iph->saddr,
-					 iph->tos, skb->dev))
+		if (ip_route_input(skb, iph->daddr, iph->saddr,
+				   iph->tos, skb->dev))
 			goto drop;
 	}
 	return dst_input(skb);
-- 
1.7.10.4
