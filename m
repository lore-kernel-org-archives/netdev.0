From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 6/6] rxrpc: Note serial number being ACK'd in the
 congestion management trace
Date: Thu, 29 Sep 2016 23:16:09 +0100
Message-ID: <147518736931.29235.14617168752414952894.stgit@warthog.procyon.org.uk>
References: <147518732742.29235.11597637573731081178.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41492 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934976AbcI2WQL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Sep 2016 18:16:11 -0400
In-Reply-To: <147518732742.29235.11597637573731081178.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note the serial number of the packet being ACK'd in the congestion
management trace rather than the serial number of the ACK packet.  Whilst
the serial number of the ACK packet is useful for matching ACK packet in
the output of wireshark, the serial number that the ACK is in response to
is of more use in working out how different trace lines relate.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 094720dd1eaf..1461d30583c9 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -41,10 +41,10 @@ static void rxrpc_proto_abort(const char *why,
  */
 static void rxrpc_congestion_management(struct rxrpc_call *call,
 					struct sk_buff *skb,
-					struct rxrpc_ack_summary *summary)
+					struct rxrpc_ack_summary *summary,
+					rxrpc_serial_t acked_serial)
 {
 	enum rxrpc_congest_change change = rxrpc_cong_no_change;
-	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	unsigned int cumulative_acks = call->cong_cumul_acks;
 	unsigned int cwnd = call->cong_cwnd;
 	bool resend = false;
@@ -172,7 +172,7 @@ out_no_clear_ca:
 		cwnd = RXRPC_RXTX_BUFF_SIZE - 1;
 	call->cong_cwnd = cwnd;
 	call->cong_cumul_acks = cumulative_acks;
-	trace_rxrpc_congest(call, summary, sp->hdr.serial, change);
+	trace_rxrpc_congest(call, summary, acked_serial, change);
 	if (resend && !test_and_set_bit(RXRPC_CALL_EV_RESEND, &call->events))
 		rxrpc_queue_call(call);
 	return;
@@ -848,7 +848,7 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 				  false, true,
 				  rxrpc_propose_ack_ping_for_lost_reply);
 
-	return rxrpc_congestion_management(call, skb, &summary);
+	return rxrpc_congestion_management(call, skb, &summary, acked_serial);
 }
 
 /*
