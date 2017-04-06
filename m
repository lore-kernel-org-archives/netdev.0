From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 7/7] rxrpc: Trace client call connection
Date: Thu, 06 Apr 2017 11:23:03 +0100
Message-ID: <149147418366.21583.2753949064080301068.stgit@warthog.procyon.org.uk>
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

Add a tracepoint (rxrpc_connect_call) to log the combination of rxrpc_call
pointer, afs_call pointer/user data and wire call parameters to make it
easier to match the tracebuffer contents to captured network packets.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   26 ++++++++++++++++++++++++++
 net/rxrpc/conn_client.c      |    1 +
 2 files changed, 27 insertions(+)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 15ba7387c243..29a3d53a4015 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -1162,6 +1162,32 @@ TRACE_EVENT(rxrpc_rx_eproto,
 		      __entry->why)
 	    );
 
+TRACE_EVENT(rxrpc_connect_call,
+	    TP_PROTO(struct rxrpc_call *call),
+
+	    TP_ARGS(call),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(unsigned long,		user_call_ID	)
+		    __field(u32,			cid		)
+		    __field(u32,			call_id		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->user_call_ID = call->user_call_ID;
+		    __entry->cid = call->cid;
+		    __entry->call_id = call->call_id;
+			   ),
+
+	    TP_printk("c=%p u=%p %08x:%08x",
+		      __entry->call,
+		      (void *)__entry->user_call_ID,
+		      __entry->cid,
+		      __entry->call_id)
+	    );
+
 #endif /* _TRACE_RXRPC_H */
 
 /* This part must be outside protection */
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index c3be03e8d098..e8dea0d49e7f 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -550,6 +550,7 @@ static void rxrpc_activate_one_channel(struct rxrpc_connection *conn,
 	call->cid	= conn->proto.cid | channel;
 	call->call_id	= call_id;
 
+	trace_rxrpc_connect_call(call);
 	_net("CONNECT call %08x:%08x as call %d on conn %d",
 	     call->cid, call->call_id, call->debug_id, conn->debug_id);
 
