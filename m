From: Dinh Nguyen <dinh.linux@gmail.com>
Subject: Re: stmmac-socfpga breakage in arm-soc
Date: Wed, 19 Mar 2014 08:33:28 -0500
Message-ID: <53299CA8.607@gmail.com>
References: <201403191333.01095.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hans de Goede <hdegoede@redhat.com>, arm@kernel.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>, Dinh Nguyen <dinguyen@altera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201403191333.01095.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

On 03/19/2014 07:33 AM, Arnd Bergmann wrote:
> Hi Dinh,
>
> I just merged your stmmac socfpga glue driver with Ack from
> David Miller, but then found multiple issues with it. I've
> attempted to fix them up in an untested patch below, which
> I could apply on top, if everyone thinks this is a good idea.
>
> If we can't get agreement on this, it's probably better if
> we revery your stmmac series for now and try to get it
> right for 3.16.
>
> On a more general note about the stmmac driver, I think it
> should be restructured into a base 'library' driver and
> multiple front-ends per SoC or interface (PCI, platform-generic,
> sun7i, socfpga, sti, spear, ...) that can be built as
> modules, like we do for other drivers that get reused a lot
> with smaller variations.
>
> Any comments?
>
> ---
>  From f9e2d095026531ffaecda84daedf275735622cb1 Mon Sep 17 00:00:00 2001
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Wed, 19 Mar 2014 12:57:05 +0100
> Subject: [PATCH] net: stmmac: improve binding and fix build
>
> The new stmmac front-end for socfpga caused build failures
> for modular drivers, e.g. 'make allmodconfig', which prompted
> me to look closer into it. I found that both the DT binding
> and the implementation of the driver are rather nonstandard
> and do things very different from the other SoC specific glue
> drivers for stmmac.
>
> This puts things back in order, hopefully fixing all the
> important issues:
>
> * Replaced the parent/child DT nodes with a combined node
> * Renamed the device node from 'ethernet0' to 'ethernet'
>    as the standard name.
> * Removed interrupt-names and clock-names properties that
>    are not documented in the binding and not used.
> * Added a new DWMAC_SOCFPGA Kconfig symbol to control
>    compilation of this driver

The v1 of this patch had this had this Kconfig symbol and is
similar to your proposed fix.

http://marc.info/?l=linux-netdev&m=139167062725242&w=2


> * Removed code related to scanning the DT nodes that
>    are no longer there.
> * Replaced platform_driver and module stuff with call from
>    main stmmac driver.
> * Removed bogus of_machine_is_compatible("altr,socfpga-vt"))
>    check that should be handled through separate compatible
>    properties of the dwmac node itself.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>
> diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> index d53d376..ec216e0 100644
> --- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> +++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> @@ -1,35 +1,25 @@
>   Altera SOCFPGA SoC DWMAC controller
>
> -The device node has following properties.
> +This is a variant of the dwmac/stmmac driver an inherits all descriptions
> +present in Documentation/devicetree/bindings/net/stmmac.txt.
> +
> +The device node has additional properties:
>
>   Required properties:
> - - compatible	: Should contain "altr,socfpga-stmmac"
> + - compatible	: Should contain "altr,socfpga-stmmac" along with
> +		  "snps,dwmac" and any applicable more detailed
> +		  designware version numbers documented in stmmac.txt
>    - altr,sysmgr-syscon : Should be the phandle to the system manager node that
>      encompasses the glue register, and the register offset.
>
> -Sub-nodes:
> -The dwmac core should be added as subnode to SOCFPGA dwmac glue.
> -- dwmac :	The binding details of dwmac can be found in
> -  Documentation/devicetree/bindings/net/stmmac.txt
> -
>   Example:
>
> -ethernet0: ethernet0 {
> -	#address-cells = <1>;
> -	#size-cells = <1>;
> -
> -	compatible = "altr,socfpga-stmmac";
> +gmac0: ethernet@ff700000 {
> +	compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
>   	altr,sysmgr-syscon = <&sysmgr 0x60>;
>   	status = "disabled";
> -	ranges;
> -
> -	gmac0: gmac0@ff700000 {
> -		compatible = "snps,dwmac-3.70a", "snps,dwmac";
> -		reg = <0xff700000 0x2000>;
> -		interrupts = <0 115 4>;
> -		interrupt-names = "macirq";
> -		mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
> -		clocks = <&emac0_clk>;
> -		clock-names = "stmmaceth";
> -	};
> +	reg = <0xff700000 0x2000>;
> +	interrupts = <0 115 4>;
> +	mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
> +	clocks = <&emac0_clk>;
>   };
> diff --git a/arch/arm/boot/dts/socfpga.dtsi b/arch/arm/boot/dts/socfpga.dtsi
> index 6d7eaa4..1595712 100644
> --- a/arch/arm/boot/dts/socfpga.dtsi
> +++ b/arch/arm/boot/dts/socfpga.dtsi
> @@ -451,43 +451,24 @@
>   				};
>   			};
>
> -		ethernet0: ethernet0 {
> -			#address-cells = <1>;
> -			#size-cells = <1>;
> -			compatible = "altr,socfpga-stmmac";
> -			altr,sysmgr-syscon = <&sysmgr 0x60>;
> +		gmac0: ethernet@ff700000 {
> +			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
>   			status = "disabled";
> -			ranges;
> -
> -			gmac0: gmac0@ff700000 {
> -				compatible = "snps,dwmac-3.70a", "snps,dwmac";
> -				reg = <0xff700000 0x2000>;
> -				interrupts = <0 115 4>;
> -				interrupt-names = "macirq";
> -				mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
> -				clocks = <&emac0_clk>;
> -				clock-names = "stmmaceth";
> -			};
> +			altr,sysmgr-syscon = <&sysmgr 0x60>;
> +			reg = <0xff700000 0x2000>;
> +			interrupts = <0 115 4>;
> +			mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
> +			clocks = <&emac0_clk>;
>   		};
>
> -		ethernet1: ethernet1 {
> -			#address-cells = <1>;
> -			#size-cells = <1>;
> -			compatible = "altr,socfpga-stmmac";
> -			altr,sysmgr-syscon = <&sysmgr 0x60>;
> +		gmac1: ethernet@ff702000 {
> +			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
>   			status = "disabled";
> -			ranges;
> -
> -			gmac1: gmac1@ff702000 {
> -				device_type = "network";
> -				compatible = "snps,dwmac-3.70a", "snps,dwmac";
> -				reg = <0xff702000 0x2000>;
> -				interrupts = <0 120 4>;
> -				interrupt-names = "macirq";
> -				mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
> -				clocks = <&emac1_clk>;
> -				clock-names = "stmmaceth";
> -			};
> +			altr,sysmgr-syscon = <&sysmgr 0x60>;
> +			reg = <0xff702000 0x2000>;
> +			interrupts = <0 120 4>;
> +			mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
> +			clocks = <&emac1_clk>;
>   		};
>
>   		L2: l2-cache@fffef000 {
> diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
> index f2d7c70..f8d5112 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
> +++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
> @@ -26,6 +26,16 @@ config STMMAC_PLATFORM
>
>   	  If unsure, say N.
>
> +config DWMAC_SOCFPGA
> +	bool "SOCFPGA dwmac support"
> +	depends on STMMAC_PLATFORM && MFD_SYSCON && (ARCH_SOCFPGA || COMPILE_TEST)
> +	help
> +	  Support for ethernet controller on Altera SOCFPGA
> +
> +	  This selects the Altera SOCFGA SoC glue layer support
> +	  for the stmmac device driver. This driver is used for
> +	  arria5 and cyclone5 FPGA SoCs.
> +
>   config DWMAC_SUNXI
>   	bool "Allwinner GMAC support"
>   	depends on STMMAC_PLATFORM && ARCH_SUNXI
> diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
> index fd5e48d..18695eb 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/Makefile
> +++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
> @@ -1,9 +1,9 @@
>   obj-$(CONFIG_STMMAC_ETH) += stmmac.o
> -stmmac-$(CONFIG_ARCH_SOCFPGA) += dwmac-socfpga.o
>   stmmac-$(CONFIG_STMMAC_PLATFORM) += stmmac_platform.o
>   stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
>   stmmac-$(CONFIG_DWMAC_SUNXI) += dwmac-sunxi.o
>   stmmac-$(CONFIG_DWMAC_STI) += dwmac-sti.o
> +stmmac-$(CONFIG_DWMAC_SOCFPGA) += dwmac-socfpga.o
>   stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
>   	      chain_mode.o dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o \
>   	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> index c7f034b..dd3de82 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> @@ -40,30 +40,16 @@ struct socfpga_dwmac {
>   	u32	reg_offset;
>   	struct	device *dev;
>   	struct regmap *sys_mgr_base_addr;
> -	struct	device_node *dwmac_np;
>   };
>
>   static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *dev)
>   {
>   	struct device_node *np	= dev->of_node;
> -	struct device_node *stmmac_np;
>   	struct regmap *sys_mgr_base_addr;
>   	u32 reg_offset;
>   	int ret;
>
> -	stmmac_np = of_get_next_available_child(np, NULL);
> -	if (!stmmac_np) {
> -		dev_info(dev, "No dwmac node found\n");
> -		return -EINVAL;
> -	}
> -
> -	if (!of_device_is_compatible(stmmac_np, "snps,dwmac")) {
> -		dev_info(dev, "dwmac node isn't compatible with snps,dwmac\n");
> -		return -EINVAL;
> -	}
> -
> -	dwmac->interface = of_get_phy_mode(stmmac_np);
> -	of_node_put(stmmac_np);
> +	dwmac->interface = of_get_phy_mode(np);
>
>   	sys_mgr_base_addr = syscon_regmap_lookup_by_phandle(np, "altr,sysmgr-syscon");
>   	if (IS_ERR(sys_mgr_base_addr)) {
> @@ -79,7 +65,6 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
>
>   	dwmac->reg_offset = reg_offset;
>   	dwmac->sys_mgr_base_addr = sys_mgr_base_addr;
> -	dwmac->dwmac_np = stmmac_np;
>   	dwmac->dev = dev;
>
>   	return 0;
> @@ -92,9 +77,6 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
>   	u32 reg_offset = dwmac->reg_offset;
>   	u32 ctrl, val, shift = 0;
>
> -	if (of_machine_is_compatible("altr,socfpga-vt"))
> -		return 0;
> -
>   	switch (phymode) {
>   	case PHY_INTERFACE_MODE_RGMII:
>   		val = SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RGMII;
> @@ -116,68 +98,31 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
>   	return 0;
>   }
>
> -static int socfpga_dwmac_probe(struct platform_device *pdev)
> +static void *socfpga_dwmac_probe(struct platform_device *pdev)
>   {
>   	struct device		*dev = &pdev->dev;
> -	struct device_node	*node = dev->of_node;
> -	int			ret = -ENOMEM;
> +	int			ret;
>   	struct socfpga_dwmac	*dwmac;
>
>   	dwmac = devm_kzalloc(dev, sizeof(*dwmac), GFP_KERNEL);
>   	if (!dwmac)
> -		return -ENOMEM;
> +		return ERR_PTR(-ENOMEM);
>
>   	ret = socfpga_dwmac_parse_data(dwmac, dev);
>   	if (ret) {
>   		dev_err(dev, "Unable to parse OF data\n");
> -		return ret;
> +		return ERR_PTR(ret);
>   	}
>
>   	ret = socfpga_dwmac_setup(dwmac);
>   	if (ret) {
>   		dev_err(dev, "couldn't setup SoC glue (%d)\n", ret);
> -		return ret;
> -	}
> -
> -	if (node) {
> -		ret = of_platform_populate(node, NULL, NULL, dev);
> -		if (ret) {
> -			dev_err(dev, "failed to add dwmac core\n");
> -			return ret;
> -		}
> -	} else {
> -		dev_err(dev, "no device node, failed to add dwmac core\n");
> -		return -ENODEV;
> +		return ERR_PTR(ret);
>   	}
>
> -	platform_set_drvdata(pdev, dwmac);
> -
> -	return 0;
> +	return dwmac;
>   }
>
> -static int socfpga_dwmac_remove(struct platform_device *pdev)
> -{
> -	return 0;
> -}
> -
> -static const struct of_device_id socfpga_dwmac_match[] = {
> -	{ .compatible = "altr,socfpga-stmmac" },
> -	{},
> -};
> -MODULE_DEVICE_TABLE(of, socfpga_dwmac_match);
> -
> -static struct platform_driver socfpga_dwmac_driver = {
> -	.probe		= socfpga_dwmac_probe,
> -	.remove		= socfpga_dwmac_remove,
> -	.driver		= {
> -		.name	= "socfpga-dwmac",
> -		.of_match_table = of_match_ptr(socfpga_dwmac_match),
> -	},
> +const struct stmmac_of_data socfpga_gmac_data = {
> +	.setup = socfpga_dwmac_probe,	
>   };
> -
> -module_platform_driver(socfpga_dwmac_driver);
> -
> -MODULE_ALIAS("platform:socfpga-dwmac");
> -MODULE_AUTHOR("Dinh Nguyen <dinguyen@altera.com>");
> -MODULE_LICENSE("GPL v2");
> -MODULE_DESCRIPTION("Altera SOCFPGA DWMAC Glue Layer");
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> index f9e60d7..cd2f6a1 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> @@ -136,6 +136,7 @@ extern const struct stmmac_of_data sun7i_gmac_data;
>   #ifdef CONFIG_DWMAC_STI
>   extern const struct stmmac_of_data sti_gmac_data;
>   #endif
> +extern const struct stmmac_of_data socfpga_gmac_data;

I think I need to wrap this around CONFIG_DWMAC_SOFPGA as well.

>   extern struct platform_driver stmmac_pltfr_driver;
>   static inline int stmmac_register_platform(void)
>   {
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 8fb32a8..46aef510 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -38,6 +38,9 @@ static const struct of_device_id stmmac_dt_ids[] = {
>   	{ .compatible = "st,stih416-dwmac", .data = &sti_gmac_data},
>   	{ .compatible = "st,stid127-dwmac", .data = &sti_gmac_data},
>   #endif
> +#ifdef CONFIG_DWMAC_SOCFPGA
> +	{ .compatible = "altr,socfpga-stmmac", .data = &socfpga_gmac_data },
> +#endif
>   	/* SoC specific glue layers should come before generic bindings */
>   	{ .compatible = "st,spear600-gmac"},
>   	{ .compatible = "snps,dwmac-3.610"},


If it's okay with you Arnd, can I take this patch and add on top of it 
as it is also breaking dtb builds:

Error: arch/arm/boot/dts/socfpga_arria5_socdk.dts:51.2-3 label or path, 
'ethernet1', not found
FATAL ERROR: Syntax error parsing input tree
Error: arch/arm/boot/dts/socfpga_cyclone5_socdk.dts:44.2-3 label or 
path, 'ethernet1', not found
FATAL ERROR: Syntax error parsing input tree
make[1]: *** [arch/arm/boot/dts/socfpga_arria5_socdk.dtb] Error 1
make[1]: *** Waiting for unfinished jobs....
make[1]: *** [arch/arm/boot/dts/socfpga_cyclone5_socdk.dtb] Error 1
Error: arch/arm/boot/dts/socfpga_cyclone5_sockit.dts:44.2-3 label or 
path, 'ethernet1', not found
FATAL ERROR: Syntax error parsing input tree
make[1]: *** [arch/arm/boot/dts/socfpga_cyclone5_sockit.dtb] Error 1
Error: arch/arm/boot/dts/socfpga_vt.dts:92.2-3 label or path, 
'ethernet0', not found

Thanks,
Dinh
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>
