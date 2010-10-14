From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/8 net-next] cnic: Add cnic_bnx2x_destroy_ramrod()
Date: Wed, 13 Oct 2010 17:06:46 -0700
Message-ID: <1287014811-10979-4-git-send-email-mchan@broadcom.com>
References: <1287014811-10979-1-git-send-email-mchan@broadcom.com>
 <1287014811-10979-2-git-send-email-mchan@broadcom.com>
 <1287014811-10979-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3286 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753129Ab0JNBEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 21:04:01 -0400
In-Reply-To: <1287014811-10979-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactoring code for the next patch to defer connection clean up.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   39 +++++++++++++++++++++++++--------------
 1 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 311b2e6..ee66c48 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -1708,25 +1708,14 @@ static int cnic_bnx2x_iscsi_update(struct cnic_dev *dev, struct kwqe *kwqe)
 	return ret;
 }
 
-static int cnic_bnx2x_iscsi_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
+static int cnic_bnx2x_destroy_ramrod(struct cnic_dev *dev, u32 l5_cid)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-	struct iscsi_kwqe_conn_destroy *req =
-		(struct iscsi_kwqe_conn_destroy *) kwqe;
-	union l5cm_specific_data l5_data;
-	u32 l5_cid = req->reserved0;
 	struct cnic_context *ctx = &cp->ctx_tbl[l5_cid];
-	int ret = 0;
-	struct iscsi_kcqe kcqe;
-	struct kcqe *cqes[1];
+	union l5cm_specific_data l5_data;
+	int ret;
 	u32 hw_cid, type;
 
-	if (!test_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags))
-		goto skip_cfc_delete;
-
-	while (!time_after(jiffies, ctx->timestamp + (2 * HZ)))
-		msleep(250);
-
 	init_waitqueue_head(&ctx->waitq);
 	ctx->wait_cond = 0;
 	memset(&l5_data, 0, sizeof(l5_data));
@@ -1742,6 +1731,28 @@ static int cnic_bnx2x_iscsi_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
 	if (ret == 0)
 		wait_event(ctx->waitq, ctx->wait_cond);
 
+	return ret;
+}
+
+static int cnic_bnx2x_iscsi_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct iscsi_kwqe_conn_destroy *req =
+		(struct iscsi_kwqe_conn_destroy *) kwqe;
+	u32 l5_cid = req->reserved0;
+	struct cnic_context *ctx = &cp->ctx_tbl[l5_cid];
+	int ret = 0;
+	struct iscsi_kcqe kcqe;
+	struct kcqe *cqes[1];
+
+	if (!test_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags))
+		goto skip_cfc_delete;
+
+	while (!time_after(jiffies, ctx->timestamp + (2 * HZ)))
+		msleep(250);
+
+	ret = cnic_bnx2x_destroy_ramrod(dev, l5_cid);
+
 skip_cfc_delete:
 	cnic_free_bnx2x_conn_resc(dev, l5_cid);
 
-- 
1.6.4.GIT


