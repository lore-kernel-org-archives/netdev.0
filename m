From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] tools: selftests: psock_tpacket: get rid of macro wrappers
Date: Mon,  1 Jul 2013 18:09:50 +0200
Message-ID: <1372694990-10876-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23899 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750769Ab3GAQJy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 12:09:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TPACKET_V3 test code consists of a lot of unecessary macro
wrappers that rather obfuscate what members are accessed in what
way. So get rid of them and make the code more readable. Also
credit Chetan for providing tpacket_v3 example code. Furthermore,
get rid of private offset usage, as we do not need it here.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 tools/testing/selftests/net/psock_tpacket.c | 59 ++++++++++-------------------
 1 file changed, 20 insertions(+), 39 deletions(-)

diff --git a/tools/testing/selftests/net/psock_tpacket.c b/tools/testing/selftests/net/psock_tpacket.c
index c41b586..24adf70 100644
--- a/tools/testing/selftests/net/psock_tpacket.c
+++ b/tools/testing/selftests/net/psock_tpacket.c
@@ -1,6 +1,7 @@
 /*
  * Copyright 2013 Red Hat, Inc.
  * Author: Daniel Borkmann <dborkman@redhat.com>
+ *         Chetan Loke <loke.chetan@gmail.com> (TPACKET_V3 usage example)
  *
  * A basic test of packet socket's TPACKET_V1/TPACKET_V2/TPACKET_V3 behavior.
  *
@@ -71,18 +72,8 @@
 # define __align_tpacket(x)	__attribute__((aligned(TPACKET_ALIGN(x))))
 #endif
 
-#define BLOCK_STATUS(x)		((x)->h1.block_status)
-#define BLOCK_NUM_PKTS(x)	((x)->h1.num_pkts)
-#define BLOCK_O2FP(x)		((x)->h1.offset_to_first_pkt)
-#define BLOCK_LEN(x)		((x)->h1.blk_len)
-#define BLOCK_SNUM(x)		((x)->h1.seq_num)
-#define BLOCK_O2PRIV(x)		((x)->offset_to_priv)
-#define BLOCK_PRIV(x)		((void *) ((uint8_t *) (x) + BLOCK_O2PRIV(x)))
-#define BLOCK_HDR_LEN		(ALIGN_8(sizeof(struct block_desc)))
-#define ALIGN_8(x)		(((x) + 8 - 1) & ~(8 - 1))
-#define BLOCK_PLUS_PRIV(sz_pri)	(BLOCK_HDR_LEN + ALIGN_8((sz_pri)))
-
 #define NUM_PACKETS		100
+#define ALIGN_8(x)		(((x) + 8 - 1) & ~(8 - 1))
 
 struct ring {
 	struct iovec *rd;
@@ -476,41 +467,30 @@ static uint64_t __v3_prev_block_seq_num = 0;
 
 void __v3_test_block_seq_num(struct block_desc *pbd)
 {
-	if (__v3_prev_block_seq_num + 1 != BLOCK_SNUM(pbd)) {
+	if (__v3_prev_block_seq_num + 1 != pbd->h1.seq_num) {
 		fprintf(stderr, "\nprev_block_seq_num:%"PRIu64", expected "
 			"seq:%"PRIu64" != actual seq:%"PRIu64"\n",
 			__v3_prev_block_seq_num, __v3_prev_block_seq_num + 1,
-			(uint64_t) BLOCK_SNUM(pbd));
+			(uint64_t) pbd->h1.seq_num);
 		exit(1);
 	}
 
-	__v3_prev_block_seq_num = BLOCK_SNUM(pbd);
+	__v3_prev_block_seq_num = pbd->h1.seq_num;
 }
 
 static void __v3_test_block_len(struct block_desc *pbd, uint32_t bytes, int block_num)
 {
-	if (BLOCK_NUM_PKTS(pbd)) {
-		if (bytes != BLOCK_LEN(pbd)) {
-			fprintf(stderr, "\nblock:%u with %upackets, expected "
-				"len:%u != actual len:%u\n", block_num,
-				BLOCK_NUM_PKTS(pbd), bytes, BLOCK_LEN(pbd));
-			exit(1);
-		}
-	} else {
-		if (BLOCK_LEN(pbd) != BLOCK_PLUS_PRIV(13)) {
-			fprintf(stderr, "\nblock:%u, expected len:%lu != "
-				"actual len:%u\n", block_num, BLOCK_HDR_LEN,
-				BLOCK_LEN(pbd));
-			exit(1);
-		}
+	if (pbd->h1.num_pkts && bytes != pbd->h1.blk_len) {
+		fprintf(stderr, "\nblock:%u with %upackets, expected "
+			"len:%u != actual len:%u\n", block_num,
+			pbd->h1.num_pkts, bytes, pbd->h1.blk_len);
+		exit(1);
 	}
 }
 
 static void __v3_test_block_header(struct block_desc *pbd, const int block_num)
 {
-	uint32_t block_status = BLOCK_STATUS(pbd);
-
-	if ((block_status & TP_STATUS_USER) == 0) {
+	if ((pbd->h1.block_status & TP_STATUS_USER) == 0) {
 		fprintf(stderr, "\nblock %u: not in TP_STATUS_USER\n", block_num);
 		exit(1);
 	}
@@ -520,14 +500,15 @@ static void __v3_test_block_header(struct block_desc *pbd, const int block_num)
 
 static void __v3_walk_block(struct block_desc *pbd, const int block_num)
 {
-	int num_pkts = BLOCK_NUM_PKTS(pbd), i;
-	unsigned long bytes = 0;
-	unsigned long bytes_with_padding = BLOCK_PLUS_PRIV(13);
+	int num_pkts = pbd->h1.num_pkts, i;
+	unsigned long bytes = 0, bytes_with_padding = ALIGN_8(sizeof(*pbd));
 	struct tpacket3_hdr *ppd;
 
 	__v3_test_block_header(pbd, block_num);
 
-	ppd = (struct tpacket3_hdr *) ((uint8_t *) pbd + BLOCK_O2FP(pbd));
+	ppd = (struct tpacket3_hdr *) ((uint8_t *) pbd +
+				       pbd->h1.offset_to_first_pkt);
+
 	for (i = 0; i < num_pkts; ++i) {
 		bytes += ppd->tp_snaplen;
 
@@ -551,7 +532,7 @@ static void __v3_walk_block(struct block_desc *pbd, const int block_num)
 
 void __v3_flush_block(struct block_desc *pbd)
 {
-	BLOCK_STATUS(pbd) = TP_STATUS_KERNEL;
+	pbd->h1.block_status = TP_STATUS_KERNEL;
 	__sync_synchronize();
 }
 
@@ -577,7 +558,7 @@ static void walk_v3_rx(int sock, struct ring *ring)
 	while (total_packets < NUM_PACKETS * 2) {
 		pbd = (struct block_desc *) ring->rd[block_num].iov_base;
 
-		while ((BLOCK_STATUS(pbd) & TP_STATUS_USER) == 0)
+		while ((pbd->h1.block_status & TP_STATUS_USER) == 0)
 			poll(&pfd, 1, 1);
 
 		__v3_walk_block(pbd, block_num);
@@ -624,8 +605,8 @@ static void __v1_v2_fill(struct ring *ring, unsigned int blocks)
 static void __v3_fill(struct ring *ring, unsigned int blocks)
 {
 	ring->req3.tp_retire_blk_tov = 64;
-	ring->req3.tp_sizeof_priv = 13;
-	ring->req3.tp_feature_req_word |= TP_FT_REQ_FILL_RXHASH;
+	ring->req3.tp_sizeof_priv = 0;
+	ring->req3.tp_feature_req_word = TP_FT_REQ_FILL_RXHASH;
 
 	ring->req3.tp_block_size = getpagesize() << 2;
 	ring->req3.tp_frame_size = TPACKET_ALIGNMENT << 7;
-- 
1.7.11.7
