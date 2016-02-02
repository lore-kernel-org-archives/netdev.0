From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 5/5] vxlan: consolidate vxlan_xmit_skb and vxlan6_xmit_skb
Date: Tue,  2 Feb 2016 11:13:25 +0100
Message-ID: <0fb02d1526b8f5f602f78536d261713edee9b4ef.1454407418.git.jbenc@redhat.com>
References: <cover.1454407418.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38677 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754768AbcBBKNz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 05:13:55 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id 0D855C00124A
	for <netdev@vger.kernel.org>; Tue,  2 Feb 2016 10:13:55 +0000 (UTC)
Received: from griffin.localdomain (ovpn-204-27.brq.redhat.com [10.40.204.27])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u12ADmYj027928
	for <netdev@vger.kernel.org>; Tue, 2 Feb 2016 05:13:54 -0500
In-Reply-To: <cover.1454407418.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a lot of code duplication. Factor out the duplicate code to a new
function shared between IPv4 and IPv6 xmit path.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 141 +++++++++++-----------------------------------------
 1 file changed, 29 insertions(+), 112 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d0f7723fd776..cf7de95eccfc 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1684,98 +1684,9 @@ static void vxlan_build_gbp_hdr(struct vxlanhdr *vxh, u32 vxflags,
 	gbp->policy_id = htons(md->gbp & VXLAN_GBP_ID_MASK);
 }
 
-#if IS_ENABLED(CONFIG_IPV6)
-static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
-			   struct sk_buff *skb,
-			   struct net_device *dev, struct in6_addr *saddr,
-			   struct in6_addr *daddr, __u8 prio, __u8 ttl,
-			   __be16 src_port, __be16 dst_port, __be32 vni,
-			   struct vxlan_metadata *md, bool xnet, u32 vxflags)
-{
-	struct vxlanhdr *vxh;
-	int min_headroom;
-	int err;
-	bool udp_sum = !(vxflags & VXLAN_F_UDP_ZERO_CSUM6_TX);
-	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
-	u16 hdrlen = sizeof(struct vxlanhdr);
-
-	if ((vxflags & VXLAN_F_REMCSUM_TX) &&
-	    skb->ip_summed == CHECKSUM_PARTIAL) {
-		int csum_start = skb_checksum_start_offset(skb);
-
-		if (csum_start <= VXLAN_MAX_REMCSUM_START &&
-		    !(csum_start & VXLAN_RCO_SHIFT_MASK) &&
-		    (skb->csum_offset == offsetof(struct udphdr, check) ||
-		     skb->csum_offset == offsetof(struct tcphdr, check))) {
-			udp_sum = false;
-			type |= SKB_GSO_TUNNEL_REMCSUM;
-		}
-	}
-
-	skb_scrub_packet(skb, xnet);
-
-	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len
-			+ VXLAN_HLEN + sizeof(struct ipv6hdr)
-			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
-
-	/* Need space for new headers (invalidates iph ptr) */
-	err = skb_cow_head(skb, min_headroom);
-	if (unlikely(err)) {
-		kfree_skb(skb);
-		goto err;
-	}
-
-	skb = vlan_hwaccel_push_inside(skb);
-	if (WARN_ON(!skb)) {
-		err = -ENOMEM;
-		goto err;
-	}
-
-	skb = iptunnel_handle_offloads(skb, udp_sum, type);
-	if (IS_ERR(skb)) {
-		err = -EINVAL;
-		goto err;
-	}
-
-	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
-	vxh->vx_flags = htonl(VXLAN_HF_VNI);
-	vxh->vx_vni = vni;
-
-	if (type & SKB_GSO_TUNNEL_REMCSUM) {
-		u32 data = (skb_checksum_start_offset(skb) - hdrlen) >>
-			   VXLAN_RCO_SHIFT;
-
-		if (skb->csum_offset == offsetof(struct udphdr, check))
-			data |= VXLAN_RCO_UDP;
-
-		vxh->vx_vni |= htonl(data);
-		vxh->vx_flags |= htonl(VXLAN_HF_RCO);
-
-		if (!skb_is_gso(skb)) {
-			skb->ip_summed = CHECKSUM_NONE;
-			skb->encapsulation = 0;
-		}
-	}
-
-	if (vxflags & VXLAN_F_GBP)
-		vxlan_build_gbp_hdr(vxh, vxflags, md);
-
-	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
-
-	udp_tunnel6_xmit_skb(dst, sk, skb, dev, saddr, daddr, prio,
-			     ttl, src_port, dst_port,
-			     !!(vxflags & VXLAN_F_UDP_ZERO_CSUM6_TX));
-	return 0;
-err:
-	dst_release(dst);
-	return err;
-}
-#endif
-
-static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
-			  __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
-			  __be16 src_port, __be16 dst_port, __be32 vni,
-			  struct vxlan_metadata *md, bool xnet, u32 vxflags)
+static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
+			   int iphdr_len, __be32 vni,
+			   struct vxlan_metadata *md, u32 vxflags)
 {
 	struct vxlanhdr *vxh;
 	int min_headroom;
@@ -1797,8 +1708,8 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 		}
 	}
 
-	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
-			+ VXLAN_HLEN + sizeof(struct iphdr)
+	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len
+			+ VXLAN_HLEN + iphdr_len
 			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
 
 	/* Need space for new headers (invalidates iph ptr) */
@@ -1840,10 +1751,6 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 		vxlan_build_gbp_hdr(vxh, vxflags, md);
 
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
-
-	udp_tunnel_xmit_skb(rt, sk, skb, src, dst, tos, ttl, df,
-			    src_port, dst_port, xnet,
-			    !(vxflags & VXLAN_F_UDP_CSUM));
 	return 0;
 }
 
@@ -1959,6 +1866,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	__u8 tos, ttl;
 	int err;
 	u32 flags = vxlan->flags;
+	bool xnet = !net_eq(vxlan->net, dev_net(vxlan->dev));
 
 	info = skb_tunnel_info(skb);
 
@@ -2065,16 +1973,15 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
-		err = vxlan_xmit_skb(rt, sk, skb, saddr,
-				     dst->sin.sin_addr.s_addr, tos, ttl, df,
-				     src_port, dst_port, htonl(vni << 8), md,
-				     !net_eq(vxlan->net, dev_net(vxlan->dev)),
-				     flags);
-		if (err < 0) {
-			/* skb is already freed. */
-			skb = NULL;
-			goto rt_tx_error;
-		}
+		err = vxlan_build_skb(skb, &rt->dst, sizeof(struct iphdr),
+				      htonl(vni << 8), md, flags);
+		if (err < 0)
+			goto xmit_tx_error;
+
+		udp_tunnel_xmit_skb(rt, sk, skb, saddr,
+				    dst->sin.sin_addr.s_addr, tos, ttl, df,
+				    src_port, dst_port, xnet,
+				    !(flags & VXLAN_F_UDP_CSUM));
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
 		struct dst_entry *ndst;
@@ -2127,10 +2034,17 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		}
 
 		ttl = ttl ? : ip6_dst_hoplimit(ndst);
-		err = vxlan6_xmit_skb(ndst, sk, skb, dev, &saddr, &dst->sin6.sin6_addr,
-				      0, ttl, src_port, dst_port, htonl(vni << 8), md,
-				      !net_eq(vxlan->net, dev_net(vxlan->dev)),
-				      flags);
+		skb_scrub_packet(skb, xnet);
+		err = vxlan_build_skb(skb, ndst, sizeof(struct ipv6hdr),
+				      htonl(vni << 8), md, flags);
+		if (err < 0) {
+			dst_release(ndst);
+			return;
+		}
+		udp_tunnel6_xmit_skb(ndst, sk, skb, dev,
+				     &saddr, &dst->sin6.sin6_addr,
+				     0, ttl, src_port, dst_port,
+				     !!(flags & VXLAN_F_UDP_ZERO_CSUM6_TX));
 #endif
 	}
 
@@ -2140,6 +2054,9 @@ drop:
 	dev->stats.tx_dropped++;
 	goto tx_free;
 
+xmit_tx_error:
+	/* skb is already freed. */
+	skb = NULL;
 rt_tx_error:
 	ip_rt_put(rt);
 tx_error:
-- 
1.8.3.1
