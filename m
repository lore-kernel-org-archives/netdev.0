From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 1/1] net/macb: add DT support
Date: Mon, 21 Nov 2011 12:08:16 +0100
Message-ID: <4ECA3120.1050902@atmel.com>
References: <1321626565-11261-1-git-send-email-plagnioj@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: devicetree-discuss@ozlabs.org, netdev@vger.kernel.org,
	Jamie Iles <jamie@jamieiles.com>
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from newsmtp5.atmel.com ([204.2.163.5]:64374 "EHLO
	sjogate2.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755625Ab1KULIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 06:08:24 -0500
In-Reply-To: <1321626565-11261-1-git-send-email-plagnioj@jcrosoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2011 03:29 PM, Jean-Christophe PLAGNIOL-VILLARD :
> allow the DT to pass the mac address and the phy mode
> 
> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> Cc: Jamie Iles <jamie@jamieiles.com>
> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
> ---
>  Documentation/devicetree/bindings/net/macb.txt |   22 ++++++++
>  drivers/net/ethernet/cadence/macb.c            |   65 +++++++++++++++++++++---
>  drivers/net/ethernet/cadence/macb.h            |    2 +
>  3 files changed, 81 insertions(+), 8 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/macb.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
> new file mode 100644
> index 0000000..2b727ec
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/macb.txt
> @@ -0,0 +1,22 @@
> +* Cadence EMACB
> +
> +Implemeted on Atmel AT91 & AVR32 SoC

Ditto with Jamie's comments.

> +
> +Required properties:
> +- compatible : Should be "atmel,macb" for Atmel
> +- reg : Address and length of the register set for the device
> +- interrupts : Should contain macb interrupt
> +- phy-mode : String, operation mode of the PHY interface.
> +  Supported values are: "mii", "rmii",
> +
> +Optional properties:
> +- local-mac-address : 6 bytes, mac address
> +
> +Examples:
> +
> +	macb0: macb@fffc4000 {
> +		compatible = "atmel,macb";

Ditto.

> +		reg = <oxfffc4000 0x4000>;
> +		interrupts = <21>;
> +		phy-mode = "mii";
> +	};
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index a437b46..2c345bc 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -20,6 +20,9 @@
>  #include <linux/etherdevice.h>
>  #include <linux/dma-mapping.h>
>  #include <linux/platform_device.h>
> +#include <linux/of.h>
> +#include <linux/of_device.h>
> +#include <linux/of_net.h>
>  #include <linux/phy.h>
>  
>  #include <mach/board.h>
> @@ -81,6 +84,20 @@ static void __init macb_get_hwaddr(struct macb *bp)
>  	addr[4] = top & 0xff;
>  	addr[5] = (top >> 8) & 0xff;
>  
> +#ifdef CONFIG_OF
> +	/*
> +	 * 2) from device tree data
> +	 */
> +	if (!is_valid_ether_addr(addr)) {
> +		struct device_node *np = bp->pdev->dev.of_node;
> +		if (np) {
> +			const char *mac = of_get_mac_address(np);
> +			if (mac)


Maybe here also, check is_valid_ether_addr(mac): it seems safer.


> +				memcpy(addr, mac, sizeof(addr));
> +		}
> +	}
> +#endif
> +
>  	if (is_valid_ether_addr(addr)) {
>  		memcpy(bp->dev->dev_addr, addr, sizeof(addr));
>  	} else {
> @@ -191,7 +208,6 @@ static int macb_mii_probe(struct net_device *dev)
>  {
>  	struct macb *bp = netdev_priv(dev);
>  	struct phy_device *phydev;
> -	struct eth_platform_data *pdata;
>  	int ret;
>  
>  	phydev = phy_find_first(bp->mii_bus);
> @@ -200,14 +216,11 @@ static int macb_mii_probe(struct net_device *dev)
>  		return -1;
>  	}
>  
> -	pdata = bp->pdev->dev.platform_data;
>  	/* TODO : add pin_irq */
>  
>  	/* attach the mac to the phy */
>  	ret = phy_connect_direct(dev, phydev, &macb_handle_link_change, 0,
> -				 pdata && pdata->is_rmii ?
> -				 PHY_INTERFACE_MODE_RMII :
> -				 PHY_INTERFACE_MODE_MII);
> +				 bp->phy_interface);
>  	if (ret) {
>  		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
>  		return ret;
> @@ -1117,6 +1130,30 @@ static const struct net_device_ops macb_netdev_ops = {
>  #endif
>  };
>  
> +#if defined(CONFIG_OF)
> +static const struct of_device_id macb_dt_ids[] = {
> +	{ .compatible = "atmel,macb" },
> +	{ /* sentinel */ }
> +};
> +
> +MODULE_DEVICE_TABLE(of, macb_dt_ids);
> +
> +static int __devinit macb_get_phy_mode_dt(struct platform_device *pdev)
> +{
> +	struct device_node *np = pdev->dev.of_node;
> +
> +	if (np)
> +		return of_get_phy_mode(np);
> +
> +	return -ENODEV;
> +}
> +#else
> +static int __devinit macb_get_phy_mode_dt(struct platform_device *pdev)
> +{
> +	return -ENODEV;
> +}
> +#endif
> +
>  static int __init macb_probe(struct platform_device *pdev)
>  {
>  	struct eth_platform_data *pdata;
> @@ -1210,20 +1247,31 @@ static int __init macb_probe(struct platform_device *pdev)
>  	macb_writel(bp, NCFGR, config);
>  
>  	macb_get_hwaddr(bp);
> -	pdata = pdev->dev.platform_data;
>  
> -	if (pdata && pdata->is_rmii)
> +	err = macb_get_phy_mode_dt(pdev);
> +	if (err < 0) {
> +		pdata = pdev->dev.platform_data;
> +		if (pdata && pdata->is_rmii)
> +			bp->phy_interface = PHY_INTERFACE_MODE_RMII;
> +		else
> +			bp->phy_interface = PHY_INTERFACE_MODE_MII;
> +	} else {
> +		bp->phy_interface = err;
> +	}
> +
> +	if (bp->phy_interface == PHY_INTERFACE_MODE_RMII) {
>  #if defined(CONFIG_ARCH_AT91)
>  		macb_writel(bp, USRIO, (MACB_BIT(RMII) | MACB_BIT(CLKEN)) );
>  #else
>  		macb_writel(bp, USRIO, 0);
>  #endif
> -	else
> +	} else {
>  #if defined(CONFIG_ARCH_AT91)
>  		macb_writel(bp, USRIO, MACB_BIT(CLKEN));
>  #else
>  		macb_writel(bp, USRIO, MACB_BIT(MII));
>  #endif
> +	}
>  
>  	bp->tx_pending = DEF_TX_RING_PENDING;
>  
> @@ -1344,6 +1392,7 @@ static struct platform_driver macb_driver = {
>  	.driver		= {
>  		.name		= "macb",
>  		.owner	= THIS_MODULE,
> +		.of_match_table	= of_match_ptr(macb_dt_ids),
>  	},
>  };
>  
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index d3212f6..8342744 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -389,6 +389,8 @@ struct macb {
>  	unsigned int 		link;
>  	unsigned int 		speed;
>  	unsigned int 		duplex;
> +
> +	phy_interface_t		phy_interface;
>  };
>  
>  #endif /* _MACB_H */


-- 
Nicolas Ferre
