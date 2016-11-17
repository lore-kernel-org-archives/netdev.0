From: Jarno Rajahalme <jarno@ovn.org>
Subject: [RFC PATCH net-next] virtio_net: Support UDP Tunnel offloads.
Date: Thu, 17 Nov 2016 15:01:57 -0800
Message-ID: <1479423717-2339-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org, james.zhangming@huawei.com, mst@redhat.com,
        vyasevic@redhat.com, ailan@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:54025 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751609AbcKQXC0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 18:02:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a proof-of-concept I did a few months ago for UDP tunnel
offload support in virtio_net interface, and rebased on to the current
net-next.

Real implementation needs to extend the virtio_net header rather than
piggy-backing on existing fields.  Inner MAC length (or inner network
offset) also needs to be passed as a new field.  Control plane (QEMU)
also needs to be updated.

All testing was done using Geneve, but this should work for all UDP
tunnels the same.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 drivers/net/tun.c               |  7 ++++-
 drivers/net/virtio_net.c        | 16 +++++++---
 include/linux/skbuff.h          |  5 ++++
 include/linux/virtio_net.h      | 66 ++++++++++++++++++++++++++++++-----------
 include/uapi/linux/virtio_net.h |  7 +++++
 5 files changed, 78 insertions(+), 23 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 1588469..36f3219 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -198,7 +198,9 @@ struct tun_struct {
 	struct net_device	*dev;
 	netdev_features_t	set_features;
 #define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO| \
-			  NETIF_F_TSO6|NETIF_F_UFO)
+			   NETIF_F_TSO6|NETIF_F_UFO|NETIF_F_GSO_UDP_TUNNEL| \
+			   NETIF_F_GSO_UDP_TUNNEL_CSUM| \
+			   NETIF_F_GSO_TUNNEL_REMCSUM)
 
 	int			align;
 	int			vnet_hdr_sz;
@@ -1877,6 +1879,9 @@ static int set_offload(struct tun_struct *tun, unsigned long arg)
 
 		if (arg & TUN_F_UFO) {
 			features |= NETIF_F_UFO;
+#if 1
+			features |= NETIF_F_GSO_UDP_TUNNEL|NETIF_F_GSO_UDP_TUNNEL_CSUM|NETIF_F_GSO_TUNNEL_REMCSUM;
+#endif
 			arg &= ~TUN_F_UFO;
 		}
 	}
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index ca5239a..eb8d887 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1789,7 +1789,10 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
 			dev->hw_features |= NETIF_F_TSO | NETIF_F_UFO
-				| NETIF_F_TSO_ECN | NETIF_F_TSO6;
+				| NETIF_F_TSO_ECN | NETIF_F_TSO6
+				| NETIF_F_GSO_UDP_TUNNEL
+				| NETIF_F_GSO_UDP_TUNNEL_CSUM
+				| NETIF_F_GSO_TUNNEL_REMCSUM;
 		}
 		/* Individual feature bits: what can host handle? */
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_TSO4))
@@ -1798,13 +1801,18 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->hw_features |= NETIF_F_TSO6;
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_ECN))
 			dev->hw_features |= NETIF_F_TSO_ECN;
-		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_UFO))
+		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_UFO)) {
 			dev->hw_features |= NETIF_F_UFO;
-
+#if 1
+			dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
+			dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL_CSUM;
+			dev->hw_features |= NETIF_F_GSO_TUNNEL_REMCSUM;
+#endif
+		}
 		dev->features |= NETIF_F_GSO_ROBUST;
 
 		if (gso)
-			dev->features |= dev->hw_features & (NETIF_F_ALL_TSO|NETIF_F_UFO);
+			dev->features |= dev->hw_features & (NETIF_F_ALL_TSO|NETIF_F_UFO|NETIF_F_GSO_UDP_TUNNEL|NETIF_F_GSO_UDP_TUNNEL_CSUM|NETIF_F_GSO_TUNNEL_REMCSUM);
 		/* (!csum && gso) case will be fixed by register_netdev() */
 	}
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_CSUM))
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a4aeeca..992ad30 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2115,6 +2115,11 @@ static inline unsigned char *skb_inner_mac_header(const struct sk_buff *skb)
 	return skb->head + skb->inner_mac_header;
 }
 
+static inline int skb_inner_mac_offset(const struct sk_buff *skb)
+{
+	return skb_inner_mac_header(skb) - skb->data;
+}
+
 static inline void skb_reset_inner_mac_header(struct sk_buff *skb)
 {
 	skb->inner_mac_header = skb->data - skb->head;
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 1c912f8..17384d1 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -8,10 +8,19 @@ static inline int virtio_net_hdr_to_skb(struct sk_buff *skb,
 					const struct virtio_net_hdr *hdr,
 					bool little_endian)
 {
-	unsigned short gso_type = 0;
+	u16 start = __virtio16_to_cpu(little_endian, hdr->csum_start);
+
+	if (hdr->flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
+		u16 off = __virtio16_to_cpu(little_endian, hdr->csum_offset);
+
+		if (!skb_partial_csum_set(skb, start, off))
+			return -EINVAL;
+	}
 
 	if (hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
-		switch (hdr->gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
+		unsigned short gso_type = 0;
+
+		switch (hdr->gso_type & ~VIRTIO_NET_HDR_GSO_FLAGS) {
 		case VIRTIO_NET_HDR_GSO_TCPV4:
 			gso_type = SKB_GSO_TCPV4;
 			break;
@@ -27,23 +36,28 @@ static inline int virtio_net_hdr_to_skb(struct sk_buff *skb,
 
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
+		if (gso_type & (SKB_GSO_UDP_TUNNEL | SKB_GSO_UDP_TUNNEL_CSUM)) {
+			u16 hdr_len = __virtio16_to_cpu(little_endian,
+							hdr->hdr_len);
+			skb->encapsulation = 1;
+			skb_set_inner_mac_header(skb, hdr_len);
+			skb_set_inner_network_header(skb, hdr_len + ETH_HLEN);
+			/* XXX: What if start is not set? */
+			skb_set_inner_transport_header(skb, start);
+		}
 
 		if (hdr->gso_size == 0)
 			return -EINVAL;
-	}
-
-	if (hdr->flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
-		u16 start = __virtio16_to_cpu(little_endian, hdr->csum_start);
-		u16 off = __virtio16_to_cpu(little_endian, hdr->csum_offset);
-
-		if (!skb_partial_csum_set(skb, start, off))
-			return -EINVAL;
-	}
-
-	if (hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
-		u16 gso_size = __virtio16_to_cpu(little_endian, hdr->gso_size);
-
-		skb_shinfo(skb)->gso_size = gso_size;
+		skb_shinfo(skb)->gso_size = __virtio16_to_cpu(little_endian,
+							      hdr->gso_size);
 		skb_shinfo(skb)->gso_type = gso_type;
 
 		/* Header must be checked, and gso_segs computed. */
@@ -64,8 +78,8 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
 		struct skb_shared_info *sinfo = skb_shinfo(skb);
 
 		/* This is a hint as to how much should be linear. */
-		hdr->hdr_len = __cpu_to_virtio16(little_endian,
-						 skb_headlen(skb));
+		u16 hdr_len = skb_headlen(skb);
+
 		hdr->gso_size = __cpu_to_virtio16(little_endian,
 						  sinfo->gso_size);
 		if (sinfo->gso_type & SKB_GSO_TCPV4)
@@ -78,6 +92,22 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
 			return -EINVAL;
 		if (sinfo->gso_type & SKB_GSO_TCP_ECN)
 			hdr->gso_type |= VIRTIO_NET_HDR_GSO_ECN;
+		if (sinfo->gso_type & SKB_GSO_UDP_TUNNEL)
+			hdr->gso_type |= VIRTIO_NET_HDR_GSO_UDP_TUNNEL;
+		if (sinfo->gso_type & SKB_GSO_UDP_TUNNEL_CSUM)
+			hdr->gso_type |= VIRTIO_NET_HDR_GSO_UDP_TUNNEL_CSUM;
+		if (sinfo->gso_type & SKB_GSO_TUNNEL_REMCSUM)
+			hdr->gso_type |= VIRTIO_NET_HDR_GSO_TUNNEL_REMCSUM;
+
+		if (sinfo->gso_type &
+		    (SKB_GSO_UDP_TUNNEL | SKB_GSO_UDP_TUNNEL_CSUM))
+			/* For encapsulated packets 'hdr_len' is the offset to
+			 * the beginning of the inner packet.  This way the
+			 * encapsulation can remain ignorant of the size of the
+			 * UDP tunnel header.
+			 */
+			hdr_len = skb_inner_mac_offset(skb);
+		hdr->hdr_len = __cpu_to_virtio16(little_endian, hdr_len);
 	} else
 		hdr->gso_type = VIRTIO_NET_HDR_GSO_NONE;
 
diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index fc353b5..833950b 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -93,7 +93,14 @@ struct virtio_net_hdr_v1 {
 #define VIRTIO_NET_HDR_GSO_TCPV4	1	/* GSO frame, IPv4 TCP (TSO) */
 #define VIRTIO_NET_HDR_GSO_UDP		3	/* GSO frame, IPv4 UDP (UFO) */
 #define VIRTIO_NET_HDR_GSO_TCPV6	4	/* GSO frame, IPv6 TCP */
+#define VIRTIO_NET_HDR_GSO_UDP_TUNNEL	0x10	/* GSO frame, UDP tunnel */
+#define VIRTIO_NET_HDR_GSO_UDP_TUNNEL_CSUM 0x20	/* GSO frame, UDP tnl w CSUM */
+#define VIRTIO_NET_HDR_GSO_TUNNEL_REMCSUM 0x40	/* TUNNEL with TSO & REMCSUM */
 #define VIRTIO_NET_HDR_GSO_ECN		0x80	/* TCP has ECN set */
+#define VIRTIO_NET_HDR_GSO_FLAGS (VIRTIO_NET_HDR_GSO_UDP_TUNNEL | \
+				  VIRTIO_NET_HDR_GSO_UDP_TUNNEL_CSUM | \
+				  VIRTIO_NET_HDR_GSO_TUNNEL_REMCSUM | \
+				  VIRTIO_NET_HDR_GSO_ECN)
 	__u8 gso_type;
 	__virtio16 hdr_len;	/* Ethernet + IP + tcp/udp hdrs */
 	__virtio16 gso_size;	/* Bytes to append to hdr_len per frame */
-- 
2.1.4
