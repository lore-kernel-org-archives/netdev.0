From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH v3 07/14] RDS: IB: ack more receive completions to improve performance
Date: Mon,  5 Oct 2015 10:56:30 -0700
Message-ID: <1444067797-14101-8-git-send-email-santosh.shilimkar@oracle.com>
References: <1444067797-14101-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444067797-14101-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For better performance, we split the receive completion IRQ handler. That
lets us acknowledge several WCE events in one call. We also limit the WC
to max 32 to avoid latency. Acknowledging several completions in one call
instead of several calls each time will provide better performance since
less mutual exclusion locks are being performed.

In next patch, send completion is also split which re-uses the poll_cq()
and hence the code is moved to ib_cm.c

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib.h       |  28 +++++++++--
 net/rds/ib_cm.c    |  70 ++++++++++++++++++++++++++-
 net/rds/ib_recv.c  | 136 +++++++++++++++--------------------------------------
 net/rds/ib_stats.c |   3 +-
 4 files changed, 132 insertions(+), 105 deletions(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index f1fd5ff..727759b 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -24,6 +24,8 @@
 
 #define RDS_IB_RECYCLE_BATCH_COUNT	32
 
+#define RDS_IB_WC_MAX			32
+
 extern struct rw_semaphore rds_ib_devices_lock;
 extern struct list_head rds_ib_devices;
 
@@ -89,6 +91,20 @@ struct rds_ib_work_ring {
 	atomic_t	w_free_ctr;
 };
 
+/* Rings are posted with all the allocations they'll need to queue the
+ * incoming message to the receiving socket so this can't fail.
+ * All fragments start with a header, so we can make sure we're not receiving
+ * garbage, and we can tell a small 8 byte fragment from an ACK frame.
+ */
+struct rds_ib_ack_state {
+	u64		ack_next;
+	u64		ack_recv;
+	unsigned int	ack_required:1;
+	unsigned int	ack_next_valid:1;
+	unsigned int	ack_recv_valid:1;
+};
+
+
 struct rds_ib_device;
 
 struct rds_ib_connection {
@@ -102,6 +118,10 @@ struct rds_ib_connection {
 	struct ib_pd		*i_pd;
 	struct ib_cq		*i_send_cq;
 	struct ib_cq		*i_recv_cq;
+	struct ib_wc		i_recv_wc[RDS_IB_WC_MAX];
+
+	/* interrupt handling */
+	struct tasklet_struct	i_recv_tasklet;
 
 	/* tx */
 	struct rds_ib_work_ring	i_send_ring;
@@ -112,7 +132,6 @@ struct rds_ib_connection {
 	atomic_t		i_signaled_sends;
 
 	/* rx */
-	struct tasklet_struct	i_recv_tasklet;
 	struct mutex		i_recv_mutex;
 	struct rds_ib_work_ring	i_recv_ring;
 	struct rds_ib_incoming	*i_ibinc;
@@ -199,13 +218,14 @@ struct rds_ib_statistics {
 	uint64_t	s_ib_connect_raced;
 	uint64_t	s_ib_listen_closed_stale;
 	uint64_t	s_ib_tx_cq_call;
+	uint64_t	s_ib_evt_handler_call;
+	uint64_t	s_ib_tasklet_call;
 	uint64_t	s_ib_tx_cq_event;
 	uint64_t	s_ib_tx_ring_full;
 	uint64_t	s_ib_tx_throttle;
 	uint64_t	s_ib_tx_sg_mapping_failure;
 	uint64_t	s_ib_tx_stalled;
 	uint64_t	s_ib_tx_credit_updates;
-	uint64_t	s_ib_rx_cq_call;
 	uint64_t	s_ib_rx_cq_event;
 	uint64_t	s_ib_rx_ring_empty;
 	uint64_t	s_ib_rx_refill_from_cq;
@@ -324,7 +344,8 @@ void rds_ib_recv_free_caches(struct rds_ib_connection *ic);
 void rds_ib_recv_refill(struct rds_connection *conn, int prefill, gfp_t gfp);
 void rds_ib_inc_free(struct rds_incoming *inc);
 int rds_ib_inc_copy_to_user(struct rds_incoming *inc, struct iov_iter *to);
-void rds_ib_recv_cq_comp_handler(struct ib_cq *cq, void *context);
+void rds_ib_recv_cqe_handler(struct rds_ib_connection *ic, struct ib_wc *wc,
+			     struct rds_ib_ack_state *state);
 void rds_ib_recv_tasklet_fn(unsigned long data);
 void rds_ib_recv_init_ring(struct rds_ib_connection *ic);
 void rds_ib_recv_clear_ring(struct rds_ib_connection *ic);
@@ -332,6 +353,7 @@ void rds_ib_recv_init_ack(struct rds_ib_connection *ic);
 void rds_ib_attempt_ack(struct rds_ib_connection *ic);
 void rds_ib_ack_send_complete(struct rds_ib_connection *ic);
 u64 rds_ib_piggyb_ack(struct rds_ib_connection *ic);
+void rds_ib_set_ack(struct rds_ib_connection *ic, u64 seq, int ack_required);
 
 /* ib_ring.c */
 void rds_ib_ring_init(struct rds_ib_work_ring *ring, u32 nr);
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 9043f5c..28e0979 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -216,6 +216,72 @@ static void rds_ib_cq_event_handler(struct ib_event *event, void *data)
 		 event->event, ib_event_msg(event->event), data);
 }
 
+/* Plucking the oldest entry from the ring can be done concurrently with
+ * the thread refilling the ring.  Each ring operation is protected by
+ * spinlocks and the transient state of refilling doesn't change the
+ * recording of which entry is oldest.
+ *
+ * This relies on IB only calling one cq comp_handler for each cq so that
+ * there will only be one caller of rds_recv_incoming() per RDS connection.
+ */
+static void rds_ib_cq_comp_handler_recv(struct ib_cq *cq, void *context)
+{
+	struct rds_connection *conn = context;
+	struct rds_ib_connection *ic = conn->c_transport_data;
+
+	rdsdebug("conn %p cq %p\n", conn, cq);
+
+	rds_ib_stats_inc(s_ib_evt_handler_call);
+
+	tasklet_schedule(&ic->i_recv_tasklet);
+}
+
+static void poll_cq(struct rds_ib_connection *ic, struct ib_cq *cq,
+		    struct ib_wc *wcs,
+		    struct rds_ib_ack_state *ack_state)
+{
+	int nr;
+	int i;
+	struct ib_wc *wc;
+
+	while ((nr = ib_poll_cq(cq, RDS_IB_WC_MAX, wcs)) > 0) {
+		for (i = 0; i < nr; i++) {
+			wc = wcs + i;
+			rdsdebug("wc wr_id 0x%llx status %u byte_len %u imm_data %u\n",
+				 (unsigned long long)wc->wr_id, wc->status,
+				 wc->byte_len, be32_to_cpu(wc->ex.imm_data));
+			rds_ib_recv_cqe_handler(ic, wc, ack_state);
+		}
+	}
+}
+
+static void rds_ib_tasklet_fn_recv(unsigned long data)
+{
+	struct rds_ib_connection *ic = (struct rds_ib_connection *)data;
+	struct rds_connection *conn = ic->conn;
+	struct rds_ib_device *rds_ibdev = ic->rds_ibdev;
+	struct rds_ib_ack_state state;
+
+	BUG_ON(!rds_ibdev);
+
+	rds_ib_stats_inc(s_ib_tasklet_call);
+
+	memset(&state, 0, sizeof(state));
+	poll_cq(ic, ic->i_recv_cq, ic->i_recv_wc, &state);
+	ib_req_notify_cq(ic->i_recv_cq, IB_CQ_SOLICITED);
+	poll_cq(ic, ic->i_recv_cq, ic->i_recv_wc, &state);
+
+	if (state.ack_next_valid)
+		rds_ib_set_ack(ic, state.ack_next, state.ack_required);
+	if (state.ack_recv_valid && state.ack_recv > ic->i_ack_recv) {
+		rds_send_drop_acked(conn, state.ack_recv, NULL);
+		ic->i_ack_recv = state.ack_recv;
+	}
+
+	if (rds_conn_up(conn))
+		rds_ib_attempt_ack(ic);
+}
+
 static void rds_ib_qp_event_handler(struct ib_event *event, void *data)
 {
 	struct rds_connection *conn = data;
@@ -282,7 +348,7 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	}
 
 	cq_attr.cqe = ic->i_recv_ring.w_nr;
-	ic->i_recv_cq = ib_create_cq(dev, rds_ib_recv_cq_comp_handler,
+	ic->i_recv_cq = ib_create_cq(dev, rds_ib_cq_comp_handler_recv,
 				     rds_ib_cq_event_handler, conn,
 				     &cq_attr);
 	if (IS_ERR(ic->i_recv_cq)) {
@@ -743,7 +809,7 @@ int rds_ib_conn_alloc(struct rds_connection *conn, gfp_t gfp)
 	}
 
 	INIT_LIST_HEAD(&ic->ib_node);
-	tasklet_init(&ic->i_recv_tasklet, rds_ib_recv_tasklet_fn,
+	tasklet_init(&ic->i_recv_tasklet, rds_ib_tasklet_fn_recv,
 		     (unsigned long) ic);
 	mutex_init(&ic->i_recv_mutex);
 #ifndef KERNEL_HAS_ATOMIC64
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index f43831e..96744b7 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -596,8 +596,7 @@ void rds_ib_recv_init_ack(struct rds_ib_connection *ic)
  * wr_id and avoids working with the ring in that case.
  */
 #ifndef KERNEL_HAS_ATOMIC64
-static void rds_ib_set_ack(struct rds_ib_connection *ic, u64 seq,
-				int ack_required)
+void rds_ib_set_ack(struct rds_ib_connection *ic, u64 seq, int ack_required)
 {
 	unsigned long flags;
 
@@ -622,8 +621,7 @@ static u64 rds_ib_get_ack(struct rds_ib_connection *ic)
 	return seq;
 }
 #else
-static void rds_ib_set_ack(struct rds_ib_connection *ic, u64 seq,
-				int ack_required)
+void rds_ib_set_ack(struct rds_ib_connection *ic, u64 seq, int ack_required)
 {
 	atomic64_set(&ic->i_ack_next, seq);
 	if (ack_required) {
@@ -830,20 +828,6 @@ static void rds_ib_cong_recv(struct rds_connection *conn,
 	rds_cong_map_updated(map, uncongested);
 }
 
-/*
- * Rings are posted with all the allocations they'll need to queue the
- * incoming message to the receiving socket so this can't fail.
- * All fragments start with a header, so we can make sure we're not receiving
- * garbage, and we can tell a small 8 byte fragment from an ACK frame.
- */
-struct rds_ib_ack_state {
-	u64		ack_next;
-	u64		ack_recv;
-	unsigned int	ack_required:1;
-	unsigned int	ack_next_valid:1;
-	unsigned int	ack_recv_valid:1;
-};
-
 static void rds_ib_process_recv(struct rds_connection *conn,
 				struct rds_ib_recv_work *recv, u32 data_len,
 				struct rds_ib_ack_state *state)
@@ -969,96 +953,50 @@ static void rds_ib_process_recv(struct rds_connection *conn,
 	}
 }
 
-/*
- * Plucking the oldest entry from the ring can be done concurrently with
- * the thread refilling the ring.  Each ring operation is protected by
- * spinlocks and the transient state of refilling doesn't change the
- * recording of which entry is oldest.
- *
- * This relies on IB only calling one cq comp_handler for each cq so that
- * there will only be one caller of rds_recv_incoming() per RDS connection.
- */
-void rds_ib_recv_cq_comp_handler(struct ib_cq *cq, void *context)
-{
-	struct rds_connection *conn = context;
-	struct rds_ib_connection *ic = conn->c_transport_data;
-
-	rdsdebug("conn %p cq %p\n", conn, cq);
-
-	rds_ib_stats_inc(s_ib_rx_cq_call);
-
-	tasklet_schedule(&ic->i_recv_tasklet);
-}
-
-static inline void rds_poll_cq(struct rds_ib_connection *ic,
-			       struct rds_ib_ack_state *state)
+void rds_ib_recv_cqe_handler(struct rds_ib_connection *ic,
+			     struct ib_wc *wc,
+			     struct rds_ib_ack_state *state)
 {
 	struct rds_connection *conn = ic->conn;
-	struct ib_wc wc;
 	struct rds_ib_recv_work *recv;
 
-	while (ib_poll_cq(ic->i_recv_cq, 1, &wc) > 0) {
-		rdsdebug("wc wr_id 0x%llx status %u (%s) byte_len %u imm_data %u\n",
-			 (unsigned long long)wc.wr_id, wc.status,
-			 ib_wc_status_msg(wc.status), wc.byte_len,
-			 be32_to_cpu(wc.ex.imm_data));
-		rds_ib_stats_inc(s_ib_rx_cq_event);
+	rdsdebug("wc wr_id 0x%llx status %u (%s) byte_len %u imm_data %u\n",
+		 (unsigned long long)wc->wr_id, wc->status,
+		 ib_wc_status_msg(wc->status), wc->byte_len,
+		 be32_to_cpu(wc->ex.imm_data));
 
-		recv = &ic->i_recvs[rds_ib_ring_oldest(&ic->i_recv_ring)];
-
-		ib_dma_unmap_sg(ic->i_cm_id->device, &recv->r_frag->f_sg, 1, DMA_FROM_DEVICE);
-
-		/*
-		 * Also process recvs in connecting state because it is possible
-		 * to get a recv completion _before_ the rdmacm ESTABLISHED
-		 * event is processed.
-		 */
-		if (wc.status == IB_WC_SUCCESS) {
-			rds_ib_process_recv(conn, recv, wc.byte_len, state);
-		} else {
-			/* We expect errors as the qp is drained during shutdown */
-			if (rds_conn_up(conn) || rds_conn_connecting(conn))
-				rds_ib_conn_error(conn, "recv completion on %pI4 had "
-						  "status %u (%s), disconnecting and "
-						  "reconnecting\n", &conn->c_faddr,
-						  wc.status,
-						  ib_wc_status_msg(wc.status));
-		}
+	rds_ib_stats_inc(s_ib_rx_cq_event);
+	recv = &ic->i_recvs[rds_ib_ring_oldest(&ic->i_recv_ring)];
+	ib_dma_unmap_sg(ic->i_cm_id->device, &recv->r_frag->f_sg, 1,
+			DMA_FROM_DEVICE);
 
-		/*
-		 * rds_ib_process_recv() doesn't always consume the frag, and
-		 * we might not have called it at all if the wc didn't indicate
-		 * success. We already unmapped the frag's pages, though, and
-		 * the following rds_ib_ring_free() call tells the refill path
-		 * that it will not find an allocated frag here. Make sure we
-		 * keep that promise by freeing a frag that's still on the ring.
-		 */
-		if (recv->r_frag) {
-			rds_ib_frag_free(ic, recv->r_frag);
-			recv->r_frag = NULL;
-		}
-		rds_ib_ring_free(&ic->i_recv_ring, 1);
+	/* Also process recvs in connecting state because it is possible
+	 * to get a recv completion _before_ the rdmacm ESTABLISHED
+	 * event is processed.
+	 */
+	if (wc->status == IB_WC_SUCCESS) {
+		rds_ib_process_recv(conn, recv, wc->byte_len, state);
+	} else {
+		/* We expect errors as the qp is drained during shutdown */
+		if (rds_conn_up(conn) || rds_conn_connecting(conn))
+			rds_ib_conn_error(conn, "recv completion on %pI4 had status %u (%s), disconnecting and reconnecting\n",
+					  &conn->c_faddr,
+					  wc->status,
+					  ib_wc_status_msg(wc->status));
 	}
-}
 
-void rds_ib_recv_tasklet_fn(unsigned long data)
-{
-	struct rds_ib_connection *ic = (struct rds_ib_connection *) data;
-	struct rds_connection *conn = ic->conn;
-	struct rds_ib_ack_state state = { 0, };
-
-	rds_poll_cq(ic, &state);
-	ib_req_notify_cq(ic->i_recv_cq, IB_CQ_SOLICITED);
-	rds_poll_cq(ic, &state);
-
-	if (state.ack_next_valid)
-		rds_ib_set_ack(ic, state.ack_next, state.ack_required);
-	if (state.ack_recv_valid && state.ack_recv > ic->i_ack_recv) {
-		rds_send_drop_acked(conn, state.ack_recv, NULL);
-		ic->i_ack_recv = state.ack_recv;
+	/* rds_ib_process_recv() doesn't always consume the frag, and
+	 * we might not have called it at all if the wc didn't indicate
+	 * success. We already unmapped the frag's pages, though, and
+	 * the following rds_ib_ring_free() call tells the refill path
+	 * that it will not find an allocated frag here. Make sure we
+	 * keep that promise by freeing a frag that's still on the ring.
+	 */
+	if (recv->r_frag) {
+		rds_ib_frag_free(ic, recv->r_frag);
+		recv->r_frag = NULL;
 	}
-	if (rds_conn_up(conn))
-		rds_ib_attempt_ack(ic);
+	rds_ib_ring_free(&ic->i_recv_ring, 1);
 
 	/* If we ever end up with a really empty receive ring, we're
 	 * in deep trouble, as the sender will definitely see RNR
diff --git a/net/rds/ib_stats.c b/net/rds/ib_stats.c
index 2d5965d..bdf6115 100644
--- a/net/rds/ib_stats.c
+++ b/net/rds/ib_stats.c
@@ -42,14 +42,15 @@ DEFINE_PER_CPU_SHARED_ALIGNED(struct rds_ib_statistics, rds_ib_stats);
 static const char *const rds_ib_stat_names[] = {
 	"ib_connect_raced",
 	"ib_listen_closed_stale",
+	"s_ib_evt_handler_call",
 	"ib_tx_cq_call",
+	"ib_tasklet_call",
 	"ib_tx_cq_event",
 	"ib_tx_ring_full",
 	"ib_tx_throttle",
 	"ib_tx_sg_mapping_failure",
 	"ib_tx_stalled",
 	"ib_tx_credit_updates",
-	"ib_rx_cq_call",
 	"ib_rx_cq_event",
 	"ib_rx_ring_empty",
 	"ib_rx_refill_from_cq",
-- 
1.9.1
