From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 3/7 net-next-2.6] tipc: Fix race condition that could cause accept() to fail
Date: Thu, 10 Jul 2008 17:26:07 -0400
Message-ID: <1215725171-10094-4-git-send-email-allan.stephens@windriver.com>
References: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33101 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753229AbYGJVZJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 17:25:09 -0400
In-Reply-To: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensurs that accept() returns successfully even when
the newly created socket is immediately disconnected by its peer.
Previously, accept() would fail if it was unable to pass back
the optional address info for the socket's peer before the
socket became disconnected; TIPC now allows accept() to gather
peer address information after disconnection.  As a bonus, the
revised code accesses the socket's port more efficiently, without
the overhead incurred by a reference table lookup.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/socket.c |   42 ++++++++++++++++++++++--------------------
 1 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ddcb2a7..1848693 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -63,6 +63,7 @@
 struct tipc_sock {
 	struct sock sk;
 	struct tipc_port *p;
+	struct tipc_portid peer_name;
 };
 
 #define tipc_sk(sk) ((struct tipc_sock *)(sk))
@@ -377,27 +378,29 @@ static int bind(struct socket *sock, struct sockaddr *uaddr, int uaddr_len)
  * @sock: socket structure
  * @uaddr: area for returned socket address
  * @uaddr_len: area for returned length of socket address
- * @peer: 0 to obtain socket name, 1 to obtain peer socket name
+ * @peer: 0 = own ID, 1 = current peer ID, 2 = current/former peer ID
  *
  * Returns 0 on success, errno otherwise
  *
- * NOTE: This routine doesn't need to take the socket lock since it doesn't
- *       access any non-constant socket information.
+ * NOTE: This routine doesn't need to take the socket lock since it only
+ *       accesses socket information that is unchanging (or which changes in
+ * 	 a completely predictable manner).
  */
 
 static int get_name(struct socket *sock, struct sockaddr *uaddr,
 		    int *uaddr_len, int peer)
 {
 	struct sockaddr_tipc *addr = (struct sockaddr_tipc *)uaddr;
-	u32 portref = tipc_sk_port(sock->sk)->ref;
-	u32 res;
+	struct tipc_sock *tsock = tipc_sk(sock->sk);
 
 	if (peer) {
-		res = tipc_peer(portref, &addr->addr.id);
-		if (res)
-			return res;
+		if ((sock->state != SS_CONNECTED) &&
+			((peer != 2) || (sock->state != SS_DISCONNECTING)))
+			return -ENOTCONN;
+		addr->addr.id.ref = tsock->peer_name.ref;
+		addr->addr.id.node = tsock->peer_name.node;
 	} else {
-		tipc_ownidentity(portref, &addr->addr.id);
+		tipc_ownidentity(tsock->p->ref, &addr->addr.id);
 	}
 
 	*uaddr_len = sizeof(*addr);
@@ -766,18 +769,17 @@ exit:
 
 static int auto_connect(struct socket *sock, struct tipc_msg *msg)
 {
-	struct tipc_port *tport = tipc_sk_port(sock->sk);
-	struct tipc_portid peer;
+	struct tipc_sock *tsock = tipc_sk(sock->sk);
 
 	if (msg_errcode(msg)) {
 		sock->state = SS_DISCONNECTING;
 		return -ECONNREFUSED;
 	}
 
-	peer.ref = msg_origport(msg);
-	peer.node = msg_orignode(msg);
-	tipc_connect2port(tport->ref, &peer);
-	tipc_set_portimportance(tport->ref, msg_importance(msg));
+	tsock->peer_name.ref = msg_origport(msg);
+	tsock->peer_name.node = msg_orignode(msg);
+	tipc_connect2port(tsock->p->ref, &tsock->peer_name);
+	tipc_set_portimportance(tsock->p->ref, msg_importance(msg));
 	sock->state = SS_CONNECTED;
 	return 0;
 }
@@ -1529,9 +1531,9 @@ static int accept(struct socket *sock, struct socket *new_sock, int flags)
 	res = tipc_create(sock_net(sock->sk), new_sock, 0);
 	if (!res) {
 		struct sock *new_sk = new_sock->sk;
-		struct tipc_port *new_tport = tipc_sk_port(new_sk);
+		struct tipc_sock *new_tsock = tipc_sk(new_sk);
+		struct tipc_port *new_tport = new_tsock->p;
 		u32 new_ref = new_tport->ref;
-		struct tipc_portid id;
 		struct tipc_msg *msg = buf_msg(buf);
 
 		lock_sock(new_sk);
@@ -1545,9 +1547,9 @@ static int accept(struct socket *sock, struct socket *new_sock, int flags)
 
 		/* Connect new socket to it's peer */
 
-		id.ref = msg_origport(msg);
-		id.node = msg_orignode(msg);
-		tipc_connect2port(new_ref, &id);
+		new_tsock->peer_name.ref = msg_origport(msg);
+		new_tsock->peer_name.node = msg_orignode(msg);
+		tipc_connect2port(new_ref, &new_tsock->peer_name);
 		new_sock->state = SS_CONNECTED;
 
 		tipc_set_portimportance(new_ref, msg_importance(msg));
-- 
1.5.4.3

