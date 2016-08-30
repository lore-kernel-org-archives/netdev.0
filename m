From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/2] rxrpc: Pass struct socket * to more rxrpc
 kernel interface functions
Date: Tue, 30 Aug 2016 16:39:45 +0100
Message-ID: <147257158541.6286.12242091573980997460.stgit@warthog.procyon.org.uk>
References: <147257157176.6286.15041125103134993769.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147257157176.6286.15041125103134993769.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pass struct socket * to more rxrpc kernel interface functions.  They should
be starting from this rather than the socket pointer in the rxrpc_call
struct if they need to access the socket.

I have left:

	rxrpc_kernel_is_data_last()
	rxrpc_kernel_get_abort_code()
	rxrpc_kernel_get_error_number()
	rxrpc_kernel_free_skb()
	rxrpc_kernel_data_consumed()

unmodified as they're all about to be removed (and, in any case, don't
touch the socket).

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |   11 ++++++++---
 fs/afs/rxrpc.c                     |   26 +++++++++++++++-----------
 include/net/af_rxrpc.h             |   10 +++++++---
 net/rxrpc/af_rxrpc.c               |    5 +++--
 net/rxrpc/output.c                 |   20 +++++++++++---------
 5 files changed, 44 insertions(+), 28 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index dfe0b008df74..cfc8cb91452f 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -725,7 +725,8 @@ The kernel interface functions are as follows:
 
  (*) End a client call.
 
-	void rxrpc_kernel_end_call(struct rxrpc_call *call);
+	void rxrpc_kernel_end_call(struct socket *sock,
+				   struct rxrpc_call *call);
 
      This is used to end a previously begun call.  The user_call_ID is expunged
      from AF_RXRPC's knowledge and will not be seen again in association with
@@ -733,7 +734,9 @@ The kernel interface functions are as follows:
 
  (*) Send data through a call.
 
-	int rxrpc_kernel_send_data(struct rxrpc_call *call, struct msghdr *msg,
+	int rxrpc_kernel_send_data(struct socket *sock,
+				   struct rxrpc_call *call,
+				   struct msghdr *msg,
 				   size_t len);
 
      This is used to supply either the request part of a client call or the
@@ -747,7 +750,9 @@ The kernel interface functions are as follows:
 
  (*) Abort a call.
 
-	void rxrpc_kernel_abort_call(struct rxrpc_call *call, u32 abort_code);
+	void rxrpc_kernel_abort_call(struct socket *sock,
+				     struct rxrpc_call *call,
+				     u32 abort_code);
 
      This is used to abort a call if it's still in an abortable state.  The
      abort code specified will be placed in the ABORT message sent.
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index a1916750e2f9..7b0d18900f50 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -207,7 +207,7 @@ static void afs_free_call(struct afs_call *call)
 static void afs_end_call_nofree(struct afs_call *call)
 {
 	if (call->rxcall) {
-		rxrpc_kernel_end_call(call->rxcall);
+		rxrpc_kernel_end_call(afs_socket, call->rxcall);
 		call->rxcall = NULL;
 	}
 	if (call->type->destructor)
@@ -325,8 +325,8 @@ static int afs_send_pages(struct afs_call *call, struct msghdr *msg,
 			 * returns from sending the request */
 			if (first + loop >= last)
 				call->state = AFS_CALL_AWAIT_REPLY;
-			ret = rxrpc_kernel_send_data(call->rxcall, msg,
-						     to - offset);
+			ret = rxrpc_kernel_send_data(afs_socket, call->rxcall,
+						     msg, to - offset);
 			kunmap(pages[loop]);
 			if (ret < 0)
 				break;
@@ -406,7 +406,8 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 	 * request */
 	if (!call->send_pages)
 		call->state = AFS_CALL_AWAIT_REPLY;
-	ret = rxrpc_kernel_send_data(rxcall, &msg, call->request_size);
+	ret = rxrpc_kernel_send_data(afs_socket, rxcall,
+				     &msg, call->request_size);
 	if (ret < 0)
 		goto error_do_abort;
 
@@ -421,7 +422,7 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 	return wait_mode->wait(call);
 
 error_do_abort:
-	rxrpc_kernel_abort_call(rxcall, RX_USER_ABORT);
+	rxrpc_kernel_abort_call(afs_socket, rxcall, RX_USER_ABORT);
 	while ((skb = skb_dequeue(&call->rx_queue)))
 		afs_free_skb(skb);
 error_kill_call:
@@ -509,7 +510,8 @@ static void afs_deliver_to_call(struct afs_call *call)
 				if (call->state != AFS_CALL_AWAIT_REPLY)
 					abort_code = RXGEN_SS_UNMARSHAL;
 			do_abort:
-				rxrpc_kernel_abort_call(call->rxcall,
+				rxrpc_kernel_abort_call(afs_socket,
+							call->rxcall,
 							abort_code);
 				call->error = ret;
 				call->state = AFS_CALL_ERROR;
@@ -605,7 +607,7 @@ static int afs_wait_for_call_to_complete(struct afs_call *call)
 	/* kill the call */
 	if (call->state < AFS_CALL_COMPLETE) {
 		_debug("call incomplete");
-		rxrpc_kernel_abort_call(call->rxcall, RX_CALL_DEAD);
+		rxrpc_kernel_abort_call(afs_socket, call->rxcall, RX_CALL_DEAD);
 		while ((skb = skb_dequeue(&call->rx_queue)))
 			afs_free_skb(skb);
 	}
@@ -823,14 +825,15 @@ void afs_send_empty_reply(struct afs_call *call)
 	msg.msg_flags		= 0;
 
 	call->state = AFS_CALL_AWAIT_ACK;
-	switch (rxrpc_kernel_send_data(call->rxcall, &msg, 0)) {
+	switch (rxrpc_kernel_send_data(afs_socket, call->rxcall, &msg, 0)) {
 	case 0:
 		_leave(" [replied]");
 		return;
 
 	case -ENOMEM:
 		_debug("oom");
-		rxrpc_kernel_abort_call(call->rxcall, RX_USER_ABORT);
+		rxrpc_kernel_abort_call(afs_socket, call->rxcall,
+					RX_USER_ABORT);
 	default:
 		afs_end_call(call);
 		_leave(" [error]");
@@ -859,7 +862,7 @@ void afs_send_simple_reply(struct afs_call *call, const void *buf, size_t len)
 	msg.msg_flags		= 0;
 
 	call->state = AFS_CALL_AWAIT_ACK;
-	n = rxrpc_kernel_send_data(call->rxcall, &msg, len);
+	n = rxrpc_kernel_send_data(afs_socket, call->rxcall, &msg, len);
 	if (n >= 0) {
 		/* Success */
 		_leave(" [replied]");
@@ -868,7 +871,8 @@ void afs_send_simple_reply(struct afs_call *call, const void *buf, size_t len)
 
 	if (n == -ENOMEM) {
 		_debug("oom");
-		rxrpc_kernel_abort_call(call->rxcall, RX_USER_ABORT);
+		rxrpc_kernel_abort_call(afs_socket, call->rxcall,
+					RX_USER_ABORT);
 	}
 	afs_end_call(call);
 	_leave(" [error]");
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index f9224e835d43..f8d8079dc058 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -15,6 +15,9 @@
 #include <linux/skbuff.h>
 #include <linux/rxrpc.h>
 
+struct key;
+struct sock;
+struct socket;
 struct rxrpc_call;
 
 /*
@@ -39,10 +42,11 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *,
 					   struct key *,
 					   unsigned long,
 					   gfp_t);
-int rxrpc_kernel_send_data(struct rxrpc_call *, struct msghdr *, size_t);
+int rxrpc_kernel_send_data(struct socket *, struct rxrpc_call *,
+			   struct msghdr *, size_t);
 void rxrpc_kernel_data_consumed(struct rxrpc_call *, struct sk_buff *);
-void rxrpc_kernel_abort_call(struct rxrpc_call *, u32);
-void rxrpc_kernel_end_call(struct rxrpc_call *);
+void rxrpc_kernel_abort_call(struct socket *, struct rxrpc_call *, u32);
+void rxrpc_kernel_end_call(struct socket *, struct rxrpc_call *);
 bool rxrpc_kernel_is_data_last(struct sk_buff *);
 u32 rxrpc_kernel_get_abort_code(struct sk_buff *);
 int rxrpc_kernel_get_error_number(struct sk_buff *);
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index c7cf356b42b8..e07c91acd904 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -279,15 +279,16 @@ EXPORT_SYMBOL(rxrpc_kernel_begin_call);
 
 /**
  * rxrpc_kernel_end_call - Allow a kernel service to end a call it was using
+ * @sock: The socket the call is on
  * @call: The call to end
  *
  * Allow a kernel service to end a call it was using.  The call must be
  * complete before this is called (the call should be aborted if necessary).
  */
-void rxrpc_kernel_end_call(struct rxrpc_call *call)
+void rxrpc_kernel_end_call(struct socket *sock, struct rxrpc_call *call)
 {
 	_enter("%d{%d}", call->debug_id, atomic_read(&call->usage));
-	rxrpc_remove_user_ID(call->socket, call);
+	rxrpc_remove_user_ID(rxrpc_sk(sock->sk), call);
 	rxrpc_put_call(call);
 }
 EXPORT_SYMBOL(rxrpc_kernel_end_call);
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 888fa87ed1d6..b1e708a12151 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -239,6 +239,7 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 
 /**
  * rxrpc_kernel_send_data - Allow a kernel service to send data on a call
+ * @sock: The socket the call is on
  * @call: The call to send data through
  * @msg: The data to send
  * @len: The amount of data to send
@@ -248,8 +249,8 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
  * nor should an address be supplied.  MSG_MORE should be flagged if there's
  * more data to come, otherwise this data will end the transmission phase.
  */
-int rxrpc_kernel_send_data(struct rxrpc_call *call, struct msghdr *msg,
-			   size_t len)
+int rxrpc_kernel_send_data(struct socket *sock, struct rxrpc_call *call,
+			   struct msghdr *msg, size_t len)
 {
 	int ret;
 
@@ -258,7 +259,7 @@ int rxrpc_kernel_send_data(struct rxrpc_call *call, struct msghdr *msg,
 	ASSERTCMP(msg->msg_name, ==, NULL);
 	ASSERTCMP(msg->msg_control, ==, NULL);
 
-	lock_sock(&call->socket->sk);
+	lock_sock(sock->sk);
 
 	_debug("CALL %d USR %lx ST %d on CONN %p",
 	       call->debug_id, call->user_call_ID, call->state, call->conn);
@@ -270,35 +271,36 @@ int rxrpc_kernel_send_data(struct rxrpc_call *call, struct msghdr *msg,
 		   call->state != RXRPC_CALL_SERVER_SEND_REPLY) {
 		ret = -EPROTO; /* request phase complete for this client call */
 	} else {
-		ret = rxrpc_send_data(call->socket, call, msg, len);
+		ret = rxrpc_send_data(rxrpc_sk(sock->sk), call, msg, len);
 	}
 
-	release_sock(&call->socket->sk);
+	release_sock(sock->sk);
 	_leave(" = %d", ret);
 	return ret;
 }
-
 EXPORT_SYMBOL(rxrpc_kernel_send_data);
 
 /**
  * rxrpc_kernel_abort_call - Allow a kernel service to abort a call
+ * @sock: The socket the call is on
  * @call: The call to be aborted
  * @abort_code: The abort code to stick into the ABORT packet
  *
  * Allow a kernel service to abort a call, if it's still in an abortable state.
  */
-void rxrpc_kernel_abort_call(struct rxrpc_call *call, u32 abort_code)
+void rxrpc_kernel_abort_call(struct socket *sock, struct rxrpc_call *call,
+			     u32 abort_code)
 {
 	_enter("{%d},%d", call->debug_id, abort_code);
 
-	lock_sock(&call->socket->sk);
+	lock_sock(sock->sk);
 
 	_debug("CALL %d USR %lx ST %d on CONN %p",
 	       call->debug_id, call->user_call_ID, call->state, call->conn);
 
 	rxrpc_send_abort(call, abort_code);
 
-	release_sock(&call->socket->sk);
+	release_sock(sock->sk);
 	_leave("");
 }
 
