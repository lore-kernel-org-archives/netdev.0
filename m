From: Kweh Hock Leong <hock.leong.kweh@intel.com>
Subject: [PATCH v2 3/4] net: stmmac: add support for Intel Quark X1000
Date: Thu, 11 Sep 2014 16:38:39 +0800
Message-ID: <07ca9d2c89cf4f01037c98e3314dd035e4d2ee34.1410416224.git.hock.leong.kweh@intel.com>
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

The Intel Quark SoC X1000 provides two 10/100 Mbps Ethernet MAC
controllers which may or may not be connected to PHY on board.
This MAC controller only supports RMII PHY.

Besides adding Quark PCI ID to this driver, this patch introduces
run-time board detection through DMI and MAC-PHY configuration
function used by stmmac_default_data() during initialization.
It fills up the phy_address to -1 for Galileo and Galileo Gen2
boards to indicate that the 2nd Ethernet MAC controller is not
connected to any PHY.

The implementation takes into consideration for future expansion in
Quark series boards that may have different PHY address that is
linked to its MAC controllers.

This piece of work is derived from Bryan O'Donoghue's initial work for
Quark X1000 enabling.

Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
Reviewed-by: Ong, Boon Leong <boon.leong.ong@intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c |   87 ++++++++++++++++++++--
 1 file changed, 82 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 35fc884..4fae23f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -24,14 +24,18 @@
 *******************************************************************************/
 
 #include <linux/pci.h>
+#include <linux/dmi.h>
 #include "stmmac.h"
 
+static void quark_run_time_config(int chip_id, struct pci_dev *pdev);
+
 enum chip {
 	CHIP_STMICRO = 0,
+	CHIP_QUARK_X1000,
 };
 
-/* A struct for platform specific information which will be
- * used in stmmac_default_data function for initialization
+/* A struct for platform specific information which is used
+ * in stmmac_default_data function for initialization
  */
 struct platform_data {
 	int phy_addr;
@@ -44,7 +48,9 @@ struct platform_data {
 	int (*phy_reset)(void *priv);
 	unsigned int phy_mask;
 	int pbl;
+	int fixed_burst;
 	int burst_len;
+	void (*rt_config)(int chip_id, struct pci_dev *pdev);
 };
 
 static struct platform_data platform_info[] = {
@@ -59,15 +65,76 @@ static struct platform_data platform_info[] = {
 		.phy_reset = NULL,
 		.phy_mask = 0,
 		.pbl = 32,
+		.fixed_burst = 0,
 		.burst_len = DMA_AXI_BLEN_256,
+		.rt_config = NULL,
+	},
+	[CHIP_QUARK_X1000] = {
+		.phy_addr = 1,
+		.interface = PHY_INTERFACE_MODE_RMII,
+		.clk_csr = 2,
+		.has_gmac = 1,
+		.force_sf_dma_mode = 1,
+		.multicast_filter_bins = HASH_TABLE_SIZE,
+		.unicast_filter_entries = 1,
+		.phy_reset = NULL,
+		.phy_mask = 0,
+		.pbl = 16,
+		.fixed_burst = 1,
+		.burst_len = DMA_AXI_BLEN_256,
+		.rt_config = &quark_run_time_config,
+	},
+};
+
+/* This struct is used to associate PCI Function ID of MAC controller
+ * on a board, discovered via DMI, with phy_address. It is also used
+ * to describe if that MAC controller is connected with PHY.
+ */
+struct intel_quark_platform {
+	int pci_func_num;
+	const char *board_name;
+	int phy_address;
+};
+
+static struct intel_quark_platform quark_x1000_phy_info[] = {
+	{
+		.pci_func_num = 7,
+		.board_name = "Galileo",
+		/* Galileo ethernet port 2 does not connect to any PHY */
+		.phy_address = -1,
+	},
+	{
+		.pci_func_num = 7,
+		.board_name = "GalileoGen2",
+		/* Galileo Gen2 ethernet port 2 does not connect to any PHY */
+		.phy_address = -1,
 	},
 };
 
-static void stmmac_default_data(struct plat_stmmacenet_data *plat,
-				int chip_id, struct pci_dev *pdev)
+static void quark_run_time_config(int chip_id, struct pci_dev *pdev)
+{
+	const char *board_name = dmi_get_system_info(DMI_BOARD_NAME);
+	int i;
+	int func_num = PCI_FUNC(pdev->devfn);
+
+	if (!board_name)
+		return;
+
+	for (i = 0; i < ARRAY_SIZE(quark_x1000_phy_info); i++) {
+		if ((!strcmp(quark_x1000_phy_info[i].board_name, board_name)) &&
+		    quark_x1000_phy_info[i].pci_func_num == func_num)
+			platform_info[chip_id].phy_addr =
+				quark_x1000_phy_info[i].phy_address;
+	}
+}
+
+static int stmmac_default_data(struct plat_stmmacenet_data *plat,
+			       int chip_id, struct pci_dev *pdev)
 {
 	struct platform_data *chip_plat_dat = &platform_info[chip_id];
 
+	if (chip_plat_dat->rt_config)
+		chip_plat_dat->rt_config(chip_id, pdev);
 	plat->bus_id = PCI_DEVID(pdev->bus->number, pdev->devfn);
 	plat->phy_addr = chip_plat_dat->phy_addr;
 	plat->interface = chip_plat_dat->interface;
@@ -82,7 +149,13 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat,
 	plat->mdio_bus_data->phy_mask = chip_plat_dat->phy_mask;
 
 	plat->dma_cfg->pbl = chip_plat_dat->pbl;
+	plat->dma_cfg->fixed_burst = chip_plat_dat->fixed_burst;
 	plat->dma_cfg->burst_len = chip_plat_dat->burst_len;
+
+	/* Refuse to load the driver and register net device
+	 * if MAC controller does not connect to any PHY interface
+	 */
+	return (plat->phy_addr != -1) ? 0 : -ENODEV;
 }
 
 /**
@@ -156,7 +229,9 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 		goto err_out;
 	}
 
-	stmmac_default_data(plat_dat, id->driver_data, pdev);
+	ret = stmmac_default_data(plat_dat, id->driver_data, pdev);
+	if (ret)
+		goto err_out;
 
 	priv = stmmac_dvr_probe(&pdev->dev, plat_dat, addr);
 	if (IS_ERR(priv)) {
@@ -228,11 +303,13 @@ static int stmmac_pci_resume(struct pci_dev *pdev)
 
 #define STMMAC_VENDOR_ID 0x700
 #define STMMAC_DEVICE_ID 0x1108
+#define STMMAC_QUARK_X1000_ID 0x0937
 
 static const struct pci_device_id stmmac_id_table[] = {
 	{PCI_DEVICE(STMMAC_VENDOR_ID, STMMAC_DEVICE_ID), PCI_ANY_ID,
 			PCI_ANY_ID, CHIP_STMICRO},
 	{PCI_VDEVICE(STMICRO, PCI_DEVICE_ID_STMICRO_MAC), CHIP_STMICRO},
+	{PCI_VDEVICE(INTEL, STMMAC_QUARK_X1000_ID), CHIP_QUARK_X1000},
 	{}
 };
 
-- 
1.7.9.5
