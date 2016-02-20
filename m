From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [net-next][PATCH 12/13] RDS: IB: allocate extra space on queues for FRMR support
Date: Sat, 20 Feb 2016 03:30:03 -0800
Message-ID: <1455967804-27644-13-git-send-email-santosh.shilimkar@oracle.com>
References: <1455967804-27644-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1455967804-27644-1-git-send-email-santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Fastreg MR(FRMR) memory registration and invalidation makes use
of work request and completion queues for its operation. Patch
allocates extra queue space towards these operation(s).

Signed-off-by: Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 net/rds/ib.h    |  4 ++++
 net/rds/ib_cm.c | 16 ++++++++++++----
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index c5eddc2..eeb0d6c 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -14,6 +14,7 @@
 
 #define RDS_IB_DEFAULT_RECV_WR		1024
 #define RDS_IB_DEFAULT_SEND_WR		256
+#define RDS_IB_DEFAULT_FR_WR		512
 
 #define RDS_IB_DEFAULT_RETRY_COUNT	2
 
@@ -122,6 +123,9 @@ struct rds_ib_connection {
 	struct ib_wc		i_send_wc[RDS_IB_WC_MAX];
 	struct ib_wc		i_recv_wc[RDS_IB_WC_MAX];
 
+	/* To control the number of wrs from fastreg */
+	atomic_t		i_fastreg_wrs;
+
 	/* interrupt handling */
 	struct tasklet_struct	i_send_tasklet;
 	struct tasklet_struct	i_recv_tasklet;
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 7f68abc..83f4673 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -363,7 +363,7 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	struct ib_qp_init_attr attr;
 	struct ib_cq_init_attr cq_attr = {};
 	struct rds_ib_device *rds_ibdev;
-	int ret;
+	int ret, fr_queue_space;
 
 	/*
 	 * It's normal to see a null device if an incoming connection races
@@ -373,6 +373,12 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	if (!rds_ibdev)
 		return -EOPNOTSUPP;
 
+	/* The fr_queue_space is currently set to 512, to add extra space on
+	 * completion queue and send queue. This extra space is used for FRMR
+	 * registration and invalidation work requests
+	 */
+	fr_queue_space = (rds_ibdev->use_fastreg ? RDS_IB_DEFAULT_FR_WR : 0);
+
 	/* add the conn now so that connection establishment has the dev */
 	rds_ib_add_conn(rds_ibdev, conn);
 
@@ -384,7 +390,7 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	/* Protection domain and memory range */
 	ic->i_pd = rds_ibdev->pd;
 
-	cq_attr.cqe = ic->i_send_ring.w_nr + 1;
+	cq_attr.cqe = ic->i_send_ring.w_nr + fr_queue_space + 1;
 
 	ic->i_send_cq = ib_create_cq(dev, rds_ib_cq_comp_handler_send,
 				     rds_ib_cq_event_handler, conn,
@@ -424,7 +430,7 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	attr.event_handler = rds_ib_qp_event_handler;
 	attr.qp_context = conn;
 	/* + 1 to allow for the single ack message */
-	attr.cap.max_send_wr = ic->i_send_ring.w_nr + 1;
+	attr.cap.max_send_wr = ic->i_send_ring.w_nr + fr_queue_space + 1;
 	attr.cap.max_recv_wr = ic->i_recv_ring.w_nr + 1;
 	attr.cap.max_send_sge = rds_ibdev->max_sge;
 	attr.cap.max_recv_sge = RDS_IB_RECV_SGE;
@@ -432,6 +438,7 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	attr.qp_type = IB_QPT_RC;
 	attr.send_cq = ic->i_send_cq;
 	attr.recv_cq = ic->i_recv_cq;
+	atomic_set(&ic->i_fastreg_wrs, RDS_IB_DEFAULT_FR_WR);
 
 	/*
 	 * XXX this can fail if max_*_wr is too large?  Are we supposed
@@ -751,7 +758,8 @@ void rds_ib_conn_shutdown(struct rds_connection *conn)
 		 */
 		wait_event(rds_ib_ring_empty_wait,
 			   rds_ib_ring_empty(&ic->i_recv_ring) &&
-			   (atomic_read(&ic->i_signaled_sends) == 0));
+			   (atomic_read(&ic->i_signaled_sends) == 0) &&
+			   (atomic_read(&ic->i_fastreg_wrs) == RDS_IB_DEFAULT_FR_WR));
 		tasklet_kill(&ic->i_send_tasklet);
 		tasklet_kill(&ic->i_recv_tasklet);
 
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
