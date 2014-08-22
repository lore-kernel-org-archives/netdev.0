From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 07/17] tipc: eliminate function
	tipc_port_shutdown()
Date: Fri, 22 Aug 2014 18:09:10 -0400
Message-ID: <1408745360-23560-8-git-send-email-jon.maloy@ericsson.com>
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

tipc_port_shutdown() is a remnant from the now obsolete native
interface. As such it grabs port_lock in order to protect itself
from concurrent BH processing.

However, after the recent changes to the port/socket upcalls, sockets
are now basically single-threaded, and all execution, except the read-only
tipc_sk_timer(), is executing within the protection of lock_sock(). So
the use of port_lock is not needed here.

In this commit we eliminate the whole function, and merge it into its
only caller, tipc_shutdown().

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/port.c   |   24 ------------------------
 net/tipc/port.h   |    2 --
 net/tipc/socket.c |   15 +++++++++++----
 3 files changed, 11 insertions(+), 30 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 6de79f2..3ad092b 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -385,27 +385,3 @@ int tipc_port_disconnect(u32 ref)
 	tipc_port_unlock(p_ptr);
 	return res;
 }
-
-/*
- * tipc_port_shutdown(): Send a SHUTDOWN msg to peer and disconnect
- */
-int tipc_port_shutdown(u32 ref)
-{
-	struct tipc_msg *msg;
-	struct tipc_port *p_ptr;
-	struct sk_buff *buf = NULL;
-	u32 peer_node;
-
-	p_ptr = tipc_port_lock(ref);
-	if (!p_ptr)
-		return -EINVAL;
-	peer_node = tipc_port_peernode(p_ptr);
-	buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
-			      SHORT_H_SIZE, 0, peer_node,
-			      tipc_own_addr, tipc_port_peerport(p_ptr),
-			      p_ptr->ref, TIPC_CONN_SHUTDOWN);
-	tipc_port_unlock(p_ptr);
-	msg = buf_msg(buf);
-	tipc_link_xmit(buf, peer_node,	msg_link_selector(msg));
-	return tipc_port_disconnect(ref);
-}
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 6cdc7de..f5762f9 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -106,8 +106,6 @@ int tipc_port_connect(u32 portref, struct tipc_portid const *port);
 
 int tipc_port_disconnect(u32 portref);
 
-int tipc_port_shutdown(u32 ref);
-
 /*
  * The following routines require that the port be locked on entry
  */
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 5f8376e..f202d47 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1899,7 +1899,7 @@ static int tipc_shutdown(struct socket *sock, int how)
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_port *port = &tsk->port;
 	struct sk_buff *buf;
-	u32 peer;
+	u32 dnode;
 	int res;
 
 	if (how != SHUT_RDWR)
@@ -1920,10 +1920,17 @@ restart:
 				goto restart;
 			}
 			tipc_port_disconnect(port->ref);
-			if (tipc_msg_reverse(buf, &peer, TIPC_CONN_SHUTDOWN))
-				tipc_link_xmit(buf, peer, 0);
+			if (tipc_msg_reverse(buf, &dnode, TIPC_CONN_SHUTDOWN))
+				tipc_link_xmit(buf, dnode, port->ref);
 		} else {
-			tipc_port_shutdown(port->ref);
+			dnode = tipc_port_peernode(port);
+			buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
+					      TIPC_CONN_MSG, SHORT_H_SIZE,
+					      0, dnode, tipc_own_addr,
+					      tipc_port_peerport(port),
+					      port->ref, TIPC_CONN_SHUTDOWN);
+			tipc_link_xmit(buf, dnode, port->ref);
+			__tipc_port_disconnect(port);
 		}
 
 		sock->state = SS_DISCONNECTING;
-- 
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
