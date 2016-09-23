From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 09/15] rxrpc: Pass the last Tx packet marker in the
 annotation buffer
Date: Fri, 23 Sep 2016 16:16:19 +0100
Message-ID: <147464377953.5090.1295001418768244651.stgit@warthog.procyon.org.uk>
References: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the last packet of data to be transmitted on a call is queued, tx_top
is set and then the RXRPC_CALL_TX_LAST flag is set.  Unfortunately, this
leaves a race in the ACK processing side of things because the flag affects
the interpretation of tx_top and also allows us to start receiving reply
data before we've finished transmitting.

To fix this, make the following changes:

 (1) rxrpc_queue_packet() now sets a marker in the annotation buffer
     instead of setting the RXRPC_CALL_TX_LAST flag.

 (2) rxrpc_rotate_tx_window() detects the marker and sets the flag in the
     same context as the routines that use it.

 (3) rxrpc_end_tx_phase() is simplified to just shift the call state.
     The Tx window must have been rotated before calling to discard the
     last packet.

 (4) rxrpc_receiving_reply() is added to handle the arrival of the first
     DATA packet of a reply to a client call (which is an implicit ACK of
     the Tx phase).

 (5) The last part of rxrpc_input_ack() is reordered to perform Tx
     rotation, then soft-ACK application and then to end the phase if we've
     rotated the last packet.  In the event of a terminal ACK, the soft-ACK
     application will be skipped as nAcks should be 0.

 (6) rxrpc_input_ackall() now has to rotate as well as ending the phase.

In addition:

 (7) Alter the transmit tracepoint to log the rotation of the last packet.

 (8) Remove the no-longer relevant queue_reqack tracepoint note.  The
     ACK-REQUESTED packet header flag is now set as needed when we actually
     transmit the packet and may vary by retransmission.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    7 ++-
 net/rxrpc/input.c       |  102 +++++++++++++++++++++++++++++++----------------
 net/rxrpc/misc.c        |    3 +
 net/rxrpc/sendmsg.c     |   14 +++---
 4 files changed, 81 insertions(+), 45 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 9e3ba4dc9578..a494d56eb236 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -508,7 +508,9 @@ struct rxrpc_call {
 #define RXRPC_TX_ANNO_NAK	2
 #define RXRPC_TX_ANNO_RETRANS	3
 #define RXRPC_TX_ANNO_MASK	0x03
-#define RXRPC_TX_ANNO_RESENT	0x04
+#define RXRPC_TX_ANNO_LAST	0x04
+#define RXRPC_TX_ANNO_RESENT	0x08
+
 #define RXRPC_RX_ANNO_JUMBO	0x3f		/* Jumbo subpacket number + 1 if not zero */
 #define RXRPC_RX_ANNO_JLAST	0x40		/* Set if last element of a jumbo packet */
 #define RXRPC_RX_ANNO_VERIFIED	0x80		/* Set if verified and decrypted */
@@ -621,9 +623,10 @@ extern const char rxrpc_call_traces[rxrpc_call__nr_trace][4];
 enum rxrpc_transmit_trace {
 	rxrpc_transmit_wait,
 	rxrpc_transmit_queue,
-	rxrpc_transmit_queue_reqack,
 	rxrpc_transmit_queue_last,
 	rxrpc_transmit_rotate,
+	rxrpc_transmit_rotate_last,
+	rxrpc_transmit_await_reply,
 	rxrpc_transmit_end,
 	rxrpc_transmit__nr_trace
 };
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index d3d69ab1f0a1..fb3e2f6afa3b 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -59,6 +59,7 @@ static void rxrpc_rotate_tx_window(struct rxrpc_call *call, rxrpc_seq_t to)
 {
 	struct sk_buff *skb, *list = NULL;
 	int ix;
+	u8 annotation;
 
 	spin_lock(&call->lock);
 
@@ -66,16 +67,22 @@ static void rxrpc_rotate_tx_window(struct rxrpc_call *call, rxrpc_seq_t to)
 		call->tx_hard_ack++;
 		ix = call->tx_hard_ack & RXRPC_RXTX_BUFF_MASK;
 		skb = call->rxtx_buffer[ix];
+		annotation = call->rxtx_annotations[ix];
 		rxrpc_see_skb(skb, rxrpc_skb_tx_rotated);
 		call->rxtx_buffer[ix] = NULL;
 		call->rxtx_annotations[ix] = 0;
 		skb->next = list;
 		list = skb;
+
+		if (annotation & RXRPC_TX_ANNO_LAST)
+			set_bit(RXRPC_CALL_TX_LAST, &call->flags);
 	}
 
 	spin_unlock(&call->lock);
 
-	trace_rxrpc_transmit(call, rxrpc_transmit_rotate);
+	trace_rxrpc_transmit(call, (test_bit(RXRPC_CALL_TX_LAST, &call->flags) ?
+				    rxrpc_transmit_rotate_last :
+				    rxrpc_transmit_rotate));
 	wake_up(&call->waitq);
 
 	while (list) {
@@ -92,42 +99,65 @@ static void rxrpc_rotate_tx_window(struct rxrpc_call *call, rxrpc_seq_t to)
  * This occurs when we get an ACKALL packet, the first DATA packet of a reply,
  * or a final ACK packet.
  */
-static bool rxrpc_end_tx_phase(struct rxrpc_call *call, const char *abort_why)
+static bool rxrpc_end_tx_phase(struct rxrpc_call *call, bool reply_begun,
+			       const char *abort_why)
 {
-	_enter("");
-
-	switch (call->state) {
-	case RXRPC_CALL_CLIENT_RECV_REPLY:
-		return true;
-	case RXRPC_CALL_CLIENT_AWAIT_REPLY:
-	case RXRPC_CALL_SERVER_AWAIT_ACK:
-		break;
-	default:
-		rxrpc_proto_abort(abort_why, call, call->tx_top);
-		return false;
-	}
 
-	rxrpc_rotate_tx_window(call, call->tx_top);
+	ASSERT(test_bit(RXRPC_CALL_TX_LAST, &call->flags));
 
 	write_lock(&call->state_lock);
 
 	switch (call->state) {
-	default:
-		break;
+	case RXRPC_CALL_CLIENT_SEND_REQUEST:
 	case RXRPC_CALL_CLIENT_AWAIT_REPLY:
-		call->tx_phase = false;
-		call->state = RXRPC_CALL_CLIENT_RECV_REPLY;
+		if (reply_begun)
+			call->state = RXRPC_CALL_CLIENT_RECV_REPLY;
+		else
+			call->state = RXRPC_CALL_CLIENT_AWAIT_REPLY;
 		break;
+
 	case RXRPC_CALL_SERVER_AWAIT_ACK:
 		__rxrpc_call_completed(call);
 		rxrpc_notify_socket(call);
 		break;
+
+	default:
+		goto bad_state;
 	}
 
 	write_unlock(&call->state_lock);
-	trace_rxrpc_transmit(call, rxrpc_transmit_end);
+	if (call->state == RXRPC_CALL_CLIENT_AWAIT_REPLY) {
+		trace_rxrpc_transmit(call, rxrpc_transmit_await_reply);
+	} else {
+		trace_rxrpc_transmit(call, rxrpc_transmit_end);
+	}
 	_leave(" = ok");
 	return true;
+
+bad_state:
+	write_unlock(&call->state_lock);
+	kdebug("end_tx %s", rxrpc_call_states[call->state]);
+	rxrpc_proto_abort(abort_why, call, call->tx_top);
+	return false;
+}
+
+/*
+ * Begin the reply reception phase of a call.
+ */
+static bool rxrpc_receiving_reply(struct rxrpc_call *call)
+{
+	rxrpc_seq_t top = READ_ONCE(call->tx_top);
+
+	if (!test_bit(RXRPC_CALL_TX_LAST, &call->flags))
+		rxrpc_rotate_tx_window(call, top);
+	if (!test_bit(RXRPC_CALL_TX_LAST, &call->flags)) {
+		rxrpc_proto_abort("TXL", call, top);
+		return false;
+	}
+	if (!rxrpc_end_tx_phase(call, true, "ETD"))
+		return false;
+	call->tx_phase = false;
+	return true;
 }
 
 /*
@@ -226,8 +256,9 @@ static void rxrpc_input_data(struct rxrpc_call *call, struct sk_buff *skb,
 	/* Received data implicitly ACKs all of the request packets we sent
 	 * when we're acting as a client.
 	 */
-	if (call->state == RXRPC_CALL_CLIENT_AWAIT_REPLY &&
-	    !rxrpc_end_tx_phase(call, "ETD"))
+	if ((call->state == RXRPC_CALL_CLIENT_SEND_REQUEST ||
+	     call->state == RXRPC_CALL_CLIENT_AWAIT_REPLY) &&
+	    !rxrpc_receiving_reply(call))
 		return;
 
 	call->ackr_prev_seq = seq;
@@ -587,27 +618,26 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 	}
 	call->acks_latest = sp->hdr.serial;
 
-	if (test_bit(RXRPC_CALL_TX_LAST, &call->flags) &&
-	    hard_ack == call->tx_top) {
-		rxrpc_end_tx_phase(call, "ETA");
-		return;
-	}
-
 	if (before(hard_ack, call->tx_hard_ack) ||
 	    after(hard_ack, call->tx_top))
 		return rxrpc_proto_abort("AKW", call, 0);
+	if (nr_acks > call->tx_top - hard_ack)
+		return rxrpc_proto_abort("AKN", call, 0);
 
 	if (after(hard_ack, call->tx_hard_ack))
 		rxrpc_rotate_tx_window(call, hard_ack);
 
-	if (after(first_soft_ack, call->tx_top))
+	if (nr_acks > 0) {
+		if (skb_copy_bits(skb, sp->offset, buf.acks, nr_acks) < 0)
+			return rxrpc_proto_abort("XSA", call, 0);
+		rxrpc_input_soft_acks(call, buf.acks, first_soft_ack, nr_acks);
+	}
+
+	if (test_bit(RXRPC_CALL_TX_LAST, &call->flags)) {
+		rxrpc_end_tx_phase(call, false, "ETA");
 		return;
+	}
 
-	if (nr_acks > call->tx_top - first_soft_ack + 1)
-		nr_acks = first_soft_ack - call->tx_top + 1;
-	if (skb_copy_bits(skb, sp->offset, buf.acks, nr_acks) < 0)
-		return rxrpc_proto_abort("XSA", call, 0);
-	rxrpc_input_soft_acks(call, buf.acks, first_soft_ack, nr_acks);
 }
 
 /*
@@ -619,7 +649,9 @@ static void rxrpc_input_ackall(struct rxrpc_call *call, struct sk_buff *skb)
 
 	_proto("Rx ACKALL %%%u", sp->hdr.serial);
 
-	rxrpc_end_tx_phase(call, "ETL");
+	rxrpc_rotate_tx_window(call, call->tx_top);
+	if (test_bit(RXRPC_CALL_TX_LAST, &call->flags))
+		rxrpc_end_tx_phase(call, false, "ETL");
 }
 
 /*
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index 0d425e707f22..fe648711c2f7 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -155,9 +155,10 @@ const char rxrpc_client_traces[rxrpc_client__nr_trace][7] = {
 const char rxrpc_transmit_traces[rxrpc_transmit__nr_trace][4] = {
 	[rxrpc_transmit_wait]		= "WAI",
 	[rxrpc_transmit_queue]		= "QUE",
-	[rxrpc_transmit_queue_reqack]	= "QRA",
 	[rxrpc_transmit_queue_last]	= "QLS",
 	[rxrpc_transmit_rotate]		= "ROT",
+	[rxrpc_transmit_rotate_last]	= "RLS",
+	[rxrpc_transmit_await_reply]	= "AWR",
 	[rxrpc_transmit_end]		= "END",
 };
 
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 7cb34b2dfba9..93e6584cd751 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -94,11 +94,15 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	rxrpc_seq_t seq = sp->hdr.seq;
 	int ret, ix;
+	u8 annotation = RXRPC_TX_ANNO_UNACK;
 
 	_net("queue skb %p [%d]", skb, seq);
 
 	ASSERTCMP(seq, ==, call->tx_top + 1);
 
+	if (last)
+		annotation |= RXRPC_TX_ANNO_LAST;
+
 	/* We have to set the timestamp before queueing as the retransmit
 	 * algorithm can see the packet as soon as we queue it.
 	 */
@@ -106,18 +110,14 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 
 	ix = seq & RXRPC_RXTX_BUFF_MASK;
 	rxrpc_get_skb(skb, rxrpc_skb_tx_got);
-	call->rxtx_annotations[ix] = RXRPC_TX_ANNO_UNACK;
+	call->rxtx_annotations[ix] = annotation;
 	smp_wmb();
 	call->rxtx_buffer[ix] = skb;
 	call->tx_top = seq;
-	if (last) {
-		set_bit(RXRPC_CALL_TX_LAST, &call->flags);
+	if (last)
 		trace_rxrpc_transmit(call, rxrpc_transmit_queue_last);
-	} else if (sp->hdr.flags & RXRPC_REQUEST_ACK) {
-		trace_rxrpc_transmit(call, rxrpc_transmit_queue_reqack);
-	} else {
+	else
 		trace_rxrpc_transmit(call, rxrpc_transmit_queue);
-	}
 
 	if (last || call->state == RXRPC_CALL_SERVER_ACK_REQUEST) {
 		_debug("________awaiting reply/ACK__________");
