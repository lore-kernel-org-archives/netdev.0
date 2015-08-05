From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v3 net-next 1/2] RDS-TCP: Make RDS-TCP work correctly when it is set up in a netns other than init_net
Date: Wed,  5 Aug 2015 01:43:25 -0400
Message-ID: <a5441f9805603ed9f5d44a7f9a324e932a151e12.1438752224.git.sowmini.varadhan@oracle.com>
References: <cover.1438752224.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com,
	chien.yen@oracle.com, sowmini.varadhan@oracle.com,
	cwang@twopensource.com, dsahern@gmail.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1438752224.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1438752224.git.sowmini.varadhan@oracle.com>
References: <cover.1438752224.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Open the sockets calling sock_create_kern() with the correct struct net
pointer, and use that struct net pointer when verifying the
address passed to rds_bind().

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2: David Ahern comments.

 net/rds/bind.c        |    3 ++-
 net/rds/connection.c  |   16 ++++++++++------
 net/rds/ib.c          |    2 +-
 net/rds/ib_cm.c       |    5 +++--
 net/rds/iw.c          |    2 +-
 net/rds/iw_cm.c       |    5 +++--
 net/rds/rds.h         |   23 +++++++++++++++++++----
 net/rds/send.c        |    3 ++-
 net/rds/tcp.c         |    4 ++--
 net/rds/tcp_connect.c |    3 ++-
 net/rds/tcp_listen.c  |   16 ++++++++++++----
 net/rds/transport.c   |    4 ++--
 12 files changed, 59 insertions(+), 27 deletions(-)

diff --git a/net/rds/bind.c b/net/rds/bind.c
index 4ebd29c..dd666fb 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -185,7 +185,8 @@ int rds_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		ret = 0;
 		goto out;
 	}
-	trans = rds_trans_get_preferred(sin->sin_addr.s_addr);
+	trans = rds_trans_get_preferred(sock_net(sock->sk),
+					sin->sin_addr.s_addr);
 	if (!trans) {
 		ret = -EADDRNOTAVAIL;
 		rds_remove_bound(rs);
diff --git a/net/rds/connection.c b/net/rds/connection.c
index da6da57..d4fecb2 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -117,7 +117,8 @@ static void rds_conn_reset(struct rds_connection *conn)
  * For now they are not garbage collected once they're created.  They
  * are torn down as the module is removed, if ever.
  */
-static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
+static struct rds_connection *__rds_conn_create(struct net *net,
+						__be32 laddr, __be32 faddr,
 				       struct rds_transport *trans, gfp_t gfp,
 				       int is_outgoing)
 {
@@ -157,6 +158,7 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
 	conn->c_faddr = faddr;
 	spin_lock_init(&conn->c_lock);
 	conn->c_next_tx_seq = 1;
+	rds_conn_net_set(conn, net);
 
 	init_waitqueue_head(&conn->c_waitq);
 	INIT_LIST_HEAD(&conn->c_send_queue);
@@ -174,7 +176,7 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
 	 * can bind to the destination address then we'd rather the messages
 	 * flow through loopback rather than either transport.
 	 */
-	loop_trans = rds_trans_get_preferred(faddr);
+	loop_trans = rds_trans_get_preferred(net, faddr);
 	if (loop_trans) {
 		rds_trans_put(loop_trans);
 		conn->c_loopback = 1;
@@ -260,17 +262,19 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
 	return conn;
 }
 
-struct rds_connection *rds_conn_create(__be32 laddr, __be32 faddr,
+struct rds_connection *rds_conn_create(struct net *net,
+				       __be32 laddr, __be32 faddr,
 				       struct rds_transport *trans, gfp_t gfp)
 {
-	return __rds_conn_create(laddr, faddr, trans, gfp, 0);
+	return __rds_conn_create(net, laddr, faddr, trans, gfp, 0);
 }
 EXPORT_SYMBOL_GPL(rds_conn_create);
 
-struct rds_connection *rds_conn_create_outgoing(__be32 laddr, __be32 faddr,
+struct rds_connection *rds_conn_create_outgoing(struct net *net,
+						__be32 laddr, __be32 faddr,
 				       struct rds_transport *trans, gfp_t gfp)
 {
-	return __rds_conn_create(laddr, faddr, trans, gfp, 1);
+	return __rds_conn_create(net, laddr, faddr, trans, gfp, 1);
 }
 EXPORT_SYMBOL_GPL(rds_conn_create_outgoing);
 
diff --git a/net/rds/ib.c b/net/rds/ib.c
index ba2dffe..1381422 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -317,7 +317,7 @@ static void rds_ib_ic_info(struct socket *sock, unsigned int len,
  * allowed to influence which paths have priority.  We could call userspace
  * asserting this policy "routing".
  */
-static int rds_ib_laddr_check(__be32 addr)
+static int rds_ib_laddr_check(struct net *net, __be32 addr)
 {
 	int ret;
 	struct rdma_cm_id *cm_id;
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 0da2a45..f40d8f5 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -448,8 +448,9 @@ int rds_ib_cm_handle_connect(struct rdma_cm_id *cm_id,
 		 (unsigned long long)be64_to_cpu(lguid),
 		 (unsigned long long)be64_to_cpu(fguid));
 
-	conn = rds_conn_create(dp->dp_daddr, dp->dp_saddr, &rds_ib_transport,
-			       GFP_KERNEL);
+	/* RDS/IB is not currently netns aware, thus init_net */
+	conn = rds_conn_create(&init_net, dp->dp_daddr, dp->dp_saddr,
+			       &rds_ib_transport, GFP_KERNEL);
 	if (IS_ERR(conn)) {
 		rdsdebug("rds_conn_create failed (%ld)\n", PTR_ERR(conn));
 		conn = NULL;
diff --git a/net/rds/iw.c b/net/rds/iw.c
index 5899356..5d5a9d2 100644
--- a/net/rds/iw.c
+++ b/net/rds/iw.c
@@ -218,7 +218,7 @@ static void rds_iw_ic_info(struct socket *sock, unsigned int len,
  * allowed to influence which paths have priority.  We could call userspace
  * asserting this policy "routing".
  */
-static int rds_iw_laddr_check(__be32 addr)
+static int rds_iw_laddr_check(struct net *net, __be32 addr)
 {
 	int ret;
 	struct rdma_cm_id *cm_id;
diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
index 8f486fa..a6553a6 100644
--- a/net/rds/iw_cm.c
+++ b/net/rds/iw_cm.c
@@ -398,8 +398,9 @@ int rds_iw_cm_handle_connect(struct rdma_cm_id *cm_id,
 		 &dp->dp_saddr, &dp->dp_daddr,
 		 RDS_PROTOCOL_MAJOR(version), RDS_PROTOCOL_MINOR(version));
 
-	conn = rds_conn_create(dp->dp_daddr, dp->dp_saddr, &rds_iw_transport,
-			       GFP_KERNEL);
+	/* RDS/IW is not currently netns aware, thus init_net */
+	conn = rds_conn_create(&init_net, dp->dp_daddr, dp->dp_saddr,
+			       &rds_iw_transport, GFP_KERNEL);
 	if (IS_ERR(conn)) {
 		rdsdebug("rds_conn_create failed (%ld)\n", PTR_ERR(conn));
 		conn = NULL;
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 2260c1e..9005fb0 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -128,8 +128,21 @@ struct rds_connection {
 
 	/* Protocol version */
 	unsigned int		c_version;
+	possible_net_t		c_net;
 };
 
+static inline
+struct net *rds_conn_net(struct rds_connection *conn)
+{
+	return read_pnet(&conn->c_net);
+}
+
+static inline
+void rds_conn_net_set(struct rds_connection *conn, struct net *net)
+{
+	write_pnet(&conn->c_net, net);
+}
+
 #define RDS_FLAG_CONG_BITMAP	0x01
 #define RDS_FLAG_ACK_REQUIRED	0x02
 #define RDS_FLAG_RETRANSMITTED	0x04
@@ -417,7 +430,7 @@ struct rds_transport {
 	unsigned int		t_prefer_loopback:1;
 	unsigned int		t_type;
 
-	int (*laddr_check)(__be32 addr);
+	int (*laddr_check)(struct net *net, __be32 addr);
 	int (*conn_alloc)(struct rds_connection *conn, gfp_t gfp);
 	void (*conn_free)(void *data);
 	int (*conn_connect)(struct rds_connection *conn);
@@ -608,9 +621,11 @@ struct rds_message *rds_cong_update_alloc(struct rds_connection *conn);
 /* conn.c */
 int rds_conn_init(void);
 void rds_conn_exit(void);
-struct rds_connection *rds_conn_create(__be32 laddr, __be32 faddr,
+struct rds_connection *rds_conn_create(struct net *net,
+				       __be32 laddr, __be32 faddr,
 				       struct rds_transport *trans, gfp_t gfp);
-struct rds_connection *rds_conn_create_outgoing(__be32 laddr, __be32 faddr,
+struct rds_connection *rds_conn_create_outgoing(struct net *net,
+						__be32 laddr, __be32 faddr,
 			       struct rds_transport *trans, gfp_t gfp);
 void rds_conn_shutdown(struct rds_connection *conn);
 void rds_conn_destroy(struct rds_connection *conn);
@@ -795,7 +810,7 @@ void rds_connect_complete(struct rds_connection *conn);
 /* transport.c */
 int rds_trans_register(struct rds_transport *trans);
 void rds_trans_unregister(struct rds_transport *trans);
-struct rds_transport *rds_trans_get_preferred(__be32 addr);
+struct rds_transport *rds_trans_get_preferred(struct net *net, __be32 addr);
 void rds_trans_put(struct rds_transport *trans);
 unsigned int rds_trans_stats_info_copy(struct rds_info_iterator *iter,
 				       unsigned int avail);
diff --git a/net/rds/send.c b/net/rds/send.c
index e9430f5..2581b8e 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -1023,7 +1023,8 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 	if (rs->rs_conn && rs->rs_conn->c_faddr == daddr)
 		conn = rs->rs_conn;
 	else {
-		conn = rds_conn_create_outgoing(rs->rs_bound_addr, daddr,
+		conn = rds_conn_create_outgoing(sock_net(sock->sk),
+						rs->rs_bound_addr, daddr,
 					rs->rs_transport,
 					sock->sk->sk_allocation);
 		if (IS_ERR(conn)) {
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index edac9ef..98f5de3 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -189,9 +189,9 @@ static void rds_tcp_tc_info(struct socket *sock, unsigned int len,
 	spin_unlock_irqrestore(&rds_tcp_tc_list_lock, flags);
 }
 
-static int rds_tcp_laddr_check(__be32 addr)
+static int rds_tcp_laddr_check(struct net *net, __be32 addr)
 {
-	if (inet_addr_type(&init_net, addr) == RTN_LOCAL)
+	if (inet_addr_type(net, addr) == RTN_LOCAL)
 		return 0;
 	return -EADDRNOTAVAIL;
 }
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index 973109c..6473b7b 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -79,7 +79,8 @@ int rds_tcp_conn_connect(struct rds_connection *conn)
 	struct sockaddr_in src, dest;
 	int ret;
 
-	ret = sock_create(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
+	ret = sock_create_kern(rds_conn_net(conn), PF_INET,
+			       SOCK_STREAM, IPPROTO_TCP, &sock);
 	if (ret < 0)
 		goto out;
 
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 0da49e3..398ffe5 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -85,8 +85,9 @@ static int rds_tcp_accept_one(struct socket *sock)
 	struct inet_sock *inet;
 	struct rds_tcp_connection *rs_tcp;
 
-	ret = sock_create_lite(sock->sk->sk_family, sock->sk->sk_type,
-			       sock->sk->sk_protocol, &new_sock);
+	ret = sock_create_kern(sock_net(sock->sk), sock->sk->sk_family,
+			       sock->sk->sk_type, sock->sk->sk_protocol,
+			       &new_sock);
 	if (ret)
 		goto out;
 
@@ -108,7 +109,8 @@ static int rds_tcp_accept_one(struct socket *sock)
 		 &inet->inet_saddr, ntohs(inet->inet_sport),
 		 &inet->inet_daddr, ntohs(inet->inet_dport));
 
-	conn = rds_conn_create(inet->inet_saddr, inet->inet_daddr,
+	conn = rds_conn_create(sock_net(sock->sk),
+			       inet->inet_saddr, inet->inet_daddr,
 			       &rds_tcp_transport, GFP_KERNEL);
 	if (IS_ERR(conn)) {
 		ret = PTR_ERR(conn);
@@ -187,7 +189,13 @@ int rds_tcp_listen_init(void)
 	struct socket *sock = NULL;
 	int ret;
 
-	ret = sock_create(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
+	/* MUST call sock_create_kern directly so that we avoid get_net()
+	 * in sk_alloc(). Doing a get_net() will result in cleanup_net()
+	 * never getting invoked, which will leave sock and other things
+	 * in limbo.
+	 */
+	ret = sock_create_kern(current->nsproxy->net_ns, PF_INET,
+			       SOCK_STREAM, IPPROTO_TCP, &sock);
 	if (ret < 0)
 		goto out;
 
diff --git a/net/rds/transport.c b/net/rds/transport.c
index 83498e1..f3afd1d 100644
--- a/net/rds/transport.c
+++ b/net/rds/transport.c
@@ -77,7 +77,7 @@ void rds_trans_put(struct rds_transport *trans)
 		module_put(trans->t_owner);
 }
 
-struct rds_transport *rds_trans_get_preferred(__be32 addr)
+struct rds_transport *rds_trans_get_preferred(struct net *net, __be32 addr)
 {
 	struct rds_transport *ret = NULL;
 	struct rds_transport *trans;
@@ -90,7 +90,7 @@ struct rds_transport *rds_trans_get_preferred(__be32 addr)
 	for (i = 0; i < RDS_TRANS_COUNT; i++) {
 		trans = transports[i];
 
-		if (trans && (trans->laddr_check(addr) == 0) &&
+		if (trans && (trans->laddr_check(net, addr) == 0) &&
 		    (!trans->t_owner || try_module_get(trans->t_owner))) {
 			ret = trans;
 			break;
-- 
1.7.1
