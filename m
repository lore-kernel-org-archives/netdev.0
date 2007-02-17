From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 4/5][SCTP]: Fix connection hang/slowdown with PR-SCTP
Date: Fri, 16 Feb 2007 19:39:58 -0800
Message-ID: <1171683598.4568.13.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:48715 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946397AbXBQDkB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 22:40:01 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1H3dxCo010745
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 22:39:59 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1H3dxpq303676
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 22:39:59 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1H3dxb6026297
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 22:39:59 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Fix connection hang/slowdown with PR-SCTP

The problem that this patch corrects happens when all of the following
conditions are satisfisfied:
 1.  PR-SCTP is used and the timeout on the chunks is set below RTO.Max.
 2.  One of the paths on a multihomed associations is brought down.

In this scenario, data will expire within the rto of the initial
transmission and will never be retransmitted.  However this data still
fills the send buffer and is counted against the association as outstanding
data.  This causes any new data not to be sent and retransmission to not
happen.

The fix is to discount the abandoned data from the outstanding count and
peers rwnd estimation.  This allows new data to be sent and a retransmission
timer restarted.  Even though this new data will most likely expire within
the rto, the timer still counts as a strike against the transport and forces
the FORWARD-TSN chunk to be retransmitted as well.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/outqueue.c |   27 ++++++++++++++++++++++-----
 1 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 5c2ddd1..41abfd1 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -396,6 +396,19 @@ void sctp_retransmit_mark(struct sctp_ou
 		if (sctp_chunk_abandoned(chunk)) {
 			list_del_init(lchunk);
 			sctp_insert_list(&q->abandoned, lchunk);
+
+			/* If this chunk has not been previousely acked,
+			 * stop considering it 'outstanding'.  Our peer
+			 * will most likely never see it since it will
+			 * not be retransmitted
+			 */
+			if (!chunk->tsn_gap_acked) {
+				chunk->transport->flight_size -=
+						sctp_data_size(chunk);
+				q->outstanding_bytes -= sctp_data_size(chunk);
+				q->asoc->peer.rwnd += (sctp_data_size(chunk) +
+							sizeof(struct sk_buff));
+			}
 			continue;
 		}
 
@@ -1244,6 +1257,15 @@ #endif /* SCTP_DEBUG */
 		if (sctp_chunk_abandoned(tchunk)) {
 			/* Move the chunk to abandoned list. */
 			sctp_insert_list(&q->abandoned, lchunk);
+
+			/* If this chunk has not been acked, stop
+			 * considering it as 'outstanding'.
+			 */
+			if (!tchunk->tsn_gap_acked) {
+				tchunk->transport->flight_size -=
+						sctp_data_size(tchunk);
+				q->outstanding_bytes -= sctp_data_size(tchunk);
+			}
 			continue;
 		}
 
@@ -1695,11 +1717,6 @@ static void sctp_generate_fwdtsn(struct 
 		 */
 		if (TSN_lte(tsn, ctsn)) {
 			list_del_init(lchunk);
-			if (!chunk->tsn_gap_acked) {
-				chunk->transport->flight_size -=
-					sctp_data_size(chunk);
-				q->outstanding_bytes -= sctp_data_size(chunk);
-			}
 			sctp_chunk_free(chunk);
 		} else {
 			if (TSN_lte(tsn, asoc->adv_peer_ack_point+1)) {


