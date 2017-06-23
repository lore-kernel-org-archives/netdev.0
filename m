From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next 2/4] sctp: allow increasing cwnd regardless of ctsn moving or not
Date: Fri, 23 Jun 2017 19:59:34 -0300
Message-ID: <118ad6dd7f3f46e97be5de095b6ed540d7b44ea7.1498251459.git.marcelo.leitner@gmail.com>
References: <cover.1498251459.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36278 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754545AbdFWW7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 18:59:54 -0400
In-Reply-To: <cover.1498251459.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As per RFC4960 Errata 3.22, this condition is not needed anymore as it
could cause the partial_bytes_acked to not consider the TSNs acked in
the Gap Ack Blocks although they were received by the peer successfully.

This patch thus drops the check for new Cumulative TSN Ack Point,
leaving just the flight_size < cwnd one.

See-also: https://tools.ietf.org/html/draft-ietf-tsvwg-rfc4960-errata-01#section-3.22
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/transport.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 04b6dd1a07ded25fe5874518b0944a6d9df4099b..9d3589451a967a31ee241a5138a58f2f81a2f2a1 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -406,11 +406,10 @@ void sctp_transport_raise_cwnd(struct sctp_transport *transport,
 		asoc->fast_recovery = 0;
 
 	/* The appropriate cwnd increase algorithm is performed if, and only
-	 * if the cumulative TSN whould advanced and the congestion window is
-	 * being fully utilized.
+	 * if the congestion window is being fully utilized.
+	 * Note that RFC4960 Errata 3.22 removed the other condition.
 	 */
-	if (TSN_lte(sack_ctsn, transport->asoc->ctsn_ack_point) ||
-	    (flight_size < cwnd))
+	if (flight_size < cwnd)
 		return;
 
 	ssthresh = transport->ssthresh;
@@ -446,11 +445,11 @@ void sctp_transport_raise_cwnd(struct sctp_transport *transport,
 			 flight_size, pba);
 	} else {
 		/* RFC 2960 7.2.2 Whenever cwnd is greater than ssthresh,
-		 * upon each SACK arrival that advances the Cumulative TSN Ack
-		 * Point, increase partial_bytes_acked by the total number of
-		 * bytes of all new chunks acknowledged in that SACK including
-		 * chunks acknowledged by the new Cumulative TSN Ack and by
-		 * Gap Ack Blocks.
+		 * upon each SACK arrival, increase partial_bytes_acked
+		 * by the total number of bytes of all new chunks
+		 * acknowledged in that SACK including chunks
+		 * acknowledged by the new Cumulative TSN Ack and by Gap
+		 * Ack Blocks. (updated by RFC4960 Errata 3.22)
 		 *
 		 * When partial_bytes_acked is equal to or greater than
 		 * cwnd and before the arrival of the SACK the sender
-- 
2.9.4
