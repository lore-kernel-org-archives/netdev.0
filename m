From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 2/4] [SCTP]: Include sk_buff overhead while updating the
	peer's receive window.
Date: Fri, 29 Sep 2006 13:00:20 -0700
Message-ID: <1159560020.29637.50.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:8603 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1422690AbWI2UAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 16:00:23 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8TK0Mb6027043
	for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 16:00:22 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8TK0MhM229340
	for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 16:00:22 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8TK0LGl032179
	for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 16:00:22 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Include sk_buff overhead while updating the peer's receive window.

Currently if the sender is sending small messages, it can cause a receiver
to run out of receive buffer space even when the advertised receive window
is still open and results in packet drops and retransmissions. Including
a overhead while updating the sender's view of peer receive window will
reduce the chances of receive buffer space overshooting the receive window.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/output.c   |   10 ++++++++--
 net/sctp/outqueue.c |    3 ++-
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index cdc5a39..9825b11 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -633,7 +633,7 @@ static sctp_xmit_t sctp_packet_append_da
 		 * data will fit or delay in hopes of bundling a full
 		 * sized packet.
 		 */
-		if (len < asoc->pathmtu - packet->overhead) {
+		if (len < asoc->frag_point) {
 			retval = SCTP_XMIT_NAGLE_DELAY;
 			goto finish;
 		}
@@ -645,7 +645,13 @@ static sctp_xmit_t sctp_packet_append_da
 	/* Keep track of how many bytes are in flight to the receiver. */
 	asoc->outqueue.outstanding_bytes += datasize;
 
-	/* Update our view of the receiver's rwnd. */
+	/* Update our view of the receiver's rwnd. Include sk_buff overhead
+	 * while updating peer.rwnd so that it reduces the chances of a
+	 * receiver running out of receive buffer space even when receive
+	 * window is still open. This can happen when a sender is sending
+	 * sending small messages.
+	 */
+	datasize += sizeof(struct sk_buff);
 	if (datasize < rwnd)
 		rwnd -= datasize;
 	else
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 37074a3..7395824 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -416,7 +416,8 @@ void sctp_retransmit_mark(struct sctp_ou
 			 * (Section 7.2.4)), add the data size of those
 			 * chunks to the rwnd.
 			 */
-			q->asoc->peer.rwnd += sctp_data_size(chunk);
+			q->asoc->peer.rwnd += (sctp_data_size(chunk) +
+						sizeof(struct sk_buff));
 			q->outstanding_bytes -= sctp_data_size(chunk);
 			transport->flight_size -= sctp_data_size(chunk);
 


