From: Feng Kan <fkan@apm.com>
Subject: [PATCH V3] net: eth: xgene: change APM X-Gene SoC platform ethernet to support ACPI
Date: Tue,  6 Jan 2015 15:41:33 -0700
Message-ID: <1420584093-19236-1-git-send-email-fkan@apm.com>
Cc: Feng Kan <fkan@apm.com>
To: patches@apm.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds support for APM X-Gene ethernet driver to use ACPI table to derive
ethernet driver parameter.

Signed-off-by: Feng Kan <fkan@apm.com>
---
V3:
   - Fix compile error caught by allmodconfig
V2:
   - remove NO_MAC define
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   |   94 ++++++++++++++++------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c |   97 +++++++++++++++++-----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h |    3 +
 3 files changed, 150 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 7ba83ff..869d97f 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -593,10 +593,12 @@ static int xgene_enet_reset(struct xgene_enet_pdata *pdata)
 	if (!xgene_ring_mgr_init(pdata))
 		return -ENODEV;
 
-	clk_prepare_enable(pdata->clk);
-	clk_disable_unprepare(pdata->clk);
-	clk_prepare_enable(pdata->clk);
-	xgene_enet_ecc_init(pdata);
+	if (!efi_enabled(EFI_BOOT)) {
+		clk_prepare_enable(pdata->clk);
+		clk_disable_unprepare(pdata->clk);
+		clk_prepare_enable(pdata->clk);
+		xgene_enet_ecc_init(pdata);
+	}
 	xgene_enet_config_ring_if_assoc(pdata);
 
 	/* Enable auto-incr for scanning */
@@ -663,15 +665,20 @@ static int xgene_enet_phy_connect(struct net_device *ndev)
 	struct phy_device *phy_dev;
 	struct device *dev = &pdata->pdev->dev;
 
-	phy_np = of_parse_phandle(dev->of_node, "phy-handle", 0);
-	if (!phy_np) {
-		netdev_dbg(ndev, "No phy-handle found\n");
-		return -ENODEV;
+	if (dev->of_node) {
+		phy_np = of_parse_phandle(dev->of_node, "phy-handle", 0);
+		if (!phy_np) {
+			netdev_dbg(ndev, "No phy-handle found in DT\n");
+			return -ENODEV;
+		}
+		pdata->phy_dev = of_phy_find_device(phy_np);
 	}
 
-	phy_dev = of_phy_connect(ndev, phy_np, &xgene_enet_adjust_link,
-				 0, pdata->phy_mode);
-	if (!phy_dev) {
+	phy_dev = pdata->phy_dev;
+
+	if (!phy_dev ||
+	    phy_connect_direct(ndev, phy_dev, &xgene_enet_adjust_link,
+			       pdata->phy_mode)) {
 		netdev_err(ndev, "Could not connect to PHY\n");
 		return  -ENODEV;
 	}
@@ -681,32 +688,71 @@ static int xgene_enet_phy_connect(struct net_device *ndev)
 			      ~SUPPORTED_100baseT_Half &
 			      ~SUPPORTED_1000baseT_Half;
 	phy_dev->advertising = phy_dev->supported;
-	pdata->phy_dev = phy_dev;
 
 	return 0;
 }
 
-int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata)
+static int xgene_mdiobus_register(struct xgene_enet_pdata *pdata,
+				  struct mii_bus *mdio)
 {
-	struct net_device *ndev = pdata->ndev;
 	struct device *dev = &pdata->pdev->dev;
+	struct net_device *ndev = pdata->ndev;
+	struct phy_device *phy;
 	struct device_node *child_np;
 	struct device_node *mdio_np = NULL;
-	struct mii_bus *mdio_bus;
 	int ret;
+	u32 phy_id;
+
+	if (dev->of_node) {
+		for_each_child_of_node(dev->of_node, child_np) {
+			if (of_device_is_compatible(child_np,
+						    "apm,xgene-mdio")) {
+				mdio_np = child_np;
+				break;
+			}
+		}
 
-	for_each_child_of_node(dev->of_node, child_np) {
-		if (of_device_is_compatible(child_np, "apm,xgene-mdio")) {
-			mdio_np = child_np;
-			break;
+		if (!mdio_np) {
+			netdev_dbg(ndev, "No mdio node in the dts\n");
+			return -ENXIO;
 		}
-	}
 
-	if (!mdio_np) {
-		netdev_dbg(ndev, "No mdio node in the dts\n");
-		return -ENXIO;
+		return of_mdiobus_register(mdio, mdio_np);
 	}
 
+	/* Mask out all PHYs from auto probing. */
+	mdio->phy_mask = ~0;
+
+	/* Register the MDIO bus */
+	ret = mdiobus_register(mdio);
+	if (ret)
+		return ret;
+
+	ret = device_property_read_u32(dev, "phy-channel", &phy_id);
+	if (ret)
+		ret = device_property_read_u32(dev, "phy-addr", &phy_id);
+	if (ret)
+		return -EINVAL;
+
+	phy = get_phy_device(mdio, phy_id, true);
+	if (!phy || IS_ERR(phy))
+		return -EIO;
+
+	ret = phy_device_register(phy);
+	if (ret)
+		phy_device_free(phy);
+	else
+		pdata->phy_dev = phy;
+
+	return ret;
+}
+
+int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata)
+{
+	struct net_device *ndev = pdata->ndev;
+	struct mii_bus *mdio_bus;
+	int ret;
+
 	mdio_bus = mdiobus_alloc();
 	if (!mdio_bus)
 		return -ENOMEM;
@@ -720,7 +766,7 @@ int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata)
 	mdio_bus->priv = pdata;
 	mdio_bus->parent = &ndev->dev;
 
-	ret = of_mdiobus_register(mdio_bus, mdio_np);
+	ret = xgene_mdiobus_register(pdata, mdio_bus);
 	if (ret) {
 		netdev_err(ndev, "Failed to register MDIO bus\n");
 		mdiobus_free(mdio_bus);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 83a5028..1e56bf3 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -24,6 +24,10 @@
 #include "xgene_enet_sgmac.h"
 #include "xgene_enet_xgmac.h"
 
+#define RES_ENET_CSR	0
+#define RES_RING_CSR	1
+#define RES_RING_CMD	2
+
 static void xgene_enet_init_bufpool(struct xgene_enet_desc_ring *buf_pool)
 {
 	struct xgene_enet_raw_desc16 *raw_desc;
@@ -746,6 +750,41 @@ static const struct net_device_ops xgene_ndev_ops = {
 	.ndo_set_mac_address = xgene_enet_set_mac_address,
 };
 
+static int xgene_get_mac_address(struct device *dev,
+				 unsigned char *addr)
+{
+	int ret;
+
+	ret = device_property_read_u8_array(dev, "local-mac-address", addr, 6);
+	if (ret)
+		ret = device_property_read_u8_array(dev, "mac-address",
+						    addr, 6);
+	if (ret)
+		return -ENODEV;
+
+	return ETH_ALEN;
+}
+
+static int xgene_get_phy_mode(struct device *dev)
+{
+	int i, ret;
+	char *modestr;
+
+	ret = device_property_read_string(dev, "phy-connection-type",
+					  (const char **)&modestr);
+	if (ret)
+		ret = device_property_read_string(dev, "phy-mode",
+						  (const char **)&modestr);
+	if (ret)
+		return -ENODEV;
+
+	for (i = 0; i < PHY_INTERFACE_MODE_MAX; i++) {
+		if (!strcasecmp(modestr, phy_modes(i)))
+			return i;
+	}
+	return -ENODEV;
+}
+
 static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 {
 	struct platform_device *pdev;
@@ -753,29 +792,42 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	struct device *dev;
 	struct resource *res;
 	void __iomem *base_addr;
-	const char *mac;
 	int ret;
 
 	pdev = pdata->pdev;
 	dev = &pdev->dev;
 	ndev = pdata->ndev;
 
-	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "enet_csr");
-	pdata->base_addr = devm_ioremap_resource(dev, res);
+	res = platform_get_resource(pdev, IORESOURCE_MEM, RES_ENET_CSR);
+	if (!res) {
+		dev_err(dev, "Resource enet_csr not defined\n");
+		return -ENODEV;
+	}
+	pdata->base_addr = devm_ioremap(dev, res->start, resource_size(res));
 	if (IS_ERR(pdata->base_addr)) {
 		dev_err(dev, "Unable to retrieve ENET Port CSR region\n");
 		return PTR_ERR(pdata->base_addr);
 	}
 
-	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "ring_csr");
-	pdata->ring_csr_addr = devm_ioremap_resource(dev, res);
+	res = platform_get_resource(pdev, IORESOURCE_MEM, RES_RING_CSR);
+	if (!res) {
+		dev_err(dev, "Resource ring_csr not defined\n");
+		return -ENODEV;
+	}
+	pdata->ring_csr_addr = devm_ioremap(dev, res->start,
+							resource_size(res));
 	if (IS_ERR(pdata->ring_csr_addr)) {
 		dev_err(dev, "Unable to retrieve ENET Ring CSR region\n");
 		return PTR_ERR(pdata->ring_csr_addr);
 	}
 
-	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "ring_cmd");
-	pdata->ring_cmd_addr = devm_ioremap_resource(dev, res);
+	res = platform_get_resource(pdev, IORESOURCE_MEM, RES_RING_CMD);
+	if (!res) {
+		dev_err(dev, "Resource ring_cmd not defined\n");
+		return -ENODEV;
+	}
+	pdata->ring_cmd_addr = devm_ioremap(dev, res->start,
+							resource_size(res));
 	if (IS_ERR(pdata->ring_cmd_addr)) {
 		dev_err(dev, "Unable to retrieve ENET Ring command region\n");
 		return PTR_ERR(pdata->ring_cmd_addr);
@@ -789,14 +841,12 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	}
 	pdata->rx_irq = ret;
 
-	mac = of_get_mac_address(dev->of_node);
-	if (mac)
-		memcpy(ndev->dev_addr, mac, ndev->addr_len);
-	else
+	if (xgene_get_mac_address(dev, ndev->dev_addr) != ETH_ALEN)
 		eth_hw_addr_random(ndev);
+
 	memcpy(ndev->perm_addr, ndev->dev_addr, ndev->addr_len);
 
-	pdata->phy_mode = of_get_phy_mode(pdev->dev.of_node);
+	pdata->phy_mode = xgene_get_phy_mode(dev);
 	if (pdata->phy_mode < 0) {
 		dev_err(dev, "Unable to get phy-connection-type\n");
 		return pdata->phy_mode;
@@ -809,11 +859,9 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	}
 
 	pdata->clk = devm_clk_get(&pdev->dev, NULL);
-	ret = IS_ERR(pdata->clk);
 	if (IS_ERR(pdata->clk)) {
-		dev_err(&pdev->dev, "can't get clock\n");
-		ret = PTR_ERR(pdata->clk);
-		return ret;
+		/* Firmware may have set up the clock already. */
+		pdata->clk = NULL;
 	}
 
 	base_addr = pdata->base_addr;
@@ -924,7 +972,7 @@ static int xgene_enet_probe(struct platform_device *pdev)
 		goto err;
 	}
 
-	ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64));
+	ret = dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(64));
 	if (ret) {
 		netdev_err(ndev, "No usable DMA configuration\n");
 		goto err;
@@ -972,17 +1020,26 @@ static int xgene_enet_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static struct of_device_id xgene_enet_match[] = {
+#ifdef CONFIG_ACPI
+static const struct acpi_device_id xgene_enet_acpi_match[] = {
+	{ "APMC0D05", },
+	{ }
+};
+MODULE_DEVICE_TABLE(acpi, xgene_enet_acpi_match);
+#endif
+
+static struct of_device_id xgene_enet_of_match[] = {
 	{.compatible = "apm,xgene-enet",},
 	{},
 };
 
-MODULE_DEVICE_TABLE(of, xgene_enet_match);
+MODULE_DEVICE_TABLE(of, xgene_enet_of_match);
 
 static struct platform_driver xgene_enet_driver = {
 	.driver = {
 		   .name = "xgene-enet",
-		   .of_match_table = xgene_enet_match,
+		   .of_match_table = of_match_ptr(xgene_enet_of_match),
+		   .acpi_match_table = ACPI_PTR(xgene_enet_acpi_match),
 	},
 	.probe = xgene_enet_probe,
 	.remove = xgene_enet_remove,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index f9958fa..c2d465c 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -22,7 +22,10 @@
 #ifndef __XGENE_ENET_MAIN_H__
 #define __XGENE_ENET_MAIN_H__
 
+#include <linux/acpi.h>
 #include <linux/clk.h>
+#include <linux/efi.h>
+#include <linux/io.h>
 #include <linux/of_platform.h>
 #include <linux/of_net.h>
 #include <linux/of_mdio.h>
-- 
1.7.1
