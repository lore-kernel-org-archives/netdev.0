From: Martynas Pumputis <martynas@weave.works>
Subject: [PATCH] vxlan: Set flow*_dport when doing route lookups
Date: Tue, 10 Jan 2017 17:29:45 +0000
Message-ID: <20170110172945.24676-1-martynas@weave.works>
Cc: netdev@vger.kernel.org, Martynas Pumputis <martynas@weave.works>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f177.google.com ([209.85.210.177]:35045 "EHLO
        mail-wj0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936906AbdAJR3N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 12:29:13 -0500
Received: by mail-wj0-f177.google.com with SMTP id i20so86399417wjn.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 09:29:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise, no xfrm policy with dport being set can be matched.

Signed-off-by: Martynas Pumputis <martynas@weave.works>
---
 drivers/net/vxlan.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bb70dd5..fcfe786 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1798,7 +1798,7 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan, struct net_device *dev,
 				      struct vxlan_sock *sock4,
 				      struct sk_buff *skb, int oif, u8 tos,
-				      __be32 daddr, __be32 *saddr,
+				      __be32 daddr, __be32 *saddr, __be16 dport,
 				      struct dst_cache *dst_cache,
 				      const struct ip_tunnel_info *info)
 {
@@ -1824,6 +1824,7 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan, struct net_device
 	fl4.flowi4_proto = IPPROTO_UDP;
 	fl4.daddr = daddr;
 	fl4.saddr = *saddr;
+	fl4.fl4_dport = dport;
 
 	rt = ip_route_output_key(vxlan->net, &fl4);
 	if (likely(!IS_ERR(rt))) {
@@ -1851,6 +1852,7 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 					  __be32 label,
 					  const struct in6_addr *daddr,
 					  struct in6_addr *saddr,
+					  __be16 dport,
 					  struct dst_cache *dst_cache,
 					  const struct ip_tunnel_info *info)
 {
@@ -1877,6 +1879,7 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 	fl6.flowlabel = ip6_make_flowinfo(RT_TOS(tos), label);
 	fl6.flowi6_mark = skb->mark;
 	fl6.flowi6_proto = IPPROTO_UDP;
+	fl6.fl6_dport = dport;
 
 	err = ipv6_stub->ipv6_dst_lookup(vxlan->net,
 					 sock6->sock->sk,
@@ -2068,6 +2071,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				     rdst ? rdst->remote_ifindex : 0, tos,
 				     dst->sin.sin_addr.s_addr,
 				     &src->sin.sin_addr.s_addr,
+				     dst_port,
 				     dst_cache, info);
 		if (IS_ERR(rt)) {
 			err = PTR_ERR(rt);
@@ -2104,6 +2108,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 					rdst ? rdst->remote_ifindex : 0, tos,
 					label, &dst->sin6.sin6_addr,
 					&src->sin6.sin6_addr,
+					dst_port,
 					dst_cache, info);
 		if (IS_ERR(ndst)) {
 			err = PTR_ERR(ndst);
@@ -2430,7 +2435,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 
 		rt = vxlan_get_route(vxlan, dev, sock4, skb, 0, info->key.tos,
 				     info->key.u.ipv4.dst,
-				     &info->key.u.ipv4.src, NULL, info);
+				     &info->key.u.ipv4.src, dport, NULL, info);
 		if (IS_ERR(rt))
 			return PTR_ERR(rt);
 		ip_rt_put(rt);
@@ -2441,7 +2446,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 
 		ndst = vxlan6_get_route(vxlan, dev, sock6, skb, 0, info->key.tos,
 					info->key.label, &info->key.u.ipv6.dst,
-					&info->key.u.ipv6.src, NULL, info);
+					&info->key.u.ipv6.src, dport, NULL, info);
 		if (IS_ERR(ndst))
 			return PTR_ERR(ndst);
 		dst_release(ndst);
-- 
2.10.2
