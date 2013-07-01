From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 2/3] dt:net:stmmac: Add support to dwmac version 3.610 and 3.710
Date: Mon,  1 Jul 2013 12:43:54 +0100
Message-ID: <1372679034-13139-1-git-send-email-srinivas.kandagatla@st.com>
References: <1372678962-12959-1-git-send-email-srinivas.kandagatla@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372678962-12959-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch adds dt support to dwmac version 3.610 and 3.710 these
versions are integrated in STiH415 and STiH416 ARM A9 SOCs.
To support these IP version, some of the device tree properties are
extended.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt   |    4 +++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   25 ++++++++++++++++++++
 2 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 060bbf0..e1ddfcc 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -12,6 +12,10 @@ Required properties:
   property
 - phy-mode: String, operation mode of the PHY interface.
   Supported values are: "mii", "rmii", "gmii", "rgmii".
+- snps,phy-addr		phy address to connect to.
+- snps,pbl		Programmable Burst Length
+- snps,fixed-burst	Program the DMA to use the fixed burst mode
+- snps,mixed-burst	Program the DMA to use the mixed burst mode
 
 Optional properties:
 - mac-address: 6 bytes, mac address
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 5907920..060758d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -29,17 +29,26 @@
 #include "stmmac.h"
 
 #ifdef CONFIG_OF
+
 static int stmmac_probe_config_dt(struct platform_device *pdev,
 				  struct plat_stmmacenet_data *plat,
 				  const char **mac)
 {
 	struct device_node *np = pdev->dev.of_node;
+	struct stmmac_dma_cfg *dma_cfg;
 
 	if (!np)
 		return -ENODEV;
 
 	*mac = of_get_mac_address(np);
 	plat->interface = of_get_phy_mode(np);
+
+	plat->bus_id = of_alias_get_id(np, "ethernet");
+	if (plat->bus_id < 0)
+		plat->bus_id = 0;
+
+	of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr);
+
 	plat->mdio_bus_data = devm_kzalloc(&pdev->dev,
 					   sizeof(struct stmmac_mdio_bus_data),
 					   GFP_KERNEL);
@@ -51,11 +60,25 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	 */
 	if (of_device_is_compatible(np, "st,spear600-gmac") ||
 		of_device_is_compatible(np, "snps,dwmac-3.70a") ||
+		of_device_is_compatible(np, "snps,dwmac-3.610") ||
 		of_device_is_compatible(np, "snps,dwmac")) {
 		plat->has_gmac = 1;
 		plat->pmt = 1;
 	}
 
+	if (of_device_is_compatible(np, "snps,dwmac-3.610") ||
+		of_device_is_compatible(np, "snps,dwmac-3.710")) {
+		plat->enh_desc = 1;
+		plat->bugged_jumbo = 1;
+		plat->force_sf_dma_mode = 1;
+	}
+
+	dma_cfg = devm_kzalloc(&pdev->dev, sizeof(*dma_cfg), GFP_KERNEL);
+	plat->dma_cfg = dma_cfg;
+	of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl);
+	dma_cfg->fixed_burst = of_property_read_bool(np, "snps,fixed-burst");
+	dma_cfg->mixed_burst = of_property_read_bool(np, "snps,mixed-burst");
+
 	return 0;
 }
 #else
@@ -230,7 +253,9 @@ static const struct dev_pm_ops stmmac_pltfr_pm_ops;
 
 static const struct of_device_id stmmac_dt_ids[] = {
 	{ .compatible = "st,spear600-gmac"},
+	{ .compatible = "snps,dwmac-3.610"},
 	{ .compatible = "snps,dwmac-3.70a"},
+	{ .compatible = "snps,dwmac-3.710"},
 	{ .compatible = "snps,dwmac"},
 	{ /* sentinel */ }
 };
-- 
1.7.6.5
