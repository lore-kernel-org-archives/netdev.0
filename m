From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 5/5] tipc: standardize recvmsg
	routine
Date: Fri, 17 Jan 2014 09:50:07 +0800
Message-ID: <1389923407-26969-6-git-send-email-ying.xue@windriver.com>
References: <1389923407-26969-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1389923407-26969-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Standardize the behaviour of waiting for events in TIPC recvmsg()
so that all variables of socket or port structures are protected
within socket lock, allowing the process of calling recvmsg() to
be woken up at appropriate time.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c |   80 ++++++++++++++++++++++++++++-------------------------
 1 file changed, 42 insertions(+), 38 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index c480310..eab17eb 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -55,9 +55,6 @@ struct tipc_sock {
 #define tipc_sk(sk) ((struct tipc_sock *)(sk))
 #define tipc_sk_port(sk) (tipc_sk(sk)->p)
 
-#define tipc_rx_ready(sock) (!skb_queue_empty(&sock->sk->sk_receive_queue) || \
-			(sock->state == SS_DISCONNECTING))
-
 static int backlog_rcv(struct sock *sk, struct sk_buff *skb);
 static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf);
 static void wakeupdispatch(struct tipc_port *tport);
@@ -994,6 +991,37 @@ static int anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 	return 0;
 }
 
+static int tipc_wait_for_rcvmsg(struct socket *sock, long timeo)
+{
+	struct sock *sk = sock->sk;
+	DEFINE_WAIT(wait);
+	int err;
+
+	for (;;) {
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		if (skb_queue_empty(&sk->sk_receive_queue)) {
+			if (sock->state == SS_DISCONNECTING) {
+				err = -ENOTCONN;
+				break;
+			}
+			release_sock(sk);
+			timeo = schedule_timeout(timeo);
+			lock_sock(sk);
+		}
+		err = 0;
+		if (!skb_queue_empty(&sk->sk_receive_queue))
+			break;
+		err = sock_intr_errno(timeo);
+		if (signal_pending(current))
+			break;
+		err = -EAGAIN;
+		if (!timeo)
+			break;
+	}
+	finish_wait(sk_sleep(sk), &wait);
+	return err;
+}
+
 /**
  * recv_msg - receive packet-oriented message
  * @iocb: (unused)
@@ -1013,7 +1041,7 @@ static int recv_msg(struct kiocb *iocb, struct socket *sock,
 	struct tipc_port *tport = tipc_sk_port(sk);
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
-	long timeout;
+	long timeo;
 	unsigned int sz;
 	u32 err;
 	int res;
@@ -1029,25 +1057,13 @@ static int recv_msg(struct kiocb *iocb, struct socket *sock,
 		goto exit;
 	}
 
-	timeout = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
+	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
 restart:
 
 	/* Look for a message in receive queue; wait if necessary */
-	while (skb_queue_empty(&sk->sk_receive_queue)) {
-		if (sock->state == SS_DISCONNECTING) {
-			res = -ENOTCONN;
-			goto exit;
-		}
-		if (timeout <= 0L) {
-			res = timeout ? timeout : -EWOULDBLOCK;
-			goto exit;
-		}
-		release_sock(sk);
-		timeout = wait_event_interruptible_timeout(*sk_sleep(sk),
-							   tipc_rx_ready(sock),
-							   timeout);
-		lock_sock(sk);
-	}
+	res = tipc_wait_for_rcvmsg(sock, timeo);
+	if (res)
+		goto exit;
 
 	/* Look at first message in receive queue */
 	buf = skb_peek(&sk->sk_receive_queue);
@@ -1119,7 +1135,7 @@ static int recv_stream(struct kiocb *iocb, struct socket *sock,
 	struct tipc_port *tport = tipc_sk_port(sk);
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
-	long timeout;
+	long timeo;
 	unsigned int sz;
 	int sz_to_copy, target, needed;
 	int sz_copied = 0;
@@ -1132,31 +1148,19 @@ static int recv_stream(struct kiocb *iocb, struct socket *sock,
 
 	lock_sock(sk);
 
-	if (unlikely((sock->state == SS_UNCONNECTED))) {
+	if (unlikely(sock->state == SS_UNCONNECTED)) {
 		res = -ENOTCONN;
 		goto exit;
 	}
 
 	target = sock_rcvlowat(sk, flags & MSG_WAITALL, buf_len);
-	timeout = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
+	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
 
 restart:
 	/* Look for a message in receive queue; wait if necessary */
-	while (skb_queue_empty(&sk->sk_receive_queue)) {
-		if (sock->state == SS_DISCONNECTING) {
-			res = -ENOTCONN;
-			goto exit;
-		}
-		if (timeout <= 0L) {
-			res = timeout ? timeout : -EWOULDBLOCK;
-			goto exit;
-		}
-		release_sock(sk);
-		timeout = wait_event_interruptible_timeout(*sk_sleep(sk),
-							   tipc_rx_ready(sock),
-							   timeout);
-		lock_sock(sk);
-	}
+	res = tipc_wait_for_rcvmsg(sock, timeo);
+	if (res)
+		goto exit;
 
 	/* Look at first message in receive queue */
 	buf = skb_peek(&sk->sk_receive_queue);
-- 
1.7.9.5


------------------------------------------------------------------------------
CenturyLink Cloud: The Leader in Enterprise Cloud Services.
Learn Why More Businesses Are Choosing CenturyLink Cloud For
Critical Workloads, Development Environments & Everything In Between.
Get a Quote or Start a Free Trial Today. 
http://pubads.g.doubleclick.net/gampad/clk?id=119420431&iu=/4140/ostg.clktrk
