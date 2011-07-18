From: Chetan Loke <loke.chetan@gmail.com>
Subject: [PATCH net-next v3 af-packet 1/2] Enhance af-packet to provide (near zero)lossless packet capture functionality.
Date: Sun, 17 Jul 2011 23:26:49 -0400
Message-ID: <1310959610-1688-2-git-send-email-loke.chetan@gmail.com>
References: <1310959610-1688-1-git-send-email-loke.chetan@gmail.com>
Cc: Chetan Loke <loke.chetan@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:39075 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899Ab1GRD1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 23:27:20 -0400
Received: by qyk29 with SMTP id 29so1279365qyk.19
        for <netdev@vger.kernel.org>; Sun, 17 Jul 2011 20:27:19 -0700 (PDT)
In-Reply-To: <1310959610-1688-1-git-send-email-loke.chetan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Chetan Loke <loke.chetan@gmail.com>
---
 include/linux/if_packet.h |  125 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 125 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index c148606..19427d7 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -61,6 +61,17 @@ struct tpacket_stats {
 	unsigned int	tp_drops;
 };
 
+struct tpacket_stats_v3 {
+	unsigned int	tp_packets;
+	unsigned int	tp_drops;
+	unsigned int	tp_freeze_q_cnt;
+};
+
+union tpacket_stats_u {
+	struct tpacket_stats stats1;
+	struct tpacket_stats_v3 stats3;
+};
+
 struct tpacket_auxdata {
 	__u32		tp_status;
 	__u32		tp_len;
@@ -78,6 +89,7 @@ struct tpacket_auxdata {
 #define TP_STATUS_LOSING	0x4
 #define TP_STATUS_CSUMNOTREADY	0x8
 #define TP_STATUS_VLAN_VALID   0x10 /* auxdata has valid tp_vlan_tci */
+#define TP_STATUS_BLK_TMO	0x20
 
 /* Tx ring - header status */
 #define TP_STATUS_AVAILABLE	0x0
@@ -85,6 +97,9 @@ struct tpacket_auxdata {
 #define TP_STATUS_SENDING	0x2
 #define TP_STATUS_WRONG_FORMAT	0x4
 
+/* Rx ring - feature request bits */
+#define TP_FT_REQ_FILL_RXHASH	0x1
+
 struct tpacket_hdr {
 	unsigned long	tp_status;
 	unsigned int	tp_len;
@@ -111,11 +126,106 @@ struct tpacket2_hdr {
 	__u16		tp_padding;
 };
 
+struct tpacket3_hdr {
+	__u32		tp_status;
+	__u32		tp_next_offset;
+	__u32		tp_len;
+	__u32		tp_snaplen;
+	__u16		tp_mac;
+	__u16		tp_net;
+	__u32		tp_sec;
+	__u32		tp_nsec;
+	__u32		tp_rxhash;
+	__u16		tp_vlan_tci;
+	__u16		tp_padding;
+	__u32		tp_next_offset;
+};
+
+struct bd_ts {
+	unsigned int ts_sec;
+	union {
+		unsigned int ts_usec;
+		unsigned int ts_nsec;
+	};
+};
+
+struct hdr_v1 {
+	__u32	block_status;
+	__u32	num_pkts;
+	__u32	offset_to_first_pkt;
+
+	/* Number of valid bytes (including padding)
+	 * blk_len <= tp_block_size
+	 */
+	__u32	blk_len;
+
+	/*
+	 * Quite a few uses of sequence number:
+	 * 1. Make sure cache flush etc worked.
+	 *    Well, one can argue - why not use the increasing ts below?
+	 *    But look at 2. below first.
+	 * 2. When you pass around blocks to other user space decoders,
+	 *    you can see which blk[s] is[are] outstanding etc.
+	 * 3. Validate kernel code.
+	 */
+	aligned_u64	seq_num;
+
+	/*
+	 * ts_last_pkt:
+	 *
+	 * Case 1.	Block has 'N'(N >=1) packets and TMO'd(timed out)
+	 *		ts_last_pkt == 'time-stamp of last packet' and NOT the
+	 *		time when the timer fired and the block was closed.
+	 *		By providing the ts of the last packet we can absolutely
+	 *		guarantee that time-stamp wise, the first packet in the next
+	 *		block will never precede the last packet of the previous
+	 *		block.
+	 * Case 2.	Block has zero packets and TMO'd
+	 *		ts_last_pkt = time when the timer fired and the block
+	 *		was closed.
+	 * Case 3.	Block has 'N' packets and NO TMO.
+	 *		ts_last_pkt = time-stamp of the last pkt in the block.
+	 *
+	 * ts_first_pkt:
+	 *		Is always the time-stamp when the block was opened.
+	 *		Case a)	ZERO packets
+	 *			No packets to deal with but atleast you know the
+	 *			time-interval of this block.
+	 *		Case b) Non-zero packets
+	 *			Use the ts of the first packet in the block.
+	 *
+	 */
+	struct bd_ts	ts_first_pkt, ts_last_pkt;
+};
+
+union bd_header_u {
+	struct hdr_v1 h1;
+};
+
+struct block_desc {
+	__u16 version;
+	__u16 offset_to_priv;
+	__u32 rsvd1;
+	union bd_header_u hdr;
+};
+
+
+
 #define TPACKET2_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket2_hdr)) + sizeof(struct sockaddr_ll))
+#define TPACKET3_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket3_hdr)) + sizeof(struct sockaddr_ll))
+
+#define BLOCK_STATUS(x)	((x)->hdr.h1.block_status)
+#define BLOCK_NUM_PKTS(x)	((x)->hdr.h1.num_pkts)
+#define BLOCK_O2FP(x)		((x)->hdr.h1.offset_to_first_pkt)
+#define BLOCK_LEN(x)		((x)->hdr.h1.blk_len)
+#define BLOCK_SNUM(x)		((x)->hdr.h1.seq_num)
+#define BLOCK_O2PRIV(x)	((x)->offset_to_priv)
+#define BLOCK_PRIV(x)		((void *)((char *)(x) + BLOCK_O2PRIV(x)))
 
 enum tpacket_versions {
 	TPACKET_V1,
 	TPACKET_V2,
+	TPACKET_V3,
 };
 
 /*
@@ -138,6 +248,21 @@ struct tpacket_req {
 	unsigned int	tp_frame_nr;	/* Total number of frames */
 };
 
+struct tpacket_req3 {
+	unsigned int	tp_block_size;	/* Minimal size of contiguous block */
+	unsigned int	tp_block_nr;	/* Number of blocks */
+	unsigned int	tp_frame_size;	/* Size of frame */
+	unsigned int	tp_frame_nr;	/* Total number of frames */
+	unsigned int	tp_retire_blk_tov; /* timeout in msecs */
+	unsigned int	tp_sizeof_priv; /* offset to private data area */
+	unsigned int	tp_feature_req_word;
+};
+
+union tpacket_req_u {
+	struct tpacket_req	req;
+	struct tpacket_req3	req3;
+};
+
 struct packet_mreq {
 	int		mr_ifindex;
 	unsigned short	mr_type;
-- 
1.7.5.2

