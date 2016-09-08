From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 5/7] rxrpc: Add tracepoints to record received
 packets and end of data_ready
Date: Thu, 08 Sep 2016 12:44:04 +0100
Message-ID: <147333504430.5646.12583473529213491493.stgit@warthog.procyon.org.uk>
References: <147333500815.5646.1897433750795776938.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147333500815.5646.1897433750795776938.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add two tracepoints:

 (1) Record the RxRPC protocol header of packets retrieved from the UDP
     socket by the data_ready handler.

 (2) Record the outcome of the data_ready handler.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   38 ++++++++++++++++++++++++++++++++++++++
 net/rxrpc/input.c            |    8 ++++++--
 2 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 6b06cf050bc0..ea3b10ed91a8 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -80,6 +80,44 @@ TRACE_EVENT(rxrpc_skb,
 		      __entry->where)
 	    );
 
+TRACE_EVENT(rxrpc_rx_packet,
+	    TP_PROTO(struct rxrpc_skb_priv *sp),
+
+	    TP_ARGS(sp),
+
+	    TP_STRUCT__entry(
+		    __field_struct(struct rxrpc_host_header,	hdr		)
+			     ),
+
+	    TP_fast_assign(
+		    memcpy(&__entry->hdr, &sp->hdr, sizeof(__entry->hdr));
+			   ),
+
+	    TP_printk("%08x:%08x:%08x:%04x %08x %08x %02x %02x",
+		      __entry->hdr.epoch, __entry->hdr.cid,
+		      __entry->hdr.callNumber, __entry->hdr.serviceId,
+		      __entry->hdr.serial, __entry->hdr.seq,
+		      __entry->hdr.type, __entry->hdr.flags)
+	    );
+
+TRACE_EVENT(rxrpc_rx_done,
+	    TP_PROTO(int result, int abort_code),
+
+	    TP_ARGS(result, abort_code),
+
+	    TP_STRUCT__entry(
+		    __field(int,			result		)
+		    __field(int,			abort_code	)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->result = result;
+		    __entry->abort_code = abort_code;
+			   ),
+
+	    TP_printk("r=%d a=%d", __entry->result, __entry->abort_code)
+	    );
+
 TRACE_EVENT(rxrpc_abort,
 	    TP_PROTO(const char *why, u32 cid, u32 call_id, rxrpc_seq_t seq,
 		     int abort_code, int error),
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 8e624109750a..6c4b7df05e95 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -683,6 +683,7 @@ void rxrpc_data_ready(struct sock *sk)
 	/* dig out the RxRPC connection details */
 	if (rxrpc_extract_header(sp, skb) < 0)
 		goto bad_message;
+	trace_rxrpc_rx_packet(sp);
 
 	_net("Rx RxRPC %s ep=%x call=%x:%x",
 	     sp->hdr.flags & RXRPC_CLIENT_INITIATED ? "ToServer" : "ToClient",
@@ -767,6 +768,7 @@ discard_unlock:
 out_unlock:
 	rcu_read_unlock();
 out:
+	trace_rxrpc_rx_done(0, 0);
 	return;
 
 cant_route_call:
@@ -780,7 +782,7 @@ cant_route_call:
 			skb_queue_tail(&local->accept_queue, skb);
 			rxrpc_queue_work(&local->processor);
 			_leave(" [incoming]");
-			return;
+			goto out;
 		}
 		skb->priority = RX_INVALID_OPERATION;
 	} else {
@@ -789,7 +791,7 @@ cant_route_call:
 
 	if (sp->hdr.type != RXRPC_PACKET_TYPE_ABORT) {
 		_debug("reject type %d",sp->hdr.type);
-		rxrpc_reject_packet(local, skb);
+		goto reject_packet;
 	} else {
 		rxrpc_free_skb(skb);
 	}
@@ -798,6 +800,8 @@ cant_route_call:
 
 bad_message:
 	skb->priority = RX_PROTOCOL_ERROR;
+reject_packet:
+	trace_rxrpc_rx_done(skb->mark, skb->priority);
 	rxrpc_reject_packet(local, skb);
 	_leave(" [badmsg]");
 }
