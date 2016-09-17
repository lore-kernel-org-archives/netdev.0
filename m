From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 06/11] rxrpc: Add a tracepoint to log ACK
 transmission
Date: Sun, 18 Sep 2016 00:22:11 +0100
Message-ID: <147415453190.18436.12685894744537500652.stgit@warthog.procyon.org.uk>
References: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50832 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758698AbcIQXWO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:22:14 -0400
In-Reply-To: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a tracepoint to log information about ACK transmission.

Signed-off-by: David Howels <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   30 ++++++++++++++++++++++++++++++
 net/rxrpc/conn_event.c       |    3 +++
 net/rxrpc/output.c           |    7 ++++++-
 3 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 2b19f3fa5174..d545d692ae22 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -260,6 +260,36 @@ TRACE_EVENT(rxrpc_rx_ack,
 		      __entry->n_acks)
 	    );
 
+TRACE_EVENT(rxrpc_tx_ack,
+	    TP_PROTO(struct rxrpc_call *call, rxrpc_seq_t first,
+		     rxrpc_serial_t serial, u8 reason, u8 n_acks),
+
+	    TP_ARGS(call, first, serial, reason, n_acks),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(rxrpc_seq_t,		first		)
+		    __field(rxrpc_serial_t,		serial		)
+		    __field(u8,				reason		)
+		    __field(u8,				n_acks		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->first = first;
+		    __entry->serial = serial;
+		    __entry->reason = reason;
+		    __entry->n_acks = n_acks;
+			   ),
+
+	    TP_printk("c=%p %s f=%08x r=%08x n=%u",
+		      __entry->call,
+		      rxrpc_acks(__entry->reason),
+		      __entry->first,
+		      __entry->serial,
+		      __entry->n_acks)
+	    );
+
 #endif /* _TRACE_RXRPC_H */
 
 /* This part must be outside protection */
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index a43f4c94a88d..9b19c51831aa 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -98,6 +98,9 @@ static void rxrpc_conn_retransmit_call(struct rxrpc_connection *conn,
 		pkt.info.rwind		= htonl(rxrpc_rx_window_size);
 		pkt.info.jumbo_max	= htonl(rxrpc_rx_jumbo_max);
 		len += sizeof(pkt.ack) + sizeof(pkt.info);
+
+		trace_rxrpc_tx_ack(NULL, chan->last_seq, 0,
+				   RXRPC_ACK_DUPLICATE, 0);
 		break;
 	}
 
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 0b21ed859de7..2c9daeadce87 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -38,12 +38,14 @@ struct rxrpc_pkt_buffer {
 static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
 				 struct rxrpc_pkt_buffer *pkt)
 {
+	rxrpc_serial_t serial;
 	rxrpc_seq_t hard_ack, top, seq;
 	int ix;
 	u32 mtu, jmax;
 	u8 *ackp = pkt->acks;
 
 	/* Barrier against rxrpc_input_data(). */
+	serial = call->ackr_serial;
 	hard_ack = READ_ONCE(call->rx_hard_ack);
 	top = smp_load_acquire(&call->rx_top);
 
@@ -51,7 +53,7 @@ static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
 	pkt->ack.maxSkew	= htons(call->ackr_skew);
 	pkt->ack.firstPacket	= htonl(hard_ack + 1);
 	pkt->ack.previousPacket	= htonl(call->ackr_prev_seq);
-	pkt->ack.serial		= htonl(call->ackr_serial);
+	pkt->ack.serial		= htonl(serial);
 	pkt->ack.reason		= call->ackr_reason;
 	pkt->ack.nAcks		= top - hard_ack;
 
@@ -75,6 +77,9 @@ static size_t rxrpc_fill_out_ack(struct rxrpc_call *call,
 	pkt->ackinfo.rwind	= htonl(call->rx_winsize);
 	pkt->ackinfo.jumbo_max	= htonl(jmax);
 
+	trace_rxrpc_tx_ack(call, hard_ack + 1, serial, call->ackr_reason,
+			   top - hard_ack);
+
 	*ackp++ = 0;
 	*ackp++ = 0;
 	*ackp++ = 0;
