From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH] VSOCK: define VSOCK_SS_LISTEN once only
Date: Thu, 29 Oct 2015 11:57:42 +0000
Message-ID: <1446119862-24369-1-git-send-email-stefanha@redhat.com>
Cc: pv-drivers@vmware.com, linux-kernel@vger.kernel.org,
	davem@davemloft.net, jhansen@vmware.com,
	virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SS_LISTEN socket state is defined by both af_vsock.c and
vmci_transport.c.  This is risky since the value could be changed in one
file and the other would be out of sync.

Rename from SS_LISTEN to VSOCK_SS_LISTEN since the constant is not part
of enum socket_state (SS_CONNECTED, ...).  This way it is clear that the
constant is vsock-specific.

The big text reflow in af_vsock.c was necessary to keep to the maximum
line length.  Text is unchanged except for s/SS_LISTEN/VSOCK_SS_LISTEN/.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/net/af_vsock.h         |  3 +++
 net/vmw_vsock/af_vsock.c       | 37 ++++++++++++++++++-------------------
 net/vmw_vsock/vmci_transport.c |  4 +---
 3 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index db639a4..e9eb2d6 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -22,6 +22,9 @@
 
 #include "vsock_addr.h"
 
+/* vsock-specific sock->sk_state constants */
+#define VSOCK_SS_LISTEN 255
+
 #define LAST_RESERVED_PORT 1023
 
 #define vsock_sk(__sk)    ((struct vsock_sock *)__sk)
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index df5fc6b..65f2c9c 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -36,19 +36,20 @@
  * not support simultaneous connects (two "client" sockets connecting).
  *
  * - "Server" sockets are referred to as listener sockets throughout this
- * implementation because they are in the SS_LISTEN state.  When a connection
- * request is received (the second kind of socket mentioned above), we create a
- * new socket and refer to it as a pending socket.  These pending sockets are
- * placed on the pending connection list of the listener socket.  When future
- * packets are received for the address the listener socket is bound to, we
- * check if the source of the packet is from one that has an existing pending
- * connection.  If it does, we process the packet for the pending socket.  When
- * that socket reaches the connected state, it is removed from the listener
- * socket's pending list and enqueued in the listener socket's accept queue.
- * Callers of accept(2) will accept connected sockets from the listener socket's
- * accept queue.  If the socket cannot be accepted for some reason then it is
- * marked rejected.  Once the connection is accepted, it is owned by the user
- * process and the responsibility for cleanup falls with that user process.
+ * implementation because they are in the VSOCK_SS_LISTEN state.  When a
+ * connection request is received (the second kind of socket mentioned above),
+ * we create a new socket and refer to it as a pending socket.  These pending
+ * sockets are placed on the pending connection list of the listener socket.
+ * When future packets are received for the address the listener socket is
+ * bound to, we check if the source of the packet is from one that has an
+ * existing pending connection.  If it does, we process the packet for the
+ * pending socket.  When that socket reaches the connected state, it is removed
+ * from the listener socket's pending list and enqueued in the listener
+ * socket's accept queue.  Callers of accept(2) will accept connected sockets
+ * from the listener socket's accept queue.  If the socket cannot be accepted
+ * for some reason then it is marked rejected.  Once the connection is
+ * accepted, it is owned by the user process and the responsibility for cleanup
+ * falls with that user process.
  *
  * - It is possible that these pending sockets will never reach the connected
  * state; in fact, we may never receive another packet after the connection
@@ -114,8 +115,6 @@ static struct proto vsock_proto = {
  */
 #define VSOCK_DEFAULT_CONNECT_TIMEOUT (2 * HZ)
 
-#define SS_LISTEN 255
-
 static const struct vsock_transport *transport;
 static DEFINE_MUTEX(vsock_register_mutex);
 
@@ -887,7 +886,7 @@ static unsigned int vsock_poll(struct file *file, struct socket *sock,
 		/* Listening sockets that have connections in their accept
 		 * queue can be read.
 		 */
-		if (sk->sk_state == SS_LISTEN
+		if (sk->sk_state == VSOCK_SS_LISTEN
 		    && !vsock_is_accept_queue_empty(sk))
 			mask |= POLLIN | POLLRDNORM;
 
@@ -1144,7 +1143,7 @@ static int vsock_stream_connect(struct socket *sock, struct sockaddr *addr,
 		err = -EALREADY;
 		break;
 	default:
-		if ((sk->sk_state == SS_LISTEN) ||
+		if ((sk->sk_state == VSOCK_SS_LISTEN) ||
 		    vsock_addr_cast(addr, addr_len, &remote_addr) != 0) {
 			err = -EINVAL;
 			goto out;
@@ -1256,7 +1255,7 @@ static int vsock_accept(struct socket *sock, struct socket *newsock, int flags)
 		goto out;
 	}
 
-	if (listener->sk_state != SS_LISTEN) {
+	if (listener->sk_state != VSOCK_SS_LISTEN) {
 		err = -EINVAL;
 		goto out;
 	}
@@ -1348,7 +1347,7 @@ static int vsock_listen(struct socket *sock, int backlog)
 	}
 
 	sk->sk_max_ack_backlog = backlog;
-	sk->sk_state = SS_LISTEN;
+	sk->sk_state = VSOCK_SS_LISTEN;
 
 	err = 0;
 
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 1f63daf..70cc89b 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -90,8 +90,6 @@ static int PROTOCOL_OVERRIDE = -1;
  */
 #define VSOCK_DEFAULT_CONNECT_TIMEOUT (2 * HZ)
 
-#define SS_LISTEN 255
-
 /* Helper function to convert from a VMCI error code to a VSock error code. */
 
 static s32 vmci_transport_error_to_vsock_error(s32 vmci_error)
@@ -919,7 +917,7 @@ static void vmci_transport_recv_pkt_work(struct work_struct *work)
 	vsock_sk(sk)->local_addr.svm_cid = pkt->dg.dst.context;
 
 	switch (sk->sk_state) {
-	case SS_LISTEN:
+	case VSOCK_SS_LISTEN:
 		vmci_transport_recv_listen(sk, pkt);
 		break;
 	case SS_CONNECTING:
-- 
2.4.3
