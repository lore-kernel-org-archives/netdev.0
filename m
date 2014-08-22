From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 12/17] tipc: replace port pointer
	with socket pointer in registry
Date: Fri, 22 Aug 2014 18:09:15 -0400
Message-ID: <1408745360-23560-13-git-send-email-jon.maloy@ericsson.com>
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

In order to make tipc_sock the only entity referencable from other
parts of the stack, we add a tipc_sock pointer instead of a tipc_port
pointer to the registry. As a consequence, we also let the function
tipc_port_lock() return a pointer to a tipc_sock instead  of a tipc_port.
We keep the function's name for now, since the lock still is owned by
the port.

This is another step in the direction of eliminating port_lock, replacing
its usage with lock_sock() and bh_lock_sock().

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/port.h   |    4 ++--
 net/tipc/socket.c |   23 +++++++++--------------
 2 files changed, 11 insertions(+), 16 deletions(-)

diff --git a/net/tipc/port.h b/net/tipc/port.h
index 4a3c54e..33e52fe 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -101,9 +101,9 @@ void tipc_port_reinit(void);
 /**
  * tipc_port_lock - lock port instance referred to and return its pointer
  */
-static inline struct tipc_port *tipc_port_lock(u32 ref)
+static inline struct tipc_sock *tipc_port_lock(u32 ref)
 {
-	return (struct tipc_port *)tipc_ref_lock(ref);
+	return (struct tipc_sock *)tipc_ref_lock(ref);
 }
 
 /**
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ddc2f8c..247f245 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -115,11 +115,7 @@ static struct proto tipc_proto_kern;
 */
 static struct tipc_sock *tipc_sk_lock_next(u32 *ref)
 {
-	struct tipc_port *port = (struct tipc_port *)tipc_ref_lock_next(ref);
-
-	if (!port)
-		return NULL;
-	return tipc_port_to_sock(port);
+	return (struct tipc_sock *)tipc_ref_lock_next(ref);
 }
 
 /**
@@ -204,7 +200,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 
 	tsk = tipc_sk(sk);
 	port = &tsk->port;
-	ref = tipc_ref_acquire(port, &port->lock);
+	ref = tipc_ref_acquire(tsk, &port->lock);
 	if (!ref) {
 		pr_warn("Socket create failed; reference table exhausted\n");
 		return -ENOMEM;
@@ -1655,13 +1651,12 @@ int tipc_sk_rcv(struct sk_buff *buf)
 	u32 dnode;
 
 	/* Validate destination and message */
-	port = tipc_port_lock(dport);
-	if (unlikely(!port)) {
+	tsk = tipc_port_lock(dport);
+	if (unlikely(!tsk)) {
 		rc = tipc_msg_eval(buf, &dnode);
 		goto exit;
 	}
-
-	tsk = tipc_port_to_sock(port);
+	port = &tsk->port;
 	sk = &tsk->sk;
 
 	/* Queue message */
@@ -2002,21 +1997,21 @@ restart:
 
 static void tipc_sk_timeout(unsigned long ref)
 {
-	struct tipc_port *port = tipc_port_lock(ref);
-	struct tipc_sock *tsk;
+	struct tipc_sock *tsk = tipc_port_lock(ref);
+	struct tipc_port *port;
 	struct sock *sk;
 	struct sk_buff *buf = NULL;
 	struct tipc_msg *msg = NULL;
 	u32 peer_port, peer_node;
 
-	if (!port)
+	if (!tsk)
 		return;
 
+	port = &tsk->port;
 	if (!port->connected) {
 		tipc_port_unlock(port);
 		return;
 	}
-	tsk = tipc_port_to_sock(port);
 	sk = &tsk->sk;
 	bh_lock_sock(sk);
 	peer_port = tipc_port_peerport(port);
-- 
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
