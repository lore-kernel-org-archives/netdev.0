From: David Laight <David.Laight@ACULAB.COM>
Subject: [PATCH net-next v3 1/3] Open out the check for Nagle
Date: Fri, 18 Jul 2014 17:36:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17278F4D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: 'David Miller' <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40034 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S966017AbaGRRha convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2014 13:37:30 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 13371-04 for <netdev@vger.kernel.org>;
 Fri, 18 Jul 2014 18:37:21 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The check for Nagle contains 6 separate checks all of which must be true
before a data packet is delayed.
Separate out each into its own 'if (test) return SCTP_XMIT_OK' so that
the reasons can be individually described.

Also return directly with SCTP_XMIT_RWND_FULL.
Delete the now-unused 'retval' variable and 'finish' label from
sctp_packet_can_append_data().

Signed-off-by: David Laight <david.laight@aculab.com>
---

Changes from v2:
- Fix inverted test for 'inflight == 0'

 net/sctp/output.c | 69 +++++++++++++++++++++++++++++--------------------------
 1 file changed, 36 insertions(+), 33 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 0f4d15f..553ba1d 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -633,7 +633,6 @@ nomem:
 static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
 					   struct sctp_chunk *chunk)
 {
-	sctp_xmit_t retval = SCTP_XMIT_OK;
 	size_t datasize, rwnd, inflight, flight_size;
 	struct sctp_transport *transport = packet->transport;
 	struct sctp_association *asoc = transport->asoc;
@@ -658,15 +657,11 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
 
 	datasize = sctp_data_size(chunk);
 
-	if (datasize > rwnd) {
-		if (inflight > 0) {
-			/* We have (at least) one data chunk in flight,
-			 * so we can't fall back to rule 6.1 B).
-			 */
-			retval = SCTP_XMIT_RWND_FULL;
-			goto finish;
-		}
-	}
+	if (datasize > rwnd && inflight > 0)
+		/* We have (at least) one data chunk in flight,
+		 * so we can't fall back to rule 6.1 B).
+		 */
+		return SCTP_XMIT_RWND_FULL;
 
 	/* RFC 2960 6.1  Transmission of DATA Chunks
 	 *
@@ -680,36 +675,44 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
 	 *    When a Fast Retransmit is being performed the sender SHOULD
 	 *    ignore the value of cwnd and SHOULD NOT delay retransmission.
 	 */
-	if (chunk->fast_retransmit != SCTP_NEED_FRTX)
-		if (flight_size >= transport->cwnd) {
-			retval = SCTP_XMIT_RWND_FULL;
-			goto finish;
-		}
+	if (chunk->fast_retransmit != SCTP_NEED_FRTX &&
+	    flight_size >= transport->cwnd)
+		return SCTP_XMIT_RWND_FULL;
 
 	/* Nagle's algorithm to solve small-packet problem:
 	 * Inhibit the sending of new chunks when new outgoing data arrives
 	 * if any previously transmitted data on the connection remains
 	 * unacknowledged.
 	 */
-	if (!sctp_sk(asoc->base.sk)->nodelay && sctp_packet_empty(packet) &&
-	    inflight && sctp_state(asoc, ESTABLISHED)) {
-		unsigned int max = transport->pathmtu - packet->overhead;
-		unsigned int len = chunk->skb->len + q->out_qlen;
-
-		/* Check whether this chunk and all the rest of pending
-		 * data will fit or delay in hopes of bundling a full
-		 * sized packet.
-		 * Don't delay large message writes that may have been
-		 * fragmeneted into small peices.
-		 */
-		if ((len < max) && chunk->msg->can_delay) {
-			retval = SCTP_XMIT_NAGLE_DELAY;
-			goto finish;
-		}
-	}
 
-finish:
-	return retval;
+	if (sctp_sk(asoc->base.sk)->nodelay)
+		/* Nagle disabled */
+		return SCTP_XMIT_OK;
+
+	if (!sctp_packet_empty(packet))
+		/* Append to packet */
+		return SCTP_XMIT_OK;
+
+	if (inflight == 0)
+		/* Nothing unacked */
+		return SCTP_XMIT_OK;
+	
+	if (!sctp_state(asoc, ESTABLISHED))
+		return SCTP_XMIT_OK;
+
+	/* Check whether this chunk and all the rest of pending data will fit
+	 * or delay in hopes of bundling a full sized packet.
+	 */
+	if (chunk->skb->len + q->out_qlen >= transport->pathmtu - packet->overhead)
+		/* Enough data queued to fill a packet */
+		return SCTP_XMIT_OK;
+
+	/* Don't delay large message writes that may have been fragmented */
+	if (!chunk->msg->can_delay)
+		return SCTP_XMIT_OK;
+
+	/* Defer until all data acked or packet full */
+	return SCTP_XMIT_NAGLE_DELAY;
 }
 
 /* This private function does management things when adding DATA chunk */
-- 
1.8.1.2
