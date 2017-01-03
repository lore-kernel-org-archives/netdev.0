From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 2/2] tools: psock_tpacket: verify that packet was received on lo before counting it
Date: Tue,  3 Jan 2017 15:27:39 -0800
Message-ID: <3451a2008d953f33d6576a35eaefecad883eaeb5.1483482971.git.sowmini.varadhan@oracle.com>
References: <cover.1483482971.git.sowmini.varadhan@oracle.com>
Cc: daniel@iogearbox.net, willemb@google.com, davem@davemloft.net,
        shuah@kernel.org
To: linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32592 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761954AbdACX2M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 18:28:12 -0500
In-Reply-To: <cover.1483482971.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1483482971.git.sowmini.varadhan@oracle.com>
References: <cover.1483482971.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Packets from any/all interfaces may be queued up on the PF_PACKET socket
before it is bound to the loopback interface by psock_tpacket, and
when these are passed up by the kernel, they should not be counted
toward the conditions needed to pass/fail the Rx tests.

psock_tpacket discards these packets by examining the sll_ifindex sent
up in each frame and ensuring that this is the same as the ifindex
that was used in bind_ring()

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 tools/testing/selftests/net/psock_tpacket.c |   25 ++++++++++++++++++++-----
 1 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/tools/testing/selftests/net/psock_tpacket.c b/tools/testing/selftests/net/psock_tpacket.c
index 4a1bc64..3c3f1aa 100644
--- a/tools/testing/selftests/net/psock_tpacket.c
+++ b/tools/testing/selftests/net/psock_tpacket.c
@@ -235,6 +235,7 @@ static void walk_v1_v2_rx(int sock, struct ring *ring)
 	int udp_sock[2];
 	union frame_map ppd;
 	unsigned int frame_num = 0;
+	int ifindex = ring->ll.sll_ifindex;
 
 	bug_on(ring->type != PACKET_RX_RING);
 
@@ -255,12 +256,18 @@ static void walk_v1_v2_rx(int sock, struct ring *ring)
 
 			switch (ring->version) {
 			case TPACKET_V1:
+				if (ppd.v1->s_ll.sll_ifindex != ifindex)
+					goto skip;
+
 				test_payload((uint8_t *) ppd.raw + ppd.v1->tp_h.tp_mac,
 					     ppd.v1->tp_h.tp_snaplen);
 				total_bytes += ppd.v1->tp_h.tp_snaplen;
 				break;
 
 			case TPACKET_V2:
+				if (ppd.v2->s_ll.sll_ifindex != ifindex)
+					goto skip;
+
 				test_payload((uint8_t *) ppd.raw + ppd.v2->tp_h.tp_mac,
 					     ppd.v2->tp_h.tp_snaplen);
 				total_bytes += ppd.v2->tp_h.tp_snaplen;
@@ -270,6 +277,7 @@ static void walk_v1_v2_rx(int sock, struct ring *ring)
 			status_bar_update();
 			total_packets++;
 
+skip:
 			__v1_v2_rx_user_ready(ppd.raw, ring->version);
 
 			frame_num = (frame_num + 1) % ring->rd_num;
@@ -553,11 +561,13 @@ static void __v3_test_block_header(struct block_desc *pbd, const int block_num)
 	__v3_test_block_seq_num(pbd);
 }
 
-static void __v3_walk_block(struct block_desc *pbd, const int block_num)
+static void __v3_walk_block(struct block_desc *pbd, const int block_num,
+			    int ifindex)
 {
 	int num_pkts = pbd->h1.num_pkts, i;
 	unsigned long bytes = 0, bytes_with_padding = ALIGN_8(sizeof(*pbd));
 	struct tpacket3_hdr *ppd;
+	struct sockaddr_ll *s_ll;
 
 	__v3_test_block_header(pbd, block_num);
 
@@ -572,10 +582,15 @@ static void __v3_walk_block(struct block_desc *pbd, const int block_num)
 		else
 			bytes_with_padding += ALIGN_8(ppd->tp_snaplen + ppd->tp_mac);
 
-		test_payload((uint8_t *) ppd + ppd->tp_mac, ppd->tp_snaplen);
+		s_ll = (struct sockaddr_ll *)&ppd[1];
 
-		status_bar_update();
-		total_packets++;
+		if (ifindex == s_ll->sll_ifindex) {
+			test_payload((uint8_t *) ppd + ppd->tp_mac,
+				     ppd->tp_snaplen);
+
+			status_bar_update();
+			total_packets++;
+		}
 
 		ppd = (struct tpacket3_hdr *) ((uint8_t *) ppd + ppd->tp_next_offset);
 		__sync_synchronize();
@@ -616,7 +631,7 @@ static void walk_v3_rx(int sock, struct ring *ring)
 		while ((pbd->h1.block_status & TP_STATUS_USER) == 0)
 			poll(&pfd, 1, 1);
 
-		__v3_walk_block(pbd, block_num);
+		__v3_walk_block(pbd, block_num, ring->ll.sll_ifindex);
 		__v3_flush_block(pbd);
 
 		block_num = (block_num + 1) % ring->rd_num;
-- 
1.7.1
