From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 21/21] [next] qlge: Add port config mailbox command.
Date: Fri, 23 Jan 2009 07:16:39 -0800
Message-ID: <1232723799-8620-21-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48651 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755220AbZAWPSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:18:16 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for using the port config firmware mailbox command to change
the tx/rx max framesize based on MTU from host.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    3 +
 drivers/net/qlge/qlge_main.c |    5 +
 drivers/net/qlge/qlge_mpi.c  |  198 +++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 202 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index afc9a3b..47e1537 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1473,7 +1473,9 @@ struct ql_adapter {
 	struct delayed_work asic_reset_work;
 	struct delayed_work mpi_reset_work;
 	struct delayed_work mpi_work;
+	struct delayed_work mpi_port_cfg_work;
 	struct delayed_work mpi_idc_work;
+	struct completion ide_completion;
 };
 
 /*
@@ -1542,6 +1544,7 @@ void ql_queue_fw_error(struct ql_adapter *qdev);
 void ql_mpi_work(struct work_struct *work);
 void ql_mpi_reset_work(struct work_struct *work);
 void ql_mpi_idc_work(struct work_struct *work);
+void ql_mpi_port_cfg_work(struct work_struct *work);
 int ql_wait_reg_rdy(struct ql_adapter *qdev, u32 reg, u32 bit, u32 ebit);
 void ql_queue_asic_error(struct ql_adapter *qdev);
 u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr);
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 4110402..92189f7 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2994,6 +2994,7 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 	cancel_delayed_work_sync(&qdev->mpi_reset_work);
 	cancel_delayed_work_sync(&qdev->mpi_work);
 	cancel_delayed_work_sync(&qdev->mpi_idc_work);
+	cancel_delayed_work_sync(&qdev->mpi_port_cfg_work);
 	/* The default queue at index 0 is always processed in
 	 * a workqueue.
 	 */
@@ -3236,6 +3237,8 @@ static int qlge_change_mtu(struct net_device *ndev, int new_mtu)
 
 	if (ndev->mtu == 1500 && new_mtu == 9000) {
 		QPRINTK(qdev, IFUP, ERR, "Changing to jumbo MTU.\n");
+		queue_delayed_work(qdev->workqueue,
+				&qdev->mpi_port_cfg_work, 0);
 	} else if (ndev->mtu == 9000 && new_mtu == 1500) {
 		QPRINTK(qdev, IFUP, ERR, "Changing to normal MTU.\n");
 	} else if ((ndev->mtu == 1500 && new_mtu == 1500) ||
@@ -3550,6 +3553,8 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	INIT_DELAYED_WORK(&qdev->mpi_reset_work, ql_mpi_reset_work);
 	INIT_DELAYED_WORK(&qdev->mpi_work, ql_mpi_work);
 	INIT_DELAYED_WORK(&qdev->mpi_idc_work, ql_mpi_idc_work);
+	INIT_DELAYED_WORK(&qdev->mpi_port_cfg_work, ql_mpi_port_cfg_work);
+	init_completion(&qdev->ide_completion);
 	mutex_init(&qdev->mpi_mutex);
 
 	if (!cards_found) {
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index f2f77c6..864df38 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -179,6 +179,27 @@ static int ql_idc_req_aen(struct ql_adapter *qdev)
 	return status;
 }
 
+static int ql_idc_cmplt_aen(struct ql_adapter *qdev)
+{
+	int status;
+	struct mbox_params *mbcp = &qdev->idc_mbc;
+
+	mbcp->out_count = 4;
+	status = ql_get_mb_sts(qdev, mbcp);
+	if (status) {
+		QPRINTK(qdev, DRV, ERR,
+			"Could not read MPI, resetting RISC!\n");
+		ql_queue_fw_error(qdev);
+	} else
+		/* Wake up the sleeping mpi_idc_work thread that is
+		 * waiting for this event.
+		 */
+
+		complete(&qdev->ide_completion);
+
+	return status;
+}
+
 static void ql_link_up(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
 	int status = 0;
@@ -331,6 +352,11 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		status = ql_idc_req_aen(qdev);
 		break;
 
+	case AEN_IDC_CMPLT:
+	case AEN_IDC_EXT:
+		status = ql_idc_cmplt_aen(qdev);
+		break;
+
 	case AEN_LINK_UP:
 		ql_link_up(qdev, mbcp);
 		break;
@@ -423,8 +449,10 @@ static int ql_mailbox_command(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		 * command complete or an AEN.  If it's our
 		 * completion then get out.
 		 */
-		if ((mbcp->mbox_out[0] & 0x0000f000) ==
-					0x00004000)
+		if (((mbcp->mbox_out[0] & 0x0000f000) ==
+					MB_CMD_STS_GOOD) ||
+			((mbcp->mbox_out[0] & 0x0000f000) ==
+					MB_CMD_STS_INTRMDT))
 			break;
 	} while (--count);
 
@@ -440,7 +468,10 @@ static int ql_mailbox_command(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	 */
 	ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
 
-	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
+	if (((mbcp->mbox_out[0] & 0x0000f000) !=
+					MB_CMD_STS_GOOD) &&
+		((mbcp->mbox_out[0] & 0x0000f000) !=
+					MB_CMD_STS_INTRMDT)) {
 		ql_display_mb_sts(qdev, mbcp);
 		status = -EIO;
 	}
@@ -450,7 +481,8 @@ end:
 	ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16) | INTR_MASK_PI);
 	return status;
 }
-int ql_mb_idc_ack(struct ql_adapter *qdev)
+
+static int ql_mb_idc_ack(struct ql_adapter *qdev)
 {
 	struct mbox_params mbc;
 	struct mbox_params *mbcp = &mbc;
@@ -479,6 +511,164 @@ int ql_mb_idc_ack(struct ql_adapter *qdev)
 	return status;
 }
 
+/* Most likely will block. */
+static int ql_mb_set_port_cfg(struct ql_adapter *qdev)
+{
+	struct mbox_params mbc;
+	struct mbox_params *mbcp = &mbc;
+	int status = 0;
+
+	memset(mbcp, 0, sizeof(struct mbox_params));
+
+	mbcp->in_count = 3;
+	mbcp->out_count = 1;
+
+	mbcp->mbox_in[0] = MB_CMD_SET_PORT_CFG;
+	mbcp->mbox_in[1] = qdev->link_config;
+	mbcp->mbox_in[2] = qdev->max_frame_size;
+
+
+	status = ql_mailbox_command(qdev, mbcp);
+	if (status)
+		return status;
+
+	if (mbcp->mbox_out[0] == MB_CMD_STS_INTRMDT) {
+		QPRINTK(qdev, DRV, ERR,
+			"Port Config sent, wait for IDC.\n");
+	} else	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
+		QPRINTK(qdev, DRV, ERR,
+			"Failed Set Port Configuration.\n");
+		status = -EIO;
+	}
+	return status;
+}
+
+static int ql_mb_get_port_cfg(struct ql_adapter *qdev)
+{
+	struct mbox_params mbc;
+	struct mbox_params *mbcp = &mbc;
+	int status = 0;
+
+	memset(mbcp, 0, sizeof(struct mbox_params));
+
+	mbcp->in_count = 1;
+	mbcp->out_count = 3;
+
+	mbcp->mbox_in[0] = MB_CMD_GET_PORT_CFG;
+
+	status = ql_mailbox_command(qdev, mbcp);
+	if (status)
+		return status;
+
+	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
+		QPRINTK(qdev, DRV, ERR,
+			"Failed Get Port Configuration.\n");
+		status = -EIO;
+	} else	{
+		QPRINTK(qdev, DRV, ERR,
+			"Passed Get Port Configuration.\n");
+		qdev->link_config = mbcp->mbox_out[1];
+		qdev->max_frame_size = mbcp->mbox_out[2];
+	}
+	return status;
+}
+
+static int ql_idc_wait(struct ql_adapter *qdev)
+{
+	int status = -ETIMEDOUT;
+	long wait_time = 1 * HZ;
+	struct mbox_params *mbcp = &qdev->idc_mbc;
+
+	do {
+	/* Wait here for the command to complete
+	 * via the IDC process.
+	 */
+		wait_time =
+			wait_for_completion_timeout(&qdev->ide_completion,
+							wait_time);
+		if (!wait_time) {
+			QPRINTK(qdev, DRV, ERR,
+				"IDC Timeout.\n");
+			break;
+		}
+
+		/* Now examine the response from the IDC process.
+		 * We might have a good completion or a request for
+		 * more wait time.
+		 */
+		if (mbcp->mbox_out[0] == AEN_IDC_EXT) {
+			QPRINTK(qdev, DRV, ERR,
+				"IDC Time Extension from function.\n");
+			wait_time += (mbcp->mbox_out[1] >> 8) & 0x0000000f;
+		} else if (mbcp->mbox_out[0] == AEN_IDC_CMPLT) {
+			QPRINTK(qdev, DRV, ERR,
+				"IDC Success.\n");
+			status = 0;
+			break;
+		} else {
+			QPRINTK(qdev, DRV, ERR,
+				"IDC: Invalid State 0x%.04x.\n",
+				mbcp->mbox_out[0]);
+			status = -EIO;
+			break;
+		}
+	} while (wait_time);
+
+	return status;
+}
+
+static int ql_set_port_cfg(struct ql_adapter *qdev)
+{
+	int status;
+
+	status = ql_mb_set_port_cfg(qdev);
+	if (status)
+		return status;
+
+	status = ql_idc_wait(qdev);
+	return status;
+}
+
+/* The following routines are worker threads that process
+ * events that may sleep waiting for completion.
+ */
+void ql_mpi_port_cfg_work(struct work_struct *work)
+{
+	struct ql_adapter *qdev =
+	    container_of(work, struct ql_adapter, mpi_port_cfg_work.work);
+	struct net_device *ndev = qdev->ndev;
+	int status;
+
+	status = ql_mb_get_port_cfg(qdev);
+	if (status) {
+		QPRINTK(qdev, DRV, ERR,
+			"Bug: Failed to get port config data.\n");
+		goto err;
+	}
+
+	if (ndev->mtu <= 2500)
+		goto end;
+	else if (qdev->link_config & CFG_JUMBO_FRAME_SIZE &&
+			qdev->max_frame_size ==
+			CFG_DEFAULT_MAX_FRAME_SIZE)
+		goto end;
+
+	qdev->link_config |=	CFG_JUMBO_FRAME_SIZE;
+	qdev->max_frame_size = CFG_DEFAULT_MAX_FRAME_SIZE;
+	status = ql_set_port_cfg(qdev);
+	if (status) {
+		QPRINTK(qdev, DRV, ERR,
+			"Bug: Failed to set port config data.\n");
+		goto err;
+	}
+end:
+	clear_bit(QL_PORT_CFG, &qdev->flags);
+	return;
+err:
+	ql_queue_fw_error(qdev);
+	goto end;
+}
+
 void ql_mpi_idc_work(struct work_struct *work)
 {
 	struct ql_adapter *qdev =
-- 
1.6.0.2

