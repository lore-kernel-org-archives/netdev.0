From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 6/7] rxrpc: Trace changes in a call's receive
 window size
Date: Thu, 06 Apr 2017 11:22:57 +0100
Message-ID: <149147417703.21583.5740745212381414591.stgit@warthog.procyon.org.uk>
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

Add a tracepoint (rxrpc_rx_rwind_change) to log changes in a call's receive
window size as imposed by the peer through an ACK packet.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   27 +++++++++++++++++++++++++++
 net/rxrpc/input.c            |    2 ++
 2 files changed, 29 insertions(+)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 85e0148c88a8..15ba7387c243 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -707,6 +707,33 @@ TRACE_EVENT(rxrpc_rx_abort,
 		      __entry->abort_code)
 	    );
 
+TRACE_EVENT(rxrpc_rx_rwind_change,
+	    TP_PROTO(struct rxrpc_call *call, rxrpc_serial_t serial,
+		     u32 rwind, bool wake),
+
+	    TP_ARGS(call, serial, rwind, wake),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(rxrpc_serial_t,		serial		)
+		    __field(u32,			rwind		)
+		    __field(bool,			wake		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->serial = serial;
+		    __entry->rwind = rwind;
+		    __entry->wake = wake;
+			   ),
+
+	    TP_printk("c=%p %08x rw=%u%s",
+		      __entry->call,
+		      __entry->serial,
+		      __entry->rwind,
+		      __entry->wake ? " wake" : "")
+	    );
+
 TRACE_EVENT(rxrpc_tx_data,
 	    TP_PROTO(struct rxrpc_call *call, rxrpc_seq_t seq,
 		     rxrpc_serial_t serial, u8 flags, bool retrans, bool lose),
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 241e989597f2..45dba732a3b4 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -665,6 +665,8 @@ static void rxrpc_input_ackinfo(struct rxrpc_call *call, struct sk_buff *skb,
 			rwind = RXRPC_RXTX_BUFF_SIZE - 1;
 		if (rwind > call->tx_winsize)
 			wake = true;
+		trace_rxrpc_rx_rwind_change(call, sp->hdr.serial,
+					    ntohl(ackinfo->rwind), wake);
 		call->tx_winsize = rwind;
 	}
 
