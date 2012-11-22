From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 1/9] tipc: fix race/inefficiencies in poll/wait behaviour
Date: Thu, 22 Nov 2012 15:59:46 -0500
Message-ID: <1353617994-3962-2-git-send-email-paul.gortmaker@windriver.com>
References: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:59963 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757329Ab2KVVAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 16:00:03 -0500
In-Reply-To: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

When an application blocks at poll/select on a TIPC socket
while requesting a specific event mask, both the filter_rcv() and
wakeupdispatch() case will wake it up unconditionally whenever
the state changes (i.e an incoming message arrives, or congestion
has subsided).  No mask is used.

To avoid this, we populate sk->sk_data_ready and sk->sk_write_space
with tipc_data_ready and tipc_write_space respectively, which makes
tipc more in alignment with the rest of the networking code.  These
pass the exact set of possible events to the waker in fs/select.c
hence avoiding waking up blocked processes unnecessarily.

In doing so, we uncover another issue -- that there needs to be a
memory barrier in these poll/receive callbacks, otherwise we are
subject to the the same race as documented above wq_has_sleeper()
[in commit a57de0b4 "net: adding memory barrier to the poll and
receive callbacks"].  So we need to replace poll_wait() with
sock_poll_wait() and use rcu protection for the sk->sk_wq pointer
in these two new functions.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c | 45 ++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 40 insertions(+), 5 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index fd5f042..b5fc8ed 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -62,6 +62,8 @@ struct tipc_sock {
 static int backlog_rcv(struct sock *sk, struct sk_buff *skb);
 static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf);
 static void wakeupdispatch(struct tipc_port *tport);
+static void tipc_data_ready(struct sock *sk, int len);
+static void tipc_write_space(struct sock *sk);
 
 static const struct proto_ops packet_ops;
 static const struct proto_ops stream_ops;
@@ -221,6 +223,8 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol,
 	sock_init_data(sock, sk);
 	sk->sk_backlog_rcv = backlog_rcv;
 	sk->sk_rcvbuf = TIPC_FLOW_CONTROL_WIN * 2 * TIPC_MAX_USER_MSG_SIZE * 2;
+	sk->sk_data_ready = tipc_data_ready;
+	sk->sk_write_space = tipc_write_space;
 	tipc_sk(sk)->p = tp_ptr;
 	tipc_sk(sk)->conn_timeout = CONN_TIMEOUT_DEFAULT;
 
@@ -435,7 +439,7 @@ static unsigned int poll(struct file *file, struct socket *sock,
 	struct sock *sk = sock->sk;
 	u32 mask = 0;
 
-	poll_wait(file, sk_sleep(sk), wait);
+	sock_poll_wait(file, sk_sleep(sk), wait);
 
 	switch ((int)sock->state) {
 	case SS_READY:
@@ -1126,6 +1130,39 @@ exit:
 }
 
 /**
+ * tipc_write_space - wake up thread if port congestion is released
+ * @sk: socket
+ */
+static void tipc_write_space(struct sock *sk)
+{
+	struct socket_wq *wq;
+
+	rcu_read_lock();
+	wq = rcu_dereference(sk->sk_wq);
+	if (wq_has_sleeper(wq))
+		wake_up_interruptible_sync_poll(&wq->wait, POLLOUT |
+						POLLWRNORM | POLLWRBAND);
+	rcu_read_unlock();
+}
+
+/**
+ * tipc_data_ready - wake up threads to indicate messages have been received
+ * @sk: socket
+ * @len: the length of messages
+ */
+static void tipc_data_ready(struct sock *sk, int len)
+{
+	struct socket_wq *wq;
+
+	rcu_read_lock();
+	wq = rcu_dereference(sk->sk_wq);
+	if (wq_has_sleeper(wq))
+		wake_up_interruptible_sync_poll(&wq->wait, POLLIN |
+						POLLRDNORM | POLLRDBAND);
+	rcu_read_unlock();
+}
+
+/**
  * rx_queue_full - determine if receive queue can accept another message
  * @msg: message to be added to queue
  * @queue_size: current size of queue
@@ -1222,8 +1259,7 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 		tipc_disconnect_port(tipc_sk_port(sk));
 	}
 
-	if (waitqueue_active(sk_sleep(sk)))
-		wake_up_interruptible(sk_sleep(sk));
+	sk->sk_data_ready(sk, 0);
 	return TIPC_OK;
 }
 
@@ -1290,8 +1326,7 @@ static void wakeupdispatch(struct tipc_port *tport)
 {
 	struct sock *sk = (struct sock *)tport->usr_handle;
 
-	if (waitqueue_active(sk_sleep(sk)))
-		wake_up_interruptible(sk_sleep(sk));
+	sk->sk_write_space(sk);
 }
 
 /**
-- 
1.7.12.1
