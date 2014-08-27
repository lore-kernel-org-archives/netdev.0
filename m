From: Kweh Hock Leong <hock.leong.kweh@intel.com>
Subject: [PATCH 1/4] net: stmmac: enhance to support multiple device instances
Date: Wed, 27 Aug 2014 18:32:26 +0800
Message-ID: <cf29eb9e793cf67b99b455f3a4a55e7aca5d826c.1409123378.git.hock.leong.kweh@intel.com>
References: <cover.1409123378.git.hock.leong.kweh@intel.com>
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Ong Boon Leong <boon.leong.ong@intel.com>,
	Kweh Hock Leong <hock.leong.kweh@intel.com>
To: "David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48832 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933374AbaH0Kb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 06:31:59 -0400
In-Reply-To: <cover.1409123378.git.hock.leong.kweh@intel.com>
In-Reply-To: <cover.1409123378.git.hock.leong.kweh@intel.com>
References: <cover.1409123378.git.hock.leong.kweh@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>

The original stmmac_pci code only supports single ethernet controller
instance. This modification allows the driver to support multiple
stmicro ethernet controller instances by converting the static global
variables plat_dat, mdio_data & dma_cfg to dynamic allocation.

This piece of work is derived from Bryan O'Donoghue's initial work for
Quark X1000 enabling.

Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
Reviewed-by: Ong, Boon Leong <boon.leong.ong@intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c |   60 ++++++++++++++--------
 1 file changed, 39 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 655a23b..9d98935 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -26,27 +26,22 @@
 #include <linux/pci.h>
 #include "stmmac.h"
 
-static struct plat_stmmacenet_data plat_dat;
-static struct stmmac_mdio_bus_data mdio_data;
-static struct stmmac_dma_cfg dma_cfg;
+static int instance_id = 1;
 
-static void stmmac_default_data(void)
+static void stmmac_default_data(struct plat_stmmacenet_data *plat_dat)
 {
-	memset(&plat_dat, 0, sizeof(struct plat_stmmacenet_data));
-	plat_dat.bus_id = 1;
-	plat_dat.phy_addr = 0;
-	plat_dat.interface = PHY_INTERFACE_MODE_GMII;
-	plat_dat.clk_csr = 2;	/* clk_csr_i = 20-35MHz & MDC = clk_csr_i/16 */
-	plat_dat.has_gmac = 1;
-	plat_dat.force_sf_dma_mode = 1;
-
-	mdio_data.phy_reset = NULL;
-	mdio_data.phy_mask = 0;
-	plat_dat.mdio_bus_data = &mdio_data;
-
-	dma_cfg.pbl = 32;
-	dma_cfg.burst_len = DMA_AXI_BLEN_256;
-	plat_dat.dma_cfg = &dma_cfg;
+	plat_dat->bus_id = instance_id++;
+	plat_dat->phy_addr = 0;
+	plat_dat->interface = PHY_INTERFACE_MODE_GMII;
+	plat_dat->clk_csr = 2;	/* clk_csr_i = 20-35MHz & MDC = clk_csr_i/16 */
+	plat_dat->has_gmac = 1;
+	plat_dat->force_sf_dma_mode = 1;
+
+	plat_dat->mdio_bus_data->phy_reset = NULL;
+	plat_dat->mdio_bus_data->phy_mask = 0;
+
+	plat_dat->dma_cfg->pbl = 32;
+	plat_dat->dma_cfg->burst_len = DMA_AXI_BLEN_256;
 }
 
 /**
@@ -67,6 +62,7 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	int ret = 0;
 	void __iomem *addr = NULL;
 	struct stmmac_priv *priv = NULL;
+	struct plat_stmmacenet_data *plat_dat;
 	int i;
 
 	/* Enable pci device */
@@ -97,9 +93,31 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	}
 	pci_set_master(pdev);
 
-	stmmac_default_data();
+	plat_dat = devm_kzalloc(&pdev->dev, sizeof(*plat_dat), GFP_KERNEL);
+	if (!plat_dat) {
+		ret = -ENOMEM;
+		goto err_out;
+	}
+
+	plat_dat->mdio_bus_data = devm_kzalloc(&pdev->dev,
+				    sizeof(*plat_dat->mdio_bus_data),
+				    GFP_KERNEL);
+	if (!plat_dat->mdio_bus_data) {
+		ret = -ENOMEM;
+		goto err_out;
+	}
+
+	plat_dat->dma_cfg = devm_kzalloc(&pdev->dev,
+				    sizeof(*plat_dat->dma_cfg),
+				    GFP_KERNEL);
+	if (!plat_dat->dma_cfg) {
+		ret = -ENOMEM;
+		goto err_out;
+	}
+
+	stmmac_default_data(plat_dat);
 
-	priv = stmmac_dvr_probe(&(pdev->dev), &plat_dat, addr);
+	priv = stmmac_dvr_probe(&pdev->dev, plat_dat, addr);
 	if (IS_ERR(priv)) {
 		pr_err("%s: main driver probe failed", __func__);
 		ret = PTR_ERR(priv);
-- 
1.7.9.5
