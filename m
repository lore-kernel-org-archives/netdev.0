From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next v3 4/7] vxlan: improve vxlan route lookup checks.
Date: Sun, 13 Nov 2016 20:43:55 -0800
Message-ID: <1479098638-4921-5-git-send-email-pshelar@ovn.org>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:59618 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932163AbcKNEoJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 23:44:09 -0500
In-Reply-To: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move route sanity check to respective vxlan[4/6]_get_route functions.
This allows us to perform all sanity checks before caching the dst so
that we can avoid these checks on subsequent packets.
This give move accurate metadata information for packet from
fill_metadata_dst().

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 drivers/net/vxlan.c | 77 ++++++++++++++++++++++++++---------------------------
 1 file changed, 38 insertions(+), 39 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8bb58f6..aabb918 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1789,7 +1789,8 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 	return 0;
 }
 
-static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
+static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan, struct net_device *dev,
+				      struct vxlan_sock *sock4,
 				      struct sk_buff *skb, int oif, u8 tos,
 				      __be32 daddr, __be32 *saddr,
 				      struct dst_cache *dst_cache,
@@ -1799,6 +1800,9 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
 	struct rtable *rt = NULL;
 	struct flowi4 fl4;
 
+	if (!sock4)
+		return ERR_PTR(-EIO);
+
 	if (tos && !info)
 		use_cache = false;
 	if (use_cache) {
@@ -1816,16 +1820,26 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
 	fl4.saddr = *saddr;
 
 	rt = ip_route_output_key(vxlan->net, &fl4);
-	if (!IS_ERR(rt)) {
+	if (likely(!IS_ERR(rt))) {
+		if (rt->dst.dev == dev) {
+			netdev_dbg(dev, "circular route to %pI4\n", &daddr);
+			ip_rt_put(rt);
+			return ERR_PTR(-ELOOP);
+		}
+
 		*saddr = fl4.saddr;
 		if (use_cache)
 			dst_cache_set_ip4(dst_cache, &rt->dst, fl4.saddr);
+	} else {
+		netdev_dbg(dev, "no route to %pI4\n", &daddr);
+		return ERR_PTR(-ENETUNREACH);
 	}
 	return rt;
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
 static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
+					  struct net_device *dev,
 					  struct vxlan_sock *sock6,
 					  struct sk_buff *skb, int oif, u8 tos,
 					  __be32 label,
@@ -1861,8 +1875,16 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 	err = ipv6_stub->ipv6_dst_lookup(vxlan->net,
 					 sock6->sock->sk,
 					 &ndst, &fl6);
-	if (err < 0)
-		return ERR_PTR(err);
+	if (unlikely(err < 0)) {
+		netdev_dbg(dev, "no route to %pI6\n", daddr);
+		return ERR_PTR(-ENETUNREACH);
+	}
+
+	if (unlikely(ndst->dev == dev)) {
+		netdev_dbg(dev, "circular route to %pI6\n", daddr);
+		dst_release(ndst);
+		return ERR_PTR(-ELOOP);
+	}
 
 	*saddr = fl6.saddr;
 	if (use_cache)
@@ -1929,8 +1951,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	union vxlan_addr *src;
 	struct vxlan_metadata _md;
 	struct vxlan_metadata *md = &_md;
-	struct dst_entry *ndst = NULL;
 	__be16 src_port = 0, dst_port;
+	struct dst_entry *ndst = NULL;
 	__be32 vni, label;
 	__be16 df = 0;
 	__u8 tos, ttl;
@@ -2007,29 +2029,14 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		struct vxlan_sock *sock4 = rcu_dereference(vxlan->vn4_sock);
 		struct rtable *rt;
 
-		if (!sock4)
-			goto drop;
-		sk = sock4->sock->sk;
-
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
+		sk = sock4->sock->sk;
 
 		/* Bypass encapsulation if the destination is local */
 		if (!info && rt->rt_flags & RTCF_LOCAL &&
@@ -2067,27 +2074,17 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
 		u32 rt6i_flags;
 
-		ndst = vxlan6_get_route(vxlan, sock6, skb,
+		ndst = vxlan6_get_route(vxlan, dev, sock6, skb,
 					rdst ? rdst->remote_ifindex : 0, tos,
 					label, &dst->sin6.sin6_addr,
 					&src->sin6.sin6_addr,
 					dst_cache, info);
 		if (IS_ERR(ndst)) {
-			netdev_dbg(dev, "no route to %pI6\n",
-				   &dst->sin6.sin6_addr);
-			dev->stats.tx_carrier_errors++;
 			ndst = NULL;
 			goto tx_error;
 		}
-
-		if (ndst->dev == dev) {
-			netdev_dbg(dev, "circular route to %pI6\n",
-				   &dst->sin6.sin6_addr);
-			dev->stats.collisions++;
-			goto tx_error;
-		}
-
 		sk = sock6->sock->sk;
+
 		/* Bypass encapsulation if the destination is local */
 		rt6i_flags = ((struct rt6_info *)ndst)->rt6i_flags;
 		if (!info && rt6i_flags & RTF_LOCAL &&
@@ -2130,6 +2127,10 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	return;
 
 tx_error:
+	if (err == -ELOOP)
+		dev->stats.collisions++;
+	else if (err == -ENETUNREACH)
+		dev->stats.tx_carrier_errors++;
 	dst_release(ndst);
 	dev->stats.tx_errors++;
 	kfree_skb(skb);
@@ -2411,9 +2412,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 		struct vxlan_sock *sock4 = rcu_dereference(vxlan->vn4_sock);
 		struct rtable *rt;
 
-		if (!sock4)
-			return -EINVAL;
-		rt = vxlan_get_route(vxlan, skb, 0, info->key.tos,
+		rt = vxlan_get_route(vxlan, dev, sock4, skb, 0, info->key.tos,
 				     info->key.u.ipv4.dst,
 				     &info->key.u.ipv4.src, NULL, info);
 		if (IS_ERR(rt))
@@ -2424,7 +2423,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 		struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
 		struct dst_entry *ndst;
 
-		ndst = vxlan6_get_route(vxlan, sock6, skb, 0, info->key.tos,
+		ndst = vxlan6_get_route(vxlan, dev, sock6, skb, 0, info->key.tos,
 					info->key.label, &info->key.u.ipv6.dst,
 					&info->key.u.ipv6.src, NULL, info);
 		if (IS_ERR(ndst))
-- 
1.9.1
