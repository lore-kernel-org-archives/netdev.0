From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 2/3] rds: tcp: various endian-ness fixes
Date: Thu, 15 Jun 2017 11:28:54 -0700
Message-ID: <e786b6c2945a50e643b56386d80b978ad5588032.1497547381.git.sowmini.varadhan@oracle.com>
References: <cover.1497547381.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
        santosh.shilimkar@oracle.com, imanti.mendez@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32790 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752629AbdFOSba (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 14:31:30 -0400
In-Reply-To: <cover.1497547381.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1497547381.git.sowmini.varadhan@oracle.com>
References: <cover.1497547381.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found when testing between sparc and x86 machines on different
subnets, so the address comparison patterns hit the corner cases and
brought out some bugs fixed by this patch.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Tested-by: Imanti Mendez <imanti.mendez@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/rds.h         |    2 ++
 net/rds/recv.c        |   12 +++++++-----
 net/rds/send.c        |   11 +++++++----
 net/rds/tcp_connect.c |    2 +-
 net/rds/tcp_listen.c  |    2 +-
 net/rds/threads.c     |    5 +++--
 6 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/net/rds/rds.h b/net/rds/rds.h
index aa183d6..d6a04a0 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -92,6 +92,8 @@ enum {
 #define	RDS_MPATH_HASH(rs, n) (jhash_1word((rs)->rs_bound_port, \
 			       (rs)->rs_hash_initval) & ((n) - 1))
 
+#define IS_CANONICAL(laddr, faddr) (htonl(laddr) < htonl(faddr))
+
 /* Per mpath connection state */
 struct rds_conn_path {
 	struct rds_connection	*cp_conn;
diff --git a/net/rds/recv.c b/net/rds/recv.c
index c70c32c..49493db 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -215,10 +215,10 @@ static void rds_recv_hs_exthdrs(struct rds_header *hdr,
 		switch (type) {
 		case RDS_EXTHDR_NPATHS:
 			conn->c_npaths = min_t(int, RDS_MPATH_WORKERS,
-					       buffer.rds_npaths);
+					       be16_to_cpu(buffer.rds_npaths));
 			break;
 		case RDS_EXTHDR_GEN_NUM:
-			new_peer_gen_num = buffer.rds_gen_num;
+			new_peer_gen_num = be32_to_cpu(buffer.rds_gen_num);
 			break;
 		default:
 			pr_warn_ratelimited("ignoring unknown exthdr type "
@@ -254,7 +254,8 @@ static void rds_start_mprds(struct rds_connection *conn)
 	int i;
 	struct rds_conn_path *cp;
 
-	if (conn->c_npaths > 1 && conn->c_laddr < conn->c_faddr) {
+	if (conn->c_npaths > 1 &&
+	    IS_CANONICAL(conn->c_laddr, conn->c_faddr)) {
 		for (i = 1; i < conn->c_npaths; i++) {
 			cp = &conn->c_path[i];
 			rds_conn_path_connect_if_down(cp);
@@ -339,14 +340,15 @@ void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
 		rds_stats_inc(s_recv_ping);
 		rds_send_pong(cp, inc->i_hdr.h_sport);
 		/* if this is a handshake ping, start multipath if necessary */
-		if (RDS_HS_PROBE(inc->i_hdr.h_sport, inc->i_hdr.h_dport)) {
+		if (RDS_HS_PROBE(be16_to_cpu(inc->i_hdr.h_sport),
+				 be16_to_cpu(inc->i_hdr.h_dport))) {
 			rds_recv_hs_exthdrs(&inc->i_hdr, cp->cp_conn);
 			rds_start_mprds(cp->cp_conn);
 		}
 		goto out;
 	}
 
-	if (inc->i_hdr.h_dport ==  RDS_FLAG_PROBE_PORT &&
+	if (be16_to_cpu(inc->i_hdr.h_dport) ==  RDS_FLAG_PROBE_PORT &&
 	    inc->i_hdr.h_sport == 0) {
 		rds_recv_hs_exthdrs(&inc->i_hdr, cp->cp_conn);
 		/* if this is a handshake pong, start multipath if necessary */
diff --git a/net/rds/send.c b/net/rds/send.c
index 5cc6403..3652a50 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -1246,15 +1246,17 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 	rm->m_inc.i_hdr.h_flags |= h_flags;
 	cp->cp_next_tx_seq++;
 
-	if (RDS_HS_PROBE(sport, dport) && cp->cp_conn->c_trans->t_mp_capable) {
-		u16 npaths = RDS_MPATH_WORKERS;
+	if (RDS_HS_PROBE(be16_to_cpu(sport), be16_to_cpu(dport)) &&
+	    cp->cp_conn->c_trans->t_mp_capable) {
+		u16 npaths = cpu_to_be16(RDS_MPATH_WORKERS);
+		u32 my_gen_num = cpu_to_be32(cp->cp_conn->c_my_gen_num);
 
 		rds_message_add_extension(&rm->m_inc.i_hdr,
 					  RDS_EXTHDR_NPATHS, &npaths,
 					  sizeof(npaths));
 		rds_message_add_extension(&rm->m_inc.i_hdr,
 					  RDS_EXTHDR_GEN_NUM,
-					  &cp->cp_conn->c_my_gen_num,
+					  &my_gen_num,
 					  sizeof(u32));
 	}
 	spin_unlock_irqrestore(&cp->cp_lock, flags);
@@ -1293,5 +1295,6 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 	}
 	conn->c_ping_triggered = 1;
 	spin_unlock_irqrestore(&cp->cp_lock, flags);
-	rds_send_probe(&conn->c_path[0], RDS_FLAG_PROBE_PORT, 0, 0);
+	rds_send_probe(&conn->c_path[0], cpu_to_be16(RDS_FLAG_PROBE_PORT),
+		       0, 0);
 }
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index 97db861..5a62a08 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -66,7 +66,7 @@ void rds_tcp_state_change(struct sock *sk)
 		 * RDS connection as RDS_CONN_UP until the reconnect,
 		 * to avoid RDS datagram loss.
 		 */
-		if (cp->cp_conn->c_laddr > cp->cp_conn->c_faddr &&
+		if (!IS_CANONICAL(cp->cp_conn->c_laddr, cp->cp_conn->c_faddr) &&
 		    rds_conn_path_transition(cp, RDS_CONN_CONNECTING,
 					     RDS_CONN_ERROR)) {
 			rds_conn_path_drop(cp);
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 238ff5c..f9c6312 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -83,7 +83,7 @@ int rds_tcp_keepalive(struct socket *sock)
 struct rds_tcp_connection *rds_tcp_accept_one_path(struct rds_connection *conn)
 {
 	int i;
-	bool peer_is_smaller = (conn->c_faddr < conn->c_laddr);
+	bool peer_is_smaller = IS_CANONICAL(conn->c_faddr, conn->c_laddr);
 	int npaths = max_t(int, 1, conn->c_npaths);
 
 	/* for mprds, all paths MUST be initiated by the peer
diff --git a/net/rds/threads.c b/net/rds/threads.c
index 3e447d0..2852bc1 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -127,7 +127,7 @@ void rds_queue_reconnect(struct rds_conn_path *cp)
 
 	/* let peer with smaller addr initiate reconnect, to avoid duels */
 	if (conn->c_trans->t_type == RDS_TRANS_TCP &&
-	    conn->c_laddr > conn->c_faddr)
+	    !IS_CANONICAL(conn->c_laddr, conn->c_faddr))
 		return;
 
 	set_bit(RDS_RECONNECT_PENDING, &cp->cp_flags);
@@ -156,7 +156,8 @@ void rds_connect_worker(struct work_struct *work)
 	struct rds_connection *conn = cp->cp_conn;
 	int ret;
 
-	if (cp->cp_index > 0 && cp->cp_conn->c_laddr > cp->cp_conn->c_faddr)
+	if (cp->cp_index > 0 &&
+	    !IS_CANONICAL(cp->cp_conn->c_laddr, cp->cp_conn->c_faddr))
 		return;
 	clear_bit(RDS_RECONNECT_PENDING, &cp->cp_flags);
 	ret = rds_conn_path_transition(cp, RDS_CONN_DOWN, RDS_CONN_CONNECTING);
-- 
1.7.1
