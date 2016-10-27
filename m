From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 13/16] tipc: create
	TIPC_DISCONNECTING as a new sk_state
Date: Thu, 27 Oct 2016 16:22:34 +0200
Message-ID: <1477578157-13256-14-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1477578157-13256-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1477578157-13256-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In this commit, we create a new tipc socket state TIPC_DISCONNECTING in
sk_state. TIPC_DISCONNECTING is replacing the socket connection status
update using SS_DISCONNECTING.
TIPC_DISCONNECTING is set for connection oriented sockets at:
- tipc_shutdown()
- connection probe timeout
- when we receive an error message on the connection.

There is no functional change in this commit.

Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 include/uapi/linux/tipc.h |  1 +
 net/tipc/socket.c         | 39 +++++++++++++++++++++++----------------
 2 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/include/uapi/linux/tipc.h b/include/uapi/linux/tipc.h
index ae45de5e0d93..f5c03fdfc8a8 100644
--- a/include/uapi/linux/tipc.h
+++ b/include/uapi/linux/tipc.h
@@ -184,6 +184,7 @@ enum {
 	TIPC_PROBING,
 	TIPC_ESTABLISHED,
 	TIPC_OPEN,
+	TIPC_DISCONNECTING,
 };
 
 /*
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index da7f7e8244f2..6fef087c4aac 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -359,10 +359,13 @@ static int tipc_set_sk_state(struct sock *sk, int state)
 			res = 0;
 		break;
 	case TIPC_ESTABLISHED:
+		if (oldsk_state == TIPC_OPEN)
+			res = 0;
+		/* fall thru' */
+	case TIPC_DISCONNECTING:
 		if (oldsk_state == TIPC_PROBING ||
 		    oldsk_state == TIPC_ESTABLISHED ||
-		    oldstate == SS_CONNECTING ||
-		    oldsk_state == TIPC_OPEN)
+		    oldstate == SS_CONNECTING)
 			res = 0;
 		break;
 	}
@@ -621,13 +624,14 @@ static int tipc_getname(struct socket *sock, struct sockaddr *uaddr,
 			int *uaddr_len, int peer)
 {
 	struct sockaddr_tipc *addr = (struct sockaddr_tipc *)uaddr;
-	struct tipc_sock *tsk = tipc_sk(sock->sk);
+	struct sock *sk = sock->sk;
+	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_net *tn = net_generic(sock_net(sock->sk), tipc_net_id);
 
 	memset(addr, 0, sizeof(*addr));
 	if (peer) {
 		if ((sock->state != SS_CONNECTED) &&
-			((peer != 2) || (sock->state != SS_DISCONNECTING)))
+		    ((peer != 2) || (sk->sk_state != TIPC_DISCONNECTING)))
 			return -ENOTCONN;
 		addr->addr.id.ref = tsk_peer_port(tsk);
 		addr->addr.id.node = tsk_peer_node(tsk);
@@ -693,6 +697,9 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 			    (!skb_queue_empty(&sk->sk_receive_queue)))
 				mask |= (POLLIN | POLLRDNORM);
 			break;
+		case TIPC_DISCONNECTING:
+			mask = (POLLIN | POLLRDNORM | POLLHUP);
+			break;
 		case TIPC_LISTEN:
 			if (!skb_queue_empty(&sk->sk_receive_queue))
 				mask |= (POLLIN | POLLRDNORM);
@@ -1029,7 +1036,7 @@ static int tipc_wait_for_sndpkt(struct socket *sock, long *timeo_p)
 		int err = sock_error(sk);
 		if (err)
 			return err;
-		if (sock->state == SS_DISCONNECTING)
+		if (sk->sk_state == TIPC_DISCONNECTING)
 			return -EPIPE;
 		else if (sock->state != SS_CONNECTED)
 			return -ENOTCONN;
@@ -1099,7 +1106,7 @@ static int __tipc_send_stream(struct socket *sock, struct msghdr *m, size_t dsz)
 		return -EMSGSIZE;
 
 	if (unlikely(sock->state != SS_CONNECTED)) {
-		if (sock->state == SS_DISCONNECTING)
+		if (sk->sk_state == TIPC_DISCONNECTING)
 			return -EPIPE;
 		else
 			return -ENOTCONN;
@@ -1627,7 +1634,7 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 			return false;
 
 		if (unlikely(msg_errcode(hdr))) {
-			sock->state = SS_DISCONNECTING;
+			tipc_set_sk_state(sk, TIPC_DISCONNECTING);
 			/* Let timer expire on it's own */
 			tipc_node_remove_conn(net, tsk_peer_node(tsk),
 					      tsk->portid);
@@ -1642,13 +1649,13 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 			return false;
 
 		if (unlikely(msg_errcode(hdr))) {
-			sock->state = SS_DISCONNECTING;
+			tipc_set_sk_state(sk, TIPC_DISCONNECTING);
 			sk->sk_err = ECONNREFUSED;
 			return true;
 		}
 
 		if (unlikely(!msg_isdata(hdr))) {
-			sock->state = SS_DISCONNECTING;
+			tipc_set_sk_state(sk, TIPC_DISCONNECTING);
 			sk->sk_err = EINVAL;
 			return true;
 		}
@@ -1675,6 +1682,7 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 
 	switch (sk->sk_state) {
 	case TIPC_OPEN:
+	case TIPC_DISCONNECTING:
 		break;
 	case TIPC_LISTEN:
 		/* Accept only SYN message */
@@ -2196,9 +2204,7 @@ static int tipc_shutdown(struct socket *sock, int how)
 
 	lock_sock(sk);
 
-	switch (sock->state) {
-	case SS_CONNECTING:
-	case SS_CONNECTED:
+	if (sock->state == SS_CONNECTING || sock->state == SS_CONNECTED) {
 
 restart:
 		dnode = tsk_peer_node(tsk);
@@ -2219,11 +2225,12 @@ static int tipc_shutdown(struct socket *sock, int how)
 			if (skb)
 				tipc_node_xmit_skb(net, skb, dnode, tsk->portid);
 		}
-		sock->state = SS_DISCONNECTING;
+		tipc_set_sk_state(sk, TIPC_DISCONNECTING);
 		tipc_node_remove_conn(net, dnode, tsk->portid);
-		/* fall through */
+	}
 
-	case SS_DISCONNECTING:
+	switch (sk->sk_state) {
+	case TIPC_DISCONNECTING:
 
 		/* Discard any unreceived messages */
 		__skb_queue_purge(&sk->sk_receive_queue);
@@ -2259,7 +2266,7 @@ static void tipc_sk_timeout(unsigned long data)
 
 	if (sk->sk_state == TIPC_PROBING) {
 		if (!sock_owned_by_user(sk)) {
-			sk->sk_socket->state = SS_DISCONNECTING;
+			tipc_set_sk_state(sk, TIPC_DISCONNECTING);
 			tipc_node_remove_conn(sock_net(sk), tsk_peer_node(tsk),
 					      tsk_peer_port(tsk));
 			sk->sk_state_change(sk);
-- 
2.1.4


------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
