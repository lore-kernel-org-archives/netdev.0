From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH 5/7] net: of_mdio: parse "max-speed" property to set PHY
 supported features
Date: Sun, 08 Dec 2013 09:51:34 -0600
Message-ID: <52A49586.8000201@gmail.com>
References: <1386283936-26104-1-git-send-email-florian@openwrt.org> <1386283936-26104-6-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, grant.likely@linaro.org,
	devicetree@vger.kernel.org, abrodkin@synopsys.com,
	mark.rutland@arm.com, sebastian.hesselbarth@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:36024 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754916Ab3LHPvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 10:51:39 -0500
In-Reply-To: <1386283936-26104-6-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2013 04:52 PM, Florian Fainelli wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> 
> The "max-speed" property is defined per the ePAPR specification to
> express the maximum speed a PHY supports. Use that property, if present
> to set the phydev->supported features which properly restricts the PHY
> within the range of defined speeds.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/of/of_mdio.c | 25 ++++++++++++++++++++++++-
>  1 file changed, 24 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 4923ab2..e1e19e5 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -22,12 +22,30 @@
>  MODULE_AUTHOR("Grant Likely <grant.likely@secretlab.ca>");
>  MODULE_LICENSE("GPL");
>  
> +static void of_set_phy_supported(struct phy_device *phydev, u32 max_speed)
> +{
> +	phydev->supported |= PHY_DEFAULT_FEATURES;
> +
> +	switch (max_speed) {
> +	default:
> +		return;
> +
> +	case SPEED_1000:
> +		phydev->supported |= PHY_1000BT_FEATURES;

This assumes the speed is not already set. Do you need to first mask
speeds out?

No need to support 10G PHYs?

A fall-thru note would be helpful here.

> +	case SPEED_100:
> +		phydev->supported |= PHY_100BT_FEATURES;
> +	case SPEED_10:
> +		phydev->supported |= PHY_10BT_FEATURES;
> +	}
> +}
> +
>  static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *child,
>  				   u32 addr)
>  {
>  	struct phy_device *phy;
>  	bool is_c45;
>  	int rc, prev_irq;
> +	u32 max_speed = 0;
>  
>  	is_c45 = of_device_is_compatible(child,
>  					 "ethernet-phy-ieee802.3-c45");
> @@ -58,8 +76,13 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
>  		return 1;
>  	}
>  
> +	/* Set phydev->supported based on the "max-speed" property
> +	 * if present */
> +	if (!of_property_read_u32(child, "max-speed", &max_speed))
> +		of_set_phy_supported(phy, max_speed);
> +
>  	dev_dbg(&mdio->dev, "registered phy %s at address %i\n",
> -		 child->name, addr);
> +		child->name, addr);
>  
>  	return 0;
>  }
> 
