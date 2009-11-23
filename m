From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] sctp: on T3_RTX retransmit all the in-flight chunks
Date: Mon, 23 Nov 2009 14:33:53 -0500
Message-ID: <1259004833-23267-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org,
	Andrei Pelinescu-Onciul <andrei@iptel.org>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:9816 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754333AbZKWTdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 14:33:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Pelinescu-Onciul <andrei@iptel.org>

When retransmitting due to T3 timeout, retransmit all the
in-flight chunks for the corresponding  transport/path, including
chunks sent less then 1 rto ago.
This is the correct behaviour according to rfc4960 section 6.3.3
E3 and
"Note: Any DATA chunks that were sent to the address for which the
 T3-rtx timer expired but did not fit in one MTU (rule E3 above)
 should be marked for retransmission and sent as soon as cwnd
 allows (normally, when a SACK arrives). ".

This fixes problems when more then one path is present and the T3
retransmission of the first chunk that timeouts stops the T3 timer
for the initial active path, leaving all the other in-flight
chunks waiting forever or until a new chunk is transmitted on the
same path and timeouts (and this will happen only if the cwnd
allows sending new chunks, but since cwnd was dropped to MTU by
the timeout => it will wait until the first heartbeat).

Example: 10 packets in flight, sent at 0.1 s intervals on the
primary path. The primary path is down and the first packet
timeouts. The first packet is retransmitted on another path, the
T3 timer for the primary path is stopped and cwnd is set to MTU.
All the other 9 in-flight packets will not be retransmitted
(unless more new packets are sent on the primary path which depend
on cwnd allowing it, and even in this case the 9 packets will be
retransmitted only after a new packet timeouts which even in the
best case would be more then RTO).

This commit reverts d0ce92910bc04e107b2f3f2048f07e94f570035d and
also removes the now unused transport->last_rto, introduced in
 b6157d8e03e1e780660a328f7183bcbfa4a93a19.

p.s  The problem is not only when multiple paths are there.  It
can happen in a single homed environment.  If the application
stops sending data, it possible to have a hung association.

Signed-off-by: Andrei Pelinescu-Onciul <andrei@iptel.org>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    1 -
 net/sctp/outqueue.c        |   10 ----------
 net/sctp/sm_sideeffect.c   |    1 -
 net/sctp/transport.c       |    5 ++---
 4 files changed, 2 insertions(+), 15 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index cd2e187..0a47456 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -893,7 +893,6 @@ struct sctp_transport {
 	 */
 	/* RTO	       : The current retransmission timeout value.  */
 	unsigned long rto;
-	unsigned long last_rto;
 
 	__u32 rtt;		/* This is the most recent RTT.	 */
 
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index c9f20e2..23e5e97 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -423,16 +423,6 @@ void sctp_retransmit_mark(struct sctp_outq *q,
 		if ((reason == SCTP_RTXR_FAST_RTX  &&
 			    (chunk->fast_retransmit == SCTP_NEED_FRTX)) ||
 		    (reason != SCTP_RTXR_FAST_RTX  && !chunk->tsn_gap_acked)) {
-			/* If this chunk was sent less then 1 rto ago, do not
-			 * retransmit this chunk, but give the peer time
-			 * to acknowlege it.  Do this only when
-			 * retransmitting due to T3 timeout.
-			 */
-			if (reason == SCTP_RTXR_T3_RTX &&
-			    time_before(jiffies, chunk->sent_at +
-						 transport->last_rto))
-				continue;
-
 			/* RFC 2960 6.2.1 Processing a Received SACK
 			 *
 			 * C) Any time a DATA chunk is marked for
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 8674d49..efa516b 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -480,7 +480,6 @@ static void sctp_do_8_2_transport_strike(struct sctp_association *asoc,
 	 * that indicates that we have an outstanding HB.
 	 */
 	if (!is_hb || transport->hb_sent) {
-		transport->last_rto = transport->rto;
 		transport->rto = min((transport->rto * 2), transport->asoc->rto_max);
 	}
 }
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 3b141bb..37a1184 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -74,7 +74,7 @@ static struct sctp_transport *sctp_transport_init(struct sctp_transport *peer,
 	 * given destination transport address, set RTO to the protocol
 	 * parameter 'RTO.Initial'.
 	 */
-	peer->last_rto = peer->rto = msecs_to_jiffies(sctp_rto_initial);
+	peer->rto = msecs_to_jiffies(sctp_rto_initial);
 	peer->rtt = 0;
 	peer->rttvar = 0;
 	peer->srtt = 0;
@@ -386,7 +386,6 @@ void sctp_transport_update_rto(struct sctp_transport *tp, __u32 rtt)
 		tp->rto = tp->asoc->rto_max;
 
 	tp->rtt = rtt;
-	tp->last_rto = tp->rto;
 
 	/* Reset rto_pending so that a new RTT measurement is started when a
 	 * new data chunk is sent.
@@ -602,7 +601,7 @@ void sctp_transport_reset(struct sctp_transport *t)
 	 */
 	t->cwnd = min(4*asoc->pathmtu, max_t(__u32, 2*asoc->pathmtu, 4380));
 	t->ssthresh = asoc->peer.i.a_rwnd;
-	t->last_rto = t->rto = asoc->rto_initial;
+	t->rto = asoc->rto_initial;
 	t->rtt = 0;
 	t->srtt = 0;
 	t->rttvar = 0;
-- 
1.6.0.4

