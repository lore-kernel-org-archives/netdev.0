From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 05/14] RDS: make sure we post recv buffers
Date: Sat, 22 Aug 2015 15:45:26 -0700
Message-ID: <1440283535-4800-6-git-send-email-santosh.shilimkar@oracle.com>
References: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If we get an ENOMEM during rds_ib_recv_refill, we might never come
back and refill again later. Patch makes sure to kick krdsd into
helping out.

To achieve this we add RDS_RECV_REFILL flag and update in the refill
path based on that so that at least some therad will keep posting
receive buffers.

Since krdsd and softirq both might race for refill, we decide to
schedule on work queue based on ring_low instead of ring_empty.

Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/connection.c |  2 ++
 net/rds/ib.h         |  2 +-
 net/rds/ib_cm.c      |  2 +-
 net/rds/ib_recv.c    | 58 ++++++++++++++++++++++++++++++++++++++++++++++------
 net/rds/rds.h        |  1 +
 5 files changed, 57 insertions(+), 8 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index da6da57..67405c1 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -297,6 +297,8 @@ void rds_conn_shutdown(struct rds_connection *conn)
 
 		wait_event(conn->c_waitq,
 			   !test_bit(RDS_IN_XMIT, &conn->c_flags));
+		wait_event(conn->c_waitq,
+			   !test_bit(RDS_RECV_REFILL, &conn->c_flags));
 
 		conn->c_trans->conn_shutdown(conn);
 		rds_conn_reset(conn);
diff --git a/net/rds/ib.h b/net/rds/ib.h
index 86d88ec..6422c52 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -320,7 +320,7 @@ void rds_ib_recv_exit(void);
 int rds_ib_recv(struct rds_connection *conn);
 int rds_ib_recv_alloc_caches(struct rds_ib_connection *ic);
 void rds_ib_recv_free_caches(struct rds_ib_connection *ic);
-void rds_ib_recv_refill(struct rds_connection *conn, int prefill);
+void rds_ib_recv_refill(struct rds_connection *conn, int prefill, gfp_t gfp);
 void rds_ib_inc_free(struct rds_incoming *inc);
 int rds_ib_inc_copy_to_user(struct rds_incoming *inc, struct iov_iter *to);
 void rds_ib_recv_cq_comp_handler(struct ib_cq *cq, void *context);
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 8b40d3c..cb78da1 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -135,7 +135,7 @@ void rds_ib_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
 	rds_ib_recv_init_ring(ic);
 	/* Post receive buffers - as a side effect, this will update
 	 * the posted credit count. */
-	rds_ib_recv_refill(conn, 1);
+	rds_ib_recv_refill(conn, 1, GFP_KERNEL);
 
 	/* Tune RNR behavior */
 	rds_ib_tune_rnr(ic, &qp_attr);
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 2a6a75c..3afdcbd 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -297,7 +297,7 @@ static struct rds_page_frag *rds_ib_refill_one_frag(struct rds_ib_connection *ic
 }
 
 static int rds_ib_recv_refill_one(struct rds_connection *conn,
-				  struct rds_ib_recv_work *recv, int prefill)
+				  struct rds_ib_recv_work *recv, gfp_t gfp)
 {
 	struct rds_ib_connection *ic = conn->c_transport_data;
 	struct ib_sge *sge;
@@ -305,7 +305,7 @@ static int rds_ib_recv_refill_one(struct rds_connection *conn,
 	gfp_t slab_mask = GFP_NOWAIT;
 	gfp_t page_mask = GFP_NOWAIT;
 
-	if (prefill) {
+	if (gfp & __GFP_WAIT) {
 		slab_mask = GFP_KERNEL;
 		page_mask = GFP_HIGHUSER;
 	}
@@ -347,6 +347,24 @@ out:
 	return ret;
 }
 
+static int acquire_refill(struct rds_connection *conn)
+{
+	return test_and_set_bit(RDS_RECV_REFILL, &conn->c_flags) == 0;
+}
+
+static void release_refill(struct rds_connection *conn)
+{
+	clear_bit(RDS_RECV_REFILL, &conn->c_flags);
+
+	/* We don't use wait_on_bit()/wake_up_bit() because our waking is in a
+	 * hot path and finding waiters is very rare.  We don't want to walk
+	 * the system-wide hashed waitqueue buckets in the fast path only to
+	 * almost never find waiters.
+	 */
+	if (waitqueue_active(&conn->c_waitq))
+		wake_up_all(&conn->c_waitq);
+}
+
 /*
  * This tries to allocate and post unused work requests after making sure that
  * they have all the allocations they need to queue received fragments into
@@ -354,15 +372,23 @@ out:
  *
  * -1 is returned if posting fails due to temporary resource exhaustion.
  */
-void rds_ib_recv_refill(struct rds_connection *conn, int prefill)
+void rds_ib_recv_refill(struct rds_connection *conn, int prefill, gfp_t gfp)
 {
 	struct rds_ib_connection *ic = conn->c_transport_data;
 	struct rds_ib_recv_work *recv;
 	struct ib_recv_wr *failed_wr;
 	unsigned int posted = 0;
 	int ret = 0;
+	int can_wait = gfp & __GFP_WAIT;
 	u32 pos;
 
+	/* the goal here is to just make sure that someone, somewhere
+	 * is posting buffers.  If we can't get the refill lock,
+	 * let them do their thing
+	 */
+	if (!acquire_refill(conn))
+		return;
+
 	while ((prefill || rds_conn_up(conn)) &&
 	       rds_ib_ring_alloc(&ic->i_recv_ring, 1, &pos)) {
 		if (pos >= ic->i_recv_ring.w_nr) {
@@ -372,7 +398,7 @@ void rds_ib_recv_refill(struct rds_connection *conn, int prefill)
 		}
 
 		recv = &ic->i_recvs[pos];
-		ret = rds_ib_recv_refill_one(conn, recv, prefill);
+		ret = rds_ib_recv_refill_one(conn, recv, gfp);
 		if (ret) {
 			break;
 		}
@@ -402,6 +428,24 @@ void rds_ib_recv_refill(struct rds_connection *conn, int prefill)
 
 	if (ret)
 		rds_ib_ring_unalloc(&ic->i_recv_ring, 1);
+
+	release_refill(conn);
+
+	/* if we're called from the softirq handler, we'll be GFP_NOWAIT.
+	 * in this case the ring being low is going to lead to more interrupts
+	 * and we can safely let the softirq code take care of it unless the
+	 * ring is completely empty.
+	 *
+	 * if we're called from krdsd, we'll be GFP_KERNEL.  In this case
+	 * we might have raced with the softirq code while we had the refill
+	 * lock held.  Use rds_ib_ring_low() instead of ring_empty to decide
+	 * if we should requeue.
+	 */
+	if (rds_conn_up(conn) &&
+	    ((can_wait && rds_ib_ring_low(&ic->i_recv_ring)) ||
+	    rds_ib_ring_empty(&ic->i_recv_ring))) {
+		queue_delayed_work(rds_wq, &conn->c_recv_w, 1);
+	}
 }
 
 /*
@@ -1023,7 +1067,7 @@ void rds_ib_recv_tasklet_fn(unsigned long data)
 		rds_ib_stats_inc(s_ib_rx_ring_empty);
 
 	if (rds_ib_ring_low(&ic->i_recv_ring))
-		rds_ib_recv_refill(conn, 0);
+		rds_ib_recv_refill(conn, 0, GFP_NOWAIT);
 }
 
 int rds_ib_recv(struct rds_connection *conn)
@@ -1032,8 +1076,10 @@ int rds_ib_recv(struct rds_connection *conn)
 	int ret = 0;
 
 	rdsdebug("conn %p\n", conn);
-	if (rds_conn_up(conn))
+	if (rds_conn_up(conn)) {
 		rds_ib_attempt_ack(ic);
+		rds_ib_recv_refill(conn, 0, GFP_KERNEL);
+	}
 
 	return ret;
 }
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 2260c1e4..ff4c5e6 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -80,6 +80,7 @@ enum {
 #define RDS_LL_SEND_FULL	0
 #define RDS_RECONNECT_PENDING	1
 #define RDS_IN_XMIT		2
+#define RDS_RECV_REFILL		3
 
 struct rds_connection {
 	struct hlist_node	c_hash_node;
-- 
1.9.1
