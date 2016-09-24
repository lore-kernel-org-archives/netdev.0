From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 6/8] rxrpc: Generate a summary of the ACK state for
 later use
Date: Sun, 25 Sep 2016 00:25:37 +0100
Message-ID: <147475953780.15231.8143746404313078034.stgit@warthog.procyon.org.uk>
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

Generate a summary of the Tx buffer packet state when an ACK is received
for use in a later patch that does congestion management.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |   14 ++++++++++++++
 net/rxrpc/input.c       |   45 ++++++++++++++++++++++++++++++++++-----------
 2 files changed, 48 insertions(+), 11 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index cdd35e2b40ba..1a700b6a998b 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -540,6 +540,20 @@ struct rxrpc_call {
 
 	/* transmission-phase ACK management */
 	rxrpc_serial_t		acks_latest;	/* serial number of latest ACK received */
+	rxrpc_seq_t		acks_lowest_nak; /* Lowest NACK in the buffer (or ==tx_hard_ack) */
+};
+
+/*
+ * Summary of a new ACK and the changes it made.
+ */
+struct rxrpc_ack_summary {
+	u8			ack_reason;
+	u8			nr_acks;		/* Number of ACKs in packet */
+	u8			nr_nacks;		/* Number of NACKs in packet */
+	u8			nr_new_acks;		/* Number of new ACKs in packet */
+	u8			nr_new_nacks;		/* Number of new NACKs in packet */
+	u8			nr_rot_new_acks;	/* Number of rotated new ACKs */
+	bool			new_low_nack;		/* T if new low NACK found */
 };
 
 enum rxrpc_skb_trace {
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index bda11eb2ab2a..dd699667eeef 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -56,12 +56,20 @@ static void rxrpc_send_ping(struct rxrpc_call *call, struct sk_buff *skb,
 /*
  * Apply a hard ACK by advancing the Tx window.
  */
-static void rxrpc_rotate_tx_window(struct rxrpc_call *call, rxrpc_seq_t to)
+static void rxrpc_rotate_tx_window(struct rxrpc_call *call, rxrpc_seq_t to,
+				   struct rxrpc_ack_summary *summary)
 {
 	struct sk_buff *skb, *list = NULL;
 	int ix;
 	u8 annotation;
 
+	if (call->acks_lowest_nak == call->tx_hard_ack) {
+		call->acks_lowest_nak = to;
+	} else if (before_eq(call->acks_lowest_nak, to)) {
+		summary->new_low_nack = true;
+		call->acks_lowest_nak = to;
+	}
+
 	spin_lock(&call->lock);
 
 	while (before(call->tx_hard_ack, to)) {
@@ -77,6 +85,8 @@ static void rxrpc_rotate_tx_window(struct rxrpc_call *call, rxrpc_seq_t to)
 
 		if (annotation & RXRPC_TX_ANNO_LAST)
 			set_bit(RXRPC_CALL_TX_LAST, &call->flags);
+		if ((annotation & RXRPC_TX_ANNO_MASK) != RXRPC_TX_ANNO_ACK)
+			summary->nr_rot_new_acks++;
 	}
 
 	spin_unlock(&call->lock);
@@ -147,6 +157,7 @@ bad_state:
  */
 static bool rxrpc_receiving_reply(struct rxrpc_call *call)
 {
+	struct rxrpc_ack_summary summary = { 0 };
 	rxrpc_seq_t top = READ_ONCE(call->tx_top);
 
 	if (call->ackr_reason) {
@@ -159,7 +170,7 @@ static bool rxrpc_receiving_reply(struct rxrpc_call *call)
 	}
 
 	if (!test_bit(RXRPC_CALL_TX_LAST, &call->flags))
-		rxrpc_rotate_tx_window(call, top);
+		rxrpc_rotate_tx_window(call, top, &summary);
 	if (!test_bit(RXRPC_CALL_TX_LAST, &call->flags)) {
 		rxrpc_proto_abort("TXL", call, top);
 		return false;
@@ -508,7 +519,8 @@ static void rxrpc_input_ackinfo(struct rxrpc_call *call, struct sk_buff *skb,
  * the time the ACK was sent.
  */
 static void rxrpc_input_soft_acks(struct rxrpc_call *call, u8 *acks,
-				  rxrpc_seq_t seq, int nr_acks)
+				  rxrpc_seq_t seq, int nr_acks,
+				  struct rxrpc_ack_summary *summary)
 {
 	bool resend = false;
 	int ix;
@@ -521,14 +533,23 @@ static void rxrpc_input_soft_acks(struct rxrpc_call *call, u8 *acks,
 		annotation &= ~RXRPC_TX_ANNO_MASK;
 		switch (*acks++) {
 		case RXRPC_ACK_TYPE_ACK:
+			summary->nr_acks++;
 			if (anno_type == RXRPC_TX_ANNO_ACK)
 				continue;
+			summary->nr_new_acks++;
 			call->rxtx_annotations[ix] =
 				RXRPC_TX_ANNO_ACK | annotation;
 			break;
 		case RXRPC_ACK_TYPE_NACK:
+			if (!summary->nr_nacks &&
+			    call->acks_lowest_nak != seq) {
+				call->acks_lowest_nak = seq;
+				summary->new_low_nack = true;
+			}
+			summary->nr_nacks++;
 			if (anno_type == RXRPC_TX_ANNO_NAK)
 				continue;
+			summary->nr_new_nacks++;
 			if (anno_type == RXRPC_TX_ANNO_RETRANS)
 				continue;
 			call->rxtx_annotations[ix] =
@@ -558,7 +579,7 @@ static void rxrpc_input_soft_acks(struct rxrpc_call *call, u8 *acks,
 static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 			    u16 skew)
 {
-	u8 ack_reason;
+	struct rxrpc_ack_summary summary = { 0 };
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	union {
 		struct rxrpc_ackpacket ack;
@@ -581,10 +602,10 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 	first_soft_ack = ntohl(buf.ack.firstPacket);
 	hard_ack = first_soft_ack - 1;
 	nr_acks = buf.ack.nAcks;
-	ack_reason = (buf.ack.reason < RXRPC_ACK__INVALID ?
-		      buf.ack.reason : RXRPC_ACK__INVALID);
+	summary.ack_reason = (buf.ack.reason < RXRPC_ACK__INVALID ?
+			      buf.ack.reason : RXRPC_ACK__INVALID);
 
-	trace_rxrpc_rx_ack(call, first_soft_ack, ack_reason, nr_acks);
+	trace_rxrpc_rx_ack(call, first_soft_ack, summary.ack_reason, nr_acks);
 
 	_proto("Rx ACK %%%u { m=%hu f=#%u p=#%u s=%%%u r=%s n=%u }",
 	       sp->hdr.serial,
@@ -592,7 +613,7 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 	       first_soft_ack,
 	       ntohl(buf.ack.previousPacket),
 	       acked_serial,
-	       rxrpc_ack_names[ack_reason],
+	       rxrpc_ack_names[summary.ack_reason],
 	       buf.ack.nAcks);
 
 	if (buf.ack.reason == RXRPC_ACK_PING_RESPONSE)
@@ -649,12 +670,13 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 		return rxrpc_proto_abort("AKN", call, 0);
 
 	if (after(hard_ack, call->tx_hard_ack))
-		rxrpc_rotate_tx_window(call, hard_ack);
+		rxrpc_rotate_tx_window(call, hard_ack, &summary);
 
 	if (nr_acks > 0) {
 		if (skb_copy_bits(skb, sp->offset, buf.acks, nr_acks) < 0)
 			return rxrpc_proto_abort("XSA", call, 0);
-		rxrpc_input_soft_acks(call, buf.acks, first_soft_ack, nr_acks);
+		rxrpc_input_soft_acks(call, buf.acks, first_soft_ack, nr_acks,
+				      &summary);
 	}
 
 	if (test_bit(RXRPC_CALL_TX_LAST, &call->flags)) {
@@ -669,11 +691,12 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
  */
 static void rxrpc_input_ackall(struct rxrpc_call *call, struct sk_buff *skb)
 {
+	struct rxrpc_ack_summary summary = { 0 };
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 
 	_proto("Rx ACKALL %%%u", sp->hdr.serial);
 
-	rxrpc_rotate_tx_window(call, call->tx_top);
+	rxrpc_rotate_tx_window(call, call->tx_top, &summary);
 	if (test_bit(RXRPC_CALL_TX_LAST, &call->flags))
 		rxrpc_end_tx_phase(call, false, "ETL");
 }
