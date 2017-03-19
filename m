From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [RFC PATCH 5/6] virtio-net: Add support for vlan acceleration vnet header extension.
Date: Sun, 19 Mar 2017 00:06:36 -0400
Message-ID: <1489896397-2275-6-git-send-email-vyasevic@redhat.com>
References: <1489896397-2275-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@list.linux-foundation.org, mst@redhat.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33734 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751395AbdCSEG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 00:06:59 -0400
Received: by mail-qk0-f195.google.com with SMTP id j127so14345043qke.0
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 21:06:58 -0700 (PDT)
In-Reply-To: <1489896397-2275-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This extension allows us to pass vlan ID and vlan protocol data to the
host hypervisor as part of the vnet header and lets us take advantage
of HW accelerated vlan tagging in the host.  It requires support in the
host to negotiate the feature.  When the extension is enabled, the
virtio device will enabled HW accelerated vlan features.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/virtio_net.c        | 17 ++++++++++++++++-
 include/linux/virtio_net.h      | 17 +++++++++++++++++
 include/uapi/linux/virtio_net.h |  7 +++++++
 3 files changed, 40 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 7ea717b..5221111 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -169,6 +169,7 @@ struct virtio_net_hdr_max {
 	struct virtio_net_hdr_mrg_rxbuf hdr;
 	struct virtio_net_ext_hdr ext_hdr;
 	struct virtio_net_ext_ip6frag ip6f_ext;
+	struct virtio_net_ext_vlan vlan_ext;
 };
 
 static inline u8 padded_vnet_hdr(struct virtnet_info *vi)
@@ -2171,6 +2172,11 @@ static void virtnet_init_extensions(struct virtio_device *vdev)
 		vi->hdr_len += sizeof(u32);
 		vi->ext_mask |= VIRTIO_NET_EXT_F_IP6FRAG;
 	}
+
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_VLAN_OFFLOAD)) {
+		vi->hdr_len += sizeof(struct virtio_net_ext_vlan);
+		vi->ext_mask |= VIRTIO_NET_EXT_F_VLAN;
+	}
 }
 
 #define MIN_MTU ETH_MIN_MTU
@@ -2247,6 +2253,14 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_CSUM))
 		dev->features |= NETIF_F_RXCSUM;
 
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_VLAN_OFFLOAD)) {
+		dev->features |= NETIF_F_HW_VLAN_CTAG_TX |
+				 NETIF_F_HW_VLAN_CTAG_RX |
+				 NETIF_F_HW_VLAN_STAG_TX |
+				 NETIF_F_HW_VLAN_STAG_RX;
+	}
+
+
 	dev->vlan_features = dev->features;
 
 	/* MTU range: 68 - 65535 */
@@ -2290,7 +2304,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
 		vi->mergeable_rx_bufs = true;
 
-	if (virtio_has_feature(vdev, VIRTIO_NET_F_IP6_FRAGID))
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_IP6_FRAGID) ||
+	    virtio_has_feature(vdev, VIRTIO_NET_F_VLAN_OFFLOAD))
 		vi->hdr_ext = true;
 
 	if (vi->hdr_ext)
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 663214f..8e70fdb 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -109,6 +109,14 @@ static inline int virtio_net_ext_to_skb(struct sk_buff *skb,
 		ptr += sizeof(struct virtio_net_ext_ip6frag);
 	}
 
+	if (ext->flags & VIRTIO_NET_EXT_F_VLAN) {
+		struct virtio_net_ext_vlan *vhdr =
+					(struct virtio_net_ext_vlan *)ptr;
+
+		__vlan_hwaccel_put_tag(skb, vhdr->vlan_proto, vhdr->vlan_tci);
+		ptr += sizeof(struct virtio_net_ext_vlan);
+	}
+
 	return 0;
 }
 
@@ -126,6 +134,15 @@ static inline int virtio_net_ext_from_skb(const struct sk_buff *skb,
 		ext->flags |= VIRTIO_NET_EXT_F_IP6FRAG;
 	}
 
+	if (ext_mask & VIRTIO_NET_EXT_F_VLAN && skb_vlan_tag_present(skb)) {
+		struct virtio_net_ext_vlan *vhdr =
+					(struct virtio_net_ext_vlan *)ptr;
+
+		vlan_get_tag(skb, &vhdr->vlan_tci);
+		vhdr->vlan_proto = skb->vlan_proto;
+		ext->flags |= VIRTIO_NET_EXT_F_VLAN;
+	}
+
 	return 0;
 }
 #endif /* _LINUX_VIRTIO_NET_H */
diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index eac8d94..6125de7 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -57,6 +57,7 @@
 					 * Steering */
 #define VIRTIO_NET_F_CTRL_MAC_ADDR 23	/* Set MAC address */
 #define VIRTIO_NET_F_IP6_FRAGID    24	/* Host supports VLAN accleration */
+#define VIRTIO_NET_F_VLAN_OFFLOAD 25	/* Host supports VLAN accleration */
 
 #ifndef VIRTIO_NET_NO_LEGACY
 #define VIRTIO_NET_F_GSO	6	/* Host handles pkts w/ any GSO type */
@@ -111,6 +112,7 @@ struct virtio_net_hdr_v1 {
  */
 struct virtio_net_ext_hdr {
 #define VIRTIO_NET_EXT_F_IP6FRAG	(1<<0)
+#define VIRTIO_NET_EXT_F_VLAN		(1<<1)
 	__u32 flags;
 	__u8 extensions[];
 };
@@ -120,6 +122,11 @@ struct virtio_net_ext_ip6frag {
 	__be32 frag_id;
 };
 
+struct virtio_net_ext_vlan {
+	__be16 vlan_tci;
+	__be16 vlan_proto;
+};
+
 #ifndef VIRTIO_NET_NO_LEGACY
 /* This header comes first in the scatter-gather list.
  * For legacy virtio, if VIRTIO_F_ANY_LAYOUT is not negotiated, it must
-- 
2.7.4
