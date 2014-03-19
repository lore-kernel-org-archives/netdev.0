From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: stmmac-socfpga breakage in arm-soc
Date: Wed, 19 Mar 2014 16:07:21 +0100
Message-ID: <4171731.dt8xNWCpb2@wuerfel>
References: <201403191333.01095.arnd@arndb.de> <4337501.shzGE38xmF@wuerfel> <5329A7A1.20606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Dinh Nguyen <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>,
	Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, arm-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5329A7A1.20606-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 19 March 2014 09:20:17 Dinh Nguyen wrote:
> 
> Peppe asked me to remove DWMAC_SOCFPGA Koption and take the dwmac-sti.c
> file as an example, which I did. The original patch for dwmac-sti.c had 
> just a CONFIG_ARCH_STI Kconfig option and not CONFIG_DWMAC_STI.
> 
> http://marc.info/?l=linux-netdev&m=138426461307138&w=2
> 
> I'm sorry I did not follow the later versions of dwmac-sti.c.

Ok, so the two of you basically moved in opposite directions where
Srinivas started out with the method you ended up with and vice versa.

I think we've almost sorted things out now. I'll put this patch
into a temporary branch now so it shows up in tomorrow's linux-next,
and hopefully give us a working 'allmodconfig' build, but I'd hope
to get some more Acks for the final version, especially since the
patch is becoming larger than I hoped for now and we're very close
to the merge window.

	Arnd



>From b3bd053625ce2632eea035de4b320d32f14ef615 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date: Wed, 19 Mar 2014 12:57:05 +0100
Subject: [PATCH] net: stmmac: improve binding and fix build

The new stmmac front-end for socfpga caused build failures
for modular drivers, e.g. 'make allmodconfig', which prompted
me to look closer into it. I found that both the DT binding
and the implementation of the driver are rather nonstandard
and do things very different from the other SoC specific glue
drivers for stmmac.

This puts things back in order, hopefully fixing all the
important issues:

* Replaced the parent/child DT nodes with a combined node
* Renamed the device node from 'ethernet0' to 'ethernet'
  as the standard name.
* Documented the clock-names string.
* Added a new DWMAC_SOCFPGA Kconfig symbol to control
  compilation of this driver
* Removed code related to scanning the DT nodes that
  are no longer there.
* Replaced platform_driver and module stuff with call from
  main stmmac driver.
* Removed bogus of_machine_is_compatible("altr,socfpga-vt"))
  check that should be handled through separate compatible
  properties of the dwmac node itself.

Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
index d53d376..f7aa231 100644
--- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
@@ -1,35 +1,27 @@
 Altera SOCFPGA SoC DWMAC controller
 
-The device node has following properties.
+This is a variant of the dwmac/stmmac driver an inherits all descriptions
+present in Documentation/devicetree/bindings/net/stmmac.txt.
+
+The device node has additional properties:
 
 Required properties:
- - compatible	: Should contain "altr,socfpga-stmmac"
+ - compatible	: Should contain "altr,socfpga-stmmac" along with
+		  "snps,dwmac" and any applicable more detailed
+		  designware version numbers documented in stmmac.txt
  - altr,sysmgr-syscon : Should be the phandle to the system manager node that
    encompasses the glue register, and the register offset.
 
-Sub-nodes:
-The dwmac core should be added as subnode to SOCFPGA dwmac glue.
-- dwmac :	The binding details of dwmac can be found in
-  Documentation/devicetree/bindings/net/stmmac.txt
-
 Example:
 
-ethernet0: ethernet0 {
-	#address-cells = <1>;
-	#size-cells = <1>;
-
-	compatible = "altr,socfpga-stmmac";
+gmac0: ethernet@ff700000 {
+	compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
 	altr,sysmgr-syscon = <&sysmgr 0x60>;
 	status = "disabled";
-	ranges;
-
-	gmac0: gmac0@ff700000 {
-		compatible = "snps,dwmac-3.70a", "snps,dwmac";
-		reg = <0xff700000 0x2000>;
-		interrupts = <0 115 4>;
-		interrupt-names = "macirq";
-		mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
-		clocks = <&emac0_clk>;
-		clock-names = "stmmaceth";
-	};
+	reg = <0xff700000 0x2000>;
+	interrupts = <0 115 4>;
+	interrupt-names = "macirq";
+	mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
+	clocks = <&emac0_clk>;
+	clocks-names = ""stmmaceth";
 };
diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 5748351..19d5648 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -31,6 +31,10 @@ Optional properties:
 - reset-names: Should contain the reset signal name "stmmaceth", if a
 	reset phandle is given
 - max-frame-size: See ethernet.txt file in the same directory
+- clocks: If present, the first clock should be the GMAC main clock,
+  further clocks may be specified in derived bindings
+- clock-names: One name for each entry in the clocks property, the
+  first one should be "stmmaceth".
 
 Examples:
 
@@ -43,4 +47,6 @@ Examples:
 		mac-address = [000000000000]; /* Filled in by U-Boot */
 		max-frame-size = <3800>;
 		phy-mode = "gmii";
+		clocks = <&clock>;
+		clock-names = "stmmaceth">
 	};
diff --git a/arch/arm/boot/dts/socfpga.dtsi b/arch/arm/boot/dts/socfpga.dtsi
index 6d7eaa4..982649e 100644
--- a/arch/arm/boot/dts/socfpga.dtsi
+++ b/arch/arm/boot/dts/socfpga.dtsi
@@ -451,43 +451,28 @@
 				};
 			};
 
-		ethernet0: ethernet0 {
-			#address-cells = <1>;
-			#size-cells = <1>;
-			compatible = "altr,socfpga-stmmac";
-			altr,sysmgr-syscon = <&sysmgr 0x60>;
+		gmac0: ethernet@ff700000 {
+			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
 			status = "disabled";
-			ranges;
-
-			gmac0: gmac0@ff700000 {
-				compatible = "snps,dwmac-3.70a", "snps,dwmac";
-				reg = <0xff700000 0x2000>;
-				interrupts = <0 115 4>;
-				interrupt-names = "macirq";
-				mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
-				clocks = <&emac0_clk>;
-				clock-names = "stmmaceth";
-			};
+			altr,sysmgr-syscon = <&sysmgr 0x60>;
+			reg = <0xff700000 0x2000>;
+			interrupts = <0 115 4>;
+			interrupt-names = "macirq";
+			mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
+			clocks = <&emac0_clk>;
+			clock-names = "stmmaceth";
 		};
 
-		ethernet1: ethernet1 {
-			#address-cells = <1>;
-			#size-cells = <1>;
-			compatible = "altr,socfpga-stmmac";
-			altr,sysmgr-syscon = <&sysmgr 0x60>;
+		gmac1: ethernet@ff702000 {
+			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
 			status = "disabled";
-			ranges;
-
-			gmac1: gmac1@ff702000 {
-				device_type = "network";
-				compatible = "snps,dwmac-3.70a", "snps,dwmac";
-				reg = <0xff702000 0x2000>;
-				interrupts = <0 120 4>;
-				interrupt-names = "macirq";
-				mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
-				clocks = <&emac1_clk>;
-				clock-names = "stmmaceth";
-			};
+			altr,sysmgr-syscon = <&sysmgr 0x60>;
+			reg = <0xff702000 0x2000>;
+			interrupts = <0 120 4>;
+			interrupt-names = "macirq";
+			mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
+			clocks = <&emac1_clk>;
+			clock-names = "stmmaceth";
 		};
 
 		L2: l2-cache@fffef000 {
diff --git a/arch/arm/boot/dts/socfpga_arria5_socdk.dts b/arch/arm/boot/dts/socfpga_arria5_socdk.dts
index 2d6b38b..a87ee1c 100644
--- a/arch/arm/boot/dts/socfpga_arria5_socdk.dts
+++ b/arch/arm/boot/dts/socfpga_arria5_socdk.dts
@@ -46,11 +46,8 @@
 	};
 };
 
-&ethernet1 {
-	status = "okay";
-};
-
 &gmac1 {
+	status = "okay";
 	phy-mode = "rgmii";
 
 	rxd0-skew-ps = <0>;
diff --git a/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts b/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
index 26c63a0..ae16d97 100644
--- a/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
+++ b/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
@@ -39,11 +39,8 @@
 	};
 };
 
-&ethernet1 {
-	status = "okay";
-};
-
 &gmac1 {
+	status = "okay";
 	phy-mode = "rgmii";
 
 	rxd0-skew-ps = <0>;
diff --git a/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts b/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
index 469bb5c..b79e2a2 100644
--- a/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
+++ b/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
@@ -39,11 +39,8 @@
 	};
 };
 
-&ethernet1 {
-	status = "okay";
-};
-
 &gmac1 {
+	status = "okay";
 	phy-mode = "rgmii";
 
 	rxd0-skew-ps = <0>;
diff --git a/arch/arm/boot/dts/socfpga_vt.dts b/arch/arm/boot/dts/socfpga_vt.dts
index 91f6ccf..0f33f2f 100644
--- a/arch/arm/boot/dts/socfpga_vt.dts
+++ b/arch/arm/boot/dts/socfpga_vt.dts
@@ -87,10 +87,7 @@
 	};
 };
 
-&ethernet0 {
-        status = "okay";
-};
-
 &gmac0 {
+        status = "okay";
 	phy-mode = "gmii";
 };
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
index c7f034b..dd3de82 100644
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
index 8fb32a8..46aef510 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -38,6 +38,9 @@ static const struct of_device_id stmmac_dt_ids[] = {
 	{ .compatible = "st,stih416-dwmac", .data = &sti_gmac_data},
 	{ .compatible = "st,stid127-dwmac", .data = &sti_gmac_data},
 #endif
+#ifdef CONFIG_DWMAC_SOCFPGA
+	{ .compatible = "altr,socfpga-stmmac", .data = &socfpga_gmac_data },
+#endif
 	/* SoC specific glue layers should come before generic bindings */
 	{ .compatible = "st,spear600-gmac"},
 	{ .compatible = "snps,dwmac-3.610"},

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
