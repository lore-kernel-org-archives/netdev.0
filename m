From: Alessandro Rubini <rubini@gnudd.com>
Subject: [PATCH 2/3] stmmac: err out on second probe; use precompiled
 static structures
Date: Tue, 24 Jan 2012 10:09:31 +0100
Message-ID: <81a7bd5642756bb3aa1495de4941bbbc827f3260.1327394751.git.rubini@gnudd.com>
References: <cover.1327394750.git.rubini@gnudd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: giancarlo.asnaghi@st.com, rayagond@vayavyalabs.com
To: linux-kernel@vger.kernel.org, peppe.cavallaro@st.com,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1327394750.git.rubini@gnudd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver can support one device only, and this patch makes it
explicit, spitting an error in case someone makes an ASIC or FPGA with
two stmmac cells in it.

Also, the data structures are static and compile-time initialized,
instead of being in the global name space and filled at run time. This
also eases turning some fields to parameters, as different chips will
have different setups.

Signed-off-by: Alessandro Rubini <rubini@gnudd.com>
Acked-by: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Acked-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c |   47 ++++++++++++----------
 1 files changed, 26 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index c796de9..b075a5d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -24,27 +24,26 @@
 *******************************************************************************/
 
 #include <linux/pci.h>
+#include <linux/atomic.h>
 #include "stmmac.h"
 
-struct plat_stmmacenet_data plat_dat;
-struct stmmac_mdio_bus_data mdio_data;
+/* This driver supports one PCI device only, with static platform data */
+static atomic_t stmmac_pci_probed;
 
-static void stmmac_default_data(void)
-{
-	memset(&plat_dat, 0, sizeof(struct plat_stmmacenet_data));
-	plat_dat.bus_id = 1;
-	plat_dat.phy_addr = 0;
-	plat_dat.interface = PHY_INTERFACE_MODE_GMII;
-	plat_dat.pbl = 32;
-	plat_dat.clk_csr = 2;	/* clk_csr_i = 20-35MHz & MDC = clk_csr_i/16 */
-	plat_dat.has_gmac = 1;
-	plat_dat.force_sf_dma_mode = 1;
-
-	mdio_data.bus_id = 1;
-	mdio_data.phy_reset = NULL;
-	mdio_data.phy_mask = 0;
-	plat_dat.mdio_bus_data = &mdio_data;
-}
+static struct stmmac_mdio_bus_data stmmac_default_mdio_data = {
+	.bus_id = 1,
+};
+
+static struct plat_stmmacenet_data stmmac_default_data = {
+	.bus_id = 1,
+	.phy_addr = 0,
+	.interface = PHY_INTERFACE_MODE_GMII,
+	.pbl = 32,
+	.clk_csr = 2,	/* clk_csr_i = 20-35MHz & MDC = clk_csr_i/16 */
+	.has_gmac = 1,
+	.force_sf_dma_mode = 1,
+	.mdio_bus_data = &stmmac_default_mdio_data,
+};
 
 /**
  * stmmac_pci_probe
@@ -66,6 +65,13 @@ static int __devinit stmmac_pci_probe(struct pci_dev *pdev,
 	struct stmmac_priv *priv = NULL;
 	int i;
 
+	/* One device only in this version */
+	if (atomic_inc_and_test(&stmmac_pci_probed)) {
+		atomic_dec(&stmmac_pci_probed);
+		dev_err(&pdev->dev, "this driver supports one device only\n");
+		return -ENODEV;
+	}
+
 	/* Enable pci device */
 	ret = pci_enable_device(pdev);
 	if (ret) {
@@ -94,9 +100,7 @@ static int __devinit stmmac_pci_probe(struct pci_dev *pdev,
 	}
 	pci_set_master(pdev);
 
-	stmmac_default_data();
-
-	priv = stmmac_dvr_probe(&(pdev->dev), &plat_dat);
+	priv = stmmac_dvr_probe(&(pdev->dev), &stmmac_default_data);
 	if (!priv) {
 		pr_err("%s: main drivr probe failed", __func__);
 		goto err_out;
@@ -140,6 +144,7 @@ static void __devexit stmmac_pci_remove(struct pci_dev *pdev)
 	pci_iounmap(pdev, priv->ioaddr);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
+	atomic_dec(&stmmac_pci_probed);
 }
 
 #ifdef CONFIG_PM
-- 
1.7.7.2
