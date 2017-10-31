From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [RFC PATCH 01/14] packet: introduce AF_PACKET V4 userspace API
Date: Tue, 31 Oct 2017 13:41:32 +0100
Message-ID: <20171031124145.9667-2-bjorn.topel@gmail.com>
References: <20171031124145.9667-1-bjorn.topel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
        jesse.brandeburg@intel.com, anjali.singhai@intel.com,
        rami.rosen@intel.com, jeffrey.b.shaw@intel.com,
        ferruh.yigit@intel.com, qi.z.zhang@intel.com
To: bjorn.topel@gmail.com, magnus.karlsson@intel.com,
        alexander.h.duyck@intel.com, alexander.duyck@gmail.com,
        john.fastabend@gmail.com, ast@fb.com, brouer@redhat.com,
        michael.lundkvist@ericsson.com, ravineet.singh@ericsson.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:46837 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751487AbdJaMmM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 08:42:12 -0400
In-Reply-To: <20171031124145.9667-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Björn Töpel <bjorn.topel@intel.com>

This patch adds the necessary AF_PACKET V4 structures for usage from
userspace. AF_PACKET V4 is a new interface optimized for high
performance packet processing.

Signed-off-by: Björn Töpel <bjorn.topel@intel.com>
---
 include/uapi/linux/if_packet.h | 65 +++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 64 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index 4df96a7dd4fa..8eabcd1b370a 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -56,6 +56,8 @@ struct sockaddr_ll {
 #define PACKET_QDISC_BYPASS		20
 #define PACKET_ROLLOVER_STATS		21
 #define PACKET_FANOUT_DATA		22
+#define PACKET_MEMREG			23
+#define PACKET_ZEROCOPY			24
 
 #define PACKET_FANOUT_HASH		0
 #define PACKET_FANOUT_LB		1
@@ -243,13 +245,35 @@ struct tpacket_block_desc {
 	union tpacket_bd_header_u hdr;
 };
 
+#define TP4_DESC_KERNEL	0x0080 /* The descriptor is owned by the kernel */
+#define TP4_PKT_CONT	1 /* The packet continues in the next descriptor */
+
+struct tpacket4_desc {
+	__u32 idx;
+	__u32 len;
+	__u16 offset;
+	__u8  error; /* an errno */
+	__u8  flags;
+	__u8  padding[4];
+};
+
+struct tpacket4_queue {
+	struct tpacket4_desc *ring;
+
+	unsigned int avail_idx;
+	unsigned int last_used_idx;
+	unsigned int num_free;
+	unsigned int ring_mask;
+};
+
 #define TPACKET2_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket2_hdr)) + sizeof(struct sockaddr_ll))
 #define TPACKET3_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket3_hdr)) + sizeof(struct sockaddr_ll))
 
 enum tpacket_versions {
 	TPACKET_V1,
 	TPACKET_V2,
-	TPACKET_V3
+	TPACKET_V3,
+	TPACKET_V4
 };
 
 /*
@@ -282,9 +306,26 @@ struct tpacket_req3 {
 	unsigned int	tp_feature_req_word;
 };
 
+/* V4 frame structure
+ *
+ * The v4 frame is contained within a frame defined by
+ * PACKET_MEMREG/struct tpacket_memreg_req. Each frame is frame_size
+ * bytes, and laid out as following:
+ *
+ * - Start.
+ * - Gap, at least data_headroom (from struct tpacket_memreg_req),
+ *   chosen so that packet data (Start+data) is at least 64B aligned.
+ */
+
+struct tpacket_req4 {
+	int		mr_fd;	 /* File descriptor for registered buffers */
+	unsigned int	desc_nr; /* Number of entries in descriptor ring */
+};
+
 union tpacket_req_u {
 	struct tpacket_req	req;
 	struct tpacket_req3	req3;
+	struct tpacket_req4	req4;
 };
 
 struct packet_mreq {
@@ -294,6 +335,28 @@ struct packet_mreq {
 	unsigned char	mr_address[8];
 };
 
+/*
+ * struct tpacket_memreg_req is used in conjunction with PACKET_MEMREG
+ * to register user memory which should be used to store the packet
+ * data.
+ *
+ * There are some constraints for the memory being registered:
+ * - The memory area has to be memory page size aligned.
+ * - The frame size has to be a power of 2.
+ * - The frame size cannot be smaller than 2048B.
+ * - The frame size cannot be larger than the memory page size.
+ *
+ * Corollary: The number of frames that can be stored is
+ * len / frame_size.
+ *
+ */
+struct tpacket_memreg_req {
+	unsigned long	addr;		/* Start of packet data area */
+	unsigned long	len;		/* Length of packet data area */
+	unsigned int	frame_size;	/* Frame size */
+	unsigned int	data_headroom;	/* Frame head room */
+};
+
 #define PACKET_MR_MULTICAST	0
 #define PACKET_MR_PROMISC	1
 #define PACKET_MR_ALLMULTI	2
-- 
2.11.0
