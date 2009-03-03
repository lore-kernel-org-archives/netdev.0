From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 4/8] qlge: Add worker-handler for firmware events.
Date: Tue,  3 Mar 2009 14:10:33 -0800
Message-ID: <1236118237-14483-5-git-send-email-ron.mercer@qlogic.com>
References: <1236118237-14483-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50781 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761754AbZCCWNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 17:13:55 -0500
In-Reply-To: <1236118237-14483-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This worker and it's supporting routines are used for
IDC 'inter-device-communication' events that require
an ACK mailbox command be sent to allow completion
of the request. These requests are originated by
another function wanting to change some common
port paramters. Typical example would be:

1) Change max TX/RX frame size allowed.
2) Change pause parameters.
3) Change loopback mode.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    3 +
 drivers/net/qlge/qlge_main.c |    4 +-
 drivers/net/qlge/qlge_mpi.c  |  143 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 149 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 6f9fd24..9918106 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1499,6 +1499,7 @@ struct ql_adapter {
 	struct delayed_work mpi_reset_work;
 	struct delayed_work mpi_work;
 	struct delayed_work mpi_port_cfg_work;
+	struct delayed_work mpi_idc_work;
 	struct completion ide_completion;
 	struct nic_operations *nic_ops;
 	u16 device_id;
@@ -1574,8 +1575,10 @@ void ql_queue_asic_error(struct ql_adapter *qdev);
 u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr);
 void ql_set_ethtool_ops(struct net_device *ndev);
 int ql_read_xgmac_reg64(struct ql_adapter *qdev, u32 reg, u64 *data);
+void ql_mpi_idc_work(struct work_struct *work);
 void ql_mpi_port_cfg_work(struct work_struct *work);
 int ql_mb_get_fw_state(struct ql_adapter *qdev);
+int ql_cam_route_initialize(struct ql_adapter *qdev);
 
 #if 1
 #define QL_ALL_DUMP
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 7c1ce57..d800ff4 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3014,7 +3014,7 @@ exit:
 	return status;
 }
 
-static int ql_cam_route_initialize(struct ql_adapter *qdev)
+int ql_cam_route_initialize(struct ql_adapter *qdev)
 {
 	int status;
 
@@ -3195,6 +3195,7 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 		cancel_delayed_work_sync(&qdev->asic_reset_work);
 	cancel_delayed_work_sync(&qdev->mpi_reset_work);
 	cancel_delayed_work_sync(&qdev->mpi_work);
+	cancel_delayed_work_sync(&qdev->mpi_idc_work);
 	cancel_delayed_work_sync(&qdev->mpi_port_cfg_work);
 
 	/* The default queue at index 0 is always processed in
@@ -3782,6 +3783,7 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	INIT_DELAYED_WORK(&qdev->mpi_reset_work, ql_mpi_reset_work);
 	INIT_DELAYED_WORK(&qdev->mpi_work, ql_mpi_work);
 	INIT_DELAYED_WORK(&qdev->mpi_port_cfg_work, ql_mpi_port_cfg_work);
+	INIT_DELAYED_WORK(&qdev->mpi_idc_work, ql_mpi_idc_work);
 	mutex_init(&qdev->mpi_mutex);
 	init_completion(&qdev->ide_completion);
 
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 3b4b494..9f1fe54 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -138,6 +138,40 @@ end:
 	return status;
 }
 
+/* We are being asked by firmware to accept
+ * a change to the port.  This is only
+ * a change to max frame sizes (Tx/Rx), pause
+ * paramters, or loopback mode. We wake up a worker
+ * to handler processing this since a mailbox command
+ * will need to be sent to ACK the request.
+ */
+static int ql_idc_req_aen(struct ql_adapter *qdev)
+{
+	int status;
+	struct mbox_params *mbcp = &qdev->idc_mbc;
+
+	QPRINTK(qdev, DRV, ERR, "Enter!\n");
+	/* Get the status data and start up a thread to
+	 * handle the request.
+	 */
+	mbcp = &qdev->idc_mbc;
+	mbcp->out_count = 4;
+	status = ql_get_mb_sts(qdev, mbcp);
+	if (status) {
+		QPRINTK(qdev, DRV, ERR,
+			"Could not read MPI, resetting ASIC!\n");
+		ql_queue_asic_error(qdev);
+	} else	{
+		/* Begin polled mode early so
+		 * we don't get another interrupt
+		 * when we leave mpi_worker.
+		 */
+		ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16));
+		queue_delayed_work(qdev->workqueue, &qdev->mpi_idc_work, 0);
+	}
+	return status;
+}
+
 /* Process an inter-device event completion.
  * If good, signal the caller's completion.
  */
@@ -175,6 +209,35 @@ static void ql_link_up(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	qdev->link_status = mbcp->mbox_out[1];
 	QPRINTK(qdev, DRV, ERR, "Link Up.\n");
 
+	/* If we're coming back from an IDC event
+	 * then set up the CAM and frame routing.
+	 */
+	if (test_bit(QL_CAM_RT_SET, &qdev->flags)) {
+		status = ql_cam_route_initialize(qdev);
+		if (status) {
+			QPRINTK(qdev, IFUP, ERR,
+			"Failed to init CAM/Routing tables.\n");
+			return;
+		} else
+			clear_bit(QL_CAM_RT_SET, &qdev->flags);
+	}
+
+	/* Queue up a worker to check the frame
+	 * size information, and fix it if it's not
+	 * to our liking.
+	 */
+	if (!test_bit(QL_PORT_CFG, &qdev->flags)) {
+		QPRINTK(qdev, DRV, ERR, "Queue Port Config Worker!\n");
+		set_bit(QL_PORT_CFG, &qdev->flags);
+		/* Begin polled mode early so
+		 * we don't get another interrupt
+		 * when we leave mpi_worker dpc.
+		 */
+		ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16));
+		queue_delayed_work(qdev->workqueue,
+				&qdev->mpi_port_cfg_work, 0);
+	}
+
 	netif_carrier_on(qdev->ndev);
 }
 
@@ -283,6 +346,15 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		status = ql_get_mb_sts(qdev, mbcp);
 		return status;
 
+	/* We are being asked by firmware to accept
+	 * a change to the port.  This is only
+	 * a change to max frame sizes (Tx/Rx), pause
+	 * paramters, or loopback mode.
+	 */
+	case AEN_IDC_REQ:
+		status = ql_idc_req_aen(qdev);
+		break;
+
 	/* Process and inbound IDC event.
 	 * This will happen when we're trying to
 	 * change tx/rx max frame size, change pause
@@ -451,6 +523,38 @@ int ql_mb_get_fw_state(struct ql_adapter *qdev)
 	return status;
 }
 
+/* Send and ACK mailbox command to the firmware to
+ * let it continue with the change.
+ */
+int ql_mb_idc_ack(struct ql_adapter *qdev)
+{
+	struct mbox_params mbc;
+	struct mbox_params *mbcp = &mbc;
+	int status = 0;
+
+	memset(mbcp, 0, sizeof(struct mbox_params));
+
+	mbcp->in_count = 5;
+	mbcp->out_count = 1;
+
+	mbcp->mbox_in[0] = MB_CMD_IDC_ACK;
+	mbcp->mbox_in[1] = qdev->idc_mbc.mbox_out[1];
+	mbcp->mbox_in[2] = qdev->idc_mbc.mbox_out[2];
+	mbcp->mbox_in[3] = qdev->idc_mbc.mbox_out[3];
+	mbcp->mbox_in[4] = qdev->idc_mbc.mbox_out[4];
+
+	status = ql_mailbox_command(qdev, mbcp);
+	if (status)
+		return status;
+
+	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
+		QPRINTK(qdev, DRV, ERR,
+			"Failed IDC ACK send.\n");
+		status = -EIO;
+	}
+	return status;
+}
+
 /* Get link settings and maximum frame size settings
  * for the current port.
  * Most likely will block.
@@ -627,6 +731,44 @@ err:
 	goto end;
 }
 
+/* Process an inter-device request.  This is issues by
+ * the firmware in response to another function requesting
+ * a change to the port. We set a flag to indicate a change
+ * has been made and then send a mailbox command ACKing
+ * the change request.
+ */
+void ql_mpi_idc_work(struct work_struct *work)
+{
+	struct ql_adapter *qdev =
+	    container_of(work, struct ql_adapter, mpi_idc_work.work);
+	int status;
+	struct mbox_params *mbcp = &qdev->idc_mbc;
+	u32 aen;
+
+	aen = mbcp->mbox_out[1] >> 16;
+
+	switch (aen) {
+	default:
+		QPRINTK(qdev, DRV, ERR,
+			"Bug: Unhandled IDC action.\n");
+		break;
+	case MB_CMD_PORT_RESET:
+	case MB_CMD_SET_PORT_CFG:
+	case MB_CMD_STOP_FW:
+		netif_carrier_off(qdev->ndev);
+		/* Signal the resulting link up AEN
+		 * that the frame routing and mac addr
+		 * needs to be set.
+		 * */
+		set_bit(QL_CAM_RT_SET, &qdev->flags);
+		status = ql_mb_idc_ack(qdev);
+		if (status) {
+			QPRINTK(qdev, DRV, ERR,
+			"Bug: No pending IDC!\n");
+		}
+	}
+}
+
 void ql_mpi_work(struct work_struct *work)
 {
 	struct ql_adapter *qdev =
@@ -652,5 +794,6 @@ void ql_mpi_reset_work(struct work_struct *work)
 	    container_of(work, struct ql_adapter, mpi_reset_work.work);
 	cancel_delayed_work_sync(&qdev->mpi_work);
 	cancel_delayed_work_sync(&qdev->mpi_port_cfg_work);
+	cancel_delayed_work_sync(&qdev->mpi_idc_work);
 	ql_soft_reset_mpi_risc(qdev);
 }
-- 
1.6.0.2

