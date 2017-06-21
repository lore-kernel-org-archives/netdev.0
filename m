From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 2/2] rds: tcp: set linger to 1 when unloading a rds-tcp
Date: Wed, 21 Jun 2017 13:40:13 -0700
Message-ID: <f30cec61cb806c600cf3a3648f934561f3a5f54b.1498074496.git.sowmini.varadhan@oracle.com>
References: <cover.1498074496.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
        santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42114 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751865AbdFUUmd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 16:42:33 -0400
In-Reply-To: <cover.1498074496.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1498074496.git.sowmini.varadhan@oracle.com>
References: <cover.1498074496.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we are unloading the rds_tcp module, we can set linger to 1
and drop pending packets to accelerate reconnect. The peer will
end up resetting the connection based on new generation numbers
of the new incarnation, so hanging on to unsent TCP packets via
linger is mostly pointless in this case.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Tested-by: Jenny Xu <jenny.x.xu@oracle.com>
---
 net/rds/connection.c  |    1 +
 net/rds/rds.h         |    3 ++-
 net/rds/tcp.h         |    1 +
 net/rds/tcp_connect.c |    2 ++
 net/rds/tcp_listen.c  |    2 +-
 5 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 382443b..50a3789 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -412,6 +412,7 @@ void rds_conn_destroy(struct rds_connection *conn)
 		 "%pI4\n", conn, &conn->c_laddr,
 		 &conn->c_faddr);
 
+	conn->c_destroy_in_prog = 1;
 	/* Ensure conn will not be scheduled for reconnect */
 	spin_lock_irq(&rds_conn_lock);
 	hlist_del_init_rcu(&conn->c_hash_node);
diff --git a/net/rds/rds.h b/net/rds/rds.h
index aa696b3..4a25db7 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -137,7 +137,8 @@ struct rds_connection {
 	__be32			c_faddr;
 	unsigned int		c_loopback:1,
 				c_ping_triggered:1,
-				c_pad_to_32:30;
+				c_destroy_in_prog:1,
+				c_pad_to_32:29;
 	int			c_npaths;
 	struct rds_connection	*c_passive;
 	struct rds_transport	*c_trans;
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
index 56ea662..f8800b7 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -71,6 +71,7 @@ void rds_tcp_restore_callbacks(struct socket *sock,
 int rds_tcp_accept_one(struct socket *sock);
 int rds_tcp_keepalive(struct socket *sock);
 void *rds_tcp_listen_sock_def_readable(struct net *net);
+void rds_tcp_set_linger(struct socket *sock);
 
 /* tcp_recv.c */
 int rds_tcp_recv_init(void);
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index 5a62a08..cbe08a1 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -170,6 +170,8 @@ void rds_tcp_conn_path_shutdown(struct rds_conn_path *cp)
 		 cp->cp_conn, tc, sock);
 
 	if (sock) {
+		if (cp->cp_conn->c_destroy_in_prog)
+			rds_tcp_set_linger(sock);
 		sock->ops->shutdown(sock, RCV_SHUTDOWN | SEND_SHUTDOWN);
 		lock_sock(sock->sk);
 		rds_tcp_restore_callbacks(sock, tc); /* tc->tc_sock = NULL */
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 6089e9a..c6dc8ca 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -112,7 +112,7 @@ struct rds_tcp_connection *rds_tcp_accept_one_path(struct rds_connection *conn)
 	return NULL;
 }
 
-static void rds_tcp_set_linger(struct socket *sock)
+void rds_tcp_set_linger(struct socket *sock)
 {
 	struct linger no_linger = {
 		.l_onoff = 1,
-- 
1.7.1
