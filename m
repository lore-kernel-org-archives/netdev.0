From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 7/7] vxlan: allow setting ipv6 traffic class
Date: Fri,  4 Mar 2016 15:15:08 +0100
Message-ID: <c50f1e302411f7e4fe73ec469e0683f3e14fe830.1457099834.git.daniel@iogearbox.net>
References: <cover.1457099834.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39211 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756468AbcCDOPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 09:15:36 -0500
In-Reply-To: <cover.1457099834.git.daniel@iogearbox.net>
In-Reply-To: <cover.1457099834.git.daniel@iogearbox.net>
References: <cover.1457099834.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can already do that for IPv4, but IPv6 support was missing. Add
it for vxlan, so it can be used with collect metadata frontends.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/vxlan.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 366a858..d33a434 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1788,7 +1788,7 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
 
 #if IS_ENABLED(CONFIG_IPV6)
 static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
-					  struct sk_buff *skb, int oif,
+					  struct sk_buff *skb, int oif, u8 tos,
 					  const struct in6_addr *daddr,
 					  struct in6_addr *saddr,
 					  struct dst_cache *dst_cache,
@@ -1799,6 +1799,8 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 	struct flowi6 fl6;
 	int err;
 
+	if (tos && !info)
+		use_cache = false;
 	if (use_cache) {
 		ndst = dst_cache_get_ip6(dst_cache, saddr);
 		if (ndst)
@@ -1807,6 +1809,7 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_oif = oif;
+	fl6.flowi6_tos = RT_TOS(tos);
 	fl6.daddr = *daddr;
 	fl6.saddr = vxlan->cfg.saddr.sin6.sin6_addr;
 	fl6.flowi6_mark = skb->mark;
@@ -2015,7 +2018,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		sk = vxlan->vn6_sock->sock->sk;
 
 		ndst = vxlan6_get_route(vxlan, skb,
-					rdst ? rdst->remote_ifindex : 0,
+					rdst ? rdst->remote_ifindex : 0, tos,
 					&dst->sin6.sin6_addr, &saddr,
 					dst_cache, info);
 		if (IS_ERR(ndst)) {
@@ -2052,6 +2055,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		if (!info)
 			udp_sum = !(flags & VXLAN_F_UDP_ZERO_CSUM6_TX);
 
+		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip6_dst_hoplimit(ndst);
 		skb_scrub_packet(skb, xnet);
 		err = vxlan_build_skb(skb, ndst, sizeof(struct ipv6hdr),
@@ -2061,8 +2065,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			return;
 		}
 		udp_tunnel6_xmit_skb(ndst, sk, skb, dev,
-				     &saddr, &dst->sin6.sin6_addr,
-				     0, ttl, src_port, dst_port, !udp_sum);
+				     &saddr, &dst->sin6.sin6_addr, tos, ttl,
+				     src_port, dst_port, !udp_sum);
 #endif
 	}
 
@@ -2384,7 +2388,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 
 		if (!vxlan->vn6_sock)
 			return -EINVAL;
-		ndst = vxlan6_get_route(vxlan, skb, 0,
+		ndst = vxlan6_get_route(vxlan, skb, 0, info->key.tos,
 					&info->key.u.ipv6.dst,
 					&info->key.u.ipv6.src, NULL, info);
 		if (IS_ERR(ndst))
-- 
1.9.3
