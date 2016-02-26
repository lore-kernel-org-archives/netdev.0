From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 5/5] vxlan: implement GPE in L3 mode
Date: Fri, 26 Feb 2016 08:48:41 +0100
Message-ID: <20f9916704dc3b34526bc0959e7212de7ec878a4.1456472746.git.jbenc@redhat.com>
References: <cover.1456472746.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47841 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753655AbcBZHtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 02:49:01 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 6216D51D
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 07:49:01 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-33.brq.redhat.com [10.40.204.33])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1Q7mrV0021506
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 02:49:00 -0500
In-Reply-To: <cover.1456472746.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement L3 mode for VXLAN-GPE (i.e. IPv4/IPv6 payload directly after the
VXLAN header).

The GPE header parsing has to be moved before iptunnel_pull_header, as we
need to know the protocol.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c          | 127 +++++++++++++++++++++++++++++++++++--------
 include/net/vxlan.h          |   3 +-
 include/uapi/linux/if_link.h |   1 +
 3 files changed, 108 insertions(+), 23 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 81a7c1a829b9..b79472d3fd36 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1191,6 +1191,7 @@ out:
 }
 
 static bool vxlan_parse_gpe_hdr(struct vxlanhdr *unparsed,
+				__be32 *protocol,
 				struct sk_buff *skb, u32 vxflags)
 {
 	struct vxlanhdr_gpe *gpe = (struct vxlanhdr_gpe *)unparsed;
@@ -1210,9 +1211,30 @@ static bool vxlan_parse_gpe_hdr(struct vxlanhdr *unparsed,
 	if (gpe->oam_flag)
 		return false;
 
-	if (gpe->next_protocol != VXLAN_GPE_NP_ETHERNET)
+	/* L2 mode */
+	if (gpe->next_protocol == VXLAN_GPE_NP_ETHERNET) {
+		if (vxflags & VXLAN_F_GPE_L3)
+			return false;
+		*protocol = htons(ETH_P_TEB);
+		goto out;
+	}
+
+	/* L3 mode */
+	if (!(vxflags & VXLAN_F_GPE_L3))
+		return false;
+
+	switch (gpe->next_protocol) {
+	case VXLAN_GPE_NP_IPV4:
+		*protocol = htons(ETH_P_IP);
+		break;
+	case VXLAN_GPE_NP_IPV6:
+		*protocol = htons(ETH_P_IPV6);
+		break;
+	default:
 		return false;
+	}
 
+out:
 	unparsed->vx_flags &= ~VXLAN_GPE_USED_BITS;
 	return true;
 }
@@ -1282,9 +1304,10 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 	struct vxlanhdr unparsed;
 	struct vxlan_metadata _md;
 	struct vxlan_metadata *md = &_md;
+	__be32 protocol = htons(ETH_P_TEB);
 	void *oiph;
 
-	/* Need Vxlan and inner Ethernet header to be present */
+	/* Need UDP and VXLAN header to be present */
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
 		return 1;
 
@@ -1308,7 +1331,14 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 	if (!vxlan)
 		goto drop;
 
-	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB),
+	/* For backwards compatibility, only allow reserved fields to be
+	 * used by VXLAN extensions if explicitly requested.
+	 */
+	if (vs->flags & VXLAN_F_GPE)
+		if (!vxlan_parse_gpe_hdr(&unparsed, &protocol, skb, vs->flags))
+			goto drop;
+
+	if (iptunnel_pull_header(skb, VXLAN_HLEN, protocol,
 				 !net_eq(vxlan->net, dev_net(vxlan->dev))))
 		goto drop;
 
@@ -1329,12 +1359,6 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 		memset(md, 0, sizeof(*md));
 	}
 
-	/* For backwards compatibility, only allow reserved fields to be
-	 * used by VXLAN extensions if explicitly requested.
-	 */
-	if (vs->flags & VXLAN_F_GPE)
-		if (!vxlan_parse_gpe_hdr(&unparsed, skb, vs->flags))
-			goto drop;
 	if (vs->flags & VXLAN_F_REMCSUM_RX)
 		if (!vxlan_remcsum(&unparsed, skb, vs->flags))
 			goto drop;
@@ -1353,8 +1377,13 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 	}
 
-	if (!vxlan_set_mac(vxlan, vs, skb))
-		goto drop;
+	if (protocol == htons(ETH_P_TEB)) {
+		if (!vxlan_set_mac(vxlan, vs, skb))
+			goto drop;
+	} else {
+		skb->dev = vxlan->dev;
+		skb->pkt_type = PACKET_HOST;
+	}
 
 	oiph = skb_network_header(skb);
 	skb_reset_network_header(skb);
@@ -1713,12 +1742,29 @@ static void vxlan_build_gbp_hdr(struct vxlanhdr *vxh, u32 vxflags,
 	gbp->policy_id = htons(md->gbp & VXLAN_GBP_ID_MASK);
 }
 
-static void vxlan_build_gpe_hdr(struct vxlanhdr *vxh, u32 vxflags)
+static int vxlan_build_gpe_hdr(struct vxlanhdr *vxh, u32 vxflags,
+			       __be16 protocol)
 {
 	struct vxlanhdr_gpe *gpe = (struct vxlanhdr_gpe *)vxh;
 
 	gpe->np_applied = 1;
-	gpe->next_protocol = VXLAN_GPE_NP_ETHERNET;
+
+	/* L2 mode */
+	if (!(vxflags & VXLAN_F_GPE_L3)) {
+		gpe->next_protocol = VXLAN_GPE_NP_ETHERNET;
+		return 0;
+	}
+
+	/* L3 mode */
+	switch (protocol) {
+	case htons(ETH_P_IP):
+		gpe->next_protocol = VXLAN_GPE_NP_IPV4;
+		return 0;
+	case htons(ETH_P_IPV6):
+		gpe->next_protocol = VXLAN_GPE_NP_IPV6;
+		return 0;
+	}
+	return -EPFNOSUPPORT;
 }
 
 static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
@@ -1730,6 +1776,7 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 	int min_headroom;
 	int err;
 	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+	__be16 inner_protocol = htons(ETH_P_TEB);
 
 	if ((vxflags & VXLAN_F_REMCSUM_TX) &&
 	    skb->ip_summed == CHECKSUM_PARTIAL) {
@@ -1748,10 +1795,8 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 
 	/* Need space for new headers (invalidates iph ptr) */
 	err = skb_cow_head(skb, min_headroom);
-	if (unlikely(err)) {
-		kfree_skb(skb);
-		return err;
-	}
+	if (unlikely(err))
+		goto out_free;
 
 	skb = vlan_hwaccel_push_inside(skb);
 	if (WARN_ON(!skb))
@@ -1780,11 +1825,20 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 
 	if (vxflags & VXLAN_F_GBP)
 		vxlan_build_gbp_hdr(vxh, vxflags, md);
-	if (vxflags & VXLAN_F_GPE)
-		vxlan_build_gpe_hdr(vxh, vxflags);
+	if (vxflags & VXLAN_F_GPE) {
+		err = vxlan_build_gpe_hdr(vxh, vxflags, skb->protocol);
+		if (err < 0)
+			goto out_free;
+		if (vxflags & VXLAN_F_GPE_L3)
+			inner_protocol = skb->protocol;
+	}
 
-	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
+	skb_set_inner_protocol(skb, inner_protocol);
 	return 0;
+
+out_free:
+	kfree_skb(skb);
+	return err;
 }
 
 static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
@@ -2452,6 +2506,17 @@ static const struct net_device_ops vxlan_netdev_l2mode_ops = {
 	.ndo_fill_metadata_dst	= vxlan_fill_metadata_dst,
 };
 
+static const struct net_device_ops vxlan_netdev_l3mode_ops = {
+	.ndo_init		= vxlan_init,
+	.ndo_uninit		= vxlan_uninit,
+	.ndo_open		= vxlan_open,
+	.ndo_stop		= vxlan_stop,
+	.ndo_start_xmit		= vxlan_xmit,
+	.ndo_get_stats64	= ip_tunnel_get_stats64,
+	.ndo_change_mtu		= vxlan_change_mtu,
+	.ndo_fill_metadata_dst	= vxlan_fill_metadata_dst,
+};
+
 /* Info for udev, that this is a virtual tunnel endpoint */
 static struct device_type vxlan_type = {
 	.name = "vxlan",
@@ -2531,6 +2596,17 @@ static void vxlan_l2mode_setup(struct net_device *dev)
 	dev->netdev_ops = &vxlan_netdev_l2mode_ops;
 }
 
+static void vxlan_l3mode_setup(struct net_device *dev)
+{
+	dev->type = ARPHRD_NONE;
+	dev->hard_header_len = 0;
+	dev->addr_len = 0;
+	dev->mtu = ETH_DATA_LEN;
+	dev->tx_queue_len = 1000;
+	dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
+	dev->netdev_ops = &vxlan_netdev_l3mode_ops;
+}
+
 static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_ID]		= { .type = NLA_U32 },
 	[IFLA_VXLAN_GROUP]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
@@ -2761,7 +2837,10 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	    ((conf->flags & VXLAN_F_GBP) && (conf->flags & VXLAN_F_GPE)))
 		return -EINVAL;
 
-	vxlan_l2mode_setup(dev);
+	if (conf->flags & VXLAN_F_GPE_L3)
+		vxlan_l3mode_setup(dev);
+	else
+		vxlan_l2mode_setup(dev);
 
 	vxlan->net = src_net;
 
@@ -2999,6 +3078,8 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 
 		if (mode > 0 && mode <= VXLAN_GPE_MODE_MAX)
 			conf.flags |= VXLAN_F_GPE;
+		if (mode == VXLAN_GPE_MODE_L3)
+			conf.flags |= VXLAN_F_GPE_L3;
 	}
 
 	err = vxlan_dev_configure(src_net, dev, &conf);
@@ -3148,7 +3229,9 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 		goto nla_put_failure;
 
 	if (vxlan->flags & VXLAN_F_GPE &&
-	    nla_put_u8(skb, IFLA_VXLAN_GPE_MODE, VXLAN_GPE_MODE_L2))
+	    nla_put_u8(skb, IFLA_VXLAN_GPE_MODE,
+		       vxlan->flags & VXLAN_F_GPE_L3 ? VXLAN_GPE_MODE_L3 :
+						       VXLAN_GPE_MODE_L2))
 		goto nla_put_failure;
 
 	return 0;
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 7c5f1385bdfd..25b3753f6f67 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -264,6 +264,7 @@ struct vxlan_dev {
 #define VXLAN_F_REMCSUM_NOPARTIAL	0x1000
 #define VXLAN_F_COLLECT_METADATA	0x2000
 #define VXLAN_F_GPE			0x4000
+#define VXLAN_F_GPE_L3			0x8000
 
 /* Flags that are used in the receive path. These flags must match in
  * order for a socket to be shareable
@@ -273,7 +274,7 @@ struct vxlan_dev {
 					 VXLAN_F_REMCSUM_RX |		\
 					 VXLAN_F_REMCSUM_NOPARTIAL |	\
 					 VXLAN_F_COLLECT_METADATA |	\
-					 VXLAN_F_GPE)
+					 VXLAN_F_GPE | VXLAN_F_GPE_L3)
 
 struct net_device *vxlan_dev_create(struct net *net, const char *name,
 				    u8 name_assign_type, struct vxlan_config *conf);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index c2b2b7462731..ee4f7198aa21 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -464,6 +464,7 @@ enum {
 enum vxlan_gpe_mode {
 	VXLAN_GPE_MODE_DISABLED = 0,
 	VXLAN_GPE_MODE_L2,
+	VXLAN_GPE_MODE_L3,
 	__VXLAN_GPE_MODE_MAX
 };
 #define VXLAN_GPE_MODE_MAX (__VXLAN_GPE_MODE_MAX - 1)
-- 
1.8.3.1
