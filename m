From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 14/16] tipc: create
	TIPC_CLOSING as a new sk_state
Date: Thu, 27 Oct 2016 16:22:35 +0200
Message-ID: <1477578157-13256-15-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

In this commit, we create a new tipc socket state TIPC_CLOSING in
sk_state. We primarily replace all the remaining references to
SS_DISCONNECTING sock->state with TIPC_CLOSING. Thus the FSM for
sockets will be as follows:

For connectionless sockets:
+-----------+       +--------------+
| TIPC_OPEN |------>| TIPC_CLOSING |
+-----------+       +--------------+

For connection oriented sockets:
+-----------+       +------------------+      +--------------+
| TIPC_OPEN |------>| TIPC_XXXX (1..N) |----->| TIPC_CLOSING |
+-----------+       +------------------+      +--------------+

There is no functional change in this commit.

Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 include/uapi/linux/tipc.h |  1 +
 net/tipc/socket.c         | 19 ++++++++-----------
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/include/uapi/linux/tipc.h b/include/uapi/linux/tipc.h
index f5c03fdfc8a8..a45ebf273e76 100644
--- a/include/uapi/linux/tipc.h
+++ b/include/uapi/linux/tipc.h
@@ -185,6 +185,7 @@ enum {
 	TIPC_ESTABLISHED,
 	TIPC_OPEN,
 	TIPC_DISCONNECTING,
+	TIPC_CLOSING,
 };
 
 /*
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 6fef087c4aac..cddf9bca9a90 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -348,6 +348,7 @@ static int tipc_set_sk_state(struct sock *sk, int state)
 
 	switch (state) {
 	case TIPC_OPEN:
+	case TIPC_CLOSING:
 		res = 0;
 		break;
 	case TIPC_LISTEN:
@@ -508,7 +509,7 @@ static int tipc_release(struct socket *sock)
 	 * (which disconnects locally & sends a 'FIN+' to peer)
 	 */
 	dnode = tsk_peer_node(tsk);
-	while (sock->state != SS_DISCONNECTING) {
+	while (sk->sk_state != TIPC_CLOSING) {
 		skb = __skb_dequeue(&sk->sk_receive_queue);
 		if (skb == NULL)
 			break;
@@ -517,7 +518,7 @@ static int tipc_release(struct socket *sock)
 		else {
 			if ((sock->state == SS_CONNECTING) ||
 			    (sock->state == SS_CONNECTED)) {
-				sock->state = SS_DISCONNECTING;
+				tipc_set_sk_state(sk, TIPC_CLOSING);
 				tipc_node_remove_conn(net, dnode, tsk->portid);
 			}
 			tipc_sk_respond(sk, skb, TIPC_ERR_NO_PORT);
@@ -538,7 +539,7 @@ static int tipc_release(struct socket *sock)
 	}
 
 	/* Reject any messages that accumulated in backlog queue */
-	sock->state = SS_DISCONNECTING;
+	tipc_set_sk_state(sk, TIPC_CLOSING);
 	release_sock(sk);
 
 	call_rcu(&tsk->rcu, tipc_sk_callback);
@@ -685,9 +686,6 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 		if (!skb_queue_empty(&sk->sk_receive_queue))
 			mask |= (POLLIN | POLLRDNORM);
 		break;
-	case SS_DISCONNECTING:
-		mask = (POLLIN | POLLRDNORM | POLLHUP);
-		break;
 	default:
 		switch (sk->sk_state) {
 		case TIPC_OPEN:
@@ -697,6 +695,7 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 			    (!skb_queue_empty(&sk->sk_receive_queue)))
 				mask |= (POLLIN | POLLRDNORM);
 			break;
+		case TIPC_CLOSING:
 		case TIPC_DISCONNECTING:
 			mask = (POLLIN | POLLRDNORM | POLLHUP);
 			break;
@@ -881,7 +880,7 @@ static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p)
 		int err = sock_error(sk);
 		if (err)
 			return err;
-		if (sock->state == SS_DISCONNECTING)
+		if (sk->sk_state == TIPC_CLOSING)
 			return -EPIPE;
 		if (!*timeo_p)
 			return -EAGAIN;
@@ -1334,7 +1333,7 @@ static int tipc_wait_for_rcvmsg(struct socket *sock, long *timeop)
 	for (;;) {
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		if (timeo && skb_queue_empty(&sk->sk_receive_queue)) {
-			if (sock->state == SS_DISCONNECTING) {
+			if (sk->sk_state == TIPC_CLOSING) {
 				err = -ENOTCONN;
 				break;
 			}
@@ -1675,13 +1674,11 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 		/* 'ACK-' message is neither accepted nor rejected: */
 		msg_set_dest_droppable(hdr, 1);
 		return false;
-
-	case SS_DISCONNECTING:
-		break;
 	}
 
 	switch (sk->sk_state) {
 	case TIPC_OPEN:
+	case TIPC_CLOSING:
 	case TIPC_DISCONNECTING:
 		break;
 	case TIPC_LISTEN:
-- 
2.1.4


------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
