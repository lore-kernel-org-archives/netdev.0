From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 13/21] [next] qlge: Cleanup MPI RISC reset path.
Date: Fri, 23 Jan 2009 07:16:31 -0800
Message-ID: <1232723799-8620-13-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754356AbZAWPSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:18:00 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |   40 +++++++++++++++++++++++++++++++++++-----
 1 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index fa31891..eda17b0 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -1,6 +1,6 @@
 #include "qlge.h"
 
-static int ql_read_mbox_reg(struct ql_adapter *qdev, u32 reg, u32 *data)
+static int ql_read_mpi_reg(struct ql_adapter *qdev, u32 reg, u32 *data)
 {
 	int status;
 	/* wait for reg to come ready */
@@ -19,6 +19,37 @@ exit:
 	return status;
 }
 
+static int ql_write_mpi_reg(struct ql_adapter *qdev, u32 reg, u32 data)
+{
+	int status = 0;
+	/* wait for reg to come ready */
+	status = ql_wait_reg_rdy(qdev, PROC_ADDR, PROC_ADDR_RDY, PROC_ADDR_ERR);
+	if (status)
+		goto exit;
+	/* write the data to the data reg */
+	ql_write32(qdev, PROC_DATA, data);
+	/* trigger the write */
+	ql_write32(qdev, PROC_ADDR, reg);
+	/* wait for reg to come ready */
+	status = ql_wait_reg_rdy(qdev, PROC_ADDR, PROC_ADDR_RDY, PROC_ADDR_ERR);
+	if (status)
+		goto exit;
+exit:
+	return status;
+}
+
+static int ql_soft_reset_mpi_risc(struct ql_adapter *qdev)
+{
+	int status;
+	status = ql_write_mpi_reg(qdev, 0x00001010, 1);
+	if (status)
+		printk(KERN_ERR
+			"Failed to force Auto-Load/"
+			"Auto-Init, status = 0x%.08x!\n",
+			status);
+	return status;
+}
+
 static int ql_get_mb_sts(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
 	int i, status;
@@ -28,7 +59,7 @@ static int ql_get_mb_sts(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		return -EBUSY;
 	for (i = 0; i < mbcp->out_count; i++) {
 		status =
-		    ql_read_mbox_reg(qdev, qdev->mailbox_out + i,
+		    ql_read_mpi_reg(qdev, qdev->mailbox_out + i,
 				     &mbcp->mbox_out[i]);
 		if (status) {
 			QPRINTK(qdev, DRV, ERR, "Failed mailbox read.\n");
@@ -144,7 +175,6 @@ void ql_mpi_reset_work(struct work_struct *work)
 	    container_of(work, struct ql_adapter, mpi_reset_work.work);
 	QPRINTK(qdev, DRV, ERR,
 		"Enter, qdev = %p..\n", qdev);
-	ql_write32(qdev, CSR, CSR_CMD_SET_RST);
-	msleep(50);
-	ql_write32(qdev, CSR, CSR_CMD_CLR_RST);
+	cancel_delayed_work_sync(&qdev->mpi_work);
+	ql_soft_reset_mpi_risc(qdev);
 }
-- 
1.6.0.2

