From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/8] AF_RXRPC: Use own workqueues
Date: Wed, 11 Apr 2007 20:10:02 +0100
Message-ID: <20070411191002.15499.54512.stgit@warthog.cambridge.redhat.com>
References: <20070411190956.15499.55352.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070411190956.15499.55352.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the AF_RXRPC module use its own workqueues with their own per-CPU threads.
Currently it uses keventd to do the following tasks, amongst others:

 (*) Security negotiation

 (*) Packet encryption and decryption

 (*) Packet resending

 (*) ACK, abort and busy packet generation

 (*) Timeout handling

 (*) Missing packet catchup

 (*) Parts of incoming call management

 (*) Destruction of structures we've finished with

Some of these conflict with AFS's use of keventd, however, and can lead to
effective deadlock of resources.  Having discussed this, it has been suggested
that encryption and decryption shouldn't be done in keventd (that's not
unreasonable - it is potentially quite slow), and so the AF_RXRPC service is
given its own threads rather than AFS.

It might be useful to consider using the rpciod threads for this, if they were
separated out from the SunRPC module.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c      |   17 ++++++++++++++---
 net/rxrpc/ar-accept.c     |   12 ++++++------
 net/rxrpc/ar-ack.c        |   10 +++++-----
 net/rxrpc/ar-call.c       |   16 ++++++++--------
 net/rxrpc/ar-connection.c |    8 ++++----
 net/rxrpc/ar-connevent.c  |   20 ++++++++++++++++++--
 net/rxrpc/ar-error.c      |    6 +++---
 net/rxrpc/ar-input.c      |   24 ++++++++++++------------
 net/rxrpc/ar-internal.h   |   28 ++++++++++++----------------
 net/rxrpc/ar-local.c      |    2 +-
 net/rxrpc/ar-output.c     |    4 ++--
 net/rxrpc/ar-peer.c       |    2 +-
 net/rxrpc/ar-recvmsg.c    |    2 +-
 net/rxrpc/ar-skbuff.c     |    2 +-
 net/rxrpc/ar-transport.c  |    8 ++++----
 15 files changed, 92 insertions(+), 69 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index fb35998..115ad19 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -41,6 +41,8 @@ atomic_t rxrpc_debug_id;
 /* count of skbs currently in use */
 atomic_t rxrpc_n_skbs;
 
+struct workqueue_struct *rxrpc_workqueue;
+
 static void rxrpc_sock_destructor(struct sock *);
 
 /*
@@ -688,7 +690,7 @@ static int rxrpc_release_sock(struct sock *sk)
 
 	/* try to flush out this socket */
 	rxrpc_release_calls_on_socket(rx);
-	flush_scheduled_work();
+	flush_workqueue(rxrpc_workqueue);
 	rxrpc_purge_queue(&sk->sk_receive_queue);
 
 	if (rx->conn) {
@@ -785,15 +787,21 @@ static int __init af_rxrpc_init(void)
 
 	rxrpc_epoch = htonl(xtime.tv_sec);
 
+	ret = -ENOMEM;
 	rxrpc_call_jar = kmem_cache_create(
 		"rxrpc_call_jar", sizeof(struct rxrpc_call), 0,
 		SLAB_HWCACHE_ALIGN, NULL, NULL);
 	if (!rxrpc_call_jar) {
 		printk(KERN_NOTICE "RxRPC: Failed to allocate call jar\n");
-		ret = -ENOMEM;
 		goto error_call_jar;
 	}
 
+	rxrpc_workqueue = create_workqueue("krxrpcd");
+	if (!rxrpc_workqueue) {
+		printk(KERN_NOTICE "RxRPC: Failed to allocate work queue\n");
+		goto error_work_queue;
+	}
+
 	ret = proto_register(&rxrpc_proto, 1);
         if (ret < 0) {
                 printk(KERN_CRIT "RxRPC: Cannot register protocol\n");
@@ -831,6 +839,8 @@ error_key_type:
 error_sock:
 	proto_unregister(&rxrpc_proto);
 error_proto:
+	destroy_workqueue(rxrpc_workqueue);
+error_work_queue:
 	kmem_cache_destroy(rxrpc_call_jar);
 error_call_jar:
 	return ret;
@@ -855,9 +865,10 @@ static void __exit af_rxrpc_exit(void)
 	ASSERTCMP(atomic_read(&rxrpc_n_skbs), ==, 0);
 
 	_debug("flush scheduled work");
-	flush_scheduled_work();
+	flush_workqueue(rxrpc_workqueue);
 	proc_net_remove("rxrpc_conns");
 	proc_net_remove("rxrpc_calls");
+	destroy_workqueue(rxrpc_workqueue);
 	kmem_cache_destroy(rxrpc_call_jar);
 	_leave("");
 }
diff --git a/net/rxrpc/ar-accept.c b/net/rxrpc/ar-accept.c
index 405092d..73243ab 100644
--- a/net/rxrpc/ar-accept.c
+++ b/net/rxrpc/ar-accept.c
@@ -139,7 +139,7 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 			call->conn->state = RXRPC_CONN_SERVER_CHALLENGING;
 			atomic_inc(&call->conn->usage);
 			set_bit(RXRPC_CONN_CHALLENGE, &call->conn->events);
-			schedule_work(&call->conn->processor);
+			rxrpc_queue_conn(call->conn);
 		} else {
 			_debug("conn ready");
 			call->state = RXRPC_CALL_SERVER_ACCEPTING;
@@ -183,7 +183,7 @@ invalid_service:
 	if (!test_bit(RXRPC_CALL_RELEASE, &call->flags) &&
 	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events)) {
 		rxrpc_get_call(call);
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	}
 	read_unlock_bh(&call->state_lock);
 	rxrpc_put_call(call);
@@ -375,7 +375,7 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 		BUG();
 	if (test_and_set_bit(RXRPC_CALL_ACCEPTED, &call->events))
 		BUG();
-	schedule_work(&call->processor);
+	rxrpc_queue_call(call);
 
 	rxrpc_get_call(call);
 	write_unlock_bh(&call->state_lock);
@@ -390,7 +390,7 @@ out_release:
 	_debug("release %p", call);
 	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
 	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 out_discard:
 	write_unlock_bh(&call->state_lock);
 	_debug("discard %p", call);
@@ -429,7 +429,7 @@ int rxrpc_reject_call(struct rxrpc_sock *rx)
 	case RXRPC_CALL_SERVER_ACCEPTING:
 		call->state = RXRPC_CALL_SERVER_BUSY;
 		if (test_and_set_bit(RXRPC_CALL_REJECT_BUSY, &call->events))
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		ret = 0;
 		goto out_release;
 	case RXRPC_CALL_REMOTELY_ABORTED:
@@ -453,7 +453,7 @@ out_release:
 	_debug("release %p", call);
 	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
 	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 out_discard:
 	write_unlock_bh(&call->state_lock);
 	_debug("discard %p", call);
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 8f7764e..fc07a92 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -113,7 +113,7 @@ cancel_timer:
 	read_lock_bh(&call->state_lock);
 	if (call->state <= RXRPC_CALL_COMPLETE &&
 	    !test_and_set_bit(RXRPC_CALL_ACK, &call->events))
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	read_unlock_bh(&call->state_lock);
 }
 
@@ -1166,7 +1166,7 @@ send_message_2:
 		_debug("sendmsg failed: %d", ret);
 		read_lock_bh(&call->state_lock);
 		if (call->state < RXRPC_CALL_DEAD)
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		read_unlock_bh(&call->state_lock);
 		goto error;
 	}
@@ -1210,7 +1210,7 @@ maybe_reschedule:
 	if (call->events || !skb_queue_empty(&call->rx_queue)) {
 		read_lock_bh(&call->state_lock);
 		if (call->state < RXRPC_CALL_DEAD)
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		read_unlock_bh(&call->state_lock);
 	}
 
@@ -1224,7 +1224,7 @@ maybe_reschedule:
 		read_lock_bh(&call->state_lock);
 		if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
 		    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		read_unlock_bh(&call->state_lock);
 	}
 
@@ -1238,7 +1238,7 @@ error:
 	 * work pending bit and the work item being processed again */
 	if (call->events && !work_pending(&call->processor)) {
 		_debug("jumpstart %x", ntohl(call->conn->cid));
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	}
 
 	_leave("");
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index ac31cce..1d7698a 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -264,7 +264,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 		switch (call->state) {
 		case RXRPC_CALL_LOCALLY_ABORTED:
 			if (!test_and_set_bit(RXRPC_CALL_ABORT, &call->events))
-				schedule_work(&call->processor);
+				rxrpc_queue_call(call);
 		case RXRPC_CALL_REMOTELY_ABORTED:
 			read_unlock(&call->state_lock);
 			goto aborted_call;
@@ -455,7 +455,7 @@ void rxrpc_release_call(struct rxrpc_call *call)
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
 		call->abort_code = RX_CALL_DEAD;
 		set_bit(RXRPC_CALL_ABORT, &call->events);
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	}
 	write_unlock(&call->state_lock);
 	write_unlock_bh(&call->conn->lock);
@@ -538,7 +538,7 @@ static void rxrpc_mark_call_released(struct rxrpc_call *call)
 		if (!test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
 			sched = true;
 		if (sched)
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 	}
 	write_unlock(&call->state_lock);
 }
@@ -588,7 +588,7 @@ void __rxrpc_put_call(struct rxrpc_call *call)
 	if (atomic_dec_and_test(&call->usage)) {
 		_debug("call %d dead", call->debug_id);
 		ASSERTCMP(call->state, ==, RXRPC_CALL_DEAD);
-		schedule_work(&call->destroyer);
+		rxrpc_queue_work(&call->destroyer);
 	}
 	_leave("");
 }
@@ -613,7 +613,7 @@ static void rxrpc_cleanup_call(struct rxrpc_call *call)
 	ASSERTCMP(call->events, ==, 0);
 	if (work_pending(&call->processor)) {
 		_debug("defer destroy");
-		schedule_work(&call->destroyer);
+		rxrpc_queue_work(&call->destroyer);
 		return;
 	}
 
@@ -742,7 +742,7 @@ static void rxrpc_call_life_expired(unsigned long _call)
 	read_lock_bh(&call->state_lock);
 	if (call->state < RXRPC_CALL_COMPLETE) {
 		set_bit(RXRPC_CALL_LIFE_TIMER, &call->events);
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	}
 	read_unlock_bh(&call->state_lock);
 }
@@ -763,7 +763,7 @@ static void rxrpc_resend_time_expired(unsigned long _call)
 	clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
 	if (call->state < RXRPC_CALL_COMPLETE &&
 	    !test_and_set_bit(RXRPC_CALL_RESEND_TIMER, &call->events))
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	read_unlock_bh(&call->state_lock);
 }
 
@@ -782,6 +782,6 @@ static void rxrpc_ack_time_expired(unsigned long _call)
 	read_lock_bh(&call->state_lock);
 	if (call->state < RXRPC_CALL_COMPLETE &&
 	    !test_and_set_bit(RXRPC_CALL_ACK, &call->events))
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	read_unlock_bh(&call->state_lock);
 }
diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index 093af56..2d0efaa 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -778,7 +778,7 @@ void rxrpc_put_connection(struct rxrpc_connection *conn)
 	conn->put_time = xtime.tv_sec;
 	if (atomic_dec_and_test(&conn->usage)) {
 		_debug("zombie");
-		schedule_delayed_work(&rxrpc_connection_reap, 0);
+		rxrpc_queue_delayed_work(&rxrpc_connection_reap, 0);
 	}
 
 	_leave("");
@@ -862,8 +862,8 @@ void rxrpc_connection_reaper(struct work_struct *work)
 	if (earliest != ULONG_MAX) {
 		_debug("reschedule reaper %ld", (long) earliest - now);
 		ASSERTCMP(earliest, >, now);
-		schedule_delayed_work(&rxrpc_connection_reap,
-				      (earliest - now) * HZ);
+		rxrpc_queue_delayed_work(&rxrpc_connection_reap,
+					 (earliest - now) * HZ);
 	}
 
 	/* then destroy all those pulled out */
@@ -889,7 +889,7 @@ void __exit rxrpc_destroy_all_connections(void)
 
 	rxrpc_connection_timeout = 0;
 	if (try_to_cancel_delayed_work(&rxrpc_connection_reap) >= 0)
-		schedule_delayed_work(&rxrpc_connection_reap, 0);
+		rxrpc_queue_delayed_work(&rxrpc_connection_reap, 0);
 
 	_leave("");
 }
diff --git a/net/rxrpc/ar-connevent.c b/net/rxrpc/ar-connevent.c
index 1957d2f..434c1de 100644
--- a/net/rxrpc/ar-connevent.c
+++ b/net/rxrpc/ar-connevent.c
@@ -45,7 +45,7 @@ static void rxrpc_abort_calls(struct rxrpc_connection *conn, int state,
 				set_bit(RXRPC_CALL_CONN_ABORT, &call->events);
 			else
 				set_bit(RXRPC_CALL_RCVD_ABORT, &call->events);
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		}
 		write_unlock(&call->state_lock);
 	}
@@ -133,7 +133,7 @@ void rxrpc_call_is_secure(struct rxrpc_call *call)
 		read_lock(&call->state_lock);
 		if (call->state < RXRPC_CALL_COMPLETE &&
 		    !test_and_set_bit(RXRPC_CALL_SECURED, &call->events))
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		read_unlock(&call->state_lock);
 	}
 }
@@ -308,6 +308,22 @@ protocol_error:
 }
 
 /*
+ * put a packet up for transport-level abort
+ */
+void rxrpc_reject_packet(struct rxrpc_local *local, struct sk_buff *skb)
+{
+	CHECK_SLAB_OKAY(&local->usage);
+
+	if (!atomic_inc_not_zero(&local->usage)) {
+		printk("resurrected on reject\n");
+		BUG();
+	}
+
+	skb_queue_tail(&local->reject_queue, skb);
+	rxrpc_queue_work(&local->rejecter);
+}
+
+/*
  * reject packets through the local endpoint
  */
 void rxrpc_reject_packets(struct work_struct *work)
diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/ar-error.c
index 8554c44..c28001b 100644
--- a/net/rxrpc/ar-error.c
+++ b/net/rxrpc/ar-error.c
@@ -111,7 +111,7 @@ void rxrpc_UDP_error_report(struct sock *sk)
 
 	/* pass the transport ref to error_handler to release */
 	skb_queue_tail(&trans->error_queue, skb);
-	schedule_work(&trans->error_handler);
+	rxrpc_queue_work(&trans->error_handler);
 
 	/* reset and regenerate socket error */
 	spin_lock_bh(&sk->sk_error_queue.lock);
@@ -235,7 +235,7 @@ void rxrpc_UDP_error_handler(struct work_struct *work)
 			    call->state < RXRPC_CALL_NETWORK_ERROR) {
 				call->state = RXRPC_CALL_NETWORK_ERROR;
 				set_bit(RXRPC_CALL_RCVD_ERROR, &call->events);
-				schedule_work(&call->processor);
+				rxrpc_queue_call(call);
 			}
 			write_unlock(&call->state_lock);
 			list_del_init(&call->error_link);
@@ -245,7 +245,7 @@ void rxrpc_UDP_error_handler(struct work_struct *work)
 	}
 
 	if (!skb_queue_empty(&trans->error_queue))
-		schedule_work(&trans->error_handler);
+		rxrpc_queue_work(&trans->error_handler);
 
 	rxrpc_free_skb(skb);
 	rxrpc_put_transport(trans);
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 9269786..80c979d 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -238,7 +238,7 @@ static int rxrpc_fast_process_data(struct rxrpc_call *call,
 		read_lock(&call->state_lock);
 		if (call->state < RXRPC_CALL_COMPLETE &&
 		    !test_and_set_bit(RXRPC_CALL_DRAIN_RX_OOS, &call->events))
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		read_unlock(&call->state_lock);
 	}
 
@@ -273,7 +273,7 @@ enqueue_packet:
 	atomic_inc(&call->ackr_not_idle);
 	read_lock(&call->state_lock);
 	if (call->state < RXRPC_CALL_DEAD)
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	read_unlock(&call->state_lock);
 	_leave(" = 0 [queued]");
 	return 0;
@@ -366,7 +366,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 			call->state = RXRPC_CALL_REMOTELY_ABORTED;
 			call->abort_code = abort_code;
 			set_bit(RXRPC_CALL_RCVD_ABORT, &call->events);
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		}
 		goto free_packet_unlock;
 
@@ -381,7 +381,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 		case RXRPC_CALL_CLIENT_SEND_REQUEST:
 			call->state = RXRPC_CALL_SERVER_BUSY;
 			set_bit(RXRPC_CALL_RCVD_BUSY, &call->events);
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		case RXRPC_CALL_SERVER_BUSY:
 			goto free_packet_unlock;
 		default:
@@ -425,7 +425,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 		read_lock_bh(&call->state_lock);
 		if (call->state < RXRPC_CALL_DEAD) {
 			skb_queue_tail(&call->rx_queue, skb);
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 			skb = NULL;
 		}
 		read_unlock_bh(&call->state_lock);
@@ -440,7 +440,7 @@ protocol_error_locked:
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
 		call->abort_code = RX_PROTOCOL_ERROR;
 		set_bit(RXRPC_CALL_ABORT, &call->events);
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	}
 free_packet_unlock:
 	write_unlock_bh(&call->state_lock);
@@ -512,7 +512,7 @@ protocol_error:
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
 		call->abort_code = RX_PROTOCOL_ERROR;
 		set_bit(RXRPC_CALL_ABORT, &call->events);
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	}
 	write_unlock_bh(&call->state_lock);
 	_leave("");
@@ -548,7 +548,7 @@ static void rxrpc_post_packet_to_call(struct rxrpc_connection *conn,
 	switch (call->state) {
 	case RXRPC_CALL_LOCALLY_ABORTED:
 		if (!test_and_set_bit(RXRPC_CALL_ABORT, &call->events))
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 	case RXRPC_CALL_REMOTELY_ABORTED:
 	case RXRPC_CALL_NETWORK_ERROR:
 	case RXRPC_CALL_DEAD:
@@ -597,7 +597,7 @@ dead_call:
 	    sp->hdr.seq == __constant_cpu_to_be32(1)) {
 		_debug("incoming call");
 		skb_queue_tail(&conn->trans->local->accept_queue, skb);
-		schedule_work(&conn->trans->local->acceptor);
+		rxrpc_queue_work(&conn->trans->local->acceptor);
 		goto done;
 	}
 
@@ -636,7 +636,7 @@ found_completed_call:
 	_debug("final ack again");
 	rxrpc_get_call(call);
 	set_bit(RXRPC_CALL_ACK_FINAL, &call->events);
-	schedule_work(&call->processor);
+	rxrpc_queue_call(call);
 
 free_unlock:
 	read_unlock(&call->state_lock);
@@ -657,7 +657,7 @@ static void rxrpc_post_packet_to_conn(struct rxrpc_connection *conn,
 
 	atomic_inc(&conn->usage);
 	skb_queue_tail(&conn->rx_queue, skb);
-	schedule_work(&conn->processor);
+	rxrpc_queue_conn(conn);
 }
 
 /*
@@ -773,7 +773,7 @@ cant_route_call:
 		if (sp->hdr.seq == __constant_cpu_to_be32(1)) {
 			_debug("first packet");
 			skb_queue_tail(&local->accept_queue, skb);
-			schedule_work(&local->acceptor);
+			rxrpc_queue_work(&local->acceptor);
 			rxrpc_put_local(local);
 			_leave(" [incoming]");
 			return;
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 7c1887a..cb1eb49 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -19,8 +19,6 @@
 #define CHECK_SLAB_OKAY(X) do {} while(0)
 #endif
 
-extern atomic_t rxrpc_n_skbs;
-
 #define FCRYPT_BSIZE 8
 struct rxrpc_crypt {
 	union {
@@ -29,8 +27,12 @@ struct rxrpc_crypt {
 	};
 } __attribute__((aligned(8)));
 
-extern __be32 rxrpc_epoch;		/* local epoch for detecting local-end reset */
-extern atomic_t rxrpc_debug_id;		/* current debugging ID */
+#define rxrpc_queue_work(WS)	queue_work(rxrpc_workqueue, (WS))
+#define rxrpc_queue_delayed_work(WS,D)	\
+	queue_delayed_work(rxrpc_workqueue, (WS), (D))
+
+#define rxrpc_queue_call(CALL)	rxrpc_queue_work(&(CALL)->processor)
+#define rxrpc_queue_conn(CONN)	rxrpc_queue_work(&(CONN)->processor)
 
 /*
  * sk_state for RxRPC sockets
@@ -430,19 +432,12 @@ static inline void rxrpc_abort_call(struct rxrpc_call *call, u32 abort_code)
 }
 
 /*
- * put a packet up for transport-level abort
+ * af_rxrpc.c
  */
-static inline
-void rxrpc_reject_packet(struct rxrpc_local *local, struct sk_buff *skb)
-{
-	CHECK_SLAB_OKAY(&local->usage);
-	if (!atomic_inc_not_zero(&local->usage)) {
-		printk("resurrected on reject\n");
-		BUG();
-	}
-	skb_queue_tail(&local->reject_queue, skb);
-	schedule_work(&local->rejecter);
-}
+extern atomic_t rxrpc_n_skbs;
+extern __be32 rxrpc_epoch;
+extern atomic_t rxrpc_debug_id;
+extern struct workqueue_struct *rxrpc_workqueue;
 
 /*
  * ar-accept.c
@@ -507,6 +502,7 @@ rxrpc_incoming_connection(struct rxrpc_transport *, struct rxrpc_header *,
  * ar-connevent.c
  */
 extern void rxrpc_process_connection(struct work_struct *);
+extern void rxrpc_reject_packet(struct rxrpc_local *, struct sk_buff *);
 extern void rxrpc_reject_packets(struct work_struct *);
 
 /*
diff --git a/net/rxrpc/ar-local.c b/net/rxrpc/ar-local.c
index a20a2c0..fe03f71 100644
--- a/net/rxrpc/ar-local.c
+++ b/net/rxrpc/ar-local.c
@@ -228,7 +228,7 @@ void rxrpc_put_local(struct rxrpc_local *local)
 	write_lock_bh(&rxrpc_local_lock);
 	if (unlikely(atomic_dec_and_test(&local->usage))) {
 		_debug("destroy local");
-		schedule_work(&local->destroyer);
+		rxrpc_queue_work(&local->destroyer);
 	}
 	write_unlock_bh(&rxrpc_local_lock);
 	_leave("");
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index a79576f..ed7f3f4 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -113,7 +113,7 @@ static void rxrpc_send_abort(struct rxrpc_call *call, u32 abort_code)
 		clear_bit(RXRPC_CALL_RESEND_TIMER, &call->events);
 		clear_bit(RXRPC_CALL_ACK, &call->events);
 		clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	}
 
 	write_unlock_bh(&call->state_lock);
@@ -435,7 +435,7 @@ static inline void rxrpc_instant_resend(struct rxrpc_call *call)
 		clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
 		if (call->state < RXRPC_CALL_COMPLETE &&
 		    !test_and_set_bit(RXRPC_CALL_RESEND_TIMER, &call->events))
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 	}
 	read_unlock_bh(&call->state_lock);
 }
diff --git a/net/rxrpc/ar-peer.c b/net/rxrpc/ar-peer.c
index 69ac355..d399de4 100644
--- a/net/rxrpc/ar-peer.c
+++ b/net/rxrpc/ar-peer.c
@@ -219,7 +219,7 @@ void rxrpc_put_peer(struct rxrpc_peer *peer)
 		return;
 	}
 
-	schedule_work(&peer->destroyer);
+	rxrpc_queue_work(&peer->destroyer);
 	_leave("");
 }
 
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index 6fab099..f19121d 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -33,7 +33,7 @@ void rxrpc_remove_user_ID(struct rxrpc_sock *rx, struct rxrpc_call *call)
 	read_lock_bh(&call->state_lock);
 	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
 	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	read_unlock_bh(&call->state_lock);
 }
 
diff --git a/net/rxrpc/ar-skbuff.c b/net/rxrpc/ar-skbuff.c
index 487e689..de755e0 100644
--- a/net/rxrpc/ar-skbuff.c
+++ b/net/rxrpc/ar-skbuff.c
@@ -36,7 +36,7 @@ static void rxrpc_request_final_ACK(struct rxrpc_call *call)
 		rxrpc_get_call(call);
 		set_bit(RXRPC_CALL_ACK_FINAL, &call->events);
 		if (try_to_del_timer_sync(&call->ack_timer) >= 0)
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		break;
 
 	case RXRPC_CALL_SERVER_RECV_REQUEST:
diff --git a/net/rxrpc/ar-transport.c b/net/rxrpc/ar-transport.c
index 4c3fce6..2701f2f 100644
--- a/net/rxrpc/ar-transport.c
+++ b/net/rxrpc/ar-transport.c
@@ -189,7 +189,7 @@ void rxrpc_put_transport(struct rxrpc_transport *trans)
 		/* let the reaper determine the timeout to avoid a race with
 		 * overextending the timeout if the reaper is running at the
 		 * same time */
-		schedule_delayed_work(&rxrpc_transport_reap, 0);
+		rxrpc_queue_delayed_work(&rxrpc_transport_reap, 0);
 	_leave("");
 }
 
@@ -243,8 +243,8 @@ static void rxrpc_transport_reaper(struct work_struct *work)
 	if (earliest != ULONG_MAX) {
 		_debug("reschedule reaper %ld", (long) earliest - now);
 		ASSERTCMP(earliest, >, now);
-		schedule_delayed_work(&rxrpc_transport_reap,
-				      (earliest - now) * HZ);
+		rxrpc_queue_delayed_work(&rxrpc_transport_reap,
+					 (earliest - now) * HZ);
 	}
 
 	/* then destroy all those pulled out */
@@ -270,7 +270,7 @@ void __exit rxrpc_destroy_all_transports(void)
 
 	rxrpc_transport_timeout = 0;
 	if (try_to_cancel_delayed_work(&rxrpc_transport_reap) >= 0)
-		schedule_delayed_work(&rxrpc_transport_reap, 0);
+		rxrpc_queue_delayed_work(&rxrpc_transport_reap, 0);
 
 	_leave("");
 }

