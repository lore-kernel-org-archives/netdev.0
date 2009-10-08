From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 5/7] qlge: Fix chip reset process.
Date: Thu,  8 Oct 2009 12:54:41 -0700
Message-ID: <1255031683-3912-6-git-send-email-ron.mercer@qlogic.com>
References: <1255031683-3912-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:40572 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933357AbZJHUCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 16:02:49 -0400
In-Reply-To: <1255031683-3912-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add wait for NIC fifo and MGMNT fifo to empty before applying reset.
Otherwise broken frames can be processed by management processor and
cause it to hang.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    8 ++++
 drivers/net/qlge/qlge_main.c |    9 ++++
 drivers/net/qlge/qlge_mpi.c  |   89 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 106 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 567b5d6..e7285f0 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -803,6 +803,12 @@ enum {
 	MB_CMD_SET_PORT_CFG = 0x00000122,
 	MB_CMD_GET_PORT_CFG = 0x00000123,
 	MB_CMD_GET_LINK_STS = 0x00000124,
+	MB_CMD_SET_MGMNT_TFK_CTL = 0x00000160, /* Set Mgmnt Traffic Control */
+	MB_SET_MPI_TFK_STOP = (1 << 0),
+	MB_SET_MPI_TFK_RESUME = (1 << 1),
+	MB_CMD_GET_MGMNT_TFK_CTL = 0x00000161, /* Get Mgmnt Traffic Control */
+	MB_GET_MPI_TFK_STOPPED = (1 << 0),
+	MB_GET_MPI_TFK_FIFO_EMPTY = (1 << 1),
 
 	/* Mailbox Command Status. */
 	MB_CMD_STS_GOOD = 0x00004000,	/* Success. */
@@ -1606,6 +1612,8 @@ int ql_read_mpi_reg(struct ql_adapter *qdev, u32 reg, u32 *data);
 int ql_mb_about_fw(struct ql_adapter *qdev);
 void ql_link_on(struct ql_adapter *qdev);
 void ql_link_off(struct ql_adapter *qdev);
+int ql_mb_set_mgmnt_traffic_ctl(struct ql_adapter *qdev, u32 control);
+int ql_wait_fifo_empty(struct ql_adapter *qdev);
 
 #if 1
 #define QL_ALL_DUMP
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index e1203bf..fe13006 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3349,6 +3349,13 @@ static int ql_adapter_reset(struct ql_adapter *qdev)
 
 	end_jiffies = jiffies +
 		max((unsigned long)1, usecs_to_jiffies(30));
+
+	/* Stop management traffic. */
+	ql_mb_set_mgmnt_traffic_ctl(qdev, MB_SET_MPI_TFK_STOP);
+
+	/* Wait for the NIC and MGMNT FIFOs to empty. */
+	ql_wait_fifo_empty(qdev);
+
 	ql_write32(qdev, RST_FO, (RST_FO_FR << 16) | RST_FO_FR);
 
 	do {
@@ -3364,6 +3371,8 @@ static int ql_adapter_reset(struct ql_adapter *qdev)
 		status = -ETIMEDOUT;
 	}
 
+	/* Resume management traffic. */
+	ql_mb_set_mgmnt_traffic_ctl(qdev, MB_SET_MPI_TFK_RESUME);
 	return status;
 }
 
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index c2e4307..8810f5b 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -768,6 +768,95 @@ static int ql_idc_wait(struct ql_adapter *qdev)
 	return status;
 }
 
+int ql_mb_set_mgmnt_traffic_ctl(struct ql_adapter *qdev, u32 control)
+{
+	struct mbox_params mbc;
+	struct mbox_params *mbcp = &mbc;
+	int status;
+
+	memset(mbcp, 0, sizeof(struct mbox_params));
+
+	mbcp->in_count = 1;
+	mbcp->out_count = 2;
+
+	mbcp->mbox_in[0] = MB_CMD_SET_MGMNT_TFK_CTL;
+	mbcp->mbox_in[1] = control;
+
+	status = ql_mailbox_command(qdev, mbcp);
+	if (status)
+		return status;
+
+	if (mbcp->mbox_out[0] == MB_CMD_STS_GOOD)
+		return status;
+
+	if (mbcp->mbox_out[0] == MB_CMD_STS_INVLD_CMD) {
+		QPRINTK(qdev, DRV, ERR,
+			"Command not supported by firmware.\n");
+		status = -EINVAL;
+	} else if (mbcp->mbox_out[0] == MB_CMD_STS_ERR) {
+		/* This indicates that the firmware is
+		 * already in the state we are trying to
+		 * change it to.
+		 */
+		QPRINTK(qdev, DRV, ERR,
+			"Command parameters make no change.\n");
+	}
+	return status;
+}
+
+/* Returns a negative error code or the mailbox command status. */
+static int ql_mb_get_mgmnt_traffic_ctl(struct ql_adapter *qdev, u32 *control)
+{
+	struct mbox_params mbc;
+	struct mbox_params *mbcp = &mbc;
+	int status;
+
+	memset(mbcp, 0, sizeof(struct mbox_params));
+	*control = 0;
+
+	mbcp->in_count = 1;
+	mbcp->out_count = 1;
+
+	mbcp->mbox_in[0] = MB_CMD_GET_MGMNT_TFK_CTL;
+
+	status = ql_mailbox_command(qdev, mbcp);
+	if (status)
+		return status;
+
+	if (mbcp->mbox_out[0] == MB_CMD_STS_GOOD) {
+		*control = mbcp->mbox_in[1];
+		return status;
+	}
+
+	if (mbcp->mbox_out[0] == MB_CMD_STS_INVLD_CMD) {
+		QPRINTK(qdev, DRV, ERR,
+			"Command not supported by firmware.\n");
+		status = -EINVAL;
+	} else if (mbcp->mbox_out[0] == MB_CMD_STS_ERR) {
+		QPRINTK(qdev, DRV, ERR,
+			"Failed to get MPI traffic control.\n");
+		status = -EIO;
+	}
+	return status;
+}
+
+int ql_wait_fifo_empty(struct ql_adapter *qdev)
+{
+	int count = 5;
+	u32 mgmnt_fifo_empty;
+	u32 nic_fifo_empty;
+
+	do {
+		nic_fifo_empty = ql_read32(qdev, STS) & STS_NFE;
+		ql_mb_get_mgmnt_traffic_ctl(qdev, &mgmnt_fifo_empty);
+		mgmnt_fifo_empty &= MB_GET_MPI_TFK_FIFO_EMPTY;
+		if (nic_fifo_empty && mgmnt_fifo_empty)
+			return 0;
+		msleep(100);
+	} while (count-- > 0);
+	return -ETIMEDOUT;
+}
+
 /* API called in work thread context to set new TX/RX
  * maximum frame size values to match MTU.
  */
-- 
1.6.0.2

