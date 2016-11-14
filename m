From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next v3 5/7] vxlan: simplify RTF_LOCAL handling.
Date: Sun, 13 Nov 2016 20:43:56 -0800
Message-ID: <1479098638-4921-6-git-send-email-pshelar@ovn.org>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:47760 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932222AbcKNEoK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 23:44:10 -0500
In-Reply-To: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid code duplicate code for handling RTF_LOCAL routes.

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 drivers/net/vxlan.c | 85 ++++++++++++++++++++++++++++++++---------------------
 1 file changed, 51 insertions(+), 34 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index aabb918..0b188d6 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1938,6 +1938,40 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 	}
 }
 
+static int encap_bypass_if_local(struct sk_buff *skb, struct net_device *dev,
+				 struct vxlan_dev *vxlan, union vxlan_addr *daddr,
+				 __be32 dst_port, __be32 vni, struct dst_entry *dst,
+				 u32 rt_flags)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	/* IPv6 rt-flags are checked against RTF_LOCAL, but the value of
+	 * RTF_LOCAL is equal to RTCF_LOCAL. So to keep code simple
+	 * we can use RTCF_LOCAL which works for ipv4 and ipv6 route entry.
+	 */
+	BUILD_BUG_ON(RTCF_LOCAL != RTF_LOCAL);
+#endif
+	/* Bypass encapsulation if the destination is local */
+	if (rt_flags & RTCF_LOCAL &&
+	    !(rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
+		struct vxlan_dev *dst_vxlan;
+
+		dst_release(dst);
+		dst_vxlan = vxlan_find_vni(vxlan->net, vni,
+					   daddr->sa.sa_family, dst_port,
+					   vxlan->flags);
+		if (!dst_vxlan) {
+			dev->stats.tx_errors++;
+			kfree_skb(skb);
+
+			return -ENOENT;
+		}
+		vxlan_encap_bypass(skb, vxlan, dst_vxlan);
+		return 1;
+	}
+
+	return 0;
+}
+
 static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			   struct vxlan_rdst *rdst, bool did_rsc)
 {
@@ -2036,27 +2070,19 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				     dst_cache, info);
 		if (IS_ERR(rt))
 			goto tx_error;
-		sk = sock4->sock->sk;
 
+		sk = sock4->sock->sk;
 		/* Bypass encapsulation if the destination is local */
-		if (!info && rt->rt_flags & RTCF_LOCAL &&
-		    !(rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
-			struct vxlan_dev *dst_vxlan;
-
-			ip_rt_put(rt);
-			dst_vxlan = vxlan_find_vni(vxlan->net, vni,
-						   dst->sa.sa_family, dst_port,
-						   vxlan->flags);
-			if (!dst_vxlan)
-				goto tx_error;
-			vxlan_encap_bypass(skb, vxlan, dst_vxlan);
-			return;
-		}
-
-		if (!info)
+		if (!info) {
+			err = encap_bypass_if_local(skb, dev, vxlan, dst,
+						    dst_port, vni, &rt->dst,
+						    rt->rt_flags);
+			if (err)
+				return;
 			udp_sum = !(flags & VXLAN_F_UDP_ZERO_CSUM_TX);
-		else if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT)
+		} else if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT) {
 			df = htons(IP_DF);
+		}
 
 		ndst = &rt->dst;
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
@@ -2072,7 +2098,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
 		struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
-		u32 rt6i_flags;
 
 		ndst = vxlan6_get_route(vxlan, dev, sock6, skb,
 					rdst ? rdst->remote_ifindex : 0, tos,
@@ -2085,24 +2110,16 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		}
 		sk = sock6->sock->sk;
 
-		/* Bypass encapsulation if the destination is local */
-		rt6i_flags = ((struct rt6_info *)ndst)->rt6i_flags;
-		if (!info && rt6i_flags & RTF_LOCAL &&
-		    !(rt6i_flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
-			struct vxlan_dev *dst_vxlan;
-
-			dst_vxlan = vxlan_find_vni(vxlan->net, vni,
-						   dst->sa.sa_family, dst_port,
-						   vxlan->flags);
-			if (!dst_vxlan)
-				goto tx_error;
-			dst_release(ndst);
-			vxlan_encap_bypass(skb, vxlan, dst_vxlan);
-			return;
-		}
+		if (!info) {
+			u32 rt6i_flags = ((struct rt6_info *)ndst)->rt6i_flags;
 
-		if (!info)
+			err = encap_bypass_if_local(skb, dev, vxlan, dst,
+						    dst_port, vni, ndst,
+						    rt6i_flags);
+			if (err)
+				return;
 			udp_sum = !(flags & VXLAN_F_UDP_ZERO_CSUM6_TX);
+		}
 
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip6_dst_hoplimit(ndst);
-- 
1.9.1
