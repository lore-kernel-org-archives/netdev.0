From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] af_packet: Provide a TPACKET_V2 compatible Tx path for TPACKET_V3
Date: Fri, 30 Dec 2016 08:54:13 -0800
Message-ID: <1483116853-45769-1-git-send-email-sowmini.varadhan@oracle.com>
Cc: daniel@iogearbox.net, willemb@google.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17180 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751863AbcL3Qzc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 11:55:32 -0500
To: netdev@vger.kernel.org, sowmini.varadhan@oracle.com
To: sowmini.varadhan@oracle.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although TPACKET_V3 Rx has some benefits over TPACKET_V2 Rx,
*_v3 does not currently have Tx support. As a result an application
that wants the best perf for Tx and Rx (e.g. to handle
request/response transacations) ends up needing 2 sockets,
one with *_v2 for Tx and another with *_v3 for Rx.

This patch enables TPACKET_V2 compatible Tx features in TPACKET_V3
so that _v3 supports at least as many features as _v2.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 Documentation/networking/packet_mmap.txt |    6 ++++--
 net/packet/af_packet.c                   |   23 +++++++++++++++--------
 2 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
index daa015a..6425062 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -565,7 +565,7 @@ where 'tpacket_version' can be TPACKET_V1 (default), TPACKET_V2, TPACKET_V3.
 		   (void *)hdr + TPACKET_ALIGN(sizeof(struct tpacket_hdr))
 
 TPACKET_V2 --> TPACKET_V3:
-	- Flexible buffer implementation:
+	- Flexible buffer implementation for RX_RING:
 		1. Blocks can be configured with non-static frame-size
 		2. Read/poll is at a block-level (as opposed to packet-level)
 		3. Added poll timeout to avoid indefinite user-space wait
@@ -574,7 +574,9 @@ where 'tpacket_version' can be TPACKET_V1 (default), TPACKET_V2, TPACKET_V3.
 			4.1 block::timeout
 			4.2 tpkt_hdr::sk_rxhash
 	- RX Hash data available in user space
-	- Currently only RX_RING available
+	- TX_RING semantics are conceptually similar to TPACKET_V2;
+	  use tpacket3_hdr instead of tpacket2_hdr, and TPACKET3_HDRLEN
+	  instead of TPACKET2_HDRLEN.
 
 -------------------------------------------------------------------------------
 + AF_PACKET fanout mode
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 89f2e8c..57692af 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -409,6 +409,9 @@ static void __packet_set_status(struct packet_sock *po, void *frame, int status)
 		flush_dcache_page(pgv_to_page(&h.h2->tp_status));
 		break;
 	case TPACKET_V3:
+		h.h3->tp_status = status;
+		flush_dcache_page(pgv_to_page(&h.h3->tp_status));
+		break;
 	default:
 		WARN(1, "TPACKET version not supported.\n");
 		BUG();
@@ -432,6 +435,8 @@ static int __packet_get_status(struct packet_sock *po, void *frame)
 		flush_dcache_page(pgv_to_page(&h.h2->tp_status));
 		return h.h2->tp_status;
 	case TPACKET_V3:
+		flush_dcache_page(pgv_to_page(&h.h3->tp_status));
+		return h.h3->tp_status;
 	default:
 		WARN(1, "TPACKET version not supported.\n");
 		BUG();
@@ -2500,6 +2505,9 @@ static int tpacket_parse_header(struct packet_sock *po, void *frame,
 	ph.raw = frame;
 
 	switch (po->tp_version) {
+	case TPACKET_V3:
+		tp_len = ph.h3->tp_len;
+		break;
 	case TPACKET_V2:
 		tp_len = ph.h2->tp_len;
 		break;
@@ -2519,6 +2527,9 @@ static int tpacket_parse_header(struct packet_sock *po, void *frame,
 		off_max = po->tx_ring.frame_size - tp_len;
 		if (po->sk.sk_type == SOCK_DGRAM) {
 			switch (po->tp_version) {
+			case TPACKET_V3:
+				off = ph.h3->tp_net;
+				break;
 			case TPACKET_V2:
 				off = ph.h2->tp_net;
 				break;
@@ -2528,6 +2539,9 @@ static int tpacket_parse_header(struct packet_sock *po, void *frame,
 			}
 		} else {
 			switch (po->tp_version) {
+			case TPACKET_V3:
+				off = ph.h3->tp_mac;
+				break;
 			case TPACKET_V2:
 				off = ph.h2->tp_mac;
 				break;
@@ -4116,11 +4130,6 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 	struct tpacket_req *req = &req_u->req;
 
 	lock_sock(sk);
-	/* Opening a Tx-ring is NOT supported in TPACKET_V3 */
-	if (!closing && tx_ring && (po->tp_version > TPACKET_V2)) {
-		net_warn_ratelimited("Tx-ring is not supported.\n");
-		goto out;
-	}
 
 	rb = tx_ring ? &po->tx_ring : &po->rx_ring;
 	rb_queue = tx_ring ? &sk->sk_write_queue : &sk->sk_receive_queue;
@@ -4180,9 +4189,7 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 			goto out;
 		switch (po->tp_version) {
 		case TPACKET_V3:
-		/* Transmit path is not supported. We checked
-		 * it above but just being paranoid
-		 */
+			/* Block transmit is not supported yet */
 			if (!tx_ring)
 				init_prb_bdqc(po, rb, pg_vec, req_u);
 			break;
-- 
1.7.1
