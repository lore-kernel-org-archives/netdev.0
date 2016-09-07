From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/8] rxrpc: Improve the call tracking tracepoint
Date: Wed, 07 Sep 2016 16:22:47 +0100
Message-ID: <147326176735.26593.8326117095873735903.stgit@warthog.procyon.org.uk>
References: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51308 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757248AbcIGPWt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 11:22:49 -0400
In-Reply-To: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve the call tracking tracepoint by showing more differentiation
between some of the put and get events, including:

  (1) Getting and putting refs for the socket call user ID tree.

  (2) Getting and putting refs for queueing and failing to queue the call
      processor work item.

Note that these aren't necessarily used in this patch, but will be taken
advantage of in future patches.

An enum is added for the event subtype numbers rather than coding them
directly as decimal numbers and a table of 3-letter strings is provided
rather than a sequence of ?: operators.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   11 +++-------
 net/rxrpc/af_rxrpc.c         |    2 +-
 net/rxrpc/ar-internal.h      |   22 ++++++++++++++++++-
 net/rxrpc/call_accept.c      |   10 ++++-----
 net/rxrpc/call_event.c       |    2 +-
 net/rxrpc/call_object.c      |   48 +++++++++++++++++++++++++++---------------
 net/rxrpc/input.c            |    6 +++--
 net/rxrpc/recvmsg.c          |   23 +++++++++++---------
 net/rxrpc/sendmsg.c          |    4 ++--
 net/rxrpc/skbuff.c           |    2 +-
 10 files changed, 79 insertions(+), 51 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index cbe574ea674b..30164896f1f6 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -17,7 +17,8 @@
 #include <linux/tracepoint.h>
 
 TRACE_EVENT(rxrpc_call,
-	    TP_PROTO(struct rxrpc_call *call, int op, int usage, int nskb,
+	    TP_PROTO(struct rxrpc_call *call, enum rxrpc_call_trace op,
+		     int usage, int nskb,
 		     const void *where, const void *aux),
 
 	    TP_ARGS(call, op, usage, nskb, where, aux),
@@ -42,13 +43,7 @@ TRACE_EVENT(rxrpc_call,
 
 	    TP_printk("c=%p %s u=%d s=%d p=%pSR a=%p",
 		      __entry->call,
-		      (__entry->op == 0 ? "NWc" :
-		       __entry->op == 1 ? "NWs" :
-		       __entry->op == 2 ? "SEE" :
-		       __entry->op == 3 ? "GET" :
-		       __entry->op == 4 ? "Gsb" :
-		       __entry->op == 5 ? "PUT" :
-		       "Psb"),
+		      rxrpc_call_traces[__entry->op],
 		      __entry->usage,
 		      __entry->nskb,
 		      __entry->where,
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index b66a9e6f8d04..8356cd003d51 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -296,7 +296,7 @@ void rxrpc_kernel_end_call(struct socket *sock, struct rxrpc_call *call)
 	_enter("%d{%d}", call->debug_id, atomic_read(&call->usage));
 	rxrpc_remove_user_ID(rxrpc_sk(sock->sk), call);
 	rxrpc_purge_queue(&call->knlrecv_queue);
-	rxrpc_put_call(call);
+	rxrpc_put_call(call, rxrpc_call_put);
 }
 EXPORT_SYMBOL(rxrpc_kernel_end_call);
 
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index ad702f9f8d1f..913255a53564 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -508,6 +508,24 @@ struct rxrpc_call {
 	unsigned long		ackr_window[RXRPC_ACKR_WINDOW_ASZ + 1];
 };
 
+enum rxrpc_call_trace {
+	rxrpc_call_new_client,
+	rxrpc_call_new_service,
+	rxrpc_call_queued,
+	rxrpc_call_queued_ref,
+	rxrpc_call_seen,
+	rxrpc_call_got,
+	rxrpc_call_got_skb,
+	rxrpc_call_got_userid,
+	rxrpc_call_put,
+	rxrpc_call_put_skb,
+	rxrpc_call_put_userid,
+	rxrpc_call_put_noqueue,
+	rxrpc_call__nr_trace
+};
+
+extern const char rxrpc_call_traces[rxrpc_call__nr_trace][4];
+
 #include <trace/events/rxrpc.h>
 
 /*
@@ -555,8 +573,8 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *,
 void rxrpc_release_call(struct rxrpc_call *);
 void rxrpc_release_calls_on_socket(struct rxrpc_sock *);
 void rxrpc_see_call(struct rxrpc_call *);
-void rxrpc_get_call(struct rxrpc_call *);
-void rxrpc_put_call(struct rxrpc_call *);
+void rxrpc_get_call(struct rxrpc_call *, enum rxrpc_call_trace);
+void rxrpc_put_call(struct rxrpc_call *, enum rxrpc_call_trace);
 void rxrpc_get_call_for_skb(struct rxrpc_call *, struct sk_buff *);
 void rxrpc_put_call_for_skb(struct rxrpc_call *, struct sk_buff *);
 void __exit rxrpc_destroy_all_calls(void);
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 68a439e30df1..487ae7aa86db 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -115,7 +115,7 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 
 	write_lock(&rx->call_lock);
 	if (!test_and_set_bit(RXRPC_CALL_INIT_ACCEPT, &call->flags)) {
-		rxrpc_get_call(call);
+		rxrpc_get_call(call, rxrpc_call_got);
 
 		spin_lock(&call->conn->state_lock);
 		if (sp->hdr.securityIndex > 0 &&
@@ -155,7 +155,7 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 	_debug("done");
 	read_unlock_bh(&local->services_lock);
 	rxrpc_free_skb(notification);
-	rxrpc_put_call(call);
+	rxrpc_put_call(call, rxrpc_call_put);
 	_leave(" = 0");
 	return 0;
 
@@ -166,11 +166,11 @@ invalid_service:
 	read_lock_bh(&call->state_lock);
 	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
 	    !test_and_set_bit(RXRPC_CALL_EV_RELEASE, &call->events)) {
-		rxrpc_get_call(call);
+		rxrpc_get_call(call, rxrpc_call_got);
 		rxrpc_queue_call(call);
 	}
 	read_unlock_bh(&call->state_lock);
-	rxrpc_put_call(call);
+	rxrpc_put_call(call, rxrpc_call_put);
 	ret = -ECONNREFUSED;
 error:
 	rxrpc_free_skb(notification);
@@ -341,6 +341,7 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 	}
 
 	/* formalise the acceptance */
+	rxrpc_get_call(call, rxrpc_call_got_userid);
 	call->notify_rx = notify_rx;
 	call->user_call_ID = user_call_ID;
 	rb_link_node(&call->sock_node, parent, pp);
@@ -351,7 +352,6 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 		BUG();
 	rxrpc_queue_call(call);
 
-	rxrpc_get_call(call);
 	write_unlock_bh(&call->state_lock);
 	write_unlock(&rx->call_lock);
 	_leave(" = %p{%d}", call, call->debug_id);
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 4754c7fb6242..fee8b6ddb334 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -1246,7 +1246,7 @@ send_message_2:
 kill_ACKs:
 	del_timer_sync(&call->ack_timer);
 	if (test_and_clear_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events))
-		rxrpc_put_call(call);
+		rxrpc_put_call(call, rxrpc_call_put);
 	clear_bit(RXRPC_CALL_EV_ACK, &call->events);
 
 maybe_reschedule:
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 65691742199b..3166b5222435 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -55,6 +55,21 @@ const char *const rxrpc_call_completions[NR__RXRPC_CALL_COMPLETIONS] = {
 	[RXRPC_CALL_NETWORK_ERROR]		= "NetError",
 };
 
+const char rxrpc_call_traces[rxrpc_call__nr_trace][4] = {
+	[rxrpc_call_new_client]		= "NWc",
+	[rxrpc_call_new_service]	= "NWs",
+	[rxrpc_call_queued]		= "QUE",
+	[rxrpc_call_queued_ref]		= "QUR",
+	[rxrpc_call_seen]		= "SEE",
+	[rxrpc_call_got]		= "GOT",
+	[rxrpc_call_got_skb]		= "Gsk",
+	[rxrpc_call_got_userid]		= "Gus",
+	[rxrpc_call_put]		= "PUT",
+	[rxrpc_call_put_skb]		= "Psk",
+	[rxrpc_call_put_userid]		= "Pus",
+	[rxrpc_call_put_noqueue]	= "PNQ",
+};
+
 struct kmem_cache *rxrpc_call_jar;
 LIST_HEAD(rxrpc_calls);
 DEFINE_RWLOCK(rxrpc_call_lock);
@@ -96,7 +111,7 @@ struct rxrpc_call *rxrpc_find_call_by_user_ID(struct rxrpc_sock *rx,
 	return NULL;
 
 found_extant_call:
-	rxrpc_get_call(call);
+	rxrpc_get_call(call, rxrpc_call_got);
 	read_unlock(&rx->call_lock);
 	_leave(" = %p [%d]", call, atomic_read(&call->usage));
 	return call;
@@ -252,8 +267,7 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 			goto found_user_ID_now_present;
 	}
 
-	rxrpc_get_call(call);
-
+	rxrpc_get_call(call, rxrpc_call_got_userid);
 	rb_link_node(&call->sock_node, parent, pp);
 	rb_insert_color(&call->sock_node, &rx->calls);
 	write_unlock(&rx->call_lock);
@@ -275,7 +289,7 @@ error:
 	write_lock(&rx->call_lock);
 	rb_erase(&call->sock_node, &rx->calls);
 	write_unlock(&rx->call_lock);
-	rxrpc_put_call(call);
+	rxrpc_put_call(call, rxrpc_call_put_userid);
 
 	write_lock_bh(&rxrpc_call_lock);
 	list_del_init(&call->link);
@@ -283,7 +297,7 @@ error:
 
 	set_bit(RXRPC_CALL_RELEASED, &call->flags);
 	call->state = RXRPC_CALL_DEAD;
-	rxrpc_put_call(call);
+	rxrpc_put_call(call, rxrpc_call_put);
 	_leave(" = %d", ret);
 	return ERR_PTR(ret);
 
@@ -296,7 +310,7 @@ found_user_ID_now_present:
 	write_unlock(&rx->call_lock);
 	set_bit(RXRPC_CALL_RELEASED, &call->flags);
 	call->state = RXRPC_CALL_DEAD;
-	rxrpc_put_call(call);
+	rxrpc_put_call(call, rxrpc_call_put);
 	_leave(" = -EEXIST [%p]", call);
 	return ERR_PTR(-EEXIST);
 }
@@ -322,8 +336,8 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	if (!candidate)
 		return ERR_PTR(-EBUSY);
 
-	trace_rxrpc_call(candidate, 1, atomic_read(&candidate->usage),
-			 0, here, NULL);
+	trace_rxrpc_call(candidate, rxrpc_call_new_service,
+			 atomic_read(&candidate->usage), 0, here, NULL);
 
 	chan = sp->hdr.cid & RXRPC_CHANNELMASK;
 	candidate->socket	= rx;
@@ -358,7 +372,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 			read_unlock(&call->state_lock);
 			goto aborted_call;
 		default:
-			rxrpc_get_call(call);
+			rxrpc_get_call(call, rxrpc_call_got);
 			read_unlock(&call->state_lock);
 			goto extant_call;
 		}
@@ -447,20 +461,20 @@ void rxrpc_see_call(struct rxrpc_call *call)
 		int n = atomic_read(&call->usage);
 		int m = atomic_read(&call->skb_count);
 
-		trace_rxrpc_call(call, 2, n, m, here, 0);
+		trace_rxrpc_call(call, rxrpc_call_seen, n, m, here, NULL);
 	}
 }
 
 /*
  * Note the addition of a ref on a call.
  */
-void rxrpc_get_call(struct rxrpc_call *call)
+void rxrpc_get_call(struct rxrpc_call *call, enum rxrpc_call_trace op)
 {
 	const void *here = __builtin_return_address(0);
 	int n = atomic_inc_return(&call->usage);
 	int m = atomic_read(&call->skb_count);
 
-	trace_rxrpc_call(call, 3, n, m, here, 0);
+	trace_rxrpc_call(call, op, n, m, here, NULL);
 }
 
 /*
@@ -472,7 +486,7 @@ void rxrpc_get_call_for_skb(struct rxrpc_call *call, struct sk_buff *skb)
 	int n = atomic_inc_return(&call->usage);
 	int m = atomic_inc_return(&call->skb_count);
 
-	trace_rxrpc_call(call, 4, n, m, here, skb);
+	trace_rxrpc_call(call, rxrpc_call_got_skb, n, m, here, skb);
 }
 
 /*
@@ -575,7 +589,7 @@ static void rxrpc_dead_call_expired(unsigned long _call)
 	write_lock_bh(&call->state_lock);
 	call->state = RXRPC_CALL_DEAD;
 	write_unlock_bh(&call->state_lock);
-	rxrpc_put_call(call);
+	rxrpc_put_call(call, rxrpc_call_put);
 }
 
 /*
@@ -632,7 +646,7 @@ void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
 /*
  * release a call
  */
-void rxrpc_put_call(struct rxrpc_call *call)
+void rxrpc_put_call(struct rxrpc_call *call, enum rxrpc_call_trace op)
 {
 	const void *here = __builtin_return_address(0);
 	int n, m;
@@ -641,7 +655,7 @@ void rxrpc_put_call(struct rxrpc_call *call)
 
 	n = atomic_dec_return(&call->usage);
 	m = atomic_read(&call->skb_count);
-	trace_rxrpc_call(call, 5, n, m, here, NULL);
+	trace_rxrpc_call(call, op, n, m, here, NULL);
 	ASSERTCMP(n, >=, 0);
 	if (n == 0) {
 		_debug("call %d dead", call->debug_id);
@@ -661,7 +675,7 @@ void rxrpc_put_call_for_skb(struct rxrpc_call *call, struct sk_buff *skb)
 
 	n = atomic_dec_return(&call->usage);
 	m = atomic_dec_return(&call->skb_count);
-	trace_rxrpc_call(call, 6, n, m, here, skb);
+	trace_rxrpc_call(call, rxrpc_call_put_skb, n, m, here, skb);
 	ASSERTCMP(n, >=, 0);
 	if (n == 0) {
 		_debug("call %d dead", call->debug_id);
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 72f016cfaaf5..f7239a6f9181 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -537,7 +537,7 @@ static void rxrpc_post_packet_to_call(struct rxrpc_call *call,
 	}
 
 	read_unlock(&call->state_lock);
-	rxrpc_get_call(call);
+	rxrpc_get_call(call, rxrpc_call_got);
 
 	if (sp->hdr.type == RXRPC_PACKET_TYPE_DATA &&
 	    sp->hdr.flags & RXRPC_JUMBO_PACKET)
@@ -545,12 +545,12 @@ static void rxrpc_post_packet_to_call(struct rxrpc_call *call,
 	else
 		rxrpc_fast_process_packet(call, skb);
 
-	rxrpc_put_call(call);
+	rxrpc_put_call(call, rxrpc_call_put);
 	goto done;
 
 resend_final_ack:
 	_debug("final ack again");
-	rxrpc_get_call(call);
+	rxrpc_get_call(call, rxrpc_call_got);
 	set_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events);
 	rxrpc_queue_call(call);
 	goto free_unlock;
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 0ab7b334bab1..97f8ee76c67c 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -79,7 +79,8 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 			if (rx->sk.sk_state != RXRPC_SERVER_LISTENING) {
 				release_sock(&rx->sk);
 				if (continue_call)
-					rxrpc_put_call(continue_call);
+					rxrpc_put_call(continue_call,
+						       rxrpc_call_put);
 				return -ENODATA;
 			}
 		}
@@ -137,13 +138,13 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 			if (call != continue_call ||
 			    skb->mark != RXRPC_SKB_MARK_DATA) {
 				release_sock(&rx->sk);
-				rxrpc_put_call(continue_call);
+				rxrpc_put_call(continue_call, rxrpc_call_put);
 				_leave(" = %d [noncont]", copied);
 				return copied;
 			}
 		}
 
-		rxrpc_get_call(call);
+		rxrpc_get_call(call, rxrpc_call_got);
 
 		/* copy the peer address and timestamp */
 		if (!continue_call) {
@@ -233,7 +234,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		if (!continue_call)
 			continue_call = sp->call;
 		else
-			rxrpc_put_call(call);
+			rxrpc_put_call(call, rxrpc_call_put);
 		call = NULL;
 
 		if (flags & MSG_PEEK) {
@@ -255,9 +256,9 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 out:
 	release_sock(&rx->sk);
 	if (call)
-		rxrpc_put_call(call);
+		rxrpc_put_call(call, rxrpc_call_put);
 	if (continue_call)
-		rxrpc_put_call(continue_call);
+		rxrpc_put_call(continue_call, rxrpc_call_put);
 	_leave(" = %d [data]", copied);
 	return copied;
 
@@ -341,18 +342,18 @@ terminal_message:
 	}
 
 	release_sock(&rx->sk);
-	rxrpc_put_call(call);
+	rxrpc_put_call(call, rxrpc_call_put);
 	if (continue_call)
-		rxrpc_put_call(continue_call);
+		rxrpc_put_call(continue_call, rxrpc_call_put);
 	_leave(" = %d", ret);
 	return ret;
 
 copy_error:
 	_debug("copy error");
 	release_sock(&rx->sk);
-	rxrpc_put_call(call);
+	rxrpc_put_call(call, rxrpc_call_put);
 	if (continue_call)
-		rxrpc_put_call(continue_call);
+		rxrpc_put_call(continue_call, rxrpc_call_put);
 	_leave(" = %d", ret);
 	return ret;
 
@@ -361,7 +362,7 @@ wait_interrupted:
 wait_error:
 	finish_wait(sk_sleep(&rx->sk), &wait);
 	if (continue_call)
-		rxrpc_put_call(continue_call);
+		rxrpc_put_call(continue_call, rxrpc_call_put);
 	if (copied)
 		copied = ret;
 	_leave(" = %d [waitfail %d]", copied, ret);
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 7376794a0308..803078bea507 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -534,7 +534,7 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 		call = rxrpc_accept_call(rx, user_call_ID, NULL);
 		if (IS_ERR(call))
 			return PTR_ERR(call);
-		rxrpc_put_call(call);
+		rxrpc_put_call(call, rxrpc_call_put);
 		return 0;
 	}
 
@@ -573,7 +573,7 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 		ret = rxrpc_send_data(rx, call, msg, len);
 	}
 
-	rxrpc_put_call(call);
+	rxrpc_put_call(call, rxrpc_call_put);
 	_leave(" = %d", ret);
 	return ret;
 }
diff --git a/net/rxrpc/skbuff.c b/net/rxrpc/skbuff.c
index a546a2ba6341..c0613ab6d2d5 100644
--- a/net/rxrpc/skbuff.c
+++ b/net/rxrpc/skbuff.c
@@ -35,7 +35,7 @@ static void rxrpc_request_final_ACK(struct rxrpc_call *call)
 
 		/* get an extra ref on the call for the final-ACK generator to
 		 * release */
-		rxrpc_get_call(call);
+		rxrpc_get_call(call, rxrpc_call_got);
 		set_bit(RXRPC_CALL_EV_ACK_FINAL, &call->events);
 		if (try_to_del_timer_sync(&call->ack_timer) >= 0)
 			rxrpc_queue_call(call);
