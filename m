From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: start t5 timer only when peer rwnd is 0 and local state is SHUTDOWN_PENDING
Date: Sat,  5 Dec 2015 15:35:36 +0800
Message-ID: <dfbfa2ef370b0f8962933e7f9400f9588cdb2281.1449300936.git.lucien.xin@gmail.com>
Cc: marcelo.leitner@gmail.com, vyasevic@redhat.com, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33699 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbbLEHfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 02:35:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when A sends a data to B, then A close() and enter into SHUTDOWN_PENDING
state, if B neither claim his rwnd is 0 nor send SACK for this data, A
will keep retransmitting this data until t5 timeout, Max.Retrans times
can't work anymore, which is bad.

if B's rwnd is not 0, it should send abort after Max.Retrans times, only
when B's rwnd == 0 and A's retransmitting beyonds Max.Retrans times, A
will start t5 timer, which is also commit f8d960524328 ("sctp: Enforce
retransmission limit during shutdown") means, but it lacks the condition
peer rwnd == 0.

so fix it by adding a bit (zero_window_announced) in peer to record if
the last rwnd is 0. If it was, zero_window_announced will be set. and use
this bit to decide if start t5 timer when local.state is SHUTDOWN_PENDING.

Fixes: commit f8d960524328 ("sctp: Enforce retransmission limit during shutdown")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/structs.h | 3 ++-
 net/sctp/outqueue.c        | 1 +
 net/sctp/sm_statefuns.c    | 3 ++-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 7bbb710..eea9bde 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1493,7 +1493,8 @@ struct sctp_association {
 		 *             : SACK's are not delayed (see Section 6).
 		 */
 		__u8    sack_needed:1,     /* Do we need to sack the peer? */
-			sack_generation:1;
+			sack_generation:1,
+			zero_window_announced:1;
 		__u32	sack_cnt;
 
 		__u32   adaptation_ind;	 /* Adaptation Code point. */
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 7e8f0a1..8d88823 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -1251,6 +1251,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_chunk *chunk)
 	 */
 
 	sack_a_rwnd = ntohl(sack->a_rwnd);
+	asoc->peer.zero_window_announced = !sack_a_rwnd;
 	outstanding = q->outstanding_bytes;
 
 	if (outstanding < sack_a_rwnd)
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 6f46aa1..cd34a4a 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -5412,7 +5412,8 @@ sctp_disposition_t sctp_sf_do_6_3_3_rtx(struct net *net,
 	SCTP_INC_STATS(net, SCTP_MIB_T3_RTX_EXPIREDS);
 
 	if (asoc->overall_error_count >= asoc->max_retrans) {
-		if (asoc->state == SCTP_STATE_SHUTDOWN_PENDING) {
+		if (asoc->peer.zero_window_announced &&
+		    asoc->state == SCTP_STATE_SHUTDOWN_PENDING) {
 			/*
 			 * We are here likely because the receiver had its rwnd
 			 * closed for a while and we have not been able to
-- 
2.1.0
