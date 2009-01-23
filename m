From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 20/21] [next] qlge: Add mailbox command support.
Date: Fri, 23 Jan 2009 07:16:38 -0800
Message-ID: <1232723799-8620-20-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755161AbZAWPSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:18:14 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    4 +
 drivers/net/qlge/qlge_main.c |    4 +-
 drivers/net/qlge/qlge_mpi.c  |  273 +++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 279 insertions(+), 2 deletions(-)
 mode change 100755 => 100644 drivers/net/qlge/qlge.h

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
old mode 100755
new mode 100644
index 2f3ca60..afc9a3b
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1425,6 +1425,8 @@ struct ql_adapter {
 
 	u32 mailbox_in;
 	u32 mailbox_out;
+	struct mbox_params idc_mbc;
+	struct mutex	mpi_mutex;
 
 	int tx_ring_size;
 	int rx_ring_size;
@@ -1471,6 +1473,7 @@ struct ql_adapter {
 	struct delayed_work asic_reset_work;
 	struct delayed_work mpi_reset_work;
 	struct delayed_work mpi_work;
+	struct delayed_work mpi_idc_work;
 };
 
 /*
@@ -1538,6 +1541,7 @@ extern int ql_write_cfg(struct ql_adapter *qdev, void *ptr, int size, u32 bit,
 void ql_queue_fw_error(struct ql_adapter *qdev);
 void ql_mpi_work(struct work_struct *work);
 void ql_mpi_reset_work(struct work_struct *work);
+void ql_mpi_idc_work(struct work_struct *work);
 int ql_wait_reg_rdy(struct ql_adapter *qdev, u32 reg, u32 bit, u32 ebit);
 void ql_queue_asic_error(struct ql_adapter *qdev);
 u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr);
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index af4b64b..4110402 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2993,7 +2993,7 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 		cancel_delayed_work_sync(&qdev->asic_reset_work);
 	cancel_delayed_work_sync(&qdev->mpi_reset_work);
 	cancel_delayed_work_sync(&qdev->mpi_work);
-
+	cancel_delayed_work_sync(&qdev->mpi_idc_work);
 	/* The default queue at index 0 is always processed in
 	 * a workqueue.
 	 */
@@ -3549,6 +3549,8 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	INIT_DELAYED_WORK(&qdev->asic_reset_work, ql_asic_reset_work);
 	INIT_DELAYED_WORK(&qdev->mpi_reset_work, ql_mpi_reset_work);
 	INIT_DELAYED_WORK(&qdev->mpi_work, ql_mpi_work);
+	INIT_DELAYED_WORK(&qdev->mpi_idc_work, ql_mpi_idc_work);
+	mutex_init(&qdev->mpi_mutex);
 
 	if (!cards_found) {
 		dev_info(&pdev->dev, "%s\n", DRV_STRING);
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 4e336ef..f2f77c6 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -1,5 +1,25 @@
 #include "qlge.h"
 
+static void ql_display_mb_sts(struct ql_adapter *qdev,
+						struct mbox_params *mbcp)
+{
+	int i;
+	static char *err_sts[] = {
+		"Command Complete",
+		"Command Not Supported",
+		"Host Interface Error",
+		"Checksum Error",
+		"Unused Completion Status",
+		"Test Failed",
+		"Command Parameter Error"};
+
+	QPRINTK(qdev, DRV, ERR, "%s.\n",
+		err_sts[mbcp->mbox_out[0] & 0x0000000f]);
+	for (i = 0; i < mbcp->out_count; i++)
+		QPRINTK(qdev, DRV, ERR, "mbox_out[%d] = 0x%.08x.\n",
+				i, mbcp->mbox_out[i]);
+}
+
 static int ql_read_mpi_reg(struct ql_adapter *qdev, u32 reg, u32 *data)
 {
 	int status;
@@ -70,6 +90,95 @@ static int ql_get_mb_sts(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	return status;
 }
 
+/*
+ * Returns zero on success.
+ */
+static int ql_wait_mbx_cmd_cmplt(struct ql_adapter *qdev)
+{
+	int count = 50;	/* TODO: arbitrary for now. */
+	u32 value;
+
+	do {
+		value = ql_read32(qdev, STS);
+		if (value & STS_PI)
+			return 0;
+		mdelay(UDELAY_DELAY); /* 10ms */
+		if (!(count%10))
+			QPRINTK(qdev, DRV, DEBUG,
+				"Waiting for mailbox command to complete.\n");
+	} while (--count);
+	return -ETIMEDOUT;
+}
+
+/* Caller must hold PROC_ADDR semaphore */
+static int ql_exec_mb_cmd(struct ql_adapter *qdev, struct mbox_params *mbcp)
+{
+	int i, status;
+
+	/*
+	 * Make sure there's nothing pending.
+	 * This shouldn't happen.
+	 */
+	if (ql_read32(qdev, CSR) & CSR_HRI) {
+		QPRINTK(qdev, DRV, ERR,
+			"%s: CSR_HRI bit set in CSR. Should never happen!\n",
+			__func__);
+		return -EIO;
+	}
+
+	status = ql_sem_spinlock(qdev, SEM_PROC_REG_MASK);
+	if (status) {
+		QPRINTK(qdev, DRV, ERR,
+			"%s: Couldn't get PROC_ADDR semaphore.\n", __func__);
+		return status;
+	}
+
+	/*
+	 * Fill the outbound mailboxes.
+	 */
+	for (i = 0; i < mbcp->in_count; i++) {
+		status = ql_write_mpi_reg(qdev, qdev->mailbox_in + i,
+				       mbcp->mbox_in[i]);
+		if (status)
+			goto end;
+	}
+	/*
+	 * Wake up the MPI firmware.
+	 */
+	ql_write32(qdev, CSR, CSR_CMD_SET_H2R_INT);
+end:
+	ql_sem_unlock(qdev, SEM_PROC_REG_MASK);
+	return status;
+}
+
+/* MPI Async Event handlers. */
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
 static void ql_link_up(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
 	int status = 0;
@@ -187,6 +296,7 @@ static void ql_init_fw_done(struct ql_adapter *qdev, struct mbox_params *mbcp)
 static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
 	int status;
+	int orig_count = mbcp->out_count;
 
 	/* Just get mailbox zero for now. */
 	mbcp->out_count = 1;
@@ -200,6 +310,27 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 
 	switch (mbcp->mbox_out[0]) {
 
+	case MB_CMD_STS_INTRMDT:
+	case MB_CMD_STS_GOOD:
+	case MB_CMD_STS_INVLD_CMD:
+	case MB_CMD_STS_XFC_ERR:
+	case MB_CMD_STS_CSUM_ERR:
+	case MB_CMD_STS_ERR:
+	case MB_CMD_STS_PARAM_ERR:
+		/* We can only get mailbox status if we're polling from an
+		 * unfinished command.  Get the rest of the status data and
+		 * return back to the caller.
+		 * We only end up here when we're polling for a mailbox
+		 * command completion.
+		 */
+		mbcp->out_count = orig_count;
+		status = ql_get_mb_sts(qdev, mbcp);
+		return status;
+
+	case AEN_IDC_REQ:
+		status = ql_idc_req_aen(qdev);
+		break;
+
 	case AEN_LINK_UP:
 		ql_link_up(qdev, mbcp);
 		break;
@@ -226,7 +357,6 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 
 	case AEN_FW_INIT_FAIL:
 	case AEN_SYS_ERR:
-	case MB_CMD_STS_ERR:
 	default:
 		ql_queue_fw_error(qdev);
 		QPRINTK(qdev, DRV, ERR,
@@ -238,6 +368,145 @@ end:
 	return status;
 }
 
+static int ql_mailbox_command(struct ql_adapter *qdev, struct mbox_params *mbcp)
+{
+	int status, count;
+
+	mutex_lock(&qdev->mpi_mutex);
+
+	/* Begin polled mode for MPI */
+	ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16));
+
+	/* Load the mailbox registers and wake up MPI RISC. */
+	status = ql_exec_mb_cmd(qdev, mbcp);
+	if (status)
+		goto end;
+
+
+	/* If we're generating a system error, then there's nothing
+	 * to wait for.
+	 */
+	if (mbcp->mbox_in[0] == MB_CMD_MAKE_SYS_ERR)
+		goto end;
+
+	/* Wait for the command to complete. We loop
+	 * here because some AEN might arrive while
+	 * we're waiting for the mailbox command to
+	 * complete. If more than 5 arrive then we can
+	 * assume something is wrong. */
+	count = 5;
+	do {
+		/* Wait for the interrupt to come in. */
+		status = ql_wait_mbx_cmd_cmplt(qdev);
+		if (status) {
+			QPRINTK(qdev, DRV, ERR,
+				"Failed ql_wait_mbx_cmd_cmplt(),"
+				" status = %d.\n",
+				status);
+			goto end;
+		}
+
+		/* Process the event.  If it's an AEN, it
+		 * will be handled in-line or a worker
+		 * will be spawned. If it's our completion
+		 * we will catch it below.
+		 */
+		status = ql_mpi_handler(qdev, mbcp);
+		if (status) {
+			QPRINTK(qdev, DRV, ERR,
+				"Failed ql_mpi_hander(), status = %d.\n",
+				status);
+			goto end;
+		}
+
+		/* It's either the completion for our mailbox
+		 * command complete or an AEN.  If it's our
+		 * completion then get out.
+		 */
+		if ((mbcp->mbox_out[0] & 0x0000f000) ==
+					0x00004000)
+			break;
+	} while (--count);
+
+	if (!count) {
+		QPRINTK(qdev, DRV, ERR,
+			"Timed out waiting for mailbox complet.\n");
+		status = -ETIMEDOUT;
+		goto end;
+	}
+
+	/* Now we can clear the interrupt condition
+	 * and look at our status.
+	 */
+	ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
+
+	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
+		ql_display_mb_sts(qdev, mbcp);
+		status = -EIO;
+	}
+end:
+	mutex_unlock(&qdev->mpi_mutex);
+	/* End polled mode for MPI */
+	ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16) | INTR_MASK_PI);
+	return status;
+}
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
+		ql_link_off(qdev);
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
@@ -245,12 +514,14 @@ void ql_mpi_work(struct work_struct *work)
 	struct mbox_params mbc;
 	struct mbox_params *mbcp = &mbc;
 
+	mutex_lock(&qdev->mpi_mutex);
 	while (ql_read32(qdev, STS) & STS_PI) {
 		memset(mbcp, 0, sizeof(struct mbox_params));
 		mbcp->out_count = 1;
 		ql_mpi_handler(qdev, mbcp);
 	}
 
+	mutex_unlock(&qdev->mpi_mutex);
 	ql_enable_completion_interrupt(qdev, 0);
 }
 
-- 
1.6.0.2

