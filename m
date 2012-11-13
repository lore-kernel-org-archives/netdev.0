From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [RFC PATCH v1 3.7.0-rc4 1/2] dt:net/stmmac: Add complete device tree support
Date: Tue, 13 Nov 2012 13:50:26 +0000
Message-ID: <1352814626-14207-1-git-send-email-srinivas.kandagatla@st.com>
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	srinivas.kandagatla@st.com, davem@davemloft.net
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:41787 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754600Ab2KMNvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 08:51:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch attempts to add full device tree support to stmmac driver,
previously support to few optional properties were missed in both
bindings and driver.
With this patch DT support should be complete for stmmac driver.

Also all the vendor specific properties are prefixed with snps.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt   |   41 +++++++++++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   58 ++++++++++++++------
 2 files changed, 80 insertions(+), 19 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 060bbf0..b55d369 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -14,16 +14,53 @@ Required properties:
   Supported values are: "mii", "rmii", "gmii", "rgmii".
 
 Optional properties:
-- mac-address: 6 bytes, mac address
+- mac-address		6 bytes, mac address
+- phy-handle		Should be a phandle to the PHY.
+- snps,clk-csr		Fixed CSR Clock range selection.
+- snps,enh-desc		Boolean flag to indicate if mac support
+			enhanced descriptors.
+- snps,tx-coe		flag for Tx Checksum Offload engine presence
+- snps,rx-coe		flag fo Rx Checksum Offload engine presence.
+- snps,bugged-jumbo	some HWs are not able to perform the csum in HW for
+			over-sized frames due to limited buffer sizes.
+			Setting this flag the csum will be done in SW on
+			JUMBO frames.
+- snps,force-sf-dma-mode  force DMA to use the Store and Forward mode
+			instead of the Threshold.
+- snps,pbl		Programmable Burst Length
+- snps,fixed-burst	Program the DMA to use the fixed burst mode
+- snps,burst-len		This is the value we put in the register
+			supported values are provided as macros in
+			linux/stmmac.h header file.
+- snps,phy-bus-name	Name of the mdio bus to connect. if not specified
+			mac attempts to connect to stmmac mdio bus.
+- snps,phy-bus-id	Mdio bus number to connect. if not specified 0 is used.
+- snps,phy-addr		phy address to connect to.
+
 
 Examples:
 
 	gmac0: ethernet@e0800000 {
-		compatible = "st,spear600-gmac";
+		compatible = "snps,dwmac";
 		reg = <0xe0800000 0x8000>;
 		interrupt-parent = <&vic1>;
 		interrupts = <24 23>;
 		interrupt-names = "macirq", "eth_wake_irq";
 		mac-address = [000000000000]; /* Filled in by U-Boot */
 		phy-mode = "gmii";
+
+		snps,clk-csr	= <0x0>;
+		snps,enh-desc;
+		snps,tx-coe;
+		snps,rx-coe;
+		snps,bugged-jumbo;
+		snps,force-sf-dma-mode;
+		snps,pbl	= <32>;
+		snps,burst-len	= <32>;
+		snps,fixed-burst;
+
+		/* PHY specific */
+		snps,phy-bus-name = "stmmac";
+		snps,phy-bus-id = <0>;
+		snps,phy-addr = <0x9>;
 	};
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index ed112b5..6ee7548 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -29,26 +29,31 @@
 #include "stmmac.h"
 
 #ifdef CONFIG_OF
+
+static u64 stmmac_dma_mask = DMA_BIT_MASK(32);
 static int __devinit stmmac_probe_config_dt(struct platform_device *pdev,
 					    struct plat_stmmacenet_data *plat,
 					    const char **mac)
 {
 	struct device_node *np = pdev->dev.of_node;
-
+	struct stmmac_dma_cfg *dma_cfg;
+	const char **phy_bus_name = (const char **)&plat->phy_bus_name;
 	if (!np)
 		return -ENODEV;
 
 	*mac = of_get_mac_address(np);
 	plat->interface = of_get_phy_mode(np);
-	plat->mdio_bus_data = devm_kzalloc(&pdev->dev,
-					   sizeof(struct stmmac_mdio_bus_data),
-					   GFP_KERNEL);
+	of_property_read_string(np, "snps,phy-bus-name", phy_bus_name);
+	of_property_read_u32(np, "snps,phy-bus-id", &plat->bus_id);
+	of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr);
+
+	if (*phy_bus_name && strcmp(*phy_bus_name, "stmmac"))
+		plat->mdio_bus_data = NULL;
+	else
+		plat->mdio_bus_data = devm_kzalloc(&pdev->dev,
+					sizeof(struct stmmac_mdio_bus_data),
+					GFP_KERNEL);
 
-	/*
-	 * Currently only the properties needed on SPEAr600
-	 * are provided. All other properties should be added
-	 * once needed on other platforms.
-	 */
 	if (of_device_is_compatible(np, "st,spear600-gmac") ||
 		of_device_is_compatible(np, "snps,dwmac-3.70a") ||
 		of_device_is_compatible(np, "snps,dwmac")) {
@@ -56,6 +61,24 @@ static int __devinit stmmac_probe_config_dt(struct platform_device *pdev,
 		plat->pmt = 1;
 	}
 
+	of_property_read_u32(np, "snps,clk-csr", &plat->clk_csr);
+
+	plat->enh_desc = of_property_read_bool(np, "snps,enh-desc");
+	plat->tx_coe = of_property_read_bool(np, "snps,tx-coe");
+	plat->rx_coe = of_property_read_bool(np, "snps,rx-coe");
+	plat->bugged_jumbo = of_property_read_bool(np, "snps,bugged-jumbo");
+	plat->force_sf_dma_mode = of_property_read_bool(np,
+					"snps,force-sf-dma-mode");
+
+	dma_cfg = devm_kzalloc(&pdev->dev, sizeof(*dma_cfg), GFP_KERNEL);
+	plat->dma_cfg = dma_cfg;
+	of_property_read_u32(np, "snps,burst-len", &dma_cfg->burst_len);
+	of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl);
+	dma_cfg->fixed_burst = of_property_read_bool(np, "snps,fixed-burst");
+	dma_cfg->mixed_burst = of_property_read_bool(np, "snps,mixed-burst");
+
+	if (!pdev->dev.dma_mask)
+		pdev->dev.dma_mask = &stmmac_dma_mask;
 	return 0;
 }
 #else
@@ -93,14 +116,17 @@ static int __devinit stmmac_pltfr_probe(struct platform_device *pdev)
 		pr_err("%s: ERROR: memory mapping failed", __func__);
 		return -ENOMEM;
 	}
-
+	plat_dat = pdev->dev.platform_data;
 	if (pdev->dev.of_node) {
-		plat_dat = devm_kzalloc(&pdev->dev,
+		if (!plat_dat) {
+			/* no data from OF_DEV_AUXDATA */
+			plat_dat = devm_kzalloc(&pdev->dev,
 					sizeof(struct plat_stmmacenet_data),
 					GFP_KERNEL);
-		if (!plat_dat) {
-			pr_err("%s: ERROR: no memory", __func__);
-			return  -ENOMEM;
+			if (!plat_dat) {
+				pr_err("%s: ERROR: no memory", __func__);
+				return  -ENOMEM;
+			}
 		}
 
 		ret = stmmac_probe_config_dt(pdev, plat_dat, &mac);
@@ -108,8 +134,6 @@ static int __devinit stmmac_pltfr_probe(struct platform_device *pdev)
 			pr_err("%s: main dt probe failed", __func__);
 			return ret;
 		}
-	} else {
-		plat_dat = pdev->dev.platform_data;
 	}
 
 	/* Custom initialisation (if needed)*/
-- 
1.7.0.4
