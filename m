From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/8 net-next] cnic: Defer iscsi connection cleanup
Date: Wed, 13 Oct 2010 17:06:47 -0700
Message-ID: <1287014811-10979-5-git-send-email-mchan@broadcom.com>
References: <1287014811-10979-1-git-send-email-mchan@broadcom.com>
 <1287014811-10979-2-git-send-email-mchan@broadcom.com>
 <1287014811-10979-3-git-send-email-mchan@broadcom.com>
 <1287014811-10979-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1603 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753286Ab0JNBED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 21:04:03 -0400
In-Reply-To: <1287014811-10979-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bnx2x devices require a 2 second quiet time before sending the last
RAMROD command to destroy a connection.  This sleep wait adds up to a
long delay when iscsid is serially destroying maultiple connections.

Create a workqueue to perform the final connection cleanup in the
background to speed up the process.  This significantly speeds up the
process as the wait time can be done in parallel for multiple connections.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c                        |  110 +++++++++++++++++++++++++++-
 drivers/net/cnic.h                        |    3 +
 drivers/scsi/bnx2i/57xx_iscsi_constants.h |    2 +
 3 files changed, 111 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index ee66c48..b12bba7 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -81,6 +81,8 @@ static struct cnic_ops cnic_bnx2x_ops = {
 	.cnic_ctl	= cnic_ctl,
 };
 
+static struct workqueue_struct *cnic_wq;
+
 static void cnic_shutdown_rings(struct cnic_dev *);
 static void cnic_init_rings(struct cnic_dev *);
 static int cnic_cm_set_pg(struct cnic_sock *);
@@ -1629,10 +1631,11 @@ static int cnic_bnx2x_iscsi_ofld1(struct cnic_dev *dev, struct kwqe *wqes[],
 	struct iscsi_kwqe_conn_offload1 *req1;
 	struct iscsi_kwqe_conn_offload2 *req2;
 	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_context *ctx;
 	struct iscsi_kcqe kcqe;
 	struct kcqe *cqes[1];
 	u32 l5_cid;
-	int ret;
+	int ret = 0;
 
 	if (num < 2) {
 		*work = num;
@@ -1656,9 +1659,15 @@ static int cnic_bnx2x_iscsi_ofld1(struct cnic_dev *dev, struct kwqe *wqes[],
 	kcqe.iscsi_conn_id = l5_cid;
 	kcqe.completion_status = ISCSI_KCQE_COMPLETION_STATUS_CTX_ALLOC_FAILURE;
 
+	ctx = &cp->ctx_tbl[l5_cid];
+	if (test_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags)) {
+		kcqe.completion_status =
+			ISCSI_KCQE_COMPLETION_STATUS_CID_BUSY;
+		goto done;
+	}
+
 	if (atomic_inc_return(&cp->iscsi_conn) > dev->max_iscsi_conn) {
 		atomic_dec(&cp->iscsi_conn);
-		ret = 0;
 		goto done;
 	}
 	ret = cnic_alloc_bnx2x_conn_resc(dev, l5_cid);
@@ -1748,8 +1757,16 @@ static int cnic_bnx2x_iscsi_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
 	if (!test_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags))
 		goto skip_cfc_delete;
 
-	while (!time_after(jiffies, ctx->timestamp + (2 * HZ)))
-		msleep(250);
+	if (!time_after(jiffies, ctx->timestamp + (2 * HZ))) {
+		unsigned long delta = ctx->timestamp + (2 * HZ) - jiffies;
+
+		if (delta > (2 * HZ))
+			delta = 0;
+
+		set_bit(CTX_FL_DELETE_WAIT, &ctx->ctx_flags);
+		queue_delayed_work(cnic_wq, &cp->delete_task, delta);
+		goto destroy_reply;
+	}
 
 	ret = cnic_bnx2x_destroy_ramrod(dev, l5_cid);
 
@@ -1757,7 +1774,9 @@ skip_cfc_delete:
 	cnic_free_bnx2x_conn_resc(dev, l5_cid);
 
 	atomic_dec(&cp->iscsi_conn);
+	clear_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags);
 
+destroy_reply:
 	memset(&kcqe, 0, sizeof(kcqe));
 	kcqe.op_code = ISCSI_KCQE_OPCODE_DESTROY_CONN;
 	kcqe.iscsi_conn_id = l5_cid;
@@ -2748,6 +2767,13 @@ static int cnic_cm_create(struct cnic_dev *dev, int ulp_type, u32 cid,
 	if (l5_cid >= MAX_CM_SK_TBL_SZ)
 		return -EINVAL;
 
+	if (cp->ctx_tbl) {
+		struct cnic_context *ctx = &cp->ctx_tbl[l5_cid];
+
+		if (test_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags))
+			return -EAGAIN;
+	}
+
 	csk1 = &cp->csk_tbl[l5_cid];
 	if (atomic_read(&csk1->ref_count))
 		return -EAGAIN;
@@ -3299,6 +3325,32 @@ static void cnic_close_bnx2x_conn(struct cnic_sock *csk, u32 opcode)
 
 static void cnic_cm_stop_bnx2x_hw(struct cnic_dev *dev)
 {
+	struct cnic_local *cp = dev->cnic_priv;
+	int i;
+
+	if (!cp->ctx_tbl)
+		return;
+
+	if (!netif_running(dev->netdev))
+		return;
+
+	for (i = 0; i < cp->max_cid_space; i++) {
+		struct cnic_context *ctx = &cp->ctx_tbl[i];
+
+		while (test_bit(CTX_FL_DELETE_WAIT, &ctx->ctx_flags))
+			msleep(10);
+
+		if (test_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags))
+			netdev_warn(dev->netdev, "CID %x not deleted\n",
+				   ctx->cid);
+	}
+
+	cancel_delayed_work(&cp->delete_task);
+	flush_workqueue(cnic_wq);
+
+	if (atomic_read(&cp->iscsi_conn) != 0)
+		netdev_warn(dev->netdev, "%d iSCSI connections not destroyed\n",
+			    atomic_read(&cp->iscsi_conn));
 }
 
 static int cnic_cm_init_bnx2x_hw(struct cnic_dev *dev)
@@ -3333,6 +3385,46 @@ static int cnic_cm_init_bnx2x_hw(struct cnic_dev *dev)
 	return 0;
 }
 
+static void cnic_delete_task(struct work_struct *work)
+{
+	struct cnic_local *cp;
+	struct cnic_dev *dev;
+	u32 i;
+	int need_resched = 0;
+
+	cp = container_of(work, struct cnic_local, delete_task.work);
+	dev = cp->dev;
+
+	for (i = 0; i < cp->max_cid_space; i++) {
+		struct cnic_context *ctx = &cp->ctx_tbl[i];
+
+		if (!test_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags) ||
+		    !test_bit(CTX_FL_DELETE_WAIT, &ctx->ctx_flags))
+			continue;
+
+		if (!time_after(jiffies, ctx->timestamp + (2 * HZ))) {
+			need_resched = 1;
+			continue;
+		}
+
+		if (!test_and_clear_bit(CTX_FL_DELETE_WAIT, &ctx->ctx_flags))
+			continue;
+
+		cnic_bnx2x_destroy_ramrod(dev, i);
+
+		cnic_free_bnx2x_conn_resc(dev, i);
+		if (ctx->ulp_proto_id == CNIC_ULP_ISCSI)
+			atomic_dec(&cp->iscsi_conn);
+
+		clear_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags);
+	}
+
+	if (need_resched)
+		queue_delayed_work(cnic_wq, &cp->delete_task,
+				   msecs_to_jiffies(10));
+
+}
+
 static int cnic_cm_open(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -3347,6 +3439,8 @@ static int cnic_cm_open(struct cnic_dev *dev)
 	if (err)
 		goto err_out;
 
+	INIT_DELAYED_WORK(&cp->delete_task, cnic_delete_task);
+
 	dev->cm_create = cnic_cm_create;
 	dev->cm_destroy = cnic_cm_destroy;
 	dev->cm_connect = cnic_cm_connect;
@@ -4735,6 +4829,13 @@ static int __init cnic_init(void)
 		return rc;
 	}
 
+	cnic_wq = create_singlethread_workqueue("cnic_wq");
+	if (!cnic_wq) {
+		cnic_release();
+		unregister_netdevice_notifier(&cnic_netdev_notifier);
+		return -ENOMEM;
+	}
+
 	return 0;
 }
 
@@ -4742,6 +4843,7 @@ static void __exit cnic_exit(void)
 {
 	unregister_netdevice_notifier(&cnic_netdev_notifier);
 	cnic_release();
+	destroy_workqueue(cnic_wq);
 }
 
 module_init(cnic_init);
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 9907cc2..47cd801 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -170,6 +170,7 @@ struct cnic_context {
 	unsigned long		timestamp;
 	unsigned long		ctx_flags;
 #define	CTX_FL_OFFLD_START	0
+#define	CTX_FL_DELETE_WAIT	1
 	u8			ulp_proto_id;
 	union {
 		struct cnic_iscsi	*iscsi;
@@ -287,6 +288,8 @@ struct cnic_local {
 	int			hq_size;
 	int			num_cqs;
 
+	struct delayed_work	delete_task;
+
 	struct cnic_ctx		*ctx_arr;
 	int			ctx_blks;
 	int			ctx_blk_size;
diff --git a/drivers/scsi/bnx2i/57xx_iscsi_constants.h b/drivers/scsi/bnx2i/57xx_iscsi_constants.h
index 2fceb19..1b6f86b 100644
--- a/drivers/scsi/bnx2i/57xx_iscsi_constants.h
+++ b/drivers/scsi/bnx2i/57xx_iscsi_constants.h
@@ -120,6 +120,8 @@
 /* additional LOM specific iSCSI license not installed */
 #define ISCSI_KCQE_COMPLETION_STATUS_LOM_ISCSI_NOT_ENABLED              (0x51)
 
+#define ISCSI_KCQE_COMPLETION_STATUS_CID_BUSY				(0x80)
+
 /* SQ/RQ/CQ DB structure sizes */
 #define ISCSI_SQ_DB_SIZE    (16)
 #define ISCSI_RQ_DB_SIZE    (16)
-- 
1.6.4.GIT


