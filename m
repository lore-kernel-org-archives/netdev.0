From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 08/17] tipc: eliminate
	port_connect()/port_disconnect() functions
Date: Fri, 22 Aug 2014 18:09:11 -0400
Message-ID: <1408745360-23560-9-git-send-email-jon.maloy@ericsson.com>
References: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

tipc_port_connect()/tipc_port_disconnect() are remnants of the obsolete
native API. Their only task is to grab port_lock and call the functions
__tipc_port_connect()/__tipc_port_disconnect() respectively, which will
perform the actual state change.

Since socket/port exection now is single-threaded the use of port_lock
is not needed any more, so we can safely replace the two functions with
their lock-free counterparts.

In this commit, we remove the two functions. Furthermore, the contents
of __tipc_port_disconnect() is so trivial that we choose to eliminate
that function too, expanding its functionality into tipc_shutdown().
__tipc_port_connect() is simplified, moved to socket.c, and given the
more correct name tipc_sk_finish_conn(). Finally, we eliminate the
function auto_connect(), and expand its contents into filter_connect().

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/port.c   |   84 -----------------------------------------------------
 net/tipc/port.h   |   10 -------
 net/tipc/socket.c |   75 +++++++++++++++++++++++------------------------
 3 files changed, 37 insertions(+), 132 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 3ad092b..2f96719 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -40,9 +40,6 @@
 #include "name_table.h"
 #include "socket.h"
 
-/* Connection management: */
-#define PROBING_INTERVAL 3600000	/* [ms] => 1 h */
-
 #define MAX_REJECT_SIZE 1024
 
 DEFINE_SPINLOCK(tipc_port_list_lock);
@@ -304,84 +301,3 @@ int tipc_withdraw(struct tipc_port *p_ptr, unsigned int scope,
 		p_ptr->published = 0;
 	return res;
 }
-
-int tipc_port_connect(u32 ref, struct tipc_portid const *peer)
-{
-	struct tipc_port *p_ptr;
-	int res;
-
-	p_ptr = tipc_port_lock(ref);
-	if (!p_ptr)
-		return -EINVAL;
-	res = __tipc_port_connect(ref, p_ptr, peer);
-	tipc_port_unlock(p_ptr);
-	return res;
-}
-
-/*
- * __tipc_port_connect - connect to a remote peer
- *
- * Port must be locked.
- */
-int __tipc_port_connect(u32 ref, struct tipc_port *p_ptr,
-			struct tipc_portid const *peer)
-{
-	struct tipc_msg *msg;
-	int res = -EINVAL;
-
-	if (p_ptr->published || p_ptr->connected)
-		goto exit;
-	if (!peer->ref)
-		goto exit;
-
-	msg = &p_ptr->phdr;
-	msg_set_destnode(msg, peer->node);
-	msg_set_destport(msg, peer->ref);
-	msg_set_type(msg, TIPC_CONN_MSG);
-	msg_set_lookup_scope(msg, 0);
-	msg_set_hdr_sz(msg, SHORT_H_SIZE);
-
-	p_ptr->probing_interval = PROBING_INTERVAL;
-	p_ptr->probing_state = TIPC_CONN_OK;
-	p_ptr->connected = 1;
-	k_start_timer(&p_ptr->timer, p_ptr->probing_interval);
-	res = tipc_node_add_conn(tipc_port_peernode(p_ptr), p_ptr->ref,
-				 tipc_port_peerport(p_ptr));
-exit:
-	p_ptr->max_pkt = tipc_node_get_mtu(peer->node, ref);
-	return res;
-}
-
-/*
- * __tipc_disconnect - disconnect port from peer
- *
- * Port must be locked.
- */
-int __tipc_port_disconnect(struct tipc_port *tp_ptr)
-{
-	if (tp_ptr->connected) {
-		tp_ptr->connected = 0;
-		/* let timer expire on it's own to avoid deadlock! */
-		tipc_node_remove_conn(tipc_port_peernode(tp_ptr), tp_ptr->ref);
-		return 0;
-	}
-
-	return -ENOTCONN;
-}
-
-/*
- * tipc_port_disconnect(): Disconnect port form peer.
- *                    This is a node local operation.
- */
-int tipc_port_disconnect(u32 ref)
-{
-	struct tipc_port *p_ptr;
-	int res;
-
-	p_ptr = tipc_port_lock(ref);
-	if (!p_ptr)
-		return -EINVAL;
-	res = __tipc_port_disconnect(p_ptr);
-	tipc_port_unlock(p_ptr);
-	return res;
-}
diff --git a/net/tipc/port.h b/net/tipc/port.h
index f5762f9..b356cb8 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -102,16 +102,6 @@ int tipc_publish(struct tipc_port *p_ptr, unsigned int scope,
 int tipc_withdraw(struct tipc_port *p_ptr, unsigned int scope,
 		  struct tipc_name_seq const *name_seq);
 
-int tipc_port_connect(u32 portref, struct tipc_portid const *port);
-
-int tipc_port_disconnect(u32 portref);
-
-/*
- * The following routines require that the port be locked on entry
- */
-int __tipc_port_disconnect(struct tipc_port *tp_ptr);
-int __tipc_port_connect(u32 ref, struct tipc_port *p_ptr,
-		   struct tipc_portid const *peer);
 int tipc_port_peer_msg(struct tipc_port *p_ptr, struct tipc_msg *msg);
 
 struct sk_buff *tipc_port_get_ports(void);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index f202d47..a651058 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -45,6 +45,7 @@
 #define SS_READY	-2	/* socket is connectionless */
 
 #define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
+#define CONN_PROBING_INTERVAL 3600000	/* [ms] => 1 h */
 #define TIPC_FWD_MSG	        1
 
 static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb);
@@ -339,7 +340,9 @@ static int tipc_release(struct socket *sock)
 			if ((sock->state == SS_CONNECTING) ||
 			    (sock->state == SS_CONNECTED)) {
 				sock->state = SS_DISCONNECTING;
-				tipc_port_disconnect(port->ref);
+				port->connected = 0;
+				tipc_node_remove_conn(tipc_port_peernode(port),
+						      port->ref);
 			}
 			if (tipc_msg_reverse(buf, &dnode, TIPC_ERR_NO_PORT))
 				tipc_link_xmit(buf, dnode, 0);
@@ -988,29 +991,25 @@ static int tipc_send_packet(struct kiocb *iocb, struct socket *sock,
 	return tipc_send_stream(iocb, sock, m, dsz);
 }
 
-/**
- * auto_connect - complete connection setup to a remote port
- * @tsk: tipc socket structure
- * @msg: peer's response message
- *
- * Returns 0 on success, errno otherwise
+/* tipc_sk_finish_conn - complete the setup of a connection
  */
-static int auto_connect(struct tipc_sock *tsk, struct tipc_msg *msg)
+static void tipc_sk_finish_conn(struct tipc_port *port, u32 peer_port,
+				u32 peer_node)
 {
-	struct tipc_port *port = &tsk->port;
-	struct socket *sock = tsk->sk.sk_socket;
-	struct tipc_portid peer;
-
-	peer.ref = msg_origport(msg);
-	peer.node = msg_orignode(msg);
+	struct tipc_msg *msg = &port->phdr;
 
-	__tipc_port_connect(port->ref, port, &peer);
+	msg_set_destnode(msg, peer_node);
+	msg_set_destport(msg, peer_port);
+	msg_set_type(msg, TIPC_CONN_MSG);
+	msg_set_lookup_scope(msg, 0);
+	msg_set_hdr_sz(msg, SHORT_H_SIZE);
 
-	if (msg_importance(msg) > TIPC_CRITICAL_IMPORTANCE)
-		return -EINVAL;
-	msg_set_importance(&port->phdr, (u32)msg_importance(msg));
-	sock->state = SS_CONNECTED;
-	return 0;
+	port->probing_interval = CONN_PROBING_INTERVAL;
+	port->probing_state = TIPC_CONN_OK;
+	port->connected = 1;
+	k_start_timer(&port->timer, port->probing_interval);
+	tipc_node_add_conn(peer_node, port->ref, peer_port);
+	port->max_pkt = tipc_node_get_mtu(peer_node, port->ref);
 }
 
 /**
@@ -1405,7 +1404,6 @@ static int filter_connect(struct tipc_sock *tsk, struct sk_buff **buf)
 	struct tipc_msg *msg = buf_msg(*buf);
 
 	int retval = -TIPC_ERR_NO_PORT;
-	int res;
 
 	if (msg_mcast(msg))
 		return retval;
@@ -1416,13 +1414,20 @@ static int filter_connect(struct tipc_sock *tsk, struct sk_buff **buf)
 		if (msg_connected(msg) && tipc_port_peer_msg(port, msg)) {
 			if (unlikely(msg_errcode(msg))) {
 				sock->state = SS_DISCONNECTING;
-				__tipc_port_disconnect(port);
+				port->connected = 0;
+				/* let timer expire on it's own */
+				tipc_node_remove_conn(tipc_port_peernode(port),
+						      port->ref);
 			}
 			retval = TIPC_OK;
 		}
 		break;
 	case SS_CONNECTING:
 		/* Accept only ACK or NACK message */
+
+		if (unlikely(!msg_connected(msg)))
+			break;
+
 		if (unlikely(msg_errcode(msg))) {
 			sock->state = SS_DISCONNECTING;
 			sk->sk_err = ECONNREFUSED;
@@ -1430,17 +1435,17 @@ static int filter_connect(struct tipc_sock *tsk, struct sk_buff **buf)
 			break;
 		}
 
-		if (unlikely(!msg_connected(msg)))
-			break;
-
-		res = auto_connect(tsk, msg);
-		if (res) {
+		if (unlikely(msg_importance(msg) > TIPC_CRITICAL_IMPORTANCE)) {
 			sock->state = SS_DISCONNECTING;
-			sk->sk_err = -res;
+			sk->sk_err = EINVAL;
 			retval = TIPC_OK;
 			break;
 		}
 
+		tipc_sk_finish_conn(port, msg_origport(msg), msg_orignode(msg));
+		msg_set_importance(&port->phdr, msg_importance(msg));
+		sock->state = SS_CONNECTED;
+
 		/* If an incoming message is an 'ACK-', it should be
 		 * discarded here because it doesn't contain useful
 		 * data. In addition, we should try to wake up
@@ -1816,8 +1821,6 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 	struct sk_buff *buf;
 	struct tipc_port *new_port;
 	struct tipc_msg *msg;
-	struct tipc_portid peer;
-	u32 new_ref;
 	long timeo;
 	int res;
 
@@ -1840,7 +1843,6 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 
 	new_sk = new_sock->sk;
 	new_port = &tipc_sk(new_sk)->port;
-	new_ref = new_port->ref;
 	msg = buf_msg(buf);
 
 	/* we lock on new_sk; but lockdep sees the lock on sk */
@@ -1853,9 +1855,7 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 	reject_rx_queue(new_sk);
 
 	/* Connect new socket to it's peer */
-	peer.ref = msg_origport(msg);
-	peer.node = msg_orignode(msg);
-	tipc_port_connect(new_ref, &peer);
+	tipc_sk_finish_conn(new_port, msg_origport(msg), msg_orignode(msg));
 	new_sock->state = SS_CONNECTED;
 
 	tipc_port_set_importance(new_port, msg_importance(msg));
@@ -1919,9 +1919,9 @@ restart:
 				kfree_skb(buf);
 				goto restart;
 			}
-			tipc_port_disconnect(port->ref);
 			if (tipc_msg_reverse(buf, &dnode, TIPC_CONN_SHUTDOWN))
 				tipc_link_xmit(buf, dnode, port->ref);
+			tipc_node_remove_conn(dnode, port->ref);
 		} else {
 			dnode = tipc_port_peernode(port);
 			buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
@@ -1930,11 +1930,10 @@ restart:
 					      tipc_port_peerport(port),
 					      port->ref, TIPC_CONN_SHUTDOWN);
 			tipc_link_xmit(buf, dnode, port->ref);
-			__tipc_port_disconnect(port);
 		}
-
+		port->connected = 0;
 		sock->state = SS_DISCONNECTING;
-
+		tipc_node_remove_conn(dnode, port->ref);
 		/* fall through */
 
 	case SS_DISCONNECTING:
-- 
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
