From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v3 08/17] RDS: IB: split the mr registration and invalidation path
Date: Mon,  2 Jan 2017 14:45:43 -0800
Message-ID: <1483397152-8307-9-git-send-email-santosh.shilimkar@oracle.com>
References: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50552 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756912AbdABWqN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 17:46:13 -0500
In-Reply-To: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MR invalidation in RDS is done in background thread and not in
data path like registration. So break the dependency between them
which helps to remove the performance bottleneck.

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib.h      |  4 +++-
 net/rds/ib_cm.c   |  9 +++++++--
 net/rds/ib_frmr.c | 11 ++++++-----
 3 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index f4e8121..f14c26d 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -14,7 +14,8 @@
 
 #define RDS_IB_DEFAULT_RECV_WR		1024
 #define RDS_IB_DEFAULT_SEND_WR		256
-#define RDS_IB_DEFAULT_FR_WR		512
+#define RDS_IB_DEFAULT_FR_WR		256
+#define RDS_IB_DEFAULT_FR_INV_WR	256
 
 #define RDS_IB_DEFAULT_RETRY_COUNT	1
 
@@ -125,6 +126,7 @@ struct rds_ib_connection {
 
 	/* To control the number of wrs from fastreg */
 	atomic_t		i_fastreg_wrs;
+	atomic_t		i_fastunreg_wrs;
 
 	/* interrupt handling */
 	struct tasklet_struct	i_send_tasklet;
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index b9da1e5..3002acf 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -382,7 +382,10 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	 * completion queue and send queue. This extra space is used for FRMR
 	 * registration and invalidation work requests
 	 */
-	fr_queue_space = (rds_ibdev->use_fastreg ? RDS_IB_DEFAULT_FR_WR : 0);
+	fr_queue_space = rds_ibdev->use_fastreg ?
+			 (RDS_IB_DEFAULT_FR_WR + 1) +
+			 (RDS_IB_DEFAULT_FR_INV_WR + 1)
+			 : 0;
 
 	/* add the conn now so that connection establishment has the dev */
 	rds_ib_add_conn(rds_ibdev, conn);
@@ -444,6 +447,7 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	attr.send_cq = ic->i_send_cq;
 	attr.recv_cq = ic->i_recv_cq;
 	atomic_set(&ic->i_fastreg_wrs, RDS_IB_DEFAULT_FR_WR);
+	atomic_set(&ic->i_fastunreg_wrs, RDS_IB_DEFAULT_FR_INV_WR);
 
 	/*
 	 * XXX this can fail if max_*_wr is too large?  Are we supposed
@@ -766,7 +770,8 @@ void rds_ib_conn_path_shutdown(struct rds_conn_path *cp)
 		wait_event(rds_ib_ring_empty_wait,
 			   rds_ib_ring_empty(&ic->i_recv_ring) &&
 			   (atomic_read(&ic->i_signaled_sends) == 0) &&
-			   (atomic_read(&ic->i_fastreg_wrs) == RDS_IB_DEFAULT_FR_WR));
+			   (atomic_read(&ic->i_fastreg_wrs) == RDS_IB_DEFAULT_FR_WR) &&
+			   (atomic_read(&ic->i_fastunreg_wrs) == RDS_IB_DEFAULT_FR_INV_WR));
 		tasklet_kill(&ic->i_send_tasklet);
 		tasklet_kill(&ic->i_recv_tasklet);
 
diff --git a/net/rds/ib_frmr.c b/net/rds/ib_frmr.c
index 66b3d62..48332a6 100644
--- a/net/rds/ib_frmr.c
+++ b/net/rds/ib_frmr.c
@@ -241,8 +241,8 @@ static int rds_ib_post_inv(struct rds_ib_mr *ibmr)
 	if (frmr->fr_state != FRMR_IS_INUSE)
 		goto out;
 
-	while (atomic_dec_return(&ibmr->ic->i_fastreg_wrs) <= 0) {
-		atomic_inc(&ibmr->ic->i_fastreg_wrs);
+	while (atomic_dec_return(&ibmr->ic->i_fastunreg_wrs) <= 0) {
+		atomic_inc(&ibmr->ic->i_fastunreg_wrs);
 		cpu_relax();
 	}
 
@@ -261,7 +261,7 @@ static int rds_ib_post_inv(struct rds_ib_mr *ibmr)
 	if (unlikely(ret)) {
 		frmr->fr_state = FRMR_IS_STALE;
 		frmr->fr_inv = false;
-		atomic_inc(&ibmr->ic->i_fastreg_wrs);
+		atomic_inc(&ibmr->ic->i_fastunreg_wrs);
 		pr_err("RDS/IB: %s returned error(%d)\n", __func__, ret);
 		goto out;
 	}
@@ -289,9 +289,10 @@ void rds_ib_mr_cqe_handler(struct rds_ib_connection *ic, struct ib_wc *wc)
 	if (frmr->fr_inv) {
 		frmr->fr_state = FRMR_IS_FREE;
 		frmr->fr_inv = false;
+		atomic_inc(&ic->i_fastreg_wrs);
+	} else {
+		atomic_inc(&ic->i_fastunreg_wrs);
 	}
-
-	atomic_inc(&ic->i_fastreg_wrs);
 }
 
 void rds_ib_unreg_frmr(struct list_head *list, unsigned int *nfreed,
-- 
1.9.1
