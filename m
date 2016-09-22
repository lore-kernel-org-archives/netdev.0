From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/9] rxrpc: Add re-sent Tx annotation [ver #2]
Date: Thu, 22 Sep 2016 09:22:14 +0100
Message-ID: <147453253421.14579.10199701743571193345.stgit@warthog.procyon.org.uk>
References: <147453251987.14579.17230566511204847506.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147453251987.14579.17230566511204847506.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a Tx-phase annotation for packet buffers to indicate that a buffer has
already been retransmitted.  This will be used by future congestion
management.  Re-retransmissions of a packet don't affect the congestion
window managment in the same way as initial retransmissions.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    2 ++
 net/rxrpc/call_event.c  |   28 +++++++++++++++++++---------
 net/rxrpc/input.c       |   14 +++++++++++---
 3 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index f021df4a6a22..dcf54e3fb478 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -505,6 +505,8 @@ struct rxrpc_call {
 #define RXRPC_TX_ANNO_UNACK	1
 #define RXRPC_TX_ANNO_NAK	2
 #define RXRPC_TX_ANNO_RETRANS	3
+#define RXRPC_TX_ANNO_MASK	0x03
+#define RXRPC_TX_ANNO_RESENT	0x04
 #define RXRPC_RX_ANNO_JUMBO	0x3f		/* Jumbo subpacket number + 1 if not zero */
 #define RXRPC_RX_ANNO_JLAST	0x40		/* Set if last element of a jumbo packet */
 #define RXRPC_RX_ANNO_VERIFIED	0x80		/* Set if verified and decrypted */
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 6247ce25eb21..34ad967f2d81 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -144,7 +144,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 	rxrpc_seq_t cursor, seq, top;
 	unsigned long resend_at, now;
 	int ix;
-	u8 annotation;
+	u8 annotation, anno_type;
 
 	_enter("{%d,%d}", call->tx_hard_ack, call->tx_top);
 
@@ -165,14 +165,16 @@ static void rxrpc_resend(struct rxrpc_call *call)
 	for (seq = cursor + 1; before_eq(seq, top); seq++) {
 		ix = seq & RXRPC_RXTX_BUFF_MASK;
 		annotation = call->rxtx_annotations[ix];
-		if (annotation == RXRPC_TX_ANNO_ACK)
+		anno_type = annotation & RXRPC_TX_ANNO_MASK;
+		annotation &= ~RXRPC_TX_ANNO_MASK;
+		if (anno_type == RXRPC_TX_ANNO_ACK)
 			continue;
 
 		skb = call->rxtx_buffer[ix];
 		rxrpc_see_skb(skb, rxrpc_skb_tx_seen);
 		sp = rxrpc_skb(skb);
 
-		if (annotation == RXRPC_TX_ANNO_UNACK) {
+		if (anno_type == RXRPC_TX_ANNO_UNACK) {
 			if (time_after(sp->resend_at, now)) {
 				if (time_before(sp->resend_at, resend_at))
 					resend_at = sp->resend_at;
@@ -181,7 +183,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 		}
 
 		/* Okay, we need to retransmit a packet. */
-		call->rxtx_annotations[ix] = RXRPC_TX_ANNO_RETRANS;
+		call->rxtx_annotations[ix] = RXRPC_TX_ANNO_RETRANS | annotation;
 	}
 
 	call->resend_at = resend_at;
@@ -194,7 +196,8 @@ static void rxrpc_resend(struct rxrpc_call *call)
 	for (seq = cursor + 1; before_eq(seq, top); seq++) {
 		ix = seq & RXRPC_RXTX_BUFF_MASK;
 		annotation = call->rxtx_annotations[ix];
-		if (annotation != RXRPC_TX_ANNO_RETRANS)
+		anno_type = annotation & RXRPC_TX_ANNO_MASK;
+		if (anno_type != RXRPC_TX_ANNO_RETRANS)
 			continue;
 
 		skb = call->rxtx_buffer[ix];
@@ -220,10 +223,17 @@ static void rxrpc_resend(struct rxrpc_call *call)
 		 * received and the packet might have been hard-ACK'd (in which
 		 * case it will no longer be in the buffer).
 		 */
-		if (after(seq, call->tx_hard_ack) &&
-		    (call->rxtx_annotations[ix] == RXRPC_TX_ANNO_RETRANS ||
-		     call->rxtx_annotations[ix] == RXRPC_TX_ANNO_NAK))
-			call->rxtx_annotations[ix] = RXRPC_TX_ANNO_UNACK;
+		if (after(seq, call->tx_hard_ack)) {
+			annotation = call->rxtx_annotations[ix];
+			anno_type = annotation & RXRPC_TX_ANNO_MASK;
+			if (anno_type == RXRPC_TX_ANNO_RETRANS ||
+			    anno_type == RXRPC_TX_ANNO_NAK) {
+				annotation &= ~RXRPC_TX_ANNO_MASK;
+				annotation |= RXRPC_TX_ANNO_UNACK;
+			}
+			annotation |= RXRPC_TX_ANNO_RESENT;
+			call->rxtx_annotations[ix] = annotation;
+		}
 
 		if (after(call->tx_hard_ack, seq))
 			seq = call->tx_hard_ack;
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 7ac1edf3aac7..aa261df9fc9e 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -388,17 +388,25 @@ static void rxrpc_input_soft_acks(struct rxrpc_call *call, u8 *acks,
 {
 	bool resend = false;
 	int ix;
+	u8 annotation, anno_type;
 
 	for (; nr_acks > 0; nr_acks--, seq++) {
 		ix = seq & RXRPC_RXTX_BUFF_MASK;
+		annotation = call->rxtx_annotations[ix];
+		anno_type = annotation & RXRPC_TX_ANNO_MASK;
+		annotation &= ~RXRPC_TX_ANNO_MASK;
 		switch (*acks++) {
 		case RXRPC_ACK_TYPE_ACK:
-			call->rxtx_annotations[ix] = RXRPC_TX_ANNO_ACK;
+			if (anno_type == RXRPC_TX_ANNO_ACK)
+				continue;
+			call->rxtx_annotations[ix] =
+				RXRPC_TX_ANNO_ACK | annotation;
 			break;
 		case RXRPC_ACK_TYPE_NACK:
-			if (call->rxtx_annotations[ix] == RXRPC_TX_ANNO_NAK)
+			if (anno_type == RXRPC_TX_ANNO_NAK)
 				continue;
-			call->rxtx_annotations[ix] = RXRPC_TX_ANNO_NAK;
+			call->rxtx_annotations[ix] =
+				RXRPC_TX_ANNO_NAK | annotation;
 			resend = true;
 			break;
 		default:
