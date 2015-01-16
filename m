From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 11/12] amd-xgbe: Add ACPI support
Date: Fri, 16 Jan 2015 12:47:16 -0600
Message-ID: <20150116184716.18809.56335.stgit@tlendack-t1.amdoffice.net>
References: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [165.204.77.2] ([165.204.77.2]:44031 "EHLO
	tlendack-t1.amdoffice.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756801AbbAPSyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:54:31 -0500
In-Reply-To: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for ACPI to the amd-xgbe and amd-xgbe-phy drivers. This
support converts many of the device tree APIs to the new device_property
APIs.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/Kconfig          |    2 
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c  |    4 -
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |  202 +++++++++++++++++++++++------
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c |   19 ---
 drivers/net/ethernet/amd/xgbe/xgbe-ptp.c  |    4 -
 drivers/net/ethernet/amd/xgbe/xgbe.h      |   18 ++-
 drivers/net/phy/Kconfig                   |    2 
 drivers/net/phy/amd-xgbe-phy.c            |  128 +++++++++++++-----
 8 files changed, 273 insertions(+), 106 deletions(-)

diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index 7a5e4aa..5d3b520 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -179,7 +179,7 @@ config SUNLANCE
 
 config AMD_XGBE
 	tristate "AMD 10GbE Ethernet driver"
-	depends on OF_NET && HAS_IOMEM
+	depends on (OF_NET || ACPI) && HAS_IOMEM
 	select PHYLIB
 	select AMD_XGBE_PHY
 	select BITREVERSE
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 950ad2e..da593c4 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -131,7 +131,7 @@ static unsigned int xgbe_usec_to_riwt(struct xgbe_prv_data *pdata,
 
 	DBGPR("-->xgbe_usec_to_riwt\n");
 
-	rate = clk_get_rate(pdata->sysclk);
+	rate = pdata->sysclk_rate;
 
 	/*
 	 * Convert the input usec value to the watchdog timer value. Each
@@ -154,7 +154,7 @@ static unsigned int xgbe_riwt_to_usec(struct xgbe_prv_data *pdata,
 
 	DBGPR("-->xgbe_riwt_to_usec\n");
 
-	rate = clk_get_rate(pdata->sysclk);
+	rate = pdata->sysclk_rate;
 
 	/*
 	 * Convert the input watchdog timer value to the usec value. Each
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index a50dccd..32dd651 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -123,7 +123,10 @@
 #include <linux/io.h>
 #include <linux/of.h>
 #include <linux/of_net.h>
+#include <linux/of_address.h>
 #include <linux/clk.h>
+#include <linux/property.h>
+#include <linux/acpi.h>
 
 #include "xgbe.h"
 #include "xgbe-common.h"
@@ -162,6 +165,96 @@ static void xgbe_init_all_fptrs(struct xgbe_prv_data *pdata)
 	xgbe_init_function_ptrs_desc(&pdata->desc_if);
 }
 
+#ifdef CONFIG_ACPI
+static int xgbe_acpi_support(struct xgbe_prv_data *pdata)
+{
+	struct acpi_device *adev = pdata->adev;
+	struct device *dev = pdata->dev;
+	u32 property;
+	acpi_handle handle;
+	acpi_status status;
+	unsigned long long data;
+	int cca;
+	int ret;
+
+	/* Obtain the system clock setting */
+	ret = device_property_read_u32(dev, XGBE_ACPI_DMA_FREQ, &property);
+	if (ret) {
+		dev_err(dev, "unable to obtain %s property\n",
+			XGBE_ACPI_DMA_FREQ);
+		return ret;
+	}
+	pdata->sysclk_rate = property;
+
+	/* Obtain the PTP clock setting */
+	ret = device_property_read_u32(dev, XGBE_ACPI_PTP_FREQ, &property);
+	if (ret) {
+		dev_err(dev, "unable to obtain %s property\n",
+			XGBE_ACPI_PTP_FREQ);
+		return ret;
+	}
+	pdata->ptpclk_rate = property;
+
+	/* Retrieve the device cache coherency value */
+	handle = adev->handle;
+	do {
+		status = acpi_evaluate_integer(handle, "_CCA", NULL, &data);
+		if (!ACPI_FAILURE(status)) {
+			cca = data;
+			break;
+		}
+
+		status = acpi_get_parent(handle, &handle);
+	} while (!ACPI_FAILURE(status));
+
+	if (ACPI_FAILURE(status)) {
+		dev_err(dev, "error obtaining acpi coherency value\n");
+		return -EINVAL;
+	}
+	pdata->coherent = !!cca;
+
+	return 0;
+}
+#else   /* CONFIG_ACPI */
+static int xgbe_acpi_support(struct xgbe_prv_data *pdata)
+{
+	return -EINVAL;
+}
+#endif  /* CONFIG_ACPI */
+
+#ifdef CONFIG_OF
+static int xgbe_of_support(struct xgbe_prv_data *pdata)
+{
+	struct device *dev = pdata->dev;
+
+	/* Obtain the system clock setting */
+	pdata->sysclk = devm_clk_get(dev, XGBE_DMA_CLOCK);
+	if (IS_ERR(pdata->sysclk)) {
+		dev_err(dev, "dma devm_clk_get failed\n");
+		return PTR_ERR(pdata->sysclk);
+	}
+	pdata->sysclk_rate = clk_get_rate(pdata->sysclk);
+
+	/* Obtain the PTP clock setting */
+	pdata->ptpclk = devm_clk_get(dev, XGBE_PTP_CLOCK);
+	if (IS_ERR(pdata->ptpclk)) {
+		dev_err(dev, "ptp devm_clk_get failed\n");
+		return PTR_ERR(pdata->ptpclk);
+	}
+	pdata->ptpclk_rate = clk_get_rate(pdata->ptpclk);
+
+	/* Retrieve the device cache coherency value */
+	pdata->coherent = of_dma_is_coherent(dev->of_node);
+
+	return 0;
+}
+#else   /* CONFIG_OF */
+static int xgbe_of_support(struct xgbe_prv_data *pdata)
+{
+	return -EINVAL;
+}
+#endif  /*CONFIG_OF */
+
 static int xgbe_probe(struct platform_device *pdev)
 {
 	struct xgbe_prv_data *pdata;
@@ -170,7 +263,7 @@ static int xgbe_probe(struct platform_device *pdev)
 	struct net_device *netdev;
 	struct device *dev = &pdev->dev;
 	struct resource *res;
-	const u8 *mac_addr;
+	const char *phy_mode;
 	unsigned int i;
 	int ret;
 
@@ -187,6 +280,7 @@ static int xgbe_probe(struct platform_device *pdev)
 	pdata = netdev_priv(netdev);
 	pdata->netdev = netdev;
 	pdata->pdev = pdev;
+	pdata->adev = ACPI_COMPANION(dev);
 	pdata->dev = dev;
 	platform_set_drvdata(pdev, netdev);
 
@@ -195,6 +289,9 @@ static int xgbe_probe(struct platform_device *pdev)
 	mutex_init(&pdata->rss_mutex);
 	spin_lock_init(&pdata->tstamp_lock);
 
+	/* Check if we should use ACPI or DT */
+	pdata->use_acpi = (!pdata->adev || acpi_disabled) ? 0 : 1;
+
 	/* Set and validate the number of descriptors for a ring */
 	BUILD_BUG_ON_NOT_POWER_OF_2(XGBE_TX_DESC_CNT);
 	pdata->tx_desc_count = XGBE_TX_DESC_CNT;
@@ -213,22 +310,6 @@ static int xgbe_probe(struct platform_device *pdev)
 		goto err_io;
 	}
 
-	/* Obtain the system clock setting */
-	pdata->sysclk = devm_clk_get(dev, XGBE_DMA_CLOCK);
-	if (IS_ERR(pdata->sysclk)) {
-		dev_err(dev, "dma devm_clk_get failed\n");
-		ret = PTR_ERR(pdata->sysclk);
-		goto err_io;
-	}
-
-	/* Obtain the PTP clock setting */
-	pdata->ptpclk = devm_clk_get(dev, XGBE_PTP_CLOCK);
-	if (IS_ERR(pdata->ptpclk)) {
-		dev_err(dev, "ptp devm_clk_get failed\n");
-		ret = PTR_ERR(pdata->ptpclk);
-		goto err_io;
-	}
-
 	/* Obtain the mmio areas for the device */
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	pdata->xgmac_regs = devm_ioremap_resource(dev, res);
@@ -248,16 +329,42 @@ static int xgbe_probe(struct platform_device *pdev)
 	}
 	DBGPR("  xpcs_regs  = %p\n", pdata->xpcs_regs);
 
-	/* Set the DMA mask */
-	if (!dev->dma_mask)
-		dev->dma_mask = &dev->coherent_dma_mask;
-	ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(40));
-	if (ret) {
-		dev_err(dev, "dma_set_mask_and_coherent failed\n");
+	/* Retrieve the MAC address */
+	ret = device_property_read_u8_array(dev, XGBE_MAC_ADDR_PROPERTY,
+					    pdata->mac_addr,
+					    sizeof(pdata->mac_addr));
+	if (ret || !is_valid_ether_addr(pdata->mac_addr)) {
+		dev_err(dev, "invalid %s property\n", XGBE_MAC_ADDR_PROPERTY);
+		if (!ret)
+			ret = -EINVAL;
 		goto err_io;
 	}
 
-	if (of_property_read_bool(dev->of_node, "dma-coherent")) {
+	/* Retrieve the PHY mode - it must be "xgmii" */
+	ret = device_property_read_string(dev, XGBE_PHY_MODE_PROPERTY,
+					  &phy_mode);
+	if (ret || strcmp(phy_mode, phy_modes(PHY_INTERFACE_MODE_XGMII))) {
+		dev_err(dev, "invalid %s property\n", XGBE_PHY_MODE_PROPERTY);
+		if (!ret)
+			ret = -EINVAL;
+		goto err_io;
+	}
+	pdata->phy_mode = PHY_INTERFACE_MODE_XGMII;
+
+	/* Check for per channel interrupt support */
+	if (device_property_present(dev, XGBE_DMA_IRQS_PROPERTY))
+		pdata->per_channel_irq = 1;
+
+	/* Obtain device settings unique to ACPI/OF */
+	if (pdata->use_acpi)
+		ret = xgbe_acpi_support(pdata);
+	else
+		ret = xgbe_of_support(pdata);
+	if (ret)
+		goto err_io;
+
+	/* Set the DMA coherency values */
+	if (pdata->coherent) {
 		pdata->axdomain = XGBE_DMA_OS_AXDOMAIN;
 		pdata->arcache = XGBE_DMA_OS_ARCACHE;
 		pdata->awcache = XGBE_DMA_OS_AWCACHE;
@@ -267,10 +374,16 @@ static int xgbe_probe(struct platform_device *pdev)
 		pdata->awcache = XGBE_DMA_SYS_AWCACHE;
 	}
 
-	/* Check for per channel interrupt support */
-	if (of_property_read_bool(dev->of_node, XGBE_DMA_IRQS))
-		pdata->per_channel_irq = 1;
+	/* Set the DMA mask */
+	if (!dev->dma_mask)
+		dev->dma_mask = &dev->coherent_dma_mask;
+	ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(40));
+	if (ret) {
+		dev_err(dev, "dma_set_mask_and_coherent failed\n");
+		goto err_io;
+	}
 
+	/* Get the device interrupt */
 	ret = platform_get_irq(pdev, 0);
 	if (ret < 0) {
 		dev_err(dev, "platform_get_irq 0 failed\n");
@@ -280,6 +393,7 @@ static int xgbe_probe(struct platform_device *pdev)
 
 	netdev->irq = pdata->dev_irq;
 	netdev->base_addr = (unsigned long)pdata->xgmac_regs;
+	memcpy(netdev->dev_addr, pdata->mac_addr, netdev->addr_len);
 
 	/* Set all the function pointers */
 	xgbe_init_all_fptrs(pdata);
@@ -292,23 +406,6 @@ static int xgbe_probe(struct platform_device *pdev)
 	/* Populate the hardware features */
 	xgbe_get_all_hw_features(pdata);
 
-	/* Retrieve the MAC address */
-	mac_addr = of_get_mac_address(dev->of_node);
-	if (!mac_addr) {
-		dev_err(dev, "invalid mac address for this device\n");
-		ret = -EINVAL;
-		goto err_io;
-	}
-	memcpy(netdev->dev_addr, mac_addr, netdev->addr_len);
-
-	/* Retrieve the PHY mode - it must be "xgmii" */
-	pdata->phy_mode = of_get_phy_mode(dev->of_node);
-	if (pdata->phy_mode != PHY_INTERFACE_MODE_XGMII) {
-		dev_err(dev, "invalid phy-mode specified for this device\n");
-		ret = -EINVAL;
-		goto err_io;
-	}
-
 	/* Set default configuration data */
 	xgbe_default_config(pdata);
 
@@ -492,18 +589,35 @@ static int xgbe_resume(struct device *dev)
 }
 #endif /* CONFIG_PM */
 
+#ifdef CONFIG_ACPI
+static const struct acpi_device_id xgbe_acpi_match[] = {
+	{ "AMDI8001", 0 },
+	{},
+};
+
+MODULE_DEVICE_TABLE(acpi, xgbe_acpi_match);
+#endif
+
+#ifdef CONFIG_OF
 static const struct of_device_id xgbe_of_match[] = {
 	{ .compatible = "amd,xgbe-seattle-v1a", },
 	{},
 };
 
 MODULE_DEVICE_TABLE(of, xgbe_of_match);
+#endif
+
 static SIMPLE_DEV_PM_OPS(xgbe_pm_ops, xgbe_suspend, xgbe_resume);
 
 static struct platform_driver xgbe_driver = {
 	.driver = {
 		.name = "amd-xgbe",
+#ifdef CONFIG_ACPI
+		.acpi_match_table = xgbe_acpi_match,
+#endif
+#ifdef CONFIG_OF
 		.of_match_table = xgbe_of_match,
+#endif
 		.pm = &xgbe_pm_ops,
 	},
 	.probe = xgbe_probe,
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index 41e29e2..59e267f 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -205,25 +205,16 @@ void xgbe_dump_phy_registers(struct xgbe_prv_data *pdata)
 
 int xgbe_mdio_register(struct xgbe_prv_data *pdata)
 {
-	struct device_node *phy_node;
 	struct mii_bus *mii;
 	struct phy_device *phydev;
 	int ret = 0;
 
 	DBGPR("-->xgbe_mdio_register\n");
 
-	/* Retrieve the phy-handle */
-	phy_node = of_parse_phandle(pdata->dev->of_node, "phy-handle", 0);
-	if (!phy_node) {
-		dev_err(pdata->dev, "unable to parse phy-handle\n");
-		return -EINVAL;
-	}
-
 	mii = mdiobus_alloc();
 	if (!mii) {
 		dev_err(pdata->dev, "mdiobus_alloc failed\n");
-		ret = -ENOMEM;
-		goto err_node_get;
+		return -ENOMEM;
 	}
 
 	/* Register on the MDIO bus (don't probe any PHYs) */
@@ -252,12 +243,9 @@ int xgbe_mdio_register(struct xgbe_prv_data *pdata)
 	request_module(MDIO_MODULE_PREFIX MDIO_ID_FMT,
 		       MDIO_ID_ARGS(phydev->c45_ids.device_ids[MDIO_MMD_PCS]));
 
-	of_node_get(phy_node);
-	phydev->dev.of_node = phy_node;
 	ret = phy_device_register(phydev);
 	if (ret) {
 		dev_err(pdata->dev, "phy_device_register failed\n");
-		of_node_put(phy_node);
 		goto err_phy_device;
 	}
 	if (!phydev->dev.driver) {
@@ -287,8 +275,6 @@ int xgbe_mdio_register(struct xgbe_prv_data *pdata)
 
 	pdata->phydev = phydev;
 
-	of_node_put(phy_node);
-
 	DBGPHY_REGS(pdata);
 
 	DBGPR("<--xgbe_mdio_register\n");
@@ -304,9 +290,6 @@ err_mdiobus_register:
 err_mdiobus_alloc:
 	mdiobus_free(mii);
 
-err_node_get:
-	of_node_put(phy_node);
-
 	return ret;
 }
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c b/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
index f5acf4c..f326178 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
@@ -233,7 +233,7 @@ void xgbe_ptp_register(struct xgbe_prv_data *pdata)
 	snprintf(info->name, sizeof(info->name), "%s",
 		 netdev_name(pdata->netdev));
 	info->owner = THIS_MODULE;
-	info->max_adj = clk_get_rate(pdata->ptpclk);
+	info->max_adj = pdata->ptpclk_rate;
 	info->adjfreq = xgbe_adjfreq;
 	info->adjtime = xgbe_adjtime;
 	info->gettime = xgbe_gettime;
@@ -254,7 +254,7 @@ void xgbe_ptp_register(struct xgbe_prv_data *pdata)
 	 */
 	dividend = 50000000;
 	dividend <<= 32;
-	pdata->tstamp_addend = div_u64(dividend, clk_get_rate(pdata->ptpclk));
+	pdata->tstamp_addend = div_u64(dividend, pdata->ptpclk_rate);
 
 	/* Setup the timecounter */
 	cc->read = xgbe_cc_read;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index e6ee64e..13e8f95 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -182,10 +182,18 @@
 #define XGBE_PHY_NAME		"amd_xgbe_phy"
 #define XGBE_PRTAD		0
 
+/* Common property names */
+#define XGBE_MAC_ADDR_PROPERTY	"mac-address"
+#define XGBE_PHY_MODE_PROPERTY	"phy-mode"
+#define XGBE_DMA_IRQS_PROPERTY	"amd,per-channel-interrupt"
+
 /* Device-tree clock names */
 #define XGBE_DMA_CLOCK		"dma_clk"
 #define XGBE_PTP_CLOCK		"ptp_clk"
-#define XGBE_DMA_IRQS		"amd,per-channel-interrupt"
+
+/* ACPI property names */
+#define XGBE_ACPI_DMA_FREQ	"amd,dma-freq"
+#define XGBE_ACPI_PTP_FREQ	"amd,ptp-freq"
 
 /* Timestamp support - values based on 50MHz PTP clock
  *   50MHz => 20 nsec
@@ -645,8 +653,12 @@ struct xgbe_hw_features {
 struct xgbe_prv_data {
 	struct net_device *netdev;
 	struct platform_device *pdev;
+	struct acpi_device *adev;
 	struct device *dev;
 
+	/* ACPI or DT flag */
+	unsigned int use_acpi;
+
 	/* XGMAC/XPCS related mmio registers */
 	void __iomem *xgmac_regs;	/* XGMAC CSRs */
 	void __iomem *xpcs_regs;	/* XPCS MMD registers */
@@ -667,6 +679,7 @@ struct xgbe_prv_data {
 	struct xgbe_desc_if desc_if;
 
 	/* AXI DMA settings */
+	unsigned int coherent;
 	unsigned int axdomain;
 	unsigned int arcache;
 	unsigned int awcache;
@@ -734,6 +747,7 @@ struct xgbe_prv_data {
 	unsigned int phy_rx_pause;
 
 	/* Netdev related settings */
+	unsigned char mac_addr[ETH_ALEN];
 	netdev_features_t netdev_features;
 	struct napi_struct napi;
 	struct xgbe_mmc_stats mmc_stats;
@@ -743,7 +757,9 @@ struct xgbe_prv_data {
 
 	/* Device clocks */
 	struct clk *sysclk;
+	unsigned long sysclk_rate;
 	struct clk *ptpclk;
+	unsigned long ptpclk_rate;
 
 	/* Timestamp support */
 	spinlock_t tstamp_lock;
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index a3c251b..16adbc4 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -26,7 +26,7 @@ config AMD_PHY
 
 config AMD_XGBE_PHY
 	tristate "Driver for the AMD 10GbE (amd-xgbe) PHYs"
-	depends on OF && HAS_IOMEM
+	depends on (OF || ACPI) && HAS_IOMEM
 	---help---
 	  Currently supports the AMD 10GbE PHY
 
diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index e2074c7..2f210743 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -76,6 +76,8 @@
 #include <linux/of_device.h>
 #include <linux/uaccess.h>
 #include <linux/bitops.h>
+#include <linux/property.h>
+#include <linux/acpi.h>
 
 MODULE_AUTHOR("Tom Lendacky <thomas.lendacky@amd.com>");
 MODULE_LICENSE("Dual BSD/GPL");
@@ -323,12 +325,13 @@ enum amd_xgbe_phy_mode {
 };
 
 enum amd_xgbe_phy_speedset {
-	AMD_XGBE_PHY_SPEEDSET_1000_10000,
+	AMD_XGBE_PHY_SPEEDSET_1000_10000 = 0,
 	AMD_XGBE_PHY_SPEEDSET_2500_10000,
 };
 
 struct amd_xgbe_phy_priv {
 	struct platform_device *pdev;
+	struct acpi_device *adev;
 	struct device *dev;
 
 	struct phy_device *phydev;
@@ -1420,46 +1423,94 @@ static int amd_xgbe_phy_resume(struct phy_device *phydev)
 	return 0;
 }
 
+static unsigned int amd_xgbe_phy_resource_count(struct platform_device *pdev,
+						unsigned int type)
+{
+	unsigned int count;
+	int i;
+
+	for (i = 0, count = 0; i < pdev->num_resources; i++) {
+		struct resource *r = &pdev->resource[i];
+
+		if (type == resource_type(r))
+			count++;
+	}
+
+	return count;
+}
+
 static int amd_xgbe_phy_probe(struct phy_device *phydev)
 {
 	struct amd_xgbe_phy_priv *priv;
-	struct platform_device *pdev;
-	struct device *dev;
-	const __be32 *property;
-	unsigned int speed_set;
+	struct platform_device *phy_pdev;
+	struct device *dev, *phy_dev;
+	unsigned int phy_resnum, phy_irqnum;
 	int ret;
 
-	if (!phydev->dev.of_node)
+	if (!phydev->bus || !phydev->bus->parent)
 		return -EINVAL;
 
-	pdev = of_find_device_by_node(phydev->dev.of_node);
-	if (!pdev)
-		return -EINVAL;
-	dev = &pdev->dev;
+	dev = phydev->bus->parent;
 
 	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
-	if (!priv) {
-		ret = -ENOMEM;
-		goto err_pdev;
-	}
+	if (!priv)
+		return -ENOMEM;
 
-	priv->pdev = pdev;
+	priv->pdev = to_platform_device(dev);
+	priv->adev = ACPI_COMPANION(dev);
 	priv->dev = dev;
 	priv->phydev = phydev;
 	mutex_init(&priv->an_mutex);
 	INIT_WORK(&priv->an_irq_work, amd_xgbe_an_irq_work);
 	INIT_WORK(&priv->an_work, amd_xgbe_an_state_machine);
 
+	if (!priv->adev || acpi_disabled) {
+		struct device_node *bus_node;
+		struct device_node *phy_node;
+
+		bus_node = priv->dev->of_node;
+		phy_node = of_parse_phandle(bus_node, "phy-handle", 0);
+		if (!phy_node) {
+			dev_err(dev, "unable to parse phy-handle\n");
+			ret = -EINVAL;
+			goto err_priv;
+		}
+
+		phy_pdev = of_find_device_by_node(phy_node);
+		of_node_put(phy_node);
+
+		if (!phy_pdev) {
+			dev_err(dev, "unable to obtain phy device\n");
+			ret = -EINVAL;
+			goto err_priv;
+		}
+
+		phy_resnum = 0;
+		phy_irqnum = 0;
+	} else {
+		/* In ACPI, the XGBE and PHY resources are the grouped
+		 * together with the PHY resources at the end
+		 */
+		phy_pdev = priv->pdev;
+		phy_resnum = amd_xgbe_phy_resource_count(phy_pdev,
+							 IORESOURCE_MEM) - 3;
+		phy_irqnum = amd_xgbe_phy_resource_count(phy_pdev,
+							 IORESOURCE_IRQ) - 1;
+	}
+	phy_dev = &phy_pdev->dev;
+
 	/* Get the device mmio areas */
-	priv->rxtx_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	priv->rxtx_res = platform_get_resource(phy_pdev, IORESOURCE_MEM,
+					       phy_resnum++);
 	priv->rxtx_regs = devm_ioremap_resource(dev, priv->rxtx_res);
 	if (IS_ERR(priv->rxtx_regs)) {
 		dev_err(dev, "rxtx ioremap failed\n");
 		ret = PTR_ERR(priv->rxtx_regs);
-		goto err_priv;
+		goto err_put;
 	}
 
-	priv->sir0_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	priv->sir0_res = platform_get_resource(phy_pdev, IORESOURCE_MEM,
+					       phy_resnum++);
 	priv->sir0_regs = devm_ioremap_resource(dev, priv->sir0_res);
 	if (IS_ERR(priv->sir0_regs)) {
 		dev_err(dev, "sir0 ioremap failed\n");
@@ -1467,7 +1518,8 @@ static int amd_xgbe_phy_probe(struct phy_device *phydev)
 		goto err_rxtx;
 	}
 
-	priv->sir1_res = platform_get_resource(pdev, IORESOURCE_MEM, 2);
+	priv->sir1_res = platform_get_resource(phy_pdev, IORESOURCE_MEM,
+					       phy_resnum++);
 	priv->sir1_regs = devm_ioremap_resource(dev, priv->sir1_res);
 	if (IS_ERR(priv->sir1_regs)) {
 		dev_err(dev, "sir1 ioremap failed\n");
@@ -1476,7 +1528,7 @@ static int amd_xgbe_phy_probe(struct phy_device *phydev)
 	}
 
 	/* Get the auto-negotiation interrupt */
-	ret = platform_get_irq(pdev, 0);
+	ret = platform_get_irq(phy_pdev, phy_irqnum);
 	if (ret < 0) {
 		dev_err(dev, "platform_get_irq failed\n");
 		goto err_sir1;
@@ -1484,28 +1536,29 @@ static int amd_xgbe_phy_probe(struct phy_device *phydev)
 	priv->an_irq = ret;
 
 	/* Get the device speed set property */
-	speed_set = 0;
-	property = of_get_property(dev->of_node, XGBE_PHY_SPEEDSET_PROPERTY,
-				   NULL);
-	if (property)
-		speed_set = be32_to_cpu(*property);
-
-	switch (speed_set) {
-	case 0:
-		priv->speed_set = AMD_XGBE_PHY_SPEEDSET_1000_10000;
-		break;
-	case 1:
-		priv->speed_set = AMD_XGBE_PHY_SPEEDSET_2500_10000;
+	ret = device_property_read_u32(phy_dev, XGBE_PHY_SPEEDSET_PROPERTY,
+				       &priv->speed_set);
+	if (ret) {
+		dev_err(dev, "invalid %s property\n",
+			XGBE_PHY_SPEEDSET_PROPERTY);
+		goto err_sir1;
+	}
+
+	switch (priv->speed_set) {
+	case AMD_XGBE_PHY_SPEEDSET_1000_10000:
+	case AMD_XGBE_PHY_SPEEDSET_2500_10000:
 		break;
 	default:
-		dev_err(dev, "invalid amd,speed-set property\n");
+		dev_err(dev, "invalid %s property\n",
+			XGBE_PHY_SPEEDSET_PROPERTY);
 		ret = -EINVAL;
 		goto err_sir1;
 	}
 
 	phydev->priv = priv;
 
-	of_dev_put(pdev);
+	if (!priv->adev || acpi_disabled)
+		platform_device_put(phy_pdev);
 
 	return 0;
 
@@ -1524,12 +1577,13 @@ err_rxtx:
 	devm_release_mem_region(dev, priv->rxtx_res->start,
 				resource_size(priv->rxtx_res));
 
+err_put:
+	if (!priv->adev || acpi_disabled)
+		platform_device_put(phy_pdev);
+
 err_priv:
 	devm_kfree(dev, priv);
 
-err_pdev:
-	of_dev_put(pdev);
-
 	return ret;
 }
 
