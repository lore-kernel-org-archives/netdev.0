From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v2 1/2] net/rds: RDS-TCP: Always create a new rds_sock for an incoming connection.
Date: Tue,  5 May 2015 15:20:51 -0400
Message-ID: <a2af9a18e68bf1f34f2a17f7e3b25d2b66fd0e9a.1430843646.git.sowmini.varadhan@oracle.com>
References: <cover.1430843646.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, ajaykumar.hotchandani@oracle.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1430843646.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1430843646.git.sowmini.varadhan@oracle.com>
References: <cover.1430843646.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When running RDS over TCP, the active (client) side connects to the
listening ("passive") side at the RDS_TCP_PORT.  After the connection
is established, if the client side reboots (potentially without even
sending a FIN) the server still has a TCP socket in the esablished
state.  If the server-side now gets a new SYN comes from the client
with a different client port, TCP will create a new socket-pair, but
the RDS layer will incorrectly pull up the old rds_connection (which
is still associated with the stale t_sock and RDS socket state).

This patch corrects this behavior by having rds_tcp_accept_one()
always create a new connection for an incoming TCP SYN.
The rds and tcp state associated with the old socket-pair is cleaned
up via the rds_tcp_state_change() callback which would typically be
invoked in most cases when the client-TCP sends a FIN on TCP restart,
triggering a transition to CLOSE_WAIT state. In the rarer event of client
death without a FIN, TCP_KEEPALIVE probes on the socket will detect
the stale socket, and the TCP transition to CLOSE state will trigger
the RDS state cleanup.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2: DaveM comments- make the TCP server side recovery follow patterns in 
    NFS/RPC, and keep things neat without needless memory bloat.

 net/rds/connection.c  |    4 ++++
 net/rds/tcp_connect.c |    1 +
 net/rds/tcp_listen.c  |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 51 insertions(+), 0 deletions(-)

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
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index f9f564a..973109c 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -62,6 +62,7 @@ void rds_tcp_state_change(struct sock *sk)
 		case TCP_ESTABLISHED:
 			rds_connect_complete(conn);
 			break;
+		case TCP_CLOSE_WAIT:
 		case TCP_CLOSE:
 			rds_conn_drop(conn);
 		default:
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 23ab4dc..0da49e3 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -45,12 +45,45 @@ static void rds_tcp_accept_worker(struct work_struct *work);
 static DECLARE_WORK(rds_tcp_listen_work, rds_tcp_accept_worker);
 static struct socket *rds_tcp_listen_sock;
 
+static int rds_tcp_keepalive(struct socket *sock)
+{
+	/* values below based on xs_udp_default_timeout */
+	int keepidle = 5; /* send a probe 'keepidle' secs after last data */
+	int keepcnt = 5; /* number of unack'ed probes before declaring dead */
+	int keepalive = 1;
+	int ret = 0;
+
+	ret = kernel_setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE,
+				(char *)&keepalive, sizeof(keepalive));
+	if (ret < 0)
+		goto bail;
+
+	ret = kernel_setsockopt(sock, IPPROTO_TCP, TCP_KEEPCNT,
+				(char *)&keepcnt, sizeof(keepcnt));
+	if (ret < 0)
+		goto bail;
+
+	ret = kernel_setsockopt(sock, IPPROTO_TCP, TCP_KEEPIDLE,
+				(char *)&keepidle, sizeof(keepidle));
+	if (ret < 0)
+		goto bail;
+
+	/* KEEPINTVL is the interval between successive probes. We follow
+	 * the model in xs_tcp_finish_connecting() and re-use keepidle.
+	 */
+	ret = kernel_setsockopt(sock, IPPROTO_TCP, TCP_KEEPINTVL,
+				(char *)&keepidle, sizeof(keepidle));
+bail:
+	return ret;
+}
+
 static int rds_tcp_accept_one(struct socket *sock)
 {
 	struct socket *new_sock = NULL;
 	struct rds_connection *conn;
 	int ret;
 	struct inet_sock *inet;
+	struct rds_tcp_connection *rs_tcp;
 
 	ret = sock_create_lite(sock->sk->sk_family, sock->sk->sk_type,
 			       sock->sk->sk_protocol, &new_sock);
@@ -63,6 +96,10 @@ static int rds_tcp_accept_one(struct socket *sock)
 	if (ret < 0)
 		goto out;
 
+	ret = rds_tcp_keepalive(new_sock);
+	if (ret < 0)
+		goto out;
+
 	rds_tcp_tune(new_sock);
 
 	inet = inet_sk(new_sock->sk);
@@ -77,6 +114,15 @@ static int rds_tcp_accept_one(struct socket *sock)
 		ret = PTR_ERR(conn);
 		goto out;
 	}
+	/* An incoming SYN request came in, and TCP just accepted it.
+	 * We always create a new conn for listen side of TCP, and do not
+	 * add it to the c_hash_list.
+	 *
+	 * If the client reboots, this conn will need to be cleaned up.
+	 * rds_tcp_state_change() will do that cleanup
+	 */
+	rs_tcp = (struct rds_tcp_connection *)conn->c_transport_data;
+	WARN_ON(!rs_tcp || rs_tcp->t_sock);
 
 	/*
 	 * see the comment above rds_queue_delayed_reconnect()
-- 
1.7.1
