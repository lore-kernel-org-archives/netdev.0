From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/5] ipv4: Kill ip_route_input_noref().
Date: Mon, 11 Jul 2011 22:30:06 -0700 (PDT)
Message-ID: <20110711.223006.647272414141627558.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752678Ab1GLFaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 01:30:07 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6C5U6Ru030538
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 22:30:07 -0700
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
index 8861144..34c9bc5 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -165,20 +165,8 @@ static inline struct rtable *ip_route_output_gre(struct net *net, struct flowi4
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
 
 extern unsigned short	ip_rt_frag_needed(struct net *net, const struct iphdr *iph,
 					  unsigned short new_mtu, struct net_device *dev);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 1b74d3b..ef44a91 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -875,7 +875,7 @@ static int arp_process(struct sk_buff *skb)
 	}
 
 	if (arp->ar_op == htons(ARPOP_REQUEST) &&
-	    ip_route_input_noref(skb, tip, sip, 0, dev) == 0) {
+	    ip_route_input(skb, tip, sip, 0, dev) == 0) {
 
 		rt = skb_rtable(skb);
 		addr_type = rt->rt_type;
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 0e0ab98..a77b8b1 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -252,8 +252,8 @@ static void ip_expire(unsigned long arg)
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
index 073a9b0..ee753c3 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -324,8 +324,8 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	 *	how the packet travels inside Linux networking.
 	 */
 	if (skb_dst(skb) == NULL) {
-		int err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
-					       iph->tos, skb->dev);
+		int err = ip_route_input(skb, iph->daddr, iph->saddr,
+					 iph->tos, skb->dev);
 		if (unlikely(err)) {
 			if (err == -EHOSTUNREACH)
 				IP_INC_STATS_BH(dev_net(skb->dev),
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c935853..3ecef57 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1548,8 +1548,8 @@ martian_source_keep_err:
 	goto out;
 }
 
-int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-			   u8 tos, struct net_device *dev, bool noref)
+int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
+		   u8 tos, struct net_device *dev)
 {
 	int res;
 
@@ -1592,7 +1592,7 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
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
1.7.5.4

