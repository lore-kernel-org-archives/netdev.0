From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v3 net-next 2/2] tools: test case for TPACKET_V3/TX_RING support
Date: Tue,  3 Jan 2017 06:31:48 -0800
Message-ID: <dcf7fe19d3248b4f523b7f7d22937c61d92a152f.1483452545.git.sowmini.varadhan@oracle.com>
References: <cover.1483452545.git.sowmini.varadhan@oracle.com>
Cc: daniel@iogearbox.net, willemb@google.com, davem@davemloft.net
To: netdev@vger.kernel.org, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33390 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756342AbdACOc0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 09:32:26 -0500
In-Reply-To: <cover.1483452545.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1483452545.git.sowmini.varadhan@oracle.com>
References: <cover.1483452545.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a test case and sample code for (TPACKET_V3, PACKET_TX_RING)

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2: Added test case.
v3: refactored code to have a single walk_tx() function that handles all three
    TPACKET versions.

 tools/testing/selftests/net/psock_tpacket.c |   91 ++++++++++++++++++++++-----
 1 files changed, 74 insertions(+), 17 deletions(-)

diff --git a/tools/testing/selftests/net/psock_tpacket.c b/tools/testing/selftests/net/psock_tpacket.c
index 24adf70..4a1bc64 100644
--- a/tools/testing/selftests/net/psock_tpacket.c
+++ b/tools/testing/selftests/net/psock_tpacket.c
@@ -311,20 +311,33 @@ static inline void __v2_tx_user_ready(struct tpacket2_hdr *hdr)
 	__sync_synchronize();
 }
 
-static inline int __v1_v2_tx_kernel_ready(void *base, int version)
+static inline int __v3_tx_kernel_ready(struct tpacket3_hdr *hdr)
+{
+	return !(hdr->tp_status & (TP_STATUS_SEND_REQUEST | TP_STATUS_SENDING));
+}
+
+static inline void __v3_tx_user_ready(struct tpacket3_hdr *hdr)
+{
+	hdr->tp_status = TP_STATUS_SEND_REQUEST;
+	__sync_synchronize();
+}
+
+static inline int __tx_kernel_ready(void *base, int version)
 {
 	switch (version) {
 	case TPACKET_V1:
 		return __v1_tx_kernel_ready(base);
 	case TPACKET_V2:
 		return __v2_tx_kernel_ready(base);
+	case TPACKET_V3:
+		return __v3_tx_kernel_ready(base);
 	default:
 		bug_on(1);
 		return 0;
 	}
 }
 
-static inline void __v1_v2_tx_user_ready(void *base, int version)
+static inline void __tx_user_ready(void *base, int version)
 {
 	switch (version) {
 	case TPACKET_V1:
@@ -333,6 +346,9 @@ static inline void __v1_v2_tx_user_ready(void *base, int version)
 	case TPACKET_V2:
 		__v2_tx_user_ready(base);
 		break;
+	case TPACKET_V3:
+		__v3_tx_user_ready(base);
+		break;
 	}
 }
 
@@ -348,7 +364,22 @@ static void __v1_v2_set_packet_loss_discard(int sock)
 	}
 }
 
-static void walk_v1_v2_tx(int sock, struct ring *ring)
+static inline void *get_next_frame(struct ring *ring, int n)
+{
+	uint8_t *f0 = ring->rd[0].iov_base;
+
+	switch (ring->version) {
+	case TPACKET_V1:
+	case TPACKET_V2:
+		return ring->rd[n].iov_base;
+	case TPACKET_V3:
+		return f0 + (n * ring->req3.tp_frame_size);
+	default:
+		bug_on(1);
+	}
+}
+
+static void walk_tx(int sock, struct ring *ring)
 {
 	struct pollfd pfd;
 	int rcv_sock, ret;
@@ -360,9 +391,19 @@ static void walk_v1_v2_tx(int sock, struct ring *ring)
 		.sll_family = PF_PACKET,
 		.sll_halen = ETH_ALEN,
 	};
+	int nframes;
+
+	/* TPACKET_V{1,2} sets up the ring->rd* related variables based
+	 * on frames (e.g., rd_num is tp_frame_nr) whereas V3 sets these
+	 * up based on blocks (e.g, rd_num is  tp_block_nr)
+	 */
+	if (ring->version <= TPACKET_V2)
+		nframes = ring->rd_num;
+	else
+		nframes = ring->req3.tp_frame_nr;
 
 	bug_on(ring->type != PACKET_TX_RING);
-	bug_on(ring->rd_num < NUM_PACKETS);
+	bug_on(nframes < NUM_PACKETS);
 
 	rcv_sock = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
 	if (rcv_sock == -1) {
@@ -388,10 +429,11 @@ static void walk_v1_v2_tx(int sock, struct ring *ring)
 	create_payload(packet, &packet_len);
 
 	while (total_packets > 0) {
-		while (__v1_v2_tx_kernel_ready(ring->rd[frame_num].iov_base,
-					       ring->version) &&
+		void *next = get_next_frame(ring, frame_num);
+
+		while (__tx_kernel_ready(next, ring->version) &&
 		       total_packets > 0) {
-			ppd.raw = ring->rd[frame_num].iov_base;
+			ppd.raw = next;
 
 			switch (ring->version) {
 			case TPACKET_V1:
@@ -413,14 +455,27 @@ static void walk_v1_v2_tx(int sock, struct ring *ring)
 				       packet_len);
 				total_bytes += ppd.v2->tp_h.tp_snaplen;
 				break;
+			case TPACKET_V3: {
+				struct tpacket3_hdr *tx = next;
+
+				tx->tp_snaplen = packet_len;
+				tx->tp_len = packet_len;
+				tx->tp_next_offset = 0;
+
+				memcpy((uint8_t *)tx + TPACKET3_HDRLEN -
+				       sizeof(struct sockaddr_ll), packet,
+				       packet_len);
+				total_bytes += tx->tp_snaplen;
+				break;
+			}
 			}
 
 			status_bar_update();
 			total_packets--;
 
-			__v1_v2_tx_user_ready(ppd.raw, ring->version);
+			__tx_user_ready(next, ring->version);
 
-			frame_num = (frame_num + 1) % ring->rd_num;
+			frame_num = (frame_num + 1) % nframes;
 		}
 
 		poll(&pfd, 1, 1);
@@ -460,7 +515,7 @@ static void walk_v1_v2(int sock, struct ring *ring)
 	if (ring->type == PACKET_RX_RING)
 		walk_v1_v2_rx(sock, ring);
 	else
-		walk_v1_v2_tx(sock, ring);
+		walk_tx(sock, ring);
 }
 
 static uint64_t __v3_prev_block_seq_num = 0;
@@ -583,7 +638,7 @@ static void walk_v3(int sock, struct ring *ring)
 	if (ring->type == PACKET_RX_RING)
 		walk_v3_rx(sock, ring);
 	else
-		bug_on(1);
+		walk_tx(sock, ring);
 }
 
 static void __v1_v2_fill(struct ring *ring, unsigned int blocks)
@@ -602,12 +657,13 @@ static void __v1_v2_fill(struct ring *ring, unsigned int blocks)
 	ring->flen = ring->req.tp_frame_size;
 }
 
-static void __v3_fill(struct ring *ring, unsigned int blocks)
+static void __v3_fill(struct ring *ring, unsigned int blocks, int type)
 {
-	ring->req3.tp_retire_blk_tov = 64;
-	ring->req3.tp_sizeof_priv = 0;
-	ring->req3.tp_feature_req_word = TP_FT_REQ_FILL_RXHASH;
-
+	if (type == PACKET_RX_RING) {
+		ring->req3.tp_retire_blk_tov = 64;
+		ring->req3.tp_sizeof_priv = 0;
+		ring->req3.tp_feature_req_word = TP_FT_REQ_FILL_RXHASH;
+	}
 	ring->req3.tp_block_size = getpagesize() << 2;
 	ring->req3.tp_frame_size = TPACKET_ALIGNMENT << 7;
 	ring->req3.tp_block_nr = blocks;
@@ -641,7 +697,7 @@ static void setup_ring(int sock, struct ring *ring, int version, int type)
 		break;
 
 	case TPACKET_V3:
-		__v3_fill(ring, blocks);
+		__v3_fill(ring, blocks, type);
 		ret = setsockopt(sock, SOL_PACKET, type, &ring->req3,
 				 sizeof(ring->req3));
 		break;
@@ -796,6 +852,7 @@ int main(void)
 	ret |= test_tpacket(TPACKET_V2, PACKET_TX_RING);
 
 	ret |= test_tpacket(TPACKET_V3, PACKET_RX_RING);
+	ret |= test_tpacket(TPACKET_V3, PACKET_TX_RING);
 
 	if (ret)
 		return 1;
-- 
1.7.1
