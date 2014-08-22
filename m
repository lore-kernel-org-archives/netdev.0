From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 09/17] tipc: redefine message
	acknowledge function
Date: Fri, 22 Aug 2014 18:09:12 -0400
Message-ID: <1408745360-23560-10-git-send-email-jon.maloy@ericsson.com>
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

The function tipc_acknowledge() is a remnant from the obsolete native
API. Currently, it grabs port_lock, before building an acknowledge
message and sending it to the peer.

Since all access to socket members now is protected by the socket lock,
it has become unnecessary to grab port_lock here.

In this commit, we remove the usage of port_lock, simplify the
function, and move it to socket.c, renaming it to tipc_sk_send_ack().

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/port.c   |   22 ----------------------
 net/tipc/port.h   |    2 --
 net/tipc/socket.c |   22 ++++++++++++++++++++--
 3 files changed, 20 insertions(+), 26 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 2f96719..1074ccb 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -221,28 +221,6 @@ void tipc_port_reinit(void)
 	spin_unlock_bh(&tipc_port_list_lock);
 }
 
-void tipc_acknowledge(u32 ref, u32 ack)
-{
-	struct tipc_port *p_ptr;
-	struct sk_buff *buf = NULL;
-	struct tipc_msg *msg;
-
-	p_ptr = tipc_port_lock(ref);
-	if (!p_ptr)
-		return;
-	if (p_ptr->connected)
-		buf = tipc_msg_create(CONN_MANAGER, CONN_ACK, INT_H_SIZE,
-				      0, tipc_port_peernode(p_ptr),
-				      tipc_own_addr, tipc_port_peerport(p_ptr),
-				      p_ptr->ref, TIPC_OK);
-	tipc_port_unlock(p_ptr);
-	if (!buf)
-		return;
-	msg = buf_msg(buf);
-	msg_set_msgcnt(msg, ack);
-	tipc_link_xmit(buf, msg_destnode(msg),	msg_link_selector(msg));
-}
-
 int tipc_publish(struct tipc_port *p_ptr, unsigned int scope,
 		 struct tipc_name_seq const *seq)
 {
diff --git a/net/tipc/port.h b/net/tipc/port.h
index b356cb8..c92e172 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -92,8 +92,6 @@ struct tipc_port_list;
 u32 tipc_port_init(struct tipc_port *p_ptr,
 		   const unsigned int importance);
 
-void tipc_acknowledge(u32 port_ref, u32 ack);
-
 void tipc_port_destroy(struct tipc_port *p_ptr);
 
 int tipc_publish(struct tipc_port *p_ptr, unsigned int scope,
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index a651058..686a11b 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1106,6 +1106,24 @@ static int anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 	return 0;
 }
 
+static void tipc_sk_send_ack(struct tipc_port *port, uint ack)
+{
+	struct sk_buff *buf = NULL;
+	struct tipc_msg *msg;
+	u32 peer_port = tipc_port_peerport(port);
+	u32 dnode = tipc_port_peernode(port);
+
+	if (!port->connected)
+		return;
+	buf = tipc_msg_create(CONN_MANAGER, CONN_ACK, INT_H_SIZE, 0, dnode,
+			      tipc_own_addr, peer_port, port->ref, TIPC_OK);
+	if (!buf)
+		return;
+	msg = buf_msg(buf);
+	msg_set_msgcnt(msg, ack);
+	tipc_link_xmit(buf, dnode, msg_link_selector(msg));
+}
+
 static int tipc_wait_for_rcvmsg(struct socket *sock, long *timeop)
 {
 	struct sock *sk = sock->sk;
@@ -1226,7 +1244,7 @@ restart:
 	if (likely(!(flags & MSG_PEEK))) {
 		if ((sock->state != SS_READY) &&
 		    (++tsk->rcv_unacked >= TIPC_CONNACK_INTV)) {
-			tipc_acknowledge(port->ref, tsk->rcv_unacked);
+			tipc_sk_send_ack(port, tsk->rcv_unacked);
 			tsk->rcv_unacked = 0;
 		}
 		advance_rx_queue(sk);
@@ -1337,7 +1355,7 @@ restart:
 	/* Consume received message (optional) */
 	if (likely(!(flags & MSG_PEEK))) {
 		if (unlikely(++tsk->rcv_unacked >= TIPC_CONNACK_INTV)) {
-			tipc_acknowledge(port->ref, tsk->rcv_unacked);
+			tipc_sk_send_ack(port, tsk->rcv_unacked);
 			tsk->rcv_unacked = 0;
 		}
 		advance_rx_queue(sk);
-- 
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
