From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 2/8] tipc: compensate for double
	accounting in socket rcv buffer
Date: Fri,  9 May 2014 09:13:23 -0400
Message-ID: <1399641209-26112-3-git-send-email-jon.maloy@ericsson.com>
References: <1399641209-26112-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1399641209-26112-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The function net/core/sock.c::__release_sock() runs a tight loop
to move buffers from the socket backlog queue to the receive queue.

As a security measure, sk_backlog.len of the receiving socket
is not set to zero until after the loop is finished, i.e., until
the whole backlog queue has been transferred to the receive queue.
During this transfer, the data that has already been moved is counted
both in the backlog queue and the receive queue, hence giving an
incorrect picture of the available queue space for new arriving buffers.

This leads to unnecessary rejection of buffers by sk_add_backlog(),
which in TIPC leads to unnecessarily broken connections.

In this commit, we compensate for this double accounting by adding
a counter that keeps track of it. The function socket.c::backlog_rcv()
receives buffers one by one from __release_sock(), and adds them to the
socket receive queue. If the transfer is successful, it increases a new
atomic counter 'tipc_sock::dupl_rcvcnt' with 'truesize' of the
transferred buffer. If a new buffer arrives during this transfer and
finds the socket busy (owned), we attempt to add it to the backlog.
However, when sk_add_backlog() is called, we adjust the 'limit'
parameter with the value of the new counter, so that the risk of
inadvertent rejection is eliminated.

It should be noted that this change does not invalidate the original
purpose of zeroing 'sk_backlog.len' after the full transfer. We set an
upper limit for dupl_rcvcnt, so that if a 'wild' sender (i.e., one that
doesn't respect the send window) keeps pumping in buffers to
sk_add_backlog(), he will eventually reach an upper limit,
(2 x TIPC_CONN_OVERLOAD_LIMIT). After that, no messages can be added
to the backlog, and the connection will be broken. Ordinary, well-
behaved senders will never will never reach the buffer limit at all.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/socket.c |   28 +++++++++++++++++++---------
 net/tipc/socket.h |    2 ++
 2 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 8685daf..2495006 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1,5 +1,5 @@
 /*
- * net/tipc/socket.c: TIPC socket API
+* net/tipc/socket.c: TIPC socket API
  *
  * Copyright (c) 2001-2007, 2012-2014, Ericsson AB
  * Copyright (c) 2004-2008, 2010-2013, Wind River Systems
@@ -45,7 +45,7 @@
 
 #define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
 
-static int backlog_rcv(struct sock *sk, struct sk_buff *skb);
+static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb);
 static void tipc_data_ready(struct sock *sk);
 static void tipc_write_space(struct sock *sk);
 static int tipc_release(struct socket *sock);
@@ -196,11 +196,12 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	sock->state = state;
 
 	sock_init_data(sock, sk);
-	sk->sk_backlog_rcv = backlog_rcv;
+	sk->sk_backlog_rcv = tipc_backlog_rcv;
 	sk->sk_rcvbuf = sysctl_tipc_rmem[1];
 	sk->sk_data_ready = tipc_data_ready;
 	sk->sk_write_space = tipc_write_space;
-	tipc_sk(sk)->conn_timeout = CONN_TIMEOUT_DEFAULT;
+	tsk->conn_timeout = CONN_TIMEOUT_DEFAULT;
+	atomic_set(&tsk->dupl_rcvcnt, 0);
 	tipc_port_unlock(port);
 
 	if (sock->state == SS_READY) {
@@ -1416,7 +1417,7 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 }
 
 /**
- * backlog_rcv - handle incoming message from backlog queue
+ * tipc_backlog_rcv - handle incoming message from backlog queue
  * @sk: socket
  * @buf: message
  *
@@ -1424,13 +1425,18 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
  *
  * Returns 0
  */
-static int backlog_rcv(struct sock *sk, struct sk_buff *buf)
+static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *buf)
 {
 	u32 res;
+	struct tipc_sock *tsk = tipc_sk(sk);
 
 	res = filter_rcv(sk, buf);
-	if (res)
+	if (unlikely(res))
 		tipc_reject_msg(buf, res);
+
+	if (atomic_read(&tsk->dupl_rcvcnt) < TIPC_CONN_OVERLOAD_LIMIT)
+		atomic_add(buf->truesize, &tsk->dupl_rcvcnt);
+
 	return 0;
 }
 
@@ -1445,8 +1451,9 @@ static int backlog_rcv(struct sock *sk, struct sk_buff *buf)
  */
 u32 tipc_sk_rcv(struct sock *sk, struct sk_buff *buf)
 {
+	struct tipc_sock *tsk = tipc_sk(sk);
 	u32 res;
-
+	uint limit;
 	/*
 	 * Process message if socket is unlocked; otherwise add to backlog queue
 	 *
@@ -1457,7 +1464,10 @@ u32 tipc_sk_rcv(struct sock *sk, struct sk_buff *buf)
 	if (!sock_owned_by_user(sk)) {
 		res = filter_rcv(sk, buf);
 	} else {
-		if (sk_add_backlog(sk, buf, rcvbuf_limit(sk, buf)))
+		if (sk->sk_backlog.len == 0)
+			atomic_set(&tsk->dupl_rcvcnt, 0);
+		limit = rcvbuf_limit(sk, buf) + atomic_read(&tsk->dupl_rcvcnt);
+		if (sk_add_backlog(sk, buf, limit))
 			res = TIPC_ERR_OVERLOAD;
 		else
 			res = TIPC_OK;
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index 74e5c7f..86c27cc 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -44,12 +44,14 @@
  * @port: port - interacts with 'sk' and with the rest of the TIPC stack
  * @peer_name: the peer of the connection, if any
  * @conn_timeout: the time we can wait for an unresponded setup request
+ * @dupl_rcvcnt: number of bytes counted twice, in both backlog and rcv queue
  */
 
 struct tipc_sock {
 	struct sock sk;
 	struct tipc_port port;
 	unsigned int conn_timeout;
+	atomic_t dupl_rcvcnt;
 };
 
 static inline struct tipc_sock *tipc_sk(const struct sock *sk)
-- 
1.7.9.5


------------------------------------------------------------------------------
Is your legacy SCM system holding you back? Join Perforce May 7 to find out:
&#149; 3 signs your SCM is hindering your productivity
&#149; Requirements for releasing software faster
&#149; Expert tips and advice for migrating your SCM now
http://p.sf.net/sfu/perforce
