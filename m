From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 1/3] vxlan: consolidate output route calculation
Date: Wed,  2 Dec 2015 19:12:08 +0100
Message-ID: <88b8777e7f4c9d549e69cf1bdd0f73039e7774ee.1449079592.git.jbenc@redhat.com>
References: <cover.1449079592.git.jbenc@redhat.com>
Cc: Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58790 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755017AbbLBSMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 13:12:36 -0500
In-Reply-To: <cover.1449079592.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code for output route lookup is duplicated for ndo_start_xmit and
ndo_fill_metadata_dst. Move it to a common function.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 49 +++++++++++++++++++++++++++++--------------------
 1 file changed, 29 insertions(+), 20 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6369a5734d4c..085d0c5b82b7 100644
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
 /* Bypass encapsulation if the destination is local */
 static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 			       struct vxlan_dev *dst_vxlan)
@@ -1901,7 +1922,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct sock *sk;
 	struct rtable *rt = NULL;
 	const struct iphdr *old_iph;
-	struct flowi4 fl4;
 	union vxlan_addr *dst;
 	union vxlan_addr remote_ip;
 	struct vxlan_metadata _md;
@@ -1973,6 +1993,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	if (dst->sa.sa_family == AF_INET) {
+		__be32 saddr;
+
 		if (!vxlan->vn4_sock)
 			goto drop;
 		sk = vxlan->vn4_sock->sock->sk;
@@ -1980,15 +2002,9 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
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
@@ -2020,7 +2036,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
-		err = vxlan_xmit_skb(rt, sk, skb, fl4.saddr,
+		err = vxlan_xmit_skb(rt, sk, skb, saddr,
 				     dst->sin.sin_addr.s_addr, tos, ttl, df,
 				     src_port, dst_port, htonl(vni << 8), md,
 				     !net_eq(vxlan->net, dev_net(vxlan->dev)),
@@ -2366,20 +2382,13 @@ static int egress_ipv4_tun_info(struct net_device *dev, struct sk_buff *skb,
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct rtable *rt;
-	struct flowi4 fl4;
 
-	memset(&fl4, 0, sizeof(fl4));
-	fl4.flowi4_tos = RT_TOS(info->key.tos);
-	fl4.flowi4_mark = skb->mark;
-	fl4.flowi4_proto = IPPROTO_UDP;
-	fl4.daddr = info->key.u.ipv4.dst;
-
-	rt = ip_route_output_key(vxlan->net, &fl4);
+	rt = vxlan_get_route(vxlan, skb, 0, info->key.tos,
+			     info->key.u.ipv4.dst, &info->key.u.ipv4.src);
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
 	ip_rt_put(rt);
 
-	info->key.u.ipv4.src = fl4.saddr;
 	info->key.tp_src = sport;
 	info->key.tp_dst = dport;
 	return 0;
-- 
1.8.3.1
