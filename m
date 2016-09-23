From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 12/15] rxrpc: Add data Tx tracepoint and adjust Tx
 ACK tracepoint
Date: Fri, 23 Sep 2016 16:16:40 +0100
Message-ID: <147464380043.5090.13381475978736164677.stgit@warthog.procyon.org.uk>
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

Add a tracepoint to log transmission of DATA packets (including loss
injection).

Adjust the ACK transmission tracepoint to include the packet serial number
and to line this up with the DATA transmission display.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   50 +++++++++++++++++++++++++++++++++++-------
 net/rxrpc/conn_event.c       |    5 ++--
 net/rxrpc/output.c           |    5 +++-
 3 files changed, 48 insertions(+), 12 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 57322897d745..6001bf93dc79 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -256,33 +256,67 @@ TRACE_EVENT(rxrpc_rx_ack,
 		      __entry->n_acks)
 	    );
 
+TRACE_EVENT(rxrpc_tx_data,
+	    TP_PROTO(struct rxrpc_call *call, rxrpc_seq_t seq,
+		     rxrpc_serial_t serial, u8 flags, bool lose),
+
+	    TP_ARGS(call, seq, serial, flags, lose),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(rxrpc_seq_t,		seq		)
+		    __field(rxrpc_serial_t,		serial		)
+		    __field(u8,				flags		)
+		    __field(bool,			lose		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->seq = seq;
+		    __entry->serial = serial;
+		    __entry->flags = flags;
+		    __entry->lose = lose;
+			   ),
+
+	    TP_printk("c=%p DATA %08x q=%08x fl=%02x%s",
+		      __entry->call,
+		      __entry->serial,
+		      __entry->seq,
+		      __entry->flags,
+		      __entry->lose ? " *LOSE*" : "")
+	    );
+
 TRACE_EVENT(rxrpc_tx_ack,
-	    TP_PROTO(struct rxrpc_call *call, rxrpc_seq_t first,
-		     rxrpc_serial_t serial, u8 reason, u8 n_acks),
+	    TP_PROTO(struct rxrpc_call *call, rxrpc_serial_t serial,
+		     rxrpc_seq_t ack_first, rxrpc_serial_t ack_serial,
+		     u8 reason, u8 n_acks),
 
-	    TP_ARGS(call, first, serial, reason, n_acks),
+	    TP_ARGS(call, serial, ack_first, ack_serial, reason, n_acks),
 
 	    TP_STRUCT__entry(
 		    __field(struct rxrpc_call *,	call		)
-		    __field(rxrpc_seq_t,		first		)
 		    __field(rxrpc_serial_t,		serial		)
+		    __field(rxrpc_seq_t,		ack_first	)
+		    __field(rxrpc_serial_t,		ack_serial	)
 		    __field(u8,				reason		)
 		    __field(u8,				n_acks		)
 			     ),
 
 	    TP_fast_assign(
 		    __entry->call = call;
-		    __entry->first = first;
 		    __entry->serial = serial;
+		    __entry->ack_first = ack_first;
+		    __entry->ack_serial = ack_serial;
 		    __entry->reason = reason;
 		    __entry->n_acks = n_acks;
 			   ),
 
-	    TP_printk("c=%p %s f=%08x r=%08x n=%u",
+	    TP_printk(" c=%p ACK  %08x %s f=%08x r=%08x n=%u",
 		      __entry->call,
-		      rxrpc_acks(__entry->reason),
-		      __entry->first,
 		      __entry->serial,
+		      rxrpc_acks(__entry->reason),
+		      __entry->ack_first,
+		      __entry->ack_serial,
 		      __entry->n_acks)
 	    );
 
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index 75a15a4c74c3..a1cf1ec5f29e 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -98,9 +98,6 @@ static void rxrpc_conn_retransmit_call(struct rxrpc_connection *conn,
 		pkt.info.rwind		= htonl(rxrpc_rx_window_size);
 		pkt.info.jumbo_max	= htonl(rxrpc_rx_jumbo_max);
 		len += sizeof(pkt.ack) + sizeof(pkt.info);
-
-		trace_rxrpc_tx_ack(NULL, chan->last_seq, 0,
-				   RXRPC_ACK_DUPLICATE, 0);
 		break;
 	}
 
@@ -122,6 +119,8 @@ static void rxrpc_conn_retransmit_call(struct rxrpc_connection *conn,
 		_proto("Tx ABORT %%%u { %d } [re]", serial, conn->local_abort);
 		break;
 	case RXRPC_PACKET_TYPE_ACK:
+		trace_rxrpc_tx_ack(NULL, serial, chan->last_seq, 0,
+				   RXRPC_ACK_DUPLICATE, 0);
 		_proto("Tx ACK %%%u [re]", serial);
 		break;
 	}
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 5c1e008a5323..e47fbd1c836d 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -177,7 +177,7 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 	pkt->whdr.serial = htonl(serial);
 	switch (type) {
 	case RXRPC_PACKET_TYPE_ACK:
-		trace_rxrpc_tx_ack(call,
+		trace_rxrpc_tx_ack(call, serial,
 				   ntohl(pkt->ack.firstPacket),
 				   ntohl(pkt->ack.serial),
 				   pkt->ack.reason, pkt->ack.nAcks);
@@ -275,6 +275,8 @@ int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb)
 	if (IS_ENABLED(CONFIG_AF_RXRPC_INJECT_LOSS)) {
 		static int lose;
 		if ((lose++ & 7) == 7) {
+			trace_rxrpc_tx_data(call, sp->hdr.seq, serial,
+					    whdr.flags, true);
 			rxrpc_lose_skb(skb, rxrpc_skb_tx_lost);
 			_leave(" = 0 [lose]");
 			return 0;
@@ -302,6 +304,7 @@ int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb)
 		goto send_fragmentable;
 
 done:
+	trace_rxrpc_tx_data(call, sp->hdr.seq, serial, whdr.flags, false);
 	if (ret >= 0) {
 		ktime_t now = ktime_get_real();
 		skb->tstamp = now;
