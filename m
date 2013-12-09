From: srinivas kandagatla <srinivas.kandagatla@st.com>
Subject: Re: [PATCH 04/10] net: stmmac: sunxi platfrom extensions for GMAC
 in Allwinner A20 SoC's
Date: Mon, 9 Dec 2013 11:10:36 +0000
Message-ID: <52A5A52C.50605@st.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org> <1386350983-13281-5-git-send-email-wens@csie.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	<netdev@vger.kernel.org>, Rob Herring <rob.herring@calxeda.com>,
	<devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <linux-sunxi@googlegroups.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: Chen-Yu Tsai <wens@csie.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog121.obsmtp.com ([207.126.144.151]:54381 "EHLO
	eu1sys200aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932387Ab3LILQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 06:16:50 -0500
In-Reply-To: <1386350983-13281-5-git-send-email-wens@csie.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chen,
Good to know that Allwinner uses gmac.

On ST SoC, we have very similar requirements, before we merge any of
these changes I think we need to come up with common way to solve both
Allwinner and ST SOCs use cases.

I have already posted few patches on to net-dev
http://lkml.org/lkml/2013/11/12/243 to add Glue driver on top of stmmac
driver.


There are few reasons for the way I have done it.

1> I did not want to modify gmac driver in any sense to when a new SOC
support is added.
2> As the SOC specific glue logic sits on top of standard GMAC IP, it
makes sense to represent it proper harware hierarchy.
3> Did not want to change any generic gmac bindings for SOC specific
stuff as requirements if SOC glue would be very different in each case.

I see issues with this approach, which are addressed in my patches.

Please have a look at the http://lkml.org/lkml/2013/11/12/462 patch on
STi SOC glue, which does implement a very similar glue driver.

Do you see any issues not to do that way?

On 06/12/13 17:29, Chen-Yu Tsai wrote:
> The Allwinner A20 has an ethernet controller that seems to be
> an early version of Synopsys DesignWare MAC 10/100/1000 Universal,
> which is supported by the stmmac driver.
> 
> Allwinner's GMAC requires setting additional registers in the SoC's
> clock control unit.
> 
> The exact version of the DWMAC IP that Allwinner uses is unknown,
> thus the exact feature set is unknown.
> 
> Signed-off-by: Chen-Yu Tsai <wens@csie.org>
> ---
>  .../bindings/net/allwinner,sun7i-gmac.txt          | 22 +++++++
>  drivers/net/ethernet/stmicro/stmmac/Kconfig        | 12 ++++
>  drivers/net/ethernet/stmicro/stmmac/Makefile       |  1 +
>  drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c  | 76 ++++++++++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  3 +lot
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  3 +
>  6 files changed, 117 insertions(+)
> http://lkml.org/lkml/2013/11/12/462
> diff --git a/Documentation/devicetree/bindings/net/allwinner,sun7i-gmac.txt b/Documentation/devicetree/bindings/net/allwinner,sun7i-gmac.txt

> --- /dev/null
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
> @@ -0,0 +1,76 @@
> +/**
> + * dwmac-sunxi.c - Allwinner sunxi DWMAC specific glue layer
> + *
> + * Copyright (C) 2013 Chen-Yu Tsai
> + *
> + * Chen-Yu Tsai  <wens@csie.org>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, orhttp://lkml.org/lkml/2013/11/12/462
> + * (at your option) any later version.
> + *http://lkml.org/lkml/2013/11/12/462
> + * This program is distributed in the hope that it will be useful,http://lkml.org/lkml/2013/11/12/462
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#include <linux/clk.h>
> +#include <linux/phy.h>
> +#include <linux/stmmac.h>
> +
> +#define GMAC_IF_TYPE_RGMII	0x4
> +
> +#define GMAC_TX_CLK_MASK	0x3
> +#define GMAC_TX_CLK_MII		0x0
> +#define GMAC_TX_CLK_RGMII_INT	0x2
> +
> +static int sun7i_gmac_init(struct platform_device *pdev)
> +{
> +	struct resource *res;
> +	struct device *dev = &pdev->dev;
> +	void __iomem *addr = NULL;
> +	struct plat_stmmacenet_data *plat_dat = NULL;
> +	u32 priv_clk_reg;
> +
> +	plat_dat = dev_get_platdata(&pdev->dev);
This is not valid for DT case.
In DT case stmmac maintains its own instance of platform data.

Setting platform data dynamically after probe to a device is not the
right way to do.

> +	if (!plat_dat)
> +		return -EINVAL;
> +
> +	/* Get GMAC clock register in CCU */
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> +	addr = devm_ioremap_resource(dev, res);
> +	if (IS_ERR(addr))
> +		return PTR_ERR(addr);
> +
> +	priv_clk_reg = readl(addr);
> +
> +	/* Set GMAC interface port mode */
> +	if (plat_dat->interface == PHY_INTERFACE_MODE_RGMII)
> +		priv_clk_reg |= GMAC_IF_TYPE_RGMII;
> +	else
> +		priv_clk_reg &= ~GMAC_IF_TYPE_RGMII;
> +
> +	/* Set GMAC transmit clock source. */
> +	priv_clk_reg &= ~GMAC_TX_CLK_MASK;
> +	if (plat_dat->interface == PHY_INTERFACE_MODE_RGMII
> +			|| plat_dat->interface == PHY_INTERFACE_MODE_GMII)
> +		priv_clk_reg |= GMAC_TX_CLK_RGMII_INT;
> +	else
> +		priv_clk_reg |= GMAC_TX_CLK_MII;
> +
> +	writel(priv_clk_reg, addr);
> +
> +	/* mask out phy addr 0x0 */
> +	plat_dat->mdio_bus_data->phy_mask = 0x1;
> +per
> +	return 0;
> +}
> +
This routine would not scale..

stmmac can call init function multiple times, so you would be parsing DT
and also remapping the address multiple times.


[---
> +const struct plat_stmmacenet_data sun7i_gmac_data = {
> +	.has_gmac = 1,
> +	.tx_coe = 1,
> +	.init = sun7i_gmac_init,
> +};
> +
---]

This looks exactly like a AUXDATA way of doing things.
Again stmmac driver has to make a copy of this so that I would not get a
same copy for multiple instances.

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> index f16a9bd..c6e1f93 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> @@ -130,6 +130,9 @@ void stmmac_disable_eee_mode(struct stmmac_priv *priv);
>  bool stmmac_eee_init(struct stmmac_priv *priv);
>  


[...
>  #ifdef CONFIG_STMMAC_PLATFORM
> +#ifdef CONFIG_DWMAC_SUNXI
> +extern const struct plat_stmmacenet_data sun7i_gmac_data;
> +#endif
>  extern struct platform_driver stmmac_pltfr_driver;
>  static inline int stmmac_register_platform(void)
>  {
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index df3fd1c..6cf8292 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -35,6 +35,9 @@ static const struct of_device_id stmmac_dt_ids[] = {
>  	{ .compatible = "snps,dwmac-3.70a"},
>  	{ .compatible = "snps,dwmac-3.710"},
>  	{ .compatible = "snps,dwmac"},
> +#ifdef CONFIG_DWMAC_SUNXI
> +	{ .compatible = "allwinner,sun7i-gmac", .data = &sun7i_gmac_data},
> +#endif
...]

Personally, I did not want to do this kind of stuff in stmmac, As this
list would keep growing, and this file need to be edited for every new
SOC or every different type of glue logic.

Please let me know what your opnion on doing Allwinner glue driver in
line with http://lkml.org/lkml/2013/11/12/462


Thanks,
srini

>  	{ /* sentinel */ }
>  };
>  MODULE_DEVICE_TABLE(of, stmmac_dt_ids);
> 
