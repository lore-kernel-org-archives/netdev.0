From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/6] rxrpc: Make Tx loss-injection go through
 normal return and adjust tracing
Date: Thu, 29 Sep 2016 23:15:41 +0100
Message-ID: <147518734134.29235.11913142943367350662.stgit@warthog.procyon.org.uk>
References: <147518732742.29235.11597637573731081178.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147518732742.29235.11597637573731081178.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In rxrpc_send_data_packet() make the loss-injection path return through the
same code as the transmission path so that the RTT determination is
initiated and any future timer shuffling will be done, despite the packet
having been binned.

Whilst we're at it:

 (1) Add to the tx_data tracepoint an indication of whether or not we're
     retransmitting a data packet.

 (2) When we're deciding whether or not to request an ACK, rather than
     checking if we're in fast-retransmit mode check instead if we're
     retransmitting.

 (3) Don't invoke the lose_skb tracepoint when losing a Tx packet as we're
     not altering the sk_buff refcount nor are we just seeing it after
     getting it off the Tx list.

 (4) The rxrpc_skb_tx_lost note is then no longer used so remove it.

 (5) rxrpc_lose_skb() no longer needs to deal with rxrpc_skb_tx_lost.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |    6 ++++--
 net/rxrpc/ar-internal.h      |    3 +--
 net/rxrpc/call_event.c       |    2 +-
 net/rxrpc/misc.c             |    1 -
 net/rxrpc/output.c           |   17 +++++++++--------
 net/rxrpc/sendmsg.c          |    2 +-
 net/rxrpc/skbuff.c           |   11 +++--------
 7 files changed, 19 insertions(+), 23 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index ada12d00118c..8ba8d76e856a 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -258,15 +258,16 @@ TRACE_EVENT(rxrpc_rx_ack,
 
 TRACE_EVENT(rxrpc_tx_data,
 	    TP_PROTO(struct rxrpc_call *call, rxrpc_seq_t seq,
-		     rxrpc_serial_t serial, u8 flags, bool lose),
+		     rxrpc_serial_t serial, u8 flags, bool retrans, bool lose),
 
-	    TP_ARGS(call, seq, serial, flags, lose),
+	    TP_ARGS(call, seq, serial, flags, retrans, lose),
 
 	    TP_STRUCT__entry(
 		    __field(struct rxrpc_call *,	call		)
 		    __field(rxrpc_seq_t,		seq		)
 		    __field(rxrpc_serial_t,		serial		)
 		    __field(u8,				flags		)
+		    __field(bool,			retrans		)
 		    __field(bool,			lose		)
 			     ),
 
@@ -275,6 +276,7 @@ TRACE_EVENT(rxrpc_tx_data,
 		    __entry->seq = seq;
 		    __entry->serial = serial;
 		    __entry->flags = flags;
+		    __entry->retrans = retrans;
 		    __entry->lose = lose;
 			   ),
 
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index ca96e547cb9a..6aadaa7d8b43 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -603,7 +603,6 @@ enum rxrpc_skb_trace {
 	rxrpc_skb_tx_cleaned,
 	rxrpc_skb_tx_freed,
 	rxrpc_skb_tx_got,
-	rxrpc_skb_tx_lost,
 	rxrpc_skb_tx_new,
 	rxrpc_skb_tx_rotated,
 	rxrpc_skb_tx_seen,
@@ -1073,7 +1072,7 @@ extern const s8 rxrpc_ack_priority[];
  * output.c
  */
 int rxrpc_send_call_packet(struct rxrpc_call *, u8);
-int rxrpc_send_data_packet(struct rxrpc_call *, struct sk_buff *);
+int rxrpc_send_data_packet(struct rxrpc_call *, struct sk_buff *, bool);
 void rxrpc_reject_packets(struct rxrpc_local *);
 
 /*
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 0e8478012212..1f6c7633b964 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -256,7 +256,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 		rxrpc_get_skb(skb, rxrpc_skb_tx_got);
 		spin_unlock_bh(&call->lock);
 
-		if (rxrpc_send_data_packet(call, skb) < 0) {
+		if (rxrpc_send_data_packet(call, skb, true) < 0) {
 			rxrpc_free_skb(skb, rxrpc_skb_tx_freed);
 			return;
 		}
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index aedb8978226d..47dddacdbb91 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -108,7 +108,6 @@ const char rxrpc_skb_traces[rxrpc_skb__nr_trace][7] = {
 	[rxrpc_skb_tx_cleaned]		= "Tx CLN",
 	[rxrpc_skb_tx_freed]		= "Tx FRE",
 	[rxrpc_skb_tx_got]		= "Tx GOT",
-	[rxrpc_skb_tx_lost]		= "Tx *L*",
 	[rxrpc_skb_tx_new]		= "Tx NEW",
 	[rxrpc_skb_tx_rotated]		= "Tx ROT",
 	[rxrpc_skb_tx_seen]		= "Tx SEE",
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index cf43a715685e..ac9a58b619a6 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -238,7 +238,8 @@ out:
 /*
  * send a packet through the transport endpoint
  */
-int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb)
+int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb,
+			   bool retrans)
 {
 	struct rxrpc_connection *conn = call->conn;
 	struct rxrpc_wire_header whdr;
@@ -247,6 +248,7 @@ int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb)
 	struct kvec iov[2];
 	rxrpc_serial_t serial;
 	size_t len;
+	bool lost = false;
 	int ret, opt;
 
 	_enter(",{%d}", skb->len);
@@ -281,7 +283,7 @@ int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb)
 	/* If our RTT cache needs working on, request an ACK.  Also request
 	 * ACKs if a DATA packet appears to have been lost.
 	 */
-	if (call->cong_mode == RXRPC_CALL_FAST_RETRANSMIT ||
+	if (retrans ||
 	    (call->peer->rtt_usage < 3 && sp->hdr.seq & 1) ||
 	    ktime_before(ktime_add_ms(call->peer->rtt_last_req, 1000),
 			 ktime_get_real()))
@@ -290,11 +292,9 @@ int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb)
 	if (IS_ENABLED(CONFIG_AF_RXRPC_INJECT_LOSS)) {
 		static int lose;
 		if ((lose++ & 7) == 7) {
-			trace_rxrpc_tx_data(call, sp->hdr.seq, serial,
-					    whdr.flags, true);
-			rxrpc_lose_skb(skb, rxrpc_skb_tx_lost);
-			_leave(" = 0 [lose]");
-			return 0;
+			ret = 0;
+			lost = true;
+			goto done;
 		}
 	}
 
@@ -319,7 +319,8 @@ int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb)
 		goto send_fragmentable;
 
 done:
-	trace_rxrpc_tx_data(call, sp->hdr.seq, serial, whdr.flags, false);
+	trace_rxrpc_tx_data(call, sp->hdr.seq, serial, whdr.flags,
+			    retrans, lost);
 	if (ret >= 0) {
 		ktime_t now = ktime_get_real();
 		skb->tstamp = now;
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 1f8040d82395..d8dfdce874d8 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -144,7 +144,7 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	if (seq == 1 && rxrpc_is_client_call(call))
 		rxrpc_expose_client_call(call);
 
-	ret = rxrpc_send_data_packet(call, skb);
+	ret = rxrpc_send_data_packet(call, skb, false);
 	if (ret < 0) {
 		_debug("need instant resend %d", ret);
 		rxrpc_instant_resend(call, ix);
diff --git a/net/rxrpc/skbuff.c b/net/rxrpc/skbuff.c
index 5154cbf7e540..67b02c45271b 100644
--- a/net/rxrpc/skbuff.c
+++ b/net/rxrpc/skbuff.c
@@ -77,14 +77,9 @@ void rxrpc_lose_skb(struct sk_buff *skb, enum rxrpc_skb_trace op)
 	if (skb) {
 		int n;
 		CHECK_SLAB_OKAY(&skb->users);
-		if (op == rxrpc_skb_tx_lost) {
-			n = atomic_read(select_skb_count(op));
-			trace_rxrpc_skb(skb, op, atomic_read(&skb->users), n, here);
-		} else {
-			n = atomic_dec_return(select_skb_count(op));
-			trace_rxrpc_skb(skb, op, atomic_read(&skb->users), n, here);
-			kfree_skb(skb);
-		}
+		n = atomic_dec_return(select_skb_count(op));
+		trace_rxrpc_skb(skb, op, atomic_read(&skb->users), n, here);
+		kfree_skb(skb);
 	}
 }
 
