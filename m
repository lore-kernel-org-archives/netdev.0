From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 2/3] RDS: TCP: Track peer's connection generation number
Date: Wed, 16 Nov 2016 13:29:49 -0800
Message-ID: <19c4cdf5c438b9cc4fe7445328999db2a4832c01.1478876910.git.sowmini.varadhan@oracle.com>
References: <cover.1478876910.git.sowmini.varadhan@oracle.com>
Cc: santosh.shilimkar@oracle.com, sowmini.varadhan@oracle.com,
        davem@davemloft.net, rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32809 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933944AbcKPVaD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 16:30:03 -0500
In-Reply-To: <cover.1478876910.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1478876910.git.sowmini.varadhan@oracle.com>
References: <cover.1478876910.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RDS transport has to be able to distinguish between
two types of failure events:
(a) when the transport fails (e.g., TCP connection reset)
    but the RDS socket/connection layer on both sides stays
    the same
(b) when the peer's RDS layer itself resets (e.g., due to module
    reload or machine reboot at the peer)
In case (a) both sides must reconnect and continue the RDS messaging
without any message loss or disruption to the message sequence numbers,
and this is achieved by rds_send_path_reset().

In case (b) we should reset all rds_connection state to the
new incarnation of the peer. Examples of state that needs to
be reset are next expected rx sequence number from, or messages to be
retransmitted to, the new incarnation of the peer.

To achieve this, the RDS handshake probe added as part of
commit 5916e2c1554f ("RDS: TCP: Enable multipath RDS for TCP")
is enhanced so that sender and receiver of the RDS ping-probe
will add a generation number as part of the RDS_EXTHDR_GEN_NUM
extension header. Each peer stores local and remote generation
numbers as part of each rds_connection. Changes in generation
number will be detected via incoming handshake probe ping
request or response and will allow the receiver to reset rds_connection
state.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/af_rds.c     |    4 ++++
 net/rds/connection.c |    2 ++
 net/rds/message.c    |    1 +
 net/rds/rds.h        |    8 +++++++-
 net/rds/recv.c       |   36 ++++++++++++++++++++++++++++++++++++
 net/rds/send.c       |    9 +++++++--
 6 files changed, 57 insertions(+), 3 deletions(-)

diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index 6beaeb1..2ac1e61 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -605,10 +605,14 @@ static void rds_exit(void)
 }
 module_exit(rds_exit);
 
+u32 rds_gen_num;
+
 static int rds_init(void)
 {
 	int ret;
 
+	net_get_random_once(&rds_gen_num, sizeof(rds_gen_num));
+
 	ret = rds_bind_lock_init();
 	if (ret)
 		goto out;
diff --git a/net/rds/connection.c b/net/rds/connection.c
index 13f459d..b86e188 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -269,6 +269,8 @@ static void __rds_conn_path_init(struct rds_connection *conn,
 			kmem_cache_free(rds_conn_slab, conn);
 			conn = found;
 		} else {
+			conn->c_my_gen_num = rds_gen_num;
+			conn->c_peer_gen_num = 0;
 			hlist_add_head_rcu(&conn->c_hash_node, head);
 			rds_cong_add_conn(conn);
 			rds_conn_count++;
diff --git a/net/rds/message.c b/net/rds/message.c
index 6cb9106..49bfb51 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -42,6 +42,7 @@
 [RDS_EXTHDR_RDMA]	= sizeof(struct rds_ext_header_rdma),
 [RDS_EXTHDR_RDMA_DEST]	= sizeof(struct rds_ext_header_rdma_dest),
 [RDS_EXTHDR_NPATHS]	= sizeof(u16),
+[RDS_EXTHDR_GEN_NUM]	= sizeof(u32),
 };
 
 
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 4121e18..ebbf909 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -151,6 +151,9 @@ struct rds_connection {
 
 	struct rds_conn_path	c_path[RDS_MPATH_WORKERS];
 	wait_queue_head_t	c_hs_waitq; /* handshake waitq */
+
+	u32			c_my_gen_num;
+	u32			c_peer_gen_num;
 };
 
 static inline
@@ -243,7 +246,8 @@ struct rds_ext_header_rdma_dest {
 /* Extension header announcing number of paths.
  * Implicit length = 2 bytes.
  */
-#define RDS_EXTHDR_NPATHS	4
+#define RDS_EXTHDR_NPATHS	5
+#define RDS_EXTHDR_GEN_NUM	6
 
 #define __RDS_EXTHDR_MAX	16 /* for now */
 
@@ -338,6 +342,7 @@ static inline u32 rds_rdma_cookie_offset(rds_rdma_cookie_t cookie)
 #define RDS_MSG_RETRANSMITTED	5
 #define RDS_MSG_MAPPED		6
 #define RDS_MSG_PAGEVEC		7
+#define RDS_MSG_FLUSH		8
 
 struct rds_message {
 	atomic_t		m_refcount;
@@ -664,6 +669,7 @@ static inline void __rds_wake_sk_sleep(struct sock *sk)
 struct rds_message *rds_cong_update_alloc(struct rds_connection *conn);
 
 /* conn.c */
+extern u32 rds_gen_num;
 int rds_conn_init(void);
 void rds_conn_exit(void);
 struct rds_connection *rds_conn_create(struct net *net,
diff --git a/net/rds/recv.c b/net/rds/recv.c
index cbfabdf..9d0666e 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -120,6 +120,36 @@ static void rds_recv_rcvbuf_delta(struct rds_sock *rs, struct sock *sk,
 	/* do nothing if no change in cong state */
 }
 
+static void rds_conn_peer_gen_update(struct rds_connection *conn,
+				     u32 peer_gen_num)
+{
+	int i;
+	struct rds_message *rm, *tmp;
+	unsigned long flags;
+
+	WARN_ON(conn->c_trans->t_type != RDS_TRANS_TCP);
+	if (peer_gen_num != 0) {
+		if (conn->c_peer_gen_num != 0 &&
+		    peer_gen_num != conn->c_peer_gen_num) {
+			for (i = 0; i < RDS_MPATH_WORKERS; i++) {
+				struct rds_conn_path *cp;
+
+				cp = &conn->c_path[i];
+				spin_lock_irqsave(&cp->cp_lock, flags);
+				cp->cp_next_tx_seq = 1;
+				cp->cp_next_rx_seq = 0;
+				list_for_each_entry_safe(rm, tmp,
+							 &cp->cp_retrans,
+							 m_conn_item) {
+					set_bit(RDS_MSG_FLUSH, &rm->m_flags);
+				}
+				spin_unlock_irqrestore(&cp->cp_lock, flags);
+			}
+		}
+		conn->c_peer_gen_num = peer_gen_num;
+	}
+}
+
 /*
  * Process all extension headers that come with this message.
  */
@@ -163,7 +193,9 @@ static void rds_recv_hs_exthdrs(struct rds_header *hdr,
 	union {
 		struct rds_ext_header_version version;
 		u16 rds_npaths;
+		u32 rds_gen_num;
 	} buffer;
+	u32 new_peer_gen_num = 0;
 
 	while (1) {
 		len = sizeof(buffer);
@@ -176,6 +208,9 @@ static void rds_recv_hs_exthdrs(struct rds_header *hdr,
 			conn->c_npaths = min_t(int, RDS_MPATH_WORKERS,
 					       buffer.rds_npaths);
 			break;
+		case RDS_EXTHDR_GEN_NUM:
+			new_peer_gen_num = buffer.rds_gen_num;
+			break;
 		default:
 			pr_warn_ratelimited("ignoring unknown exthdr type "
 					     "0x%x\n", type);
@@ -183,6 +218,7 @@ static void rds_recv_hs_exthdrs(struct rds_header *hdr,
 	}
 	/* if RDS_EXTHDR_NPATHS was not found, default to a single-path */
 	conn->c_npaths = max_t(int, conn->c_npaths, 1);
+	rds_conn_peer_gen_update(conn, new_peer_gen_num);
 }
 
 /* rds_start_mprds() will synchronously start multiple paths when appropriate.
diff --git a/net/rds/send.c b/net/rds/send.c
index 896626b..77c8c6e 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -259,8 +259,9 @@ int rds_send_xmit(struct rds_conn_path *cp)
 			 * connection.
 			 * Therefore, we never retransmit messages with RDMA ops.
 			 */
-			if (rm->rdma.op_active &&
-			    test_bit(RDS_MSG_RETRANSMITTED, &rm->m_flags)) {
+			if (test_bit(RDS_MSG_FLUSH, &rm->m_flags) ||
+			    (rm->rdma.op_active &&
+			    test_bit(RDS_MSG_RETRANSMITTED, &rm->m_flags))) {
 				spin_lock_irqsave(&cp->cp_lock, flags);
 				if (test_and_clear_bit(RDS_MSG_ON_CONN, &rm->m_flags))
 					list_move(&rm->m_conn_item, &to_be_dropped);
@@ -1209,6 +1210,10 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 		rds_message_add_extension(&rm->m_inc.i_hdr,
 					  RDS_EXTHDR_NPATHS, &npaths,
 					  sizeof(npaths));
+		rds_message_add_extension(&rm->m_inc.i_hdr,
+					  RDS_EXTHDR_GEN_NUM,
+					  &cp->cp_conn->c_my_gen_num,
+					  sizeof(u32));
 	}
 	spin_unlock_irqrestore(&cp->cp_lock, flags);
 
-- 
1.7.1
