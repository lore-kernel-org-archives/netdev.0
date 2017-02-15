From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: ethernet: cadence: Add fixed-link functionality
Date: Wed, 15 Feb 2017 12:57:49 -0800
Message-ID: <4c9ab5ff-36d7-cdfd-3a10-bf2604d4dd3e@gmail.com>
References: <1487191445-5353-1-git-send-email-mdf@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, moritz.fischer@ettus.com,
        Nicolas Ferre <nicolas.ferre@microchip.com>
To: mdf@kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487191445-5353-1-git-send-email-mdf@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/15/2017 12:44 PM, mdf@kernel.org wrote:
> From: Moritz Fischer <mdf@kernel.org>
> 
> This allows 'fixed-link' direct MAC connections to be declared
> in devicetree.
> 
> Signed-off-by: Moritz Fischer <mdf@kernel.org>
> Cc: Nicolas Ferre <nicolas.ferre@microchip.com>
> ---
>  drivers/net/ethernet/cadence/macb.c | 61 ++++++++++++++++++++++++++++++++++---
>  drivers/net/ethernet/cadence/macb.h |  1 +
>  2 files changed, 57 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 30606b1..af443a8 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -469,6 +469,34 @@ static int macb_mii_probe(struct net_device *dev)
>  	return 0;
>  }
>  
> +static int macb_fixed_init(struct macb *bp)
> +{
> +	struct phy_device *phydev;
> +
> +	phydev = of_phy_connect(bp->dev, bp->phy_node,
> +				&macb_handle_link_change, 0,
> +				bp->phy_interface);
> +	if (!phydev)
> +		return -ENODEV;
> +
> +	/* mask with MAC supported features */
> +	if (macb_is_gem(bp) && bp->caps & MACB_CAPS_GIGABIT_MODE_AVAILABLE)
> +		phydev->supported &= PHY_GBIT_FEATURES;
> +	else
> +		phydev->supported &= PHY_BASIC_FEATURES;
> +
> +	if (bp->caps & MACB_CAPS_NO_GIGABIT_HALF)
> +		phydev->supported &= ~SUPPORTED_1000baseT_Half;
> +
> +	phydev->advertising = phydev->supported;
> +
> +	bp->link = 0;
> +	bp->speed = 0;
> +	bp->duplex = -1;
> +
> +	return 0;
> +}

This is nearly identical to macb_mii_probe(), can you try to re-use what
is done there and just extract the phy_find_first() part which is
different here?

> +
>  static int macb_mii_init(struct macb *bp)
>  {
>  	struct macb_platform_data *pdata;
> @@ -3245,6 +3273,7 @@ static int macb_probe(struct platform_device *pdev)
>  	const char *mac;
>  	struct macb *bp;
>  	int err;
> +	bool fixed_link = false;
>  
>  	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	mem = devm_ioremap_resource(&pdev->dev, regs);
> @@ -3342,8 +3371,18 @@ static int macb_probe(struct platform_device *pdev)
>  		macb_get_hwaddr(bp);
>  
>  	/* Power up the PHY if there is a GPIO reset */
> -	phy_node =  of_get_next_available_child(np, NULL);
> -	if (phy_node) {
> +	phy_node = of_parse_phandle(np, "phy-handle", 0);
> +	if (!phy_node && of_phy_is_fixed_link(np)) {
> +		err = of_phy_register_fixed_link(np);
> +		if (err < 0) {
> +			dev_err(&pdev->dev, "broken fixed-link specification");
> +			goto failed_phy;
> +		}
> +		/* in case of a fixed PHY, the DT node is the ethernet MAC */
> +		phy_node = of_node_get(np);
> +		bp->phy_node = phy_node;
> +		fixed_link = true;
> +	} else {
>  		int gpio = of_get_named_gpio(phy_node, "reset-gpios", 0);
>  
>  		if (gpio_is_valid(gpio)) {
> @@ -3369,7 +3408,10 @@ static int macb_probe(struct platform_device *pdev)
>  	if (err)
>  		goto err_out_free_netdev;
>  
> -	err = macb_mii_init(bp);
> +	if (!fixed_link)
> +		err = macb_mii_init(bp);
> +	else
> +		err = macb_fixed_init(bp);
>  	if (err)
>  		goto err_out_free_netdev;
>  
> @@ -3400,6 +3442,9 @@ static int macb_probe(struct platform_device *pdev)
>  	if (bp->reset_gpio)
>  		gpiod_set_value(bp->reset_gpio, 0);
>  
> +failed_phy:
> +	of_node_put(phy_node);
> +
>  err_out_free_netdev:
>  	free_netdev(dev);
>  
> @@ -3423,9 +3468,14 @@ static int macb_remove(struct platform_device *pdev)
>  		bp = netdev_priv(dev);
>  		if (dev->phydev)
>  			phy_disconnect(dev->phydev);
> -		mdiobus_unregister(bp->mii_bus);
> +
> +		if (!bp->phy_node)
> +			mdiobus_unregister(bp->mii_bus);
> +
>  		dev->phydev = NULL;
> -		mdiobus_free(bp->mii_bus);
> +
> +		if (!bp->phy_node)
> +			mdiobus_free(bp->mii_bus);

Humm, I'd have to read the code a bit more, but conceptually, you could
declare child MDIO device nodes (e.g: Ethernet switch) and a fixed-link
that describes how you are connecting to that Ethernet switch. The MDIO
devices require the MDIO bus to be available, so I don't think you can
treat fixed-link as mutually exclusive with an absence of PHY nodes.
-- 
Florian
