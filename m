From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 1/2] net/rds: RDS-TCP: Always create a new rds_sock for an incoming connection.
Date: Sat,  2 May 2015 07:55:08 -0400
Message-ID: <c3c228cbc7f6e4a4cb8e9e0ac400aaf4ed22b927.1430421231.git.sowmini.varadhan@oracle.com>
References: <cover.1430421231.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, ajaykumar.hotchandani@oracle.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:51204 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbbEBLzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 07:55:25 -0400
In-Reply-To: <cover.1430421231.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1430421231.git.sowmini.varadhan@oracle.com>
References: <cover.1430421231.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running RDS over TCP, the active (client) side connects to the
listening ("passive") side at the RDS_TCP_PORT.  After the connection
is established, if the client side reboots (potentially without even
sending a FIN) the server still has a TCP socket in the Established
state.  If the server-side now gets a new SYN comes from the client
with a different client port, TCP will create a new socket-pair, but
the RDS layer will incorrectly pull up the old rds_connection (which
is still associated with the stale t_sock and RDS socket state).

This patch corrects this behavior by having rds_tcp_accept_one()
always create a new connection for an incoming TCP SYN.
The rds and tcp state associated with the old socket-pair is cleaned
up in rds_tcp_set_callbacks() (i.e., rds_conn_drop on the old
connection)

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c  |    4 +++
 net/rds/tcp.c         |   51 ++++++++++++++++++++++++++++++++++++++++++++++++-
 net/rds/tcp.h         |    5 +++-
 net/rds/tcp_connect.c |    2 +-
 net/rds/tcp_listen.c  |   13 +++++++++++-
 5 files changed, 71 insertions(+), 4 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 14f0413..60f0cd6 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -126,7 +126,10 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
 	struct rds_transport *loop_trans;
 	unsigned long flags;
 	int ret;
+	struct rds_transport *otrans = trans;
 
+	if (!is_outgoing && otrans->t_type == RDS_TRANS_TCP)
+		goto new_conn;
 	rcu_read_lock();
 	conn = rds_conn_lookup(head, laddr, faddr, trans);
 	if (conn && conn->c_loopback && conn->c_trans != &rds_loop_transport &&
@@ -142,6 +145,7 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
 	if (conn)
 		goto out;
 
+new_conn:
 	conn = kmem_cache_zalloc(rds_conn_slab, gfp);
 	if (!conn) {
 		conn = ERR_PTR(-ENOMEM);
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index edac9ef..dc50057 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -113,12 +113,48 @@ void rds_tcp_restore_callbacks(struct socket *sock,
 	write_unlock_bh(&sock->sk->sk_callback_lock);
 }
 
+#define RDS_TCP_HASH_BITS 12
+#define RDS_TCP_HASH_ENTRIES (1 << RDS_TCP_HASH_BITS)
+#define RDS_TCP_HASH_MASK (RDS_TCP_HASH_ENTRIES - 1)
+
+static struct hlist_head rds_tcp_conn_hash[RDS_TCP_HASH_ENTRIES];
+
+static struct hlist_head *rds_tcp_conn_bucket(__be32 laddr, __be32 faddr)
+{
+	static u32 rds_hash_secret __read_mostly;
+	unsigned long hash;
+
+	net_get_random_once(&rds_hash_secret, sizeof(rds_hash_secret));
+	hash = __inet_ehashfn(be32_to_cpu(laddr), 0,
+			      be32_to_cpu(faddr), 0,
+			      rds_hash_secret);
+	return &rds_tcp_conn_hash[hash & RDS_TCP_HASH_MASK];
+}
+
+static struct rds_tcp_connection *rds_tcp_conn_lookup(struct hlist_head *head,
+						      __be32 laddr,
+						      __be32 faddr)
+{
+	struct rds_tcp_connection *rs_tcp, *ret = NULL;
+
+	hlist_for_each_entry_rcu(rs_tcp, head, t_passive_conn) {
+		struct rds_connection *conn = rs_tcp->conn;
+
+		if (conn->c_faddr == faddr && conn->c_laddr == laddr) {
+			ret = rs_tcp;
+			break;
+		}
+	}
+	return ret;
+}
+
 /*
  * This is the only path that sets tc->t_sock.  Send and receive trust that
  * it is set.  The RDS_CONN_CONNECTED bit protects those paths from being
  * called while it isn't set.
  */
-void rds_tcp_set_callbacks(struct socket *sock, struct rds_connection *conn)
+void rds_tcp_set_callbacks(struct socket *sock, struct rds_connection *conn,
+			   bool passive)
 {
 	struct rds_tcp_connection *tc = conn->c_transport_data;
 
@@ -140,6 +176,18 @@ void rds_tcp_set_callbacks(struct socket *sock, struct rds_connection *conn)
 	tc->t_orig_data_ready = sock->sk->sk_data_ready;
 	tc->t_orig_write_space = sock->sk->sk_write_space;
 	tc->t_orig_state_change = sock->sk->sk_state_change;
+	INIT_HLIST_NODE(&tc->t_passive_conn);
+	if (passive) {
+		__be32 laddr = inet_sk(sock->sk)->inet_saddr;
+		__be32 faddr = inet_sk(sock->sk)->inet_daddr;
+		struct hlist_head *head = rds_tcp_conn_bucket(laddr, faddr);
+		struct rds_tcp_connection *oconn;
+
+		oconn = rds_tcp_conn_lookup(head, laddr, faddr);
+		if (oconn)
+			rds_conn_drop(oconn->conn);
+		hlist_add_head_rcu(&tc->t_passive_conn, head);
+	}
 
 	sock->sk->sk_user_data = conn;
 	sock->sk->sk_data_ready = rds_tcp_data_ready;
@@ -228,6 +276,7 @@ static void rds_tcp_conn_free(void *arg)
 	spin_lock_irqsave(&rds_tcp_conn_lock, flags);
 	list_del(&tc->t_tcp_node);
 	spin_unlock_irqrestore(&rds_tcp_conn_lock, flags);
+	hlist_del_init_rcu(&tc->t_passive_conn);
 
 	kmem_cache_free(rds_tcp_conn_slab, tc);
 }
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
index 0dbdd37..a3b3926 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -32,6 +32,8 @@ struct rds_tcp_connection {
 	u32			t_last_sent_nxt;
 	u32			t_last_expected_una;
 	u32			t_last_seen_una;
+
+	struct hlist_node	t_passive_conn;
 };
 
 struct rds_tcp_statistics {
@@ -45,7 +47,8 @@ struct rds_tcp_statistics {
 /* tcp.c */
 void rds_tcp_tune(struct socket *sock);
 void rds_tcp_nonagle(struct socket *sock);
-void rds_tcp_set_callbacks(struct socket *sock, struct rds_connection *conn);
+void rds_tcp_set_callbacks(struct socket *sock, struct rds_connection *conn,
+			   bool passive);
 void rds_tcp_restore_callbacks(struct socket *sock,
 			       struct rds_tcp_connection *tc);
 u32 rds_tcp_snd_nxt(struct rds_tcp_connection *tc);
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index f9f564a..e13facb 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -103,7 +103,7 @@ int rds_tcp_conn_connect(struct rds_connection *conn)
 	 * once we call connect() we can start getting callbacks and they
 	 * own the socket
 	 */
-	rds_tcp_set_callbacks(sock, conn);
+	rds_tcp_set_callbacks(sock, conn, false);
 	ret = sock->ops->connect(sock, (struct sockaddr *)&dest, sizeof(dest),
 				 O_NONBLOCK);
 
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 23ab4dc..6b783f1 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -51,6 +51,7 @@ static int rds_tcp_accept_one(struct socket *sock)
 	struct rds_connection *conn;
 	int ret;
 	struct inet_sock *inet;
+	struct rds_tcp_connection *rs_tcp;
 
 	ret = sock_create_lite(sock->sk->sk_family, sock->sk->sk_type,
 			       sock->sk->sk_protocol, &new_sock);
@@ -77,6 +78,16 @@ static int rds_tcp_accept_one(struct socket *sock)
 		ret = PTR_ERR(conn);
 		goto out;
 	}
+	/* An incoming SYN request came in, and TCP just accepted it.
+	 * We always create a new conn for listen side of TCP, and do not
+	 * add it to the c_hash_list.
+	 *
+	 * If the client reboots, this conn will need to be cleaned up.
+	 * When we get a new connection request from the client,
+	 * rds_tcp_set_callbacks() will do that cleanup
+	 */
+	rs_tcp = (struct rds_tcp_connection *)conn->c_transport_data;
+	WARN_ON(!rs_tcp || rs_tcp->t_sock);
 
 	/*
 	 * see the comment above rds_queue_delayed_reconnect()
@@ -91,7 +102,7 @@ static int rds_tcp_accept_one(struct socket *sock)
 		goto out;
 	}
 
-	rds_tcp_set_callbacks(new_sock, conn);
+	rds_tcp_set_callbacks(new_sock, conn, true);
 	rds_connect_complete(conn);
 	new_sock = NULL;
 	ret = 0;
-- 
1.7.1
