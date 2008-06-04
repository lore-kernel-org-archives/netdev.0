From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 3/6] SCTP: Correctly implement Fast Recovery cwnd manipulations.
Date: Wed,  4 Jun 2008 14:25:48 -0400
Message-ID: <1212603951-24932-4-git-send-email-vladislav.yasevich@hp.com>
References: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org, davem@davemloft.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:15288 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757431AbYFDS0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 14:26:00 -0400
In-Reply-To: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correctly keep track of Fast Recovery state and do not reduce
congestion window multiple times during sucht state.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Tested-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 include/net/sctp/structs.h |    8 +++++++-
 net/sctp/transport.c       |   44 ++++++++++++++++++++++++++++++++------------
 2 files changed, 39 insertions(+), 13 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 0ce0443..4f7b587 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -901,7 +901,10 @@ struct sctp_transport {
 	 *		calculation completes (i.e. the DATA chunk
 	 *		is SACK'd) clear this flag.
 	 */
-	int rto_pending;
+	__u8 rto_pending;
+
+	/* Flag to track the current fast recovery state */
+	__u8 fast_recovery;
 
 	/*
 	 * These are the congestion stats.
@@ -920,6 +923,9 @@ struct sctp_transport {
 	/* Data that has been sent, but not acknowledged. */
 	__u32 flight_size;
 
+	/* TSN marking the fast recovery exit point */
+	__u32 fast_recovery_exit;
+
 	/* Destination */
 	struct dst_entry *dst;
 	/* Source address. */
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index f4938f6..3759027 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -79,6 +79,7 @@ static struct sctp_transport *sctp_transport_init(struct sctp_transport *peer,
 	peer->rttvar = 0;
 	peer->srtt = 0;
 	peer->rto_pending = 0;
+	peer->fast_recovery = 0;
 
 	peer->last_time_heard = jiffies;
 	peer->last_time_used = jiffies;
@@ -403,11 +404,16 @@ void sctp_transport_raise_cwnd(struct sctp_transport *transport,
 	cwnd = transport->cwnd;
 	flight_size = transport->flight_size;
 
+	/* See if we need to exit Fast Recovery first */
+	if (transport->fast_recovery &&
+	    TSN_lte(transport->fast_recovery_exit, sack_ctsn))
+		transport->fast_recovery = 0;
+
 	/* The appropriate cwnd increase algorithm is performed if, and only
-	 * if the cumulative TSN has advanced and the congestion window is
+	 * if the cumulative TSN whould advanced and the congestion window is
 	 * being fully utilized.
 	 */
-	if ((transport->asoc->ctsn_ack_point >= sack_ctsn) ||
+	if (TSN_lte(sack_ctsn, transport->asoc->ctsn_ack_point) ||
 	    (flight_size < cwnd))
 		return;
 
@@ -416,17 +422,23 @@ void sctp_transport_raise_cwnd(struct sctp_transport *transport,
 	pmtu = transport->asoc->pathmtu;
 
 	if (cwnd <= ssthresh) {
-		/* RFC 2960 7.2.1, sctpimpguide-05 2.14.2 When cwnd is less
-		 * than or equal to ssthresh an SCTP endpoint MUST use the
-		 * slow start algorithm to increase cwnd only if the current
-		 * congestion window is being fully utilized and an incoming
-		 * SACK advances the Cumulative TSN Ack Point. Only when these
-		 * two conditions are met can the cwnd be increased otherwise
-		 * the cwnd MUST not be increased. If these conditions are met
-		 * then cwnd MUST be increased by at most the lesser of
-		 * 1) the total size of the previously outstanding DATA
-		 * chunk(s) acknowledged, and 2) the destination's path MTU.
+		/* RFC 4960 7.2.1
+		 * o  When cwnd is less than or equal to ssthresh, an SCTP
+		 *    endpoint MUST use the slow-start algorithm to increase
+		 *    cwnd only if the current congestion window is being fully
+		 *    utilized, an incoming SACK advances the Cumulative TSN
+		 *    Ack Point, and the data sender is not in Fast Recovery.
+		 *    Only when these three conditions are met can the cwnd be
+		 *    increased; otherwise, the cwnd MUST not be increased.
+		 *    If these conditions are met, then cwnd MUST be increased
+		 *    by, at most, the lesser of 1) the total size of the
+		 *    previously outstanding DATA chunk(s) acknowledged, and
+		 *    2) the destination's path MTU.  This upper bound protects
+		 *    against the ACK-Splitting attack outlined in [SAVAGE99].
 		 */
+		if (transport->fast_recovery)
+			return;
+
 		if (bytes_acked > pmtu)
 			cwnd += pmtu;
 		else
@@ -502,6 +514,13 @@ void sctp_transport_lower_cwnd(struct sctp_transport *transport,
 		 *      cwnd = ssthresh
 		 *      partial_bytes_acked = 0
 		 */
+		if (transport->fast_recovery)
+			return;
+
+		/* Mark Fast recovery */
+		transport->fast_recovery = 1;
+		transport->fast_recovery_exit = transport->asoc->next_tsn - 1;
+
 		transport->ssthresh = max(transport->cwnd/2,
 					  4*transport->asoc->pathmtu);
 		transport->cwnd = transport->ssthresh;
@@ -586,6 +605,7 @@ void sctp_transport_reset(struct sctp_transport *t)
 	t->flight_size = 0;
 	t->error_count = 0;
 	t->rto_pending = 0;
+	t->fast_recovery = 0;
 
 	/* Initialize the state information for SFR-CACC */
 	t->cacc.changeover_active = 0;
-- 
1.5.3.5

