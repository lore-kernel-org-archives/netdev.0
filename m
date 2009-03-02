From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/3] qlge: Add support for getting/setting port config.
Date: Mon,  2 Mar 2009 10:07:32 -0800
Message-ID: <1236017252-6867-4-git-send-email-ron.mercer@qlogic.com>
References: <1236017252-6867-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:2875 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbZCBSKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 13:10:46 -0500
In-Reply-To: <1236017252-6867-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds functionality to get and set port parameters.
Currently it is used to set maximum TX/RX frame sizes. This process is
also capable of setting:
1) Pause type: Standard or Priority based.
2) Loop back mode.
3) Enable Jumbo frame mode (included here...)

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    6 +
 drivers/net/qlge/qlge_main.c |   14 +++-
 drivers/net/qlge/qlge_mpi.c  |  209 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 228 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 5f60ec4..6f9fd24 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1450,6 +1450,7 @@ struct ql_adapter {
 
 	u32 mailbox_in;
 	u32 mailbox_out;
+	struct mbox_params idc_mbc;
 	struct mutex	mpi_mutex;
 
 	int tx_ring_size;
@@ -1486,6 +1487,8 @@ struct ql_adapter {
 	u32 port_link_up;
 	u32 port_init;
 	u32 link_status;
+	u32 link_config;
+	u32 max_frame_size;
 
 	union flash_params flash;
 
@@ -1495,6 +1498,8 @@ struct ql_adapter {
 	struct delayed_work asic_reset_work;
 	struct delayed_work mpi_reset_work;
 	struct delayed_work mpi_work;
+	struct delayed_work mpi_port_cfg_work;
+	struct completion ide_completion;
 	struct nic_operations *nic_ops;
 	u16 device_id;
 };
@@ -1569,6 +1574,7 @@ void ql_queue_asic_error(struct ql_adapter *qdev);
 u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr);
 void ql_set_ethtool_ops(struct net_device *ndev);
 int ql_read_xgmac_reg64(struct ql_adapter *qdev, u32 reg, u64 *data);
+void ql_mpi_port_cfg_work(struct work_struct *work);
 int ql_mb_get_fw_state(struct ql_adapter *qdev);
 
 #if 1
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 29334d9..7c1ce57 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -837,7 +837,14 @@ exit:
 
 static int ql_8000_port_initialize(struct ql_adapter *qdev)
 {
-	return ql_mb_get_fw_state(qdev);
+	int status;
+	status = ql_mb_get_fw_state(qdev);
+	if (status)
+		goto exit;
+	/* Wake up a worker to get/set the TX/RX frame sizes. */
+	queue_delayed_work(qdev->workqueue, &qdev->mpi_port_cfg_work, 0);
+exit:
+	return status;
 }
 
 /* Take the MAC Core out of reset.
@@ -3188,6 +3195,7 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 		cancel_delayed_work_sync(&qdev->asic_reset_work);
 	cancel_delayed_work_sync(&qdev->mpi_reset_work);
 	cancel_delayed_work_sync(&qdev->mpi_work);
+	cancel_delayed_work_sync(&qdev->mpi_port_cfg_work);
 
 	/* The default queue at index 0 is always processed in
 	 * a workqueue.
@@ -3462,6 +3470,8 @@ static int qlge_change_mtu(struct net_device *ndev, int new_mtu)
 
 	if (ndev->mtu == 1500 && new_mtu == 9000) {
 		QPRINTK(qdev, IFUP, ERR, "Changing to jumbo MTU.\n");
+		queue_delayed_work(qdev->workqueue,
+				&qdev->mpi_port_cfg_work, 0);
 	} else if (ndev->mtu == 9000 && new_mtu == 1500) {
 		QPRINTK(qdev, IFUP, ERR, "Changing to normal MTU.\n");
 	} else if ((ndev->mtu == 1500 && new_mtu == 1500) ||
@@ -3771,7 +3781,9 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	INIT_DELAYED_WORK(&qdev->asic_reset_work, ql_asic_reset_work);
 	INIT_DELAYED_WORK(&qdev->mpi_reset_work, ql_mpi_reset_work);
 	INIT_DELAYED_WORK(&qdev->mpi_work, ql_mpi_work);
+	INIT_DELAYED_WORK(&qdev->mpi_port_cfg_work, ql_mpi_port_cfg_work);
 	mutex_init(&qdev->mpi_mutex);
+	init_completion(&qdev->ide_completion);
 
 	if (!cards_found) {
 		dev_info(&pdev->dev, "%s\n", DRV_STRING);
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 11102be..ef610c6 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -138,6 +138,27 @@ end:
 	return status;
 }
 
+/* Process an inter-device event completion.
+ * If good, signal the caller's completion.
+ */
+static int ql_idc_cmplt_aen(struct ql_adapter *qdev)
+{
+	int status;
+	struct mbox_params *mbcp = &qdev->idc_mbc;
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
+		complete(&qdev->ide_completion);
+
+	return status;
+}
 static void ql_link_up(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
 	mbcp->out_count = 2;
@@ -241,6 +262,16 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		status = ql_get_mb_sts(qdev, mbcp);
 		return status;
 
+	/* Process and inbound IDC event.
+	 * This will happen when we're trying to
+	 * change tx/rx max frame size, change pause
+	 * paramters or loopback mode.
+	 */
+	case AEN_IDC_CMPLT:
+	case AEN_IDC_EXT:
+		status = ql_idc_cmplt_aen(qdev);
+		break;
+
 	case AEN_LINK_UP:
 		ql_link_up(qdev, mbcp);
 		break;
@@ -391,6 +422,182 @@ int ql_mb_get_fw_state(struct ql_adapter *qdev)
 	return status;
 }
 
+/* Get link settings and maximum frame size settings
+ * for the current port.
+ * Most likely will block.
+ */
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
+/* Get link settings and maximum frame size settings
+ * for the current port.
+ * Most likely will block.
+ */
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
+		QPRINTK(qdev, DRV, DEBUG,
+			"Passed Get Port Configuration.\n");
+		qdev->link_config = mbcp->mbox_out[1];
+		qdev->max_frame_size = mbcp->mbox_out[2];
+	}
+	return status;
+}
+
+/* IDC - Inter Device Communication...
+ * Some firmware commands require consent of adjacent FCOE
+ * function.  This function waits for the OK, or a
+ * counter-request for a little more time.i
+ * The firmware will complete the request if the other
+ * function doesn't respond.
+ */
+static int ql_idc_wait(struct ql_adapter *qdev)
+{
+	int status = -ETIMEDOUT;
+	long wait_time = 1 * HZ;
+	struct mbox_params *mbcp = &qdev->idc_mbc;
+	do {
+		/* Wait here for the command to complete
+		 * via the IDC process.
+		 */
+		wait_time =
+			wait_for_completion_timeout(&qdev->ide_completion,
+							wait_time);
+		if (!wait_time) {
+			QPRINTK(qdev, DRV, ERR,
+				"IDC Timeout.\n");
+			break;
+		}
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
+/* API called in work thread context to set new TX/RX
+ * maximum frame size values to match MTU.
+ */
+static int ql_set_port_cfg(struct ql_adapter *qdev)
+{
+	int status;
+	status = ql_mb_set_port_cfg(qdev);
+	if (status)
+		return status;
+	status = ql_idc_wait(qdev);
+	return status;
+}
+
+/* The following routines are worker threads that process
+ * events that may sleep waiting for completion.
+ */
+
+/* This thread gets the maximum TX and RX frame size values
+ * from the firmware and, if necessary, changes them to match
+ * the MTU setting.
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
 void ql_mpi_work(struct work_struct *work)
 {
 	struct ql_adapter *qdev =
@@ -414,5 +621,7 @@ void ql_mpi_reset_work(struct work_struct *work)
 {
 	struct ql_adapter *qdev =
 	    container_of(work, struct ql_adapter, mpi_reset_work.work);
+	cancel_delayed_work_sync(&qdev->mpi_work);
+	cancel_delayed_work_sync(&qdev->mpi_port_cfg_work);
 	ql_soft_reset_mpi_risc(qdev);
 }
-- 
1.6.0.2

