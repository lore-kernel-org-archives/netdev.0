From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 5/5] rxrpc: Use a tracepoint for skb accounting
 debugging
Date: Tue, 23 Aug 2016 16:26:54 +0100
Message-ID: <147196601419.28271.12718931081588758130.stgit@warthog.procyon.org.uk>
References: <147196597852.28271.4071308846084923450.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50594 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752715AbcHWP1d (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 11:27:33 -0400
In-Reply-To: <147196597852.28271.4071308846084923450.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a tracepoint to log various skb accounting points to help in debugging
refcounting errors.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   56 ++++++++++++++++++++++++++++++++++++++
 net/rxrpc/af_rxrpc.c         |    1 +
 net/rxrpc/ar-internal.h      |   45 +++++-------------------------
 net/rxrpc/call_accept.c      |    1 +
 net/rxrpc/call_event.c       |    3 ++
 net/rxrpc/conn_event.c       |    2 +
 net/rxrpc/local_event.c      |    1 +
 net/rxrpc/output.c           |    1 +
 net/rxrpc/recvmsg.c          |    1 +
 net/rxrpc/skbuff.c           |   62 ++++++++++++++++++++++++++++++++++++++++++
 10 files changed, 135 insertions(+), 38 deletions(-)
 create mode 100644 include/trace/events/rxrpc.h

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
new file mode 100644
index 000000000000..15283ee3e41a
--- /dev/null
+++ b/include/trace/events/rxrpc.h
@@ -0,0 +1,56 @@
+/* AF_RXRPC tracepoints
+ *
+ * Copyright (C) 2016 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM rxrpc
+
+#if !defined(_TRACE_RXRPC_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_RXRPC_H
+
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(rxrpc_skb,
+	    TP_PROTO(struct sk_buff *skb, int op, int usage, int mod_count,
+		     const void *where),
+
+	    TP_ARGS(skb, op, usage, mod_count, where),
+
+	    TP_STRUCT__entry(
+		    __field(struct sk_buff *,		skb		)
+		    __field(int,			op		)
+		    __field(int,			usage		)
+		    __field(int,			mod_count	)
+		    __field(const void *,		where		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->skb = skb;
+		    __entry->op = op;
+		    __entry->usage = usage;
+		    __entry->mod_count = mod_count;
+		    __entry->where = where;
+			   ),
+
+	    TP_printk("s=%p %s u=%d m=%d p=%pSR",
+		      __entry->skb,
+		      (__entry->op == 0 ? "NEW" :
+		       __entry->op == 1 ? "SEE" :
+		       __entry->op == 2 ? "GET" :
+		       __entry->op == 3 ? "FRE" :
+		       "PUR"),
+		      __entry->usage,
+		      __entry->mod_count,
+		      __entry->where)
+	    );
+
+#endif /* _TRACE_RXRPC_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 88effadd4b16..c7cf356b42b8 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -22,6 +22,7 @@
 #include <net/net_namespace.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
+#define CREATE_TRACE_POINTS
 #include "ar-internal.h"
 
 MODULE_DESCRIPTION("RxRPC network protocol");
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 648060a5df35..8cb517fbbd23 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -479,6 +479,8 @@ static inline void rxrpc_abort_call(struct rxrpc_call *call, u32 abort_code)
 	write_unlock_bh(&call->state_lock);
 }
 
+#include <trace/events/rxrpc.h>
+
 /*
  * af_rxrpc.c
  */
@@ -752,6 +754,11 @@ int rxrpc_init_server_conn_security(struct rxrpc_connection *);
  * skbuff.c
  */
 void rxrpc_packet_destructor(struct sk_buff *);
+void rxrpc_new_skb(struct sk_buff *);
+void rxrpc_see_skb(struct sk_buff *);
+void rxrpc_get_skb(struct sk_buff *);
+void rxrpc_free_skb(struct sk_buff *);
+void rxrpc_purge_queue(struct sk_buff_head *);
 
 /*
  * sysctl.c
@@ -899,44 +906,6 @@ do {						\
 
 #endif /* __KDEBUGALL */
 
-/*
- * socket buffer accounting / leak finding
- */
-static inline void __rxrpc_new_skb(struct sk_buff *skb, const char *fn)
-{
-	//_net("new skb %p %s [%d]", skb, fn, atomic_read(&rxrpc_n_skbs));
-	//atomic_inc(&rxrpc_n_skbs);
-}
-
-#define rxrpc_new_skb(skb) __rxrpc_new_skb((skb), __func__)
-
-static inline void __rxrpc_kill_skb(struct sk_buff *skb, const char *fn)
-{
-	//_net("kill skb %p %s [%d]", skb, fn, atomic_read(&rxrpc_n_skbs));
-	//atomic_dec(&rxrpc_n_skbs);
-}
-
-#define rxrpc_kill_skb(skb) __rxrpc_kill_skb((skb), __func__)
-
-static inline void __rxrpc_free_skb(struct sk_buff *skb, const char *fn)
-{
-	if (skb) {
-		CHECK_SLAB_OKAY(&skb->users);
-		//_net("free skb %p %s [%d]",
-		//     skb, fn, atomic_read(&rxrpc_n_skbs));
-		//atomic_dec(&rxrpc_n_skbs);
-		kfree_skb(skb);
-	}
-}
-
-#define rxrpc_free_skb(skb) __rxrpc_free_skb((skb), __func__)
-
-static inline void rxrpc_purge_queue(struct sk_buff_head *list)
-{
-	struct sk_buff *skb;
-	while ((skb = skb_dequeue((list))) != NULL)
-		rxrpc_free_skb(skb);
-}
 
 #define rxrpc_get_call(CALL)				\
 do {							\
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 9bae21e66d65..669ac79d3b44 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -203,6 +203,7 @@ void rxrpc_accept_incoming_calls(struct rxrpc_local *local)
 
 	_net("incoming call skb %p", skb);
 
+	rxrpc_see_skb(skb);
 	sp = rxrpc_skb(skb);
 
 	/* Set up a response packet header in case we need it */
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index eaa8035dcb71..3d1267cea9ea 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -407,6 +407,7 @@ static int rxrpc_drain_rx_oos_queue(struct rxrpc_call *call)
 
 	skb = skb_dequeue(&call->rx_oos_queue);
 	if (skb) {
+		rxrpc_see_skb(skb);
 		sp = rxrpc_skb(skb);
 
 		_debug("drain OOS packet %d [%d]",
@@ -427,6 +428,7 @@ static int rxrpc_drain_rx_oos_queue(struct rxrpc_call *call)
 
 			/* find out what the next packet is */
 			skb = skb_peek(&call->rx_oos_queue);
+			rxrpc_see_skb(skb);
 			if (skb)
 				call->rx_first_oos = rxrpc_skb(skb)->hdr.seq;
 			else
@@ -576,6 +578,7 @@ process_further:
 	if (!skb)
 		return -EAGAIN;
 
+	rxrpc_see_skb(skb);
 	_net("deferred skb %p", skb);
 
 	sp = rxrpc_skb(skb);
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index cee0f35bc1cf..c631d926f4db 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -277,6 +277,7 @@ void rxrpc_process_connection(struct work_struct *work)
 	/* go through the conn-level event packets, releasing the ref on this
 	 * connection that each one has when we've finished with it */
 	while ((skb = skb_dequeue(&conn->rx_queue))) {
+		rxrpc_see_skb(skb);
 		ret = rxrpc_process_event(conn, skb, &abort_code);
 		switch (ret) {
 		case -EPROTO:
@@ -365,6 +366,7 @@ void rxrpc_reject_packets(struct rxrpc_local *local)
 	whdr.type = RXRPC_PACKET_TYPE_ABORT;
 
 	while ((skb = skb_dequeue(&local->reject_queue))) {
+		rxrpc_see_skb(skb);
 		sp = rxrpc_skb(skb);
 		switch (sa.sa.sa_family) {
 		case AF_INET:
diff --git a/net/rxrpc/local_event.c b/net/rxrpc/local_event.c
index 31a3f86ef2f6..bcc6593b4cdb 100644
--- a/net/rxrpc/local_event.c
+++ b/net/rxrpc/local_event.c
@@ -93,6 +93,7 @@ void rxrpc_process_local_events(struct rxrpc_local *local)
 	if (skb) {
 		struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 
+		rxrpc_see_skb(skb);
 		_debug("{%d},{%u}", local->debug_id, sp->hdr.type);
 
 		switch (sp->hdr.type) {
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 9e626f1e2668..e3a08d542fb7 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -548,6 +548,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 
 	skb = call->tx_pending;
 	call->tx_pending = NULL;
+	rxrpc_see_skb(skb);
 
 	copied = 0;
 	do {
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 9ed66d533002..b964c2d49a88 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -111,6 +111,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		}
 
 	peek_next_packet:
+		rxrpc_see_skb(skb);
 		sp = rxrpc_skb(skb);
 		call = sp->call;
 		ASSERT(call != NULL);
diff --git a/net/rxrpc/skbuff.c b/net/rxrpc/skbuff.c
index 06c51d4b622d..d28058a97bc1 100644
--- a/net/rxrpc/skbuff.c
+++ b/net/rxrpc/skbuff.c
@@ -163,3 +163,65 @@ void rxrpc_kernel_free_skb(struct sk_buff *skb)
 	rxrpc_free_skb(skb);
 }
 EXPORT_SYMBOL(rxrpc_kernel_free_skb);
+
+/*
+ * Note the existence of a new-to-us socket buffer (allocated or dequeued).
+ */
+void rxrpc_new_skb(struct sk_buff *skb)
+{
+	const void *here = __builtin_return_address(0);
+	int n = atomic_inc_return(&rxrpc_n_skbs);
+	trace_rxrpc_skb(skb, 0, atomic_read(&skb->users), n, here);
+}
+
+/*
+ * Note the re-emergence of a socket buffer from a queue or buffer.
+ */
+void rxrpc_see_skb(struct sk_buff *skb)
+{
+	const void *here = __builtin_return_address(0);
+	if (skb) {
+		int n = atomic_read(&rxrpc_n_skbs);
+		trace_rxrpc_skb(skb, 1, atomic_read(&skb->users), n, here);
+	}
+}
+
+/*
+ * Note the addition of a ref on a socket buffer.
+ */
+void rxrpc_get_skb(struct sk_buff *skb)
+{
+	const void *here = __builtin_return_address(0);
+	int n = atomic_inc_return(&rxrpc_n_skbs);
+	trace_rxrpc_skb(skb, 2, atomic_read(&skb->users), n, here);
+	skb_get(skb);
+}
+
+/*
+ * Note the destruction of a socket buffer.
+ */
+void rxrpc_free_skb(struct sk_buff *skb)
+{
+	const void *here = __builtin_return_address(0);
+	if (skb) {
+		int n;
+		CHECK_SLAB_OKAY(&skb->users);
+		n = atomic_dec_return(&rxrpc_n_skbs);
+		trace_rxrpc_skb(skb, 3, atomic_read(&skb->users), n, here);
+		kfree_skb(skb);
+	}
+}
+
+/*
+ * Clear a queue of socket buffers.
+ */
+void rxrpc_purge_queue(struct sk_buff_head *list)
+{
+	const void *here = __builtin_return_address(0);
+	struct sk_buff *skb;
+	while ((skb = skb_dequeue((list))) != NULL) {
+		int n = atomic_dec_return(&rxrpc_n_skbs);
+		trace_rxrpc_skb(skb, 4, atomic_read(&skb->users), n, here);
+		kfree_skb(skb);
+	}
+}
