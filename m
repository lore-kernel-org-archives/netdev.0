From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 04/14] rxrpc: Fix handling of the last packet in
 rxrpc_recvmsg_data()
Date: Sun, 18 Sep 2016 00:18:12 +0100
Message-ID: <147415429264.17897.6609331289273741186.stgit@warthog.procyon.org.uk>
References: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44530 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932827AbcIQXSU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:18:20 -0400
In-Reply-To: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code for determining the last packet in rxrpc_recvmsg_data() has been
using the RXRPC_CALL_RX_LAST flag to determine if the rx_top pointer points
to the last packet or not.  This isn't a good idea, however, as the input
code may be running simultaneously on another CPU and that sets the flag
*before* updating the top pointer.

Fix this by the following means:

 (1) Restrict the use of RXRPC_CALL_RX_LAST to the input routines only.
     There's otherwise a synchronisation problem between detecting the flag
     and checking tx_top.  This could probably be dealt with by appropriate
     application of memory barriers, but there's a simpler way.

 (2) Set RXRPC_CALL_RX_LAST after setting rx_top.

 (3) Make rxrpc_rotate_rx_window() consult the flags header field of the
     DATA packet it's about to discard to see if that was the last packet.
     Use this as the basis for ending the Rx phase.  This shouldn't be a
     problem because the recvmsg side of things is guaranteed to see the
     packets in order.

 (4) Make rxrpc_recvmsg_data() return 1 to indicate the end of the data if:

     (a) the packet it has just processed is marked as RXRPC_LAST_PACKET

     (b) the call's Rx phase has been ended.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c   |    4 +++-
 net/rxrpc/recvmsg.c |   49 +++++++++++++++++++++++++++++++++----------------
 2 files changed, 36 insertions(+), 17 deletions(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 75af0bd316c7..f0d9115b9b7e 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -238,7 +238,7 @@ next_subpacket:
 		len = RXRPC_JUMBO_DATALEN;
 
 	if (flags & RXRPC_LAST_PACKET) {
-		if (test_and_set_bit(RXRPC_CALL_RX_LAST, &call->flags) &&
+		if (test_bit(RXRPC_CALL_RX_LAST, &call->flags) &&
 		    seq != call->rx_top)
 			return rxrpc_proto_abort("LSN", call, seq);
 	} else {
@@ -282,6 +282,8 @@ next_subpacket:
 	call->rxtx_buffer[ix] = skb;
 	if (after(seq, call->rx_top))
 		smp_store_release(&call->rx_top, seq);
+	if (flags & RXRPC_LAST_PACKET)
+		set_bit(RXRPC_CALL_RX_LAST, &call->flags);
 	queued = true;
 
 	if (after_eq(seq, call->rx_expect_next)) {
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 1edf2cf62cc5..8b8d7e14f800 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -134,6 +134,8 @@ static void rxrpc_end_rx_phase(struct rxrpc_call *call)
 {
 	_enter("%d,%s", call->debug_id, rxrpc_call_states[call->state]);
 
+	ASSERTCMP(call->rx_hard_ack, ==, call->rx_top);
+
 	if (call->state == RXRPC_CALL_CLIENT_RECV_REPLY) {
 		rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, 0, 0, true, false);
 		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
@@ -163,8 +165,10 @@ static void rxrpc_end_rx_phase(struct rxrpc_call *call)
  */
 static void rxrpc_rotate_rx_window(struct rxrpc_call *call)
 {
+	struct rxrpc_skb_priv *sp;
 	struct sk_buff *skb;
 	rxrpc_seq_t hard_ack, top;
+	u8 flags;
 	int ix;
 
 	_enter("%d", call->debug_id);
@@ -177,6 +181,8 @@ static void rxrpc_rotate_rx_window(struct rxrpc_call *call)
 	ix = hard_ack & RXRPC_RXTX_BUFF_MASK;
 	skb = call->rxtx_buffer[ix];
 	rxrpc_see_skb(skb);
+	sp = rxrpc_skb(skb);
+	flags = sp->hdr.flags;
 	call->rxtx_buffer[ix] = NULL;
 	call->rxtx_annotations[ix] = 0;
 	/* Barrier against rxrpc_input_data(). */
@@ -184,8 +190,8 @@ static void rxrpc_rotate_rx_window(struct rxrpc_call *call)
 
 	rxrpc_free_skb(skb);
 
-	_debug("%u,%u,%lx", hard_ack, top, call->flags);
-	if (hard_ack == top && test_bit(RXRPC_CALL_RX_LAST, &call->flags))
+	_debug("%u,%u,%02x", hard_ack, top, flags);
+	if (flags & RXRPC_LAST_PACKET)
 		rxrpc_end_rx_phase(call);
 }
 
@@ -278,13 +284,19 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 	size_t remain;
 	bool last;
 	unsigned int rx_pkt_offset, rx_pkt_len;
-	int ix, copy, ret = 0;
+	int ix, copy, ret = -EAGAIN, ret2;
 
 	_enter("");
 
 	rx_pkt_offset = call->rx_pkt_offset;
 	rx_pkt_len = call->rx_pkt_len;
 
+	if (call->state >= RXRPC_CALL_SERVER_ACK_REQUEST) {
+		seq = call->rx_hard_ack;
+		ret = 1;
+		goto done;
+	}
+
 	/* Barriers against rxrpc_input_data(). */
 	hard_ack = call->rx_hard_ack;
 	top = smp_load_acquire(&call->rx_top);
@@ -301,11 +313,13 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 			sock_recv_timestamp(msg, sock->sk, skb);
 
 		if (rx_pkt_offset == 0) {
-			ret = rxrpc_locate_data(call, skb,
-						&call->rxtx_annotations[ix],
-						&rx_pkt_offset, &rx_pkt_len);
-			if (ret < 0)
+			ret2 = rxrpc_locate_data(call, skb,
+						 &call->rxtx_annotations[ix],
+						 &rx_pkt_offset, &rx_pkt_len);
+			if (ret2 < 0) {
+				ret = ret2;
 				goto out;
+			}
 		}
 		_debug("recvmsg %x DATA #%u { %d, %d }",
 		       sp->hdr.callNumber, seq, rx_pkt_offset, rx_pkt_len);
@@ -316,10 +330,12 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 		if (copy > remain)
 			copy = remain;
 		if (copy > 0) {
-			ret = skb_copy_datagram_iter(skb, rx_pkt_offset, iter,
-						     copy);
-			if (ret < 0)
+			ret2 = skb_copy_datagram_iter(skb, rx_pkt_offset, iter,
+						      copy);
+			if (ret2 < 0) {
+				ret = ret2;
 				goto out;
+			}
 
 			/* handle piecemeal consumption of data packets */
 			_debug("copied %d @%zu", copy, *_offset);
@@ -332,6 +348,7 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 		if (rx_pkt_len > 0) {
 			_debug("buffer full");
 			ASSERTCMP(*_offset, ==, len);
+			ret = 0;
 			break;
 		}
 
@@ -342,19 +359,19 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 		rx_pkt_offset = 0;
 		rx_pkt_len = 0;
 
-		ASSERTIFCMP(last, seq, ==, top);
-	}
-
-	if (after(seq, top)) {
-		ret = -EAGAIN;
-		if (test_bit(RXRPC_CALL_RX_LAST, &call->flags))
+		if (last) {
+			ASSERTCMP(seq, ==, READ_ONCE(call->rx_top));
 			ret = 1;
+			goto out;
+		}
 	}
+
 out:
 	if (!(flags & MSG_PEEK)) {
 		call->rx_pkt_offset = rx_pkt_offset;
 		call->rx_pkt_len = rx_pkt_len;
 	}
+done:
 	_leave(" = %d [%u/%u]", ret, seq, top);
 	return ret;
 }
