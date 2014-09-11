From: Kweh Hock Leong <hock.leong.kweh@intel.com>
Subject: [PATCH v2 2/4] net: stmmac: better code manageability with platform data struct
Date: Thu, 11 Sep 2014 16:38:38 +0800
Message-ID: <ee40f7c4ee227b9fda1f0269493dfa5526561f02.1410416224.git.hock.leong.kweh@intel.com>
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

Introduce additional struct to hold platform info for pci device. It
is used to store features that are supported by specific chip vendor.
This code change helps to expand further to support more platform
vendors and this implementation promotes better code manageability
and keep code base clean. In addition, this patch adds mcast & ucast
filter configuration in pci driver.

Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
Reviewed-by: Ong, Boon Leong <boon.leong.ong@intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c |   77 +++++++++++++++++-----
 1 file changed, 60 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 4d9a5c2..35fc884 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -26,21 +26,63 @@
 #include <linux/pci.h>
 #include "stmmac.h"
 
-static void stmmac_default_data(struct plat_stmmacenet_data *plat_dat,
-				struct pci_dev *pdev)
+enum chip {
+	CHIP_STMICRO = 0,
+};
+
+/* A struct for platform specific information which will be
+ * used in stmmac_default_data function for initialization
+ */
+struct platform_data {
+	int phy_addr;
+	int interface;
+	int clk_csr;
+	int has_gmac;
+	int force_sf_dma_mode;
+	int multicast_filter_bins;
+	int unicast_filter_entries;
+	int (*phy_reset)(void *priv);
+	unsigned int phy_mask;
+	int pbl;
+	int burst_len;
+};
+
+static struct platform_data platform_info[] = {
+	[CHIP_STMICRO] = {
+		.phy_addr = 0,
+		.interface = PHY_INTERFACE_MODE_GMII,
+		.clk_csr = 2,
+		.has_gmac = 1,
+		.force_sf_dma_mode = 1,
+		.multicast_filter_bins = HASH_TABLE_SIZE,
+		.unicast_filter_entries = 1,
+		.phy_reset = NULL,
+		.phy_mask = 0,
+		.pbl = 32,
+		.burst_len = DMA_AXI_BLEN_256,
+	},
+};
+
+static void stmmac_default_data(struct plat_stmmacenet_data *plat,
+				int chip_id, struct pci_dev *pdev)
 {
-	plat_dat->bus_id = PCI_DEVID(pdev->bus->number, pdev->devfn);
-	plat_dat->phy_addr = 0;
-	plat_dat->interface = PHY_INTERFACE_MODE_GMII;
-	plat_dat->clk_csr = 2;	/* clk_csr_i = 20-35MHz & MDC = clk_csr_i/16 */
-	plat_dat->has_gmac = 1;
-	plat_dat->force_sf_dma_mode = 1;
-
-	plat_dat->mdio_bus_data->phy_reset = NULL;
-	plat_dat->mdio_bus_data->phy_mask = 0;
-
-	plat_dat->dma_cfg->pbl = 32;
-	plat_dat->dma_cfg->burst_len = DMA_AXI_BLEN_256;
+	struct platform_data *chip_plat_dat = &platform_info[chip_id];
+
+	plat->bus_id = PCI_DEVID(pdev->bus->number, pdev->devfn);
+	plat->phy_addr = chip_plat_dat->phy_addr;
+	plat->interface = chip_plat_dat->interface;
+	/* clk_csr_i = 20-35MHz & MDC = clk_csr_i/16 */
+	plat->clk_csr = chip_plat_dat->clk_csr;
+	plat->has_gmac = chip_plat_dat->has_gmac;
+	plat->force_sf_dma_mode = chip_plat_dat->force_sf_dma_mode;
+	plat->multicast_filter_bins = chip_plat_dat->multicast_filter_bins;
+	plat->unicast_filter_entries = chip_plat_dat->unicast_filter_entries;
+
+	plat->mdio_bus_data->phy_reset = chip_plat_dat->phy_reset;
+	plat->mdio_bus_data->phy_mask = chip_plat_dat->phy_mask;
+
+	plat->dma_cfg->pbl = chip_plat_dat->pbl;
+	plat->dma_cfg->burst_len = chip_plat_dat->burst_len;
 }
 
 /**
@@ -114,7 +156,7 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 		goto err_out;
 	}
 
-	stmmac_default_data(plat_dat, pdev);
+	stmmac_default_data(plat_dat, id->driver_data, pdev);
 
 	priv = stmmac_dvr_probe(&pdev->dev, plat_dat, addr);
 	if (IS_ERR(priv)) {
@@ -188,8 +230,9 @@ static int stmmac_pci_resume(struct pci_dev *pdev)
 #define STMMAC_DEVICE_ID 0x1108
 
 static const struct pci_device_id stmmac_id_table[] = {
-	{PCI_DEVICE(STMMAC_VENDOR_ID, STMMAC_DEVICE_ID)},
-	{PCI_DEVICE(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_MAC)},
+	{PCI_DEVICE(STMMAC_VENDOR_ID, STMMAC_DEVICE_ID), PCI_ANY_ID,
+			PCI_ANY_ID, CHIP_STMICRO},
+	{PCI_VDEVICE(STMICRO, PCI_DEVICE_ID_STMICRO_MAC), CHIP_STMICRO},
 	{}
 };
 
-- 
1.7.9.5
