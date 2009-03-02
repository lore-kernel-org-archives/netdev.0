From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 5/5] sctp: Fix broken RTO-doubling for data retransmits
Date: Mon,  2 Mar 2009 14:46:14 -0500
Message-ID: <1236023174-18314-6-git-send-email-vladislav.yasevich@hp.com>
References: <>
 <1236023174-18314-1-git-send-email-vladislav.yasevich@hp.com>
 <1236023174-18314-2-git-send-email-vladislav.yasevich@hp.com>
 <1236023174-18314-3-git-send-email-vladislav.yasevich@hp.com>
 <1236023174-18314-4-git-send-email-vladislav.yasevich@hp.com>
 <1236023174-18314-5-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:16225 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306AbZCBTq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 14:46:27 -0500
In-Reply-To: <1236023174-18314-5-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit faee47cdbfe8d74a1573c2f81ea6dbb08d735be6
(sctp: Fix the RTO-doubling on idle-link heartbeats)
broke the RTO doubling for data retransmits.  If the
heartbeat was sent before the data T3-rtx time, the
the RTO will not double upon the T3-rtx expiration.
Distingish between the operations by passing an argument
to the function.

Additionally, Wei Youngjun pointed out that our treatment
of requested HEARTBEATS and timer HEARTBEATS is the same
wrt resetting congestion window.  That needs to be separated,
since user requested HEARTBEATS should not treat the link
as idle.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/command.h |    3 ++-
 net/sctp/sm_sideeffect.c   |   32 +++++++++++++-------------------
 net/sctp/sm_statefuns.c    |    6 ++++--
 3 files changed, 19 insertions(+), 22 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 88988ab..3b96680 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -77,7 +77,8 @@ typedef enum {
 	SCTP_CMD_HB_TIMERS_START,    /* Start the heartbeat timers. */
 	SCTP_CMD_HB_TIMER_UPDATE,    /* Update a heartbeat timers.  */
 	SCTP_CMD_HB_TIMERS_STOP,     /* Stop the heartbeat timers.  */
-	SCTP_CMD_TRANSPORT_RESET,    /* Reset the status of a transport. */
+	SCTP_CMD_TRANSPORT_HB_SENT,  /* Reset the status of a transport. */
+	SCTP_CMD_TRANSPORT_IDLE,     /* Do manipulations on idle transport */
 	SCTP_CMD_TRANSPORT_ON,       /* Mark the transport as active. */
 	SCTP_CMD_REPORT_ERROR,   /* Pass this error back out of the sm. */
 	SCTP_CMD_REPORT_BAD_TAG, /* Verification tags didn't match. */
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 0146cfb..5385150 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -434,7 +434,8 @@ sctp_timer_event_t *sctp_timer_events[SCTP_NUM_TIMEOUT_TYPES] = {
  *
  */
 static void sctp_do_8_2_transport_strike(struct sctp_association *asoc,
-					 struct sctp_transport *transport)
+					 struct sctp_transport *transport,
+					 int is_hb)
 {
 	/* The check for association's overall error counter exceeding the
 	 * threshold is done in the state function.
@@ -466,7 +467,7 @@ static void sctp_do_8_2_transport_strike(struct sctp_association *asoc,
 	 * The first unacknowleged HB triggers it.  We do this with a flag
 	 * that indicates that we have an outstanding HB.
 	 */
-	if (transport->hb_sent) {
+	if (!is_hb || transport->hb_sent) {
 		transport->last_rto = transport->rto;
 		transport->rto = min((transport->rto * 2), transport->asoc->rto_max);
 	}
@@ -657,20 +658,6 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
 		sctp_transport_hold(t);
 }
 
-/* Helper function to do a transport reset at the expiry of the hearbeat
- * timer.
- */
-static void sctp_cmd_transport_reset(sctp_cmd_seq_t *cmds,
-				     struct sctp_association *asoc,
-				     struct sctp_transport *t)
-{
-	sctp_transport_lower_cwnd(t, SCTP_LOWER_CWND_INACTIVE);
-
-	/* Mark one strike against a transport.  */
-	sctp_do_8_2_transport_strike(asoc, t);
-
-	t->hb_sent = 1;
-}
 
 /* Helper function to process the process SACK command.  */
 static int sctp_cmd_process_sack(sctp_cmd_seq_t *cmds,
@@ -1459,12 +1446,19 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 
 		case SCTP_CMD_STRIKE:
 			/* Mark one strike against a transport.  */
-			sctp_do_8_2_transport_strike(asoc, cmd->obj.transport);
+			sctp_do_8_2_transport_strike(asoc, cmd->obj.transport,
+						    0);
+			break;
+
+		case SCTP_CMD_TRANSPORT_IDLE:
+			t = cmd->obj.transport;
+			sctp_transport_lower_cwnd(t, SCTP_LOWER_CWND_INACTIVE);
 			break;
 
-		case SCTP_CMD_TRANSPORT_RESET:
+		case SCTP_CMD_TRANSPORT_HB_SENT:
 			t = cmd->obj.transport;
-			sctp_cmd_transport_reset(commands, asoc, t);
+			sctp_do_8_2_transport_strike(asoc, t, 1);
+			t->hb_sent = 1;
 			break;
 
 		case SCTP_CMD_TRANSPORT_ON:
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 3a0cd07..a907bab 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -988,7 +988,9 @@ sctp_disposition_t sctp_sf_sendbeat_8_3(const struct sctp_endpoint *ep,
 		/* Set transport error counter and association error counter
 		 * when sending heartbeat.
 		 */
-		sctp_add_cmd_sf(commands, SCTP_CMD_TRANSPORT_RESET,
+		sctp_add_cmd_sf(commands, SCTP_CMD_TRANSPORT_IDLE,
+				SCTP_TRANSPORT(transport));
+		sctp_add_cmd_sf(commands, SCTP_CMD_TRANSPORT_HB_SENT,
 				SCTP_TRANSPORT(transport));
 	}
 	sctp_add_cmd_sf(commands, SCTP_CMD_HB_TIMER_UPDATE,
@@ -4967,7 +4969,7 @@ sctp_disposition_t sctp_sf_do_prm_requestheartbeat(
 	 *    to that address and not acknowledged within one RTO.
 	 *
 	 */
-	sctp_add_cmd_sf(commands, SCTP_CMD_TRANSPORT_RESET,
+	sctp_add_cmd_sf(commands, SCTP_CMD_TRANSPORT_HB_SENT,
 			SCTP_TRANSPORT(arg));
 	return SCTP_DISPOSITION_CONSUME;
 }
-- 
1.5.4.3

