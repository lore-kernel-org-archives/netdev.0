From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 04/11] rxrpc: Add a tracepoint to follow the life
 of a packet in the Tx buffer
Date: Sun, 18 Sep 2016 00:21:57 +0100
Message-ID: <147415451788.18436.8653394936798209500.stgit@warthog.procyon.org.uk>
References: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53280 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757736AbcIQXWA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:22:00 -0400
In-Reply-To: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a tracepoint to follow the insertion of a packet into the transmit
buffer, its transmission and its rotation out of the buffer.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   26 ++++++++++++++++++++++++++
 net/rxrpc/ar-internal.h      |   12 ++++++++++++
 net/rxrpc/input.c            |    2 ++
 net/rxrpc/misc.c             |    9 +++++++++
 net/rxrpc/sendmsg.c          |    9 ++++++++-
 5 files changed, 57 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index c0c496c83f31..ffc74b3e5b76 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -208,6 +208,32 @@ TRACE_EVENT(rxrpc_abort,
 		      __entry->abort_code, __entry->error, __entry->why)
 	    );
 
+TRACE_EVENT(rxrpc_transmit,
+	    TP_PROTO(struct rxrpc_call *call, enum rxrpc_transmit_trace why),
+
+	    TP_ARGS(call, why),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(enum rxrpc_transmit_trace,	why		)
+		    __field(rxrpc_seq_t,		tx_hard_ack	)
+		    __field(rxrpc_seq_t,		tx_top		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->why = why;
+		    __entry->tx_hard_ack = call->tx_hard_ack;
+		    __entry->tx_top = call->tx_top;
+			   ),
+
+	    TP_printk("c=%p %s f=%08x n=%u",
+		      __entry->call,
+		      rxrpc_transmit_traces[__entry->why],
+		      __entry->tx_hard_ack + 1,
+		      __entry->tx_top - __entry->tx_hard_ack)
+	    );
+
 #endif /* _TRACE_RXRPC_H */
 
 /* This part must be outside protection */
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 6ca40eea3022..afa5dcc05fe0 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -593,6 +593,18 @@ enum rxrpc_call_trace {
 
 extern const char rxrpc_call_traces[rxrpc_call__nr_trace][4];
 
+enum rxrpc_transmit_trace {
+	rxrpc_transmit_wait,
+	rxrpc_transmit_queue,
+	rxrpc_transmit_queue_reqack,
+	rxrpc_transmit_queue_last,
+	rxrpc_transmit_rotate,
+	rxrpc_transmit_end,
+	rxrpc_transmit__nr_trace
+};
+
+extern const char rxrpc_transmit_traces[rxrpc_transmit__nr_trace][4];
+
 extern const char *const rxrpc_pkts[];
 extern const char *rxrpc_acks(u8 reason);
 
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index c1f83d22f9b7..c7eb5104e91a 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -59,6 +59,7 @@ static void rxrpc_rotate_tx_window(struct rxrpc_call *call, rxrpc_seq_t to)
 
 	spin_unlock(&call->lock);
 
+	trace_rxrpc_transmit(call, rxrpc_transmit_rotate);
 	wake_up(&call->waitq);
 
 	while (list) {
@@ -107,6 +108,7 @@ static bool rxrpc_end_tx_phase(struct rxrpc_call *call, const char *abort_why)
 	}
 
 	write_unlock(&call->state_lock);
+	trace_rxrpc_transmit(call, rxrpc_transmit_end);
 	_leave(" = ok");
 	return true;
 }
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index 598064d3bdd2..dca89995f03e 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -132,3 +132,12 @@ const char rxrpc_client_traces[rxrpc_client__nr_trace][7] = {
 	[rxrpc_client_to_waiting]	= "->Wait",
 	[rxrpc_client_uncount]		= "Uncoun",
 };
+
+const char rxrpc_transmit_traces[rxrpc_transmit__nr_trace][4] = {
+	[rxrpc_transmit_wait]		= "WAI",
+	[rxrpc_transmit_queue]		= "QUE",
+	[rxrpc_transmit_queue_reqack]	= "QRA",
+	[rxrpc_transmit_queue_last]	= "QLS",
+	[rxrpc_transmit_rotate]		= "ROT",
+	[rxrpc_transmit_end]		= "END",
+};
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 8bfddf4e338c..28d8f73cf11d 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -56,6 +56,7 @@ static int rxrpc_wait_for_tx_window(struct rxrpc_sock *rx,
 			break;
 		}
 
+		trace_rxrpc_transmit(call, rxrpc_transmit_wait);
 		release_sock(&rx->sk);
 		*timeo = schedule_timeout(*timeo);
 		lock_sock(&rx->sk);
@@ -104,8 +105,14 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	smp_wmb();
 	call->rxtx_buffer[ix] = skb;
 	call->tx_top = seq;
-	if (last)
+	if (last) {
 		set_bit(RXRPC_CALL_TX_LAST, &call->flags);
+		trace_rxrpc_transmit(call, rxrpc_transmit_queue_last);
+	} else if (sp->hdr.flags & RXRPC_REQUEST_ACK) {
+		trace_rxrpc_transmit(call, rxrpc_transmit_queue_reqack);
+	} else {
+		trace_rxrpc_transmit(call, rxrpc_transmit_queue);
+	}
 
 	if (last || call->state == RXRPC_CALL_SERVER_ACK_REQUEST) {
 		_debug("________awaiting reply/ACK__________");
