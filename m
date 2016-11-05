From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next v2 5/7] vxlan: simplify RTF_LOCAL handling.
Date: Sat,  5 Nov 2016 11:45:55 -0700
Message-ID: <1478371557-71888-6-git-send-email-pshelar@ovn.org>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:56526 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756224AbcKESqJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Nov 2016 14:46:09 -0400
In-Reply-To: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid code duplicate code for handling RTF_LOCAL routes.

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 drivers/net/vxlan.c | 85 +++++++++++++++++++++++++++++++----------------------
 1 file changed, 50 insertions(+), 35 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f106178..838be4c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1947,6 +1947,40 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 	}
 }
 
+static int check_route_rtf_local(struct sk_buff *skb, struct net_device *dev,
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
@@ -2047,26 +2081,16 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		if (IS_ERR(rt))
 			goto tx_error;
 
-		/* Bypass encapsulation if the destination is local */
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
+			err = check_route_rtf_local(skb, dev, vxlan, dst,
+						    dst_port, vni, &rt->dst,
+						    rt->rt_flags);
+			if (err)
+				return;
 			udp_sum = !(flags & VXLAN_F_UDP_ZERO_CSUM_TX);
-		else if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT)
+		} else if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT) {
 			df = htons(IP_DF);
-
+		}
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
 		err = vxlan_build_skb(skb, &rt->dst, sizeof(struct iphdr),
@@ -2081,7 +2105,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	} else {
 		struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
 		struct dst_entry *ndst;
-		u32 rt6i_flags;
 
 		sk = sock6->sock->sk;
 
@@ -2093,24 +2116,16 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		if (IS_ERR(ndst))
 			goto tx_error;
 
-		/* Bypass encapsulation if the destination is local */
-		rt6i_flags = ((struct rt6_info *)ndst)->rt6i_flags;
-		if (!info && rt6i_flags & RTF_LOCAL &&
-		    !(rt6i_flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
-			struct vxlan_dev *dst_vxlan;
-
-			dst_release(ndst);
-			dst_vxlan = vxlan_find_vni(vxlan->net, vni,
-						   dst->sa.sa_family, dst_port,
-						   vxlan->flags);
-			if (!dst_vxlan)
-				goto tx_error;
-			vxlan_encap_bypass(skb, vxlan, dst_vxlan);
-			return;
-		}
+		if (!info) {
+			u32 rt6i_flags = ((struct rt6_info *)ndst)->rt6i_flags;
 
-		if (!info)
+			err = check_route_rtf_local(skb, dev, vxlan, dst,
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
