From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 2/9] tipc: simplify message
	forwarding and rejection in socket layer
Date: Thu,  5 Feb 2015 08:36:37 -0500
Message-ID: <1423143404-23322-3-git-send-email-jon.maloy@ericsson.com>
References: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Despite recent improvements, the handling of error codes and return
values at reception of messages in the socket layer is still confusing.

In this commit, we try to make it more comprehensible. First, we
separate between the return values coming from the functions called
by tipc_sk_rcv(), -those are TIPC specific error codes, and the
return values returned by tipc_sk_rcv() itself. Second, we don't
use the returned TIPC error code as indication for whether a buffer
should be forwarded/rejected or not; instead we use the buffer pointer
passed along with filter_msg(). This separation is necessary because
we sometimes want to forward messages even when there is no error
(i.e., protocol messages and successfully secondary looked up data
messages).

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 120 ++++++++++++++++++++++++++----------------------------
 1 file changed, 58 insertions(+), 62 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index b384e65..f9cd587 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -818,17 +818,14 @@ void tipc_sk_mcast_rcv(struct net *net, struct sk_buff *buf)
 /**
  * tipc_sk_proto_rcv - receive a connection mng protocol message
  * @tsk: receiving socket
- * @dnode: node to send response message to, if any
- * @buf: buffer containing protocol message
- * Returns 0 (TIPC_OK) if message was consumed, 1 (TIPC_FWD_MSG) if
- * (CONN_PROBE_REPLY) message should be forwarded.
+ * @skb: pointer to message buffer. Set to NULL if buffer is consumed.
  */
-static int tipc_sk_proto_rcv(struct tipc_sock *tsk, u32 *dnode,
-			     struct sk_buff *buf)
+static void tipc_sk_proto_rcv(struct tipc_sock *tsk, struct sk_buff **skb)
 {
-	struct tipc_msg *msg = buf_msg(buf);
+	struct tipc_msg *msg = buf_msg(*skb);
 	int conn_cong;
-
+	u32 dnode;
+	u32 own_node = tsk_own_node(tsk);
 	/* Ignore if connection cannot be validated: */
 	if (!tsk_peer_msg(tsk, msg))
 		goto exit;
@@ -841,15 +838,15 @@ static int tipc_sk_proto_rcv(struct tipc_sock *tsk, u32 *dnode,
 		if (conn_cong)
 			tsk->sk.sk_write_space(&tsk->sk);
 	} else if (msg_type(msg) == CONN_PROBE) {
-		if (!tipc_msg_reverse(tsk_own_node(tsk), buf, dnode, TIPC_OK))
-			return TIPC_OK;
-		msg_set_type(msg, CONN_PROBE_REPLY);
-		return TIPC_FWD_MSG;
+		if (tipc_msg_reverse(own_node, *skb, &dnode, TIPC_OK)) {
+			msg_set_type(msg, CONN_PROBE_REPLY);
+			return;
+		}
 	}
 	/* Do nothing if msg_type() == CONN_PROBE_REPLY */
 exit:
-	kfree_skb(buf);
-	return TIPC_OK;
+	kfree_skb(*skb);
+	*skb = NULL;
 }
 
 static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p)
@@ -1568,16 +1565,16 @@ static void tipc_data_ready(struct sock *sk)
 /**
  * filter_connect - Handle all incoming messages for a connection-based socket
  * @tsk: TIPC socket
- * @msg: message
+ * @skb: pointer to message buffer. Set to NULL if buffer is consumed
  *
  * Returns 0 (TIPC_OK) if everything ok, -TIPC_ERR_NO_PORT otherwise
  */
-static int filter_connect(struct tipc_sock *tsk, struct sk_buff **buf)
+static int filter_connect(struct tipc_sock *tsk, struct sk_buff **skb)
 {
 	struct sock *sk = &tsk->sk;
 	struct net *net = sock_net(sk);
 	struct socket *sock = sk->sk_socket;
-	struct tipc_msg *msg = buf_msg(*buf);
+	struct tipc_msg *msg = buf_msg(*skb);
 	int retval = -TIPC_ERR_NO_PORT;
 
 	if (msg_mcast(msg))
@@ -1627,8 +1624,8 @@ static int filter_connect(struct tipc_sock *tsk, struct sk_buff **buf)
 		 * connect() routine if sleeping.
 		 */
 		if (msg_data_sz(msg) == 0) {
-			kfree_skb(*buf);
-			*buf = NULL;
+			kfree_skb(*skb);
+			*skb = NULL;
 			if (waitqueue_active(sk_sleep(sk)))
 				wake_up_interruptible(sk_sleep(sk));
 		}
@@ -1680,32 +1677,33 @@ static unsigned int rcvbuf_limit(struct sock *sk, struct sk_buff *buf)
 /**
  * filter_rcv - validate incoming message
  * @sk: socket
- * @buf: message
+ * @skb: pointer to message. Set to NULL if buffer is consumed.
  *
  * Enqueues message on receive queue if acceptable; optionally handles
  * disconnect indication for a connected socket.
  *
- * Called with socket lock already taken; port lock may also be taken.
+ * Called with socket lock already taken
  *
- * Returns 0 (TIPC_OK) if message was consumed, -TIPC error code if message
- * to be rejected, 1 (TIPC_FWD_MSG) if (CONN_MANAGER) message to be forwarded
+ * Returns 0 (TIPC_OK) if message was ok, -TIPC error code if rejected
  */
-static int filter_rcv(struct sock *sk, struct sk_buff *buf)
+static int filter_rcv(struct sock *sk, struct sk_buff **skb)
 {
 	struct socket *sock = sk->sk_socket;
 	struct tipc_sock *tsk = tipc_sk(sk);
-	struct tipc_msg *msg = buf_msg(buf);
-	unsigned int limit = rcvbuf_limit(sk, buf);
-	u32 onode;
+	struct tipc_msg *msg = buf_msg(*skb);
+	unsigned int limit = rcvbuf_limit(sk, *skb);
 	int rc = TIPC_OK;
 
-	if (unlikely(msg_user(msg) == CONN_MANAGER))
-		return tipc_sk_proto_rcv(tsk, &onode, buf);
+	if (unlikely(msg_user(msg) == CONN_MANAGER)) {
+		tipc_sk_proto_rcv(tsk, skb);
+		return TIPC_OK;
+	}
 
 	if (unlikely(msg_user(msg) == SOCK_WAKEUP)) {
-		kfree_skb(buf);
+		kfree_skb(*skb);
 		tsk->link_cong = 0;
 		sk->sk_write_space(sk);
+		*skb = NULL;
 		return TIPC_OK;
 	}
 
@@ -1717,21 +1715,22 @@ static int filter_rcv(struct sock *sk, struct sk_buff *buf)
 		if (msg_connected(msg))
 			return -TIPC_ERR_NO_PORT;
 	} else {
-		rc = filter_connect(tsk, &buf);
-		if (rc != TIPC_OK || buf == NULL)
+		rc = filter_connect(tsk, skb);
+		if (rc != TIPC_OK || !*skb)
 			return rc;
 	}
 
 	/* Reject message if there isn't room to queue it */
-	if (sk_rmem_alloc_get(sk) + buf->truesize >= limit)
+	if (sk_rmem_alloc_get(sk) + (*skb)->truesize >= limit)
 		return -TIPC_ERR_OVERLOAD;
 
 	/* Enqueue message */
-	TIPC_SKB_CB(buf)->handle = NULL;
-	__skb_queue_tail(&sk->sk_receive_queue, buf);
-	skb_set_owner_r(buf, sk);
+	TIPC_SKB_CB(*skb)->handle = NULL;
+	__skb_queue_tail(&sk->sk_receive_queue, *skb);
+	skb_set_owner_r(*skb, sk);
 
 	sk->sk_data_ready(sk);
+	*skb = NULL;
 	return TIPC_OK;
 }
 
@@ -1746,25 +1745,22 @@ static int filter_rcv(struct sock *sk, struct sk_buff *buf)
  */
 static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
-	int rc;
-	u32 onode;
+	int err;
+	atomic_t *dcnt;
+	u32 dnode;
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct net *net = sock_net(sk);
 	uint truesize = skb->truesize;
 
-	rc = filter_rcv(sk, skb);
-
-	if (likely(!rc)) {
-		if (atomic_read(&tsk->dupl_rcvcnt) < TIPC_CONN_OVERLOAD_LIMIT)
-			atomic_add(truesize, &tsk->dupl_rcvcnt);
+	err = filter_rcv(sk, &skb);
+	if (likely(!skb)) {
+		dcnt = &tsk->dupl_rcvcnt;
+		if (atomic_read(dcnt) < TIPC_CONN_OVERLOAD_LIMIT)
+			atomic_add(truesize, dcnt);
 		return 0;
 	}
-
-	if ((rc < 0) && !tipc_msg_reverse(tsk_own_node(tsk), skb, &onode, -rc))
-		return 0;
-
-	tipc_link_xmit_skb(net, skb, onode, 0);
-
+	if (!err || tipc_msg_reverse(tsk_own_node(tsk), skb, &dnode, -err))
+		tipc_link_xmit_skb(net, skb, dnode, tsk->portid);
 	return 0;
 }
 
@@ -1780,14 +1776,14 @@ int tipc_sk_rcv(struct net *net, struct sk_buff *skb)
 	struct tipc_net *tn;
 	struct sock *sk;
 	u32 dport = msg_destport(buf_msg(skb));
-	int rc = TIPC_OK;
+	int err = TIPC_OK;
 	uint limit;
 	u32 dnode;
 
 	/* Validate destination and message */
 	tsk = tipc_sk_lookup(net, dport);
 	if (unlikely(!tsk)) {
-		rc = tipc_msg_eval(net, skb, &dnode);
+		err = tipc_msg_eval(net, skb, &dnode);
 		goto exit;
 	}
 	sk = &tsk->sk;
@@ -1796,25 +1792,25 @@ int tipc_sk_rcv(struct net *net, struct sk_buff *skb)
 	spin_lock_bh(&sk->sk_lock.slock);
 
 	if (!sock_owned_by_user(sk)) {
-		rc = filter_rcv(sk, skb);
+		err = filter_rcv(sk, &skb);
 	} else {
 		if (sk->sk_backlog.len == 0)
 			atomic_set(&tsk->dupl_rcvcnt, 0);
 		limit = rcvbuf_limit(sk, skb) + atomic_read(&tsk->dupl_rcvcnt);
-		if (sk_add_backlog(sk, skb, limit))
-			rc = -TIPC_ERR_OVERLOAD;
+		if (likely(!sk_add_backlog(sk, skb, limit)))
+			skb = NULL;
+		else
+			err = -TIPC_ERR_OVERLOAD;
 	}
 	spin_unlock_bh(&sk->sk_lock.slock);
 	sock_put(sk);
-	if (likely(!rc))
-		return 0;
 exit:
-	tn = net_generic(net, tipc_net_id);
-	if ((rc < 0) && !tipc_msg_reverse(tn->own_addr, skb, &dnode, -rc))
-		return -EHOSTUNREACH;
-
-	tipc_link_xmit_skb(net, skb, dnode, 0);
-	return (rc < 0) ? -EHOSTUNREACH : 0;
+	if (unlikely(skb)) {
+		tn = net_generic(net, tipc_net_id);
+		if (!err || tipc_msg_reverse(tn->own_addr, skb, &dnode, -err))
+			tipc_link_xmit_skb(net, skb, dnode, 0);
+	}
+	return err ? -EHOSTUNREACH : 0;
 }
 
 static int tipc_wait_for_connect(struct socket *sock, long *timeo_p)
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
