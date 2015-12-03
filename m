From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2] vxlan: consolidate output route calculation
Date: Thu,  3 Dec 2015 12:23:57 +0100
Message-ID: <65e2af7ff108b1c7b477c3df91382bb9e4662edf.1449141813.git.jbenc@redhat.com>
Cc: Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40632 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759879AbbLCLYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 06:24:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code for output route lookup is duplicated for ndo_start_xmit and
ndo_fill_metadata_dst. Move it to a common function.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
This applies on top of the "vxlan: IPv6 fill_metadata_dst support" patchset
submitted to net.git.

v2: rebased on top of the IPv6 patches
---
 drivers/net/vxlan.c | 75 +++++++++++++++++++++++++----------------------------
 1 file changed, 36 insertions(+), 39 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d3594de3ad07..ed290d4ec67e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1848,6 +1848,27 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 				   !(vxflags & VXLAN_F_UDP_CSUM));
 }
 
+static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
+				      struct sk_buff *skb, int oif, u8 tos,
+				      __be32 daddr, __be32 *saddr)
+{
+	struct rtable *rt = NULL;
+	struct flowi4 fl4;
+
+	memset(&fl4, 0, sizeof(fl4));
+	fl4.flowi4_oif = oif;
+	fl4.flowi4_tos = RT_TOS(tos);
+	fl4.flowi4_mark = skb->mark;
+	fl4.flowi4_proto = IPPROTO_UDP;
+	fl4.daddr = daddr;
+	fl4.saddr = vxlan->cfg.saddr.sin.sin_addr.s_addr;
+
+	rt = ip_route_output_key(vxlan->net, &fl4);
+	if (!IS_ERR(rt))
+		*saddr = fl4.saddr;
+	return rt;
+}
+
 #if IS_ENABLED(CONFIG_IPV6)
 static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 					  struct sk_buff *skb, int oif,
@@ -1929,7 +1950,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct sock *sk;
 	struct rtable *rt = NULL;
 	const struct iphdr *old_iph;
-	struct flowi4 fl4;
 	union vxlan_addr *dst;
 	union vxlan_addr remote_ip;
 	struct vxlan_metadata _md;
@@ -2001,6 +2021,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	if (dst->sa.sa_family == AF_INET) {
+		__be32 saddr;
+
 		if (!vxlan->vn4_sock)
 			goto drop;
 		sk = vxlan->vn4_sock->sock->sk;
@@ -2008,15 +2030,9 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		if (info && (info->key.tun_flags & TUNNEL_DONT_FRAGMENT))
 			df = htons(IP_DF);
 
-		memset(&fl4, 0, sizeof(fl4));
-		fl4.flowi4_oif = rdst ? rdst->remote_ifindex : 0;
-		fl4.flowi4_tos = RT_TOS(tos);
-		fl4.flowi4_mark = skb->mark;
-		fl4.flowi4_proto = IPPROTO_UDP;
-		fl4.daddr = dst->sin.sin_addr.s_addr;
-		fl4.saddr = vxlan->cfg.saddr.sin.sin_addr.s_addr;
-
-		rt = ip_route_output_key(vxlan->net, &fl4);
+		rt = vxlan_get_route(vxlan, skb,
+				     rdst ? rdst->remote_ifindex : 0, tos,
+				     dst->sin.sin_addr.s_addr, &saddr);
 		if (IS_ERR(rt)) {
 			netdev_dbg(dev, "no route to %pI4\n",
 				   &dst->sin.sin_addr.s_addr);
@@ -2048,7 +2064,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
-		err = vxlan_xmit_skb(rt, sk, skb, fl4.saddr,
+		err = vxlan_xmit_skb(rt, sk, skb, saddr,
 				     dst->sin.sin_addr.s_addr, tos, ttl, df,
 				     src_port, dst_port, htonl(vni << 8), md,
 				     !net_eq(vxlan->net, dev_net(vxlan->dev)),
@@ -2384,31 +2400,6 @@ static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-static int egress_ipv4_tun_info(struct net_device *dev, struct sk_buff *skb,
-				struct ip_tunnel_info *info,
-				__be16 sport, __be16 dport)
-{
-	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct rtable *rt;
-	struct flowi4 fl4;
-
-	memset(&fl4, 0, sizeof(fl4));
-	fl4.flowi4_tos = RT_TOS(info->key.tos);
-	fl4.flowi4_mark = skb->mark;
-	fl4.flowi4_proto = IPPROTO_UDP;
-	fl4.daddr = info->key.u.ipv4.dst;
-
-	rt = ip_route_output_key(vxlan->net, &fl4);
-	if (IS_ERR(rt))
-		return PTR_ERR(rt);
-	ip_rt_put(rt);
-
-	info->key.u.ipv4.src = fl4.saddr;
-	info->key.tp_src = sport;
-	info->key.tp_dst = dport;
-	return 0;
-}
-
 static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
@@ -2416,6 +2407,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 #if IS_ENABLED(CONFIG_IPV6)
 	struct dst_entry *ndst;
 #endif
+	struct rtable *rt;
 	__be16 sport, dport;
 
 	sport = udp_flow_src_port(dev_net(dev), skb, vxlan->cfg.port_min,
@@ -2425,7 +2417,12 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 	if (ip_tunnel_info_af(info) == AF_INET) {
 		if (!vxlan->vn4_sock)
 			return -EINVAL;
-		return egress_ipv4_tun_info(dev, skb, info, sport, dport);
+		rt = vxlan_get_route(vxlan, skb, 0, info->key.tos,
+				     info->key.u.ipv4.dst,
+				     &info->key.u.ipv4.src);
+		if (IS_ERR(rt))
+			return PTR_ERR(rt);
+		ip_rt_put(rt);
 	} else {
 		if (!IS_ENABLED(CONFIG_IPV6))
 			return -EPFNOSUPPORT;
@@ -2440,9 +2437,9 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 			return PTR_ERR(ndst);
 		dst_release(ndst);
 #endif
-		info->key.tp_src = sport;
-		info->key.tp_dst = dport;
 	}
+	info->key.tp_src = sport;
+	info->key.tp_dst = dport;
 	return 0;
 }
 
-- 
1.8.3.1
