From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 07/11] rxrpc: Add a tracepoint to follow packets in
 the Rx buffer
Date: Sun, 18 Sep 2016 00:22:18 +0100
Message-ID: <147415453889.18436.14620909095224470936.stgit@warthog.procyon.org.uk>
References: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a tracepoint to follow the life of packets that get added to a call's
receive buffer.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   33 +++++++++++++++++++++++++++++++++
 net/rxrpc/ar-internal.h      |   12 ++++++++++++
 net/rxrpc/call_accept.c      |    3 +++
 net/rxrpc/input.c            |    6 +++++-
 net/rxrpc/misc.c             |    9 +++++++++
 net/rxrpc/recvmsg.c          |   11 +++++++++++
 6 files changed, 73 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index d545d692ae22..7dd5f0188681 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -290,6 +290,39 @@ TRACE_EVENT(rxrpc_tx_ack,
 		      __entry->n_acks)
 	    );
 
+TRACE_EVENT(rxrpc_receive,
+	    TP_PROTO(struct rxrpc_call *call, enum rxrpc_receive_trace why,
+		     rxrpc_serial_t serial, rxrpc_seq_t seq),
+
+	    TP_ARGS(call, why, serial, seq),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(enum rxrpc_receive_trace,	why		)
+		    __field(rxrpc_serial_t,		serial		)
+		    __field(rxrpc_seq_t,		seq		)
+		    __field(rxrpc_seq_t,		hard_ack	)
+		    __field(rxrpc_seq_t,		top		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->why = why;
+		    __entry->serial = serial;
+		    __entry->seq = seq;
+		    __entry->hard_ack = call->rx_hard_ack;
+		    __entry->top = call->rx_top;
+			   ),
+
+	    TP_printk("c=%p %s r=%08x q=%08x w=%08x-%08x",
+		      __entry->call,
+		      rxrpc_receive_traces[__entry->why],
+		      __entry->serial,
+		      __entry->seq,
+		      __entry->hard_ack,
+		      __entry->top)
+	    );
+
 #endif /* _TRACE_RXRPC_H */
 
 /* This part must be outside protection */
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index afa5dcc05fe0..e5d2f2fb8e41 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -605,6 +605,18 @@ enum rxrpc_transmit_trace {
 
 extern const char rxrpc_transmit_traces[rxrpc_transmit__nr_trace][4];
 
+enum rxrpc_receive_trace {
+	rxrpc_receive_incoming,
+	rxrpc_receive_queue,
+	rxrpc_receive_queue_last,
+	rxrpc_receive_front,
+	rxrpc_receive_rotate,
+	rxrpc_receive_end,
+	rxrpc_receive__nr_trace
+};
+
+extern const char rxrpc_receive_traces[rxrpc_receive__nr_trace][4];
+
 extern const char *const rxrpc_pkts[];
 extern const char *rxrpc_acks(u8 reason);
 
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 3e474508ba75..a8d39d7cf42c 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -367,6 +367,9 @@ found_service:
 		goto out;
 	}
 
+	trace_rxrpc_receive(call, rxrpc_receive_incoming,
+			    sp->hdr.serial, sp->hdr.seq);
+
 	/* Make the call live. */
 	rxrpc_incoming_call(rx, call, skb);
 	conn = call->conn;
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 7b18ca124978..b690220533c6 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -284,8 +284,12 @@ next_subpacket:
 	call->rxtx_buffer[ix] = skb;
 	if (after(seq, call->rx_top))
 		smp_store_release(&call->rx_top, seq);
-	if (flags & RXRPC_LAST_PACKET)
+	if (flags & RXRPC_LAST_PACKET) {
 		set_bit(RXRPC_CALL_RX_LAST, &call->flags);
+		trace_rxrpc_receive(call, rxrpc_receive_queue_last, serial, seq);
+	} else {
+		trace_rxrpc_receive(call, rxrpc_receive_queue, serial, seq);
+	}
 	queued = true;
 
 	if (after_eq(seq, call->rx_expect_next)) {
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index dca89995f03e..db5f1d54fc90 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -141,3 +141,12 @@ const char rxrpc_transmit_traces[rxrpc_transmit__nr_trace][4] = {
 	[rxrpc_transmit_rotate]		= "ROT",
 	[rxrpc_transmit_end]		= "END",
 };
+
+const char rxrpc_receive_traces[rxrpc_receive__nr_trace][4] = {
+	[rxrpc_receive_incoming]	= "INC",
+	[rxrpc_receive_queue]		= "QUE",
+	[rxrpc_receive_queue_last]	= "QLS",
+	[rxrpc_receive_front]		= "FRN",
+	[rxrpc_receive_rotate]		= "ROT",
+	[rxrpc_receive_end]		= "END",
+};
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 8b8d7e14f800..22d51087c580 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -134,6 +134,7 @@ static void rxrpc_end_rx_phase(struct rxrpc_call *call)
 {
 	_enter("%d,%s", call->debug_id, rxrpc_call_states[call->state]);
 
+	trace_rxrpc_receive(call, rxrpc_receive_end, 0, call->rx_top);
 	ASSERTCMP(call->rx_hard_ack, ==, call->rx_top);
 
 	if (call->state == RXRPC_CALL_CLIENT_RECV_REPLY) {
@@ -167,6 +168,7 @@ static void rxrpc_rotate_rx_window(struct rxrpc_call *call)
 {
 	struct rxrpc_skb_priv *sp;
 	struct sk_buff *skb;
+	rxrpc_serial_t serial;
 	rxrpc_seq_t hard_ack, top;
 	u8 flags;
 	int ix;
@@ -183,6 +185,10 @@ static void rxrpc_rotate_rx_window(struct rxrpc_call *call)
 	rxrpc_see_skb(skb);
 	sp = rxrpc_skb(skb);
 	flags = sp->hdr.flags;
+	serial = sp->hdr.serial;
+	if (call->rxtx_annotations[ix] & RXRPC_RX_ANNO_JUMBO)
+		serial += (call->rxtx_annotations[ix] & RXRPC_RX_ANNO_JUMBO) - 1;
+
 	call->rxtx_buffer[ix] = NULL;
 	call->rxtx_annotations[ix] = 0;
 	/* Barrier against rxrpc_input_data(). */
@@ -191,6 +197,7 @@ static void rxrpc_rotate_rx_window(struct rxrpc_call *call)
 	rxrpc_free_skb(skb);
 
 	_debug("%u,%u,%02x", hard_ack, top, flags);
+	trace_rxrpc_receive(call, rxrpc_receive_rotate, serial, hard_ack);
 	if (flags & RXRPC_LAST_PACKET)
 		rxrpc_end_rx_phase(call);
 }
@@ -309,6 +316,10 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 		rxrpc_see_skb(skb);
 		sp = rxrpc_skb(skb);
 
+		if (!(flags & MSG_PEEK))
+			trace_rxrpc_receive(call, rxrpc_receive_front,
+					    sp->hdr.serial, seq);
+
 		if (msg)
 			sock_recv_timestamp(msg, sock->sk, skb);
 
