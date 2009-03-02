From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/3] qlge: Add support for device ID 8000.
Date: Mon,  2 Mar 2009 10:07:31 -0800
Message-ID: <1236017252-6867-3-git-send-email-ron.mercer@qlogic.com>
References: <1236017252-6867-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:2875 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbZCBSKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 13:10:47 -0500
In-Reply-To: <1236017252-6867-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This device has more firmware support for link management, setting
TX and RX maximum frame sizes.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |   37 +++++++++++++++++++++++-
 drivers/net/qlge/qlge_main.c |   64 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 100 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 7bf18c6..5f60ec4 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -29,7 +29,7 @@
 
 #define QLGE_VENDOR_ID    0x1077
 #define QLGE_DEVICE_ID_8012	0x8012
-
+#define QLGE_DEVICE_ID_8000	0x8000
 #define MAX_CPUS 8
 #define MAX_TX_RINGS MAX_CPUS
 #define MAX_RX_RINGS ((MAX_CPUS * 2) + 1)
@@ -808,8 +808,42 @@ struct flash_params_8012 {
 	__le16 res;
 };
 
+/* 8000 device's flash is a different structure
+ * at a different offset in flash.
+ */
+#define FUNC0_FLASH_OFFSET 0x140200
+#define FUNC1_FLASH_OFFSET 0x140600
+
+/* Flash related data structures. */
+struct flash_params_8000 {
+	u8 dev_id_str[4];	/* "8000" */
+	__le16 ver;
+	__le16 size;
+	__le16 csum;
+	__le16 reserved0;
+	__le16 total_size;
+	__le16 entry_count;
+	u8 data_type0;
+	u8 data_size0;
+	u8 mac_addr[6];
+	u8 data_type1;
+	u8 data_size1;
+	u8 mac_addr1[6];
+	u8 data_type2;
+	u8 data_size2;
+	__le16 vlan_id;
+	u8 data_type3;
+	u8 data_size3;
+	__le16 last;
+	u8 reserved1[464];
+	__le16	subsys_ven_id;
+	__le16	subsys_dev_id;
+	u8 reserved2[4];
+};
+
 union flash_params {
 	struct flash_params_8012 flash_params_8012;
+	struct flash_params_8000 flash_params_8000;
 };
 
 /*
@@ -1535,6 +1569,7 @@ void ql_queue_asic_error(struct ql_adapter *qdev);
 u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr);
 void ql_set_ethtool_ops(struct net_device *ndev);
 int ql_read_xgmac_reg64(struct ql_adapter *qdev, u32 reg, u64 *data);
+int ql_mb_get_fw_state(struct ql_adapter *qdev);
 
 #if 1
 #define QL_ALL_DUMP
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index b4c6fd7..29334d9 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -76,6 +76,7 @@ MODULE_PARM_DESC(irq_type, "0 = MSI-X, 1 = MSI, 2 = Legacy.");
 
 static struct pci_device_id qlge_pci_tbl[] __devinitdata = {
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID_8012)},
+	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID_8000)},
 	/* required last entry */
 	{0,}
 };
@@ -669,6 +670,57 @@ exit:
 	return status;
 }
 
+static int ql_get_8000_flash_params(struct ql_adapter *qdev)
+{
+	u32 i, size;
+	int status;
+	__le32 *p = (__le32 *)&qdev->flash;
+	u32 offset;
+
+	/* Get flash offset for function and adjust
+	 * for dword access.
+	 */
+	if (!qdev->func)
+		offset = FUNC0_FLASH_OFFSET / sizeof(u32);
+	else
+		offset = FUNC1_FLASH_OFFSET / sizeof(u32);
+
+	if (ql_sem_spinlock(qdev, SEM_FLASH_MASK))
+		return -ETIMEDOUT;
+
+	size = sizeof(struct flash_params_8000) / sizeof(u32);
+	for (i = 0; i < size; i++, p++) {
+		status = ql_read_flash_word(qdev, i+offset, p);
+		if (status) {
+			QPRINTK(qdev, IFUP, ERR, "Error reading flash.\n");
+			goto exit;
+		}
+	}
+
+	status = ql_validate_flash(qdev,
+			sizeof(struct flash_params_8000) / sizeof(u16),
+			"8000");
+	if (status) {
+		QPRINTK(qdev, IFUP, ERR, "Invalid flash.\n");
+		status = -EINVAL;
+		goto exit;
+	}
+
+	if (!is_valid_ether_addr(qdev->flash.flash_params_8000.mac_addr)) {
+		QPRINTK(qdev, IFUP, ERR, "Invalid MAC address.\n");
+		status = -EINVAL;
+		goto exit;
+	}
+
+	memcpy(qdev->ndev->dev_addr,
+		qdev->flash.flash_params_8000.mac_addr,
+		qdev->ndev->addr_len);
+
+exit:
+	ql_sem_unlock(qdev, SEM_FLASH_MASK);
+	return status;
+}
+
 static int ql_get_8012_flash_params(struct ql_adapter *qdev)
 {
 	int i;
@@ -783,6 +835,11 @@ exit:
 	return status;
 }
 
+static int ql_8000_port_initialize(struct ql_adapter *qdev)
+{
+	return ql_mb_get_fw_state(qdev);
+}
+
 /* Take the MAC Core out of reset.
  * Enable statistics counting.
  * Take the transmitter/receiver out of reset.
@@ -3557,6 +3614,11 @@ static struct nic_operations qla8012_nic_ops = {
 	.port_initialize	= ql_8012_port_initialize,
 };
 
+static struct nic_operations qla8000_nic_ops = {
+	.get_flash		= ql_get_8000_flash_params,
+	.port_initialize	= ql_8000_port_initialize,
+};
+
 
 static void ql_get_board_info(struct ql_adapter *qdev)
 {
@@ -3579,6 +3641,8 @@ static void ql_get_board_info(struct ql_adapter *qdev)
 	qdev->device_id = qdev->pdev->device;
 	if (qdev->device_id == QLGE_DEVICE_ID_8012)
 		qdev->nic_ops = &qla8012_nic_ops;
+	else if (qdev->device_id == QLGE_DEVICE_ID_8000)
+		qdev->nic_ops = &qla8000_nic_ops;
 }
 
 static void ql_release_all(struct pci_dev *pdev)
-- 
1.6.0.2

