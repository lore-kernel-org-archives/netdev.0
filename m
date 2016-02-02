From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 5/6] vxlan: consolidate csum flag handling
Date: Tue,  2 Feb 2016 18:09:15 +0100
Message-ID: <d5d3a3ce760f262b2d9dd933447452338bdf552a.1454432731.git.jbenc@redhat.com>
References: <cover.1454432731.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60936 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932970AbcBBRJ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 12:09:29 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (Postfix) with ESMTPS id 46720C0B6119
	for <netdev@vger.kernel.org>; Tue,  2 Feb 2016 17:09:29 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-49.brq.redhat.com [10.40.204.49])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u12H9NSq003510
	for <netdev@vger.kernel.org>; Tue, 2 Feb 2016 12:09:28 -0500
In-Reply-To: <cover.1454432731.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The flag for tx checksumming for tunneling over IPv4 and IPv6 is different.
Decide whether to do tx checksumming in vxlan_xmit_one and pass it on as
a separate flag. This will allow for tx path consolidation in the next
patch.

Unfortunately, gcc is not clever enough to see that udp_sum is always
initialized and gives an uninitialized variable warning. Set it to false to
silence the warning.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
New in v2.
---
 drivers/net/vxlan.c | 37 ++++++++++++++++---------------------
 1 file changed, 16 insertions(+), 21 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d0f7723fd776..fe3fd4808f4d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1690,12 +1690,13 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 			   struct net_device *dev, struct in6_addr *saddr,
 			   struct in6_addr *daddr, __u8 prio, __u8 ttl,
 			   __be16 src_port, __be16 dst_port, __be32 vni,
-			   struct vxlan_metadata *md, bool xnet, u32 vxflags)
+			   struct vxlan_metadata *md, bool xnet, u32 vxflags,
+			   bool udp_sum)
 {
 	struct vxlanhdr *vxh;
 	int min_headroom;
 	int err;
-	bool udp_sum = !(vxflags & VXLAN_F_UDP_ZERO_CSUM6_TX);
+	bool nocheck = !udp_sum;
 	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 	u16 hdrlen = sizeof(struct vxlanhdr);
 
@@ -1763,8 +1764,7 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
 	udp_tunnel6_xmit_skb(dst, sk, skb, dev, saddr, daddr, prio,
-			     ttl, src_port, dst_port,
-			     !!(vxflags & VXLAN_F_UDP_ZERO_CSUM6_TX));
+			     ttl, src_port, dst_port, nocheck);
 	return 0;
 err:
 	dst_release(dst);
@@ -1775,12 +1775,13 @@ err:
 static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
 			  __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
 			  __be16 src_port, __be16 dst_port, __be32 vni,
-			  struct vxlan_metadata *md, bool xnet, u32 vxflags)
+			  struct vxlan_metadata *md, bool xnet, u32 vxflags,
+			  bool udp_sum)
 {
 	struct vxlanhdr *vxh;
 	int min_headroom;
 	int err;
-	bool udp_sum = !!(vxflags & VXLAN_F_UDP_CSUM);
+	bool nocheck = !udp_sum;
 	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 	u16 hdrlen = sizeof(struct vxlanhdr);
 
@@ -1842,8 +1843,7 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
 	udp_tunnel_xmit_skb(rt, sk, skb, src, dst, tos, ttl, df,
-			    src_port, dst_port, xnet,
-			    !(vxflags & VXLAN_F_UDP_CSUM));
+			    src_port, dst_port, xnet, nocheck);
 	return 0;
 }
 
@@ -1959,6 +1959,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	__u8 tos, ttl;
 	int err;
 	u32 flags = vxlan->flags;
+	bool udp_sum = false;
 
 	info = skb_tunnel_info(skb);
 
@@ -2007,6 +2008,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	if (info) {
 		ttl = info->key.ttl;
 		tos = info->key.tos;
+		udp_sum = !!(info->key.tun_flags & TUNNEL_CSUM);
 
 		if (info->options_len)
 			md = ip_tunnel_info_opts(info);
@@ -2024,11 +2026,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		if (info) {
 			if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT)
 				df = htons(IP_DF);
-
-			if (info->key.tun_flags & TUNNEL_CSUM)
-				flags |= VXLAN_F_UDP_CSUM;
-			else
-				flags &= ~VXLAN_F_UDP_CSUM;
+		} else {
+			udp_sum = !!(flags & VXLAN_F_UDP_CSUM);
 		}
 
 		rt = vxlan_get_route(vxlan, skb,
@@ -2069,7 +2068,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				     dst->sin.sin_addr.s_addr, tos, ttl, df,
 				     src_port, dst_port, htonl(vni << 8), md,
 				     !net_eq(vxlan->net, dev_net(vxlan->dev)),
-				     flags);
+				     flags, udp_sum);
 		if (err < 0) {
 			/* skb is already freed. */
 			skb = NULL;
@@ -2119,18 +2118,14 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			return;
 		}
 
-		if (info) {
-			if (info->key.tun_flags & TUNNEL_CSUM)
-				flags &= ~VXLAN_F_UDP_ZERO_CSUM6_TX;
-			else
-				flags |= VXLAN_F_UDP_ZERO_CSUM6_TX;
-		}
+		if (!info)
+			udp_sum = !(flags & VXLAN_F_UDP_ZERO_CSUM6_TX);
 
 		ttl = ttl ? : ip6_dst_hoplimit(ndst);
 		err = vxlan6_xmit_skb(ndst, sk, skb, dev, &saddr, &dst->sin6.sin6_addr,
 				      0, ttl, src_port, dst_port, htonl(vni << 8), md,
 				      !net_eq(vxlan->net, dev_net(vxlan->dev)),
-				      flags);
+				      flags, udp_sum);
 #endif
 	}
 
-- 
1.8.3.1
