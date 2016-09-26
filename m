From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 2/5] sctp: reuse sent_count to avoid retransmitted chunks for RTT measurements
Date: Mon, 26 Sep 2016 17:47:51 +0800
Message-ID: <e8146a7075544ccb2631117f507cfd51e20b4cde.1474883200.git.lucien.xin@gmail.com>
References: <cover.1474883200.git.lucien.xin@gmail.com>
 <03a642a76d02e8536404aa27561c44e348f3e3a0.1474883200.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33213 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030209AbcIZJsF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 05:48:05 -0400
In-Reply-To: <03a642a76d02e8536404aa27561c44e348f3e3a0.1474883200.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1474883200.git.lucien.xin@gmail.com>
References: <cover.1474883200.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now sctp uses chunk->resent to record if a chunk is retransmitted, for
RTT measurements with retransmitted DATA chunks. chunk->sent_count was
introduced to record how many times one chunk has been sent for prsctp
RTX policy before. We actually can know if one chunk is retransmitted
by checking chunk->sent_count is greater than 1.

This patch is to remove resent from sctp_chunk and reuse sent_count
to avoid retransmitted chunks for RTT measurements.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h | 1 -
 net/sctp/output.c          | 3 ++-
 net/sctp/outqueue.c        | 4 +---
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 4f097f5..81a5faa 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -647,7 +647,6 @@ struct sctp_chunk {
 #define SCTP_NEED_FRTX 0x1
 #define SCTP_DONT_FRTX 0x2
 	__u16	rtt_in_progress:1,	/* This chunk used for RTT calc? */
-		resent:1,		/* Has this chunk ever been resent. */
 		has_tsn:1,		/* Does this chunk have a TSN yet? */
 		has_ssn:1,		/* Does this chunk have a SSN yet? */
 		singleton:1,		/* Only chunk in the packet? */
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 31b7bc3..483d2ed 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -547,7 +547,8 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 				 * for a given destination transport address.
 				 */
 
-				if (!chunk->resent && !tp->rto_pending) {
+				if (chunk->sent_count == 1 &&
+				    !tp->rto_pending) {
 					chunk->rtt_in_progress = 1;
 					tp->rto_pending = 1;
 				}
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 72e54a4..2a629fa 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -536,8 +536,6 @@ void sctp_retransmit_mark(struct sctp_outq *q,
 				transport->rto_pending = 0;
 			}
 
-			chunk->resent = 1;
-
 			/* Move the chunk to the retransmit queue. The chunks
 			 * on the retransmit queue are always kept in order.
 			 */
@@ -1467,7 +1465,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 				 * instance).
 				 */
 				if (!tchunk->tsn_gap_acked &&
-				    !tchunk->resent &&
+				    tchunk->sent_count == 1 &&
 				    tchunk->rtt_in_progress) {
 					tchunk->rtt_in_progress = 0;
 					rtt = jiffies - tchunk->sent_at;
-- 
2.1.0
