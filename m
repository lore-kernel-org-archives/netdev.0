From: Chetan Loke <loke.chetan@gmail.com>
Subject: [af-packet 1/2] Enhance af-packet to provide (near zero)lossless packet capture functionality.
Date: Tue,  7 Jun 2011 23:13:05 -0400
Message-ID: <1307502786-1396-2-git-send-email-loke.chetan@gmail.com>
References: <1307502786-1396-1-git-send-email-loke.chetan@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kaber@trash.net,
	johann.baudy@gnu-log.net, Chetan Loke <loke.chetan@gmail.com>,
	Chetan Loke <lokec@ccs.neu.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:61221 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076Ab1FHDNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 23:13:50 -0400
Received: by qyg14 with SMTP id 14so41359qyg.19
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2011 20:13:50 -0700 (PDT)
In-Reply-To: <1307502786-1396-1-git-send-email-loke.chetan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added TPACKET_V3 definitions

Signed-off-by: Chetan Loke <lokec@ccs.neu.edu>
---
 include/linux/if_packet.h |  127 ++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 126 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index 72bfa5a..9e4eea1 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -24,7 +24,7 @@ struct sockaddr_ll {
 #define PACKET_HOST		0		/* To us		*/
 #define PACKET_BROADCAST	1		/* To all		*/
 #define PACKET_MULTICAST	2		/* To group		*/
-#define PACKET_OTHERHOST	3		/* To someone else 	*/
+#define PACKET_OTHERHOST	3		/* To someone else	*/
 #define PACKET_OUTGOING		4		/* Outgoing of any type */
 /* These ones are invisible by user level */
 #define PACKET_LOOPBACK		5		/* MC/BRD frame looped back */
@@ -55,6 +55,17 @@ struct tpacket_stats {
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
@@ -70,6 +81,7 @@ struct tpacket_auxdata {
 #define TP_STATUS_COPY		0x2
 #define TP_STATUS_LOSING	0x4
 #define TP_STATUS_CSUMNOTREADY	0x8
+#define TP_STATUS_BLK_TMO	0x10
 
 /* Tx ring - header status */
 #define TP_STATUS_AVAILABLE	0x0
@@ -102,11 +114,111 @@ struct tpacket2_hdr {
 	__u16		tp_vlan_tci;
 };
 
+struct tpacket3_hdr {
+	__u32		tp_status;
+	__u32		tp_len;
+	__u32		tp_snaplen;
+	__u16		tp_mac;
+	__u16		tp_net;
+	__u32		tp_sec;
+	__u32		tp_nsec;
+	__u16		tp_vlan_tci;
+	__u32		tp_next_offset;
+};
+
+struct bd_ts {
+	unsigned int ts_sec;
+	union {
+		struct {
+			unsigned int ts_usec;
+		};
+		struct {
+			unsigned int ts_nsec;
+		};
+	};
+} __attribute__ ((__packed__));
+
+struct bd_v1 {
+	/*
+	 * If you re-order the first 5 fields then
+	 * the BLOCK_XXX macros will NOT work.
+	 */
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
+	__u64	seq_num;
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
+	struct bd_ts	ts_first_pkt;
+	struct bd_ts	ts_last_pkt;
+} __attribute__ ((__packed__));
+
+struct block_desc {
+	__u16 version;
+	union {
+		struct {
+			__u32	words[4];
+			__u64	dword;
+		} __attribute__ ((__packed__));
+		struct bd_v1 bd1;
+	};
+} __attribute__ ((__packed__));
+
+
+
 #define TPACKET2_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket2_hdr)) + sizeof(struct sockaddr_ll))
+#define TPACKET3_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket3_hdr)) + sizeof(struct sockaddr_ll))
+
+#define BLOCK_STATUS(x)	((x)->words[0])
+#define BLOCK_NUM_PKTS(x)	((x)->words[1])
+#define BLOCK_O2FP(x)		((x)->words[2])
+#define BLOCK_LEN(x)		((x)->words[3])
+#define BLOCK_SNUM(x)		((x)->dword)
+
 
 enum tpacket_versions {
 	TPACKET_V1,
 	TPACKET_V2,
+	TPACKET_V3,
 };
 
 /*
@@ -129,6 +241,19 @@ struct tpacket_req {
 	unsigned int	tp_frame_nr;	/* Total number of frames */
 };
 
+struct tpacket_req3 {
+	unsigned int	tp_block_size;	/* Minimal size of contiguous block */
+	unsigned int	tp_block_nr;	/* Number of blocks */
+	unsigned int	tp_frame_size;	/* Size of frame */
+	unsigned int	tp_frame_nr;	/* Total number of frames */
+	unsigned int	tp_retire_blk_tov; /* timeout in msecs */
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

