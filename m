From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [RFC PATCH 3/6] virtio_net: Add basic skeleton for handling vnet header extensions.
Date: Sun, 19 Mar 2017 00:06:34 -0400
Message-ID: <1489896397-2275-4-git-send-email-vyasevic@redhat.com>
References: <1489896397-2275-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@list.linux-foundation.org, mst@redhat.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35320 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751395AbdCSEG4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 00:06:56 -0400
Received: by mail-qk0-f194.google.com with SMTP id o135so14359701qke.2
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 21:06:54 -0700 (PDT)
In-Reply-To: <1489896397-2275-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the basic sceleton which will be fleshed out by individiual
extensions.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/virtio_net.c        | 21 +++++++++++++++++++++
 include/linux/virtio_net.h      | 12 ++++++++++++
 include/uapi/linux/virtio_net.h | 11 +++++++++++
 3 files changed, 44 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 2905d52..b61de96 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -132,6 +132,10 @@ struct virtnet_info {
 	/* Packet virtio header size */
 	u8 hdr_len;
 
+	/* Header extensions were negotiated */
+	bool hdr_ext;
+	u32 ext_mask;
+
 	/* Active statistics */
 	struct virtnet_stats __percpu *stats;
 
@@ -161,6 +165,11 @@ struct virtnet_info {
 	u32 speed;
 };
 
+struct virtio_net_hdr_max {
+	struct virtio_net_hdr_mrg_rxbuf hdr;
+	struct virtio_net_ext_hdr ext_hdr;
+};
+
 static inline u8 padded_vnet_hdr(struct virtnet_info *vi)
 {
 	u8 hdr_len = vi->hdr_len;
@@ -201,6 +210,7 @@ static int rxq2vq(int rxq)
 
 static inline struct virtio_net_hdr_mrg_rxbuf *skb_vnet_hdr(struct sk_buff *skb)
 {
+	BUILD_BUG_ON(sizeof(struct virtio_net_hdr_max) > sizeof(skb->cb));
 	return (struct virtio_net_hdr_mrg_rxbuf *)skb->cb;
 }
 
@@ -759,6 +769,12 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 		goto frame_err;
 	}
 
+	if (vi->hdr_ext &&
+	    virtio_net_ext_to_skb(skb,
+				  (struct virtio_net_ext_hdr *)(hdr + 1))) {
+		goto frame_err;
+	}
+
 	skb->protocol = eth_type_trans(skb, dev);
 	pr_debug("Receiving skb proto 0x%04x len %i type %i\n",
 		 ntohs(skb->protocol), skb->len, skb->pkt_type);
@@ -1114,6 +1130,11 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 	if (vi->mergeable_rx_bufs)
 		hdr->num_buffers = 0;
 
+	if (vi->hdr_ext &&
+	    virtio_net_ext_from_skb(skb, (struct virtio_net_ext_hdr *)(hdr + 1),
+				    vi->ext_mask))
+		BUG();
+
 	sg_init_table(sq->sg, skb_shinfo(skb)->nr_frags + (can_push ? 1 : 2));
 	if (can_push) {
 		__skb_push(skb, hdr_len);
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 5643647..4790ade 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -96,4 +96,16 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
 	return 0;
 }
 
+static inline int virtio_net_ext_to_skb(struct sk_buff *skb,
+					struct virtio_net_ext_hdr *ext)
+{
+	return 0;
+}
+
+static inline int virtio_net_ext_from_skb(const struct sk_buff *skb,
+					  struct virtio_net_ext_hdr *ext,
+					  __u32 ext_mask)
+{
+	return 0;
+}
 #endif /* _LINUX_VIRTIO_NET_H */
diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index fc353b5..0039b72 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -88,6 +88,7 @@ struct virtio_net_config {
 struct virtio_net_hdr_v1 {
 #define VIRTIO_NET_HDR_F_NEEDS_CSUM	1	/* Use csum_start, csum_offset */
 #define VIRTIO_NET_HDR_F_DATA_VALID	2	/* Csum is valid */
+#define VIRTIO_NET_HDR_F_VNET_EXT	4	/* Vnet extensions present */
 	__u8 flags;
 #define VIRTIO_NET_HDR_GSO_NONE		0	/* Not a GSO frame */
 #define VIRTIO_NET_HDR_GSO_TCPV4	1	/* GSO frame, IPv4 TCP (TSO) */
@@ -102,6 +103,16 @@ struct virtio_net_hdr_v1 {
 	__virtio16 num_buffers;	/* Number of merged rx buffers */
 };
 
+/* If IRTIO_NET_HDR_F_VNET_EXT flags is set, this header immediately
+ * follows the virtio_net_hdr.  The flags in this header will indicate
+ * which extension will follow.  The extnsion data will immidiately follow
+ * this header.
+ */
+struct virtio_net_ext_hdr {
+	__u32 flags;
+	__u8 extensions[];
+};
+
 #ifndef VIRTIO_NET_NO_LEGACY
 /* This header comes first in the scatter-gather list.
  * For legacy virtio, if VIRTIO_F_ANY_LAYOUT is not negotiated, it must
-- 
2.7.4
