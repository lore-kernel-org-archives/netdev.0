From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 02/13] tipc: use negative error return values in functions
Date: Wed, 25 Jun 2014 20:41:31 -0500
Message-ID: <1403746902-20408-3-git-send-email-jon.maloy@ericsson.com>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.ne1.yahoo.com ([98.138.207.12]:24120 "HELO
	smtp105.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756874AbaFZBsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:48:46 -0400
In-Reply-To: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some places, TIPC functions returns positive integers as return
codes. This goes against standard Linux coding practice, and may
even cause problems in some cases.

We now change the return values of the functions filter_rcv()
and filter_connect() to become signed integers, and return
negative error codes when needed. The codes we use in these
particular cases are still TIPC specific, since they are both
part of the TIPC API and have no correspondence in errno.h

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/socket.c |   46 +++++++++++++++++++++++-----------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ef04755..9a95dab 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1269,17 +1269,16 @@ static void tipc_data_ready(struct sock *sk)
  * @tsk: TIPC socket
  * @msg: message
  *
- * Returns TIPC error status code and socket error status code
- * once it encounters some errors
+ * Returns 0 (TIPC_OK) if everyting ok, -TIPC_ERR_NO_PORT otherwise
  */
-static u32 filter_connect(struct tipc_sock *tsk, struct sk_buff **buf)
+static int filter_connect(struct tipc_sock *tsk, struct sk_buff **buf)
 {
 	struct sock *sk = &tsk->sk;
 	struct tipc_port *port = &tsk->port;
 	struct socket *sock = sk->sk_socket;
 	struct tipc_msg *msg = buf_msg(*buf);
 
-	u32 retval = TIPC_ERR_NO_PORT;
+	int retval = -TIPC_ERR_NO_PORT;
 	int res;
 
 	if (msg_mcast(msg))
@@ -1382,32 +1381,33 @@ static unsigned int rcvbuf_limit(struct sock *sk, struct sk_buff *buf)
  *
  * Called with socket lock already taken; port lock may also be taken.
  *
- * Returns TIPC error status code (TIPC_OK if message is not to be rejected)
+ * Returns 0 (TIPC_OK) if message was consumed, -TIPC error code if message
+ * to be rejected.
  */
-static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
+static int filter_rcv(struct sock *sk, struct sk_buff *buf)
 {
 	struct socket *sock = sk->sk_socket;
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_msg *msg = buf_msg(buf);
 	unsigned int limit = rcvbuf_limit(sk, buf);
-	u32 res = TIPC_OK;
+	int rc = TIPC_OK;
 
 	/* Reject message if it is wrong sort of message for socket */
 	if (msg_type(msg) > TIPC_DIRECT_MSG)
-		return TIPC_ERR_NO_PORT;
+		return -TIPC_ERR_NO_PORT;
 
 	if (sock->state == SS_READY) {
 		if (msg_connected(msg))
-			return TIPC_ERR_NO_PORT;
+			return -TIPC_ERR_NO_PORT;
 	} else {
-		res = filter_connect(tsk, &buf);
-		if (res != TIPC_OK || buf == NULL)
-			return res;
+		rc = filter_connect(tsk, &buf);
+		if (rc != TIPC_OK || buf == NULL)
+			return rc;
 	}
 
 	/* Reject message if there isn't room to queue it */
 	if (sk_rmem_alloc_get(sk) + buf->truesize >= limit)
-		return TIPC_ERR_OVERLOAD;
+		return -TIPC_ERR_OVERLOAD;
 
 	/* Enqueue message */
 	TIPC_SKB_CB(buf)->handle = NULL;
@@ -1429,13 +1429,13 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
  */
 static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *buf)
 {
-	u32 res;
+	int rc;
 	struct tipc_sock *tsk = tipc_sk(sk);
 	uint truesize = buf->truesize;
 
-	res = filter_rcv(sk, buf);
-	if (unlikely(res))
-		tipc_reject_msg(buf, res);
+	rc = filter_rcv(sk, buf);
+	if (unlikely(rc))
+		tipc_reject_msg(buf, -rc);
 
 	if (atomic_read(&tsk->dupl_rcvcnt) < TIPC_CONN_OVERLOAD_LIMIT)
 		atomic_add(truesize, &tsk->dupl_rcvcnt);
@@ -1455,7 +1455,7 @@ int tipc_sk_rcv(struct sk_buff *buf)
 	struct tipc_port *port;
 	struct sock *sk;
 	u32 dport = msg_destport(buf_msg(buf));
-	int err = TIPC_OK;
+	int rc = TIPC_OK;
 	uint limit;
 
 	/* Forward unresolved named message */
@@ -1467,7 +1467,7 @@ int tipc_sk_rcv(struct sk_buff *buf)
 	/* Validate destination */
 	port = tipc_port_lock(dport);
 	if (unlikely(!port)) {
-		err = TIPC_ERR_NO_PORT;
+		rc = -TIPC_ERR_NO_PORT;
 		goto exit;
 	}
 
@@ -1478,22 +1478,22 @@ int tipc_sk_rcv(struct sk_buff *buf)
 	bh_lock_sock(sk);
 
 	if (!sock_owned_by_user(sk)) {
-		err = filter_rcv(sk, buf);
+		rc = filter_rcv(sk, buf);
 	} else {
 		if (sk->sk_backlog.len == 0)
 			atomic_set(&tsk->dupl_rcvcnt, 0);
 		limit = rcvbuf_limit(sk, buf) + atomic_read(&tsk->dupl_rcvcnt);
 		if (sk_add_backlog(sk, buf, limit))
-			err = TIPC_ERR_OVERLOAD;
+			rc = -TIPC_ERR_OVERLOAD;
 	}
 
 	bh_unlock_sock(sk);
 	tipc_port_unlock(port);
 
-	if (likely(!err))
+	if (likely(!rc))
 		return 0;
 exit:
-	tipc_reject_msg(buf, err);
+	tipc_reject_msg(buf, -rc);
 	return -EHOSTUNREACH;
 }
 
-- 
1.7.9.5
