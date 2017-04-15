From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH RFC (resend) net-next 4/6] virtio-net: Add support for IPv6 fragment id vnet header extension.
Date: Sat, 15 Apr 2017 12:38:16 -0400
Message-ID: <1492274298-17362-5-git-send-email-vyasevic@redhat.com>
References: <1492274298-17362-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@lists.linux-foundation.org,
        virtio-dev@lists.oasis-open.org, mst@redhat.com,
        jasowang@redhat.com, maxime.coquelin@redhat.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35281 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754405AbdDOQil (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 12:38:41 -0400
Received: by mail-qt0-f196.google.com with SMTP id o36so14303640qtb.2
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2017 09:38:41 -0700 (PDT)
In-Reply-To: <1492274298-17362-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the ability to pass a guest generated IPv6 fragment id to the
host hypervisor.  The id is passed as big endian to eliminate unnecessary
conversions.  The host will be able to directly use this id instead of
attempting to generate its own.  This makes the IPv6 framgnet id sligtly
harder to predict.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/virtio_net.c        | 27 +++++++++++++++++++++++++--
 include/linux/virtio_net.h      | 20 ++++++++++++++++++++
 include/uapi/linux/virtio_net.h |  7 +++++++
 3 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 08e2709..18eb0dd 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -181,6 +181,7 @@ struct virtnet_info {
 struct virtio_net_hdr_max {
 	struct virtio_net_hdr_mrg_rxbuf hdr;
 	struct virtio_net_ext_hdr ext_hdr;
+	struct virtio_net_ext_ip6frag ip6f_ext;
 };
 
 static inline u8 padded_vnet_hdr(struct virtnet_info *vi)
@@ -2260,6 +2261,23 @@ static bool virtnet_validate_features(struct virtio_device *vdev)
 	return true;
 }
 
+static void virtnet_init_extensions(struct virtio_device *vdev)
+{
+	struct virtnet_info *vi = vdev->priv;
+
+	/* Start with V1 header size plus the extension header */
+	vi->hdr_len = sizeof(struct virtio_net_hdr_v1) +
+		      sizeof(struct virtio_net_ext_hdr);
+
+	/* now check all the negotiated extensions and add up
+	 * the sizes
+	 */
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_IP6_FRAGID)) {
+		vi->hdr_len += sizeof(u32);
+		vi->ext_mask |= VIRTIO_NET_EXT_F_IP6FRAG;
+	}
+}
+
 #define MIN_MTU ETH_MIN_MTU
 #define MAX_MTU ETH_MAX_MTU
 
@@ -2377,8 +2395,13 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
 		vi->mergeable_rx_bufs = true;
 
-	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF) ||
-	    virtio_has_feature(vdev, VIRTIO_F_VERSION_1))
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_IP6_FRAGID))
+		vi->hdr_ext = true;
+
+	if (vi->hdr_ext)
+		virtnet_init_extensions(vdev);
+	else if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF) ||
+		 virtio_has_feature(vdev, VIRTIO_F_VERSION_1))
 		vi->hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
 	else
 		vi->hdr_len = sizeof(struct virtio_net_hdr);
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index eaa524f..3b259dc 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -103,6 +103,16 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
 static inline int virtio_net_ext_to_skb(struct sk_buff *skb,
 					struct virtio_net_ext_hdr *ext)
 {
+	__u8 *ptr = ext->extensions;
+
+	if (ext->flags & VIRTIO_NET_EXT_F_IP6FRAG) {
+		struct virtio_net_ext_ip6frag *fhdr =
+					(struct virtio_net_ext_ip6frag *)ptr;
+
+		skb_shinfo(skb)->ip6_frag_id = fhdr->frag_id;
+		ptr += sizeof(struct virtio_net_ext_ip6frag);
+	}
+
 	return 0;
 }
 
@@ -110,6 +120,16 @@ static inline int virtio_net_ext_from_skb(const struct sk_buff *skb,
 					  struct virtio_net_ext_hdr *ext,
 					  __u32 ext_mask)
 {
+	__u8 *ptr = ext->extensions;
+
+	if ((ext_mask & VIRTIO_NET_EXT_F_IP6FRAG) &&
+	    skb_shinfo(skb)->ip6_frag_id) {
+		struct virtio_net_ext_ip6frag *fhdr =
+					(struct virtio_net_ext_ip6frag *)ptr;
+		fhdr->frag_id = skb_shinfo(skb)->ip6_frag_id;
+		ext->flags |= VIRTIO_NET_EXT_F_IP6FRAG;
+	}
+
 	return 0;
 }
 #endif /* _LINUX_VIRTIO_NET_H */
diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index 0039b72..eac8d94 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -56,6 +56,7 @@
 #define VIRTIO_NET_F_MQ	22	/* Device supports Receive Flow
 					 * Steering */
 #define VIRTIO_NET_F_CTRL_MAC_ADDR 23	/* Set MAC address */
+#define VIRTIO_NET_F_IP6_FRAGID    24	/* Host supports VLAN accleration */
 
 #ifndef VIRTIO_NET_NO_LEGACY
 #define VIRTIO_NET_F_GSO	6	/* Host handles pkts w/ any GSO type */
@@ -109,10 +110,16 @@ struct virtio_net_hdr_v1 {
  * this header.
  */
 struct virtio_net_ext_hdr {
+#define VIRTIO_NET_EXT_F_IP6FRAG	(1<<0)
 	__u32 flags;
 	__u8 extensions[];
 };
 
+/* Same as vlan_hdr */
+struct virtio_net_ext_ip6frag {
+	__be32 frag_id;
+};
+
 #ifndef VIRTIO_NET_NO_LEGACY
 /* This header comes first in the scatter-gather list.
  * For legacy virtio, if VIRTIO_F_ANY_LAYOUT is not negotiated, it must
-- 
2.7.4
