From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 6/7] rxrpc: Add notification of end-of-Tx phase
Date: Tue, 29 Aug 2017 13:27:30 +0100
Message-ID: <150400965040.21371.16551943619251407361.stgit@warthog.procyon.org.uk>
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

Add a callback to rxrpc_kernel_send_data() so that a kernel service can get
a notification that the AF_RXRPC call has transitioned out the Tx phase and
is now waiting for a reply or a final ACK.

This is called from AF_RXRPC with the call state lock held so the
notification is guaranteed to come before any reply is passed back.

Further, modify the AFS filesystem to make use of this so that we don't have
to change the afs_call state before sending the last bit of data.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |   12 +++++++++
 fs/afs/rxrpc.c                     |   46 +++++++++++++++++++++++++++---------
 include/net/af_rxrpc.h             |    5 +++-
 net/rxrpc/sendmsg.c                |   34 +++++++++++++++++++++------
 4 files changed, 77 insertions(+), 20 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index 8c70ba5dee4d..92a3c3bd5ac3 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -818,10 +818,15 @@ The kernel interface functions are as follows:
 
  (*) Send data through a call.
 
+	typedef void (*rxrpc_notify_end_tx_t)(struct sock *sk,
+					      unsigned long user_call_ID,
+					      struct sk_buff *skb);
+
 	int rxrpc_kernel_send_data(struct socket *sock,
 				   struct rxrpc_call *call,
 				   struct msghdr *msg,
-				   size_t len);
+				   size_t len,
+				   rxrpc_notify_end_tx_t notify_end_rx);
 
      This is used to supply either the request part of a client call or the
      reply part of a server call.  msg.msg_iovlen and msg.msg_iov specify the
@@ -832,6 +837,11 @@ The kernel interface functions are as follows:
      The msg must not specify a destination address, control data or any flags
      other than MSG_MORE.  len is the total amount of data to transmit.
 
+     notify_end_rx can be NULL or it can be used to specify a function to be
+     called when the call changes state to end the Tx phase.  This function is
+     called with the call-state spinlock held to prevent any reply or final ACK
+     from being delivered first.
+
  (*) Receive data from a call.
 
 	int rxrpc_kernel_recv_data(struct socket *sock,
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 10743043d431..0bf191f0dbaf 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -292,6 +292,19 @@ static void afs_load_bvec(struct afs_call *call, struct msghdr *msg,
 }
 
 /*
+ * Advance the AFS call state when the RxRPC call ends the transmit phase.
+ */
+static void afs_notify_end_request_tx(struct sock *sock,
+				      struct rxrpc_call *rxcall,
+				      unsigned long call_user_ID)
+{
+	struct afs_call *call = (struct afs_call *)call_user_ID;
+
+	if (call->state == AFS_CALL_REQUESTING)
+		call->state = AFS_CALL_AWAIT_REPLY;
+}
+
+/*
  * attach the data from a bunch of pages on an inode to a call
  */
 static int afs_send_pages(struct afs_call *call, struct msghdr *msg)
@@ -310,14 +323,8 @@ static int afs_send_pages(struct afs_call *call, struct msghdr *msg)
 		bytes = msg->msg_iter.count;
 		nr = msg->msg_iter.nr_segs;
 
-		/* Have to change the state *before* sending the last
-		 * packet as RxRPC might give us the reply before it
-		 * returns from sending the request.
-		 */
-		if (first + nr - 1 >= last)
-			call->state = AFS_CALL_AWAIT_REPLY;
-		ret = rxrpc_kernel_send_data(afs_socket, call->rxcall,
-					     msg, bytes);
+		ret = rxrpc_kernel_send_data(afs_socket, call->rxcall, msg,
+					     bytes, afs_notify_end_request_tx);
 		for (loop = 0; loop < nr; loop++)
 			put_page(bv[loop].bv_page);
 		if (ret < 0)
@@ -409,7 +416,8 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 	if (!call->send_pages)
 		call->state = AFS_CALL_AWAIT_REPLY;
 	ret = rxrpc_kernel_send_data(afs_socket, rxcall,
-				     &msg, call->request_size);
+				     &msg, call->request_size,
+				     afs_notify_end_request_tx);
 	if (ret < 0)
 		goto error_do_abort;
 
@@ -741,6 +749,20 @@ static int afs_deliver_cm_op_id(struct afs_call *call)
 }
 
 /*
+ * Advance the AFS call state when an RxRPC service call ends the transmit
+ * phase.
+ */
+static void afs_notify_end_reply_tx(struct sock *sock,
+				    struct rxrpc_call *rxcall,
+				    unsigned long call_user_ID)
+{
+	struct afs_call *call = (struct afs_call *)call_user_ID;
+
+	if (call->state == AFS_CALL_REPLYING)
+		call->state = AFS_CALL_AWAIT_ACK;
+}
+
+/*
  * send an empty reply
  */
 void afs_send_empty_reply(struct afs_call *call)
@@ -759,7 +781,8 @@ void afs_send_empty_reply(struct afs_call *call)
 	msg.msg_flags		= 0;
 
 	call->state = AFS_CALL_AWAIT_ACK;
-	switch (rxrpc_kernel_send_data(afs_socket, call->rxcall, &msg, 0)) {
+	switch (rxrpc_kernel_send_data(afs_socket, call->rxcall, &msg, 0,
+				       afs_notify_end_reply_tx)) {
 	case 0:
 		_leave(" [replied]");
 		return;
@@ -797,7 +820,8 @@ void afs_send_simple_reply(struct afs_call *call, const void *buf, size_t len)
 	msg.msg_flags		= 0;
 
 	call->state = AFS_CALL_AWAIT_ACK;
-	n = rxrpc_kernel_send_data(afs_socket, call->rxcall, &msg, len);
+	n = rxrpc_kernel_send_data(afs_socket, call->rxcall, &msg, len,
+				   afs_notify_end_reply_tx);
 	if (n >= 0) {
 		/* Success */
 		_leave(" [replied]");
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index c172709787af..07a47ee6f783 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -21,6 +21,8 @@ struct rxrpc_call;
 
 typedef void (*rxrpc_notify_rx_t)(struct sock *, struct rxrpc_call *,
 				  unsigned long);
+typedef void (*rxrpc_notify_end_tx_t)(struct sock *, struct rxrpc_call *,
+				      unsigned long);
 typedef void (*rxrpc_notify_new_call_t)(struct sock *, struct rxrpc_call *,
 					unsigned long);
 typedef void (*rxrpc_discard_new_call_t)(struct rxrpc_call *, unsigned long);
@@ -37,7 +39,8 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *,
 					   gfp_t,
 					   rxrpc_notify_rx_t);
 int rxrpc_kernel_send_data(struct socket *, struct rxrpc_call *,
-			   struct msghdr *, size_t);
+			   struct msghdr *, size_t,
+			   rxrpc_notify_end_tx_t);
 int rxrpc_kernel_recv_data(struct socket *, struct rxrpc_call *,
 			   void *, size_t, size_t *, bool, u32 *);
 bool rxrpc_kernel_abort_call(struct socket *, struct rxrpc_call *,
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index bc7f0241d92b..344fdce89823 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -101,11 +101,23 @@ static inline void rxrpc_instant_resend(struct rxrpc_call *call, int ix)
 }
 
 /*
+ * Notify the owner of the call that the transmit phase is ended and the last
+ * packet has been queued.
+ */
+static void rxrpc_notify_end_tx(struct rxrpc_sock *rx, struct rxrpc_call *call,
+				rxrpc_notify_end_tx_t notify_end_tx)
+{
+	if (notify_end_tx)
+		notify_end_tx(&rx->sk, call, call->user_call_ID);
+}
+
+/*
  * Queue a DATA packet for transmission, set the resend timeout and send the
  * packet immediately
  */
-static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
-			       bool last)
+static void rxrpc_queue_packet(struct rxrpc_sock *rx, struct rxrpc_call *call,
+			       struct sk_buff *skb, bool last,
+			       rxrpc_notify_end_tx_t notify_end_tx)
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	rxrpc_seq_t seq = sp->hdr.seq;
@@ -141,6 +153,7 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 		switch (call->state) {
 		case RXRPC_CALL_CLIENT_SEND_REQUEST:
 			call->state = RXRPC_CALL_CLIENT_AWAIT_REPLY;
+			rxrpc_notify_end_tx(rx, call, notify_end_tx);
 			break;
 		case RXRPC_CALL_SERVER_ACK_REQUEST:
 			call->state = RXRPC_CALL_SERVER_SEND_REPLY;
@@ -153,6 +166,7 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 				break;
 		case RXRPC_CALL_SERVER_SEND_REPLY:
 			call->state = RXRPC_CALL_SERVER_AWAIT_ACK;
+			rxrpc_notify_end_tx(rx, call, notify_end_tx);
 			break;
 		default:
 			break;
@@ -189,7 +203,8 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
  */
 static int rxrpc_send_data(struct rxrpc_sock *rx,
 			   struct rxrpc_call *call,
-			   struct msghdr *msg, size_t len)
+			   struct msghdr *msg, size_t len,
+			   rxrpc_notify_end_tx_t notify_end_tx)
 {
 	struct rxrpc_skb_priv *sp;
 	struct sk_buff *skb;
@@ -350,7 +365,9 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 			if (ret < 0)
 				goto out;
 
-			rxrpc_queue_packet(call, skb, !msg_data_left(msg) && !more);
+			rxrpc_queue_packet(rx, call, skb,
+					   !msg_data_left(msg) && !more,
+					   notify_end_tx);
 			skb = NULL;
 		}
 	} while (msg_data_left(msg) > 0);
@@ -611,7 +628,7 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 		/* Reply phase not begun or not complete for service call. */
 		ret = -EPROTO;
 	} else {
-		ret = rxrpc_send_data(rx, call, msg, len);
+		ret = rxrpc_send_data(rx, call, msg, len, NULL);
 	}
 
 	mutex_unlock(&call->user_mutex);
@@ -631,6 +648,7 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
  * @call: The call to send data through
  * @msg: The data to send
  * @len: The amount of data to send
+ * @notify_end_tx: Notification that the last packet is queued.
  *
  * Allow a kernel service to send data on a call.  The call must be in an state
  * appropriate to sending data.  No control data should be supplied in @msg,
@@ -638,7 +656,8 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
  * more data to come, otherwise this data will end the transmission phase.
  */
 int rxrpc_kernel_send_data(struct socket *sock, struct rxrpc_call *call,
-			   struct msghdr *msg, size_t len)
+			   struct msghdr *msg, size_t len,
+			   rxrpc_notify_end_tx_t notify_end_tx)
 {
 	int ret;
 
@@ -656,7 +675,8 @@ int rxrpc_kernel_send_data(struct socket *sock, struct rxrpc_call *call,
 	case RXRPC_CALL_CLIENT_SEND_REQUEST:
 	case RXRPC_CALL_SERVER_ACK_REQUEST:
 	case RXRPC_CALL_SERVER_SEND_REPLY:
-		ret = rxrpc_send_data(rxrpc_sk(sock->sk), call, msg, len);
+		ret = rxrpc_send_data(rxrpc_sk(sock->sk), call, msg, len,
+				      notify_end_tx);
 		break;
 	case RXRPC_CALL_COMPLETE:
 		read_lock_bh(&call->state_lock);
