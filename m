From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: reduce memory footprint of sctp_chunk structure
Date: Fri, 25 Jul 2008 12:44:09 -0400
Message-ID: <20080725164409.GD12725@hmsreliant.think-freely.org>
References: <20080725121130.GB12725@hmsreliant.think-freely.org> <4889CF25.30405@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3441 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016AbYGYQou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 12:44:50 -0400
Content-Disposition: inline
In-Reply-To: <4889CF25.30405@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2008 at 09:03:33AM -0400, Vlad Yasevich wrote:
> Hi Neil
> 
> A few small nits.
> 
No problem, New patch attached.

sctp_chunks should be put on a diet.  This is some of the low hanging fruit that
we can strip out.  Changes all the __s8/__u8 flags to bitfields.  Saves 12 bytes
per chunk.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/net/sctp/structs.h |   31 +++++++++++++++++--------------
 net/sctp/output.c          |    2 +-
 net/sctp/outqueue.c        |   14 +++++++-------
 net/sctp/sm_make_chunk.c   |    2 +-
 4 files changed, 26 insertions(+), 23 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 7f25195..1f9ae90 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -731,20 +731,23 @@ struct sctp_chunk {
 	 */
 	struct sk_buff *auth_chunk;
 
-	__u8 rtt_in_progress;	/* Is this chunk used for RTT calculation? */
-	__u8 resent;		/* Has this chunk ever been retransmitted. */
-	__u8 has_tsn;		/* Does this chunk have a TSN yet? */
-	__u8 has_ssn;		/* Does this chunk have a SSN yet? */
-	__u8 singleton;		/* Was this the only chunk in the packet? */
-	__u8 end_of_packet;	/* Was this the last chunk in the packet? */
-	__u8 ecn_ce_done;	/* Have we processed the ECN CE bit? */
-	__u8 pdiscard;		/* Discard the whole packet now? */
-	__u8 tsn_gap_acked;	/* Is this chunk acked by a GAP ACK? */
-	__s8 fast_retransmit;	 /* Is this chunk fast retransmitted? */
-	__u8 tsn_missing_report; /* Data chunk missing counter. */
-	__u8 data_accepted; 	/* At least 1 chunk in this packet accepted */
-	__u8 auth;		/* IN: was auth'ed | OUT: needs auth */
-	__u8 has_asconf;	/* IN: have seen an asconf before */
+#define SCTP_CAN_FRTX 0x0
+#define SCTP_NEED_FRTX 0x1
+#define SCTP_DONT_FRTX 0x2
+	__u16	rtt_in_progress:1,	/* This chunk used for RTT calc? */
+		resent:1,		/* Has this chunk ever been resent. */
+		has_tsn:1,		/* Does this chunk have a TSN yet? */
+		has_ssn:1,		/* Does this chunk have a SSN yet? */
+		singleton:1,		/* Only chunk in the packet? */
+		end_of_packet:1,	/* Last chunk in the packet? */
+		ecn_ce_done:1,		/* Have we processed the ECN CE bit? */
+		pdiscard:1,		/* Discard the whole packet now? */
+		tsn_gap_acked:1,	/* Is this chunk acked by a GAP ACK? */
+		tsn_missing_report:1,	/* Data chunk missing counter. */
+		data_accepted:1,	/* At least 1 chunk accepted */
+		auth:1,			/* IN: was auth'ed | OUT: needs auth */
+		has_asconf:1,		/* IN: have seen an asconf before */
+		fast_retransmit:2;	/* Is this chunk fast retransmitted? */
 };
 
 void sctp_chunk_hold(struct sctp_chunk *);
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 7e7e612..548b567 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -709,7 +709,7 @@ static sctp_xmit_t sctp_packet_append_data(struct sctp_packet *packet,
 	 *    When a Fast Retransmit is being performed the sender SHOULD
 	 *    ignore the value of cwnd and SHOULD NOT delay retransmission.
 	 */
-	if (chunk->fast_retransmit <= 0)
+	if (chunk->fast_retransmit != SCTP_CAN_FRTX)
 		if (transport->flight_size >= transport->cwnd) {
 			retval = SCTP_XMIT_RWND_FULL;
 			goto finish;
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index ace6770..34405f0 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -418,7 +418,7 @@ void sctp_retransmit_mark(struct sctp_outq *q,
 		 * be added to the retransmit queue.
 		 */
 		if ((reason == SCTP_RTXR_FAST_RTX  &&
-			    (chunk->fast_retransmit > 0)) ||
+			    (chunk->fast_retransmit == SCTP_NEED_FRTX)) ||
 		    (reason != SCTP_RTXR_FAST_RTX  && !chunk->tsn_gap_acked)) {
 			/* If this chunk was sent less then 1 rto ago, do not
 			 * retransmit this chunk, but give the peer time
@@ -648,8 +648,8 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 			/* Mark the chunk as ineligible for fast retransmit
 			 * after it is retransmitted.
 			 */
-			if (chunk->fast_retransmit > 0)
-				chunk->fast_retransmit = -1;
+			if (chunk->fast_retransmit == SCTP_NEED_FRTX)
+				chunk->fast_retransmit = SCTP_DONT_FRTX;
 
 			/* Force start T3-rtx timer when fast retransmitting
 			 * the earliest outstanding TSN
@@ -678,8 +678,8 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 	 */
 	if (rtx_timeout || fast_rtx) {
 		list_for_each_entry(chunk1, lqueue, transmitted_list) {
-			if (chunk1->fast_retransmit > 0)
-				chunk1->fast_retransmit = -1;
+			if (chunk1->fast_retransmit == SCTP_NEED_FRTX)
+				chunk1->fast_retransmit = SCTP_DONT_FRTX;
 		}
 	}
 
@@ -1635,7 +1635,7 @@ static void sctp_mark_missing(struct sctp_outq *q,
 		 * chunk if it has NOT been fast retransmitted or marked for
 		 * fast retransmit already.
 		 */
-		if (!chunk->fast_retransmit &&
+		if (!(chunk->fast_retransmit == SCTP_NEED_FRTX) &&
 		    !chunk->tsn_gap_acked &&
 		    TSN_lt(tsn, highest_new_tsn_in_sack)) {
 
@@ -1660,7 +1660,7 @@ static void sctp_mark_missing(struct sctp_outq *q,
 		 */
 
 		if (chunk->tsn_missing_report >= 3) {
-			chunk->fast_retransmit = 1;
+			chunk->fast_retransmit = SCTP_NEED_FRTX;
 			do_fast_retransmit = 1;
 		}
 	}
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 3b55ad1..c9264dc 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1195,7 +1195,7 @@ struct sctp_chunk *sctp_chunkify(struct sk_buff *skb,
 	 */
 	retval->tsn_missing_report = 0;
 	retval->tsn_gap_acked = 0;
-	retval->fast_retransmit = 0;
+	retval->fast_retransmit = SCTP_CAN_FRTX;
 
 	/* If this is a fragmented message, track all fragments
 	 * of the message (for SEND_FAILED).

-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
