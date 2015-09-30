From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH v2 08/14] RDS: IB: split send completion handling and do batch ack
Date: Wed, 30 Sep 2015 13:24:27 -0400
Message-ID: <1443633873-13359-9-git-send-email-santosh.shilimkar@oracle.com>
References: <1443633873-13359-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-rdma@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443633873-13359-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Similar to what we did with receive CQ completion handling, we split
the transmit completion handler so that it lets us implement batched
work completion handling.

We re-use the cq_poll routine and makes use of RDS_IB_SEND_OP to
identify the send vs receive completion event handler invocation.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib.h       |   6 ++-
 net/rds/ib_cm.c    |  45 ++++++++++++++++++++--
 net/rds/ib_send.c  | 110 +++++++++++++++++++++++++----------------------------
 net/rds/ib_stats.c |   1 -
 net/rds/send.c     |   1 +
 5 files changed, 98 insertions(+), 65 deletions(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index 727759b..3a8cd31 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -25,6 +25,7 @@
 #define RDS_IB_RECYCLE_BATCH_COUNT	32
 
 #define RDS_IB_WC_MAX			32
+#define RDS_IB_SEND_OP			BIT_ULL(63)
 
 extern struct rw_semaphore rds_ib_devices_lock;
 extern struct list_head rds_ib_devices;
@@ -118,9 +119,11 @@ struct rds_ib_connection {
 	struct ib_pd		*i_pd;
 	struct ib_cq		*i_send_cq;
 	struct ib_cq		*i_recv_cq;
+	struct ib_wc		i_send_wc[RDS_IB_WC_MAX];
 	struct ib_wc		i_recv_wc[RDS_IB_WC_MAX];
 
 	/* interrupt handling */
+	struct tasklet_struct	i_send_tasklet;
 	struct tasklet_struct	i_recv_tasklet;
 
 	/* tx */
@@ -217,7 +220,6 @@ struct rds_ib_device {
 struct rds_ib_statistics {
 	uint64_t	s_ib_connect_raced;
 	uint64_t	s_ib_listen_closed_stale;
-	uint64_t	s_ib_tx_cq_call;
 	uint64_t	s_ib_evt_handler_call;
 	uint64_t	s_ib_tasklet_call;
 	uint64_t	s_ib_tx_cq_event;
@@ -371,7 +373,7 @@ extern wait_queue_head_t rds_ib_ring_empty_wait;
 void rds_ib_xmit_complete(struct rds_connection *conn);
 int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
 		unsigned int hdr_off, unsigned int sg, unsigned int off);
-void rds_ib_send_cq_comp_handler(struct ib_cq *cq, void *context);
+void rds_ib_send_cqe_handler(struct rds_ib_connection *ic, struct ib_wc *wc);
 void rds_ib_send_init_ring(struct rds_ib_connection *ic);
 void rds_ib_send_clear_ring(struct rds_ib_connection *ic);
 int rds_ib_xmit_rdma(struct rds_connection *conn, struct rm_rdma_op *op);
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 28e0979..8f51d0d 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -250,11 +250,34 @@ static void poll_cq(struct rds_ib_connection *ic, struct ib_cq *cq,
 			rdsdebug("wc wr_id 0x%llx status %u byte_len %u imm_data %u\n",
 				 (unsigned long long)wc->wr_id, wc->status,
 				 wc->byte_len, be32_to_cpu(wc->ex.imm_data));
-			rds_ib_recv_cqe_handler(ic, wc, ack_state);
+
+			if (wc->wr_id & RDS_IB_SEND_OP)
+				rds_ib_send_cqe_handler(ic, wc);
+			else
+				rds_ib_recv_cqe_handler(ic, wc, ack_state);
 		}
 	}
 }
 
+static void rds_ib_tasklet_fn_send(unsigned long data)
+{
+	struct rds_ib_connection *ic = (struct rds_ib_connection *)data;
+	struct rds_connection *conn = ic->conn;
+	struct rds_ib_ack_state state;
+
+	rds_ib_stats_inc(s_ib_tasklet_call);
+
+	memset(&state, 0, sizeof(state));
+	poll_cq(ic, ic->i_send_cq, ic->i_send_wc, &state);
+	ib_req_notify_cq(ic->i_send_cq, IB_CQ_NEXT_COMP);
+	poll_cq(ic, ic->i_send_cq, ic->i_send_wc, &state);
+
+	if (rds_conn_up(conn) &&
+	    (!test_bit(RDS_LL_SEND_FULL, &conn->c_flags) ||
+	    test_bit(0, &conn->c_map_queued)))
+		rds_send_xmit(ic->conn);
+}
+
 static void rds_ib_tasklet_fn_recv(unsigned long data)
 {
 	struct rds_ib_connection *ic = (struct rds_ib_connection *)data;
@@ -304,6 +327,18 @@ static void rds_ib_qp_event_handler(struct ib_event *event, void *data)
 	}
 }
 
+static void rds_ib_cq_comp_handler_send(struct ib_cq *cq, void *context)
+{
+	struct rds_connection *conn = context;
+	struct rds_ib_connection *ic = conn->c_transport_data;
+
+	rdsdebug("conn %p cq %p\n", conn, cq);
+
+	rds_ib_stats_inc(s_ib_evt_handler_call);
+
+	tasklet_schedule(&ic->i_send_tasklet);
+}
+
 /*
  * This needs to be very careful to not leave IS_ERR pointers around for
  * cleanup to trip over.
@@ -337,7 +372,8 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	ic->i_pd = rds_ibdev->pd;
 
 	cq_attr.cqe = ic->i_send_ring.w_nr + 1;
-	ic->i_send_cq = ib_create_cq(dev, rds_ib_send_cq_comp_handler,
+
+	ic->i_send_cq = ib_create_cq(dev, rds_ib_cq_comp_handler_send,
 				     rds_ib_cq_event_handler, conn,
 				     &cq_attr);
 	if (IS_ERR(ic->i_send_cq)) {
@@ -703,6 +739,7 @@ void rds_ib_conn_shutdown(struct rds_connection *conn)
 		wait_event(rds_ib_ring_empty_wait,
 			   rds_ib_ring_empty(&ic->i_recv_ring) &&
 			   (atomic_read(&ic->i_signaled_sends) == 0));
+		tasklet_kill(&ic->i_send_tasklet);
 		tasklet_kill(&ic->i_recv_tasklet);
 
 		/* first destroy the ib state that generates callbacks */
@@ -809,8 +846,10 @@ int rds_ib_conn_alloc(struct rds_connection *conn, gfp_t gfp)
 	}
 
 	INIT_LIST_HEAD(&ic->ib_node);
+	tasklet_init(&ic->i_send_tasklet, rds_ib_tasklet_fn_send,
+		     (unsigned long)ic);
 	tasklet_init(&ic->i_recv_tasklet, rds_ib_tasklet_fn_recv,
-		     (unsigned long) ic);
+		     (unsigned long)ic);
 	mutex_init(&ic->i_recv_mutex);
 #ifndef KERNEL_HAS_ATOMIC64
 	spin_lock_init(&ic->i_ack_lock);
diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index 4e88047..670882c 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -195,7 +195,7 @@ void rds_ib_send_init_ring(struct rds_ib_connection *ic)
 
 		send->s_op = NULL;
 
-		send->s_wr.wr_id = i;
+		send->s_wr.wr_id = i | RDS_IB_SEND_OP;
 		send->s_wr.sg_list = send->s_sge;
 		send->s_wr.ex.imm_data = 0;
 
@@ -237,81 +237,73 @@ static void rds_ib_sub_signaled(struct rds_ib_connection *ic, int nr)
  * unallocs the next free entry in the ring it doesn't alter which is
  * the next to be freed, which is what this is concerned with.
  */
-void rds_ib_send_cq_comp_handler(struct ib_cq *cq, void *context)
+void rds_ib_send_cqe_handler(struct rds_ib_connection *ic, struct ib_wc *wc)
 {
-	struct rds_connection *conn = context;
-	struct rds_ib_connection *ic = conn->c_transport_data;
 	struct rds_message *rm = NULL;
-	struct ib_wc wc;
+	struct rds_connection *conn = ic->conn;
 	struct rds_ib_send_work *send;
 	u32 completed;
 	u32 oldest;
 	u32 i = 0;
-	int ret;
 	int nr_sig = 0;
 
-	rdsdebug("cq %p conn %p\n", cq, conn);
-	rds_ib_stats_inc(s_ib_tx_cq_call);
-	ret = ib_req_notify_cq(cq, IB_CQ_NEXT_COMP);
-	if (ret)
-		rdsdebug("ib_req_notify_cq send failed: %d\n", ret);
-
-	while (ib_poll_cq(cq, 1, &wc) > 0) {
-		rdsdebug("wc wr_id 0x%llx status %u (%s) byte_len %u imm_data %u\n",
-			 (unsigned long long)wc.wr_id, wc.status,
-			 ib_wc_status_msg(wc.status), wc.byte_len,
-			 be32_to_cpu(wc.ex.imm_data));
-		rds_ib_stats_inc(s_ib_tx_cq_event);
-
-		if (wc.wr_id == RDS_IB_ACK_WR_ID) {
-			if (time_after(jiffies, ic->i_ack_queued + HZ/2))
-				rds_ib_stats_inc(s_ib_tx_stalled);
-			rds_ib_ack_send_complete(ic);
-			continue;
-		}
 
-		oldest = rds_ib_ring_oldest(&ic->i_send_ring);
+	rdsdebug("wc wr_id 0x%llx status %u (%s) byte_len %u imm_data %u\n",
+		 (unsigned long long)wc->wr_id, wc->status,
+		 ib_wc_status_msg(wc->status), wc->byte_len,
+		 be32_to_cpu(wc->ex.imm_data));
+	rds_ib_stats_inc(s_ib_tx_cq_event);
 
-		completed = rds_ib_ring_completed(&ic->i_send_ring, wc.wr_id, oldest);
+	if (wc->wr_id == RDS_IB_ACK_WR_ID) {
+		if (time_after(jiffies, ic->i_ack_queued + HZ / 2))
+			rds_ib_stats_inc(s_ib_tx_stalled);
+		rds_ib_ack_send_complete(ic);
+		return;
+	}
 
-		for (i = 0; i < completed; i++) {
-			send = &ic->i_sends[oldest];
-			if (send->s_wr.send_flags & IB_SEND_SIGNALED)
-				nr_sig++;
+	oldest = rds_ib_ring_oldest(&ic->i_send_ring);
 
-			rm = rds_ib_send_unmap_op(ic, send, wc.status);
+	completed = rds_ib_ring_completed(&ic->i_send_ring,
+					  (wc->wr_id & ~RDS_IB_SEND_OP),
+					  oldest);
 
-			if (time_after(jiffies, send->s_queued + HZ/2))
-				rds_ib_stats_inc(s_ib_tx_stalled);
+	for (i = 0; i < completed; i++) {
+		send = &ic->i_sends[oldest];
+		if (send->s_wr.send_flags & IB_SEND_SIGNALED)
+			nr_sig++;
 
-			if (send->s_op) {
-				if (send->s_op == rm->m_final_op) {
-					/* If anyone waited for this message to get flushed out, wake
-					 * them up now */
-					rds_message_unmapped(rm);
-				}
-				rds_message_put(rm);
-				send->s_op = NULL;
-			}
+		rm = rds_ib_send_unmap_op(ic, send, wc->status);
 
-			oldest = (oldest + 1) % ic->i_send_ring.w_nr;
-		}
+		if (time_after(jiffies, send->s_queued + HZ / 2))
+			rds_ib_stats_inc(s_ib_tx_stalled);
 
-		rds_ib_ring_free(&ic->i_send_ring, completed);
-		rds_ib_sub_signaled(ic, nr_sig);
-		nr_sig = 0;
-
-		if (test_and_clear_bit(RDS_LL_SEND_FULL, &conn->c_flags) ||
-		    test_bit(0, &conn->c_map_queued))
-			queue_delayed_work(rds_wq, &conn->c_send_w, 0);
-
-		/* We expect errors as the qp is drained during shutdown */
-		if (wc.status != IB_WC_SUCCESS && rds_conn_up(conn)) {
-			rds_ib_conn_error(conn, "send completion on %pI4 had status "
-					  "%u (%s), disconnecting and reconnecting\n",
-					  &conn->c_faddr, wc.status,
-					  ib_wc_status_msg(wc.status));
+		if (send->s_op) {
+			if (send->s_op == rm->m_final_op) {
+				/* If anyone waited for this message to get
+				 * flushed out, wake them up now
+				 */
+				rds_message_unmapped(rm);
+			}
+			rds_message_put(rm);
+			send->s_op = NULL;
 		}
+
+		oldest = (oldest + 1) % ic->i_send_ring.w_nr;
+	}
+
+	rds_ib_ring_free(&ic->i_send_ring, completed);
+	rds_ib_sub_signaled(ic, nr_sig);
+	nr_sig = 0;
+
+	if (test_and_clear_bit(RDS_LL_SEND_FULL, &conn->c_flags) ||
+	    test_bit(0, &conn->c_map_queued))
+		queue_delayed_work(rds_wq, &conn->c_send_w, 0);
+
+	/* We expect errors as the qp is drained during shutdown */
+	if (wc->status != IB_WC_SUCCESS && rds_conn_up(conn)) {
+		rds_ib_conn_error(conn, "send completion on %pI4 had status %u (%s), disconnecting and reconnecting\n",
+				  &conn->c_faddr, wc->status,
+				  ib_wc_status_msg(wc->status));
 	}
 }
 
diff --git a/net/rds/ib_stats.c b/net/rds/ib_stats.c
index bdf6115..8c8b84f 100644
--- a/net/rds/ib_stats.c
+++ b/net/rds/ib_stats.c
@@ -43,7 +43,6 @@ static const char *const rds_ib_stat_names[] = {
 	"ib_connect_raced",
 	"ib_listen_closed_stale",
 	"s_ib_evt_handler_call",
-	"ib_tx_cq_call",
 	"ib_tasklet_call",
 	"ib_tx_cq_event",
 	"ib_tx_ring_full",
diff --git a/net/rds/send.c b/net/rds/send.c
index 9d8b52d..de930b9 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -431,6 +431,7 @@ over_batch:
 out:
 	return ret;
 }
+EXPORT_SYMBOL_GPL(rds_send_xmit);
 
 static void rds_send_sndbuf_remove(struct rds_sock *rs, struct rds_message *rm)
 {
-- 
1.9.1
