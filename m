From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 3/5] RDS: TCP: Enable multipath RDS for TCP
Date: Thu, 14 Jul 2016 03:51:03 -0700
Message-ID: <7a00f744a33192a5126b30419f7526795ab77cae.1468488884.git.sowmini.varadhan@oracle.com>
References: <cover.1468488884.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42531 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058AbcGNKv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 06:51:26 -0400
In-Reply-To: <cover.1468488884.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1468488884.git.sowmini.varadhan@oracle.com>
References: <cover.1468488884.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use RDS probe-ping to compute how many paths may be used with
the peer, and to synchronously start the multiple paths. If mprds is
supported, hash outgoing traffic to one of multiple paths in rds_sendmsg()
when multipath RDS is supported by the transport.

CC: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/bind.c        |    6 ++++
 net/rds/connection.c  |   17 +++++------
 net/rds/message.c     |    1 +
 net/rds/rds.h         |   25 +++++++++++++++-
 net/rds/recv.c        |   75 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/rds/send.c        |   71 +++++++++++++++++++++++++++++++++++++++++++--
 net/rds/tcp.c         |    2 +-
 net/rds/tcp_connect.c |    7 ++++-
 net/rds/tcp_listen.c  |   63 ++++++++++++++++++++++++++++++++++++-----
 net/rds/tcp_send.c    |   18 ++++++++---
 net/rds/threads.c     |    2 +
 11 files changed, 257 insertions(+), 30 deletions(-)

diff --git a/net/rds/bind.c b/net/rds/bind.c
index b22ea95..095f6ce 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -81,6 +81,8 @@ static int rds_add_bound(struct rds_sock *rs, __be32 addr, __be16 *port)
 
 	if (*port != 0) {
 		rover = be16_to_cpu(*port);
+		if (rover == RDS_FLAG_PROBE_PORT)
+			return -EINVAL;
 		last = rover;
 	} else {
 		rover = max_t(u16, prandom_u32(), 2);
@@ -91,12 +93,16 @@ static int rds_add_bound(struct rds_sock *rs, __be32 addr, __be16 *port)
 		if (rover == 0)
 			rover++;
 
+		if (rover == RDS_FLAG_PROBE_PORT)
+			continue;
 		key = ((u64)addr << 32) | cpu_to_be16(rover);
 		if (rhashtable_lookup_fast(&bind_hash_table, &key, ht_parms))
 			continue;
 
 		rs->rs_bound_key = key;
 		rs->rs_bound_addr = addr;
+		net_get_random_once(&rs->rs_hash_initval,
+				    sizeof(rs->rs_hash_initval));
 		rs->rs_bound_port = cpu_to_be16(rover);
 		rs->rs_bound_node.next = NULL;
 		rds_sock_addref(rs);
diff --git a/net/rds/connection.c b/net/rds/connection.c
index 19a4fee..f505855 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -155,7 +155,7 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 	struct hlist_head *head = rds_conn_bucket(laddr, faddr);
 	struct rds_transport *loop_trans;
 	unsigned long flags;
-	int ret;
+	int ret, i;
 
 	rcu_read_lock();
 	conn = rds_conn_lookup(net, head, laddr, faddr, trans);
@@ -211,6 +211,12 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 
 	conn->c_trans = trans;
 
+	init_waitqueue_head(&conn->c_hs_waitq);
+	for (i = 0; i < RDS_MPATH_WORKERS; i++) {
+		__rds_conn_path_init(conn, &conn->c_path[i],
+				     is_outgoing);
+		conn->c_path[i].cp_index = i;
+	}
 	ret = trans->conn_alloc(conn, gfp);
 	if (ret) {
 		kmem_cache_free(rds_conn_slab, conn);
@@ -263,14 +269,6 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 			kmem_cache_free(rds_conn_slab, conn);
 			conn = found;
 		} else {
-			int i;
-
-			for (i = 0; i < RDS_MPATH_WORKERS; i++) {
-				__rds_conn_path_init(conn, &conn->c_path[i],
-						     is_outgoing);
-				conn->c_path[i].cp_index = i;
-			}
-
 			hlist_add_head_rcu(&conn->c_hash_node, head);
 			rds_cong_add_conn(conn);
 			rds_conn_count++;
@@ -668,6 +666,7 @@ EXPORT_SYMBOL_GPL(rds_conn_path_drop);
 
 void rds_conn_drop(struct rds_connection *conn)
 {
+	WARN_ON(conn->c_trans->t_mp_capable);
 	rds_conn_path_drop(&conn->c_path[0]);
 }
 EXPORT_SYMBOL_GPL(rds_conn_drop);
diff --git a/net/rds/message.c b/net/rds/message.c
index 756c737..6cb9106 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -41,6 +41,7 @@ static unsigned int	rds_exthdr_size[__RDS_EXTHDR_MAX] = {
 [RDS_EXTHDR_VERSION]	= sizeof(struct rds_ext_header_version),
 [RDS_EXTHDR_RDMA]	= sizeof(struct rds_ext_header_rdma),
 [RDS_EXTHDR_RDMA_DEST]	= sizeof(struct rds_ext_header_rdma_dest),
+[RDS_EXTHDR_NPATHS]	= sizeof(u16),
 };
 
 
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 6ef07bd..b2d17f0 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -85,7 +85,9 @@ enum {
 #define RDS_RECV_REFILL		3
 
 /* Max number of multipaths per RDS connection. Must be a power of 2 */
-#define	RDS_MPATH_WORKERS	1
+#define	RDS_MPATH_WORKERS	8
+#define	RDS_MPATH_HASH(rs, n) (jhash_1word((rs)->rs_bound_port, \
+			       (rs)->rs_hash_initval) & ((n) - 1))
 
 /* Per mpath connection state */
 struct rds_conn_path {
@@ -131,7 +133,8 @@ struct rds_connection {
 	__be32			c_laddr;
 	__be32			c_faddr;
 	unsigned int		c_loopback:1,
-				c_pad_to_32:31;
+				c_ping_triggered:1,
+				c_pad_to_32:30;
 	int			c_npaths;
 	struct rds_connection	*c_passive;
 	struct rds_transport	*c_trans;
@@ -147,6 +150,7 @@ struct rds_connection {
 	unsigned long		c_map_queued;
 
 	struct rds_conn_path	c_path[RDS_MPATH_WORKERS];
+	wait_queue_head_t	c_hs_waitq; /* handshake waitq */
 };
 
 static inline
@@ -166,6 +170,17 @@ void rds_conn_net_set(struct rds_connection *conn, struct net *net)
 #define RDS_FLAG_RETRANSMITTED	0x04
 #define RDS_MAX_ADV_CREDIT	255
 
+/* RDS_FLAG_PROBE_PORT is the reserved sport used for sending a ping
+ * probe to exchange control information before establishing a connection.
+ * Currently the control information that is exchanged is the number of
+ * supported paths. If the peer is a legacy (older kernel revision) peer,
+ * it would return a pong message without additional control information
+ * that would then alert the sender that the peer was an older rev.
+ */
+#define RDS_FLAG_PROBE_PORT	1
+#define	RDS_HS_PROBE(sport, dport) \
+		((sport == RDS_FLAG_PROBE_PORT && dport == 0) || \
+		 (sport == 0 && dport == RDS_FLAG_PROBE_PORT))
 /*
  * Maximum space available for extension headers.
  */
@@ -225,6 +240,11 @@ struct rds_ext_header_rdma_dest {
 	__be32			h_rdma_offset;
 };
 
+/* Extension header announcing number of paths.
+ * Implicit length = 2 bytes.
+ */
+#define RDS_EXTHDR_NPATHS	4
+
 #define __RDS_EXTHDR_MAX	16 /* for now */
 
 struct rds_incoming {
@@ -545,6 +565,7 @@ struct rds_sock {
 	/* Socket options - in case there will be more */
 	unsigned char		rs_recverr,
 				rs_cong_monitor;
+	u32			rs_hash_initval;
 };
 
 static inline struct rds_sock *rds_sk_to_rs(const struct sock *sk)
diff --git a/net/rds/recv.c b/net/rds/recv.c
index fed53a6..cbfabdf 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -156,6 +156,67 @@ static void rds_recv_incoming_exthdrs(struct rds_incoming *inc, struct rds_sock 
 	}
 }
 
+static void rds_recv_hs_exthdrs(struct rds_header *hdr,
+				struct rds_connection *conn)
+{
+	unsigned int pos = 0, type, len;
+	union {
+		struct rds_ext_header_version version;
+		u16 rds_npaths;
+	} buffer;
+
+	while (1) {
+		len = sizeof(buffer);
+		type = rds_message_next_extension(hdr, &pos, &buffer, &len);
+		if (type == RDS_EXTHDR_NONE)
+			break;
+		/* Process extension header here */
+		switch (type) {
+		case RDS_EXTHDR_NPATHS:
+			conn->c_npaths = min_t(int, RDS_MPATH_WORKERS,
+					       buffer.rds_npaths);
+			break;
+		default:
+			pr_warn_ratelimited("ignoring unknown exthdr type "
+					     "0x%x\n", type);
+		}
+	}
+	/* if RDS_EXTHDR_NPATHS was not found, default to a single-path */
+	conn->c_npaths = max_t(int, conn->c_npaths, 1);
+}
+
+/* rds_start_mprds() will synchronously start multiple paths when appropriate.
+ * The scheme is based on the following rules:
+ *
+ * 1. rds_sendmsg on first connect attempt sends the probe ping, with the
+ *    sender's npaths (s_npaths)
+ * 2. rcvr of probe-ping knows the mprds_paths = min(s_npaths, r_npaths). It
+ *    sends back a probe-pong with r_npaths. After that, if rcvr is the
+ *    smaller ip addr, it starts rds_conn_path_connect_if_down on all
+ *    mprds_paths.
+ * 3. sender gets woken up, and can move to rds_conn_path_connect_if_down.
+ *    If it is the smaller ipaddr, rds_conn_path_connect_if_down can be
+ *    called after reception of the probe-pong on all mprds_paths.
+ *    Otherwise (sender of probe-ping is not the smaller ip addr): just call
+ *    rds_conn_path_connect_if_down on the hashed path. (see rule 4)
+ * 4. when cp_index > 0, rds_connect_worker must only trigger
+ *    a connection if laddr < faddr.
+ * 5. sender may end up queuing the packet on the cp. will get sent out later.
+ *    when connection is completed.
+ */
+static void rds_start_mprds(struct rds_connection *conn)
+{
+	int i;
+	struct rds_conn_path *cp;
+
+	if (conn->c_npaths > 1 && conn->c_laddr < conn->c_faddr) {
+		for (i = 1; i < conn->c_npaths; i++) {
+			cp = &conn->c_path[i];
+			rds_conn_path_connect_if_down(cp);
+		}
+	}
+}
+
 /*
  * The transport must make sure that this is serialized against other
  * rx and conn reset on this specific conn.
@@ -232,6 +293,20 @@ void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
 		}
 		rds_stats_inc(s_recv_ping);
 		rds_send_pong(cp, inc->i_hdr.h_sport);
+		/* if this is a handshake ping, start multipath if necessary */
+		if (RDS_HS_PROBE(inc->i_hdr.h_sport, inc->i_hdr.h_dport)) {
+			rds_recv_hs_exthdrs(&inc->i_hdr, cp->cp_conn);
+			rds_start_mprds(cp->cp_conn);
+		}
+		goto out;
+	}
+
+	if (inc->i_hdr.h_dport ==  RDS_FLAG_PROBE_PORT &&
+	    inc->i_hdr.h_sport == 0) {
+		rds_recv_hs_exthdrs(&inc->i_hdr, cp->cp_conn);
+		/* if this is a handshake pong, start multipath if necessary */
+		rds_start_mprds(cp->cp_conn);
+		wake_up(&cp->cp_conn->c_hs_waitq);
 		goto out;
 	}
 
diff --git a/net/rds/send.c b/net/rds/send.c
index 5a9caf1..896626b 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -963,6 +963,29 @@ static int rds_cmsg_send(struct rds_sock *rs, struct rds_message *rm,
 	return ret;
 }
 
+static void rds_send_ping(struct rds_connection *conn);
+
+static int rds_send_mprds_hash(struct rds_sock *rs, struct rds_connection *conn)
+{
+	int hash;
+
+	if (conn->c_npaths == 0)
+		hash = RDS_MPATH_HASH(rs, RDS_MPATH_WORKERS);
+	else
+		hash = RDS_MPATH_HASH(rs, conn->c_npaths);
+	if (conn->c_npaths == 0 && hash != 0) {
+		rds_send_ping(conn);
+
+		if (conn->c_npaths == 0) {
+			wait_event_interruptible(conn->c_hs_waitq,
+						 (conn->c_npaths != 0));
+		}
+		if (conn->c_npaths == 1)
+			hash = 0;
+	}
+	return hash;
+}
+
 int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 {
 	struct sock *sk = sock->sk;
@@ -1075,7 +1098,10 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 		goto out;
 	}
 
-	cpath = &conn->c_path[0];
+	if (conn->c_trans->t_mp_capable)
+		cpath = &conn->c_path[rds_send_mprds_hash(rs, conn)];
+	else
+		cpath = &conn->c_path[0];
 
 	rds_conn_path_connect_if_down(cpath);
 
@@ -1135,10 +1161,16 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 }
 
 /*
- * Reply to a ping packet.
+ * send out a probe. Can be shared by rds_send_ping,
+ * rds_send_pong, rds_send_hb.
+ * rds_send_hb should use h_flags
+ *   RDS_FLAG_HB_PING|RDS_FLAG_ACK_REQUIRED
+ * or
+ *   RDS_FLAG_HB_PONG|RDS_FLAG_ACK_REQUIRED
  */
 int
-rds_send_pong(struct rds_conn_path *cp, __be16 dport)
+rds_send_probe(struct rds_conn_path *cp, __be16 sport,
+	       __be16 dport, u8 h_flags)
 {
 	struct rds_message *rm;
 	unsigned long flags;
@@ -1166,9 +1198,18 @@ rds_send_pong(struct rds_conn_path *cp, __be16 dport)
 	rm->m_inc.i_conn = cp->cp_conn;
 	rm->m_inc.i_conn_path = cp;
 
-	rds_message_populate_header(&rm->m_inc.i_hdr, 0, dport,
+	rds_message_populate_header(&rm->m_inc.i_hdr, sport, dport,
 				    cp->cp_next_tx_seq);
+	rm->m_inc.i_hdr.h_flags |= h_flags;
 	cp->cp_next_tx_seq++;
+
+	if (RDS_HS_PROBE(sport, dport) && cp->cp_conn->c_trans->t_mp_capable) {
+		u16 npaths = RDS_MPATH_WORKERS;
+
+		rds_message_add_extension(&rm->m_inc.i_hdr,
+					  RDS_EXTHDR_NPATHS, &npaths,
+					  sizeof(npaths));
+	}
 	spin_unlock_irqrestore(&cp->cp_lock, flags);
 
 	rds_stats_inc(s_send_queued);
@@ -1185,3 +1226,25 @@ rds_send_pong(struct rds_conn_path *cp, __be16 dport)
 		rds_message_put(rm);
 	return ret;
 }
+
+int
+rds_send_pong(struct rds_conn_path *cp, __be16 dport)
+{
+	return rds_send_probe(cp, 0, dport, 0);
+}
+
+void
+rds_send_ping(struct rds_connection *conn)
+{
+	unsigned long flags;
+	struct rds_conn_path *cp = &conn->c_path[0];
+
+	spin_lock_irqsave(&cp->cp_lock, flags);
+	if (conn->c_ping_triggered) {
+		spin_unlock_irqrestore(&cp->cp_lock, flags);
+		return;
+	}
+	conn->c_ping_triggered = 1;
+	spin_unlock_irqrestore(&cp->cp_lock, flags);
+	rds_send_probe(&conn->c_path[0], RDS_FLAG_PROBE_PORT, 0, 0);
+}
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index a4a67f6..52a5b90 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -38,7 +38,6 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
-#include "rds_single_path.h"
 #include "rds.h"
 #include "tcp.h"
 
@@ -358,6 +357,7 @@ struct rds_transport rds_tcp_transport = {
 	.t_name			= "tcp",
 	.t_type			= RDS_TRANS_TCP,
 	.t_prefer_loopback	= 1,
+	.t_mp_capable		= 1,
 };
 
 static int rds_tcp_netid;
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index c916715..05f61c5 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -34,7 +34,6 @@
 #include <linux/in.h>
 #include <net/tcp.h>
 
-#include "rds_single_path.h"
 #include "rds.h"
 #include "tcp.h"
 
@@ -82,6 +81,12 @@ int rds_tcp_conn_path_connect(struct rds_conn_path *cp)
 	struct rds_connection *conn = cp->cp_conn;
 	struct rds_tcp_connection *tc = cp->cp_transport_data;
 
+	/* for multipath rds,we only trigger the connection after
+	 * the handshake probe has determined the number of paths.
+	 */
+	if (cp->cp_index > 0 && cp->cp_conn->c_npaths < 2)
+		return -EAGAIN;
+
 	mutex_lock(&tc->t_conn_path_lock);
 
 	if (rds_conn_path_up(cp)) {
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 73040e3..e0b23fb 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -35,7 +35,6 @@
 #include <linux/in.h>
 #include <net/tcp.h>
 
-#include "rds_single_path.h"
 #include "rds.h"
 #include "tcp.h"
 
@@ -71,6 +70,52 @@ int rds_tcp_keepalive(struct socket *sock)
 	return ret;
 }
 
+/* rds_tcp_accept_one_path(): if accepting on cp_index > 0, make sure the
+ * client's ipaddr < server's ipaddr. Otherwise, close the accepted
+ * socket and force a reconneect from smaller -> larger ip addr. The reason
+ * we special case cp_index 0 is to allow the rds probe ping itself to itself
+ * get through efficiently.
+ * Since reconnects are only initiated from the node with the numerically
+ * smaller ip address, we recycle conns in RDS_CONN_ERROR on the passive side
+ * by moving them to CONNECTING in this function.
+ */
+struct rds_tcp_connection *rds_tcp_accept_one_path(struct rds_connection *conn)
+{
+	int i;
+	bool peer_is_smaller = (conn->c_faddr < conn->c_laddr);
+	int npaths = conn->c_npaths;
+
+	if (npaths <= 1) {
+		struct rds_conn_path *cp = &conn->c_path[0];
+		int ret;
+
+		ret = rds_conn_path_transition(cp, RDS_CONN_DOWN,
+					       RDS_CONN_CONNECTING);
+		if (!ret)
+			rds_conn_path_transition(cp, RDS_CONN_ERROR,
+						 RDS_CONN_CONNECTING);
+		return cp->cp_transport_data;
+	}
+
+	/* for mprds, paths with cp_index > 0 MUST be initiated by the peer
+	 * with the smaller address.
+	 */
+	if (!peer_is_smaller)
+		return NULL;
+
+	for (i = 1; i < npaths; i++) {
+		struct rds_conn_path *cp = &conn->c_path[i];
+
+		if (rds_conn_path_transition(cp, RDS_CONN_DOWN,
+					     RDS_CONN_CONNECTING) ||
+		    rds_conn_path_transition(cp, RDS_CONN_ERROR,
+					     RDS_CONN_CONNECTING)) {
+			return cp->cp_transport_data;
+		}
+	}
+	return NULL;
+}
+
 int rds_tcp_accept_one(struct socket *sock)
 {
 	struct socket *new_sock = NULL;
@@ -120,12 +165,14 @@ int rds_tcp_accept_one(struct socket *sock)
 	 * If the client reboots, this conn will need to be cleaned up.
 	 * rds_tcp_state_change() will do that cleanup
 	 */
-	rs_tcp = (struct rds_tcp_connection *)conn->c_transport_data;
-	cp = &conn->c_path[0];
-	rds_conn_transition(conn, RDS_CONN_DOWN, RDS_CONN_CONNECTING);
+	rs_tcp = rds_tcp_accept_one_path(conn);
+	if (!rs_tcp)
+		goto rst_nsk;
 	mutex_lock(&rs_tcp->t_conn_path_lock);
-	conn_state = rds_conn_state(conn);
-	if (conn_state != RDS_CONN_CONNECTING && conn_state != RDS_CONN_UP)
+	cp = rs_tcp->t_cpath;
+	conn_state = rds_conn_path_state(cp);
+	if (conn_state != RDS_CONN_CONNECTING && conn_state != RDS_CONN_UP &&
+	    conn_state != RDS_CONN_ERROR)
 		goto rst_nsk;
 	if (rs_tcp->t_sock) {
 		/* Need to resolve a duelling SYN between peers.
@@ -135,11 +182,11 @@ int rds_tcp_accept_one(struct socket *sock)
 		 * c_transport_data.
 		 */
 		if (ntohl(inet->inet_saddr) < ntohl(inet->inet_daddr) ||
-		    !conn->c_path[0].cp_outgoing) {
+		    !cp->cp_outgoing) {
 			goto rst_nsk;
 		} else {
 			rds_tcp_reset_callbacks(new_sock, cp);
-			conn->c_path[0].cp_outgoing = 0;
+			cp->cp_outgoing = 0;
 			/* rds_connect_path_complete() marks RDS_CONN_UP */
 			rds_connect_path_complete(cp, RDS_CONN_RESETTING);
 		}
diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index 57e0f58..89d09b4 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -81,7 +81,8 @@ static int rds_tcp_sendmsg(struct socket *sock, void *data, unsigned int len)
 int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
 		 unsigned int hdr_off, unsigned int sg, unsigned int off)
 {
-	struct rds_tcp_connection *tc = conn->c_transport_data;
+	struct rds_conn_path *cp = rm->m_inc.i_conn_path;
+	struct rds_tcp_connection *tc = cp->cp_transport_data;
 	int done = 0;
 	int ret = 0;
 	int more;
@@ -150,10 +151,17 @@ int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
 			rds_tcp_stats_inc(s_tcp_sndbuf_full);
 			ret = 0;
 		} else {
-			printk(KERN_WARNING "RDS/tcp: send to %pI4 "
-			       "returned %d, disconnecting and reconnecting\n",
-			       &conn->c_faddr, ret);
-			rds_conn_drop(conn);
+			/* No need to disconnect/reconnect if path_drop
+			 * has already been triggered, because, e.g., of
+			 * an incoming RST.
+			 */
+			if (rds_conn_path_up(cp)) {
+				pr_warn("RDS/tcp: send to %pI4 on cp [%d]"
+					"returned %d, "
+					"disconnecting and reconnecting\n",
+					&conn->c_faddr, cp->cp_index, ret);
+				rds_conn_path_drop(cp);
+			}
 		}
 	}
 	if (done == 0)
diff --git a/net/rds/threads.c b/net/rds/threads.c
index bc97d67..e42df11 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -156,6 +156,8 @@ void rds_connect_worker(struct work_struct *work)
 	struct rds_connection *conn = cp->cp_conn;
 	int ret;
 
+	if (cp->cp_index > 1 && cp->cp_conn->c_laddr > cp->cp_conn->c_faddr)
+		return;
 	clear_bit(RDS_RECONNECT_PENDING, &cp->cp_flags);
 	ret = rds_conn_path_transition(cp, RDS_CONN_DOWN, RDS_CONN_CONNECTING);
 	if (ret) {
-- 
1.7.1
