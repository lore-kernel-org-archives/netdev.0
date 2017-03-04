From: David Howells <dhowells@redhat.com>
Subject: [PATCH net] rxrpc: Call state should be read with READ_ONCE() under
 some circumstances
Date: Sat, 04 Mar 2017 00:01:41 +0000
Message-ID: <148858570121.7759.13967054786116725339.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The call state may be changed at any time by the data-ready routine in
response to received packets, so if the call state is to be read and acted
upon several times in a function, READ_ONCE() must be used unless the call
state lock is held.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c   |   12 +++++++-----
 net/rxrpc/recvmsg.c |    4 ++--
 net/rxrpc/sendmsg.c |   48 ++++++++++++++++++++++++++++++------------------
 3 files changed, 39 insertions(+), 25 deletions(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 9f4cfa25af7c..d74921c4969b 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -420,6 +420,7 @@ static void rxrpc_input_data(struct rxrpc_call *call, struct sk_buff *skb,
 			     u16 skew)
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	enum rxrpc_call_state state;
 	unsigned int offset = sizeof(struct rxrpc_wire_header);
 	unsigned int ix;
 	rxrpc_serial_t serial = sp->hdr.serial, ack_serial = 0;
@@ -434,14 +435,15 @@ static void rxrpc_input_data(struct rxrpc_call *call, struct sk_buff *skb,
 	_proto("Rx DATA %%%u { #%u f=%02x }",
 	       sp->hdr.serial, seq, sp->hdr.flags);
 
-	if (call->state >= RXRPC_CALL_COMPLETE)
+	state = READ_ONCE(call->state);
+	if (state >= RXRPC_CALL_COMPLETE)
 		return;
 
 	/* Received data implicitly ACKs all of the request packets we sent
 	 * when we're acting as a client.
 	 */
-	if ((call->state == RXRPC_CALL_CLIENT_SEND_REQUEST ||
-	     call->state == RXRPC_CALL_CLIENT_AWAIT_REPLY) &&
+	if ((state == RXRPC_CALL_CLIENT_SEND_REQUEST ||
+	     state == RXRPC_CALL_CLIENT_AWAIT_REPLY) &&
 	    !rxrpc_receiving_reply(call))
 		return;
 
@@ -799,7 +801,7 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 		return rxrpc_proto_abort("AK0", call, 0);
 
 	/* Ignore ACKs unless we are or have just been transmitting. */
-	switch (call->state) {
+	switch (READ_ONCE(call->state)) {
 	case RXRPC_CALL_CLIENT_SEND_REQUEST:
 	case RXRPC_CALL_CLIENT_AWAIT_REPLY:
 	case RXRPC_CALL_SERVER_SEND_REPLY:
@@ -940,7 +942,7 @@ static void rxrpc_input_call_packet(struct rxrpc_call *call,
 static void rxrpc_input_implicit_end_call(struct rxrpc_connection *conn,
 					  struct rxrpc_call *call)
 {
-	switch (call->state) {
+	switch (READ_ONCE(call->state)) {
 	case RXRPC_CALL_SERVER_AWAIT_ACK:
 		rxrpc_call_completed(call);
 		break;
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 22447dbcc380..46b1a93be03a 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -525,7 +525,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		msg->msg_namelen = len;
 	}
 
-	switch (call->state) {
+	switch (READ_ONCE(call->state)) {
 	case RXRPC_CALL_SERVER_ACCEPTING:
 		ret = rxrpc_recvmsg_new_call(rx, call, msg, flags);
 		break;
@@ -638,7 +638,7 @@ int rxrpc_kernel_recv_data(struct socket *sock, struct rxrpc_call *call,
 
 	mutex_lock(&call->user_mutex);
 
-	switch (call->state) {
+	switch (READ_ONCE(call->state)) {
 	case RXRPC_CALL_CLIENT_RECV_REPLY:
 	case RXRPC_CALL_SERVER_RECV_REQUEST:
 	case RXRPC_CALL_SERVER_ACK_REQUEST:
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 27685d8cba1a..9c2e443de811 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -486,6 +486,7 @@ rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 	__releases(&rx->sk.sk_lock.slock)
 {
+	enum rxrpc_call_state state;
 	enum rxrpc_command cmd;
 	struct rxrpc_call *call;
 	unsigned long user_call_ID = 0;
@@ -524,13 +525,17 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 			return PTR_ERR(call);
 		/* ... and we have the call lock. */
 	} else {
-		ret = -EBUSY;
-		if (call->state == RXRPC_CALL_UNINITIALISED ||
-		    call->state == RXRPC_CALL_CLIENT_AWAIT_CONN ||
-		    call->state == RXRPC_CALL_SERVER_PREALLOC ||
-		    call->state == RXRPC_CALL_SERVER_SECURING ||
-		    call->state == RXRPC_CALL_SERVER_ACCEPTING)
+		switch (READ_ONCE(call->state)) {
+		case RXRPC_CALL_UNINITIALISED:
+		case RXRPC_CALL_CLIENT_AWAIT_CONN:
+		case RXRPC_CALL_SERVER_PREALLOC:
+		case RXRPC_CALL_SERVER_SECURING:
+		case RXRPC_CALL_SERVER_ACCEPTING:
+			ret = -EBUSY;
 			goto error_release_sock;
+		default:
+			break;
+		}
 
 		ret = mutex_lock_interruptible(&call->user_mutex);
 		release_sock(&rx->sk);
@@ -540,10 +545,11 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 		}
 	}
 
+	state = READ_ONCE(call->state);
 	_debug("CALL %d USR %lx ST %d on CONN %p",
-	       call->debug_id, call->user_call_ID, call->state, call->conn);
+	       call->debug_id, call->user_call_ID, state, call->conn);
 
-	if (call->state >= RXRPC_CALL_COMPLETE) {
+	if (state >= RXRPC_CALL_COMPLETE) {
 		/* it's too late for this call */
 		ret = -ESHUTDOWN;
 	} else if (cmd == RXRPC_CMD_SEND_ABORT) {
@@ -553,12 +559,12 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 	} else if (cmd != RXRPC_CMD_SEND_DATA) {
 		ret = -EINVAL;
 	} else if (rxrpc_is_client_call(call) &&
-		   call->state != RXRPC_CALL_CLIENT_SEND_REQUEST) {
+		   state != RXRPC_CALL_CLIENT_SEND_REQUEST) {
 		/* request phase complete for this client call */
 		ret = -EPROTO;
 	} else if (rxrpc_is_service_call(call) &&
-		   call->state != RXRPC_CALL_SERVER_ACK_REQUEST &&
-		   call->state != RXRPC_CALL_SERVER_SEND_REPLY) {
+		   state != RXRPC_CALL_SERVER_ACK_REQUEST &&
+		   state != RXRPC_CALL_SERVER_SEND_REPLY) {
 		/* Reply phase not begun or not complete for service call. */
 		ret = -EPROTO;
 	} else {
@@ -603,14 +609,20 @@ int rxrpc_kernel_send_data(struct socket *sock, struct rxrpc_call *call,
 	_debug("CALL %d USR %lx ST %d on CONN %p",
 	       call->debug_id, call->user_call_ID, call->state, call->conn);
 
-	if (call->state >= RXRPC_CALL_COMPLETE) {
-		ret = -ESHUTDOWN; /* it's too late for this call */
-	} else if (call->state != RXRPC_CALL_CLIENT_SEND_REQUEST &&
-		   call->state != RXRPC_CALL_SERVER_ACK_REQUEST &&
-		   call->state != RXRPC_CALL_SERVER_SEND_REPLY) {
-		ret = -EPROTO; /* request phase complete for this client call */
-	} else {
+	switch (READ_ONCE(call->state)) {
+	case RXRPC_CALL_CLIENT_SEND_REQUEST:
+	case RXRPC_CALL_SERVER_ACK_REQUEST:
+	case RXRPC_CALL_SERVER_SEND_REPLY:
 		ret = rxrpc_send_data(rxrpc_sk(sock->sk), call, msg, len);
+		break;
+	case RXRPC_CALL_COMPLETE:
+		/* It's too late for this call */
+		ret = -ESHUTDOWN;
+		break;
+	default:
+		 /* Request phase complete for this client call */
+		ret = -EPROTO;
+		break;
 	}
 
 	mutex_unlock(&call->user_mutex);
