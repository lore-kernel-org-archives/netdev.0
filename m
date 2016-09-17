From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 05/11] rxrpc: Add a tracepoint to log received ACK
 packets
Date: Sun, 18 Sep 2016 00:22:04 +0100
Message-ID: <147415452488.18436.151884014626979888.stgit@warthog.procyon.org.uk>
References: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49248 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758131AbcIQXWH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:22:07 -0400
In-Reply-To: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a tracepoint to log information from received ACK packets.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   26 ++++++++++++++++++++++++++
 net/rxrpc/input.c            |    2 ++
 2 files changed, 28 insertions(+)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index ffc74b3e5b76..2b19f3fa5174 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -234,6 +234,32 @@ TRACE_EVENT(rxrpc_transmit,
 		      __entry->tx_top - __entry->tx_hard_ack)
 	    );
 
+TRACE_EVENT(rxrpc_rx_ack,
+	    TP_PROTO(struct rxrpc_call *call, rxrpc_seq_t first, u8 reason, u8 n_acks),
+
+	    TP_ARGS(call, first, reason, n_acks),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(rxrpc_seq_t,		first		)
+		    __field(u8,				reason		)
+		    __field(u8,				n_acks		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->first = first;
+		    __entry->reason = reason;
+		    __entry->n_acks = n_acks;
+			   ),
+
+	    TP_printk("c=%p %s f=%08x n=%u",
+		      __entry->call,
+		      rxrpc_acks(__entry->reason),
+		      __entry->first,
+		      __entry->n_acks)
+	    );
+
 #endif /* _TRACE_RXRPC_H */
 
 /* This part must be outside protection */
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index c7eb5104e91a..7b18ca124978 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -440,6 +440,8 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 	hard_ack = first_soft_ack - 1;
 	nr_acks = buf.ack.nAcks;
 
+	trace_rxrpc_rx_ack(call, first_soft_ack, buf.ack.reason, nr_acks);
+
 	_proto("Rx ACK %%%u { m=%hu f=#%u p=#%u s=%%%u r=%s n=%u }",
 	       sp->hdr.serial,
 	       ntohs(buf.ack.maxSkew),
