From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next 3/4] sctp: adjust cwnd increase in Congestion Avoidance phase
Date: Fri, 23 Jun 2017 19:59:35 -0300
Message-ID: <bdfc1166a147438676c789fd2578a0b319cffc90.1498251459.git.marcelo.leitner@gmail.com>
References: <cover.1498251459.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36291 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754550AbdFWW75 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 18:59:57 -0400
In-Reply-To: <cover.1498251459.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC4960 Errata 3.26 identified that at the same time RFC4960 states that
cwnd should never grow more than 1*MTU per RTT, Section 7.2.2 was
underspecified and as described could allow increasing cwnd more than
that.

This patch updates it so partial_bytes_acked is maxed to cwnd if
flight_size doesn't reach cwnd, protecting it from such case.

See-also: https://tools.ietf.org/html/draft-ietf-tsvwg-rfc4960-errata-01#section-3.26
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/transport.c | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 9d3589451a967a31ee241a5138a58f2f81a2f2a1..e3ebf04ddbd092a1ba04962c8fbe85a58588771a 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -405,13 +405,6 @@ void sctp_transport_raise_cwnd(struct sctp_transport *transport,
 	    TSN_lte(asoc->fast_recovery_exit, sack_ctsn))
 		asoc->fast_recovery = 0;
 
-	/* The appropriate cwnd increase algorithm is performed if, and only
-	 * if the congestion window is being fully utilized.
-	 * Note that RFC4960 Errata 3.22 removed the other condition.
-	 */
-	if (flight_size < cwnd)
-		return;
-
 	ssthresh = transport->ssthresh;
 	pba = transport->partial_bytes_acked;
 	pmtu = transport->asoc->pathmtu;
@@ -434,6 +427,14 @@ void sctp_transport_raise_cwnd(struct sctp_transport *transport,
 		if (asoc->fast_recovery)
 			return;
 
+		/* The appropriate cwnd increase algorithm is performed
+		 * if, and only if the congestion window is being fully
+		 * utilized.  Note that RFC4960 Errata 3.22 removed the
+		 * other condition on ctsn moving.
+		 */
+		if (flight_size < cwnd)
+			return;
+
 		if (bytes_acked > pmtu)
 			cwnd += pmtu;
 		else
@@ -451,6 +452,13 @@ void sctp_transport_raise_cwnd(struct sctp_transport *transport,
 		 * acknowledged by the new Cumulative TSN Ack and by Gap
 		 * Ack Blocks. (updated by RFC4960 Errata 3.22)
 		 *
+		 * When partial_bytes_acked is greater than cwnd and
+		 * before the arrival of the SACK the sender had less
+		 * bytes of data outstanding than cwnd (i.e., before
+		 * arrival of the SACK, flightsize was less than cwnd),
+		 * reset partial_bytes_acked to cwnd. (RFC 4960 Errata
+		 * 3.26)
+		 *
 		 * When partial_bytes_acked is equal to or greater than
 		 * cwnd and before the arrival of the SACK the sender
 		 * had cwnd or more bytes of data outstanding (i.e.,
@@ -460,7 +468,9 @@ void sctp_transport_raise_cwnd(struct sctp_transport *transport,
 		 * increased by MTU. (RFC 4960 Errata 3.12)
 		 */
 		pba += bytes_acked;
-		if (pba >= cwnd) {
+		if (pba > cwnd && flight_size < cwnd)
+			pba = cwnd;
+		if (pba >= cwnd && flight_size >= cwnd) {
 			pba = pba - cwnd;
 			cwnd += pmtu;
 		}
-- 
2.9.4
