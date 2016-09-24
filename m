From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 7/8] rxrpc: Schedule an ACK if the reply to a
 client call appears overdue
Date: Sun, 25 Sep 2016 00:25:44 +0100
Message-ID: <147475954473.15231.5330364029304752744.stgit@warthog.procyon.org.uk>
References: <147475949656.15231.3434038490632820605.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147475949656.15231.3434038490632820605.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If we've sent all the request data in a client call but haven't seen any
sign of the reply data yet, schedule an ACK to be sent to the server to
find out if the reply data got lost.

If the server hasn't yet hard-ACK'd the request data, we send a PING ACK to
demand a response to find out whether we need to retransmit.

If the server says it has received all of the data, we send an IDLE ACK to
tell the server that we haven't received anything in the receive phase as
yet.

To make this work, a non-immediate PING ACK must carry a delay.  I've chosen
the same as the IDLE ACK for the moment.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    2 ++
 net/rxrpc/call_event.c  |    1 +
 net/rxrpc/input.c       |    8 ++++++++
 net/rxrpc/misc.c        |    2 ++
 4 files changed, 13 insertions(+)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 1a700b6a998b..b1e697fc9ffb 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -707,7 +707,9 @@ enum rxrpc_timer_trace {
 extern const char rxrpc_timer_traces[rxrpc_timer__nr_trace][8];
 
 enum rxrpc_propose_ack_trace {
+	rxrpc_propose_ack_client_tx_end,
 	rxrpc_propose_ack_input_data,
+	rxrpc_propose_ack_ping_for_lost_reply,
 	rxrpc_propose_ack_ping_for_params,
 	rxrpc_propose_ack_respond_to_ack,
 	rxrpc_propose_ack_respond_to_ping,
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index d5bf9ce7ec6f..05b94d1acf52 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -100,6 +100,7 @@ static void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 			expiry = rxrpc_soft_ack_delay;
 		break;
 
+	case RXRPC_ACK_PING:
 	case RXRPC_ACK_IDLE:
 		if (rxrpc_idle_ack_delay < expiry)
 			expiry = rxrpc_idle_ack_delay;
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index dd699667eeef..0344f4494eb7 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -138,6 +138,8 @@ static bool rxrpc_end_tx_phase(struct rxrpc_call *call, bool reply_begun,
 
 	write_unlock(&call->state_lock);
 	if (call->state == RXRPC_CALL_CLIENT_AWAIT_REPLY) {
+		rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, 0, 0, false, true,
+				  rxrpc_propose_ack_client_tx_end);
 		trace_rxrpc_transmit(call, rxrpc_transmit_await_reply);
 	} else {
 		trace_rxrpc_transmit(call, rxrpc_transmit_end);
@@ -684,6 +686,12 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 		return;
 	}
 
+	if (call->rxtx_annotations[call->tx_top & RXRPC_RXTX_BUFF_MASK] &
+	    RXRPC_TX_ANNO_LAST &&
+	    summary.nr_acks == call->tx_top - hard_ack)
+		rxrpc_propose_ACK(call, RXRPC_ACK_PING, skew, sp->hdr.serial,
+				  false, true,
+				  rxrpc_propose_ack_ping_for_lost_reply);
 }
 
 /*
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index 901c012a2700..a608769343e6 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -198,7 +198,9 @@ const char rxrpc_timer_traces[rxrpc_timer__nr_trace][8] = {
 };
 
 const char rxrpc_propose_ack_traces[rxrpc_propose_ack__nr_trace][8] = {
+	[rxrpc_propose_ack_client_tx_end]	= "ClTxEnd",
 	[rxrpc_propose_ack_input_data]		= "DataIn ",
+	[rxrpc_propose_ack_ping_for_lost_reply]	= "LostRpl",
 	[rxrpc_propose_ack_ping_for_params]	= "Params ",
 	[rxrpc_propose_ack_respond_to_ack]	= "Rsp2Ack",
 	[rxrpc_propose_ack_respond_to_ping]	= "Rsp2Png",
