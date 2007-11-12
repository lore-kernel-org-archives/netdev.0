From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 03/14] SCTP: Fix difference cases of retransmit.
Date: Mon, 12 Nov 2007 11:38:18 -0500
Message-ID: <11948855124148-git-send-email-vladislav.yasevich@hp.com>
References: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:47686 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753812AbXKLQid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 11:38:33 -0500
In-Reply-To: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit d0ce92910bc04e107b2f3f2048f07e94f570035d broke several retransmit
cases including fast retransmit.  The reason is that we should
only delay by rto while doing retranmists as a result of a timeout.
Retransmit as a result of path mtu discover, fast retransmit, or
other evernts that should trigger immidiate retransmissions got broken.

Also, since rto is doubled prior to marking of packets elegable for
retransmission, we never marked correct chunks anyway.

The fix is provide a reason for a given retransmission so that we
can mark chunks appropriately and to save the old rto value to do
comparisons against.

All regressions tests passed with this code.

Spotted by Wei Yongjun <yjwei@cn.fujitsu.com>

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/command.h   |    1 +
 include/net/sctp/constants.h |    1 +
 include/net/sctp/sctp.h      |    1 +
 include/net/sctp/structs.h   |    5 +++--
 net/sctp/outqueue.c          |   33 +++++++++++++++++----------------
 net/sctp/sm_sideeffect.c     |   10 +++++++++-
 net/sctp/sm_statefuns.c      |    2 +-
 net/sctp/transport.c         |    5 +++--
 8 files changed, 36 insertions(+), 22 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index b873336..c1f7976 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -103,6 +103,7 @@ typedef enum {
 	SCTP_CMD_ASSOC_CHANGE,	 /* generate and send assoc_change event */
 	SCTP_CMD_ADAPTATION_IND, /* generate and send adaptation event */
 	SCTP_CMD_ASSOC_SHKEY,    /* generate the association shared keys */
+	SCTP_CMD_T1_RETRAN,	 /* Mark for retransmission after T1 timeout  */
 	SCTP_CMD_LAST
 } sctp_verb_t;
 
diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index da8354e..73fbdf6 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -407,6 +407,7 @@ typedef enum {
 	SCTP_RTXR_T3_RTX,
 	SCTP_RTXR_FAST_RTX,
 	SCTP_RTXR_PMTUD,
+	SCTP_RTXR_T1_RTX,
 } sctp_retransmit_reason_t;
 
 /* Reasons to lower cwnd. */
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 93eb708..7082730 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -267,6 +267,7 @@ enum
 	SCTP_MIB_T5_SHUTDOWN_GUARD_EXPIREDS,
 	SCTP_MIB_DELAY_SACK_EXPIREDS,
 	SCTP_MIB_AUTOCLOSE_EXPIREDS,
+	SCTP_MIB_T1_RETRANSMITS,
 	SCTP_MIB_T3_RETRANSMITS,
 	SCTP_MIB_PMTUD_RETRANSMITS,
 	SCTP_MIB_FAST_RETRANSMITS,
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index ef892e0..482c2aa 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -873,10 +873,11 @@ struct sctp_transport {
 	 * address list derived from the INIT or INIT ACK chunk, a
 	 * number of data elements needs to be maintained including:
 	 */
-	__u32 rtt;		/* This is the most recent RTT.	 */
-
 	/* RTO	       : The current retransmission timeout value.  */
 	unsigned long rto;
+	unsigned long last_rto;
+
+	__u32 rtt;		/* This is the most recent RTT.	 */
 
 	/* RTTVAR      : The current RTT variation.  */
 	__u32 rttvar;
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index e315c6c..99a3db5 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -382,7 +382,7 @@ static void sctp_insert_list(struct list_head *head, struct list_head *new)
 /* Mark all the eligible packets on a transport for retransmission.  */
 void sctp_retransmit_mark(struct sctp_outq *q,
 			  struct sctp_transport *transport,
-			  __u8 fast_retransmit)
+			  __u8 reason)
 {
 	struct list_head *lchunk, *ltemp;
 	struct sctp_chunk *chunk;
@@ -412,20 +412,20 @@ void sctp_retransmit_mark(struct sctp_outq *q,
 			continue;
 		}
 
-		/* If we are doing retransmission due to a fast retransmit,
-		 * only the chunk's that are marked for fast retransmit
-		 * should be added to the retransmit queue.  If we are doing
-		 * retransmission due to a timeout or pmtu discovery, only the
-		 * chunks that are not yet acked should be added to the
-		 * retransmit queue.
+		/* If we are doing  retransmission due to a timeout or pmtu
+		 * discovery, only the  chunks that are not yet acked should
+		 * be added to the retransmit queue.
 		 */
-		if ((fast_retransmit && (chunk->fast_retransmit > 0)) ||
-		   (!fast_retransmit && !chunk->tsn_gap_acked)) {
+		if ((reason == SCTP_RTXR_FAST_RTX  &&
+			    (chunk->fast_retransmit > 0)) ||
+		    (reason != SCTP_RTXR_FAST_RTX  && !chunk->tsn_gap_acked)) {
 			/* If this chunk was sent less then 1 rto ago, do not
 			 * retransmit this chunk, but give the peer time
-			 * to acknowlege it.
+			 * to acknowlege it.  Do this only when
+			 * retransmitting due to T3 timeout.
 			 */
-			if ((jiffies - chunk->sent_at) < transport->rto)
+			if (reason == SCTP_RTXR_T3_RTX &&
+			    (jiffies - chunk->sent_at) < transport->last_rto)
 				continue;
 
 			/* RFC 2960 6.2.1 Processing a Received SACK
@@ -467,10 +467,10 @@ void sctp_retransmit_mark(struct sctp_outq *q,
 		}
 	}
 
-	SCTP_DEBUG_PRINTK("%s: transport: %p, fast_retransmit: %d, "
+	SCTP_DEBUG_PRINTK("%s: transport: %p, reason: %d, "
 			  "cwnd: %d, ssthresh: %d, flight_size: %d, "
 			  "pba: %d\n", __FUNCTION__,
-			  transport, fast_retransmit,
+			  transport, reason,
 			  transport->cwnd, transport->ssthresh,
 			  transport->flight_size,
 			  transport->partial_bytes_acked);
@@ -484,7 +484,6 @@ void sctp_retransmit(struct sctp_outq *q, struct sctp_transport *transport,
 		     sctp_retransmit_reason_t reason)
 {
 	int error = 0;
-	__u8 fast_retransmit = 0;
 
 	switch(reason) {
 	case SCTP_RTXR_T3_RTX:
@@ -499,16 +498,18 @@ void sctp_retransmit(struct sctp_outq *q, struct sctp_transport *transport,
 	case SCTP_RTXR_FAST_RTX:
 		SCTP_INC_STATS(SCTP_MIB_FAST_RETRANSMITS);
 		sctp_transport_lower_cwnd(transport, SCTP_LOWER_CWND_FAST_RTX);
-		fast_retransmit = 1;
 		break;
 	case SCTP_RTXR_PMTUD:
 		SCTP_INC_STATS(SCTP_MIB_PMTUD_RETRANSMITS);
 		break;
+	case SCTP_RTXR_T1_RTX:
+		SCTP_INC_STATS(SCTP_MIB_T1_RETRANSMITS);
+		break;
 	default:
 		BUG();
 	}
 
-	sctp_retransmit_mark(q, transport, fast_retransmit);
+	sctp_retransmit_mark(q, transport, reason);
 
 	/* PR-SCTP A5) Any time the T3-rtx timer expires, on any destination,
 	 * the sender SHOULD try to advance the "Advanced.Peer.Ack.Point" by
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index bbdc938..78d1a8a 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -453,6 +453,7 @@ static void sctp_do_8_2_transport_strike(struct sctp_association *asoc,
 	 * maximum value discussed in rule C7 above (RTO.max) may be
 	 * used to provide an upper bound to this doubling operation.
 	 */
+	transport->last_rto = transport->rto;
 	transport->rto = min((transport->rto * 2), transport->asoc->rto_max);
 }
 
@@ -1267,6 +1268,12 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 			sctp_ootb_pkt_free(packet);
 			break;
 
+		case SCTP_CMD_T1_RETRAN:
+			/* Mark a transport for retransmission.  */
+			sctp_retransmit(&asoc->outqueue, cmd->obj.transport,
+					SCTP_RTXR_T1_RTX);
+			break;
+
 		case SCTP_CMD_RETRAN:
 			/* Mark a transport for retransmission.  */
 			sctp_retransmit(&asoc->outqueue, cmd->obj.transport,
@@ -1393,7 +1400,8 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 			list_for_each(pos, &asoc->peer.transport_addr_list) {
 				t = list_entry(pos, struct sctp_transport,
 					       transports);
-				sctp_retransmit_mark(&asoc->outqueue, t, 0);
+				sctp_retransmit_mark(&asoc->outqueue, t,
+					    SCTP_RTXR_T1_RTX);
 			}
 
 			sctp_add_cmd_sf(commands,
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index f01b408..a66075a 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2305,7 +2305,7 @@ static sctp_disposition_t sctp_sf_do_5_2_6_stale(const struct sctp_endpoint *ep,
 	/* If we've sent any data bundled with COOKIE-ECHO we will need to
 	 * resend
 	 */
-	sctp_add_cmd_sf(commands, SCTP_CMD_RETRAN,
+	sctp_add_cmd_sf(commands, SCTP_CMD_T1_RETRAN,
 			SCTP_TRANSPORT(asoc->peer.primary_path));
 
 	/* Cast away the const modifier, as we want to just
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 5f467c9..d55ce83 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -74,8 +74,8 @@ static struct sctp_transport *sctp_transport_init(struct sctp_transport *peer,
 	 * given destination transport address, set RTO to the protocol
 	 * parameter 'RTO.Initial'.
 	 */
+	peer->last_rto = peer->rto = msecs_to_jiffies(sctp_rto_initial);
 	peer->rtt = 0;
-	peer->rto = msecs_to_jiffies(sctp_rto_initial);
 	peer->rttvar = 0;
 	peer->srtt = 0;
 	peer->rto_pending = 0;
@@ -385,6 +385,7 @@ void sctp_transport_update_rto(struct sctp_transport *tp, __u32 rtt)
 		tp->rto = tp->asoc->rto_max;
 
 	tp->rtt = rtt;
+	tp->last_rto = tp->rto;
 
 	/* Reset rto_pending so that a new RTT measurement is started when a
 	 * new data chunk is sent.
@@ -578,7 +579,7 @@ void sctp_transport_reset(struct sctp_transport *t)
 	 */
 	t->cwnd = min(4*asoc->pathmtu, max_t(__u32, 2*asoc->pathmtu, 4380));
 	t->ssthresh = asoc->peer.i.a_rwnd;
-	t->rto = asoc->rto_initial;
+	t->last_rto = t->rto = asoc->rto_initial;
 	t->rtt = 0;
 	t->srtt = 0;
 	t->rttvar = 0;
-- 
1.5.2.4

