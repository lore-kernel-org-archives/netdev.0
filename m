From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: stmmac: Add Altera's SOCFPGA extensions for GMAC
Date: Thu, 06 Feb 2014 17:07:26 +0400
Message-ID: <52F3890E.2070805@cogentembedded.com>
References: <1391646915-22045-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dinh.linux@gmail.com, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Vince Bridgers <vbridgers2013@gmail.com>
To: dinguyen@altera.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:55068 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbaBFNHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 08:07:00 -0500
Received: by mail-la0-f52.google.com with SMTP id c6so1449831lan.11
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 05:06:59 -0800 (PST)
In-Reply-To: <1391646915-22045-1-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06-02-2014 4:35, dinguyen@altera.com wrote:

> From: Dinh Nguyen <dinguyen@altera.com>

> The GMAC controller on Altera's SOCFPGA requires setting the phy mode
> in a register that exists in the System Manager. This patch sets those
> register through the syscon interface.

> Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Vince Bridgers <vbridgers2013@gmail.com>
> ---
>   arch/arm/boot/dts/socfpga.dtsi                     |    6 +-
>   arch/arm/boot/dts/socfpga_cyclone5.dtsi            |    6 --
>   arch/arm/boot/dts/socfpga_cyclone5_socdk.dts       |   18 ++++
>   arch/arm/boot/dts/socfpga_cyclone5_sockit.dts      |   13 +++
>   drivers/net/ethernet/stmicro/stmmac/Kconfig        |    7 ++
>   drivers/net/ethernet/stmicro/stmmac/Makefile       |    1 +
>   .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |  104 ++++++++++++++++++++
>   drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    4 +
>   .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    1 +
>   9 files changed, 151 insertions(+), 9 deletions(-)
>   create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>
> diff --git a/arch/arm/boot/dts/socfpga.dtsi b/arch/arm/boot/dts/socfpga.dtsi
> index 8c4adb7..895257d 100644
> --- a/arch/arm/boot/dts/socfpga.dtsi
> +++ b/arch/arm/boot/dts/socfpga.dtsi
> @@ -442,7 +442,7 @@
>   				};
>   			};
>
> -		gmac0: ethernet@ff700000 {
> +		gmac0: gmac0@ff700000 {

    Why are you renaming the node from ePAPR compatible name?

>   			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
>   			reg = <0xff700000 0x2000>;
>   			interrupts = <0 115 4>;
> @@ -453,7 +453,7 @@
>   			status = "disabled";
>   		};
>
> -		gmac1: ethernet@ff702000 {
> +		gmac1: gmac1@ff702000 {
>   			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
>   			reg = <0xff702000 0x2000>;
>   			interrupts = <0 120 4>;
> @@ -534,7 +534,7 @@
>   		};
>
>   		rstmgr@ffd05000 {
> -			compatible = "altr,rst-mgr";
> +			compatible = "altr,rst-mgr", "syscon";
>   			reg = <0xffd05000 0x1000>;
>   		};
>
> diff --git a/arch/arm/boot/dts/socfpga_cyclone5.dtsi b/arch/arm/boot/dts/socfpga_cyclone5.dtsi
> index ca41b0e..454148d 100644
> --- a/arch/arm/boot/dts/socfpga_cyclone5.dtsi
> +++ b/arch/arm/boot/dts/socfpga_cyclone5.dtsi
> @@ -39,12 +39,6 @@
>   			};
>   		};
>
> -		ethernet@ff702000 {
> -			phy-mode = "rgmii";
> -			phy-addr = <0xffffffff>; /* probe for phy addr */
> -			status = "okay";
> -		};
> -
>   		timer0@ffc08000 {
>   			clock-frequency = <100000000>;
>   		};
[...]
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> new file mode 100644
> index 0000000..13fa90c
> --- /dev/null
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> @@ -0,0 +1,104 @@
[...]
> +static int socfpga_gmac_init(struct platform_device *pdev, void *priv)
> +{
> +	struct device_node *np = pdev->dev.of_node;
> +	struct regmap *sys_mgr_base_addr;
> +	struct regmap *rst_mgr_base_addr;
> +	int phymode;
> +	u32 ctrl, val, shift = 0;
> +	u32 rstmask = 0;
> +
> +	if (of_machine_is_compatible("altr,socfpga-vt"))
> +		return 0;
> +
> +	phymode = of_get_phy_mode(pdev->dev.of_node);
> +

    I don't think emoty line is needed here.

> +	switch (phymode) {
> +	case PHY_INTERFACE_MODE_RGMII:
> +		val = SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RGMII;
> +		break;
> +	case PHY_INTERFACE_MODE_MII:
> +	case PHY_INTERFACE_MODE_GMII:
> +		val = SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_GMII_MII;
> +		break;
> +	default:
> +		dev_err(&pdev->dev, "bad phy mode %d\n", phymode);
> +		return -EINVAL;
> +	}
[...]
> +	if (streq(np->name, "gmac0"))
> +		rstmask = RSTMGR_PERMODRST_EMAC0;

    Ah, for that you renamed the nodes! Shouldn't this info be placed in some 
node property instead?

> +	else if (streq(np->name, "gmac1")) {
> +		shift = SYSMGR_EMACGRP_CTRL_PHYSEL_WIDTH;
> +		rstmask = RSTMGR_PERMODRST_EMAC1;
> +	} else {
> +		dev_err(&pdev->dev, "Not a valid GMAC!\n");
> +		return -EINVAL;
> +	}
> +
> +	regmap_read(sys_mgr_base_addr, SYSMGR_EMACGRP_CTRL_OFFSET, &ctrl);
> +	ctrl &= ~(SYSMGR_EMACGRP_CTRL_PHYSEL_MASK << shift);
> +	ctrl |= (val << shift);

    () not needed.

> +
> +	regmap_write(sys_mgr_base_addr, SYSMGR_EMACGRP_CTRL_OFFSET, ctrl);
> +
> +	/* Bring the appropriate GMAC out of reset */
> +	regmap_read(rst_mgr_base_addr, SOCFPGA_RSTMGR_MODPERRST, &ctrl);
> +	ctrl &= ~(rstmask);

    Likewise.

[...]

WBR, Sergei
