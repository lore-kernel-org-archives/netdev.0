From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 3/5] [net-next] qlge: Move firmware event handler.
Date: Thu, 26 Feb 2009 12:08:34 -0800
Message-ID: <1235678916-2856-3-git-send-email-ron.mercer@qlogic.com>
References: <20090226200746.GA23769@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:10180 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753485AbZBZUL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 15:11:56 -0500
In-Reply-To: <20090226200746.GA23769@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is not a logical change but rather a move of the inbound firmware event
handler into it's own function as it will later be called by the outbound
path.
The addition of the mutex is to create exclusive access to the mailbox
commands between inbound and outbound handling.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    1 +
 drivers/net/qlge/qlge_main.c |    1 +
 drivers/net/qlge/qlge_mpi.c  |   88 ++++++++++++++++++++++++++++-------------
 3 files changed, 62 insertions(+), 28 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 8b3c37a..2103fe6 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1407,6 +1407,7 @@ struct ql_adapter {
 
 	u32 mailbox_in;
 	u32 mailbox_out;
+	struct mutex	mpi_mutex;
 
 	int tx_ring_size;
 	int rx_ring_size;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 655f3c4..b144b6b 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3659,6 +3659,7 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	INIT_DELAYED_WORK(&qdev->asic_reset_work, ql_asic_reset_work);
 	INIT_DELAYED_WORK(&qdev->mpi_reset_work, ql_mpi_reset_work);
 	INIT_DELAYED_WORK(&qdev->mpi_work, ql_mpi_work);
+	mutex_init(&qdev->mpi_mutex);
 
 	if (!cards_found) {
 		dev_info(&pdev->dev, "%s\n", DRV_STRING);
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index f9db786..a4b810d 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -124,43 +124,75 @@ exit:
 	ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
 }
 
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
+	case MB_CMD_STS_GOOD:
+		break;
+
+	case AEN_FW_INIT_FAIL:
+	case AEN_SYS_ERR:
+	case MB_CMD_STS_ERR:
+		ql_queue_fw_error(qdev);
+		break;
+
+	default:
+		QPRINTK(qdev, DRV, ERR,
+			"Unsupported AE %.08x.\n", mbcp->mbox_out[0]);
+		/* Clear the MPI firmware status. */
+	}
+end:
+	ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
+	return status;
+}
+
 void ql_mpi_work(struct work_struct *work)
 {
 	struct ql_adapter *qdev =
 	    container_of(work, struct ql_adapter, mpi_work.work);
 	struct mbox_params mbc;
 	struct mbox_params *mbcp = &mbc;
-	mbcp->out_count = 1;
 
-	while (ql_read32(qdev, STS) & STS_PI) {
-		if (ql_get_mb_sts(qdev, mbcp)) {
-			QPRINTK(qdev, DRV, ERR,
-				"Could not read MPI, resetting ASIC!\n");
-			ql_queue_asic_error(qdev);
-		}
+	mutex_lock(&qdev->mpi_mutex);
 
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
+	while (ql_read32(qdev, STS) & STS_PI) {
+		memset(mbcp, 0, sizeof(struct mbox_params));
+		mbcp->out_count = 1;
+		ql_mpi_handler(qdev, mbcp);
 	}
+
+	mutex_unlock(&qdev->mpi_mutex);
 	ql_enable_completion_interrupt(qdev, 0);
 }
 
-- 
1.6.0.2

