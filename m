From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next v2 6/7] vxlan: simplify vxlan xmit
Date: Sat,  5 Nov 2016 11:45:56 -0700
Message-ID: <1478371557-71888-7-git-send-email-pshelar@ovn.org>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:33333 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756288AbcKESqK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Nov 2016 14:46:10 -0400
In-Reply-To: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Existing vxlan xmit function handles two distinct cases.
1. vxlan net device
2. vxlan lwt device.
By seperating initilization these two cases the egress path
looks better.

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 drivers/net/vxlan.c | 79 ++++++++++++++++++++++++-----------------------------
 1 file changed, 35 insertions(+), 44 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 838be4c..db6e012 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1987,8 +1987,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct dst_cache *dst_cache;
 	struct ip_tunnel_info *info;
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct sock *sk;
-	const struct iphdr *old_iph;
+	const struct iphdr *old_iph = ip_hdr(skb);
 	union vxlan_addr *dst;
 	union vxlan_addr remote_ip, local_ip;
 	union vxlan_addr *src;
@@ -1996,7 +1995,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct vxlan_metadata *md = &_md;
 	__be16 src_port = 0, dst_port;
 	__be32 vni, label;
-	__be16 df = 0;
 	__u8 tos, ttl;
 	int err;
 	u32 flags = vxlan->flags;
@@ -2006,11 +2004,34 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
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
@@ -2030,32 +2051,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		dst = &remote_ip;
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
 		ttl = info->key.ttl;
 		tos = info->key.tos;
 		label = info->key.label;
@@ -2063,15 +2058,15 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		if (info->options_len)
 			md = ip_tunnel_info_opts(info);
-	} else {
-		md->gbp = skb->mark;
 	}
 
+	src_port = udp_flow_src_port(dev_net(dev), skb, vxlan->cfg.port_min,
+				     vxlan->cfg.port_max, true);
+
 	if (dst->sa.sa_family == AF_INET) {
 		struct vxlan_sock *sock4 = rcu_dereference(vxlan->vn4_sock);
 		struct rtable *rt;
-
-		sk = sock4->sock->sk;
+		__be16 df = 0;
 
 		rt = vxlan_get_route(vxlan, dev, sock4, skb,
 				     rdst ? rdst->remote_ifindex : 0, tos,
@@ -2087,18 +2082,17 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 						    rt->rt_flags);
 			if (err)
 				return;
-			udp_sum = !(flags & VXLAN_F_UDP_ZERO_CSUM_TX);
 		} else if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT) {
 			df = htons(IP_DF);
 		}
-		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
-		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
 		err = vxlan_build_skb(skb, &rt->dst, sizeof(struct iphdr),
 				      vni, md, flags, udp_sum);
 		if (err < 0)
 			goto tx_error;
 
-		udp_tunnel_xmit_skb(rt, sk, skb, src->sin.sin_addr.s_addr,
+		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
+		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
+		udp_tunnel_xmit_skb(rt, sock4->sock->sk, skb, src->sin.sin_addr.s_addr,
 				    dst->sin.sin_addr.s_addr, tos, ttl, df,
 				    src_port, dst_port, xnet, !udp_sum);
 #if IS_ENABLED(CONFIG_IPV6)
@@ -2106,8 +2100,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
 		struct dst_entry *ndst;
 
-		sk = sock6->sock->sk;
-
 		ndst = vxlan6_get_route(vxlan, dev, sock6, skb,
 					rdst ? rdst->remote_ifindex : 0, tos,
 					label, &dst->sin6.sin6_addr,
@@ -2124,18 +2116,17 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 						    rt6i_flags);
 			if (err)
 				return;
-			udp_sum = !(flags & VXLAN_F_UDP_ZERO_CSUM6_TX);
 		}
 
-		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
-		ttl = ttl ? : ip6_dst_hoplimit(ndst);
 		skb_scrub_packet(skb, xnet);
 		err = vxlan_build_skb(skb, ndst, sizeof(struct ipv6hdr),
 				      vni, md, flags, udp_sum);
 		if (err < 0)
 			goto tx_error;
 
-		udp_tunnel6_xmit_skb(ndst, sk, skb, dev,
+		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
+		ttl = ttl ? : ip6_dst_hoplimit(ndst);
+		udp_tunnel6_xmit_skb(ndst, sock6->sock->sk, skb, dev,
 				     &src->sin6.sin6_addr,
 				     &dst->sin6.sin6_addr, tos, ttl,
 				     label, src_port, dst_port, !udp_sum);
-- 
1.9.1
