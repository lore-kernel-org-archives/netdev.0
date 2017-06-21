From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 1/2] rds: tcp: send handshake ping-probe from passive endpoint
Date: Wed, 21 Jun 2017 13:40:12 -0700
Message-ID: <e15d014a7229fb584f1411bbd8d303cdcc4377b0.1498074496.git.sowmini.varadhan@oracle.com>
References: <cover.1498074496.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
        santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42128 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751865AbdFUUmk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 16:42:40 -0400
In-Reply-To: <cover.1498074496.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1498074496.git.sowmini.varadhan@oracle.com>
References: <cover.1498074496.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RDS handshake ping probe added by commit 5916e2c1554f
("RDS: TCP: Enable multipath RDS for TCP") is sent from rds_sendmsg()
before the first data packet is sent to a peer. If the conversation
is not bidirectional  (i.e., one side is always passive and never
invokes rds_sendmsg()) and the passive side restarts its rds_tcp
module, a new HS ping probe needs to be sent, so that the number
of paths can be re-established.

This patch achieves that by sending a HS ping probe from
rds_tcp_accept_one() when c_npaths is 0 (i.e., we have not done
a handshake probe with this peer yet).

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Tested-by: Jenny Xu <jenny.x.xu@oracle.com>
---
 net/rds/rds.h        |    1 +
 net/rds/recv.c       |    6 +++---
 net/rds/send.c       |   14 ++++++--------
 net/rds/tcp_listen.c |    2 ++
 4 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/rds/rds.h b/net/rds/rds.h
index d6a04a0..aa696b3 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -827,6 +827,7 @@ void rds_send_drop_acked(struct rds_connection *conn, u64 ack,
 			 is_acked_func is_acked);
 void rds_send_path_drop_acked(struct rds_conn_path *cp, u64 ack,
 			      is_acked_func is_acked);
+void rds_send_ping(struct rds_connection *conn, int cp_index);
 int rds_send_pong(struct rds_conn_path *cp, __be16 dport);
 
 /* rdma.c */
diff --git a/net/rds/recv.c b/net/rds/recv.c
index 49493db..373a6aa 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -227,6 +227,7 @@ static void rds_recv_hs_exthdrs(struct rds_header *hdr,
 	}
 	/* if RDS_EXTHDR_NPATHS was not found, default to a single-path */
 	conn->c_npaths = max_t(int, conn->c_npaths, 1);
+	conn->c_ping_triggered = 0;
 	rds_conn_peer_gen_update(conn, new_peer_gen_num);
 }
 
@@ -244,8 +245,7 @@ static void rds_recv_hs_exthdrs(struct rds_header *hdr,
  *    called after reception of the probe-pong on all mprds_paths.
  *    Otherwise (sender of probe-ping is not the smaller ip addr): just call
  *    rds_conn_path_connect_if_down on the hashed path. (see rule 4)
- * 4. when cp_index > 0, rds_connect_worker must only trigger
- *    a connection if laddr < faddr.
+ * 4. rds_connect_worker must only trigger a connection if laddr < faddr.
  * 5. sender may end up queuing the packet on the cp. will get sent out later.
  *    when connection is completed.
  */
@@ -256,7 +256,7 @@ static void rds_start_mprds(struct rds_connection *conn)
 
 	if (conn->c_npaths > 1 &&
 	    IS_CANONICAL(conn->c_laddr, conn->c_faddr)) {
-		for (i = 1; i < conn->c_npaths; i++) {
+		for (i = 0; i < conn->c_npaths; i++) {
 			cp = &conn->c_path[i];
 			rds_conn_path_connect_if_down(cp);
 		}
diff --git a/net/rds/send.c b/net/rds/send.c
index 3652a50..e81aa17 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -971,8 +971,6 @@ static int rds_cmsg_send(struct rds_sock *rs, struct rds_message *rm,
 	return ret;
 }
 
-static void rds_send_ping(struct rds_connection *conn);
-
 static int rds_send_mprds_hash(struct rds_sock *rs, struct rds_connection *conn)
 {
 	int hash;
@@ -982,7 +980,7 @@ static int rds_send_mprds_hash(struct rds_sock *rs, struct rds_connection *conn)
 	else
 		hash = RDS_MPATH_HASH(rs, conn->c_npaths);
 	if (conn->c_npaths == 0 && hash != 0) {
-		rds_send_ping(conn);
+		rds_send_ping(conn, 0);
 
 		if (conn->c_npaths == 0) {
 			wait_event_interruptible(conn->c_hs_waitq,
@@ -1282,11 +1280,11 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 	return rds_send_probe(cp, 0, dport, 0);
 }
 
-static void
-rds_send_ping(struct rds_connection *conn)
+void
+rds_send_ping(struct rds_connection *conn, int cp_index)
 {
 	unsigned long flags;
-	struct rds_conn_path *cp = &conn->c_path[0];
+	struct rds_conn_path *cp = &conn->c_path[cp_index];
 
 	spin_lock_irqsave(&cp->cp_lock, flags);
 	if (conn->c_ping_triggered) {
@@ -1295,6 +1293,6 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 	}
 	conn->c_ping_triggered = 1;
 	spin_unlock_irqrestore(&cp->cp_lock, flags);
-	rds_send_probe(&conn->c_path[0], cpu_to_be16(RDS_FLAG_PROBE_PORT),
-		       0, 0);
+	rds_send_probe(cp, cpu_to_be16(RDS_FLAG_PROBE_PORT), 0, 0);
 }
+EXPORT_SYMBOL_GPL(rds_send_ping);
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index df291ac..6089e9a 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -192,6 +192,8 @@ int rds_tcp_accept_one(struct socket *sock)
 	}
 	new_sock = NULL;
 	ret = 0;
+	if (conn->c_npaths == 0)
+		rds_send_ping(cp->cp_conn, cp->cp_index);
 	goto out;
 rst_nsk:
 	/* reset the newly returned accept sock and bail.
-- 
1.7.1
