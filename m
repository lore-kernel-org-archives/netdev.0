From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v2 04/13] RDS: IB: Remove the RDS_IB_SEND_OP dependency
Date: Sat, 27 Feb 2016 18:19:41 -0800
Message-ID: <1456625990-4739-5-git-send-email-santosh.shilimkar@oracle.com>
References: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This helps to combine asynchronous fastreg MR completion handler
with send completion handler.

No functional change.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib.h      |  1 -
 net/rds/ib_cm.c   | 42 +++++++++++++++++++++++++++---------------
 net/rds/ib_send.c |  6 ++----
 3 files changed, 29 insertions(+), 20 deletions(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index b3fdebb..09cd8e3 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -28,7 +28,6 @@
 #define RDS_IB_RECYCLE_BATCH_COUNT	32
 
 #define RDS_IB_WC_MAX			32
-#define RDS_IB_SEND_OP			BIT_ULL(63)
 
 extern struct rw_semaphore rds_ib_devices_lock;
 extern struct list_head rds_ib_devices;
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index da5a7fb..7f68abc 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -236,12 +236,10 @@ static void rds_ib_cq_comp_handler_recv(struct ib_cq *cq, void *context)
 	tasklet_schedule(&ic->i_recv_tasklet);
 }
 
-static void poll_cq(struct rds_ib_connection *ic, struct ib_cq *cq,
-		    struct ib_wc *wcs,
-		    struct rds_ib_ack_state *ack_state)
+static void poll_scq(struct rds_ib_connection *ic, struct ib_cq *cq,
+		     struct ib_wc *wcs)
 {
-	int nr;
-	int i;
+	int nr, i;
 	struct ib_wc *wc;
 
 	while ((nr = ib_poll_cq(cq, RDS_IB_WC_MAX, wcs)) > 0) {
@@ -251,10 +249,7 @@ static void poll_cq(struct rds_ib_connection *ic, struct ib_cq *cq,
 				 (unsigned long long)wc->wr_id, wc->status,
 				 wc->byte_len, be32_to_cpu(wc->ex.imm_data));
 
-			if (wc->wr_id & RDS_IB_SEND_OP)
-				rds_ib_send_cqe_handler(ic, wc);
-			else
-				rds_ib_recv_cqe_handler(ic, wc, ack_state);
+			rds_ib_send_cqe_handler(ic, wc);
 		}
 	}
 }
@@ -263,14 +258,12 @@ static void rds_ib_tasklet_fn_send(unsigned long data)
 {
 	struct rds_ib_connection *ic = (struct rds_ib_connection *)data;
 	struct rds_connection *conn = ic->conn;
-	struct rds_ib_ack_state state;
 
 	rds_ib_stats_inc(s_ib_tasklet_call);
 
-	memset(&state, 0, sizeof(state));
-	poll_cq(ic, ic->i_send_cq, ic->i_send_wc, &state);
+	poll_scq(ic, ic->i_send_cq, ic->i_send_wc);
 	ib_req_notify_cq(ic->i_send_cq, IB_CQ_NEXT_COMP);
-	poll_cq(ic, ic->i_send_cq, ic->i_send_wc, &state);
+	poll_scq(ic, ic->i_send_cq, ic->i_send_wc);
 
 	if (rds_conn_up(conn) &&
 	    (!test_bit(RDS_LL_SEND_FULL, &conn->c_flags) ||
@@ -278,6 +271,25 @@ static void rds_ib_tasklet_fn_send(unsigned long data)
 		rds_send_xmit(ic->conn);
 }
 
+static void poll_rcq(struct rds_ib_connection *ic, struct ib_cq *cq,
+		     struct ib_wc *wcs,
+		     struct rds_ib_ack_state *ack_state)
+{
+	int nr, i;
+	struct ib_wc *wc;
+
+	while ((nr = ib_poll_cq(cq, RDS_IB_WC_MAX, wcs)) > 0) {
+		for (i = 0; i < nr; i++) {
+			wc = wcs + i;
+			rdsdebug("wc wr_id 0x%llx status %u byte_len %u imm_data %u\n",
+				 (unsigned long long)wc->wr_id, wc->status,
+				 wc->byte_len, be32_to_cpu(wc->ex.imm_data));
+
+			rds_ib_recv_cqe_handler(ic, wc, ack_state);
+		}
+	}
+}
+
 static void rds_ib_tasklet_fn_recv(unsigned long data)
 {
 	struct rds_ib_connection *ic = (struct rds_ib_connection *)data;
@@ -291,9 +303,9 @@ static void rds_ib_tasklet_fn_recv(unsigned long data)
 	rds_ib_stats_inc(s_ib_tasklet_call);
 
 	memset(&state, 0, sizeof(state));
-	poll_cq(ic, ic->i_recv_cq, ic->i_recv_wc, &state);
+	poll_rcq(ic, ic->i_recv_cq, ic->i_recv_wc, &state);
 	ib_req_notify_cq(ic->i_recv_cq, IB_CQ_SOLICITED);
-	poll_cq(ic, ic->i_recv_cq, ic->i_recv_wc, &state);
+	poll_rcq(ic, ic->i_recv_cq, ic->i_recv_wc, &state);
 
 	if (state.ack_next_valid)
 		rds_ib_set_ack(ic, state.ack_next, state.ack_required);
diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index eac30bf..f27d2c8 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -195,7 +195,7 @@ void rds_ib_send_init_ring(struct rds_ib_connection *ic)
 
 		send->s_op = NULL;
 
-		send->s_wr.wr_id = i | RDS_IB_SEND_OP;
+		send->s_wr.wr_id = i;
 		send->s_wr.sg_list = send->s_sge;
 		send->s_wr.ex.imm_data = 0;
 
@@ -263,9 +263,7 @@ void rds_ib_send_cqe_handler(struct rds_ib_connection *ic, struct ib_wc *wc)
 
 	oldest = rds_ib_ring_oldest(&ic->i_send_ring);
 
-	completed = rds_ib_ring_completed(&ic->i_send_ring,
-					  (wc->wr_id & ~RDS_IB_SEND_OP),
-					  oldest);
+	completed = rds_ib_ring_completed(&ic->i_send_ring, wc->wr_id, oldest);
 
 	for (i = 0; i < completed; i++) {
 		send = &ic->i_sends[oldest];
-- 
1.9.1
