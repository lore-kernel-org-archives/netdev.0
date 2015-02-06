From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 3/5] virtio: Don't expose legacy net features when VIRTIO_NET_NO_LEGACY defined.
Date: Fri,  6 Feb 2015 15:36:54 +1030
Message-ID: <1423199216-2094-4-git-send-email-rusty@rustcorp.com.au>
References: <1423199216-2094-1-git-send-email-rusty@rustcorp.com.au>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "lkml" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423199216-2094-1-git-send-email-rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In particular, the virtio header always has the u16 num_buffers field.
We define a new 'struct virtio_net_modern_hdr' for this (rather than
simply calling it 'struct virtio_net_hdr', to avoid nasty type errors
if some parts of a project define VIRTIO_NET_NO_LEGACY and some don't.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 include/uapi/linux/virtio_net.h | 30 ++++++++++++++++++++++++++++--
 1 file changed, 28 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index b5f1677b291c..32754f3000e8 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -35,7 +35,6 @@
 #define VIRTIO_NET_F_CSUM	0	/* Host handles pkts w/ partial csum */
 #define VIRTIO_NET_F_GUEST_CSUM	1	/* Guest handles pkts w/ partial csum */
 #define VIRTIO_NET_F_MAC	5	/* Host has given MAC address. */
-#define VIRTIO_NET_F_GSO	6	/* Host handles pkts w/ any GSO type */
 #define VIRTIO_NET_F_GUEST_TSO4	7	/* Guest can handle TSOv4 in. */
 #define VIRTIO_NET_F_GUEST_TSO6	8	/* Guest can handle TSOv6 in. */
 #define VIRTIO_NET_F_GUEST_ECN	9	/* Guest can handle TSO[6] w/ ECN in. */
@@ -56,6 +55,10 @@
 					 * Steering */
 #define VIRTIO_NET_F_CTRL_MAC_ADDR 23	/* Set MAC address */
 
+#ifndef VIRTIO_NET_NO_LEGACY
+#define VIRTIO_NET_F_GSO	6	/* Host handles pkts w/ any GSO type */
+#endif /* VIRTIO_NET_NO_LEGACY */
+
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 #define VIRTIO_NET_S_ANNOUNCE	2	/* Announcement is needed */
 
@@ -71,8 +74,9 @@ struct virtio_net_config {
 	__u16 max_virtqueue_pairs;
 } __attribute__((packed));
 
+#ifndef VIRTIO_NET_NO_LEGACY
 /* This header comes first in the scatter-gather list.
- * If VIRTIO_F_ANY_LAYOUT is not negotiated, it must
+ * For legacy virtio, if VIRTIO_F_ANY_LAYOUT is not negotiated, it must
  * be the first element of the scatter-gather list.  If you don't
  * specify GSO or CSUM features, you can simply ignore the header. */
 struct virtio_net_hdr {
@@ -97,6 +101,28 @@ struct virtio_net_hdr_mrg_rxbuf {
 	struct virtio_net_hdr hdr;
 	__virtio16 num_buffers;	/* Number of merged rx buffers */
 };
+#else /* ... VIRTIO_NET_NO_LEGACY */
+/*
+ * This header comes first in the scatter-gather list.  If you don't
+ * specify GSO or CSUM features, you can simply ignore the header.
+ */
+struct virtio_net_modern_hdr {
+#define VIRTIO_NET_HDR_F_NEEDS_CSUM	1	/* Use csum_start, csum_offset */
+#define VIRTIO_NET_HDR_F_DATA_VALID	2	/* Csum is valid */
+	__u8 flags;
+#define VIRTIO_NET_HDR_GSO_NONE		0	/* Not a GSO frame */
+#define VIRTIO_NET_HDR_GSO_TCPV4	1	/* GSO frame, IPv4 TCP (TSO) */
+#define VIRTIO_NET_HDR_GSO_UDP		3	/* GSO frame, IPv4 UDP (UFO) */
+#define VIRTIO_NET_HDR_GSO_TCPV6	4	/* GSO frame, IPv6 TCP */
+#define VIRTIO_NET_HDR_GSO_ECN		0x80	/* TCP has ECN set */
+	__u8 gso_type;
+	__virtio16 hdr_len;	/* Ethernet + IP + tcp/udp hdrs */
+	__virtio16 gso_size;	/* Bytes to append to hdr_len per frame */
+	__virtio16 csum_start;	/* Position to start checksumming from */
+	__virtio16 csum_offset;	/* Offset after that to place checksum */
+	__virtio16 num_buffers;	/* Number of merged rx buffers */
+};
+#endif /* ...VIRTIO_NET_NO_LEGACY */
 
 /*
  * Control virtqueue data structures
-- 
2.1.0
