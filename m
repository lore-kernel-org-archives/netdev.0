From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHi v2] net: sh_eth: Add support of device tree probe
Date: Fri, 15 Feb 2013 16:32:51 +0000
Message-ID: <20130215163251.GA2597@e106331-lin.cambridge.arm.com>
References: <1360803091-26400-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"horms+renesas@verge.net.au" <horms+renesas@verge.net.au>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"magnus.damm@gmail.com" <magnus.damm@gmail.com>,
	"kda@linux-powerpc.org" <kda@linux-powerpc.org>
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:34782 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758501Ab3BOQdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 11:33:10 -0500
Content-Disposition: inline
In-Reply-To: <1360803091-26400-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a couple of comments on the binding and the way it's parsed.

On Thu, Feb 14, 2013 at 12:51:31AM +0000, Nobuhiro Iwamatsu wrote:
> This adds support of device tree probe for Renesas sh-ether driver.
> 
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> 
> ---
> V2: - Removed ether_setup().
>     - Fixed typo from "sh-etn" to "sh-eth".
> 	- Removed "needs-init" and sh-eth,endian from definition of DT.
> 	- Changed "sh-eth,edmac-endian" instead of "sh-eth,edmac-big-endain"
> 	  in definition of DT.
> 
>  Documentation/devicetree/bindings/net/sh_ether.txt |   41 +++++
>  drivers/net/ethernet/renesas/sh_eth.c              |  156 +++++++++++++++++---
>  2 files changed, 173 insertions(+), 24 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/sh_ether.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/sh_ether.txt b/Documentation/devicetree/bindings/net/sh_ether.txt
> new file mode 100644
> index 0000000..7415e54
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/sh_ether.txt
> @@ -0,0 +1,41 @@
> +* Renesas Electronics SuperH EMAC
> +
> +This file provides information, what the device node
> +for the sh_eth interface contains.
> +
> +Required properties:
> +- compatible:                   "renesas,sh-eth";
> +- interrupt-parent:             The phandle for the interrupt controller that
> +                                services interrupts for this device.

Is this really a required property?

As it's a standard property with a well-defined meaning, is it necessary to
document?

> +- reg:                          Offset and length of the register set for the
> +                                device.

The example below shows 2 reg values, yet this implies only one is necessary.

> +- interrupts:                   Interrupt mapping for the sh_eth interrupt
> +                                sources (vector id).

How many interrupts are expected, what are they, and in what order should they be in?

> +- phy-mode:                     String, operation mode of the PHY interface.

What are the valid values for this?

If they're defined in another document, it'd be good to reference it.

> +- sh-eth,register-type:         String, register type of sh_eth.
> +                                Please select "gigabit", "fast-sh4" or
> +                                "fast-sh3-sh2".

Why are these not handled as separate versions using the compatible string to
differentiate them?

[...]

> +- sh-eth,phy-id:                PHY id.
> +
> +Optional properties:
> +- local-mac-address:            6 bytes, mac address
> +- sh-eth,no-ether-link:         Set link control by software. When device does
> +                                not support ether-link, set.
> +- sh-eth,ether-link-active-low: Set link check method.
> +                                When detection of link is treated as active-low,
> +                                set.
> +- sh-eth,edmac-big-endian:      Set big endian for sh_eth dmac.
> +                                It work as little endian when this is not set. 
> +- sh-etn,needs-init:            Initialization flag.
> +                                When initialize device in probing device, set.
> +
> +Example (armadillo800eva):
> +	sh-eth@e9a00000 {
> +		compatible = "renesas,sh-eth";
> +		interrupt-parent = <&intca>;
> +		reg = <0xe9a00000 0x800>, <0xe9a01800 0x800>;
> +		interrupts = <0x500>;
> +		phy-mode = "mii";
> +		sh-eth,register-type = "gigabit";
> +		sh-eth,phy-id = <0>;
> +	};
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 3d70586..15e50b87 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -1,7 +1,7 @@
>  /*
>   *  SuperH Ethernet device driver
>   *
> - *  Copyright (C) 2006-2012 Nobuhiro Iwamatsu
> + *  Copyright (C) 2006-2013 Nobuhiro Iwamatsu
>   *  Copyright (C) 2008-2012 Renesas Solutions Corp.
>   *
>   *  This program is free software; you can redistribute it and/or modify it
> @@ -31,6 +31,12 @@
>  #include <linux/platform_device.h>
>  #include <linux/mdio-bitbang.h>
>  #include <linux/netdevice.h>
> +#include <linux/of.h>
> +#include <linux/of_device.h>
> +#include <linux/of_platform.h>
> +#include <linux/of_address.h>
> +#include <linux/of_irq.h>
> +#include <linux/of_net.h>
>  #include <linux/phy.h>
>  #include <linux/cache.h>
>  #include <linux/io.h>
> @@ -2347,26 +2353,109 @@ static const struct net_device_ops sh_eth_netdev_ops = {
>  	.ndo_change_mtu		= eth_change_mtu,
>  };
>  
> +#ifdef CONFIG_OF
> +
> +static int
> +sh_eth_of_get_register_type(struct device_node *np)
> +{
> +	const char *of_str;
> +	int ret = of_property_read_string(np, "sh-eth,register-type", &of_str);
> +	if (ret)
> +		return ret;
> +
> +	if (of_str && !strcmp(of_str, "gigabit"))
> +		return SH_ETH_REG_GIGABIT;
> +

This line space between the if and the else should disappear.

> +	else if (of_str && !strcmp(of_str, "fast-sh4"))
> +		return SH_ETH_REG_FAST_SH4;
> +	else if (of_str && !strcmp(of_str, "fast-sh3-sh2"))
> +		return SH_ETH_REG_FAST_SH3_SH2;
> +	else
> +		return -EINVAL;

I think this block is better handled using a compatible string.

> +}
> +
> +static struct sh_eth_plat_data *
> +sh_eth_parse_dt(struct device *dev, struct net_device *ndev)
> +{
> +	int ret;
> +	struct device_node *np = dev->of_node;
> +	struct sh_eth_plat_data *pdata;
> +
> +	pdata = devm_kzalloc(dev, sizeof(struct sh_eth_plat_data),
> +					GFP_KERNEL);
> +	if (!pdata) {
> +		dev_err(dev, "%s: failed to allocate config data\n", __func__);
> +		return NULL;
> +	}
> +
> +	pdata->phy_interface = of_get_phy_mode(np);
> +
> +	of_property_read_u32(np, "sh-eth,phy-id", &pdata->phy);

No sanity checking required?

Is there a maximum possible PHY id?

> +
> +	if (of_find_property(np, "sh-eth,edmac-big-endian", NULL))
> +		pdata->edmac_endian = EDMAC_BIG_ENDIAN;
> +	else
> +		pdata->edmac_endian = EDMAC_LITTLE_ENDIAN;

You can use of_property_read_bool here.

> +
> +	if (of_find_property(np, "sh-eth,no-ether-link", NULL))
> +		pdata->no_ether_link = 1;
> +	else
> +		pdata->no_ether_link = 0;

This can be:

pdata->no_ether_link = of_property_read_bool(np, "sh-eth,no-ether-link");

> +
> +	if (of_find_property(np, "sh-eth,ether-link-active-low", NULL))
> +		pdata->ether_link_active_low = 1;
> +	else
> +		pdata->ether_link_active_low = 0;

A similar thing can be done here.

> +
> +	ret = sh_eth_of_get_register_type(np);
> +	if (ret < 0)
> +		goto error;
> +	pdata->register_type = ret;

This could be done using the compatible string and some auxdata.

[...]

Thanks,
Mark.
