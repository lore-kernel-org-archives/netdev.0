From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH RFC (resend) net-next 6/6] virtio: Add support for UDP tunnel offload and extension.
Date: Sat, 15 Apr 2017 12:38:18 -0400
Message-ID: <1492274298-17362-7-git-send-email-vyasevic@redhat.com>
References: <1492274298-17362-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@lists.linux-foundation.org,
        virtio-dev@lists.oasis-open.org, mst@redhat.com,
        jasowang@redhat.com, maxime.coquelin@redhat.com,
        Vladislav Yasevich <vyasevic@redhat.com>,
        Vlad Yasevich <vaysevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34274 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754160AbdDOQio (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 12:38:44 -0400
Received: by mail-qt0-f193.google.com with SMTP id y33so243929qta.1
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2017 09:38:43 -0700 (PDT)
In-Reply-To: <1492274298-17362-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides the ablility to negotiate UDP tunnel offload features
in the virtio devices as well as the necesary extension to pass additional
information to the host.  This work is based on earlier work by Jarno
Rajahalme <jarno@ovn.org).

The innert transport header offset is carried in a virtio net header
extension which is negotiated between the host and the guest.  When
the extension is enabled, device features to support UDP tunnel offload
are enabled.

Signed-off-by: Vlad Yasevich <vaysevic@redhat.com>
---
 drivers/net/virtio_net.c        | 36 ++++++++++++++++++++++++++------
 include/linux/skbuff.h          |  5 +++++
 include/linux/virtio_net.h      | 46 ++++++++++++++++++++++++++++++++++++++---
 include/uapi/linux/virtio_net.h | 13 ++++++++++++
 4 files changed, 91 insertions(+), 9 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 696ef4a..d122ecc 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -183,6 +183,7 @@ struct virtio_net_hdr_max {
 	struct virtio_net_ext_hdr ext_hdr;
 	struct virtio_net_ext_ip6frag ip6f_ext;
 	struct virtio_net_ext_vlan vlan_ext;
+	struct virtio_net_ext_udp_tunnel enc_ext;
 };
 
 static inline u8 padded_vnet_hdr(struct virtnet_info *vi)
@@ -738,6 +739,7 @@ static int receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 	struct sk_buff *skb;
 	struct virtio_net_hdr_mrg_rxbuf *hdr;
 	int ret;
+	bool little_endian = virtio_is_little_endian(vi->vdev);
 
 	if (unlikely(len < vi->hdr_len + ETH_HLEN)) {
 		pr_debug("%s: short packet %i\n", dev->name, len);
@@ -771,8 +773,7 @@ static int receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 	if (hdr->hdr.flags & VIRTIO_NET_HDR_F_DATA_VALID)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	if (virtio_net_hdr_to_skb(skb, &hdr->hdr,
-				  virtio_is_little_endian(vi->vdev))) {
+	if (virtio_net_hdr_to_skb(skb, &hdr->hdr, little_endian)) {
 		net_warn_ratelimited("%s: bad gso: type: %u, size: %u\n",
 				     dev->name, hdr->hdr.gso_type,
 				     hdr->hdr.gso_size);
@@ -781,7 +782,8 @@ static int receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 
 	if (vi->hdr_ext &&
 	    virtio_net_ext_to_skb(skb,
-				  (struct virtio_net_ext_hdr *)(hdr + 1))) {
+				  (struct virtio_net_ext_hdr *)(hdr + 1),
+				  little_endian)) {
 		goto frame_err;
 	}
 
@@ -1104,6 +1106,7 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 	unsigned num_sg;
 	unsigned hdr_len = vi->hdr_len;
 	bool can_push;
+	bool little_endian = virtio_is_little_endian(vi->vdev);
 
 	pr_debug("%s: xmit %p %pM\n", vi->dev->name, skb, dest);
 
@@ -1126,7 +1129,7 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 
 	if (vi->hdr_ext &&
 	    virtio_net_ext_from_skb(skb, (struct virtio_net_ext_hdr *)(hdr + 1),
-				    vi->ext_mask))
+				    vi->ext_mask, little_endian))
 		BUG();
 
 	sg_init_table(sq->sg, skb_shinfo(skb)->nr_frags + (can_push ? 1 : 2));
@@ -2282,6 +2285,11 @@ static void virtnet_init_extensions(struct virtio_device *vdev)
 		vi->hdr_len += sizeof(struct virtio_net_ext_vlan);
 		vi->ext_mask |= VIRTIO_NET_EXT_F_VLAN;
 	}
+
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_UDP_TUNNEL)) {
+		vi->hdr_len += sizeof(struct virtio_net_ext_udp_tunnel);
+		vi->ext_mask |= VIRTIO_NET_EXT_F_UDP_TUNNEL;
+	}
 }
 
 #define MIN_MTU ETH_MIN_MTU
@@ -2338,6 +2346,12 @@ static int virtnet_probe(struct virtio_device *vdev)
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
 			dev->hw_features |= NETIF_F_TSO | NETIF_F_UFO
 				| NETIF_F_TSO_ECN | NETIF_F_TSO6;
+
+			if (virtio_has_feature(vdev, VIRTIO_NET_F_UDP_TUNNEL)) {
+				dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL |
+						    NETIF_F_GSO_UDP_TUNNEL_CSUM |
+						    NETIF_F_GSO_TUNNEL_REMCSUM;
+			}
 		}
 		/* Individual feature bits: what can host handle? */
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_TSO4))
@@ -2348,11 +2362,20 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->hw_features |= NETIF_F_TSO_ECN;
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_UFO))
 			dev->hw_features |= NETIF_F_UFO;
+		if (virtio_has_feature(vdev, VIRTIO_NET_F_UDP_TUNNEL)) {
+			dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL |
+					    NETIF_F_GSO_UDP_TUNNEL_CSUM |
+					    NETIF_F_GSO_TUNNEL_REMCSUM;
+		}
+
 
 		dev->features |= NETIF_F_GSO_ROBUST;
 
 		if (gso)
-			dev->features |= dev->hw_features & (NETIF_F_ALL_TSO|NETIF_F_UFO);
+			dev->features |= dev->hw_features &
+					 (NETIF_F_ALL_TSO |
+					  NETIF_F_UFO |
+					  NETIF_F_GSO_ENCAP_ALL);
 		/* (!csum && gso) case will be fixed by register_netdev() */
 	}
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_CSUM))
@@ -2410,7 +2433,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 		vi->mergeable_rx_bufs = true;
 
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_IP6_FRAGID) ||
-	    virtio_has_feature(vdev, VIRTIO_NET_F_VLAN_OFFLOAD))
+	    virtio_has_feature(vdev, VIRTIO_NET_F_VLAN_OFFLOAD) ||
+	    virtio_has_feature(vdev, VIRTIO_NET_F_UDP_TUNNEL))
 		vi->hdr_ext = true;
 
 	if (vi->hdr_ext)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 741d75c..ad363da 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2270,6 +2270,11 @@ static inline int skb_inner_network_offset(const struct sk_buff *skb)
 	return skb_inner_network_header(skb) - skb->data;
 }
 
+static inline int skb_inner_mac_offset(const struct sk_buff *skb)
+{
+	return skb_inner_mac_header(skb) - skb->data;
+}
+
 static inline int pskb_network_may_pull(struct sk_buff *skb, unsigned int len)
 {
 	return pskb_may_pull(skb, skb_network_offset(skb) + len);
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index e790191..716ac32 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -11,7 +11,7 @@ static inline int virtio_net_hdr_to_skb(struct sk_buff *skb,
 	unsigned short gso_type = 0;
 
 	if (hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
-		switch (hdr->gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
+		switch (hdr->gso_type & ~VIRTIO_NET_HDR_GSO_FLAGS) {
 		case VIRTIO_NET_HDR_GSO_TCPV4:
 			gso_type = SKB_GSO_TCPV4;
 			break;
@@ -27,6 +27,14 @@ static inline int virtio_net_hdr_to_skb(struct sk_buff *skb,
 
 		if (hdr->gso_type & VIRTIO_NET_HDR_GSO_ECN)
 			gso_type |= SKB_GSO_TCP_ECN;
+		if (hdr->gso_type & VIRTIO_NET_HDR_GSO_UDP_TUNNEL)
+			gso_type |= SKB_GSO_UDP_TUNNEL;
+		if (hdr->gso_type & VIRTIO_NET_HDR_GSO_UDP_TUNNEL_CSUM)
+			gso_type |= SKB_GSO_UDP_TUNNEL_CSUM;
+		if (hdr->gso_type & VIRTIO_NET_HDR_GSO_TUNNEL_REMCSUM) {
+			gso_type |= SKB_GSO_TUNNEL_REMCSUM;
+			skb->remcsum_offload = true;
+		}
 
 		if (hdr->gso_size == 0)
 			return -EINVAL;
@@ -77,8 +85,15 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
 			hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP;
 		else
 			return -EINVAL;
+
 		if (sinfo->gso_type & SKB_GSO_TCP_ECN)
 			hdr->gso_type |= VIRTIO_NET_HDR_GSO_ECN;
+		if (sinfo->gso_type & SKB_GSO_UDP_TUNNEL)
+			hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP_TUNNEL;
+		if (sinfo->gso_type & SKB_GSO_UDP_TUNNEL_CSUM)
+			hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP_TUNNEL_CSUM;
+		if (sinfo->gso_type & SKB_GSO_TUNNEL_REMCSUM)
+			hdr->gso_type = VIRTIO_NET_HDR_GSO_TUNNEL_REMCSUM;
 	} else
 		hdr->gso_type = VIRTIO_NET_HDR_GSO_NONE;
 
@@ -101,7 +116,8 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
 }
 
 static inline int virtio_net_ext_to_skb(struct sk_buff *skb,
-					struct virtio_net_ext_hdr *ext)
+					struct virtio_net_ext_hdr *ext,
+					bool little_endian)
 {
 	__u8 *ptr = ext->extensions;
 
@@ -121,12 +137,27 @@ static inline int virtio_net_ext_to_skb(struct sk_buff *skb,
 		ptr += sizeof(struct virtio_net_ext_vlan);
 	}
 
+	if (ext->flags & VIRTIO_NET_EXT_F_UDP_TUNNEL) {
+		struct virtio_net_ext_udp_tunnel *uhdr =
+					(struct virtio_net_ext_udp_tunnel *)ptr;
+		u16 inner_offset = __virtio16_to_cpu(little_endian,
+						     uhdr->inner_mac_offset);
+
+		skb->encapsulation = 1;
+		skb_set_inner_mac_header(skb, inner_offset);
+		skb_set_inner_network_header(skb, inner_offset + ETH_HLEN);
+		/* this would be set by skb_partial_csum_set */
+		skb_set_inner_transport_header(skb,
+					       skb_checksum_start_offset(skb));
+	}
+
 	return 0;
 }
 
 static inline int virtio_net_ext_from_skb(const struct sk_buff *skb,
 					  struct virtio_net_ext_hdr *ext,
-					  __u32 ext_mask)
+					  __u32 ext_mask,
+					  bool little_endian)
 {
 	__u8 *ptr = ext->extensions;
 
@@ -147,6 +178,15 @@ static inline int virtio_net_ext_from_skb(const struct sk_buff *skb,
 		ext->flags |= VIRTIO_NET_EXT_F_VLAN;
 	}
 
+	if (ext_mask & VIRTIO_NET_EXT_F_UDP_TUNNEL && skb_is_gso(skb) &&
+	    skb->encapsulation) {
+		struct virtio_net_ext_udp_tunnel *uhdr =
+					(struct virtio_net_ext_udp_tunnel *)ptr;
+
+		uhdr->inner_mac_offset = skb_inner_mac_offset(skb);
+		ext->flags |= VIRTIO_NET_EXT_F_UDP_TUNNEL;
+	}
+
 	return 0;
 }
 #endif /* _LINUX_VIRTIO_NET_H */
diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index 6125de7..26ddacf 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -58,6 +58,7 @@
 #define VIRTIO_NET_F_CTRL_MAC_ADDR 23	/* Set MAC address */
 #define VIRTIO_NET_F_IP6_FRAGID    24	/* Host supports VLAN accleration */
 #define VIRTIO_NET_F_VLAN_OFFLOAD 25	/* Host supports VLAN accleration */
+#define VIRTIO_NET_F_UDP_TUNNEL    26   /* Host supports UDP tunnel offload */
 
 #ifndef VIRTIO_NET_NO_LEGACY
 #define VIRTIO_NET_F_GSO	6	/* Host handles pkts w/ any GSO type */
@@ -96,7 +97,14 @@ struct virtio_net_hdr_v1 {
 #define VIRTIO_NET_HDR_GSO_TCPV4	1	/* GSO frame, IPv4 TCP (TSO) */
 #define VIRTIO_NET_HDR_GSO_UDP		3	/* GSO frame, IPv4 UDP (UFO) */
 #define VIRTIO_NET_HDR_GSO_TCPV6	4	/* GSO frame, IPv6 TCP */
+#define VIRTIO_NET_HDR_GSO_UDP_TUNNEL	0x10	/* GSO frame, UDP tunnel */
+#define VIRTIO_NET_HDR_GSO_UDP_TUNNEL_CSUM 0x20 /* GSO frame, UDP tnl + csum */
+#define VIRTIO_NET_HDR_GSO_TUNNEL_REMCSUM  0x40	/* tunnel with TSO + remcsum */
 #define VIRTIO_NET_HDR_GSO_ECN		0x80	/* TCP has ECN set */
+#define VIRTIO_NET_HDR_GSO_FLAGS	(VIRTIO_NET_HDR_GSO_UDP_TUNNEL | \
+					 VIRTIO_NET_HDR_GSO_UDP_TUNNEL_CSUM | \
+					 VIRTIO_NET_HDR_GSO_TUNNEL_REMCSUM | \
+					 VIRTIO_NET_HDR_GSO_ECN)
 	__u8 gso_type;
 	__virtio16 hdr_len;	/* Ethernet + IP + tcp/udp hdrs */
 	__virtio16 gso_size;	/* Bytes to append to hdr_len per frame */
@@ -113,6 +121,7 @@ struct virtio_net_hdr_v1 {
 struct virtio_net_ext_hdr {
 #define VIRTIO_NET_EXT_F_IP6FRAG	(1<<0)
 #define VIRTIO_NET_EXT_F_VLAN		(1<<1)
+#define VIRTIO_NET_EXT_F_UDP_TUNNEL	(1<<2)
 	__u32 flags;
 	__u8 extensions[];
 };
@@ -127,6 +136,10 @@ struct virtio_net_ext_vlan {
 	__be16 vlan_proto;
 };
 
+struct virtio_net_ext_udp_tunnel {
+	__virtio16 inner_mac_offset;
+};
+
 #ifndef VIRTIO_NET_NO_LEGACY
 /* This header comes first in the scatter-gather list.
  * For legacy virtio, if VIRTIO_F_ANY_LAYOUT is not negotiated, it must
-- 
2.7.4
