From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 4/7] rxrpc: Remove skb_count from struct rxrpc_call
Date: Thu, 08 Sep 2016 12:43:57 +0100
Message-ID: <147333503696.5646.7766598163305325611.stgit@warthog.procyon.org.uk>
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

Remove the sk_buff count from the rxrpc_call struct as it's less useful
once we stop queueing sk_buffs.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   10 +++-------
 net/rxrpc/ar-internal.h      |    1 -
 net/rxrpc/call_object.c      |   34 ++++++++++++----------------------
 3 files changed, 15 insertions(+), 30 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 85ee035774ae..6b06cf050bc0 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -18,16 +18,14 @@
 
 TRACE_EVENT(rxrpc_call,
 	    TP_PROTO(struct rxrpc_call *call, enum rxrpc_call_trace op,
-		     int usage, int nskb,
-		     const void *where, const void *aux),
+		     int usage, const void *where, const void *aux),
 
-	    TP_ARGS(call, op, usage, nskb, where, aux),
+	    TP_ARGS(call, op, usage, where, aux),
 
 	    TP_STRUCT__entry(
 		    __field(struct rxrpc_call *,	call		)
 		    __field(int,			op		)
 		    __field(int,			usage		)
-		    __field(int,			nskb		)
 		    __field(const void *,		where		)
 		    __field(const void *,		aux		)
 			     ),
@@ -36,16 +34,14 @@ TRACE_EVENT(rxrpc_call,
 		    __entry->call = call;
 		    __entry->op = op;
 		    __entry->usage = usage;
-		    __entry->nskb = nskb;
 		    __entry->where = where;
 		    __entry->aux = aux;
 			   ),
 
-	    TP_printk("c=%p %s u=%d s=%d p=%pSR a=%p",
+	    TP_printk("c=%p %s u=%d sp=%pSR a=%p",
 		      __entry->call,
 		      rxrpc_call_traces[__entry->op],
 		      __entry->usage,
-		      __entry->nskb,
 		      __entry->where,
 		      __entry->aux)
 	    );
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index fd438dc93ee9..027791261768 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -467,7 +467,6 @@ struct rxrpc_call {
 	enum rxrpc_call_state	state;		/* current state of call */
 	enum rxrpc_call_completion completion;	/* Call completion condition */
 	atomic_t		usage;
-	atomic_t		skb_count;	/* Outstanding packets on this call */
 	atomic_t		sequence;	/* Tx data packet sequence counter */
 	u16			service_id;	/* service ID */
 	u8			security_ix;	/* Security type */
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 9efd9b0b0bdf..f843397e03b6 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -232,9 +232,8 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 		return call;
 	}
 
-	trace_rxrpc_call(call, rxrpc_call_new_client,
-			 atomic_read(&call->usage), 0,
-			 here, (const void *)user_call_ID);
+	trace_rxrpc_call(call, 0, atomic_read(&call->usage), here,
+			 (const void *)user_call_ID);
 
 	/* Publish the call, even though it is incompletely set up as yet */
 	call->user_call_ID = user_call_ID;
@@ -325,7 +324,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 		return ERR_PTR(-EBUSY);
 
 	trace_rxrpc_call(candidate, rxrpc_call_new_service,
-			 atomic_read(&candidate->usage), 0, here, NULL);
+			 atomic_read(&candidate->usage), here, NULL);
 
 	chan = sp->hdr.cid & RXRPC_CHANNELMASK;
 	candidate->conn		= conn;
@@ -446,11 +445,10 @@ bool rxrpc_queue_call(struct rxrpc_call *call)
 {
 	const void *here = __builtin_return_address(0);
 	int n = __atomic_add_unless(&call->usage, 1, 0);
-	int m = atomic_read(&call->skb_count);
 	if (n == 0)
 		return false;
 	if (rxrpc_queue_work(&call->processor))
-		trace_rxrpc_call(call, rxrpc_call_queued, n + 1, m, here, NULL);
+		trace_rxrpc_call(call, rxrpc_call_queued, n + 1, here, NULL);
 	else
 		rxrpc_put_call(call, rxrpc_call_put_noqueue);
 	return true;
@@ -463,10 +461,9 @@ bool __rxrpc_queue_call(struct rxrpc_call *call)
 {
 	const void *here = __builtin_return_address(0);
 	int n = atomic_read(&call->usage);
-	int m = atomic_read(&call->skb_count);
 	ASSERTCMP(n, >=, 1);
 	if (rxrpc_queue_work(&call->processor))
-		trace_rxrpc_call(call, rxrpc_call_queued_ref, n, m, here, NULL);
+		trace_rxrpc_call(call, rxrpc_call_queued_ref, n, here, NULL);
 	else
 		rxrpc_put_call(call, rxrpc_call_put_noqueue);
 	return true;
@@ -480,9 +477,8 @@ void rxrpc_see_call(struct rxrpc_call *call)
 	const void *here = __builtin_return_address(0);
 	if (call) {
 		int n = atomic_read(&call->usage);
-		int m = atomic_read(&call->skb_count);
 
-		trace_rxrpc_call(call, rxrpc_call_seen, n, m, here, NULL);
+		trace_rxrpc_call(call, rxrpc_call_seen, n, here, NULL);
 	}
 }
 
@@ -493,9 +489,8 @@ void rxrpc_get_call(struct rxrpc_call *call, enum rxrpc_call_trace op)
 {
 	const void *here = __builtin_return_address(0);
 	int n = atomic_inc_return(&call->usage);
-	int m = atomic_read(&call->skb_count);
 
-	trace_rxrpc_call(call, op, n, m, here, NULL);
+	trace_rxrpc_call(call, op, n, here, NULL);
 }
 
 /*
@@ -505,9 +500,8 @@ void rxrpc_get_call_for_skb(struct rxrpc_call *call, struct sk_buff *skb)
 {
 	const void *here = __builtin_return_address(0);
 	int n = atomic_inc_return(&call->usage);
-	int m = atomic_inc_return(&call->skb_count);
 
-	trace_rxrpc_call(call, rxrpc_call_got_skb, n, m, here, skb);
+	trace_rxrpc_call(call, rxrpc_call_got_skb, n, here, skb);
 }
 
 /*
@@ -642,17 +636,15 @@ void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
 void rxrpc_put_call(struct rxrpc_call *call, enum rxrpc_call_trace op)
 {
 	const void *here = __builtin_return_address(0);
-	int n, m;
+	int n;
 
 	ASSERT(call != NULL);
 
 	n = atomic_dec_return(&call->usage);
-	m = atomic_read(&call->skb_count);
-	trace_rxrpc_call(call, op, n, m, here, NULL);
+	trace_rxrpc_call(call, op, n, here, NULL);
 	ASSERTCMP(n, >=, 0);
 	if (n == 0) {
 		_debug("call %d dead", call->debug_id);
-		WARN_ON(m != 0);
 		rxrpc_cleanup_call(call);
 	}
 }
@@ -663,15 +655,13 @@ void rxrpc_put_call(struct rxrpc_call *call, enum rxrpc_call_trace op)
 void rxrpc_put_call_for_skb(struct rxrpc_call *call, struct sk_buff *skb)
 {
 	const void *here = __builtin_return_address(0);
-	int n, m;
+	int n;
 
 	n = atomic_dec_return(&call->usage);
-	m = atomic_dec_return(&call->skb_count);
-	trace_rxrpc_call(call, rxrpc_call_put_skb, n, m, here, skb);
+	trace_rxrpc_call(call, rxrpc_call_put_skb, n, here, skb);
 	ASSERTCMP(n, >=, 0);
 	if (n == 0) {
 		_debug("call %d dead", call->debug_id);
-		WARN_ON(m != 0);
 		rxrpc_cleanup_call(call);
 	}
 }
