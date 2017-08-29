From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 7/7] rxrpc: Allow failed client calls to be retried
Date: Tue, 29 Aug 2017 13:27:37 +0100
Message-ID: <150400965727.21371.231552212599612769.stgit@warthog.procyon.org.uk>
References: <150400960745.21371.15455867950162722742.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150400960745.21371.15455867950162722742.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow a client call that failed on network error to be retried, provided
that the Tx queue still holds DATA packet 1.  This allows an operation to
be submitted to another server or another address for the same server
without having to repackage and re-encrypt the data so far processed.

Two new functions are provided:

 (1) rxrpc_kernel_check_call() - This is used to find out the completion
     state of a call to guess whether it can be retried and whether it
     should be retried.

 (2) rxrpc_kernel_retry_call() - Disconnect the call from its current
     connection, reset the state and submit it as a new client call to a
     new address.  The new address need not match the previous address.

A call may be retried even if all the data hasn't been loaded into it yet;
a partially constructed will be retained at the same point it was at when
an error condition was detected.  msg_data_left() can be used to find out
how much data was packaged before the error occurred.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |   45 ++++++++++++++++
 include/net/af_rxrpc.h             |   16 ++++++
 net/rxrpc/af_rxrpc.c               |   69 ++++++++++++++++++++++++
 net/rxrpc/ar-internal.h            |   19 ++-----
 net/rxrpc/call_object.c            |  102 ++++++++++++++++++++++++++++++++++--
 net/rxrpc/conn_client.c            |   17 +++++-
 net/rxrpc/sendmsg.c                |   24 +++++---
 7 files changed, 261 insertions(+), 31 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index 92a3c3bd5ac3..810620153a44 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -975,6 +975,51 @@ The kernel interface functions are as follows:
      size should be set when the call is begun.  tx_total_len may not be less
      than zero.
 
+ (*) Check to see the completion state of a call so that the caller can assess
+     whether it needs to be retried.
+
+	enum rxrpc_call_completion {
+		RXRPC_CALL_SUCCEEDED,
+		RXRPC_CALL_REMOTELY_ABORTED,
+		RXRPC_CALL_LOCALLY_ABORTED,
+		RXRPC_CALL_LOCAL_ERROR,
+		RXRPC_CALL_NETWORK_ERROR,
+	};
+
+	int rxrpc_kernel_check_call(struct socket *sock, struct rxrpc_call *call,
+				    enum rxrpc_call_completion *_compl,
+				    u32 *_abort_code);
+
+     On return, -EINPROGRESS will be returned if the call is still ongoing; if
+     it is finished, *_compl will be set to indicate the manner of completion,
+     *_abort_code will be set to any abort code that occurred.  0 will be
+     returned on a successful completion, -ECONNABORTED will be returned if the
+     client failed due to a remote abort and anything else will return an
+     appropriate error code.
+
+     The caller should look at this information to decide if it's worth
+     retrying the call.
+
+ (*) Retry a client call.
+
+	int rxrpc_kernel_retry_call(struct socket *sock,
+				    struct rxrpc_call *call,
+				    struct sockaddr_rxrpc *srx,
+				    struct key *key);
+
+     This attempts to partially reinitialise a call and submit it again whilst
+     reusing the original call's Tx queue to avoid the need to repackage and
+     re-encrypt the data to be sent.  call indicates the call to retry, srx the
+     new address to send it to and key the encryption key to use for signing or
+     encrypting the packets.
+
+     For this to work, the first Tx data packet must still be in the transmit
+     queue, and currently this is only permitted for local and network errors
+     and the call must not have been aborted.  Any partially constructed Tx
+     packet is left as is and can continue being filled afterwards.
+
+     It returns 0 if the call was requeued and an error otherwise.
+
 
 =======================
 CONFIGURABLE PARAMETERS
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index 07a47ee6f783..3ac79150291f 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -19,6 +19,18 @@ struct sock;
 struct socket;
 struct rxrpc_call;
 
+/*
+ * Call completion condition (state == RXRPC_CALL_COMPLETE).
+ */
+enum rxrpc_call_completion {
+	RXRPC_CALL_SUCCEEDED,		/* - Normal termination */
+	RXRPC_CALL_REMOTELY_ABORTED,	/* - call aborted by peer */
+	RXRPC_CALL_LOCALLY_ABORTED,	/* - call aborted locally on error or close */
+	RXRPC_CALL_LOCAL_ERROR,		/* - call failed due to local error */
+	RXRPC_CALL_NETWORK_ERROR,	/* - call terminated by network error */
+	NR__RXRPC_CALL_COMPLETIONS
+};
+
 typedef void (*rxrpc_notify_rx_t)(struct sock *, struct rxrpc_call *,
 				  unsigned long);
 typedef void (*rxrpc_notify_end_tx_t)(struct sock *, struct rxrpc_call *,
@@ -51,5 +63,9 @@ void rxrpc_kernel_get_peer(struct socket *, struct rxrpc_call *,
 int rxrpc_kernel_charge_accept(struct socket *, rxrpc_notify_rx_t,
 			       rxrpc_user_attach_call_t, unsigned long, gfp_t);
 void rxrpc_kernel_set_tx_length(struct socket *, struct rxrpc_call *, s64);
+int rxrpc_kernel_retry_call(struct socket *, struct rxrpc_call *,
+			    struct sockaddr_rxrpc *, struct key *);
+int rxrpc_kernel_check_call(struct socket *, struct rxrpc_call *,
+			    enum rxrpc_call_completion *, u32 *);
 
 #endif /* _NET_RXRPC_H */
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 31e97f714ca9..fb17552fd292 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -337,6 +337,75 @@ void rxrpc_kernel_end_call(struct socket *sock, struct rxrpc_call *call)
 EXPORT_SYMBOL(rxrpc_kernel_end_call);
 
 /**
+ * rxrpc_kernel_check_call - Check a call's state
+ * @sock: The socket the call is on
+ * @call: The call to check
+ * @_compl: Where to store the completion state
+ * @_abort_code: Where to store any abort code
+ *
+ * Allow a kernel service to query the state of a call and find out the manner
+ * of its termination if it has completed.  Returns -EINPROGRESS if the call is
+ * still going, 0 if the call finished successfully, -ECONNABORTED if the call
+ * was aborted and an appropriate error if the call failed in some other way.
+ */
+int rxrpc_kernel_check_call(struct socket *sock, struct rxrpc_call *call,
+			    enum rxrpc_call_completion *_compl, u32 *_abort_code)
+{
+	if (call->state != RXRPC_CALL_COMPLETE)
+		return -EINPROGRESS;
+	smp_rmb();
+	*_compl = call->completion;
+	*_abort_code = call->abort_code;
+	return call->error;
+}
+EXPORT_SYMBOL(rxrpc_kernel_check_call);
+
+/**
+ * rxrpc_kernel_retry_call - Allow a kernel service to retry a call
+ * @sock: The socket the call is on
+ * @call: The call to retry
+ * @srx: The address of the peer to contact
+ * @key: The security context to use (defaults to socket setting)
+ *
+ * Allow a kernel service to try resending a client call that failed due to a
+ * network error to a new address.  The Tx queue is maintained intact, thereby
+ * relieving the need to re-encrypt any request data that has already been
+ * buffered.
+ */
+int rxrpc_kernel_retry_call(struct socket *sock, struct rxrpc_call *call,
+			    struct sockaddr_rxrpc *srx, struct key *key)
+{
+	struct rxrpc_conn_parameters cp;
+	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
+	int ret;
+
+	_enter("%d{%d}", call->debug_id, atomic_read(&call->usage));
+
+	if (!key)
+		key = rx->key;
+	if (key && !key->payload.data[0])
+		key = NULL; /* a no-security key */
+
+	memset(&cp, 0, sizeof(cp));
+	cp.local		= rx->local;
+	cp.key			= key;
+	cp.security_level	= 0;
+	cp.exclusive		= false;
+	cp.service_id		= srx->srx_service;
+
+	mutex_lock(&call->user_mutex);
+
+	ret = rxrpc_prepare_call_for_retry(rx, call);
+	if (ret == 0)
+		ret = rxrpc_retry_client_call(rx, call, &cp, srx, GFP_KERNEL);
+
+	mutex_unlock(&call->user_mutex);
+	_leave(" = %d", ret);
+	return ret;
+}
+EXPORT_SYMBOL(rxrpc_kernel_retry_call);
+
+/**
  * rxrpc_kernel_new_call_notification - Get notifications of new calls
  * @sock: The socket to intercept received messages on
  * @notify_new_call: Function to be called when new calls appear
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 227e24794055..ea5600b747cc 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -445,6 +445,7 @@ enum rxrpc_call_flag {
 	RXRPC_CALL_EXPOSED,		/* The call was exposed to the world */
 	RXRPC_CALL_RX_LAST,		/* Received the last packet (at rxtx_top) */
 	RXRPC_CALL_TX_LAST,		/* Last packet in Tx buffer (at rxtx_top) */
+	RXRPC_CALL_TX_LASTQ,		/* Last packet has been queued */
 	RXRPC_CALL_SEND_PING,		/* A ping will need to be sent */
 	RXRPC_CALL_PINGING,		/* Ping in process */
 	RXRPC_CALL_RETRANS_TIMEOUT,	/* Retransmission due to timeout occurred */
@@ -482,18 +483,6 @@ enum rxrpc_call_state {
 };
 
 /*
- * Call completion condition (state == RXRPC_CALL_COMPLETE).
- */
-enum rxrpc_call_completion {
-	RXRPC_CALL_SUCCEEDED,		/* - Normal termination */
-	RXRPC_CALL_REMOTELY_ABORTED,	/* - call aborted by peer */
-	RXRPC_CALL_LOCALLY_ABORTED,	/* - call aborted locally on error or close */
-	RXRPC_CALL_LOCAL_ERROR,		/* - call failed due to local error */
-	RXRPC_CALL_NETWORK_ERROR,	/* - call terminated by network error */
-	NR__RXRPC_CALL_COMPLETIONS
-};
-
-/*
  * Call Tx congestion management modes.
  */
 enum rxrpc_congest_mode {
@@ -687,9 +676,15 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *,
 					 struct rxrpc_conn_parameters *,
 					 struct sockaddr_rxrpc *,
 					 unsigned long, s64, gfp_t);
+int rxrpc_retry_client_call(struct rxrpc_sock *,
+			    struct rxrpc_call *,
+			    struct rxrpc_conn_parameters *,
+			    struct sockaddr_rxrpc *,
+			    gfp_t);
 void rxrpc_incoming_call(struct rxrpc_sock *, struct rxrpc_call *,
 			 struct sk_buff *);
 void rxrpc_release_call(struct rxrpc_sock *, struct rxrpc_call *);
+int rxrpc_prepare_call_for_retry(struct rxrpc_sock *, struct rxrpc_call *);
 void rxrpc_release_calls_on_socket(struct rxrpc_sock *);
 bool __rxrpc_queue_call(struct rxrpc_call *);
 bool rxrpc_queue_call(struct rxrpc_call *);
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index d7809a0620b4..fcdd6555a820 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -269,11 +269,6 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 	trace_rxrpc_call(call, rxrpc_call_connected, atomic_read(&call->usage),
 			 here, NULL);
 
-	spin_lock_bh(&call->conn->params.peer->lock);
-	hlist_add_head(&call->error_link,
-		       &call->conn->params.peer->error_targets);
-	spin_unlock_bh(&call->conn->params.peer->lock);
-
 	rxrpc_start_call_timer(call);
 
 	_net("CALL new %d on CONN %d", call->debug_id, call->conn->debug_id);
@@ -304,6 +299,48 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 }
 
 /*
+ * Retry a call to a new address.  It is expected that the Tx queue of the call
+ * will contain data previously packaged for an old call.
+ */
+int rxrpc_retry_client_call(struct rxrpc_sock *rx,
+			    struct rxrpc_call *call,
+			    struct rxrpc_conn_parameters *cp,
+			    struct sockaddr_rxrpc *srx,
+			    gfp_t gfp)
+{
+	const void *here = __builtin_return_address(0);
+	int ret;
+
+	/* Set up or get a connection record and set the protocol parameters,
+	 * including channel number and call ID.
+	 */
+	ret = rxrpc_connect_call(call, cp, srx, gfp);
+	if (ret < 0)
+		goto error;
+
+	trace_rxrpc_call(call, rxrpc_call_connected, atomic_read(&call->usage),
+			 here, NULL);
+
+	rxrpc_start_call_timer(call);
+
+	_net("CALL new %d on CONN %d", call->debug_id, call->conn->debug_id);
+
+	if (!test_and_set_bit(RXRPC_CALL_EV_RESEND, &call->events))
+		rxrpc_queue_call(call);
+
+	_leave(" = 0");
+	return 0;
+
+error:
+	rxrpc_set_call_completion(call, RXRPC_CALL_LOCAL_ERROR,
+				  RX_CALL_DEAD, ret);
+	trace_rxrpc_call(call, rxrpc_call_error, atomic_read(&call->usage),
+			 here, ERR_PTR(ret));
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
  * Set up an incoming call.  call->conn points to the connection.
  * This is called in BH context and isn't allowed to fail.
  */
@@ -471,6 +508,61 @@ void rxrpc_release_call(struct rxrpc_sock *rx, struct rxrpc_call *call)
 }
 
 /*
+ * Prepare a kernel service call for retry.
+ */
+int rxrpc_prepare_call_for_retry(struct rxrpc_sock *rx, struct rxrpc_call *call)
+{
+	const void *here = __builtin_return_address(0);
+	int i;
+	u8 last = 0;
+
+	_enter("{%d,%d}", call->debug_id, atomic_read(&call->usage));
+
+	trace_rxrpc_call(call, rxrpc_call_release, atomic_read(&call->usage),
+			 here, (const void *)call->flags);
+
+	ASSERTCMP(call->state, ==, RXRPC_CALL_COMPLETE);
+	ASSERTCMP(call->completion, !=, RXRPC_CALL_REMOTELY_ABORTED);
+	ASSERTCMP(call->completion, !=, RXRPC_CALL_LOCALLY_ABORTED);
+	ASSERT(list_empty(&call->recvmsg_link));
+
+	del_timer_sync(&call->timer);
+
+	_debug("RELEASE CALL %p (%d CONN %p)", call, call->debug_id, call->conn);
+
+	if (call->conn)
+		rxrpc_disconnect_call(call);
+
+	if (rxrpc_is_service_call(call) ||
+	    !call->tx_phase ||
+	    call->tx_hard_ack != 0 ||
+	    call->rx_hard_ack != 0 ||
+	    call->rx_top != 0)
+		return -EINVAL;
+
+	call->state = RXRPC_CALL_UNINITIALISED;
+	call->completion = RXRPC_CALL_SUCCEEDED;
+	call->call_id = 0;
+	call->cid = 0;
+	call->cong_cwnd = 0;
+	call->cong_extra = 0;
+	call->cong_ssthresh = 0;
+	call->cong_mode = 0;
+	call->cong_dup_acks = 0;
+	call->cong_cumul_acks = 0;
+	call->acks_lowest_nak = 0;
+
+	for (i = 0; i < RXRPC_RXTX_BUFF_SIZE; i++) {
+		last |= call->rxtx_annotations[i];
+		call->rxtx_annotations[i] &= RXRPC_TX_ANNO_LAST;
+		call->rxtx_annotations[i] |= RXRPC_TX_ANNO_RETRANS;
+	}
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
  * release all the calls associated with a socket
  */
 void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index eb2157680399..5f9624bd311c 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -555,7 +555,10 @@ static void rxrpc_activate_one_channel(struct rxrpc_connection *conn,
 	trace_rxrpc_client(conn, channel, rxrpc_client_chan_activate);
 
 	write_lock_bh(&call->state_lock);
-	call->state = RXRPC_CALL_CLIENT_SEND_REQUEST;
+	if (!test_bit(RXRPC_CALL_TX_LASTQ, &call->flags))
+		call->state = RXRPC_CALL_CLIENT_SEND_REQUEST;
+	else
+		call->state = RXRPC_CALL_CLIENT_AWAIT_REPLY;
 	write_unlock_bh(&call->state_lock);
 
 	rxrpc_see_call(call);
@@ -688,15 +691,23 @@ int rxrpc_connect_call(struct rxrpc_call *call,
 
 	ret = rxrpc_get_client_conn(call, cp, srx, gfp);
 	if (ret < 0)
-		return ret;
+		goto out;
 
 	rxrpc_animate_client_conn(rxnet, call->conn);
 	rxrpc_activate_channels(call->conn);
 
 	ret = rxrpc_wait_for_channel(call, gfp);
-	if (ret < 0)
+	if (ret < 0) {
 		rxrpc_disconnect_client_call(call);
+		goto out;
+	}
+
+	spin_lock_bh(&call->conn->params.peer->lock);
+	hlist_add_head(&call->error_link,
+		       &call->conn->params.peer->error_targets);
+	spin_unlock_bh(&call->conn->params.peer->lock);
 
+out:
 	_leave(" = %d", ret);
 	return ret;
 }
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 344fdce89823..9ea6f972767e 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -128,8 +128,10 @@ static void rxrpc_queue_packet(struct rxrpc_sock *rx, struct rxrpc_call *call,
 
 	ASSERTCMP(seq, ==, call->tx_top + 1);
 
-	if (last)
+	if (last) {
 		annotation |= RXRPC_TX_ANNO_LAST;
+		set_bit(RXRPC_CALL_TX_LASTQ, &call->flags);
+	}
 
 	/* We have to set the timestamp before queueing as the retransmit
 	 * algorithm can see the packet as soon as we queue it.
@@ -326,11 +328,6 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 				call->tx_total_len -= copy;
 		}
 
-		/* check for the far side aborting the call or a network error
-		 * occurring */
-		if (call->state == RXRPC_CALL_COMPLETE)
-			goto call_terminated;
-
 		/* add the packet to the send queue if it's now full */
 		if (sp->remain <= 0 ||
 		    (msg_data_left(msg) == 0 && !more)) {
@@ -370,6 +367,16 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 					   notify_end_tx);
 			skb = NULL;
 		}
+
+		/* Check for the far side aborting the call or a network error
+		 * occurring.  If this happens, save any packet that was under
+		 * construction so that in the case of a network error, the
+		 * call can be retried or redirected.
+		 */
+		if (call->state == RXRPC_CALL_COMPLETE) {
+			ret = call->error;
+			goto out;
+		}
 	} while (msg_data_left(msg) > 0);
 
 success:
@@ -379,11 +386,6 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 	_leave(" = %d", ret);
 	return ret;
 
-call_terminated:
-	rxrpc_free_skb(skb, rxrpc_skb_tx_freed);
-	_leave(" = %d", call->error);
-	return call->error;
-
 maybe_error:
 	if (copied)
 		goto success;
