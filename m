From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/4 net-next] cnic: Wait for all Context IDs to be
 deleted before sending FCOE_DESTROY_FUNC
Date: Wed, 20 Jul 2011 17:55:23 -0700
Message-ID: <1311209725-10414-2-git-send-email-mchan@broadcom.com>
References: <1311209725-10414-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3031 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751686Ab1GUBre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 21:47:34 -0400
In-Reply-To: <1311209725-10414-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise, the firmware will not respond and we'll have to wait for
timeout.  Refactor the wait loop we already have into a separate
function for this purpose.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
---
 drivers/net/cnic.c |   45 +++++++++++++++++++++++++++------------------
 1 files changed, 27 insertions(+), 18 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 455fd0d..9be0c26 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2448,6 +2448,30 @@ static int cnic_bnx2x_fcoe_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
 	return ret;
 }
 
+static void cnic_bnx2x_delete_wait(struct cnic_dev *dev, u32 start_cid)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	u32 i;
+
+	for (i = start_cid; i < cp->max_cid_space; i++) {
+		struct cnic_context *ctx = &cp->ctx_tbl[i];
+		int j;
+
+		while (test_bit(CTX_FL_DELETE_WAIT, &ctx->ctx_flags))
+			msleep(10);
+
+		for (j = 0; j < 5; j++) {
+			if (!test_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags))
+				break;
+			msleep(20);
+		}
+
+		if (test_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags))
+			netdev_warn(dev->netdev, "CID %x not deleted\n",
+				   ctx->cid);
+	}
+}
+
 static int cnic_bnx2x_fcoe_fw_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
 {
 	struct fcoe_kwqe_destroy *req;
@@ -2456,6 +2480,8 @@ static int cnic_bnx2x_fcoe_fw_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
 	int ret;
 	u32 cid;
 
+	cnic_bnx2x_delete_wait(dev, MAX_ISCSI_TBL_SZ);
+
 	req = (struct fcoe_kwqe_destroy *) kwqe;
 	cid = BNX2X_HW_CID(cp, cp->fcoe_init_cid);
 
@@ -3930,7 +3956,6 @@ static void cnic_close_bnx2x_conn(struct cnic_sock *csk, u32 opcode)
 static void cnic_cm_stop_bnx2x_hw(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-	int i;
 
 	if (!cp->ctx_tbl)
 		return;
@@ -3938,23 +3963,7 @@ static void cnic_cm_stop_bnx2x_hw(struct cnic_dev *dev)
 	if (!netif_running(dev->netdev))
 		return;
 
-	for (i = 0; i < cp->max_cid_space; i++) {
-		struct cnic_context *ctx = &cp->ctx_tbl[i];
-		int j;
-
-		while (test_bit(CTX_FL_DELETE_WAIT, &ctx->ctx_flags))
-			msleep(10);
-
-		for (j = 0; j < 5; j++) {
-			if (!test_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags))
-				break;
-			msleep(20);
-		}
-
-		if (test_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags))
-			netdev_warn(dev->netdev, "CID %x not deleted\n",
-				   ctx->cid);
-	}
+	cnic_bnx2x_delete_wait(dev, 0);
 
 	cancel_delayed_work(&cp->delete_task);
 	flush_workqueue(cnic_wq);
-- 
1.6.4.GIT


