From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] doc: packet: simplify tpacket example code
Date: Fri,  7 Jun 2013 02:08:13 +0200
Message-ID: <1370563693-19599-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24486 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752175Ab3FGAIT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jun 2013 20:08:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch simplifies the tpacket_v3 example code a bit by getting rid
of unecessary macro wrappers, removing some debugging code so that it is
more to the point, and also adds a header comment. Now this example code
is the very minimum one needs to start from when dealing with tpacket_v3
and ~100 lines smaller than before.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Documentation/networking/packet_mmap.txt | 133 +++++++------------------------
 1 file changed, 28 insertions(+), 105 deletions(-)

diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
index 23dd80e..4c5109e 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -704,6 +704,12 @@ So it seems to be a good candidate to be used with packet fanout.
 Minimal example code by Daniel Borkmann based on Chetan Loke's lolpcap (compile
 it with gcc -Wall -O2 blob.c, and try things like "./a.out eth0", etc.):
 
+/* Written from scratch, but kernel-to-user space API usage
+ * dissected from lolpcap:
+ *  Copyright 2011, Chetan Loke <loke.chetan@gmail.com>
+ *  License: GPL, version 2.0
+ */
+
 #include <stdio.h>
 #include <stdlib.h>
 #include <stdint.h>
@@ -722,27 +728,6 @@ it with gcc -Wall -O2 blob.c, and try things like "./a.out eth0", etc.):
 #include <linux/if_ether.h>
 #include <linux/ip.h>
 
-#define BLOCK_SIZE		(1 << 22)
-#define FRAME_SIZE		2048
-
-#define NUM_BLOCKS		64
-#define NUM_FRAMES		((BLOCK_SIZE * NUM_BLOCKS) / FRAME_SIZE)
-
-#define BLOCK_RETIRE_TOV_IN_MS	64
-#define BLOCK_PRIV_AREA_SZ	13
-
-#define ALIGN_8(x)		(((x) + 8 - 1) & ~(8 - 1))
-
-#define BLOCK_STATUS(x)		((x)->h1.block_status)
-#define BLOCK_NUM_PKTS(x)	((x)->h1.num_pkts)
-#define BLOCK_O2FP(x)		((x)->h1.offset_to_first_pkt)
-#define BLOCK_LEN(x)		((x)->h1.blk_len)
-#define BLOCK_SNUM(x)		((x)->h1.seq_num)
-#define BLOCK_O2PRIV(x)		((x)->offset_to_priv)
-#define BLOCK_PRIV(x)		((void *) ((uint8_t *) (x) + BLOCK_O2PRIV(x)))
-#define BLOCK_HDR_LEN		(ALIGN_8(sizeof(struct block_desc)))
-#define BLOCK_PLUS_PRIV(sz_pri)	(BLOCK_HDR_LEN + ALIGN_8((sz_pri)))
-
 #ifndef likely
 # define likely(x)		__builtin_expect(!!(x), 1)
 #endif
@@ -765,7 +750,7 @@ struct ring {
 static unsigned long packets_total = 0, bytes_total = 0;
 static sig_atomic_t sigint = 0;
 
-void sighandler(int num)
+static void sighandler(int num)
 {
 	sigint = 1;
 }
@@ -774,6 +759,8 @@ static int setup_socket(struct ring *ring, char *netdev)
 {
 	int err, i, fd, v = TPACKET_V3;
 	struct sockaddr_ll ll;
+	unsigned int blocksiz = 1 << 22, framesiz = 1 << 11;
+	unsigned int blocknum = 64;
 
 	fd = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
 	if (fd < 0) {
@@ -788,13 +775,12 @@ static int setup_socket(struct ring *ring, char *netdev)
 	}
 
 	memset(&ring->req, 0, sizeof(ring->req));
-	ring->req.tp_block_size = BLOCK_SIZE;
-	ring->req.tp_frame_size = FRAME_SIZE;
-	ring->req.tp_block_nr = NUM_BLOCKS;
-	ring->req.tp_frame_nr = NUM_FRAMES;
-	ring->req.tp_retire_blk_tov = BLOCK_RETIRE_TOV_IN_MS;
-	ring->req.tp_sizeof_priv = BLOCK_PRIV_AREA_SZ;
-	ring->req.tp_feature_req_word |= TP_FT_REQ_FILL_RXHASH;
+	ring->req.tp_block_size = blocksiz;
+	ring->req.tp_frame_size = framesiz;
+	ring->req.tp_block_nr = blocknum;
+	ring->req.tp_frame_nr = (blocksiz * blocknum) / framesiz;
+	ring->req.tp_retire_blk_tov = 60;
+	ring->req.tp_feature_req_word = TP_FT_REQ_FILL_RXHASH;
 
 	err = setsockopt(fd, SOL_PACKET, PACKET_RX_RING, &ring->req,
 			 sizeof(ring->req));
@@ -804,8 +790,7 @@ static int setup_socket(struct ring *ring, char *netdev)
 	}
 
 	ring->map = mmap(NULL, ring->req.tp_block_size * ring->req.tp_block_nr,
-			 PROT_READ | PROT_WRITE, MAP_SHARED | MAP_LOCKED,
-			 fd, 0);
+			 PROT_READ | PROT_WRITE, MAP_SHARED | MAP_LOCKED, fd, 0);
 	if (ring->map == MAP_FAILED) {
 		perror("mmap");
 		exit(1);
@@ -835,58 +820,6 @@ static int setup_socket(struct ring *ring, char *netdev)
 	return fd;
 }
 
-#ifdef __checked
-static uint64_t prev_block_seq_num = 0;
-
-void assert_block_seq_num(struct block_desc *pbd)
-{
-	if (unlikely(prev_block_seq_num + 1 != BLOCK_SNUM(pbd))) {
-		printf("prev_block_seq_num:%"PRIu64", expected seq:%"PRIu64" != "
-		       "actual seq:%"PRIu64"\n", prev_block_seq_num,
-		       prev_block_seq_num + 1, (uint64_t) BLOCK_SNUM(pbd));
-		exit(1);
-	}
-
-	prev_block_seq_num = BLOCK_SNUM(pbd);
-}
-
-static void assert_block_len(struct block_desc *pbd, uint32_t bytes, int block_num)
-{
-	if (BLOCK_NUM_PKTS(pbd)) {
-		if (unlikely(bytes != BLOCK_LEN(pbd))) {
-			printf("block:%u with %upackets, expected len:%u != actual len:%u\n",
-			       block_num, BLOCK_NUM_PKTS(pbd), bytes, BLOCK_LEN(pbd));
-			exit(1);
-		}
-	} else {
-		if (unlikely(BLOCK_LEN(pbd) != BLOCK_PLUS_PRIV(BLOCK_PRIV_AREA_SZ))) {
-			printf("block:%u, expected len:%lu != actual len:%u\n",
-			       block_num, BLOCK_HDR_LEN, BLOCK_LEN(pbd));
-			exit(1);
-		}
-	}
-}
-
-static void assert_block_header(struct block_desc *pbd, const int block_num)
-{
-	uint32_t block_status = BLOCK_STATUS(pbd);
-
-	if (unlikely((block_status & TP_STATUS_USER) == 0)) {
-		printf("block:%u, not in TP_STATUS_USER\n", block_num);
-		exit(1);
-	}
-
-	assert_block_seq_num(pbd);
-}
-#else
-static inline void assert_block_header(struct block_desc *pbd, const int block_num)
-{
-}
-static void assert_block_len(struct block_desc *pbd, uint32_t bytes, int block_num)
-{
-}
-#endif
-
 static void display(struct tpacket3_hdr *ppd)
 {
 	struct ethhdr *eth = (struct ethhdr *) ((uint8_t *) ppd + ppd->tp_mac);
@@ -916,37 +849,27 @@ static void display(struct tpacket3_hdr *ppd)
 
 static void walk_block(struct block_desc *pbd, const int block_num)
 {
-	int num_pkts = BLOCK_NUM_PKTS(pbd), i;
+	int num_pkts = pbd->h1.num_pkts, i;
 	unsigned long bytes = 0;
-	unsigned long bytes_with_padding = BLOCK_PLUS_PRIV(BLOCK_PRIV_AREA_SZ);
 	struct tpacket3_hdr *ppd;
 
-	assert_block_header(pbd, block_num);
-
-	ppd = (struct tpacket3_hdr *) ((uint8_t *) pbd + BLOCK_O2FP(pbd));
+	ppd = (struct tpacket3_hdr *) ((uint8_t *) pbd +
+				       pbd->h1.offset_to_first_pkt);
 	for (i = 0; i < num_pkts; ++i) {
 		bytes += ppd->tp_snaplen;
-		if (ppd->tp_next_offset)
-			bytes_with_padding += ppd->tp_next_offset;
-		else
-			bytes_with_padding += ALIGN_8(ppd->tp_snaplen + ppd->tp_mac);
-
 		display(ppd);
 
-		ppd = (struct tpacket3_hdr *) ((uint8_t *) ppd + ppd->tp_next_offset);
-		__sync_synchronize();
+		ppd = (struct tpacket3_hdr *) ((uint8_t *) ppd +
+					       ppd->tp_next_offset);
 	}
 
-	assert_block_len(pbd, bytes_with_padding, block_num);
-
 	packets_total += num_pkts;
 	bytes_total += bytes;
 }
 
-void flush_block(struct block_desc *pbd)
+static void flush_block(struct block_desc *pbd)
 {
-	BLOCK_STATUS(pbd) = TP_STATUS_KERNEL;
-	__sync_synchronize();
+	pbd->h1.block_status = TP_STATUS_KERNEL;
 }
 
 static void teardown_socket(struct ring *ring, int fd)
@@ -962,7 +885,7 @@ int main(int argc, char **argp)
 	socklen_t len;
 	struct ring ring;
 	struct pollfd pfd;
-	unsigned int block_num = 0;
+	unsigned int block_num = 0, blocks = 64;
 	struct block_desc *pbd;
 	struct tpacket_stats_v3 stats;
 
@@ -984,15 +907,15 @@ int main(int argc, char **argp)
 
 	while (likely(!sigint)) {
 		pbd = (struct block_desc *) ring.rd[block_num].iov_base;
-retry_block:
-		if ((BLOCK_STATUS(pbd) & TP_STATUS_USER) == 0) {
+
+		if ((pbd->h1.block_status & TP_STATUS_USER) == 0) {
 			poll(&pfd, 1, -1);
-			goto retry_block;
+			continue;
 		}
 
 		walk_block(pbd, block_num);
 		flush_block(pbd);
-		block_num = (block_num + 1) % NUM_BLOCKS;
+		block_num = (block_num + 1) % blocks;
 	}
 
 	len = sizeof(stats);
-- 
1.7.11.7
