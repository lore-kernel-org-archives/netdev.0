From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 4/5] [net-next] qlge: Prepare to add new device.
Date: Thu, 26 Feb 2009 12:08:35 -0800
Message-ID: <1235678916-2856-4-git-send-email-ron.mercer@qlogic.com>
References: <20090226200746.GA23769@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:10180 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753673AbZBZULz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 15:11:55 -0500
In-Reply-To: <20090226200746.GA23769@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This organizes a few calls into a function table to enable adding new
devices.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |   17 +++++++--
 drivers/net/qlge/qlge_main.c |   80 +++++++++++++++++++++++++++++++++--------
 2 files changed, 78 insertions(+), 19 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 2103fe6..7bf18c6 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -28,7 +28,7 @@
        } while (0)
 
 #define QLGE_VENDOR_ID    0x1077
-#define QLGE_DEVICE_ID    0x8012
+#define QLGE_DEVICE_ID_8012	0x8012
 
 #define MAX_CPUS 8
 #define MAX_TX_RINGS MAX_CPUS
@@ -798,7 +798,7 @@ struct mbox_params {
 	int out_count;
 };
 
-struct flash_params {
+struct flash_params_8012 {
 	u8 dev_id_str[4];
 	__le16 size;
 	__le16 csum;
@@ -808,6 +808,9 @@ struct flash_params {
 	__le16 res;
 };
 
+union flash_params {
+	struct flash_params_8012 flash_params_8012;
+};
 
 /*
  * doorbell space for the rx ring context
@@ -1367,6 +1370,12 @@ enum {
 	CFG_DEFAULT_MAX_FRAME_SIZE = 0x00002580,
 };
 
+struct nic_operations {
+
+	int (*get_flash) (struct ql_adapter *);
+	int (*port_initialize) (struct ql_adapter *);
+};
+
 /*
  * The main Adapter structure definition.
  * This structure has all fields relevant to the hardware.
@@ -1444,7 +1453,7 @@ struct ql_adapter {
 	u32 port_init;
 	u32 link_status;
 
-	struct flash_params flash;
+	union flash_params flash;
 
 	struct net_device_stats stats;
 	struct workqueue_struct *q_workqueue;
@@ -1452,6 +1461,8 @@ struct ql_adapter {
 	struct delayed_work asic_reset_work;
 	struct delayed_work mpi_reset_work;
 	struct delayed_work mpi_work;
+	struct nic_operations *nic_ops;
+	u16 device_id;
 };
 
 /*
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index b144b6b..d1d8f05 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -75,7 +75,7 @@ module_param(irq_type, int, MSIX_IRQ);
 MODULE_PARM_DESC(irq_type, "0 = MSI-X, 1 = MSI, 2 = Legacy.");
 
 static struct pci_device_id qlge_pci_tbl[] __devinitdata = {
-	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID)},
+	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID_8012)},
 	/* required last entry */
 	{0,}
 };
@@ -623,6 +623,28 @@ static void ql_enable_all_completion_interrupts(struct ql_adapter *qdev)
 
 }
 
+static int ql_validate_flash(struct ql_adapter *qdev, u32 size, const char *str)
+{
+	int status, i;
+	u16 csum = 0;
+	__le16 *flash = (__le16 *)&qdev->flash;
+
+	status = strncmp((char *)&qdev->flash, str, 4);
+	if (status) {
+		QPRINTK(qdev, IFUP, ERR, "Invalid flash signature.\n");
+		return	status;
+	}
+
+	for (i = 0; i < size; i++)
+		csum += le16_to_cpu(*flash++);
+
+	if (csum)
+		QPRINTK(qdev, IFUP, ERR,
+			"Invalid flash checksum, csum = 0x%.04x.\n", csum);
+
+	return csum;
+}
+
 static int ql_read_flash_word(struct ql_adapter *qdev, int offset, __le32 *data)
 {
 	int status = 0;
@@ -647,23 +669,24 @@ exit:
 	return status;
 }
 
-static int ql_get_flash_params(struct ql_adapter *qdev)
+static int ql_get_8012_flash_params(struct ql_adapter *qdev)
 {
 	int i;
 	int status;
 	__le32 *p = (__le32 *)&qdev->flash;
 	u32 offset = 0;
+	u32 size = sizeof(struct flash_params_8012) / sizeof(u32);
 
 	/* Second function's parameters follow the first
 	 * function's.
 	 */
 	if (qdev->func)
-		offset = sizeof(qdev->flash) / sizeof(u32);
+		offset = size;
 
 	if (ql_sem_spinlock(qdev, SEM_FLASH_MASK))
 		return -ETIMEDOUT;
 
-	for (i = 0; i < sizeof(qdev->flash) / sizeof(u32); i++, p++) {
+	for (i = 0; i < size; i++, p++) {
 		status = ql_read_flash_word(qdev, i+offset, p);
 		if (status) {
 			QPRINTK(qdev, IFUP, ERR, "Error reading flash.\n");
@@ -671,6 +694,25 @@ static int ql_get_flash_params(struct ql_adapter *qdev)
 		}
 
 	}
+
+	status = ql_validate_flash(qdev,
+			sizeof(struct flash_params_8012) / sizeof(u16),
+			"8012");
+	if (status) {
+		QPRINTK(qdev, IFUP, ERR, "Invalid flash.\n");
+		status = -EINVAL;
+		goto exit;
+	}
+
+	if (!is_valid_ether_addr(qdev->flash.flash_params_8012.mac_addr)) {
+		status = -EINVAL;
+		goto exit;
+	}
+
+	memcpy(qdev->ndev->dev_addr,
+		qdev->flash.flash_params_8012.mac_addr,
+		qdev->ndev->addr_len);
+
 exit:
 	ql_sem_unlock(qdev, SEM_FLASH_MASK);
 	return status;
@@ -747,7 +789,7 @@ exit:
  * This functionality may be done in the MPI firmware at a
  * later date.
  */
-static int ql_port_initialize(struct ql_adapter *qdev)
+static int ql_8012_port_initialize(struct ql_adapter *qdev)
 {
 	int status = 0;
 	u32 data;
@@ -2994,11 +3036,12 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 		}
 	}
 
-	status = ql_port_initialize(qdev);
-	if (status) {
-		QPRINTK(qdev, IFUP, ERR, "Failed to start port.\n");
-		return status;
-	}
+	/* Initialize the port and set the max framesize. */
+	status = qdev->nic_ops->port_initialize(qdev);
+       if (status) {
+              QPRINTK(qdev, IFUP, ERR, "Failed to start port.\n");
+              return status;
+       }
 
 	/* Set up the MAC address and frame routing filter. */
 	status = ql_cam_route_initialize(qdev);
@@ -3509,6 +3552,12 @@ static void ql_asic_reset_work(struct work_struct *work)
 	ql_cycle_adapter(qdev);
 }
 
+static struct nic_operations qla8012_nic_ops = {
+	.get_flash		= ql_get_8012_flash_params,
+	.port_initialize	= ql_8012_port_initialize,
+};
+
+
 static void ql_get_board_info(struct ql_adapter *qdev)
 {
 	qdev->func =
@@ -3527,6 +3576,9 @@ static void ql_get_board_info(struct ql_adapter *qdev)
 		qdev->mailbox_out = PROC_ADDR_MPI_RISC | PROC_ADDR_FUNC0_MBO;
 	}
 	qdev->chip_rev_id = ql_read32(qdev, REV_ID);
+	qdev->device_id = qdev->pdev->device;
+	if (qdev->device_id == QLGE_DEVICE_ID_8012)
+		qdev->nic_ops = &qla8012_nic_ops;
 }
 
 static void ql_release_all(struct pci_dev *pdev)
@@ -3619,24 +3671,20 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 		goto err_out;
 	}
 
-	ql_get_board_info(qdev);
 	qdev->ndev = ndev;
 	qdev->pdev = pdev;
+	ql_get_board_info(qdev);
 	qdev->msg_enable = netif_msg_init(debug, default_msg);
 	spin_lock_init(&qdev->hw_lock);
 	spin_lock_init(&qdev->stats_lock);
 
 	/* make sure the EEPROM is good */
-	err = ql_get_flash_params(qdev);
+	err = qdev->nic_ops->get_flash(qdev);
 	if (err) {
 		dev_err(&pdev->dev, "Invalid FLASH.\n");
 		goto err_out;
 	}
 
-	if (!is_valid_ether_addr(qdev->flash.mac_addr))
-		goto err_out;
-
-	memcpy(ndev->dev_addr, qdev->flash.mac_addr, ndev->addr_len);
 	memcpy(ndev->perm_addr, ndev->dev_addr, ndev->addr_len);
 
 	/* Set up the default ring sizes. */
-- 
1.6.0.2

