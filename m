From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 8/8] tipc: merge port message
	reception into socket reception function
Date: Fri,  9 May 2014 09:13:29 -0400
Message-ID: <1399641209-26112-9-git-send-email-jon.maloy@ericsson.com>
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

In order to reduce complexity and save a call level during message
reception at port/socket level, we remove the function tipc_port_rcv()
and merge its functionality into tipc_sk_rcv().

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c   |    3 ++-
 net/tipc/net.c    |    3 ++-
 net/tipc/port.c   |   39 ++++--------------------------------
 net/tipc/port.h   |    1 -
 net/tipc/socket.c |   57 ++++++++++++++++++++++++++++++++++-------------------
 net/tipc/socket.h |    2 +-
 6 files changed, 46 insertions(+), 59 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 24d0587..ad2c57f 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -37,6 +37,7 @@
 #include "core.h"
 #include "link.h"
 #include "port.h"
+#include "socket.h"
 #include "name_distr.h"
 #include "discover.h"
 #include "config.h"
@@ -1590,7 +1591,7 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		case TIPC_HIGH_IMPORTANCE:
 		case TIPC_CRITICAL_IMPORTANCE:
 			tipc_node_unlock(n_ptr);
-			tipc_port_rcv(buf);
+			tipc_sk_rcv(buf);
 			continue;
 		case MSG_BUNDLER:
 			l_ptr->stats.recv_bundles++;
diff --git a/net/tipc/net.c b/net/tipc/net.c
index f8fc95d..f64375e 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -39,6 +39,7 @@
 #include "name_distr.h"
 #include "subscr.h"
 #include "port.h"
+#include "socket.h"
 #include "node.h"
 #include "config.h"
 
@@ -141,7 +142,7 @@ void tipc_net_route_msg(struct sk_buff *buf)
 			if (msg_mcast(msg))
 				tipc_port_mcast_rcv(buf, NULL);
 			else if (msg_destport(msg))
-				tipc_port_rcv(buf);
+				tipc_sk_rcv(buf);
 			else
 				net_route_named_msg(buf);
 			return;
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 5c14c78..5fd7acc 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -165,7 +165,7 @@ void tipc_port_mcast_rcv(struct sk_buff *buf, struct tipc_port_list *dp)
 		msg_set_destnode(msg, tipc_own_addr);
 		if (dp->count == 1) {
 			msg_set_destport(msg, dp->ports[0]);
-			tipc_port_rcv(buf);
+			tipc_sk_rcv(buf);
 			tipc_port_list_free(dp);
 			return;
 		}
@@ -180,7 +180,7 @@ void tipc_port_mcast_rcv(struct sk_buff *buf, struct tipc_port_list *dp)
 			if ((index == 0) && (cnt != 0))
 				item = item->next;
 			msg_set_destport(buf_msg(b), item->ports[index]);
-			tipc_port_rcv(b);
+			tipc_sk_rcv(b);
 		}
 	}
 exit:
@@ -343,7 +343,7 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 	/* send returned message & dispose of rejected message */
 	src_node = msg_prevnode(msg);
 	if (in_own_node(src_node))
-		tipc_port_rcv(rbuf);
+		tipc_sk_rcv(rbuf);
 	else
 		tipc_link_xmit(rbuf, src_node, msg_link_selector(rmsg));
 exit:
@@ -754,37 +754,6 @@ int tipc_port_shutdown(u32 ref)
 	return tipc_port_disconnect(ref);
 }
 
-/**
- * tipc_port_rcv - receive message from lower layer and deliver to port user
- */
-int tipc_port_rcv(struct sk_buff *buf)
-{
-	struct tipc_port *p_ptr;
-	struct tipc_msg *msg = buf_msg(buf);
-	u32 destport = msg_destport(msg);
-	u32 dsz = msg_data_sz(msg);
-	u32 err;
-
-	/* forward unresolved named message */
-	if (unlikely(!destport)) {
-		tipc_net_route_msg(buf);
-		return dsz;
-	}
-
-	/* validate destination & pass to port, otherwise reject message */
-	p_ptr = tipc_port_lock(destport);
-	if (likely(p_ptr)) {
-		err = tipc_sk_rcv(&tipc_port_to_sock(p_ptr)->sk, buf);
-		tipc_port_unlock(p_ptr);
-		if (likely(!err))
-			return dsz;
-	} else {
-		err = TIPC_ERR_NO_PORT;
-	}
-
-	return tipc_reject_msg(buf, err);
-}
-
 /*
  *  tipc_port_iovec_rcv: Concatenate and deliver sectioned
  *                       message for this node.
@@ -798,7 +767,7 @@ static int tipc_port_iovec_rcv(struct tipc_port *sender,
 
 	res = tipc_msg_build(&sender->phdr, msg_sect, len, MAX_MSG_SIZE, &buf);
 	if (likely(buf))
-		tipc_port_rcv(buf);
+		tipc_sk_rcv(buf);
 	return res;
 }
 
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 5dfd165..cf4ca5b 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -135,7 +135,6 @@ int tipc_port_peer_msg(struct tipc_port *p_ptr, struct tipc_msg *msg);
 /*
  * TIPC messaging routines
  */
-int tipc_port_rcv(struct sk_buff *buf);
 
 int tipc_send(struct tipc_port *port,
 	      struct iovec const *msg_sect,
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 2495006..ac08966 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1442,39 +1442,56 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *buf)
 
 /**
  * tipc_sk_rcv - handle incoming message
- * @sk:  socket receiving message
- * @buf: message
- *
- * Called with port lock already taken.
- *
- * Returns TIPC error status code (TIPC_OK if message is not to be rejected)
+ * @buf: buffer containing arriving message
+ * Consumes buffer
+ * Returns 0 if success, or errno: -EHOSTUNREACH
  */
-u32 tipc_sk_rcv(struct sock *sk, struct sk_buff *buf)
+int tipc_sk_rcv(struct sk_buff *buf)
 {
-	struct tipc_sock *tsk = tipc_sk(sk);
-	u32 res;
+	struct tipc_sock *tsk;
+	struct tipc_port *port;
+	struct sock *sk;
+	u32 dport = msg_destport(buf_msg(buf));
+	int err = TIPC_OK;
 	uint limit;
-	/*
-	 * Process message if socket is unlocked; otherwise add to backlog queue
-	 *
-	 * This code is based on sk_receive_skb(), but must be distinct from it
-	 * since a TIPC-specific filter/reject mechanism is utilized
-	 */
+
+	/* Forward unresolved named message */
+	if (unlikely(!dport)) {
+		tipc_net_route_msg(buf);
+		return 0;
+	}
+
+	/* Validate destination */
+	port = tipc_port_lock(dport);
+	if (unlikely(!port)) {
+		err = TIPC_ERR_NO_PORT;
+		goto exit;
+	}
+
+	tsk = tipc_port_to_sock(port);
+	sk = &tsk->sk;
+
+	/* Queue message */
 	bh_lock_sock(sk);
+
 	if (!sock_owned_by_user(sk)) {
-		res = filter_rcv(sk, buf);
+		err = filter_rcv(sk, buf);
 	} else {
 		if (sk->sk_backlog.len == 0)
 			atomic_set(&tsk->dupl_rcvcnt, 0);
 		limit = rcvbuf_limit(sk, buf) + atomic_read(&tsk->dupl_rcvcnt);
 		if (sk_add_backlog(sk, buf, limit))
-			res = TIPC_ERR_OVERLOAD;
-		else
-			res = TIPC_OK;
+			err = TIPC_ERR_OVERLOAD;
 	}
+
 	bh_unlock_sock(sk);
+	tipc_port_unlock(port);
 
-	return res;
+	if (likely(!err))
+		return 0;
+exit:
+	tipc_reject_msg(buf, err);
+	return -EHOSTUNREACH;
 }
 
 static int tipc_wait_for_connect(struct socket *sock, long *timeo_p)
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index 86c27cc..3afcd2a 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -69,6 +69,6 @@ static inline void tipc_sock_wakeup(struct tipc_sock *tsk)
 	tsk->sk.sk_write_space(&tsk->sk);
 }
 
-u32 tipc_sk_rcv(struct sock *sk, struct sk_buff *buf);
+int tipc_sk_rcv(struct sk_buff *buf);
 
 #endif
-- 
1.7.9.5


------------------------------------------------------------------------------
Is your legacy SCM system holding you back? Join Perforce May 7 to find out:
&#149; 3 signs your SCM is hindering your productivity
&#149; Requirements for releasing software faster
&#149; Expert tips and advice for migrating your SCM now
http://p.sf.net/sfu/perforce
