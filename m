From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 6/8] qlge: Add support for varied pcie function numbers.
Date: Tue,  9 Jun 2009 08:39:32 -0700
Message-ID: <1244561974-25662-6-git-send-email-ron.mercer@qlogic.com>
References: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58941 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753832AbZFIPrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 11:47:16 -0400
In-Reply-To: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we support only PCIe NIC functions zero and one, and FCoE
functions as 3 and 4. Future configurations can mix these up in any
fashion.
This patch removes the 0-1 dependancy and allows usage of any of the 4
functions. We also find the alternate NIC function (if exist) and
determine our port number based on the comparison of the two functions:
Lower function number gets first port, higher function gets second port.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |   14 ++++++++++
 drivers/net/qlge/qlge_main.c |   60 +++++++++++++++++++++++++++++++++++++----
 2 files changed, 68 insertions(+), 6 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 258ef44..5eb52ca 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -65,6 +65,17 @@
 
 #define DB_PAGE_SIZE 4096
 
+/* MPI test register definitions. This register
+ * is used for determining alternate NIC function's
+ * PCI->func number.
+ */
+enum {
+	MPI_TEST_FUNC_PORT_CFG = 0x1002,
+	MPI_TEST_NIC1_FUNC_SHIFT = 1,
+	MPI_TEST_NIC2_FUNC_SHIFT = 5,
+	MPI_TEST_NIC_FUNC_MASK = 0x00000007,
+};
+
 /*
  * Processor Address Register (PROC_ADDR) bit definitions.
  */
@@ -1432,6 +1443,8 @@ struct ql_adapter {
 	u32 chip_rev_id;
 	u32 fw_rev_id;
 	u32 func;		/* PCI function for this adapter */
+	u32 alt_func;		/* PCI function for alternate adapter */
+	u32 port;		/* Port number this adapter */
 
 	spinlock_t adapter_lock;
 	spinlock_t hw_lock;
@@ -1581,6 +1594,7 @@ void ql_mpi_idc_work(struct work_struct *work);
 void ql_mpi_port_cfg_work(struct work_struct *work);
 int ql_mb_get_fw_state(struct ql_adapter *qdev);
 int ql_cam_route_initialize(struct ql_adapter *qdev);
+int ql_read_mpi_reg(struct ql_adapter *qdev, u32 reg, u32 *data);
 int ql_mb_about_fw(struct ql_adapter *qdev);
 
 #if 1
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 738691d..d5f3628 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -679,7 +679,7 @@ static int ql_get_8000_flash_params(struct ql_adapter *qdev)
 	/* Get flash offset for function and adjust
 	 * for dword access.
 	 */
-	if (!qdev->func)
+	if (!qdev->port)
 		offset = FUNC0_FLASH_OFFSET / sizeof(u32);
 	else
 		offset = FUNC1_FLASH_OFFSET / sizeof(u32);
@@ -731,7 +731,7 @@ static int ql_get_8012_flash_params(struct ql_adapter *qdev)
 	/* Second function's parameters follow the first
 	 * function's.
 	 */
-	if (qdev->func)
+	if (qdev->port)
 		offset = size;
 
 	if (ql_sem_spinlock(qdev, SEM_FLASH_MASK))
@@ -3207,9 +3207,10 @@ static void ql_display_dev_info(struct net_device *ndev)
 	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
 
 	QPRINTK(qdev, PROBE, INFO,
-		"Function #%d, NIC Roll %d, NIC Rev = %d, "
+		"Function #%d, Port %d, NIC Roll %d, NIC Rev = %d, "
 		"XG Roll = %d, XG Rev = %d.\n",
 		qdev->func,
+		qdev->port,
 		qdev->chip_rev_id & 0x0000000f,
 		qdev->chip_rev_id >> 4 & 0x0000000f,
 		qdev->chip_rev_id >> 8 & 0x0000000f,
@@ -3664,12 +3665,53 @@ static struct nic_operations qla8000_nic_ops = {
 	.port_initialize	= ql_8000_port_initialize,
 };
 
+/* Find the pcie function number for the other NIC
+ * on this chip.  Since both NIC functions share a
+ * common firmware we have the lowest enabled function
+ * do any common work.  Examples would be resetting
+ * after a fatal firmware error, or doing a firmware
+ * coredump.
+ */
+static int ql_get_alt_pcie_func(struct ql_adapter *qdev)
+{
+	int status = 0;
+	u32 temp;
+	u32 nic_func1, nic_func2;
+
+	status = ql_read_mpi_reg(qdev, MPI_TEST_FUNC_PORT_CFG,
+			&temp);
+	if (status)
+		return status;
+
+	nic_func1 = ((temp >> MPI_TEST_NIC1_FUNC_SHIFT) &
+			MPI_TEST_NIC_FUNC_MASK);
+	nic_func2 = ((temp >> MPI_TEST_NIC2_FUNC_SHIFT) &
+			MPI_TEST_NIC_FUNC_MASK);
+
+	if (qdev->func == nic_func1)
+		qdev->alt_func = nic_func2;
+	else if (qdev->func == nic_func2)
+		qdev->alt_func = nic_func1;
+	else
+		status = -EIO;
+
+	return status;
+}
 
-static void ql_get_board_info(struct ql_adapter *qdev)
+static int ql_get_board_info(struct ql_adapter *qdev)
 {
+	int status;
 	qdev->func =
 	    (ql_read32(qdev, STS) & STS_FUNC_ID_MASK) >> STS_FUNC_ID_SHIFT;
-	if (qdev->func) {
+	if (qdev->func > 3)
+		return -EIO;
+
+	status = ql_get_alt_pcie_func(qdev);
+	if (status)
+		return status;
+
+	qdev->port = (qdev->func < qdev->alt_func) ? 0 : 1;
+	if (qdev->port) {
 		qdev->xg_sem_mask = SEM_XGMAC1_MASK;
 		qdev->port_link_up = STS_PL1;
 		qdev->port_init = STS_PI1;
@@ -3688,6 +3730,7 @@ static void ql_get_board_info(struct ql_adapter *qdev)
 		qdev->nic_ops = &qla8012_nic_ops;
 	else if (qdev->device_id == QLGE_DEVICE_ID_8000)
 		qdev->nic_ops = &qla8000_nic_ops;
+	return status;
 }
 
 static void ql_release_all(struct pci_dev *pdev)
@@ -3782,7 +3825,12 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 
 	qdev->ndev = ndev;
 	qdev->pdev = pdev;
-	ql_get_board_info(qdev);
+	err = ql_get_board_info(qdev);
+	if (err) {
+		dev_err(&pdev->dev, "Register access failed.\n");
+		err = -EIO;
+		goto err_out;
+	}
 	qdev->msg_enable = netif_msg_init(debug, default_msg);
 	spin_lock_init(&qdev->hw_lock);
 	spin_lock_init(&qdev->stats_lock);
-- 
1.6.0.2

