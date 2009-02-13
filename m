From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 3/4] sctp: Fix the RTO-doubling on idle-link heartbeats
Date: Fri, 13 Feb 2009 13:33:43 -0500
Message-ID: <1234550024-30915-4-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:12875 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793AbZBMSdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 13:33:50 -0500
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP incorrectly doubles rto ever time a Hearbeat chunk
is generated.   However RFC 4960 states:

   On an idle destination address that is allowed to heartbeat, it is
   recommended that a HEARTBEAT chunk is sent once per RTO of that
   destination address plus the protocol parameter 'HB.interval', with
   jittering of +/- 50% of the RTO value, and exponential backoff of the
   RTO if the previous HEARTBEAT is unanswered.

Essentially, of if the heartbean is unacknowledged, do we double the RTO.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    2 ++
 net/sctp/sm_sideeffect.c   |   17 +++++++++++++++--
 net/sctp/transport.c       |    2 ++
 3 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 9f70d54..23f08fe 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -910,8 +910,10 @@ struct sctp_transport {
 	 *		should be set. Every time the RTT
 	 *		calculation completes (i.e. the DATA chunk
 	 *		is SACK'd) clear this flag.
+	 * hb_sent : a flag that signals that we have a pending heartbeat.
 	 */
 	__u8 rto_pending;
+	__u8 hb_sent;
 
 	/* Flag to track the current fast recovery state */
 	__u8 fast_recovery;
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index e1d6076..0146cfb 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -461,9 +461,15 @@ static void sctp_do_8_2_transport_strike(struct sctp_association *asoc,
 	 * expires, set RTO <- RTO * 2 ("back off the timer").  The
 	 * maximum value discussed in rule C7 above (RTO.max) may be
 	 * used to provide an upper bound to this doubling operation.
+	 *
+	 * Special Case:  the first HB doesn't trigger exponential backoff.
+	 * The first unacknowleged HB triggers it.  We do this with a flag
+	 * that indicates that we have an outstanding HB.
 	 */
-	transport->last_rto = transport->rto;
-	transport->rto = min((transport->rto * 2), transport->asoc->rto_max);
+	if (transport->hb_sent) {
+		transport->last_rto = transport->rto;
+		transport->rto = min((transport->rto * 2), transport->asoc->rto_max);
+	}
 }
 
 /* Worker routine to handle INIT command failure.  */
@@ -621,6 +627,11 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
 	t->error_count = 0;
 	t->asoc->overall_error_count = 0;
 
+	/* Clear the hb_sent flag to signal that we had a good
+	 * acknowledgement.
+	 */
+	t->hb_sent = 0;
+
 	/* Mark the destination transport address as active if it is not so
 	 * marked.
 	 */
@@ -657,6 +668,8 @@ static void sctp_cmd_transport_reset(sctp_cmd_seq_t *cmds,
 
 	/* Mark one strike against a transport.  */
 	sctp_do_8_2_transport_strike(asoc, t);
+
+	t->hb_sent = 1;
 }
 
 /* Helper function to process the process SACK command.  */
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index e745c11..5c29b14 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -79,6 +79,7 @@ static struct sctp_transport *sctp_transport_init(struct sctp_transport *peer,
 	peer->rttvar = 0;
 	peer->srtt = 0;
 	peer->rto_pending = 0;
+	peer->hb_sent = 0;
 	peer->fast_recovery = 0;
 
 	peer->last_time_heard = jiffies;
@@ -608,6 +609,7 @@ void sctp_transport_reset(struct sctp_transport *t)
 	t->flight_size = 0;
 	t->error_count = 0;
 	t->rto_pending = 0;
+	t->hb_sent = 0;
 	t->fast_recovery = 0;
 
 	/* Initialize the state information for SFR-CACC */
-- 
1.5.4.3

