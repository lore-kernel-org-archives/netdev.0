From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH 1/7] net: of_mdio: factor PHY registration from of_mdiobus_register
Date: Sun, 08 Dec 2013 10:00:16 -0600
Message-ID: <52A49790.5080901@gmail.com>
References: <1386283936-26104-1-git-send-email-florian@openwrt.org> <1386283936-26104-2-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, grant.likely@linaro.org,
	devicetree@vger.kernel.org, abrodkin@synopsys.com,
	rob.herring@calxeda.com, mark.rutland@arm.com,
	sebastian.hesselbarth@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:46774 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755010Ab3LHQAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 11:00:19 -0500
In-Reply-To: <1386283936-26104-2-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2013 04:52 PM, Florian Fainelli wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> 
> Since commit 779d835e ("net: of_mdio: scan mdiobus for PHYs without reg
> property") we have two foreach loops which do pretty much the same
> thing. Factor the PHY device registration in a function helper:
> of_mdiobus_register_phy() which takes care of the details and allows for
> future PHY specific extensions.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

A couple of formatting nits, but otherwise:

Acked-by: Rob Herring <rob.herring@calxeda.com>

BTW, unless David has objections, I'd like to see this file moved to
drivers/net. He tends to merge the of_mdio.c changes anyway. We've moved
most other subsystem parsing code out of drivers/of.

> ---
>  drivers/of/of_mdio.c | 109 ++++++++++++++++++++++-----------------------------
>  1 file changed, 46 insertions(+), 63 deletions(-)
> 
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index d5a57a9..82485d2 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -22,6 +22,47 @@
>  MODULE_AUTHOR("Grant Likely <grant.likely@secretlab.ca>");
>  MODULE_LICENSE("GPL");
>  
> +static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *child,
> +				   u32 addr)
> +{
> +	struct phy_device *phy;
> +	bool is_c45;
> +	int rc;
> +
> +	is_c45 = of_device_is_compatible(child,
> +					 "ethernet-phy-ieee802.3-c45");

This looks like it can be 1 line.

> +
> +	phy = get_phy_device(mdio, addr, is_c45);
> +	if (!phy || IS_ERR(phy))
> +		return 1;
> +
> +	if (mdio->irq) {
> +		mdio->irq[addr] =
> +			irq_of_parse_and_map(child, 0);

ditto

> +		if (!mdio->irq[addr])
> +			mdio->irq[addr] = PHY_POLL;
> +	}
> +
> +	/* Associate the OF node with the device structure so it
> +	 * can be looked up later */
> +	of_node_get(child);
> +	phy->dev.of_node = child;
> +
> +	/* All data is now stored in the phy struct;
> +	 * register it */
> +	rc = phy_device_register(phy);
> +	if (rc) {
> +		phy_device_free(phy);
> +		of_node_put(child);
> +		return 1;
> +	}
> +
> +	dev_dbg(&mdio->dev, "registered phy %s at address %i\n",
> +		 child->name, addr);
> +
> +	return 0;
> +}
> +
>  /**
>   * of_mdiobus_register - Register mii_bus and create PHYs from the device tree
>   * @mdio: pointer to mii_bus structure
> @@ -32,11 +73,10 @@ MODULE_LICENSE("GPL");
>   */
>  int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  {
> -	struct phy_device *phy;
>  	struct device_node *child;
>  	const __be32 *paddr;
>  	u32 addr;
> -	bool is_c45, scanphys = false;
> +	bool scanphys = false;
>  	int rc, i, len;
>  
>  	/* Mask out all PHYs from auto probing.  Instead the PHYs listed in
> @@ -73,38 +113,9 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  			continue;
>  		}
>  
> -		if (mdio->irq) {
> -			mdio->irq[addr] = irq_of_parse_and_map(child, 0);
> -			if (!mdio->irq[addr])
> -				mdio->irq[addr] = PHY_POLL;
> -		}
> -
> -		is_c45 = of_device_is_compatible(child,
> -						 "ethernet-phy-ieee802.3-c45");
> -		phy = get_phy_device(mdio, addr, is_c45);
> -
> -		if (!phy || IS_ERR(phy)) {
> -			dev_err(&mdio->dev,
> -				"cannot get PHY at address %i\n",
> -				addr);
> -			continue;
> -		}
> -
> -		/* Associate the OF node with the device structure so it
> -		 * can be looked up later */
> -		of_node_get(child);
> -		phy->dev.of_node = child;
> -
> -		/* All data is now stored in the phy struct; register it */
> -		rc = phy_device_register(phy);
> -		if (rc) {
> -			phy_device_free(phy);
> -			of_node_put(child);
> +		rc = of_mdiobus_register_phy(mdio, child, addr);
> +		if (rc)
>  			continue;
> -		}
> -
> -		dev_dbg(&mdio->dev, "registered phy %s at address %i\n",
> -			child->name, addr);
>  	}
>  
>  	if (!scanphys)
> @@ -117,9 +128,6 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  		if (paddr)
>  			continue;
>  
> -		is_c45 = of_device_is_compatible(child,
> -						 "ethernet-phy-ieee802.3-c45");
> -
>  		for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
>  			/* skip already registered PHYs */
>  			if (mdio->phy_map[addr])
> @@ -129,34 +137,9 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  			dev_info(&mdio->dev, "scan phy %s at address %i\n",
>  				 child->name, addr);
>  
> -			phy = get_phy_device(mdio, addr, is_c45);
> -			if (!phy || IS_ERR(phy))
> +			rc = of_mdiobus_register_phy(mdio, child, addr);
> +			if (rc)
>  				continue;
> -
> -			if (mdio->irq) {
> -				mdio->irq[addr] =
> -					irq_of_parse_and_map(child, 0);
> -				if (!mdio->irq[addr])
> -					mdio->irq[addr] = PHY_POLL;
> -			}
> -
> -			/* Associate the OF node with the device structure so it
> -			 * can be looked up later */
> -			of_node_get(child);
> -			phy->dev.of_node = child;
> -
> -			/* All data is now stored in the phy struct;
> -			 * register it */
> -			rc = phy_device_register(phy);
> -			if (rc) {
> -				phy_device_free(phy);
> -				of_node_put(child);
> -				continue;
> -			}
> -
> -			dev_info(&mdio->dev, "registered phy %s at address %i\n",
> -				 child->name, addr);
> -			break;
>  		}
>  	}
>  
> 
