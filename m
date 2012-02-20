From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 2/5] bnx2fc: HSI dependent changes for 7.2.xx FW
Date: Mon, 20 Feb 2012 21:59:09 +0200
Message-ID: <1329767952-12605-3-git-send-email-dmitry@broadcom.com>
References: <1329767952-12605-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Bhanu Prakash Gollapudi" <bprakash@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3378 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134Ab2BTT7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Feb 2012 14:59:13 -0500
In-Reply-To: <1329767952-12605-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bhanu Prakash Gollapudi <bprakash@broadcom.com>

>From FW version 7.2.x, firwmare expects the driver to set Rx only section along
with Tx only section for single cached SGEs.

Signed-off-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/scsi/bnx2fc/bnx2fc_constants.h |    2 +-
 drivers/scsi/bnx2fc/bnx2fc_hwi.c       |   12 +++++++++---
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/scsi/bnx2fc/bnx2fc_constants.h b/drivers/scsi/bnx2fc/bnx2fc_constants.h
index 399cda0..c12702b 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_constants.h
+++ b/drivers/scsi/bnx2fc/bnx2fc_constants.h
@@ -7,7 +7,7 @@
 
 /* Current FCoE HSI version number composed of two fields (16 bit) */
 /* Implies on a change broken previous HSI */
-#define FCOE_HSI_MAJOR_VERSION (1)
+#define FCOE_HSI_MAJOR_VERSION (2)
 /* Implies on a change which does not broken previous HSI */
 #define FCOE_HSI_MINOR_VERSION (1)
 
diff --git a/drivers/scsi/bnx2fc/bnx2fc_hwi.c b/drivers/scsi/bnx2fc/bnx2fc_hwi.c
index 1923a25..afd5709 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_hwi.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_hwi.c
@@ -1716,15 +1716,19 @@ void bnx2fc_init_task(struct bnx2fc_cmd *io_req,
 
 	/* Tx only */
 	bd_count = bd_tbl->bd_valid;
+	cached_sge = &task->rxwr_only.union_ctx.read_info.sgl_ctx.cached_sge;
 	if (task_type == FCOE_TASK_TYPE_WRITE) {
 		if ((dev_type == TYPE_DISK) && (bd_count == 1)) {
 			struct fcoe_bd_ctx *fcoe_bd_tbl = bd_tbl->bd_tbl;
 
 			task->txwr_only.sgl_ctx.cached_sge.cur_buf_addr.lo =
+			cached_sge->cur_buf_addr.lo =
 					fcoe_bd_tbl->buf_addr_lo;
 			task->txwr_only.sgl_ctx.cached_sge.cur_buf_addr.hi =
+			cached_sge->cur_buf_addr.hi =
 					fcoe_bd_tbl->buf_addr_hi;
 			task->txwr_only.sgl_ctx.cached_sge.cur_buf_rem =
+			cached_sge->cur_buf_rem =
 					fcoe_bd_tbl->buf_len;
 
 			task->txwr_rxrd.const_ctx.init_flags |= 1 <<
@@ -1790,11 +1794,13 @@ void bnx2fc_init_task(struct bnx2fc_cmd *io_req,
 	task->rxwr_txrd.var_ctx.rx_id = 0xffff;
 
 	/* Rx Only */
-	cached_sge = &task->rxwr_only.union_ctx.read_info.sgl_ctx.cached_sge;
+	if (task_type != FCOE_TASK_TYPE_READ)
+		return;
+
 	sgl = &task->rxwr_only.union_ctx.read_info.sgl_ctx.sgl;
 	bd_count = bd_tbl->bd_valid;
-	if (task_type == FCOE_TASK_TYPE_READ &&
-	    dev_type == TYPE_DISK) {
+
+	if (dev_type == TYPE_DISK) {
 		if (bd_count == 1) {
 
 			struct fcoe_bd_ctx *fcoe_bd_tbl = bd_tbl->bd_tbl;
-- 
1.7.7.2
