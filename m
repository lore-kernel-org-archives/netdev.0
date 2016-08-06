From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net 1/2] net: vxlan: lwt: Use source ip address during route lookup.
Date: Fri,  5 Aug 2016 17:45:36 -0700
Message-ID: <1470444337-3725-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:36839 "EHLO
	slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025AbcHFUMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2016 16:12:20 -0400
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
	by slow1-d.mail.gandi.net (Postfix) with ESMTP id 5818547A0B7
	for <netdev@vger.kernel.org>; Sat,  6 Aug 2016 02:46:07 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LWT user can specify destination as well as source ip address
for given tunnel endpoint. But vxlan is ignoring given source
ip address. Following patch uses both ip address to route the
tunnel packet. This consistent with other LWT implementations,
like GENEVE and GRE.

Fixes: ee122c79d42 ("vxlan: Flow based tunneling").
Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 drivers/net/vxlan.c | 30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index da4e3d6..b812234 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1811,7 +1811,7 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
 	fl4.flowi4_mark = skb->mark;
 	fl4.flowi4_proto = IPPROTO_UDP;
 	fl4.daddr = daddr;
-	fl4.saddr = vxlan->cfg.saddr.sin.sin_addr.s_addr;
+	fl4.saddr = *saddr;
 
 	rt = ip_route_output_key(vxlan->net, &fl4);
 	if (!IS_ERR(rt)) {
@@ -1847,7 +1847,7 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_oif = oif;
 	fl6.daddr = *daddr;
-	fl6.saddr = vxlan->cfg.saddr.sin6.sin6_addr;
+	fl6.saddr = *saddr;
 	fl6.flowlabel = ip6_make_flowinfo(RT_TOS(tos), label);
 	fl6.flowi6_mark = skb->mark;
 	fl6.flowi6_proto = IPPROTO_UDP;
@@ -1920,7 +1920,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct rtable *rt = NULL;
 	const struct iphdr *old_iph;
 	union vxlan_addr *dst;
-	union vxlan_addr remote_ip;
+	union vxlan_addr remote_ip, local_ip;
+	union vxlan_addr *src;
 	struct vxlan_metadata _md;
 	struct vxlan_metadata *md = &_md;
 	__be16 src_port = 0, dst_port;
@@ -1938,6 +1939,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		dst_port = rdst->remote_port ? rdst->remote_port : vxlan->cfg.dst_port;
 		vni = rdst->remote_vni;
 		dst = &rdst->remote_ip;
+		src = &vxlan->cfg.saddr;
 		dst_cache = &rdst->dst_cache;
 	} else {
 		if (!info) {
@@ -1948,11 +1950,15 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		dst_port = info->key.tp_dst ? : vxlan->cfg.dst_port;
 		vni = vxlan_tun_id_to_vni(info->key.tun_id);
 		remote_ip.sa.sa_family = ip_tunnel_info_af(info);
-		if (remote_ip.sa.sa_family == AF_INET)
+		if (remote_ip.sa.sa_family == AF_INET) {
 			remote_ip.sin.sin_addr.s_addr = info->key.u.ipv4.dst;
-		else
+			local_ip.sin.sin_addr.s_addr = info->key.u.ipv4.src;
+		} else {
 			remote_ip.sin6.sin6_addr = info->key.u.ipv6.dst;
+			local_ip.sin6.sin6_addr = info->key.u.ipv6.src;
+		}
 		dst = &remote_ip;
+		src = &local_ip;
 		dst_cache = &info->dst_cache;
 	}
 
@@ -1992,15 +1998,14 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	if (dst->sa.sa_family == AF_INET) {
-		__be32 saddr;
-
 		if (!vxlan->vn4_sock)
 			goto drop;
 		sk = vxlan->vn4_sock->sock->sk;
 
 		rt = vxlan_get_route(vxlan, skb,
 				     rdst ? rdst->remote_ifindex : 0, tos,
-				     dst->sin.sin_addr.s_addr, &saddr,
+				     dst->sin.sin_addr.s_addr,
+				     &src->sin.sin_addr.s_addr,
 				     dst_cache, info);
 		if (IS_ERR(rt)) {
 			netdev_dbg(dev, "no route to %pI4\n",
@@ -2043,13 +2048,12 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		if (err < 0)
 			goto xmit_tx_error;
 
-		udp_tunnel_xmit_skb(rt, sk, skb, saddr,
+		udp_tunnel_xmit_skb(rt, sk, skb, src->sin.sin_addr.s_addr,
 				    dst->sin.sin_addr.s_addr, tos, ttl, df,
 				    src_port, dst_port, xnet, !udp_sum);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
 		struct dst_entry *ndst;
-		struct in6_addr saddr;
 		u32 rt6i_flags;
 
 		if (!vxlan->vn6_sock)
@@ -2058,7 +2062,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		ndst = vxlan6_get_route(vxlan, skb,
 					rdst ? rdst->remote_ifindex : 0, tos,
-					label, &dst->sin6.sin6_addr, &saddr,
+					label, &dst->sin6.sin6_addr,
+					&src->sin6.sin6_addr,
 					dst_cache, info);
 		if (IS_ERR(ndst)) {
 			netdev_dbg(dev, "no route to %pI6\n",
@@ -2104,7 +2109,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			return;
 		}
 		udp_tunnel6_xmit_skb(ndst, sk, skb, dev,
-				     &saddr, &dst->sin6.sin6_addr, tos, ttl,
+				     &src->sin6.sin6_addr,
+				     &dst->sin6.sin6_addr, tos, ttl,
 				     label, src_port, dst_port, !udp_sum);
 #endif
 	}
-- 
1.9.1
