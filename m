From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v5] net: sh_eth: Add support of device tree probe
Date: Tue, 5 Mar 2013 09:43:39 +0900
Message-ID: <20130305004338.GA10651@verge.net.au>
References: <1362433940-20533-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, grant.likely@secretlab.ca,
	kuninori.morimoto.gx@renesas.com,
	devicetree-discuss@lists.ozlabs.org, magnus.damm@gmail.com,
	kda@linux-powerpc.org, Mark Rutland <mark.rutland@arm.com>
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:50782 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932582Ab3CEAnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 19:43:42 -0500
Content-Disposition: inline
In-Reply-To: <1362433940-20533-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Cc: Mark Rutland ]

On Tue, Mar 05, 2013 at 06:52:20AM +0900, Nobuhiro Iwamatsu wrote:
> This adds support of device tree probe for Renesas sh-ether driver.
> 
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

Hi Iwamatsu-san,

could you please address the review by
Mark Rutland of the bindings in this patch.
The review was made for v2 but I believe it
is still applicable to v5.

http://www.spinics.net/lists/netdev/msg226454.html

> V5: - Rewrite sh_eth_parse_dt().
>       Remove of_device_is_available() and CONFIG_OF from support OF
>       checking function and re-add empty sh_eth_parse_dt().
>     - Add CONFIG_PM to definition of dev_pm_ops.
> 	- Add CONFIG_OF to definition of of_device_id.
> V4: - Remove empty sh_eth_parse_dt().
> V3: - Remove empty sh_eth_parse_dt().
> V3: - Removed sentnece of "needs-init" from document.
> V2: - Removed ether_setup().
>     - Fixed typo from "sh-etn" to "sh-eth".
> 	- Removed "needs-init" and sh-eth,endian from definition of DT.
> 	- Changed "sh-eth,edmac-endian" instead of "sh-eth,edmac-big-endain"
> 	  in definition of DT.
> ---
>  Documentation/devicetree/bindings/net/sh_ether.txt |   39 +++++
>  drivers/net/ethernet/renesas/sh_eth.c              |  164 +++++++++++++++++---
>  2 files changed, 178 insertions(+), 25 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/sh_ether.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/sh_ether.txt b/Documentation/devicetree/bindings/net/sh_ether.txt
> new file mode 100644
> index 0000000..2deb841
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/sh_ether.txt
> @@ -0,0 +1,39 @@
> +* Renesas Electronics SuperH EMAC
> +
> +This file provides information, what the device node
> +for the sh_eth interface contains.
> +
> +Required properties:
> +- compatible:                   "renesas,sh-eth";
> +- interrupt-parent:             The phandle for the interrupt controller that
> +                                services interrupts for this device.
> +- reg:                          Offset and length of the register set for the
> +                                device.
> +- interrupts:                   Interrupt mapping for the sh_eth interrupt
> +                                sources (vector id).
> +- phy-mode:                     String, operation mode of the PHY interface.
> +- sh-eth,register-type:         String, register type of sh_eth.
> +                                Please select "gigabit", "fast-sh4" or
> +                                "fast-sh3-sh2".
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
> index 3d70586..a97d208 100644
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
> +	else if (of_str && !strcmp(of_str, "fast-sh4"))
> +		return SH_ETH_REG_FAST_SH4;
> +	else if (of_str && !strcmp(of_str, "fast-sh3-sh2"))
> +		return SH_ETH_REG_FAST_SH3_SH2;
> +	else
> +		return -EINVAL;
> +}
> +
> +static struct sh_eth_plat_data *
> +sh_eth_parse_dt(struct device *dev, struct net_device *ndev,
> +				struct device_node *np)
> +{
> +	int ret;
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
> +
> +	if (of_find_property(np, "sh-eth,edmac-big-endian", NULL))
> +		pdata->edmac_endian = EDMAC_BIG_ENDIAN;
> +	else
> +		pdata->edmac_endian = EDMAC_LITTLE_ENDIAN;
> +
> +	if (of_find_property(np, "sh-eth,no-ether-link", NULL))
> +		pdata->no_ether_link = 1;
> +	else
> +		pdata->no_ether_link = 0;
> +
> +	if (of_find_property(np, "sh-eth,ether-link-active-low", NULL))
> +		pdata->ether_link_active_low = 1;
> +	else
> +		pdata->ether_link_active_low = 0;
> +
> +	ret = sh_eth_of_get_register_type(np);
> +	if (ret < 0)
> +		goto error;
> +	pdata->register_type = ret;
> +
> +#ifdef CONFIG_OF_NET
> +	if (!is_valid_ether_addr(ndev->dev_addr)) {
> +		const char *macaddr = of_get_mac_address(np);
> +		if (macaddr)
> +			memcpy(pdata->mac_addr, macaddr, ETH_ALEN);
> +	}
> +#endif
> +
> +	return pdata;
> +
> +error:
> +	devm_kfree(dev, pdata);
> +	return NULL;
> +}
> +#else
> +static inline struct sh_eth_plat_data *
> +sh_eth_parse_dt(struct device *dev, struct net_device *ndev,
> +				struct device_node *np)
> +{
> +	return NULL;
> +}
> +#endif
> +
>  static int sh_eth_drv_probe(struct platform_device *pdev)
>  {
> -	int ret, devno = 0;
> +	int ret = 0, devno = 0;
>  	struct resource *res;
>  	struct net_device *ndev = NULL;
>  	struct sh_eth_private *mdp = NULL;
>  	struct sh_eth_plat_data *pd;
> +	struct device_node *np = pdev->dev.of_node;
>  
> +	ndev = alloc_etherdev(sizeof(struct sh_eth_private));
> +	if (!ndev) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	mdp = netdev_priv(ndev);
>  	/* get base addr */
>  	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	if (unlikely(res == NULL)) {
>  		dev_err(&pdev->dev, "invalid resource\n");
>  		ret = -EINVAL;
> -		goto out;
> -	}
> -
> -	ndev = alloc_etherdev(sizeof(struct sh_eth_private));
> -	if (!ndev) {
> -		ret = -ENOMEM;
> -		goto out;
> +		goto out_release;
>  	}
>  
>  	/* The sh Ether-specific entries in the device structure. */
> @@ -2383,14 +2472,6 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>  	}
>  	ndev->irq = ret;
>  
> -	SET_NETDEV_DEV(ndev, &pdev->dev);
> -
> -	/* Fill in the fields of the device structure with ethernet values. */
> -	ether_setup(ndev);
> -
> -	mdp = netdev_priv(ndev);
> -	mdp->num_tx_ring = TX_RING_SIZE;
> -	mdp->num_rx_ring = RX_RING_SIZE;
>  	mdp->addr = ioremap(res->start, resource_size(res));
>  	if (mdp->addr == NULL) {
>  		ret = -ENOMEM;
> @@ -2398,12 +2479,33 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>  		goto out_release;
>  	}
>  
> +	if (np) {
> +		pd = sh_eth_parse_dt(&pdev->dev, ndev, np);
> +		if (pdev->dev.platform_data && pd) {
> +			struct sh_eth_plat_data *tmp =
> +				pdev->dev.platform_data;
> +			pd->set_mdio_gate = tmp->set_mdio_gate;
> +			pd->needs_init = tmp->needs_init;
> +		}
> +	} else
> +		pd = pdev->dev.platform_data;
> +
> +	if (!pd) {
> +		dev_err(&pdev->dev, "no setup data defined\n");
> +		ret = -EINVAL;
> +		goto out_release;
> +	}
> +
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +
> +	mdp->num_tx_ring = TX_RING_SIZE;
> +	mdp->num_rx_ring = RX_RING_SIZE;
> +
>  	spin_lock_init(&mdp->lock);
>  	mdp->pdev = pdev;
>  	pm_runtime_enable(&pdev->dev);
>  	pm_runtime_resume(&pdev->dev);
>  
> -	pd = (struct sh_eth_plat_data *)(pdev->dev.platform_data);
>  	/* get PHY ID */
>  	mdp->phy_id = pd->phy;
>  	mdp->phy_interface = pd->phy_interface;
> @@ -2412,6 +2514,8 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>  	mdp->no_ether_link = pd->no_ether_link;
>  	mdp->ether_link_active_low = pd->ether_link_active_low;
>  	mdp->reg_offset = sh_eth_get_register_offset(pd->register_type);
> +	/* read and set MAC address */
> +	read_mac_address(ndev, pd->mac_addr);
>  
>  	/* set cpu data */
>  #if defined(SH_ETH_HAS_BOTH_MODULES)
> @@ -2429,20 +2533,16 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>  	/* debug message level */
>  	mdp->msg_enable = SH_ETH_DEF_MSG_ENABLE;
>  
> -	/* read and set MAC address */
> -	read_mac_address(ndev, pd->mac_addr);
> -
>  	/* ioremap the TSU registers */
>  	if (mdp->cd->tsu) {
>  		struct resource *rtsu;
>  		rtsu = platform_get_resource(pdev, IORESOURCE_MEM, 1);
>  		if (!rtsu) {
>  			dev_err(&pdev->dev, "Not found TSU resource\n");
> -			ret = -ENODEV;
>  			goto out_release;
>  		}
>  		mdp->tsu_addr = ioremap(rtsu->start,
> -					resource_size(rtsu));
> +				resource_size(rtsu));
>  		mdp->port = devno % 2;
>  		ndev->features = NETIF_F_HW_VLAN_FILTER;
>  	}
> @@ -2509,6 +2609,7 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
>  	return 0;
>  }
>  
> +#ifdef CONFIG_PM
>  static int sh_eth_runtime_nop(struct device *dev)
>  {
>  	/*
> @@ -2522,17 +2623,30 @@ static int sh_eth_runtime_nop(struct device *dev)
>  	return 0;
>  }
>  
> -static struct dev_pm_ops sh_eth_dev_pm_ops = {
> +static const struct dev_pm_ops sh_eth_dev_pm_ops = {
>  	.runtime_suspend = sh_eth_runtime_nop,
>  	.runtime_resume = sh_eth_runtime_nop,
>  };
> +#define SH_ETH_PM_OPS (&sh_eth_dev_pm_ops)
> +#else
> +#define SH_ETH_PM_OPS NULL
> +#endif
> +
> +#ifdef CONFIG_OF
> +static const struct of_device_id sh_eth_match[] = {
> +	{ .compatible = "renesas,sh-eth", },
> +	{},
> +};
> +MODULE_DEVICE_TABLE(of, sh_eth_match);
> +#endif
>  
>  static struct platform_driver sh_eth_driver = {
>  	.probe = sh_eth_drv_probe,
>  	.remove = sh_eth_drv_remove,
>  	.driver = {
>  		   .name = CARDNAME,
> -		   .pm = &sh_eth_dev_pm_ops,
> +		   .pm = SH_ETH_PM_OPS,
> +		   .of_match_table = of_match_ptr(sh_eth_match),
>  	},
>  };
>  
> -- 
> 1.7.10.4
> 
