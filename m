From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next v3 6/7] vxlan: simplify vxlan xmit
Date: Sun, 13 Nov 2016 20:43:57 -0800
Message-ID: <1479098638-4921-7-git-send-email-pshelar@ovn.org>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:56839 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932546AbcKNEoL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 23:44:11 -0500
In-Reply-To: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Existing vxlan xmit function handles two distinct cases.
1. vxlan net device
2. vxlan lwt device.
By seperating initialization these two cases the egress path
looks better.

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
Acked-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 78 +++++++++++++++++++++++------------------------------
 1 file changed, 34 insertions(+), 44 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 0b188d6..411534c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1978,8 +1978,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct dst_cache *dst_cache;
 	struct ip_tunnel_info *info;
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct sock *sk;
-	const struct iphdr *old_iph;
+	const struct iphdr *old_iph = ip_hdr(skb);
 	union vxlan_addr *dst;
 	union vxlan_addr remote_ip, local_ip;
 	union vxlan_addr *src;
@@ -1988,7 +1987,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	__be16 src_port = 0, dst_port;
 	struct dst_entry *ndst = NULL;
 	__be32 vni, label;
-	__be16 df = 0;
 	__u8 tos, ttl;
 	int err;
 	u32 flags = vxlan->flags;
@@ -1998,19 +1996,40 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	info = skb_tunnel_info(skb);
 
 	if (rdst) {
+		dst = &rdst->remote_ip;
+		if (vxlan_addr_any(dst)) {
+			if (did_rsc) {
+				/* short-circuited back to local bridge */
+				vxlan_encap_bypass(skb, vxlan, vxlan);
+				return;
+			}
+			goto drop;
+		}
+
 		dst_port = rdst->remote_port ? rdst->remote_port : vxlan->cfg.dst_port;
 		vni = rdst->remote_vni;
-		dst = &rdst->remote_ip;
 		src = &vxlan->cfg.saddr;
 		dst_cache = &rdst->dst_cache;
+		md->gbp = skb->mark;
+		ttl = vxlan->cfg.ttl;
+		if (!ttl && vxlan_addr_multicast(dst))
+			ttl = 1;
+
+		tos = vxlan->cfg.tos;
+		if (tos == 1)
+			tos = ip_tunnel_get_dsfield(old_iph, skb);
+
+		if (dst->sa.sa_family == AF_INET)
+			udp_sum = !(flags & VXLAN_F_UDP_ZERO_CSUM_TX);
+		else
+			udp_sum = !(flags & VXLAN_F_UDP_ZERO_CSUM6_TX);
+		label = vxlan->cfg.label;
 	} else {
 		if (!info) {
 			WARN_ONCE(1, "%s: Missing encapsulation instructions\n",
 				  dev->name);
 			goto drop;
 		}
-		dst_port = info->key.tp_dst ? : vxlan->cfg.dst_port;
-		vni = tunnel_id_to_key32(info->key.tun_id);
 		remote_ip.sa.sa_family = ip_tunnel_info_af(info);
 		if (remote_ip.sa.sa_family == AF_INET) {
 			remote_ip.sin.sin_addr.s_addr = info->key.u.ipv4.dst;
@@ -2020,48 +2039,24 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			local_ip.sin6.sin6_addr = info->key.u.ipv6.src;
 		}
 		dst = &remote_ip;
+		dst_port = info->key.tp_dst ? : vxlan->cfg.dst_port;
+		vni = tunnel_id_to_key32(info->key.tun_id);
 		src = &local_ip;
 		dst_cache = &info->dst_cache;
-	}
-
-	if (vxlan_addr_any(dst)) {
-		if (did_rsc) {
-			/* short-circuited back to local bridge */
-			vxlan_encap_bypass(skb, vxlan, vxlan);
-			return;
-		}
-		goto drop;
-	}
-
-	old_iph = ip_hdr(skb);
-
-	ttl = vxlan->cfg.ttl;
-	if (!ttl && vxlan_addr_multicast(dst))
-		ttl = 1;
-
-	tos = vxlan->cfg.tos;
-	if (tos == 1)
-		tos = ip_tunnel_get_dsfield(old_iph, skb);
-
-	label = vxlan->cfg.label;
-	src_port = udp_flow_src_port(dev_net(dev), skb, vxlan->cfg.port_min,
-				     vxlan->cfg.port_max, true);
-
-	if (info) {
+		if (info->options_len)
+			md = ip_tunnel_info_opts(info);
 		ttl = info->key.ttl;
 		tos = info->key.tos;
 		label = info->key.label;
 		udp_sum = !!(info->key.tun_flags & TUNNEL_CSUM);
-
-		if (info->options_len)
-			md = ip_tunnel_info_opts(info);
-	} else {
-		md->gbp = skb->mark;
 	}
+	src_port = udp_flow_src_port(dev_net(dev), skb, vxlan->cfg.port_min,
+				     vxlan->cfg.port_max, true);
 
 	if (dst->sa.sa_family == AF_INET) {
 		struct vxlan_sock *sock4 = rcu_dereference(vxlan->vn4_sock);
 		struct rtable *rt;
+		__be16 df = 0;
 
 		rt = vxlan_get_route(vxlan, dev, sock4, skb,
 				     rdst ? rdst->remote_ifindex : 0, tos,
@@ -2071,7 +2066,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		if (IS_ERR(rt))
 			goto tx_error;
 
-		sk = sock4->sock->sk;
 		/* Bypass encapsulation if the destination is local */
 		if (!info) {
 			err = encap_bypass_if_local(skb, dev, vxlan, dst,
@@ -2079,7 +2073,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 						    rt->rt_flags);
 			if (err)
 				return;
-			udp_sum = !(flags & VXLAN_F_UDP_ZERO_CSUM_TX);
 		} else if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT) {
 			df = htons(IP_DF);
 		}
@@ -2092,7 +2085,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		if (err < 0)
 			goto tx_error;
 
-		udp_tunnel_xmit_skb(rt, sk, skb, src->sin.sin_addr.s_addr,
+		udp_tunnel_xmit_skb(rt, sock4->sock->sk, skb, src->sin.sin_addr.s_addr,
 				    dst->sin.sin_addr.s_addr, tos, ttl, df,
 				    src_port, dst_port, xnet, !udp_sum);
 #if IS_ENABLED(CONFIG_IPV6)
@@ -2108,7 +2101,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			ndst = NULL;
 			goto tx_error;
 		}
-		sk = sock6->sock->sk;
 
 		if (!info) {
 			u32 rt6i_flags = ((struct rt6_info *)ndst)->rt6i_flags;
@@ -2118,7 +2110,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 						    rt6i_flags);
 			if (err)
 				return;
-			udp_sum = !(flags & VXLAN_F_UDP_ZERO_CSUM6_TX);
 		}
 
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
@@ -2129,13 +2120,12 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		if (err < 0)
 			goto tx_error;
 
-		udp_tunnel6_xmit_skb(ndst, sk, skb, dev,
+		udp_tunnel6_xmit_skb(ndst, sock6->sock->sk, skb, dev,
 				     &src->sin6.sin6_addr,
 				     &dst->sin6.sin6_addr, tos, ttl,
 				     label, src_port, dst_port, !udp_sum);
 #endif
 	}
-
 	return;
 
 drop:
-- 
1.9.1
