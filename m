From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH 3/5] VSOCK: use TCP state constants for sk_state
Date: Tue,  3 Oct 2017 11:39:41 -0400
Message-ID: <20171003153943.23159-4-stefanha@redhat.com>
References: <20171003153943.23159-1-stefanha@redhat.com>
Cc: Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35914 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752106AbdJCPkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 11:40:09 -0400
In-Reply-To: <20171003153943.23159-1-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two state fields: socket->state and sock->sk_state.  The
socket->state field uses SS_UNCONNECTED, SS_CONNECTED, etc while the
sock->sk_state typically uses values that match TCP state constants
(TCP_CLOSE, TCP_ESTABLISHED).  AF_VSOCK does not follow this convention
and instead uses SS_* constants for both fields.

The sk_state field will be exposed to userspace through the vsock_diag
interface for ss(8), netstat(8), and other programs.

This patch switches sk_state to TCP state constants so that the meaning
of this field is consistent with other address families.  Not just
AF_INET and AF_INET6 use the TCP constants, AF_UNIX and others do too.

The following mapping was used to convert the code:

  SS_FREE -> TCP_CLOSE
  SS_UNCONNECTED -> TCP_CLOSE
  SS_CONNECTING -> TCP_SYN_SENT
  SS_CONNECTED -> TCP_ESTABLISHED
  SS_DISCONNECTING -> TCP_CLOSING
  VSOCK_SS_LISTEN -> TCP_LISTEN

In __vsock_create() the sk_state initialization was dropped because
sock_init_data() already initializes sk_state to TCP_CLOSE.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/net/af_vsock.h                       |  3 --
 net/vmw_vsock/af_vsock.c                     | 46 ++++++++++++++++------------
 net/vmw_vsock/virtio_transport.c             |  2 +-
 net/vmw_vsock/virtio_transport_common.c      | 22 ++++++-------
 net/vmw_vsock/vmci_transport.c               | 34 ++++++++++----------
 net/vmw_vsock/vmci_transport_notify.c        |  2 +-
 net/vmw_vsock/vmci_transport_notify_qstate.c |  2 +-
 7 files changed, 58 insertions(+), 53 deletions(-)

diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index 88149d580975..eaf45df90d97 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -22,9 +22,6 @@
 
 #include "vsock_addr.h"
 
-/* vsock-specific sock->sk_state constants */
-#define VSOCK_SS_LISTEN 255
-
 #define LAST_RESERVED_PORT 1023
 
 #define VSOCK_HASH_SIZE         251
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index f2d0fb593908..9b76953aeac6 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -36,7 +36,7 @@
  * not support simultaneous connects (two "client" sockets connecting).
  *
  * - "Server" sockets are referred to as listener sockets throughout this
- * implementation because they are in the VSOCK_SS_LISTEN state.  When a
+ * implementation because they are in the TCP_LISTEN state.  When a
  * connection request is received (the second kind of socket mentioned above),
  * we create a new socket and refer to it as a pending socket.  These pending
  * sockets are placed on the pending connection list of the listener socket.
@@ -82,6 +82,15 @@
  * argument, we must ensure the reference count is increased to ensure the
  * socket isn't freed before the function is run; the deferred function will
  * then drop the reference.
+ *
+ * - sk->sk_state uses the TCP state constants because they are widely used by
+ * other address families and exposed to userspace tools like ss(8):
+ *
+ *   TCP_CLOSE - unconnected
+ *   TCP_SYN_SENT - connecting
+ *   TCP_ESTABLISHED - connected
+ *   TCP_CLOSING - disconnecting
+ *   TCP_LISTEN - listening
  */
 
 #include <linux/types.h>
@@ -489,7 +498,7 @@ void vsock_pending_work(struct work_struct *work)
 	if (vsock_in_connected_table(vsk))
 		vsock_remove_connected(vsk);
 
-	sk->sk_state = SS_FREE;
+	sk->sk_state = TCP_CLOSE;
 
 out:
 	release_sock(sk);
@@ -629,7 +638,6 @@ struct sock *__vsock_create(struct net *net,
 
 	sk->sk_destruct = vsock_sk_destruct;
 	sk->sk_backlog_rcv = vsock_queue_rcv_skb;
-	sk->sk_state = 0;
 	sock_reset_flag(sk, SOCK_DONE);
 
 	INIT_LIST_HEAD(&vsk->bound_table);
@@ -903,7 +911,7 @@ static unsigned int vsock_poll(struct file *file, struct socket *sock,
 		/* Listening sockets that have connections in their accept
 		 * queue can be read.
 		 */
-		if (sk->sk_state == VSOCK_SS_LISTEN
+		if (sk->sk_state == TCP_LISTEN
 		    && !vsock_is_accept_queue_empty(sk))
 			mask |= POLLIN | POLLRDNORM;
 
@@ -932,7 +940,7 @@ static unsigned int vsock_poll(struct file *file, struct socket *sock,
 		}
 
 		/* Connected sockets that can produce data can be written. */
-		if (sk->sk_state == SS_CONNECTED) {
+		if (sk->sk_state == TCP_ESTABLISHED) {
 			if (!(sk->sk_shutdown & SEND_SHUTDOWN)) {
 				bool space_avail_now = false;
 				int ret = transport->notify_poll_out(
@@ -954,7 +962,7 @@ static unsigned int vsock_poll(struct file *file, struct socket *sock,
 		 * POLLOUT|POLLWRNORM when peer is closed and nothing to read,
 		 * but local send is not shutdown.
 		 */
-		if (sk->sk_state == SS_UNCONNECTED) {
+		if (sk->sk_state == TCP_CLOSE) {
 			if (!(sk->sk_shutdown & SEND_SHUTDOWN))
 				mask |= POLLOUT | POLLWRNORM;
 
@@ -1124,9 +1132,9 @@ static void vsock_connect_timeout(struct work_struct *work)
 	sk = sk_vsock(vsk);
 
 	lock_sock(sk);
-	if (sk->sk_state == SS_CONNECTING &&
+	if (sk->sk_state == TCP_SYN_SENT &&
 	    (sk->sk_shutdown != SHUTDOWN_MASK)) {
-		sk->sk_state = SS_UNCONNECTED;
+		sk->sk_state = TCP_CLOSE;
 		sk->sk_err = ETIMEDOUT;
 		sk->sk_error_report(sk);
 		cancel = 1;
@@ -1172,7 +1180,7 @@ static int vsock_stream_connect(struct socket *sock, struct sockaddr *addr,
 		err = -EALREADY;
 		break;
 	default:
-		if ((sk->sk_state == VSOCK_SS_LISTEN) ||
+		if ((sk->sk_state == TCP_LISTEN) ||
 		    vsock_addr_cast(addr, addr_len, &remote_addr) != 0) {
 			err = -EINVAL;
 			goto out;
@@ -1195,7 +1203,7 @@ static int vsock_stream_connect(struct socket *sock, struct sockaddr *addr,
 		if (err)
 			goto out;
 
-		sk->sk_state = SS_CONNECTING;
+		sk->sk_state = TCP_SYN_SENT;
 
 		err = transport->connect(vsk);
 		if (err < 0)
@@ -1215,7 +1223,7 @@ static int vsock_stream_connect(struct socket *sock, struct sockaddr *addr,
 	timeout = vsk->connect_timeout;
 	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 
-	while (sk->sk_state != SS_CONNECTED && sk->sk_err == 0) {
+	while (sk->sk_state != TCP_ESTABLISHED && sk->sk_err == 0) {
 		if (flags & O_NONBLOCK) {
 			/* If we're not going to block, we schedule a timeout
 			 * function to generate a timeout on the connection
@@ -1238,13 +1246,13 @@ static int vsock_stream_connect(struct socket *sock, struct sockaddr *addr,
 
 		if (signal_pending(current)) {
 			err = sock_intr_errno(timeout);
-			sk->sk_state = SS_UNCONNECTED;
+			sk->sk_state = TCP_CLOSE;
 			sock->state = SS_UNCONNECTED;
 			vsock_transport_cancel_pkt(vsk);
 			goto out_wait;
 		} else if (timeout == 0) {
 			err = -ETIMEDOUT;
-			sk->sk_state = SS_UNCONNECTED;
+			sk->sk_state = TCP_CLOSE;
 			sock->state = SS_UNCONNECTED;
 			vsock_transport_cancel_pkt(vsk);
 			goto out_wait;
@@ -1255,7 +1263,7 @@ static int vsock_stream_connect(struct socket *sock, struct sockaddr *addr,
 
 	if (sk->sk_err) {
 		err = -sk->sk_err;
-		sk->sk_state = SS_UNCONNECTED;
+		sk->sk_state = TCP_CLOSE;
 		sock->state = SS_UNCONNECTED;
 	} else {
 		err = 0;
@@ -1288,7 +1296,7 @@ static int vsock_accept(struct socket *sock, struct socket *newsock, int flags,
 		goto out;
 	}
 
-	if (listener->sk_state != VSOCK_SS_LISTEN) {
+	if (listener->sk_state != TCP_LISTEN) {
 		err = -EINVAL;
 		goto out;
 	}
@@ -1378,7 +1386,7 @@ static int vsock_listen(struct socket *sock, int backlog)
 	}
 
 	sk->sk_max_ack_backlog = backlog;
-	sk->sk_state = VSOCK_SS_LISTEN;
+	sk->sk_state = TCP_LISTEN;
 
 	err = 0;
 
@@ -1558,7 +1566,7 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 
 	/* Callers should not provide a destination with stream sockets. */
 	if (msg->msg_namelen) {
-		err = sk->sk_state == SS_CONNECTED ? -EISCONN : -EOPNOTSUPP;
+		err = sk->sk_state == TCP_ESTABLISHED ? -EISCONN : -EOPNOTSUPP;
 		goto out;
 	}
 
@@ -1569,7 +1577,7 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 		goto out;
 	}
 
-	if (sk->sk_state != SS_CONNECTED ||
+	if (sk->sk_state != TCP_ESTABLISHED ||
 	    !vsock_addr_bound(&vsk->local_addr)) {
 		err = -ENOTCONN;
 		goto out;
@@ -1693,7 +1701,7 @@ vsock_stream_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 
 	lock_sock(sk);
 
-	if (sk->sk_state != SS_CONNECTED) {
+	if (sk->sk_state != TCP_ESTABLISHED) {
 		/* Recvmsg is supposed to return 0 if a peer performs an
 		 * orderly shutdown. Differentiate between that case and when a
 		 * peer has not connected or a local shutdown occured with the
diff --git a/net/vmw_vsock/virtio_transport.c b/net/vmw_vsock/virtio_transport.c
index 403d86e80162..8e03bd3f3668 100644
--- a/net/vmw_vsock/virtio_transport.c
+++ b/net/vmw_vsock/virtio_transport.c
@@ -414,7 +414,7 @@ static void virtio_vsock_event_fill(struct virtio_vsock *vsock)
 static void virtio_vsock_reset_sock(struct sock *sk)
 {
 	lock_sock(sk);
-	sk->sk_state = SS_UNCONNECTED;
+	sk->sk_state = TCP_CLOSE;
 	sk->sk_err = ECONNRESET;
 	sk->sk_error_report(sk);
 	release_sock(sk);
diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
index edba7ab97563..3ae3a33da70b 100644
--- a/net/vmw_vsock/virtio_transport_common.c
+++ b/net/vmw_vsock/virtio_transport_common.c
@@ -708,7 +708,7 @@ static void virtio_transport_do_close(struct vsock_sock *vsk,
 	sock_set_flag(sk, SOCK_DONE);
 	vsk->peer_shutdown = SHUTDOWN_MASK;
 	if (vsock_stream_has_data(vsk) <= 0)
-		sk->sk_state = SS_DISCONNECTING;
+		sk->sk_state = TCP_CLOSING;
 	sk->sk_state_change(sk);
 
 	if (vsk->close_work_scheduled &&
@@ -748,8 +748,8 @@ static bool virtio_transport_close(struct vsock_sock *vsk)
 {
 	struct sock *sk = &vsk->sk;
 
-	if (!(sk->sk_state == SS_CONNECTED ||
-	      sk->sk_state == SS_DISCONNECTING))
+	if (!(sk->sk_state == TCP_ESTABLISHED ||
+	      sk->sk_state == TCP_CLOSING))
 		return true;
 
 	/* Already received SHUTDOWN from peer, reply with RST */
@@ -801,7 +801,7 @@ virtio_transport_recv_connecting(struct sock *sk,
 
 	switch (le16_to_cpu(pkt->hdr.op)) {
 	case VIRTIO_VSOCK_OP_RESPONSE:
-		sk->sk_state = SS_CONNECTED;
+		sk->sk_state = TCP_ESTABLISHED;
 		sk->sk_socket->state = SS_CONNECTED;
 		vsock_insert_connected(vsk);
 		sk->sk_state_change(sk);
@@ -821,7 +821,7 @@ virtio_transport_recv_connecting(struct sock *sk,
 
 destroy:
 	virtio_transport_reset(vsk, pkt);
-	sk->sk_state = SS_UNCONNECTED;
+	sk->sk_state = TCP_CLOSE;
 	sk->sk_err = skerr;
 	sk->sk_error_report(sk);
 	return err;
@@ -857,7 +857,7 @@ virtio_transport_recv_connected(struct sock *sk,
 			vsk->peer_shutdown |= SEND_SHUTDOWN;
 		if (vsk->peer_shutdown == SHUTDOWN_MASK &&
 		    vsock_stream_has_data(vsk) <= 0)
-			sk->sk_state = SS_DISCONNECTING;
+			sk->sk_state = TCP_CLOSING;
 		if (le32_to_cpu(pkt->hdr.flags))
 			sk->sk_state_change(sk);
 		break;
@@ -928,7 +928,7 @@ virtio_transport_recv_listen(struct sock *sk, struct virtio_vsock_pkt *pkt)
 
 	lock_sock_nested(child, SINGLE_DEPTH_NESTING);
 
-	child->sk_state = SS_CONNECTED;
+	child->sk_state = TCP_ESTABLISHED;
 
 	vchild = vsock_sk(child);
 	vsock_addr_init(&vchild->local_addr, le64_to_cpu(pkt->hdr.dst_cid),
@@ -1016,18 +1016,18 @@ void virtio_transport_recv_pkt(struct virtio_vsock_pkt *pkt)
 		sk->sk_write_space(sk);
 
 	switch (sk->sk_state) {
-	case VSOCK_SS_LISTEN:
+	case TCP_LISTEN:
 		virtio_transport_recv_listen(sk, pkt);
 		virtio_transport_free_pkt(pkt);
 		break;
-	case SS_CONNECTING:
+	case TCP_SYN_SENT:
 		virtio_transport_recv_connecting(sk, pkt);
 		virtio_transport_free_pkt(pkt);
 		break;
-	case SS_CONNECTED:
+	case TCP_ESTABLISHED:
 		virtio_transport_recv_connected(sk, pkt);
 		break;
-	case SS_DISCONNECTING:
+	case TCP_CLOSING:
 		virtio_transport_recv_disconnecting(sk, pkt);
 		virtio_transport_free_pkt(pkt);
 		break;
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 10ae7823a19d..9cb3a6c780aa 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -743,7 +743,7 @@ static int vmci_transport_recv_stream_cb(void *data, struct vmci_datagram *dg)
 		/* The local context ID may be out of date, update it. */
 		vsk->local_addr.svm_cid = dst.svm_cid;
 
-		if (sk->sk_state == SS_CONNECTED)
+		if (sk->sk_state == TCP_ESTABLISHED)
 			vmci_trans(vsk)->notify_ops->handle_notify_pkt(
 					sk, pkt, true, &dst, &src,
 					&bh_process_pkt);
@@ -801,7 +801,9 @@ static void vmci_transport_handle_detach(struct sock *sk)
 		 * left in our consume queue.
 		 */
 		if (vsock_stream_has_data(vsk) <= 0) {
-			if (sk->sk_state == SS_CONNECTING) {
+			sk->sk_state = TCP_CLOSE;
+
+			if (sk->sk_state == TCP_SYN_SENT) {
 				/* The peer may detach from a queue pair while
 				 * we are still in the connecting state, i.e.,
 				 * if the peer VM is killed after attaching to
@@ -810,12 +812,10 @@ static void vmci_transport_handle_detach(struct sock *sk)
 				 * event like a reset.
 				 */
 
-				sk->sk_state = SS_UNCONNECTED;
 				sk->sk_err = ECONNRESET;
 				sk->sk_error_report(sk);
 				return;
 			}
-			sk->sk_state = SS_UNCONNECTED;
 		}
 		sk->sk_state_change(sk);
 	}
@@ -883,17 +883,17 @@ static void vmci_transport_recv_pkt_work(struct work_struct *work)
 	vsock_sk(sk)->local_addr.svm_cid = pkt->dg.dst.context;
 
 	switch (sk->sk_state) {
-	case VSOCK_SS_LISTEN:
+	case TCP_LISTEN:
 		vmci_transport_recv_listen(sk, pkt);
 		break;
-	case SS_CONNECTING:
+	case TCP_SYN_SENT:
 		/* Processing of pending connections for servers goes through
 		 * the listening socket, so see vmci_transport_recv_listen()
 		 * for that path.
 		 */
 		vmci_transport_recv_connecting_client(sk, pkt);
 		break;
-	case SS_CONNECTED:
+	case TCP_ESTABLISHED:
 		vmci_transport_recv_connected(sk, pkt);
 		break;
 	default:
@@ -942,7 +942,7 @@ static int vmci_transport_recv_listen(struct sock *sk,
 		vsock_sk(pending)->local_addr.svm_cid = pkt->dg.dst.context;
 
 		switch (pending->sk_state) {
-		case SS_CONNECTING:
+		case TCP_SYN_SENT:
 			err = vmci_transport_recv_connecting_server(sk,
 								    pending,
 								    pkt);
@@ -1072,7 +1072,7 @@ static int vmci_transport_recv_listen(struct sock *sk,
 	vsock_add_pending(sk, pending);
 	sk->sk_ack_backlog++;
 
-	pending->sk_state = SS_CONNECTING;
+	pending->sk_state = TCP_SYN_SENT;
 	vmci_trans(vpending)->produce_size =
 		vmci_trans(vpending)->consume_size = qp_size;
 	vmci_trans(vpending)->queue_pair_size = qp_size;
@@ -1197,11 +1197,11 @@ vmci_transport_recv_connecting_server(struct sock *listener,
 	 * the socket will be valid until it is removed from the queue.
 	 *
 	 * If we fail sending the attach below, we remove the socket from the
-	 * connected list and move the socket to SS_UNCONNECTED before
+	 * connected list and move the socket to TCP_CLOSE before
 	 * releasing the lock, so a pending slow path processing of an incoming
 	 * packet will not see the socket in the connected state in that case.
 	 */
-	pending->sk_state = SS_CONNECTED;
+	pending->sk_state = TCP_ESTABLISHED;
 
 	vsock_insert_connected(vpending);
 
@@ -1232,7 +1232,7 @@ vmci_transport_recv_connecting_server(struct sock *listener,
 
 destroy:
 	pending->sk_err = skerr;
-	pending->sk_state = SS_UNCONNECTED;
+	pending->sk_state = TCP_CLOSE;
 	/* As long as we drop our reference, all necessary cleanup will handle
 	 * when the cleanup function drops its reference and our destruct
 	 * implementation is called.  Note that since the listen handler will
@@ -1270,7 +1270,7 @@ vmci_transport_recv_connecting_client(struct sock *sk,
 		 * accounting (it can already be found since it's in the bound
 		 * table).
 		 */
-		sk->sk_state = SS_CONNECTED;
+		sk->sk_state = TCP_ESTABLISHED;
 		sk->sk_socket->state = SS_CONNECTED;
 		vsock_insert_connected(vsk);
 		sk->sk_state_change(sk);
@@ -1338,7 +1338,7 @@ vmci_transport_recv_connecting_client(struct sock *sk,
 destroy:
 	vmci_transport_send_reset(sk, pkt);
 
-	sk->sk_state = SS_UNCONNECTED;
+	sk->sk_state = TCP_CLOSE;
 	sk->sk_err = skerr;
 	sk->sk_error_report(sk);
 	return err;
@@ -1526,7 +1526,7 @@ static int vmci_transport_recv_connected(struct sock *sk,
 		sock_set_flag(sk, SOCK_DONE);
 		vsk->peer_shutdown = SHUTDOWN_MASK;
 		if (vsock_stream_has_data(vsk) <= 0)
-			sk->sk_state = SS_DISCONNECTING;
+			sk->sk_state = TCP_CLOSING;
 
 		sk->sk_state_change(sk);
 		break;
@@ -1790,7 +1790,7 @@ static int vmci_transport_connect(struct vsock_sock *vsk)
 		err = vmci_transport_send_conn_request(
 			sk, vmci_trans(vsk)->queue_pair_size);
 		if (err < 0) {
-			sk->sk_state = SS_UNCONNECTED;
+			sk->sk_state = TCP_CLOSE;
 			return err;
 		}
 	} else {
@@ -1800,7 +1800,7 @@ static int vmci_transport_connect(struct vsock_sock *vsk)
 				sk, vmci_trans(vsk)->queue_pair_size,
 				supported_proto_versions);
 		if (err < 0) {
-			sk->sk_state = SS_UNCONNECTED;
+			sk->sk_state = TCP_CLOSE;
 			return err;
 		}
 
diff --git a/net/vmw_vsock/vmci_transport_notify.c b/net/vmw_vsock/vmci_transport_notify.c
index 1406db4d97d1..41fb427f150a 100644
--- a/net/vmw_vsock/vmci_transport_notify.c
+++ b/net/vmw_vsock/vmci_transport_notify.c
@@ -355,7 +355,7 @@ vmci_transport_notify_pkt_poll_in(struct sock *sk,
 		 * queue. Ask for notifications when there is something to
 		 * read.
 		 */
-		if (sk->sk_state == SS_CONNECTED) {
+		if (sk->sk_state == TCP_ESTABLISHED) {
 			if (!send_waiting_read(sk, 1))
 				return -1;
 
diff --git a/net/vmw_vsock/vmci_transport_notify_qstate.c b/net/vmw_vsock/vmci_transport_notify_qstate.c
index f3a0afc46208..0cc84f2bb05e 100644
--- a/net/vmw_vsock/vmci_transport_notify_qstate.c
+++ b/net/vmw_vsock/vmci_transport_notify_qstate.c
@@ -176,7 +176,7 @@ vmci_transport_notify_pkt_poll_in(struct sock *sk,
 		 * queue. Ask for notifications when there is something to
 		 * read.
 		 */
-		if (sk->sk_state == SS_CONNECTED)
+		if (sk->sk_state == TCP_ESTABLISHED)
 			vsock_block_update_write_window(sk);
 		*data_ready_now = false;
 	}
-- 
2.13.6
