From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/8] qlge: Add support for retrieving firmware version.
Date: Tue,  9 Jun 2009 08:39:29 -0700
Message-ID: <1244561974-25662-3-git-send-email-ron.mercer@qlogic.com>
References: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58941 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520AbZFIPrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 11:47:14 -0400
In-Reply-To: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is used by driver banner and ethtool info.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h         |    2 ++
 drivers/net/qlge/qlge_ethtool.c |    5 ++++-
 drivers/net/qlge/qlge_main.c    |    7 +++++++
 drivers/net/qlge/qlge_mpi.c     |   34 ++++++++++++++++++++++++++++++++++
 4 files changed, 47 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index e186071..258ef44 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1430,6 +1430,7 @@ struct ql_adapter {
 
 	/* Hardware information */
 	u32 chip_rev_id;
+	u32 fw_rev_id;
 	u32 func;		/* PCI function for this adapter */
 
 	spinlock_t adapter_lock;
@@ -1580,6 +1581,7 @@ void ql_mpi_idc_work(struct work_struct *work);
 void ql_mpi_port_cfg_work(struct work_struct *work);
 int ql_mb_get_fw_state(struct ql_adapter *qdev);
 int ql_cam_route_initialize(struct ql_adapter *qdev);
+int ql_mb_about_fw(struct ql_adapter *qdev);
 
 #if 1
 #define QL_ALL_DUMP
diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index 913b2a5..ea02163 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -293,7 +293,10 @@ static void ql_get_drvinfo(struct net_device *ndev,
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	strncpy(drvinfo->driver, qlge_driver_name, 32);
 	strncpy(drvinfo->version, qlge_driver_version, 32);
-	strncpy(drvinfo->fw_version, "N/A", 32);
+	snprintf(drvinfo->fw_version, 32, "v%d.%d.%d",
+		 (qdev->fw_rev_id & 0x00ff0000) >> 16,
+		 (qdev->fw_rev_id & 0x0000ff00) >> 8,
+		 (qdev->fw_rev_id & 0x000000ff));
 	strncpy(drvinfo->bus_info, pci_name(qdev->pdev), 32);
 	drvinfo->n_stats = 0;
 	drvinfo->testinfo_len = 0;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 7c17aa2..f2e4501 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -837,6 +837,13 @@ exit:
 static int ql_8000_port_initialize(struct ql_adapter *qdev)
 {
 	int status;
+	/*
+	 * Get MPI firmware version for driver banner
+	 * and ethool info.
+	 */
+	status = ql_mb_about_fw(qdev);
+	if (status)
+		goto exit;
 	status = ql_mb_get_fw_state(qdev);
 	if (status)
 		goto exit;
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 3bd60a4..a67c14a 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -547,6 +547,40 @@ end:
 	return status;
 }
 
+
+/* Get MPI firmware version. This will be used for
+ * driver banner and for ethtool info.
+ * Returns zero on success.
+ */
+int ql_mb_about_fw(struct ql_adapter *qdev)
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
+	mbcp->mbox_in[0] = MB_CMD_ABOUT_FW;
+
+	status = ql_mailbox_command(qdev, mbcp);
+	if (status)
+		return status;
+
+	if (mbcp->mbox_out[0] != MB_CMD_STS_GOOD) {
+		QPRINTK(qdev, DRV, ERR,
+			"Failed about firmware command\n");
+		status = -EIO;
+	}
+
+	/* Store the firmware version */
+	qdev->fw_rev_id = mbcp->mbox_out[1];
+
+	return status;
+}
+
 /* Get functional state for MPI firmware.
  * Returns zero on success.
  */
-- 
1.6.0.2

