From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH] stmmac: pci: allocate memory resources dynamically
Date: Fri, 28 Nov 2014 15:40:56 +0200
Message-ID: <1417182056-17650-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>,
	Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24609 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751366AbaK1NlA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Nov 2014 08:41:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using global variables we are going to use dynamically allocated
memory. It allows to append a support of more than one ethernet adapter which
might have different settings simultaniously.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 55 +++++++++++++-----------
 1 file changed, 31 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 77a6d68..054520d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -26,34 +26,26 @@
 #include <linux/pci.h>
 #include "stmmac.h"
 
-static struct plat_stmmacenet_data plat_dat;
-static struct stmmac_mdio_bus_data mdio_data;
-static struct stmmac_dma_cfg dma_cfg;
-
-static void stmmac_default_data(void)
+static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 {
-	memset(&plat_dat, 0, sizeof(struct plat_stmmacenet_data));
-
-	plat_dat.bus_id = 1;
-	plat_dat.phy_addr = 0;
-	plat_dat.interface = PHY_INTERFACE_MODE_GMII;
-	plat_dat.clk_csr = 2;	/* clk_csr_i = 20-35MHz & MDC = clk_csr_i/16 */
-	plat_dat.has_gmac = 1;
-	plat_dat.force_sf_dma_mode = 1;
+	plat->bus_id = 1;
+	plat->phy_addr = 0;
+	plat->interface = PHY_INTERFACE_MODE_GMII;
+	plat->clk_csr = 2;	/* clk_csr_i = 20-35MHz & MDC = clk_csr_i/16 */
+	plat->has_gmac = 1;
+	plat->force_sf_dma_mode = 1;
 
-	mdio_data.phy_reset = NULL;
-	mdio_data.phy_mask = 0;
-	plat_dat.mdio_bus_data = &mdio_data;
+	plat->mdio_bus_data->phy_reset = NULL;
+	plat->mdio_bus_data->phy_mask = 0;
 
-	dma_cfg.pbl = 32;
-	dma_cfg.burst_len = DMA_AXI_BLEN_256;
-	plat_dat.dma_cfg = &dma_cfg;
+	plat->dma_cfg->pbl = 32;
+	plat->dma_cfg->burst_len = DMA_AXI_BLEN_256;
 
 	/* Set default value for multicast hash bins */
-	plat_dat.multicast_filter_bins = HASH_TABLE_SIZE;
+	plat->multicast_filter_bins = HASH_TABLE_SIZE;
 
 	/* Set default value for unicast filter entries */
-	plat_dat.unicast_filter_entries = 1;
+	plat->unicast_filter_entries = 1;
 }
 
 /**
@@ -71,10 +63,26 @@ static void stmmac_default_data(void)
 static int stmmac_pci_probe(struct pci_dev *pdev,
 			    const struct pci_device_id *id)
 {
+	struct plat_stmmacenet_data *plat;
 	struct stmmac_priv *priv;
 	int i;
 	int ret;
 
+	plat = devm_kzalloc(&pdev->dev, sizeof(*plat), GFP_KERNEL);
+	if (!plat)
+		return -ENOMEM;
+
+	plat->mdio_bus_data = devm_kzalloc(&pdev->dev,
+					   sizeof(*plat->mdio_bus_data),
+					   GFP_KERNEL);
+	if (!plat->mdio_bus_data)
+		return -ENOMEM;
+
+	plat->dma_cfg = devm_kzalloc(&pdev->dev, sizeof(*plat->dma_cfg),
+				     GFP_KERNEL);
+	if (!plat->dma_cfg)
+		return -ENOMEM;
+
 	/* Enable pci device */
 	ret = pcim_enable_device(pdev);
 	if (ret) {
@@ -95,10 +103,9 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	stmmac_default_data();
+	stmmac_default_data(plat);
 
-	priv = stmmac_dvr_probe(&pdev->dev, &plat_dat,
-				pcim_iomap_table(pdev)[i]);
+	priv = stmmac_dvr_probe(&pdev->dev, plat, pcim_iomap_table(pdev)[i]);
 	if (IS_ERR(priv)) {
 		dev_err(&pdev->dev, "%s: main driver probe failed\n", __func__);
 		return PTR_ERR(priv);
-- 
2.1.3
