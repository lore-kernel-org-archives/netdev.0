From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 2/3] amd-xgbe: Move the phy device resources into
 network device
Date: Fri, 29 Aug 2014 10:22:01 -0500
Message-ID: <20140829152201.13783.54793.stgit@tlendack-t1.amdoffice.net>
References: <20140829152148.13783.23789.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0145.outbound.protection.outlook.com ([207.46.163.145]:13739
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753732AbaH2PWI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 11:22:08 -0400
In-Reply-To: <20140829152148.13783.23789.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the second step of moving the phy driver into the network driver,
move the phy device resources and settings into the network device.
Creating a new compatible id string for this format allows for backward
compatibility with old device trees.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 .../devicetree/bindings/net/amd-xgbe-phy.txt       |   23 --------
 Documentation/devicetree/bindings/net/amd-xgbe.txt |   18 ++++--
 drivers/net/ethernet/amd/xgbe/xgbe-main.c          |   60 ++++++++++++++------
 drivers/net/ethernet/amd/xgbe/xgbe-phy.c           |   14 ++---
 drivers/net/ethernet/amd/xgbe/xgbe.h               |   13 +++-
 5 files changed, 73 insertions(+), 55 deletions(-)
 delete mode 100644 Documentation/devicetree/bindings/net/amd-xgbe-phy.txt

diff --git a/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt b/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
deleted file mode 100644
index 42409bf..0000000
--- a/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
+++ /dev/null
@@ -1,23 +0,0 @@
-* AMD 10GbE PHY driver (amd-xgbe-phy)
-
-Required properties:
-- compatible: Should be "amd,xgbe-phy-seattle-v1a" and
-  "ethernet-phy-ieee802.3-c45"
-- reg: Address and length of the register sets for the device
-   - SerDes Rx/Tx registers
-   - SerDes integration registers (1/2)
-   - SerDes integration registers (2/2)
-
-Optional properties:
-- amd,speed-set: Speed capabilities of the device
-    0 - 1GbE and 10GbE (default)
-    1 - 2.5GbE and 10GbE
-
-Example:
-	xgbe_phy@e1240800 {
-		compatible = "amd,xgbe-phy-seattle-v1a", "ethernet-phy-ieee802.3-c45";
-		reg = <0 0xe1240800 0 0x00400>,
-		      <0 0xe1250000 0 0x00060>,
-		      <0 0xe1250080 0 0x00004>;
-		amd,speed-set = <0>;
-	};
diff --git a/Documentation/devicetree/bindings/net/amd-xgbe.txt b/Documentation/devicetree/bindings/net/amd-xgbe.txt
index 41354f7..259482c 100644
--- a/Documentation/devicetree/bindings/net/amd-xgbe.txt
+++ b/Documentation/devicetree/bindings/net/amd-xgbe.txt
@@ -1,10 +1,13 @@
 * AMD 10GbE driver (amd-xgbe)
 
 Required properties:
-- compatible: Should be "amd,xgbe-seattle-v1a"
+- compatible: Should be "amd,xgbe-seattle-v1b"
 - reg: Address and length of the register sets for the device
    - MAC registers
    - PCS registers
+   - SerDes Rx/Tx registers
+   - SerDes integration registers (1/2)
+   - SerDes integration registers (2/2)
 - interrupt-parent: Should be the phandle for the interrupt controller
   that services interrupts for this device
 - interrupts: Should contain the amd-xgbe interrupt
@@ -16,24 +19,29 @@ Required properties:
 - clock-names: Should be the names of the clocks
    - "dma_clk" for the DMA clock
    - "ptp_clk" for the PTP clock
-- phy-handle: See ethernet.txt file in the same directory
 - phy-mode: See ethernet.txt file in the same directory
 
 Optional properties:
 - mac-address: mac address to be assigned to the device. Can be overridden
   by UEFI.
+- amd,speed-set: available network speeds
+  0 - 1GbE and 10GbE
+  1 - 2.5GbE and 10GbE
 - dma-coherent: Present if dma operations are coherent
 
 Example:
 	xgbe@e0700000 {
-		compatible = "amd,xgbe-seattle-v1a";
+		compatible = "amd,xgbe-seattle-v1b";
 		reg = <0 0xe0700000 0 0x80000>,
-		      <0 0xe0780000 0 0x80000>;
+		      <0 0xe0780000 0 0x80000>,
+		      <0 0xe1240800 0 0x00400>,
+		      <0 0xe1250000 0 0x00060>,
+		      <0 0xe1250080 0 0x00004>;
 		interrupt-parent = <&gic>;
 		interrupts = <0 325 4>;
 		clocks = <&xgbe_dma_clk>, <&xgbe_ptp_clk>;
 		clock-names = "dma_clk", "ptp_clk";
-		phy-handle = <&phy>;
 		phy-mode = "xgmii";
+		amd,speed-set = <0>;
 		mac-address = [ 02 a1 a2 a3 a4 a5 ];
 	};
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index f9ffbfc..7382525 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -136,6 +136,8 @@ MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION(XGBE_DRV_VERSION);
 MODULE_DESCRIPTION(XGBE_DRV_DESC);
 
+static const struct of_device_id xgbe_of_match[];
+
 static struct xgbe_channel *xgbe_alloc_rings(struct xgbe_prv_data *pdata)
 {
 	struct xgbe_channel *channel_mem, *channel;
@@ -224,12 +226,14 @@ static int xgbe_probe(struct platform_device *pdev)
 	struct xgbe_hw_if *hw_if;
 	struct xgbe_desc_if *desc_if;
 	struct net_device *netdev;
+	const struct of_device_id *of_dev;
 	struct device *dev = &pdev->dev;
 	struct device_node *phy_node;
 	struct platform_device *phy_pdev;
 	struct resource *res;
 	const __be32 *property;
 	const u8 *mac_addr;
+	unsigned int mem_resource;
 	int ret;
 
 	DBGPR("--> xgbe_probe\n");
@@ -252,19 +256,34 @@ static int xgbe_probe(struct platform_device *pdev)
 	mutex_init(&pdata->xpcs_mutex);
 	spin_lock_init(&pdata->tstamp_lock);
 
-	/* Obtain a reference the phy device */
-	phy_node = of_parse_phandle(dev->of_node, "phy-handle", 0);
-	if (!phy_node) {
-		dev_err(dev, "unable to parse phy-handle\n");
-		ret = -EINVAL;
+	of_dev = of_match_device(xgbe_of_match, dev);
+	if (!of_dev) {
+		ret = -ENODEV;
 		goto err_put;
 	}
+	pdata->drv_level = (enum xgbe_drv_level)of_dev->data;
+
+	if (pdata->drv_level == XGBE_DRV_LEVEL_V1A) {
+		/* Obtain a reference the phy device */
+		phy_node = of_parse_phandle(dev->of_node, "phy-handle", 0);
+		if (!phy_node) {
+			dev_err(dev, "unable to parse phy-handle\n");
+			ret = -EINVAL;
+			goto err_put;
+		}
 
-	phy_pdev = of_find_device_by_node(phy_node);
-	if (!phy_pdev) {
-		dev_err(dev, "unable to locate phy device\n");
-		ret = -EINVAL;
-		goto err_io;
+		phy_pdev = of_find_device_by_node(phy_node);
+		if (!phy_pdev) {
+			dev_err(dev, "unable to locate phy device\n");
+			ret = -EINVAL;
+			goto err_io;
+		}
+
+		mem_resource = 0;
+	} else {
+		phy_node = of_node_get(dev->of_node);
+		phy_pdev = pdev;
+		mem_resource = 2;
 	}
 
 	/* Set and validate the number of descriptors for a ring */
@@ -321,7 +340,7 @@ static int xgbe_probe(struct platform_device *pdev)
 	DBGPR("  xpcs_regs  = %p\n", pdata->xpcs_regs);
 
 	/* Obtain the mmio areas for the phy device */
-	res = platform_get_resource(phy_pdev, IORESOURCE_MEM, 0);
+	res = platform_get_resource(phy_pdev, IORESOURCE_MEM, mem_resource++);
 	pdata->rxtx_regs = devm_ioremap_resource(dev, res);
 	if (IS_ERR(pdata->rxtx_regs)) {
 		dev_err(dev, "rxtx ioremap failed\n");
@@ -330,7 +349,7 @@ static int xgbe_probe(struct platform_device *pdev)
 	}
 	DBGPR("  rxtx_regs  = %p\n", pdata->rxtx_regs);
 
-	res = platform_get_resource(phy_pdev, IORESOURCE_MEM, 1);
+	res = platform_get_resource(phy_pdev, IORESOURCE_MEM, mem_resource++);
 	pdata->sir0_regs = devm_ioremap_nocache(dev, res->start,
 						resource_size(res));
 	if (IS_ERR(pdata->sir0_regs)) {
@@ -340,7 +359,7 @@ static int xgbe_probe(struct platform_device *pdev)
 	}
 	DBGPR("  sir0_regs  = %p\n", pdata->sir0_regs);
 
-	res = platform_get_resource(phy_pdev, IORESOURCE_MEM, 2);
+	res = platform_get_resource(phy_pdev, IORESOURCE_MEM, mem_resource++);
 	pdata->sir1_regs = devm_ioremap_nocache(dev, res->start,
 						resource_size(res));
 	if (IS_ERR(pdata->sir1_regs)) {
@@ -351,13 +370,13 @@ static int xgbe_probe(struct platform_device *pdev)
 	DBGPR("  sir1_regs  = %p\n", pdata->sir1_regs);
 
 	/* Get the device speed set property */
-	property = of_get_property(phy_node, XGBE_PHY_SPEEDSET_PROPERTY, NULL);
+	property = of_get_property(phy_node, XGBE_SPEEDSET_PROPERTY, NULL);
 	if (property)
 		pdata->speed_set = be32_to_cpu(*property);
 
 	switch (pdata->speed_set) {
-	case XGBE_PHY_SPEEDSET_1000_10000:
-	case XGBE_PHY_SPEEDSET_2500_10000:
+	case XGBE_SPEEDSET_1000_10000:
+	case XGBE_SPEEDSET_2500_10000:
 		break;
 	default:
 		dev_err(dev, "invalid amd,speed-set property\n");
@@ -604,7 +623,14 @@ static int xgbe_resume(struct device *dev)
 #endif /* CONFIG_PM */
 
 static const struct of_device_id xgbe_of_match[] = {
-	{ .compatible = "amd,xgbe-seattle-v1a", },
+	{
+		.compatible = "amd,xgbe-seattle-v1a",
+		.data = (void *)XGBE_DRV_LEVEL_V1A,
+	},
+	{
+		.compatible = "amd,xgbe-seattle-v1b",
+		.data = (void *)XGBE_DRV_LEVEL_V1B,
+	},
 	{},
 };
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-phy.c b/drivers/net/ethernet/amd/xgbe/xgbe-phy.c
index 7aca21d..d072201 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-phy.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-phy.c
@@ -469,7 +469,7 @@ static void xgbe_phy_switch_mode(struct phy_device *phydev)
 
 	/* If we are in KR switch to KX, and vice-versa */
 	if (xgbe_phy_in_kr_mode(phydev)) {
-		if (pdata->speed_set == XGBE_PHY_SPEEDSET_1000_10000)
+		if (pdata->speed_set == XGBE_SPEEDSET_1000_10000)
 			xgbe_phy_gmii_mode(phydev);
 		else
 			xgbe_phy_gmii_2500_mode(phydev);
@@ -805,10 +805,10 @@ static int xgbe_phy_config_init(struct phy_device *phydev)
 	phydev->supported |= SUPPORTED_10000baseKR_Full |
 			     SUPPORTED_10000baseR_FEC;
 	switch (pdata->speed_set) {
-	case XGBE_PHY_SPEEDSET_1000_10000:
+	case XGBE_SPEEDSET_1000_10000:
 		phydev->supported |= SUPPORTED_1000baseKX_Full;
 		break;
-	case XGBE_PHY_SPEEDSET_2500_10000:
+	case XGBE_SPEEDSET_2500_10000:
 		phydev->supported |= SUPPORTED_2500baseX_Full;
 		break;
 	}
@@ -981,11 +981,11 @@ static int xgbe_phy_read_status(struct phy_device *phydev)
 			xgbe_phy_set_mode(phydev, XGBE_SPEED_MODE_KR);
 		} else {
 			switch (pdata->speed_set) {
-			case XGBE_PHY_SPEEDSET_1000_10000:
+			case XGBE_SPEEDSET_1000_10000:
 				phydev->speed = SPEED_1000;
 				break;
 
-			case XGBE_PHY_SPEEDSET_2500_10000:
+			case XGBE_SPEEDSET_2500_10000:
 				phydev->speed = SPEED_2500;
 				break;
 			}
@@ -998,11 +998,11 @@ static int xgbe_phy_read_status(struct phy_device *phydev)
 			phydev->speed = SPEED_10000;
 		} else {
 			switch (pdata->speed_set) {
-			case XGBE_PHY_SPEEDSET_1000_10000:
+			case XGBE_SPEEDSET_1000_10000:
 				phydev->speed = SPEED_1000;
 				break;
 
-			case XGBE_PHY_SPEEDSET_2500_10000:
+			case XGBE_SPEEDSET_2500_10000:
 				phydev->speed = SPEED_2500;
 				break;
 			}
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 36f8717..2d057cf 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -174,9 +174,9 @@
 #define XGBE_PTP_CLOCK		"ptp_clk"
 
 /* Device-tree property names/values */
-#define XGBE_PHY_SPEEDSET_PROPERTY	"amd,speed-set"
-#define XGBE_PHY_SPEEDSET_1000_10000	0
-#define XGBE_PHY_SPEEDSET_2500_10000	1
+#define XGBE_SPEEDSET_PROPERTY	"amd,speed-set"
+#define XGBE_SPEEDSET_1000_10000	0
+#define XGBE_SPEEDSET_2500_10000	1
 
 /* Timestamp support - values based on 50MHz PTP clock
  *   50MHz => 20 nsec
@@ -611,11 +611,18 @@ struct xgbe_hw_features {
 	unsigned int aux_snap_num;	/* Number of Aux snapshot inputs */
 };
 
+enum xgbe_drv_level {
+	XGBE_DRV_LEVEL_V1A = 0,
+	XGBE_DRV_LEVEL_V1B,
+};
+
 struct xgbe_prv_data {
 	struct net_device *netdev;
 	struct platform_device *pdev;
 	struct device *dev;
 
+	enum xgbe_drv_level drv_level;
+
 	/* XGMAC/XPCS related mmio registers */
 	void __iomem *xgmac_regs;	/* XGMAC CSRs */
 	void __iomem *xpcs_regs;	/* XPCS MMD registers */
