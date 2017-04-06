From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 5/7] rxrpc: Trace received aborts
Date: Thu, 06 Apr 2017 11:22:50 +0100
Message-ID: <149147417030.21583.17130513258609085128.stgit@warthog.procyon.org.uk>
References: <149147413410.21583.16278066955827076779.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149147413410.21583.16278066955827076779.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a tracepoint (rxrpc_rx_abort) to record received aborts.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   24 ++++++++++++++++++++++++
 net/rxrpc/input.c            |    4 +++-
 2 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 626af97863e8..85e0148c88a8 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -683,6 +683,30 @@ TRACE_EVENT(rxrpc_rx_ack,
 		      __entry->n_acks)
 	    );
 
+TRACE_EVENT(rxrpc_rx_abort,
+	    TP_PROTO(struct rxrpc_call *call, rxrpc_serial_t serial,
+		     u32 abort_code),
+
+	    TP_ARGS(call, serial, abort_code),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(rxrpc_serial_t,		serial		)
+		    __field(u32,			abort_code	)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->serial = serial;
+		    __entry->abort_code = abort_code;
+			   ),
+
+	    TP_printk("c=%p ABORT %08x ac=%d",
+		      __entry->call,
+		      __entry->serial,
+		      __entry->abort_code)
+	    );
+
 TRACE_EVENT(rxrpc_tx_data,
 	    TP_PROTO(struct rxrpc_call *call, rxrpc_seq_t seq,
 		     rxrpc_serial_t serial, u8 flags, bool retrans, bool lose),
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 3685dbe05a8f..241e989597f2 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -877,7 +877,7 @@ static void rxrpc_input_ackall(struct rxrpc_call *call, struct sk_buff *skb)
 }
 
 /*
- * Process an ABORT packet.
+ * Process an ABORT packet directed at a call.
  */
 static void rxrpc_input_abort(struct rxrpc_call *call, struct sk_buff *skb)
 {
@@ -892,6 +892,8 @@ static void rxrpc_input_abort(struct rxrpc_call *call, struct sk_buff *skb)
 			  &wtmp, sizeof(wtmp)) >= 0)
 		abort_code = ntohl(wtmp);
 
+	trace_rxrpc_rx_abort(call, sp->hdr.serial, abort_code);
+
 	_proto("Rx ABORT %%%u { %x }", sp->hdr.serial, abort_code);
 
 	if (rxrpc_set_call_completion(call, RXRPC_CALL_REMOTELY_ABORTED,
