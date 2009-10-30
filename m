From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 5/5] RDS/IB+IW: Move recv processing to a tasklet
Date: Fri, 30 Oct 2009 11:51:57 -0700
Message-ID: <1256928717-17757-5-git-send-email-andy.grover@oracle.com>
References: <1256928717-17757-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:54628 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757140AbZJ3SxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 14:53:17 -0400
Received: from rgminet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9UIrtpH017370
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 18:53:56 GMT
In-Reply-To: <1256928717-17757-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move receive processing from event handler to a tasklet.
This should help prevent hangcheck timer from going off
when RDS is under heavy load.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib.h      |    2 ++
 net/rds/ib_cm.c   |    2 ++
 net/rds/ib_recv.c |   28 ++++++++++++++++++++++------
 net/rds/iw.h      |    2 ++
 net/rds/iw_cm.c   |    2 ++
 net/rds/iw_recv.c |   28 ++++++++++++++++++++++------
 6 files changed, 52 insertions(+), 12 deletions(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index 1378b85..64df4e7 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -98,6 +98,7 @@ struct rds_ib_connection {
 	struct rds_ib_send_work *i_sends;
 
 	/* rx */
+	struct tasklet_struct	i_recv_tasklet;
 	struct mutex		i_recv_mutex;
 	struct rds_ib_work_ring	i_recv_ring;
 	struct rds_ib_incoming	*i_ibinc;
@@ -303,6 +304,7 @@ void rds_ib_inc_free(struct rds_incoming *inc);
 int rds_ib_inc_copy_to_user(struct rds_incoming *inc, struct iovec *iov,
 			     size_t size);
 void rds_ib_recv_cq_comp_handler(struct ib_cq *cq, void *context);
+void rds_ib_recv_tasklet_fn(unsigned long data);
 void rds_ib_recv_init_ring(struct rds_ib_connection *ic);
 void rds_ib_recv_clear_ring(struct rds_ib_connection *ic);
 void rds_ib_recv_init_ack(struct rds_ib_connection *ic);
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index c2d372f..9d32069 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -694,6 +694,8 @@ int rds_ib_conn_alloc(struct rds_connection *conn, gfp_t gfp)
 		return -ENOMEM;
 
 	INIT_LIST_HEAD(&ic->ib_node);
+	tasklet_init(&ic->i_recv_tasklet, rds_ib_recv_tasklet_fn,
+		     (unsigned long) ic);
 	mutex_init(&ic->i_recv_mutex);
 #ifndef KERNEL_HAS_ATOMIC64
 	spin_lock_init(&ic->i_ack_lock);
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 2f009d3..fe5ab8c 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -825,17 +825,22 @@ void rds_ib_recv_cq_comp_handler(struct ib_cq *cq, void *context)
 {
 	struct rds_connection *conn = context;
 	struct rds_ib_connection *ic = conn->c_transport_data;
-	struct ib_wc wc;
-	struct rds_ib_ack_state state = { 0, };
-	struct rds_ib_recv_work *recv;
 
 	rdsdebug("conn %p cq %p\n", conn, cq);
 
 	rds_ib_stats_inc(s_ib_rx_cq_call);
 
-	ib_req_notify_cq(cq, IB_CQ_SOLICITED);
+	tasklet_schedule(&ic->i_recv_tasklet);
+}
 
-	while (ib_poll_cq(cq, 1, &wc) > 0) {
+static inline void rds_poll_cq(struct rds_ib_connection *ic,
+			       struct rds_ib_ack_state *state)
+{
+	struct rds_connection *conn = ic->conn;
+	struct ib_wc wc;
+	struct rds_ib_recv_work *recv;
+
+	while (ib_poll_cq(ic->i_recv_cq, 1, &wc) > 0) {
 		rdsdebug("wc wr_id 0x%llx status %u byte_len %u imm_data %u\n",
 			 (unsigned long long)wc.wr_id, wc.status, wc.byte_len,
 			 be32_to_cpu(wc.ex.imm_data));
@@ -853,7 +858,7 @@ void rds_ib_recv_cq_comp_handler(struct ib_cq *cq, void *context)
 		if (rds_conn_up(conn) || rds_conn_connecting(conn)) {
 			/* We expect errors as the qp is drained during shutdown */
 			if (wc.status == IB_WC_SUCCESS) {
-				rds_ib_process_recv(conn, recv, wc.byte_len, &state);
+				rds_ib_process_recv(conn, recv, wc.byte_len, state);
 			} else {
 				rds_ib_conn_error(conn, "recv completion on "
 				       "%pI4 had status %u, disconnecting and "
@@ -864,6 +869,17 @@ void rds_ib_recv_cq_comp_handler(struct ib_cq *cq, void *context)
 
 		rds_ib_ring_free(&ic->i_recv_ring, 1);
 	}
+}
+
+void rds_ib_recv_tasklet_fn(unsigned long data)
+{
+	struct rds_ib_connection *ic = (struct rds_ib_connection *) data;
+	struct rds_connection *conn = ic->conn;
+	struct rds_ib_ack_state state = { 0, };
+
+	rds_poll_cq(ic, &state);
+	ib_req_notify_cq(ic->i_recv_cq, IB_CQ_SOLICITED);
+	rds_poll_cq(ic, &state);
 
 	if (state.ack_next_valid)
 		rds_ib_set_ack(ic, state.ack_next, state.ack_required);
diff --git a/net/rds/iw.h b/net/rds/iw.h
index dd72b62..eef2f0c 100644
--- a/net/rds/iw.h
+++ b/net/rds/iw.h
@@ -119,6 +119,7 @@ struct rds_iw_connection {
 	struct rds_iw_send_work *i_sends;
 
 	/* rx */
+	struct tasklet_struct	i_recv_tasklet;
 	struct mutex		i_recv_mutex;
 	struct rds_iw_work_ring	i_recv_ring;
 	struct rds_iw_incoming	*i_iwinc;
@@ -330,6 +331,7 @@ void rds_iw_inc_free(struct rds_incoming *inc);
 int rds_iw_inc_copy_to_user(struct rds_incoming *inc, struct iovec *iov,
 			     size_t size);
 void rds_iw_recv_cq_comp_handler(struct ib_cq *cq, void *context);
+void rds_iw_recv_tasklet_fn(unsigned long data);
 void rds_iw_recv_init_ring(struct rds_iw_connection *ic);
 void rds_iw_recv_clear_ring(struct rds_iw_connection *ic);
 void rds_iw_recv_init_ack(struct rds_iw_connection *ic);
diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
index a416b0d..394cf6b 100644
--- a/net/rds/iw_cm.c
+++ b/net/rds/iw_cm.c
@@ -696,6 +696,8 @@ int rds_iw_conn_alloc(struct rds_connection *conn, gfp_t gfp)
 		return -ENOMEM;
 
 	INIT_LIST_HEAD(&ic->iw_node);
+	tasklet_init(&ic->i_recv_tasklet, rds_iw_recv_tasklet_fn,
+		     (unsigned long) ic);
 	mutex_init(&ic->i_recv_mutex);
 #ifndef KERNEL_HAS_ATOMIC64
 	spin_lock_init(&ic->i_ack_lock);
diff --git a/net/rds/iw_recv.c b/net/rds/iw_recv.c
index 9f98150..24fc53f 100644
--- a/net/rds/iw_recv.c
+++ b/net/rds/iw_recv.c
@@ -784,17 +784,22 @@ void rds_iw_recv_cq_comp_handler(struct ib_cq *cq, void *context)
 {
 	struct rds_connection *conn = context;
 	struct rds_iw_connection *ic = conn->c_transport_data;
-	struct ib_wc wc;
-	struct rds_iw_ack_state state = { 0, };
-	struct rds_iw_recv_work *recv;
 
 	rdsdebug("conn %p cq %p\n", conn, cq);
 
 	rds_iw_stats_inc(s_iw_rx_cq_call);
 
-	ib_req_notify_cq(cq, IB_CQ_SOLICITED);
+	tasklet_schedule(&ic->i_recv_tasklet);
+}
 
-	while (ib_poll_cq(cq, 1, &wc) > 0) {
+static inline void rds_poll_cq(struct rds_iw_connection *ic,
+			       struct rds_iw_ack_state *state)
+{
+	struct rds_connection *conn = ic->conn;
+	struct ib_wc wc;
+	struct rds_iw_recv_work *recv;
+
+	while (ib_poll_cq(ic->i_recv_cq, 1, &wc) > 0) {
 		rdsdebug("wc wr_id 0x%llx status %u byte_len %u imm_data %u\n",
 			 (unsigned long long)wc.wr_id, wc.status, wc.byte_len,
 			 be32_to_cpu(wc.ex.imm_data));
@@ -812,7 +817,7 @@ void rds_iw_recv_cq_comp_handler(struct ib_cq *cq, void *context)
 		if (rds_conn_up(conn) || rds_conn_connecting(conn)) {
 			/* We expect errors as the qp is drained during shutdown */
 			if (wc.status == IB_WC_SUCCESS) {
-				rds_iw_process_recv(conn, recv, wc.byte_len, &state);
+				rds_iw_process_recv(conn, recv, wc.byte_len, state);
 			} else {
 				rds_iw_conn_error(conn, "recv completion on "
 				       "%pI4 had status %u, disconnecting and "
@@ -823,6 +828,17 @@ void rds_iw_recv_cq_comp_handler(struct ib_cq *cq, void *context)
 
 		rds_iw_ring_free(&ic->i_recv_ring, 1);
 	}
+}
+
+void rds_iw_recv_tasklet_fn(unsigned long data)
+{
+	struct rds_iw_connection *ic = (struct rds_iw_connection *) data;
+	struct rds_connection *conn = ic->conn;
+	struct rds_iw_ack_state state = { 0, };
+
+	rds_poll_cq(ic, &state);
+	ib_req_notify_cq(ic->i_recv_cq, IB_CQ_SOLICITED);
+	rds_poll_cq(ic, &state);
 
 	if (state.ack_next_valid)
 		rds_iw_set_ack(ic, state.ack_next, state.ack_required);
-- 
1.6.3.3

