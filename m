From: Martynas Pumputis <martynas@weave.works>
Subject: [PATCH v2] vxlan: Set ports in flow key when doing route lookups
Date: Wed, 11 Jan 2017 15:18:53 +0000
Message-ID: <20170111151853.4794-1-martynas@weave.works>
References: <20170110.211004.1712612611986550798.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Martynas Pumputis <martynas@weave.works>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f175.google.com ([209.85.210.175]:35395 "EHLO
        mail-wj0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750890AbdAKPVQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 10:21:16 -0500
Received: by mail-wj0-f175.google.com with SMTP id i20so104618670wjn.2
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 07:21:15 -0800 (PST)
In-Reply-To: <20170110.211004.1712612611986550798.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise, a xfrm policy with sport/dport being set cannot be matched.

Signed-off-by: Martynas Pumputis <martynas@weave.works>
---
Changes in v2:
    - Set the source port in the flow key.

 drivers/net/vxlan.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bb70dd5..ca7196c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1798,7 +1798,7 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan, struct net_device *dev,
 				      struct vxlan_sock *sock4,
 				      struct sk_buff *skb, int oif, u8 tos,
-				      __be32 daddr, __be32 *saddr,
+				      __be32 daddr, __be32 *saddr, __be16 dport, __be16 sport,
 				      struct dst_cache *dst_cache,
 				      const struct ip_tunnel_info *info)
 {
@@ -1824,6 +1824,8 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan, struct net_device
 	fl4.flowi4_proto = IPPROTO_UDP;
 	fl4.daddr = daddr;
 	fl4.saddr = *saddr;
+	fl4.fl4_dport = dport;
+	fl4.fl4_sport = sport;
 
 	rt = ip_route_output_key(vxlan->net, &fl4);
 	if (likely(!IS_ERR(rt))) {
@@ -1851,6 +1853,7 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 					  __be32 label,
 					  const struct in6_addr *daddr,
 					  struct in6_addr *saddr,
+					  __be16 dport, __be16 sport,
 					  struct dst_cache *dst_cache,
 					  const struct ip_tunnel_info *info)
 {
@@ -1877,6 +1880,8 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 	fl6.flowlabel = ip6_make_flowinfo(RT_TOS(tos), label);
 	fl6.flowi6_mark = skb->mark;
 	fl6.flowi6_proto = IPPROTO_UDP;
+	fl6.fl6_dport = dport;
+	fl6.fl6_sport = sport;
 
 	err = ipv6_stub->ipv6_dst_lookup(vxlan->net,
 					 sock6->sock->sk,
@@ -2068,6 +2073,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				     rdst ? rdst->remote_ifindex : 0, tos,
 				     dst->sin.sin_addr.s_addr,
 				     &src->sin.sin_addr.s_addr,
+				     dst_port, src_port,
 				     dst_cache, info);
 		if (IS_ERR(rt)) {
 			err = PTR_ERR(rt);
@@ -2104,6 +2110,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 					rdst ? rdst->remote_ifindex : 0, tos,
 					label, &dst->sin6.sin6_addr,
 					&src->sin6.sin6_addr,
+					dst_port, src_port,
 					dst_cache, info);
 		if (IS_ERR(ndst)) {
 			err = PTR_ERR(ndst);
@@ -2430,7 +2437,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 
 		rt = vxlan_get_route(vxlan, dev, sock4, skb, 0, info->key.tos,
 				     info->key.u.ipv4.dst,
-				     &info->key.u.ipv4.src, NULL, info);
+				     &info->key.u.ipv4.src, dport, sport, NULL, info);
 		if (IS_ERR(rt))
 			return PTR_ERR(rt);
 		ip_rt_put(rt);
@@ -2441,7 +2448,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 
 		ndst = vxlan6_get_route(vxlan, dev, sock6, skb, 0, info->key.tos,
 					info->key.label, &info->key.u.ipv6.dst,
-					&info->key.u.ipv6.src, NULL, info);
+					&info->key.u.ipv6.src, dport, sport, NULL, info);
 		if (IS_ERR(ndst))
 			return PTR_ERR(ndst);
 		dst_release(ndst);
-- 
2.10.2
