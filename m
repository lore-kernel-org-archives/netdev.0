From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next v3 3/7] vxlan: simplify exception handling
Date: Sun, 13 Nov 2016 20:43:54 -0800
Message-ID: <1479098638-4921-4-git-send-email-pshelar@ovn.org>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:56839 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754285AbcKNEoJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 23:44:09 -0500
In-Reply-To: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vxlan egress path error handling has became complicated, it
need to handle IPv4 and IPv6 tunnel cases.
Earlier patch removes vlan handling from vxlan_build_skb(), so
vxlan_build_skb does not need to free skb and we can simplify
the xmit path by having single error handling for both type of
tunnels.

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 drivers/net/vxlan.c | 46 +++++++++++++++++++---------------------------
 1 file changed, 19 insertions(+), 27 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9adeff9..8bb58f6 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1753,11 +1753,11 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 	/* Need space for new headers (invalidates iph ptr) */
 	err = skb_cow_head(skb, min_headroom);
 	if (unlikely(err))
-		goto out_free;
+		return err;
 
 	err = iptunnel_handle_offloads(skb, type);
 	if (err)
-		goto out_free;
+		return err;
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = VXLAN_HF_VNI;
@@ -1781,16 +1781,12 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 	if (vxflags & VXLAN_F_GPE) {
 		err = vxlan_build_gpe_hdr(vxh, vxflags, skb->protocol);
 		if (err < 0)
-			goto out_free;
+			return err;
 		inner_protocol = skb->protocol;
 	}
 
 	skb_set_inner_protocol(skb, inner_protocol);
 	return 0;
-
-out_free:
-	kfree_skb(skb);
-	return err;
 }
 
 static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
@@ -1927,13 +1923,13 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct ip_tunnel_info *info;
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct sock *sk;
-	struct rtable *rt = NULL;
 	const struct iphdr *old_iph;
 	union vxlan_addr *dst;
 	union vxlan_addr remote_ip, local_ip;
 	union vxlan_addr *src;
 	struct vxlan_metadata _md;
 	struct vxlan_metadata *md = &_md;
+	struct dst_entry *ndst = NULL;
 	__be16 src_port = 0, dst_port;
 	__be32 vni, label;
 	__be16 df = 0;
@@ -2009,6 +2005,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 	if (dst->sa.sa_family == AF_INET) {
 		struct vxlan_sock *sock4 = rcu_dereference(vxlan->vn4_sock);
+		struct rtable *rt;
 
 		if (!sock4)
 			goto drop;
@@ -2030,7 +2027,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			netdev_dbg(dev, "circular route to %pI4\n",
 				   &dst->sin.sin_addr.s_addr);
 			dev->stats.collisions++;
-			goto rt_tx_error;
+			ip_rt_put(rt);
+			goto tx_error;
 		}
 
 		/* Bypass encapsulation if the destination is local */
@@ -2053,12 +2051,13 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		else if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT)
 			df = htons(IP_DF);
 
+		ndst = &rt->dst;
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
-		err = vxlan_build_skb(skb, &rt->dst, sizeof(struct iphdr),
+		err = vxlan_build_skb(skb, ndst, sizeof(struct iphdr),
 				      vni, md, flags, udp_sum);
 		if (err < 0)
-			goto xmit_tx_error;
+			goto tx_error;
 
 		udp_tunnel_xmit_skb(rt, sk, skb, src->sin.sin_addr.s_addr,
 				    dst->sin.sin_addr.s_addr, tos, ttl, df,
@@ -2066,7 +2065,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
 		struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
-		struct dst_entry *ndst;
 		u32 rt6i_flags;
 
 		ndst = vxlan6_get_route(vxlan, sock6, skb,
@@ -2078,13 +2076,13 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			netdev_dbg(dev, "no route to %pI6\n",
 				   &dst->sin6.sin6_addr);
 			dev->stats.tx_carrier_errors++;
+			ndst = NULL;
 			goto tx_error;
 		}
 
 		if (ndst->dev == dev) {
 			netdev_dbg(dev, "circular route to %pI6\n",
 				   &dst->sin6.sin6_addr);
-			dst_release(ndst);
 			dev->stats.collisions++;
 			goto tx_error;
 		}
@@ -2096,12 +2094,12 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		    !(rt6i_flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
 			struct vxlan_dev *dst_vxlan;
 
-			dst_release(ndst);
 			dst_vxlan = vxlan_find_vni(vxlan->net, vni,
 						   dst->sa.sa_family, dst_port,
 						   vxlan->flags);
 			if (!dst_vxlan)
 				goto tx_error;
+			dst_release(ndst);
 			vxlan_encap_bypass(skb, vxlan, dst_vxlan);
 			return;
 		}
@@ -2114,11 +2112,9 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		skb_scrub_packet(skb, xnet);
 		err = vxlan_build_skb(skb, ndst, sizeof(struct ipv6hdr),
 				      vni, md, flags, udp_sum);
-		if (err < 0) {
-			dst_release(ndst);
-			dev->stats.tx_errors++;
-			return;
-		}
+		if (err < 0)
+			goto tx_error;
+
 		udp_tunnel6_xmit_skb(ndst, sk, skb, dev,
 				     &src->sin6.sin6_addr,
 				     &dst->sin6.sin6_addr, tos, ttl,
@@ -2130,17 +2126,13 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 drop:
 	dev->stats.tx_dropped++;
-	goto tx_free;
+	dev_kfree_skb(skb);
+	return;
 
-xmit_tx_error:
-	/* skb is already freed. */
-	skb = NULL;
-rt_tx_error:
-	ip_rt_put(rt);
 tx_error:
+	dst_release(ndst);
 	dev->stats.tx_errors++;
-tx_free:
-	dev_kfree_skb(skb);
+	kfree_skb(skb);
 }
 
 /* Transmit local packets over Vxlan
-- 
1.9.1
