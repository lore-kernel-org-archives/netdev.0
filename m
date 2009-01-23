From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 14/21] [next] qlge: Clean up MPI firware event handler.
Date: Fri, 23 Jan 2009 07:16:32 -0800
Message-ID: <1232723799-8620-14-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754401AbZAWPR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:17:59 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    1 +
 drivers/net/qlge/qlge_main.c |    2 +-
 drivers/net/qlge/qlge_mpi.c  |  101 ++++++++++++++++++++++++++----------------
 3 files changed, 64 insertions(+), 40 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 02c7812..0779f07 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1512,6 +1512,7 @@ void ql_queue_asic_error(struct ql_adapter *qdev);
 u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr);
 void ql_set_ethtool_ops(struct net_device *ndev);
 int ql_read_xgmac_reg64(struct ql_adapter *qdev, u32 reg, u64 *data);
+int ql_cam_route_initialize(struct ql_adapter *qdev);
 
 #if 1
 #define QL_ALL_DUMP
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 023dfe9..ec01dbf 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2937,7 +2937,7 @@ exit:
 	return status;
 }
 
-static int ql_cam_route_initialize(struct ql_adapter *qdev)
+int ql_cam_route_initialize(struct ql_adapter *qdev)
 {
 	int status;
 
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index eda17b0..867baca 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -75,7 +75,7 @@ static void ql_link_up(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	mbcp->out_count = 2;
 
 	if (ql_get_mb_sts(qdev, mbcp))
-		goto exit;
+		return;
 
 	qdev->link_status = mbcp->mbox_out[1];
 	QPRINTK(qdev, DRV, ERR, "Link Up.\n");
@@ -85,9 +85,6 @@ static void ql_link_up(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		netif_carrier_on(qdev->ndev);
 		netif_wake_queue(qdev->ndev);
 	}
-exit:
-	/* Clear the MPI firmware status. */
-	ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
 }
 
 static void ql_link_down(struct ql_adapter *qdev, struct mbox_params *mbcp)
@@ -96,7 +93,7 @@ static void ql_link_down(struct ql_adapter *qdev, struct mbox_params *mbcp)
 
 	if (ql_get_mb_sts(qdev, mbcp)) {
 		QPRINTK(qdev, DRV, ERR, "Firmware did not initialize!\n");
-		goto exit;
+		return;
 	}
 
 	if (netif_carrier_ok(qdev->ndev)) {
@@ -106,27 +103,77 @@ static void ql_link_down(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	}
 	QPRINTK(qdev, DRV, ERR, "Link Down.\n");
 	QPRINTK(qdev, DRV, ERR, "Link Status = 0x%.08x.\n", mbcp->mbox_out[1]);
-exit:
-	/* Clear the MPI firmware status. */
-	ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
 }
 
 static void ql_init_fw_done(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
+	int status;
+
 	mbcp->out_count = 2;
 
 	if (ql_get_mb_sts(qdev, mbcp)) {
 		QPRINTK(qdev, DRV, ERR, "Firmware did not initialize!\n");
-		goto exit;
+		return;
+	}
+	status = ql_cam_route_initialize(qdev);
+	if (status) {
+		QPRINTK(qdev, IFUP, ERR,
+			"Failed to init CAM/Routing tables.\n");
+		return;
 	}
 	QPRINTK(qdev, DRV, ERR, "Firmware initialized!\n");
 	QPRINTK(qdev, DRV, ERR, "Firmware status = 0x%.08x.\n",
 		mbcp->mbox_out[0]);
 	QPRINTK(qdev, DRV, ERR, "Firmware Revision  = 0x%.08x.\n",
 		mbcp->mbox_out[1]);
-exit:
-	/* Clear the MPI firmware status. */
+}
+
+/* Process an async event and clear it unless it's an
+ * error condition.
+ *  This can get called iteratively from the mpi_work thread
+ *  when events arrive via an interrupt.
+ *  It also gets called when a mailbox command is polling for
+ *  it's completion. */
+static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
+{
+	int status;
+
+	/* Just get mailbox zero for now. */
+	mbcp->out_count = 1;
+	status = ql_get_mb_sts(qdev, mbcp);
+	if (status) {
+		QPRINTK(qdev, DRV, ERR,
+			"Could not read MPI, resetting ASIC!\n");
+		ql_queue_asic_error(qdev);
+		goto end;
+	}
+
+	switch (mbcp->mbox_out[0]) {
+
+	case AEN_LINK_UP:
+		ql_link_up(qdev, mbcp);
+		break;
+
+	case AEN_LINK_DOWN:
+		ql_link_down(qdev, mbcp);
+		break;
+
+	case AEN_FW_INIT_DONE:
+		ql_init_fw_done(qdev, mbcp);
+		break;
+
+	case AEN_FW_INIT_FAIL:
+	case AEN_SYS_ERR:
+	case MB_CMD_STS_ERR:
+	default:
+		ql_queue_fw_error(qdev);
+		QPRINTK(qdev, DRV, ERR,
+			"Unsupported AE %.08x.\n", mbcp->mbox_out[0]);
+		/* Clear the MPI firmware status. */
+	}
+end:
 	ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
+	return status;
 }
 
 void ql_mpi_work(struct work_struct *work)
@@ -135,37 +182,13 @@ void ql_mpi_work(struct work_struct *work)
 	    container_of(work, struct ql_adapter, mpi_work.work);
 	struct mbox_params mbc;
 	struct mbox_params *mbcp = &mbc;
-	mbcp->out_count = 1;
 
 	while (ql_read32(qdev, STS) & STS_PI) {
-		if (ql_get_mb_sts(qdev, mbcp)) {
-			QPRINTK(qdev, DRV, ERR,
-				"Could not read MPI, resetting ASIC!\n");
-			ql_queue_asic_error(qdev);
-		}
-
-		switch (mbcp->mbox_out[0]) {
-		case AEN_LINK_UP:
-			ql_link_up(qdev, mbcp);
-			break;
-		case AEN_LINK_DOWN:
-			ql_link_down(qdev, mbcp);
-			break;
-		case AEN_FW_INIT_DONE:
-			ql_init_fw_done(qdev, mbcp);
-			break;
-		case MB_CMD_STS_GOOD:
-			break;
-		case AEN_FW_INIT_FAIL:
-		case AEN_SYS_ERR:
-		case MB_CMD_STS_ERR:
-			ql_queue_fw_error(qdev);
-		default:
-			/* Clear the MPI firmware status. */
-			ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
-			break;
-		}
+		memset(mbcp, 0, sizeof(struct mbox_params));
+		mbcp->out_count = 1;
+		ql_mpi_handler(qdev, mbcp);
 	}
+
 	ql_enable_completion_interrupt(qdev, 0);
 }
 
-- 
1.6.0.2

