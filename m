From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 5/6] SCTP: Flush the queue only once during fast retransmit.
Date: Wed,  4 Jun 2008 14:25:50 -0400
Message-ID: <1212603951-24932-6-git-send-email-vladislav.yasevich@hp.com>
References: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org, davem@davemloft.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:49106 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758846AbYFDS0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 14:26:02 -0400
In-Reply-To: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When fast retransmit is triggered by a sack, we should flush
the queue only once so that only 1 retransmit happens.  Also,
since we could potentially have non-fast-rtx chunks on
the retransmit queue, we need make sure any chunks eligable
for fast retransmit are sent first during fast retransmission.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Tested-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/outqueue.c |   82 ++++++++++++++++++++++++++++++---------------------
 1 files changed, 48 insertions(+), 34 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 5d3c441..ace6770 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -520,9 +520,15 @@ void sctp_retransmit(struct sctp_outq *q, struct sctp_transport *transport,
 	 * the sender SHOULD try to advance the "Advanced.Peer.Ack.Point" by
 	 * following the procedures outlined in C1 - C5.
 	 */
-	sctp_generate_fwdtsn(q, q->asoc->ctsn_ack_point);
+	if (reason == SCTP_RTXR_T3_RTX)
+		sctp_generate_fwdtsn(q, q->asoc->ctsn_ack_point);
 
-	error = sctp_outq_flush(q, /* rtx_timeout */ 1);
+	/* Flush the queues only on timeout, since fast_rtx is only
+	 * triggered during sack processing and the queue
+	 * will be flushed at the end.
+	 */
+	if (reason != SCTP_RTXR_FAST_RTX)
+		error = sctp_outq_flush(q, /* rtx_timeout */ 1);
 
 	if (error)
 		q->asoc->base.sk->sk_err = -error;
@@ -540,7 +546,6 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 			       int rtx_timeout, int *start_timer)
 {
 	struct list_head *lqueue;
-	struct list_head *lchunk;
 	struct sctp_transport *transport = pkt->transport;
 	sctp_xmit_t status;
 	struct sctp_chunk *chunk, *chunk1;
@@ -548,12 +553,16 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 	int fast_rtx;
 	int error = 0;
 	int timer = 0;
+	int done = 0;
 
 	asoc = q->asoc;
 	lqueue = &q->retransmit;
 	fast_rtx = q->fast_rtx;
 
-	/* RFC 2960 6.3.3 Handle T3-rtx Expiration
+	/* This loop handles time-out retransmissions, fast retransmissions,
+	 * and retransmissions due to opening of whindow.
+	 *
+	 * RFC 2960 6.3.3 Handle T3-rtx Expiration
 	 *
 	 * E3) Determine how many of the earliest (i.e., lowest TSN)
 	 * outstanding DATA chunks for the address for which the
@@ -568,12 +577,12 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 	 * [Just to be painfully clear, if we are retransmitting
 	 * because a timeout just happened, we should send only ONE
 	 * packet of retransmitted data.]
+	 *
+	 * For fast retransmissions we also send only ONE packet.  However,
+	 * if we are just flushing the queue due to open window, we'll
+	 * try to send as much as possible.
 	 */
-	lchunk = sctp_list_dequeue(lqueue);
-
-	while (lchunk) {
-		chunk = list_entry(lchunk, struct sctp_chunk,
-				   transmitted_list);
+	list_for_each_entry_safe(chunk, chunk1, lqueue, transmitted_list) {
 
 		/* Make sure that Gap Acked TSNs are not retransmitted.  A
 		 * simple approach is just to move such TSNs out of the
@@ -581,11 +590,18 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 		 * next chunk.
 		 */
 		if (chunk->tsn_gap_acked) {
-			list_add_tail(lchunk, &transport->transmitted);
-			lchunk = sctp_list_dequeue(lqueue);
+			list_del(&chunk->transmitted_list);
+			list_add_tail(&chunk->transmitted_list,
+					&transport->transmitted);
 			continue;
 		}
 
+		/* If we are doing fast retransmit, ignore non-fast_rtransmit
+		 * chunks
+		 */
+		if (fast_rtx && !chunk->fast_retransmit)
+			continue;
+
 		/* Attempt to append this chunk to the packet. */
 		status = sctp_packet_append_chunk(pkt, chunk);
 
@@ -597,12 +613,10 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 			/* If we are retransmitting, we should only
 			 * send a single packet.
 			 */
-			if (rtx_timeout || fast_rtx) {
-				list_add(lchunk, lqueue);
-				lchunk = NULL;
-			}
+			if (rtx_timeout || fast_rtx)
+				done = 1;
 
-			/* Bundle lchunk in the next round.  */
+			/* Bundle next chunk in the next round.  */
 			break;
 
 		case SCTP_XMIT_RWND_FULL:
@@ -612,8 +626,7 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 			/* Stop sending DATA as there is no more room
 			 * at the receiver.
 			 */
-			list_add(lchunk, lqueue);
-			lchunk = NULL;
+			done = 1;
 			break;
 
 		case SCTP_XMIT_NAGLE_DELAY:
@@ -621,15 +634,16 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 			error = sctp_packet_transmit(pkt);
 
 			/* Stop sending DATA because of nagle delay. */
-			list_add(lchunk, lqueue);
-			lchunk = NULL;
+			done = 1;
 			break;
 
 		default:
 			/* The append was successful, so add this chunk to
 			 * the transmitted list.
 			 */
-			list_add_tail(lchunk, &transport->transmitted);
+			list_del(&chunk->transmitted_list);
+			list_add_tail(&chunk->transmitted_list,
+					&transport->transmitted);
 
 			/* Mark the chunk as ineligible for fast retransmit
 			 * after it is retransmitted.
@@ -646,9 +660,6 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 				timer = 2;
 
 			q->empty = 0;
-
-			/* Retrieve a new chunk to bundle. */
-			lchunk = sctp_list_dequeue(lqueue);
 			break;
 		}
 
@@ -656,16 +667,19 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 		if (!error && !timer)
 			timer = 1;
 
-		/* If we are here due to a retransmit timeout or a fast
-		 * retransmit and if there are any chunks left in the retransmit
-		 * queue that could not fit in the PMTU sized packet, they need
-		 * to be marked as ineligible for a subsequent fast retransmit.
-		 */
-		if (rtx_timeout && fast_rtx) {
-			list_for_each_entry(chunk1, lqueue, transmitted_list) {
-				if (chunk1->fast_retransmit > 0)
-					chunk1->fast_retransmit = -1;
-			}
+		if (done)
+			break;
+	}
+
+	/* If we are here due to a retransmit timeout or a fast
+	 * retransmit and if there are any chunks left in the retransmit
+	 * queue that could not fit in the PMTU sized packet, they need
+	 * to be marked as ineligible for a subsequent fast retransmit.
+	 */
+	if (rtx_timeout || fast_rtx) {
+		list_for_each_entry(chunk1, lqueue, transmitted_list) {
+			if (chunk1->fast_retransmit > 0)
+				chunk1->fast_retransmit = -1;
 		}
 	}
 
-- 
1.5.3.5

