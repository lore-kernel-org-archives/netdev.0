From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next v3 2/7] vxlan: avoid checking socket multiple times.
Date: Sun, 13 Nov 2016 20:43:53 -0800
Message-ID: <1479098638-4921-3-git-send-email-pshelar@ovn.org>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:47760 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751201AbcKNEoH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 23:44:07 -0500
In-Reply-To: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check the vxlan socket in vxlan6_getroute().

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 drivers/net/vxlan.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 756d826..9adeff9 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1830,6 +1830,7 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
 
 #if IS_ENABLED(CONFIG_IPV6)
 static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
+					  struct vxlan_sock *sock6,
 					  struct sk_buff *skb, int oif, u8 tos,
 					  __be32 label,
 					  const struct in6_addr *daddr,
@@ -1837,7 +1838,6 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 					  struct dst_cache *dst_cache,
 					  const struct ip_tunnel_info *info)
 {
-	struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
 	bool use_cache = ip_tunnel_dst_cache_usable(skb, info);
 	struct dst_entry *ndst;
 	struct flowi6 fl6;
@@ -2069,11 +2069,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		struct dst_entry *ndst;
 		u32 rt6i_flags;
 
-		if (!sock6)
-			goto drop;
-		sk = sock6->sock->sk;
-
-		ndst = vxlan6_get_route(vxlan, skb,
+		ndst = vxlan6_get_route(vxlan, sock6, skb,
 					rdst ? rdst->remote_ifindex : 0, tos,
 					label, &dst->sin6.sin6_addr,
 					&src->sin6.sin6_addr,
@@ -2093,6 +2089,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			goto tx_error;
 		}
 
+		sk = sock6->sock->sk;
 		/* Bypass encapsulation if the destination is local */
 		rt6i_flags = ((struct rt6_info *)ndst)->rt6i_flags;
 		if (!info && rt6i_flags & RTF_LOCAL &&
@@ -2432,9 +2429,10 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 		ip_rt_put(rt);
 	} else {
 #if IS_ENABLED(CONFIG_IPV6)
+		struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
 		struct dst_entry *ndst;
 
-		ndst = vxlan6_get_route(vxlan, skb, 0, info->key.tos,
+		ndst = vxlan6_get_route(vxlan, sock6, skb, 0, info->key.tos,
 					info->key.label, &info->key.u.ipv6.dst,
 					&info->key.u.ipv6.src, NULL, info);
 		if (IS_ERR(ndst))
-- 
1.9.1
