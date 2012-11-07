From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 5/7] be2net: fix access to SEMAPHORE reg
Date: Wed, 7 Nov 2012 09:18:59 +0530
Message-ID: <f12190a7-bc6f-4faf-b4e2-25d4fb63a5ab@CMEXHTCAS2.ad.emulex.com>
References: <1352260141-27725-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:25378 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876Ab2KGDqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 22:46:20 -0500
In-Reply-To: <1352260141-27725-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SEMAPHORE register was being accessed from the csr BAR space. This BAR
may not be available in some Skyhawk-R configurations. Instead, access this
register via the PCI config space (it's available there too).

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 -
 drivers/net/ethernet/emulex/benet/be_cmds.c |   11 +++++------
 drivers/net/ethernet/emulex/benet/be_hw.h   |   12 ++++++------
 drivers/net/ethernet/emulex/benet/be_main.c |    9 ---------
 4 files changed, 11 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 26b9b8b..e391d5a 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -348,7 +348,6 @@ struct be_adapter {
 	struct pci_dev *pdev;
 	struct net_device *netdev;
 
-	u8 __iomem *csr;
 	u8 __iomem *db;		/* Door Bell */
 
 	struct mutex mbox_lock; /* For serializing mbox cmds to BE card */
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 1768cfa..f2875aa 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -468,14 +468,13 @@ static int be_mbox_notify_wait(struct be_adapter *adapter)
 static int be_POST_stage_get(struct be_adapter *adapter, u16 *stage)
 {
 	u32 sem;
+	u32 reg = skyhawk_chip(adapter) ? SLIPORT_SEMAPHORE_OFFSET_SH :
+					  SLIPORT_SEMAPHORE_OFFSET_BE;
 
-	if (lancer_chip(adapter))
-		sem  = ioread32(adapter->db + MPU_EP_SEMAPHORE_IF_TYPE2_OFFSET);
-	else
-		sem  = ioread32(adapter->csr + MPU_EP_SEMAPHORE_OFFSET);
+	pci_read_config_dword(adapter->pdev, reg, &sem);
+	*stage = sem & POST_STAGE_MASK;
 
-	*stage = sem & EP_SEMAPHORE_POST_STAGE_MASK;
-	if ((sem >> EP_SEMAPHORE_POST_ERR_SHIFT) & EP_SEMAPHORE_POST_ERR_MASK)
+	if ((sem >> POST_ERR_SHIFT) & POST_ERR_MASK)
 		return -1;
 	else
 		return 0;
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index c257207..541d453 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -31,12 +31,12 @@
 
 #define MPU_EP_CONTROL 		0
 
-/********** MPU semphore ******************/
-#define MPU_EP_SEMAPHORE_OFFSET		0xac
-#define MPU_EP_SEMAPHORE_IF_TYPE2_OFFSET	0x400
-#define EP_SEMAPHORE_POST_STAGE_MASK		0x0000FFFF
-#define EP_SEMAPHORE_POST_ERR_MASK		0x1
-#define EP_SEMAPHORE_POST_ERR_SHIFT		31
+/********** MPU semphore: used for SH & BE  *************/
+#define SLIPORT_SEMAPHORE_OFFSET_BE		0x7c
+#define SLIPORT_SEMAPHORE_OFFSET_SH		0x94
+#define POST_STAGE_MASK				0x0000FFFF
+#define POST_ERR_MASK				0x1
+#define POST_ERR_SHIFT				31
 
 /* MPU semphore POST stage values */
 #define POST_STAGE_AWAITING_HOST_RDY 	0x1 /* FW awaiting goahead from host */
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 95e279f..5c475cc 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3619,8 +3619,6 @@ static void be_netdev_init(struct net_device *netdev)
 
 static void be_unmap_pci_bars(struct be_adapter *adapter)
 {
-	if (adapter->csr)
-		pci_iounmap(adapter->pdev, adapter->csr);
 	if (adapter->db)
 		pci_iounmap(adapter->pdev, adapter->db);
 	if (adapter->roce_db.base)
@@ -3668,13 +3666,6 @@ static int be_map_pci_bars(struct be_adapter *adapter)
 	adapter->if_type = (sli_intf & SLI_INTF_IF_TYPE_MASK) >>
 				SLI_INTF_IF_TYPE_SHIFT;
 
-	if (be_physfn(adapter) && !lancer_chip(adapter)) {
-		addr = pci_iomap(adapter->pdev, 2, 0);
-		if (addr == NULL)
-			return -ENOMEM;
-		adapter->csr = addr;
-	}
-
 	addr = pci_iomap(adapter->pdev, db_bar(adapter), 0);
 	if (addr == NULL)
 		goto pci_map_err;
-- 
1.7.1
