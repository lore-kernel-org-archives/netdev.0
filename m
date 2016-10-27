From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 10/16] tipc: create
	TIPC_LISTEN as a new sk_state
Date: Thu, 27 Oct 2016 16:22:31 +0200
Message-ID: <1477578157-13256-11-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

Until now, tipc maintains the socket state in sock->state variable.
This is used to maintain generic socket states, but in tipc
we overload it and save tipc socket states like TIPC_LISTEN.
Other protocols like TCP, UDP store protocol specific states
in sk->sk_state instead.

In this commit, we :
- declare a new tipc state TIPC_LISTEN, that replaces SS_LISTEN
- Create a new function tipc_set_state(), to update sk->sk_state.
- TIPC_LISTEN state is maintained in sk->sk_state.
- replace references to SS_LISTEN with TIPC_LISTEN.

There is no functional change in this commit.

Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 include/uapi/linux/tipc.h |  7 ++++++
 net/tipc/socket.c         | 59 ++++++++++++++++++++++++++++++++---------------
 2 files changed, 47 insertions(+), 19 deletions(-)

diff --git a/include/uapi/linux/tipc.h b/include/uapi/linux/tipc.h
index bf049e8fe31b..8a107085f268 100644
--- a/include/uapi/linux/tipc.h
+++ b/include/uapi/linux/tipc.h
@@ -177,6 +177,13 @@ struct tipc_event {
 };
 
 /*
+ *     Definitions for the TIPC protocol sk_state field.
+ */
+enum {
+	TIPC_LISTEN = 1,
+};
+
+/*
  * Socket API
  */
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 6c71951b7d0c..7c9c97363e81 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -44,8 +44,6 @@
 #include "bcast.h"
 #include "netlink.h"
 
-#define SS_LISTENING		-1	/* socket is listening */
-
 #define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
 #define CONN_PROBING_INTERVAL	msecs_to_jiffies(3600000)  /* [ms] => 1 h */
 #define TIPC_FWD_MSG		1
@@ -337,6 +335,32 @@ static bool tsk_peer_msg(struct tipc_sock *tsk, struct tipc_msg *msg)
 	return false;
 }
 
+/* tipc_set_sk_state - set the sk_state of the socket
+ * @sk: socket
+ *
+ * Caller must hold socket lock
+ *
+ * Returns 0 on success, errno otherwise
+ */
+static int tipc_set_sk_state(struct sock *sk, int state)
+{
+	int oldstate = sk->sk_socket->state;
+	int res = -EINVAL;
+
+	switch (state) {
+	case TIPC_LISTEN:
+		if (oldstate == SS_UNCONNECTED)
+			res = 0;
+		break;
+	}
+
+	if (res)
+		return res;
+
+	sk->sk_state = state;
+	return 0;
+}
+
 /**
  * tipc_sk_create - create a TIPC socket
  * @net: network namespace (must be default network)
@@ -666,15 +690,22 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 
 	switch ((int)sock->state) {
 	case SS_UNCONNECTED:
-		if (!tsk->link_cong)
-			mask |= POLLOUT;
+		switch (sk->sk_state) {
+		case TIPC_LISTEN:
+			if (!skb_queue_empty(&sk->sk_receive_queue))
+				mask |= (POLLIN | POLLRDNORM);
+			break;
+		default:
+			if (!tsk->link_cong)
+				mask |= POLLOUT;
+			break;
+		}
 		break;
 	case SS_CONNECTED:
 		if (!tsk->link_cong && !tsk_conn_cong(tsk))
 			mask |= POLLOUT;
 		/* fall thru' */
 	case SS_CONNECTING:
-	case SS_LISTENING:
 		if (!skb_queue_empty(&sk->sk_receive_queue))
 			mask |= (POLLIN | POLLRDNORM);
 		break;
@@ -925,7 +956,7 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 		return -EINVAL;
 	}
 	if (!is_connectionless) {
-		if (sock->state == SS_LISTENING)
+		if (sk->sk_state == TIPC_LISTEN)
 			return -EPIPE;
 		if (sock->state != SS_UNCONNECTED)
 			return -EISCONN;
@@ -1651,7 +1682,6 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 		msg_set_dest_droppable(hdr, 1);
 		return false;
 
-	case SS_LISTENING:
 	case SS_UNCONNECTED:
 
 		/* Accept only SYN message */
@@ -2026,15 +2056,9 @@ static int tipc_listen(struct socket *sock, int len)
 	int res;
 
 	lock_sock(sk);
-
-	if (sock->state != SS_UNCONNECTED)
-		res = -EINVAL;
-	else {
-		sock->state = SS_LISTENING;
-		res = 0;
-	}
-
+	res = tipc_set_sk_state(sk, TIPC_LISTEN);
 	release_sock(sk);
+
 	return res;
 }
 
@@ -2060,9 +2084,6 @@ static int tipc_wait_for_accept(struct socket *sock, long timeo)
 		err = 0;
 		if (!skb_queue_empty(&sk->sk_receive_queue))
 			break;
-		err = -EINVAL;
-		if (sock->state != SS_LISTENING)
-			break;
 		err = -EAGAIN;
 		if (!timeo)
 			break;
@@ -2093,7 +2114,7 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 
 	lock_sock(sk);
 
-	if (sock->state != SS_LISTENING) {
+	if (sk->sk_state != TIPC_LISTEN) {
 		res = -EINVAL;
 		goto exit;
 	}
-- 
2.1.4


------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
