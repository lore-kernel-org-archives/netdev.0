From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next 4/7] vxlan: improve vxlan route lookup checks.
Date: Fri,  4 Nov 2016 13:51:53 -0700
Message-ID: <1478292716-54649-5-git-send-email-pshelar@ovn.org>
References: <1478292716-54649-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:46663 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758698AbcKDUwG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 16:52:06 -0400
In-Reply-To: <1478292716-54649-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move route sanity check to respective vxlan[4/6]_get_route functions.
This allows us to perform all sanity checks before caching the dst so
that we can avoid these checks on subsequent packets.
This give move accurate metadata information for packet from
fill_metadata_dst().

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 drivers/net/vxlan.c | 71 +++++++++++++++++++++++++----------------------------
 1 file changed, 34 insertions(+), 37 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6435d6a..15319f1 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1793,7 +1793,8 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 	return err;
 }
 
-static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
+static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan, struct net_device *dev,
+				      struct vxlan_sock *sock4,
 				      struct sk_buff *skb, int oif, u8 tos,
 				      __be32 daddr, __be32 *saddr,
 				      struct dst_cache *dst_cache,
@@ -1803,6 +1804,9 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
 	struct rtable *rt = NULL;
 	struct flowi4 fl4;
 
+	if (!sock4)
+		return ERR_PTR(-EIO);
+
 	if (tos && !info)
 		use_cache = false;
 	if (use_cache) {
@@ -1820,16 +1824,27 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
 	fl4.saddr = *saddr;
 
 	rt = ip_route_output_key(vxlan->net, &fl4);
-	if (!IS_ERR(rt)) {
+	if (likely(!IS_ERR(rt))) {
+		if (rt->dst.dev == dev) {
+			netdev_dbg(dev, "circular route to %pI4\n", &daddr);
+			dev->stats.collisions++;
+			ip_rt_put(rt);
+			return ERR_PTR(-ELOOP);
+		}
+
 		*saddr = fl4.saddr;
 		if (use_cache)
 			dst_cache_set_ip4(dst_cache, &rt->dst, fl4.saddr);
+	} else {
+		netdev_dbg(dev, "no route to %pI4\n", &daddr);
+		dev->stats.tx_carrier_errors++;
 	}
 	return rt;
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
 static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
+					  struct net_device *dev,
 					  struct vxlan_sock *sock6,
 					  struct sk_buff *skb, int oif, u8 tos,
 					  __be32 label,
@@ -1865,8 +1880,18 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 	err = ipv6_stub->ipv6_dst_lookup(vxlan->net,
 					 sock6->sock->sk,
 					 &ndst, &fl6);
-	if (err < 0)
+	if (unlikely(err < 0)) {
+		netdev_dbg(dev, "no route to %pI6\n", daddr);
+		dev->stats.tx_carrier_errors++;
 		return ERR_PTR(err);
+	}
+
+	if (unlikely(ndst->dev == dev)) {
+		netdev_dbg(dev, "circular route to %pI6\n", daddr);
+		dst_release(ndst);
+		dev->stats.collisions++;
+		return ERR_PTR(-ELOOP);
+	}
 
 	*saddr = fl6.saddr;
 	if (use_cache)
@@ -2010,29 +2035,15 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		struct vxlan_sock *sock4 = rcu_dereference(vxlan->vn4_sock);
 		struct rtable *rt;
 
-		if (!sock4)
-			goto drop;
 		sk = sock4->sock->sk;
 
-		rt = vxlan_get_route(vxlan, skb,
+		rt = vxlan_get_route(vxlan, dev, sock4, skb,
 				     rdst ? rdst->remote_ifindex : 0, tos,
 				     dst->sin.sin_addr.s_addr,
 				     &src->sin.sin_addr.s_addr,
 				     dst_cache, info);
-		if (IS_ERR(rt)) {
-			netdev_dbg(dev, "no route to %pI4\n",
-				   &dst->sin.sin_addr.s_addr);
-			dev->stats.tx_carrier_errors++;
-			goto tx_error;
-		}
-
-		if (rt->dst.dev == dev) {
-			netdev_dbg(dev, "circular route to %pI4\n",
-				   &dst->sin.sin_addr.s_addr);
-			dev->stats.collisions++;
-			ip_rt_put(rt);
+		if (IS_ERR(rt))
 			goto tx_error;
-		}
 
 		/* Bypass encapsulation if the destination is local */
 		if (!info && rt->rt_flags & RTCF_LOCAL &&
@@ -2072,25 +2083,13 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		sk = sock6->sock->sk;
 
-		ndst = vxlan6_get_route(vxlan, sock6, skb,
+		ndst = vxlan6_get_route(vxlan, dev, sock6, skb,
 					rdst ? rdst->remote_ifindex : 0, tos,
 					label, &dst->sin6.sin6_addr,
 					&src->sin6.sin6_addr,
 					dst_cache, info);
-		if (IS_ERR(ndst)) {
-			netdev_dbg(dev, "no route to %pI6\n",
-				   &dst->sin6.sin6_addr);
-			dev->stats.tx_carrier_errors++;
-			goto tx_error;
-		}
-
-		if (ndst->dev == dev) {
-			netdev_dbg(dev, "circular route to %pI6\n",
-				   &dst->sin6.sin6_addr);
-			dst_release(ndst);
-			dev->stats.collisions++;
+		if (IS_ERR(ndst))
 			goto tx_error;
-		}
 
 		/* Bypass encapsulation if the destination is local */
 		rt6i_flags = ((struct rt6_info *)ndst)->rt6i_flags;
@@ -2414,9 +2413,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 		struct vxlan_sock *sock4 = rcu_dereference(vxlan->vn4_sock);
 		struct rtable *rt;
 
-		if (!sock4)
-			return -EINVAL;
-		rt = vxlan_get_route(vxlan, skb, 0, info->key.tos,
+		rt = vxlan_get_route(vxlan, dev, sock4, skb, 0, info->key.tos,
 				     info->key.u.ipv4.dst,
 				     &info->key.u.ipv4.src, NULL, info);
 		if (IS_ERR(rt))
@@ -2427,7 +2424,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 		struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
 		struct dst_entry *ndst;
 
-		ndst = vxlan6_get_route(vxlan, sock6, skb, 0, info->key.tos,
+		ndst = vxlan6_get_route(vxlan, dev, sock6, skb, 0, info->key.tos,
 					info->key.label, &info->key.u.ipv6.dst,
 					&info->key.u.ipv6.src, NULL, info);
 		if (IS_ERR(ndst))
-- 
1.9.1
