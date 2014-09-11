From: Kweh Hock Leong <hock.leong.kweh@intel.com>
Subject: [PATCH v2 4/4] net: stmmac: add MSI support for Intel Quark X1000
Date: Thu, 11 Sep 2014 16:38:40 +0800
Message-ID: <0c16a3c5e46cf4a198180057b3e2a10f5a8c7888.1410416224.git.hock.leong.kweh@intel.com>
References: <cover.1410416223.git.hock.leong.kweh@intel.com>
Cc: Vince Bridgers <vbridgers2013@gmail.com>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Ong Boon Leong <boon.leong.ong@intel.com>,
	Kweh Hock Leong <hock.leong.kweh@intel.com>
To: "David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	rayagond@vayavyalabs.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1410416223.git.hock.leong.kweh@intel.com>
In-Reply-To: <cover.1410416223.git.hock.leong.kweh@intel.com>
References: <cover.1410416223.git.hock.leong.kweh@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>

In Intel Quark SoC X1000, both of the Ethernet controllers support
MSI interrupt handling. This patch enables them to use MSI interrupt
servicing in stmmac_pci for Intel Quark X1000.

Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
Reviewed-by: Ong, Boon Leong <boon.leong.ong@intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c |   19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 4fae23f..02861c3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -51,6 +51,7 @@ struct platform_data {
 	int fixed_burst;
 	int burst_len;
 	void (*rt_config)(int chip_id, struct pci_dev *pdev);
+	int support_msi;
 };
 
 static struct platform_data platform_info[] = {
@@ -68,6 +69,7 @@ static struct platform_data platform_info[] = {
 		.fixed_burst = 0,
 		.burst_len = DMA_AXI_BLEN_256,
 		.rt_config = NULL,
+		.support_msi = 0,
 	},
 	[CHIP_QUARK_X1000] = {
 		.phy_addr = 1,
@@ -83,6 +85,7 @@ static struct platform_data platform_info[] = {
 		.fixed_burst = 1,
 		.burst_len = DMA_AXI_BLEN_256,
 		.rt_config = &quark_run_time_config,
+		.support_msi = 1,
 	},
 };
 
@@ -210,7 +213,7 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	plat_dat = devm_kzalloc(&pdev->dev, sizeof(*plat_dat), GFP_KERNEL);
 	if (!plat_dat) {
 		ret = -ENOMEM;
-		goto err_out;
+		goto err_out_alloc_failed;
 	}
 
 	plat_dat->mdio_bus_data = devm_kzalloc(&pdev->dev,
@@ -218,7 +221,7 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 					       GFP_KERNEL);
 	if (!plat_dat->mdio_bus_data) {
 		ret = -ENOMEM;
-		goto err_out;
+		goto err_out_alloc_failed;
 	}
 
 	plat_dat->dma_cfg = devm_kzalloc(&pdev->dev,
@@ -226,12 +229,15 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 					 GFP_KERNEL);
 	if (!plat_dat->dma_cfg) {
 		ret = -ENOMEM;
-		goto err_out;
+		goto err_out_alloc_failed;
 	}
 
 	ret = stmmac_default_data(plat_dat, id->driver_data, pdev);
 	if (ret)
-		goto err_out;
+		goto err_out_alloc_failed;
+
+	if (platform_info[id->driver_data].support_msi)
+		pci_enable_msi(pdev);
 
 	priv = stmmac_dvr_probe(&pdev->dev, plat_dat, addr);
 	if (IS_ERR(priv)) {
@@ -249,6 +255,9 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	return 0;
 
 err_out:
+	if (platform_info[id->driver_data].support_msi)
+		pci_disable_msi(pdev);
+err_out_alloc_failed:
 	pci_clear_master(pdev);
 err_out_map_failed:
 	pci_release_regions(pdev);
@@ -272,6 +281,8 @@ static void stmmac_pci_remove(struct pci_dev *pdev)
 
 	stmmac_dvr_remove(ndev);
 
+	if (pci_dev_msi_enabled(pdev))
+		pci_disable_msi(pdev);
 	pci_iounmap(pdev, priv->ioaddr);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-- 
1.7.9.5
