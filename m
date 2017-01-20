From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 1/2] amd-xgbe: Add a hardware quirk for register
 definitions
Date: Fri, 20 Jan 2017 12:14:03 -0600
Message-ID: <20170120181403.2321.30449.stgit@tlendack-t1.amdoffice.net>
References: <20170120181352.2321.63733.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0079.outbound.protection.outlook.com ([104.47.41.79]:64282
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752219AbdATSOJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 13:14:09 -0500
In-Reply-To: <20170120181352.2321.63733.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A newer version of the hardware is using the same PCI ids for the network
device but has altered register definitions for determining the window
settings for the indirect PCS access.  Add support to check for this
hardware and if found use the new register values.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-common.h |    2 ++
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c    |    4 ++--
 drivers/net/ethernet/amd/xgbe/xgbe-pci.c    |   15 ++++++++++++++-
 drivers/net/ethernet/amd/xgbe/xgbe.h        |    2 ++
 4 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index 5b7ba25..8a280e7 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -891,6 +891,8 @@
 #define PCS_V1_WINDOW_SELECT		0x03fc
 #define PCS_V2_WINDOW_DEF		0x9060
 #define PCS_V2_WINDOW_SELECT		0x9064
+#define PCS_V2_RV_WINDOW_DEF		0x1060
+#define PCS_V2_RV_WINDOW_SELECT		0x1064
 
 /* PCS register entry bit positions and sizes */
 #define PCS_V2_WINDOW_DEF_OFFSET_INDEX	6
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index aaf0350..c8e8a4a 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1151,7 +1151,7 @@ static int xgbe_read_mmd_regs_v2(struct xgbe_prv_data *pdata, int prtad,
 	offset = pdata->xpcs_window + (mmd_address & pdata->xpcs_window_mask);
 
 	spin_lock_irqsave(&pdata->xpcs_lock, flags);
-	XPCS32_IOWRITE(pdata, PCS_V2_WINDOW_SELECT, index);
+	XPCS32_IOWRITE(pdata, pdata->xpcs_window_sel_reg, index);
 	mmd_data = XPCS16_IOREAD(pdata, offset);
 	spin_unlock_irqrestore(&pdata->xpcs_lock, flags);
 
@@ -1183,7 +1183,7 @@ static void xgbe_write_mmd_regs_v2(struct xgbe_prv_data *pdata, int prtad,
 	offset = pdata->xpcs_window + (mmd_address & pdata->xpcs_window_mask);
 
 	spin_lock_irqsave(&pdata->xpcs_lock, flags);
-	XPCS32_IOWRITE(pdata, PCS_V2_WINDOW_SELECT, index);
+	XPCS32_IOWRITE(pdata, pdata->xpcs_window_sel_reg, index);
 	XPCS16_IOWRITE(pdata, offset, mmd_data);
 	spin_unlock_irqrestore(&pdata->xpcs_lock, flags);
 }
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-pci.c b/drivers/net/ethernet/amd/xgbe/xgbe-pci.c
index e76b7f6..c2730f1 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-pci.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-pci.c
@@ -265,6 +265,7 @@ static int xgbe_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	struct xgbe_prv_data *pdata;
 	struct device *dev = &pdev->dev;
 	void __iomem * const *iomap_table;
+	struct pci_dev *rdev;
 	unsigned int ma_lo, ma_hi;
 	unsigned int reg;
 	int bar_mask;
@@ -326,8 +327,20 @@ static int xgbe_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	if (netif_msg_probe(pdata))
 		dev_dbg(dev, "xpcs_regs  = %p\n", pdata->xpcs_regs);
 
+	/* Set the PCS indirect addressing definition registers */
+	rdev = pci_get_domain_bus_and_slot(0, 0, PCI_DEVFN(0, 0));
+	if (rdev &&
+	    (rdev->vendor == PCI_VENDOR_ID_AMD) && (rdev->device == 0x15d0)) {
+		pdata->xpcs_window_def_reg = PCS_V2_RV_WINDOW_DEF;
+		pdata->xpcs_window_sel_reg = PCS_V2_RV_WINDOW_SELECT;
+	} else {
+		pdata->xpcs_window_def_reg = PCS_V2_WINDOW_DEF;
+		pdata->xpcs_window_sel_reg = PCS_V2_WINDOW_SELECT;
+	}
+	pci_dev_put(rdev);
+
 	/* Configure the PCS indirect addressing support */
-	reg = XPCS32_IOREAD(pdata, PCS_V2_WINDOW_DEF);
+	reg = XPCS32_IOREAD(pdata, pdata->xpcs_window_def_reg);
 	pdata->xpcs_window = XPCS_GET_BITS(reg, PCS_V2_WINDOW_DEF, OFFSET);
 	pdata->xpcs_window <<= 6;
 	pdata->xpcs_window_size = XPCS_GET_BITS(reg, PCS_V2_WINDOW_DEF, SIZE);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index f52a9bd..0010881 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -955,6 +955,8 @@ struct xgbe_prv_data {
 
 	/* XPCS indirect addressing lock */
 	spinlock_t xpcs_lock;
+	unsigned int xpcs_window_def_reg;
+	unsigned int xpcs_window_sel_reg;
 	unsigned int xpcs_window;
 	unsigned int xpcs_window_size;
 	unsigned int xpcs_window_mask;
