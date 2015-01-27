From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v3 1/3] stmmac: pci: add support for Intel Quark X1000
Date: Tue, 27 Jan 2015 21:44:47 +0200
Message-ID: <1422387889-21559-2-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1422387889-21559-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7495 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759436AbbA0TpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 14:45:05 -0500
In-Reply-To: <1422387889-21559-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>

The Intel Quark SoC X1000 provides two 10/100 Mbps Ethernet MAC
controllers which may or may not be connected to PHY on board.
This MAC controller only supports RMII PHY. This patch add Quark
PCI ID as well as Quark default platform data info to this driver.

Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 51 +++++++++++++++++++++++-
 1 file changed, 50 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 054520d..a316187 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -26,6 +26,12 @@
 #include <linux/pci.h>
 #include "stmmac.h"
 
+struct stmmac_pci_info {
+	struct pci_dev *pdev;
+	int (*setup)(struct plat_stmmacenet_data *plat,
+		     struct stmmac_pci_info *info);
+};
+
 static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 {
 	plat->bus_id = 1;
@@ -48,6 +54,38 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 	plat->unicast_filter_entries = 1;
 }
 
+static int quark_default_data(struct plat_stmmacenet_data *plat,
+			      struct stmmac_pci_info *info)
+{
+	struct pci_dev *pdev = info->pdev;
+
+	plat->bus_id = PCI_DEVID(pdev->bus->number, pdev->devfn);
+	plat->phy_addr = 1;
+	plat->interface = PHY_INTERFACE_MODE_RMII;
+	plat->clk_csr = 2;
+	plat->has_gmac = 1;
+	plat->force_sf_dma_mode = 1;
+
+	plat->mdio_bus_data->phy_reset = NULL;
+	plat->mdio_bus_data->phy_mask = 0;
+
+	plat->dma_cfg->pbl = 16;
+	plat->dma_cfg->burst_len = DMA_AXI_BLEN_256;
+	plat->dma_cfg->fixed_burst = 1;
+
+	/* Set default value for multicast hash bins */
+	plat->multicast_filter_bins = HASH_TABLE_SIZE;
+
+	/* Set default value for unicast filter entries */
+	plat->unicast_filter_entries = 1;
+
+	return 0;
+}
+
+static struct stmmac_pci_info quark_pci_info = {
+	.setup = quark_default_data,
+};
+
 /**
  * stmmac_pci_probe
  *
@@ -63,6 +101,7 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 static int stmmac_pci_probe(struct pci_dev *pdev,
 			    const struct pci_device_id *id)
 {
+	struct stmmac_pci_info *info = (struct stmmac_pci_info *)id->driver_data;
 	struct plat_stmmacenet_data *plat;
 	struct stmmac_priv *priv;
 	int i;
@@ -103,7 +142,15 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	stmmac_default_data(plat);
+	if (info) {
+		info->pdev = pdev;
+		if (info->setup) {
+			ret = info->setup(plat, info);
+			if (ret)
+				return ret;
+		}
+	} else
+		stmmac_default_data(plat);
 
 	priv = stmmac_dvr_probe(&pdev->dev, plat, pcim_iomap_table(pdev)[i]);
 	if (IS_ERR(priv)) {
@@ -155,11 +202,13 @@ static int stmmac_pci_resume(struct device *dev)
 static SIMPLE_DEV_PM_OPS(stmmac_pm_ops, stmmac_pci_suspend, stmmac_pci_resume);
 
 #define STMMAC_VENDOR_ID 0x700
+#define STMMAC_QUARK_ID  0x0937
 #define STMMAC_DEVICE_ID 0x1108
 
 static const struct pci_device_id stmmac_id_table[] = {
 	{PCI_DEVICE(STMMAC_VENDOR_ID, STMMAC_DEVICE_ID)},
 	{PCI_DEVICE(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_MAC)},
+	{PCI_VDEVICE(INTEL, STMMAC_QUARK_ID), (kernel_ulong_t)&quark_pci_info},
 	{}
 };
 
-- 
2.1.4
