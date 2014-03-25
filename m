From: <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] net: stmmac: improve binding and fix build
Date: Tue, 25 Mar 2014 18:34:40 -0500
Message-ID: <1395790482-3957-2-git-send-email-dinguyen@altera.com>
References: <1395790482-3957-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <arm-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dinh Nguyen <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
To: <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1395790482-3957-1-git-send-email-dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dinh Nguyen <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>

The new stmmac front-end for socfpga caused build failures
for modular drivers, e.g. 'make allmodconfig', which prompted
me to look closer into it. I found that both the DT binding
and the implementation of the driver are rather nonstandard
and do things very different from the other SoC specific glue
drivers for stmmac.

This puts things back in order, hopefully fixing all the
important issues:

* Added a new DWMAC_SOCFPGA Kconfig symbol to control
  compilation of this driver
* Removed code related to scanning the DT nodes that
  are no longer there.
* Replaced platform_driver and module stuff with call from
  main stmmac driver.
* Removed bogus of_machine_is_compatible("altr,socfpga-vt"))
  check that should be handled through separate compatible
  properties of the dwmac node itself.

This aligns the socfpga stmmac front-end to the sunxi and sti platforms.

Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Signed-off-by: Dinh Nguyen <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   10 +++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    2 +-
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |   73 +++-----------------
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    1 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    3 +
 5 files changed, 24 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index f2d7c70..f8d5112 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -26,6 +26,16 @@ config STMMAC_PLATFORM
 
 	  If unsure, say N.
 
+config DWMAC_SOCFPGA
+	bool "SOCFPGA dwmac support"
+	depends on STMMAC_PLATFORM && MFD_SYSCON && (ARCH_SOCFPGA || COMPILE_TEST)
+	help
+	  Support for ethernet controller on Altera SOCFPGA
+
+	  This selects the Altera SOCFGA SoC glue layer support
+	  for the stmmac device driver. This driver is used for
+	  arria5 and cyclone5 FPGA SoCs.
+
 config DWMAC_SUNXI
 	bool "Allwinner GMAC support"
 	depends on STMMAC_PLATFORM && ARCH_SUNXI
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index fd5e48d..18695eb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -1,9 +1,9 @@
 obj-$(CONFIG_STMMAC_ETH) += stmmac.o
-stmmac-$(CONFIG_ARCH_SOCFPGA) += dwmac-socfpga.o
 stmmac-$(CONFIG_STMMAC_PLATFORM) += stmmac_platform.o
 stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
 stmmac-$(CONFIG_DWMAC_SUNXI) += dwmac-sunxi.o
 stmmac-$(CONFIG_DWMAC_STI) += dwmac-sti.o
+stmmac-$(CONFIG_DWMAC_SOCFPGA) += dwmac-socfpga.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 	      chain_mode.o dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o \
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index c7f034b..f27336c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -40,30 +40,16 @@ struct socfpga_dwmac {
 	u32	reg_offset;
 	struct	device *dev;
 	struct regmap *sys_mgr_base_addr;
-	struct	device_node *dwmac_np;
 };
 
 static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *dev)
 {
 	struct device_node *np	= dev->of_node;
-	struct device_node *stmmac_np;
 	struct regmap *sys_mgr_base_addr;
 	u32 reg_offset;
 	int ret;
 
-	stmmac_np = of_get_next_available_child(np, NULL);
-	if (!stmmac_np) {
-		dev_info(dev, "No dwmac node found\n");
-		return -EINVAL;
-	}
-
-	if (!of_device_is_compatible(stmmac_np, "snps,dwmac")) {
-		dev_info(dev, "dwmac node isn't compatible with snps,dwmac\n");
-		return -EINVAL;
-	}
-
-	dwmac->interface = of_get_phy_mode(stmmac_np);
-	of_node_put(stmmac_np);
+	dwmac->interface = of_get_phy_mode(np);
 
 	sys_mgr_base_addr = syscon_regmap_lookup_by_phandle(np, "altr,sysmgr-syscon");
 	if (IS_ERR(sys_mgr_base_addr)) {
@@ -79,7 +65,6 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 
 	dwmac->reg_offset = reg_offset;
 	dwmac->sys_mgr_base_addr = sys_mgr_base_addr;
-	dwmac->dwmac_np = stmmac_np;
 	dwmac->dev = dev;
 
 	return 0;
@@ -92,9 +77,6 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
 	u32 reg_offset = dwmac->reg_offset;
 	u32 ctrl, val, shift = 0;
 
-	if (of_machine_is_compatible("altr,socfpga-vt"))
-		return 0;
-
 	switch (phymode) {
 	case PHY_INTERFACE_MODE_RGMII:
 		val = SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RGMII;
@@ -116,68 +98,31 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
 	return 0;
 }
 
-static int socfpga_dwmac_probe(struct platform_device *pdev)
+static void *socfpga_dwmac_probe(struct platform_device *pdev)
 {
 	struct device		*dev = &pdev->dev;
-	struct device_node	*node = dev->of_node;
-	int			ret = -ENOMEM;
+	int			ret;
 	struct socfpga_dwmac	*dwmac;
 
 	dwmac = devm_kzalloc(dev, sizeof(*dwmac), GFP_KERNEL);
 	if (!dwmac)
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 
 	ret = socfpga_dwmac_parse_data(dwmac, dev);
 	if (ret) {
 		dev_err(dev, "Unable to parse OF data\n");
-		return ret;
+		return ERR_PTR(ret);
 	}
 
 	ret = socfpga_dwmac_setup(dwmac);
 	if (ret) {
 		dev_err(dev, "couldn't setup SoC glue (%d)\n", ret);
-		return ret;
-	}
-
-	if (node) {
-		ret = of_platform_populate(node, NULL, NULL, dev);
-		if (ret) {
-			dev_err(dev, "failed to add dwmac core\n");
-			return ret;
-		}
-	} else {
-		dev_err(dev, "no device node, failed to add dwmac core\n");
-		return -ENODEV;
+		return ERR_PTR(ret);
 	}
 
-	platform_set_drvdata(pdev, dwmac);
-
-	return 0;
+	return dwmac;
 }
 
-static int socfpga_dwmac_remove(struct platform_device *pdev)
-{
-	return 0;
-}
-
-static const struct of_device_id socfpga_dwmac_match[] = {
-	{ .compatible = "altr,socfpga-stmmac" },
-	{},
-};
-MODULE_DEVICE_TABLE(of, socfpga_dwmac_match);
-
-static struct platform_driver socfpga_dwmac_driver = {
-	.probe		= socfpga_dwmac_probe,
-	.remove		= socfpga_dwmac_remove,
-	.driver		= {
-		.name	= "socfpga-dwmac",
-		.of_match_table = of_match_ptr(socfpga_dwmac_match),
-	},
+const struct stmmac_of_data socfpga_gmac_data = {
+	.setup = socfpga_dwmac_probe,
 };
-
-module_platform_driver(socfpga_dwmac_driver);
-
-MODULE_ALIAS("platform:socfpga-dwmac");
-MODULE_AUTHOR("Dinh Nguyen <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>");
-MODULE_LICENSE("GPL v2");
-MODULE_DESCRIPTION("Altera SOCFPGA DWMAC Glue Layer");
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index f9e60d7..cd2f6a1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -136,6 +136,7 @@ extern const struct stmmac_of_data sun7i_gmac_data;
 #ifdef CONFIG_DWMAC_STI
 extern const struct stmmac_of_data sti_gmac_data;
 #endif
+extern const struct stmmac_of_data socfpga_gmac_data;
 extern struct platform_driver stmmac_pltfr_driver;
 static inline int stmmac_register_platform(void)
 {
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index c61bc72b..8894697 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -38,6 +38,9 @@ static const struct of_device_id stmmac_dt_ids[] = {
 	{ .compatible = "st,stih416-dwmac", .data = &sti_gmac_data},
 	{ .compatible = "st,stih127-dwmac", .data = &sti_gmac_data},
 #endif
+#ifdef CONFIG_DWMAC_SOCFPGA
+	{ .compatible = "altr,socfpga-stmmac", .data = &socfpga_gmac_data },
+#endif
 	/* SoC specific glue layers should come before generic bindings */
 	{ .compatible = "st,spear600-gmac"},
 	{ .compatible = "snps,dwmac-3.610"},
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
