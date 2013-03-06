From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH] be2net: use CSR-BAR SEMAPHORE reg for BE2/BE3
Date: Wed, 6 Mar 2013 13:53:20 +0530
Message-ID: <eb9ec39f-6c12-4f1d-ae31-9f1e9ba76848@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:39592 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514Ab3CFIUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 03:20:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SLIPORT_SEMAPHORE register shadowed in the
config-space may not reflect the correct POST stage after
an EEH reset in BE2/3; it may return FW_READY state even though
FW is not ready. This causes the driver to prematurely
poll the FW mailbox and fail.

For BE2/3 use the CSR-BAR/0xac instead.

Reported-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c |   15 +++++++++------
 drivers/net/ethernet/emulex/benet/be_hw.h   |    4 ++--
 drivers/net/ethernet/emulex/benet/be_main.c |   10 ++++++++++
 4 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 28ceb84..29aff55 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -349,6 +349,7 @@ struct be_adapter {
 	struct pci_dev *pdev;
 	struct net_device *netdev;
 
+	u8 __iomem *csr;	/* CSR BAR used only for BE2/3 */
 	u8 __iomem *db;		/* Door Bell */
 
 	struct mutex mbox_lock; /* For serializing mbox cmds to BE card */
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 813407f..3c9b4f1 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -473,14 +473,17 @@ static int be_mbox_notify_wait(struct be_adapter *adapter)
 	return 0;
 }
 
-static void be_POST_stage_get(struct be_adapter *adapter, u16 *stage)
+static u16 be_POST_stage_get(struct be_adapter *adapter)
 {
 	u32 sem;
-	u32 reg = skyhawk_chip(adapter) ? SLIPORT_SEMAPHORE_OFFSET_SH :
-					  SLIPORT_SEMAPHORE_OFFSET_BE;
 
-	pci_read_config_dword(adapter->pdev, reg, &sem);
-	*stage = sem & POST_STAGE_MASK;
+	if (BEx_chip(adapter))
+		sem  = ioread32(adapter->csr + SLIPORT_SEMAPHORE_OFFSET_BEx);
+	else
+		pci_read_config_dword(adapter->pdev,
+				      SLIPORT_SEMAPHORE_OFFSET_SH, &sem);
+
+	return sem & POST_STAGE_MASK;
 }
 
 int lancer_wait_ready(struct be_adapter *adapter)
@@ -574,7 +577,7 @@ int be_fw_wait_ready(struct be_adapter *adapter)
 	}
 
 	do {
-		be_POST_stage_get(adapter, &stage);
+		stage = be_POST_stage_get(adapter);
 		if (stage == POST_STAGE_ARMFW_RDY)
 			return 0;
 
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index 541d453..62dc220 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -32,8 +32,8 @@
 #define MPU_EP_CONTROL 		0
 
 /********** MPU semphore: used for SH & BE  *************/
-#define SLIPORT_SEMAPHORE_OFFSET_BE		0x7c
-#define SLIPORT_SEMAPHORE_OFFSET_SH		0x94
+#define SLIPORT_SEMAPHORE_OFFSET_BEx		0xac  /* CSR BAR offset */
+#define SLIPORT_SEMAPHORE_OFFSET_SH		0x94  /* PCI-CFG offset */
 #define POST_STAGE_MASK				0x0000FFFF
 #define POST_ERR_MASK				0x1
 #define POST_ERR_SHIFT				31
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3860888..08e54f3 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3688,6 +3688,8 @@ static void be_netdev_init(struct net_device *netdev)
 
 static void be_unmap_pci_bars(struct be_adapter *adapter)
 {
+	if (adapter->csr)
+		pci_iounmap(adapter->pdev, adapter->csr);
 	if (adapter->db)
 		pci_iounmap(adapter->pdev, adapter->db);
 }
@@ -3721,6 +3723,12 @@ static int be_map_pci_bars(struct be_adapter *adapter)
 	adapter->if_type = (sli_intf & SLI_INTF_IF_TYPE_MASK) >>
 				SLI_INTF_IF_TYPE_SHIFT;
 
+	if (BEx_chip(adapter) && be_physfn(adapter)) {
+		adapter->csr = pci_iomap(adapter->pdev, 2, 0);
+		if (adapter->csr == NULL)
+			return -ENOMEM;
+	}
+
 	addr = pci_iomap(adapter->pdev, db_bar(adapter), 0);
 	if (addr == NULL)
 		goto pci_map_err;
@@ -4329,6 +4337,8 @@ static pci_ers_result_t be_eeh_reset(struct pci_dev *pdev)
 	pci_restore_state(pdev);
 
 	/* Check if card is ok and fw is ready */
+	dev_info(&adapter->pdev->dev,
+		 "Waiting for FW to be ready after EEH reset\n");
 	status = be_fw_wait_ready(adapter);
 	if (status)
 		return PCI_ERS_RESULT_DISCONNECT;
-- 
1.7.1
