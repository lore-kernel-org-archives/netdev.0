From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 4/6] sctp: save transmit error to sk_err in sctp_outq_flush
Date: Thu,  8 Sep 2016 17:43:10 +0800
Message-ID: <d74ba73ed567914c048532d25df2f54a865a41f4.1473327790.git.lucien.xin@gmail.com>
References: <cover.1473326067.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33014 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932342AbcIHJnR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 05:43:17 -0400
In-Reply-To: <cover.1473326067.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Every time when sctp calls sctp_outq_flush, it sends out the chunks of
control queue, retransmit queue and data queue. Even if some trunks are
failed to transmit, it still has to flush all the transports, as it's
the only chance to clean that transmit_list.

So the latest transmit error here should be returned back. This transmit
error is an internal error of sctp stack.

I checked all the places where it uses the transmit error (the return
value of sctp_outq_flush), most of them are actually just save it to
sk_err.

Except for sctp_assoc/endpoint_bh_rcv, they will drop the chunk if
it's failed to send a REPLY, which is actually incorrect, as we can't
be sure the error that sctp_outq_flush returns is from sending that
REPLY.

So it's meaningless for sctp_outq_flush to return error back.

This patch is to save transmit error to sk_err in sctp_outq_flush, the
new error can update the old value. Eventually, sctp_wait_for_* would
check for it.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/output.c   |  3 ++-
 net/sctp/outqueue.c | 21 ++++++++++++---------
 2 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 1f1682b..1934933 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -180,7 +180,6 @@ sctp_xmit_t sctp_packet_transmit_chunk(struct sctp_packet *packet,
 				       int one_packet, gfp_t gfp)
 {
 	sctp_xmit_t retval;
-	int error = 0;
 
 	pr_debug("%s: packet:%p size:%Zu chunk:%p size:%d\n", __func__,
 		 packet, packet->size, chunk, chunk->skb ? chunk->skb->len : -1);
@@ -188,6 +187,8 @@ sctp_xmit_t sctp_packet_transmit_chunk(struct sctp_packet *packet,
 	switch ((retval = (sctp_packet_append_chunk(packet, chunk)))) {
 	case SCTP_XMIT_PMTU_FULL:
 		if (!packet->has_cookie_echo) {
+			int error = 0;
+
 			error = sctp_packet_transmit(packet, gfp);
 			if (error < 0)
 				chunk->skb->sk->sk_err = -error;
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index da2418b..0c6210d 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -534,7 +534,6 @@ void sctp_retransmit(struct sctp_outq *q, struct sctp_transport *transport,
 		     sctp_retransmit_reason_t reason)
 {
 	struct net *net = sock_net(q->asoc->base.sk);
-	int error = 0;
 
 	switch (reason) {
 	case SCTP_RTXR_T3_RTX:
@@ -578,10 +577,7 @@ void sctp_retransmit(struct sctp_outq *q, struct sctp_transport *transport,
 	 * will be flushed at the end.
 	 */
 	if (reason != SCTP_RTXR_FAST_RTX)
-		error = sctp_outq_flush(q, /* rtx_timeout */ 1, GFP_ATOMIC);
-
-	if (error)
-		q->asoc->base.sk->sk_err = -error;
+		sctp_outq_flush(q, /* rtx_timeout */ 1, GFP_ATOMIC);
 }
 
 /*
@@ -894,8 +890,10 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 			sctp_packet_config(&singleton, vtag, 0);
 			sctp_packet_append_chunk(&singleton, chunk);
 			error = sctp_packet_transmit(&singleton, gfp);
-			if (error < 0)
-				return error;
+			if (error < 0) {
+				asoc->base.sk->sk_err = -error;
+				return 0;
+			}
 			break;
 
 		case SCTP_CID_ABORT:
@@ -993,6 +991,8 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 		retran:
 			error = sctp_outq_flush_rtx(q, packet,
 						    rtx_timeout, &start_timer);
+			if (error < 0)
+				asoc->base.sk->sk_err = -error;
 
 			if (start_timer) {
 				sctp_transport_reset_t3_rtx(transport);
@@ -1167,14 +1167,17 @@ sctp_flush_out:
 						      struct sctp_transport,
 						      send_ready);
 		packet = &t->packet;
-		if (!sctp_packet_empty(packet))
+		if (!sctp_packet_empty(packet)) {
 			error = sctp_packet_transmit(packet, gfp);
+			if (error < 0)
+				asoc->base.sk->sk_err = -error;
+		}
 
 		/* Clear the burst limited state, if any */
 		sctp_transport_burst_reset(t);
 	}
 
-	return error;
+	return 0;
 }
 
 /* Update unack_data based on the incoming SACK chunk */
-- 
2.1.0
