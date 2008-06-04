From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 4/6] SCTP: Start T3-RTX timer when fast retransmitting lowest TSN
Date: Wed,  4 Jun 2008 14:25:49 -0400
Message-ID: <1212603951-24932-5-git-send-email-vladislav.yasevich@hp.com>
References: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org, davem@davemloft.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:42554 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758694AbYFDS0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 14:26:01 -0400
In-Reply-To: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we are trying to fast retransmit the lowest outstanding TSN, we
need to restart the T3-RTX timer, so that subsequent timeouts will
correctly tag all the packets necessary for retransmissions.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Tested-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 include/net/sctp/structs.h |    5 ++++-
 net/sctp/outqueue.c        |   42 +++++++++++++++++++++++++++++++-----------
 net/sctp/transport.c       |    4 ++--
 3 files changed, 37 insertions(+), 14 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 4f7b587..1014c77 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1050,7 +1050,7 @@ void sctp_transport_route(struct sctp_transport *, union sctp_addr *,
 			  struct sctp_sock *);
 void sctp_transport_pmtu(struct sctp_transport *);
 void sctp_transport_free(struct sctp_transport *);
-void sctp_transport_reset_timers(struct sctp_transport *);
+void sctp_transport_reset_timers(struct sctp_transport *, int);
 void sctp_transport_hold(struct sctp_transport *);
 void sctp_transport_put(struct sctp_transport *);
 void sctp_transport_update_rto(struct sctp_transport *, __u32);
@@ -1140,6 +1140,9 @@ struct sctp_outq {
 	/* How many unackd bytes do we have in-flight?	*/
 	__u32 outstanding_bytes;
 
+	/* Are we doing fast-rtx on this queue */
+	char fast_rtx;
+
 	/* Corked? */
 	char cork;
 
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 59edfd2..5d3c441 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -208,6 +208,7 @@ void sctp_outq_init(struct sctp_association *asoc, struct sctp_outq *q)
 	INIT_LIST_HEAD(&q->sacked);
 	INIT_LIST_HEAD(&q->abandoned);
 
+	q->fast_rtx = 0;
 	q->outstanding_bytes = 0;
 	q->empty = 1;
 	q->cork  = 0;
@@ -500,6 +501,7 @@ void sctp_retransmit(struct sctp_outq *q, struct sctp_transport *transport,
 	case SCTP_RTXR_FAST_RTX:
 		SCTP_INC_STATS(SCTP_MIB_FAST_RETRANSMITS);
 		sctp_transport_lower_cwnd(transport, SCTP_LOWER_CWND_FAST_RTX);
+		q->fast_rtx = 1;
 		break;
 	case SCTP_RTXR_PMTUD:
 		SCTP_INC_STATS(SCTP_MIB_PMTUD_RETRANSMITS);
@@ -543,10 +545,13 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 	sctp_xmit_t status;
 	struct sctp_chunk *chunk, *chunk1;
 	struct sctp_association *asoc;
+	int fast_rtx;
 	int error = 0;
+	int timer = 0;
 
 	asoc = q->asoc;
 	lqueue = &q->retransmit;
+	fast_rtx = q->fast_rtx;
 
 	/* RFC 2960 6.3.3 Handle T3-rtx Expiration
 	 *
@@ -587,13 +592,12 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 		switch (status) {
 		case SCTP_XMIT_PMTU_FULL:
 			/* Send this packet.  */
-			if ((error = sctp_packet_transmit(pkt)) == 0)
-				*start_timer = 1;
+			error = sctp_packet_transmit(pkt);
 
 			/* If we are retransmitting, we should only
 			 * send a single packet.
 			 */
-			if (rtx_timeout) {
+			if (rtx_timeout || fast_rtx) {
 				list_add(lchunk, lqueue);
 				lchunk = NULL;
 			}
@@ -603,8 +607,7 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 
 		case SCTP_XMIT_RWND_FULL:
 			/* Send this packet. */
-			if ((error = sctp_packet_transmit(pkt)) == 0)
-				*start_timer = 1;
+			error = sctp_packet_transmit(pkt);
 
 			/* Stop sending DATA as there is no more room
 			 * at the receiver.
@@ -615,8 +618,7 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 
 		case SCTP_XMIT_NAGLE_DELAY:
 			/* Send this packet. */
-			if ((error = sctp_packet_transmit(pkt)) == 0)
-				*start_timer = 1;
+			error = sctp_packet_transmit(pkt);
 
 			/* Stop sending DATA because of nagle delay. */
 			list_add(lchunk, lqueue);
@@ -635,7 +637,14 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 			if (chunk->fast_retransmit > 0)
 				chunk->fast_retransmit = -1;
 
-			*start_timer = 1;
+			/* Force start T3-rtx timer when fast retransmitting
+			 * the earliest outstanding TSN
+			 */
+			if (!timer && fast_rtx &&
+			    ntohl(chunk->subh.data_hdr->tsn) ==
+					     asoc->ctsn_ack_point + 1)
+				timer = 2;
+
 			q->empty = 0;
 
 			/* Retrieve a new chunk to bundle. */
@@ -643,12 +652,16 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 			break;
 		}
 
+		/* Set the timer if there were no errors */
+		if (!error && !timer)
+			timer = 1;
+
 		/* If we are here due to a retransmit timeout or a fast
 		 * retransmit and if there are any chunks left in the retransmit
 		 * queue that could not fit in the PMTU sized packet, they need
 		 * to be marked as ineligible for a subsequent fast retransmit.
 		 */
-		if (rtx_timeout && !lchunk) {
+		if (rtx_timeout && fast_rtx) {
 			list_for_each_entry(chunk1, lqueue, transmitted_list) {
 				if (chunk1->fast_retransmit > 0)
 					chunk1->fast_retransmit = -1;
@@ -656,6 +669,12 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 		}
 	}
 
+	*start_timer = timer;
+
+	/* Clear fast retransmit hint */
+	if (fast_rtx)
+		q->fast_rtx = 0;
+
 	return error;
 }
 
@@ -862,7 +881,8 @@ int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 						    rtx_timeout, &start_timer);
 
 			if (start_timer)
-				sctp_transport_reset_timers(transport);
+				sctp_transport_reset_timers(transport,
+							    start_timer-1);
 
 			/* This can happen on COOKIE-ECHO resend.  Only
 			 * one chunk can get bundled with a COOKIE-ECHO.
@@ -977,7 +997,7 @@ int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 			list_add_tail(&chunk->transmitted_list,
 				      &transport->transmitted);
 
-			sctp_transport_reset_timers(transport);
+			sctp_transport_reset_timers(transport, start_timer-1);
 
 			q->empty = 0;
 
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 3759027..33d9201 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -191,7 +191,7 @@ static void sctp_transport_destroy(struct sctp_transport *transport)
 /* Start T3_rtx timer if it is not already running and update the heartbeat
  * timer.  This routine is called every time a DATA chunk is sent.
  */
-void sctp_transport_reset_timers(struct sctp_transport *transport)
+void sctp_transport_reset_timers(struct sctp_transport *transport, int force)
 {
 	/* RFC 2960 6.3.2 Retransmission Timer Rules
 	 *
@@ -201,7 +201,7 @@ void sctp_transport_reset_timers(struct sctp_transport *transport)
 	 * address.
 	 */
 
-	if (!timer_pending(&transport->T3_rtx_timer))
+	if (force || !timer_pending(&transport->T3_rtx_timer))
 		if (!mod_timer(&transport->T3_rtx_timer,
 			       jiffies + transport->rto))
 			sctp_transport_hold(transport);
-- 
1.5.3.5

