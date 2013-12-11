From: Grant Likely <grant.likely@linaro.org>
Subject: Re: [PATCH 5/7] net: of_mdio: parse "max-speed" property to set PHY supported features
Date: Wed, 11 Dec 2013 14:02:00 +0000
Message-ID: <20131211140200.DCD09C4061A@trevor.secretlab.ca>
References: <1386283936-26104-1-git-send-email-florian@openwrt.org> < 1386283936-26104-6-git-send-email-florian@openwrt.org>
Cc: davem@davemloft.net, devicetree@vger.kernel.org,
	abrodkin@synopsys.com, rob.herring@calxeda.com,
	mark.rutland@arm.com, sebastian.hesselbarth@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:33871 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496Ab3LKOCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 09:02:11 -0500
Received: by mail-ea0-f175.google.com with SMTP id z10so2940519ead.34
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 06:02:10 -0800 (PST)
In-Reply-To: <1386283936-26104-6-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 5 Dec 2013 14:52:14 -0800, Florian Fainelli <florian@openwrt.org> wrote:
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

No need for a default clause.

> +
> +	case SPEED_1000:
> +		phydev->supported |= PHY_1000BT_FEATURES;
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

Why the separate function? There is no need since there is only one
caller and the block is very short. Just do this:

	if (!of_property_read_u32(child, "max-speed", &max_speed)) {
		phydev->supported |= PHY_DEFAULT_FEATURES;
		switch (max_speed) {
		case SPEED_1000:
			phydev->supported |= PHY_1000BT_FEATURES;
		case SPEED_100:
			phydev->supported |= PHY_100BT_FEATURES;
		case SPEED_10:
			phydev->supported |= PHY_10BT_FEATURES;
		}
	}

>  	dev_dbg(&mdio->dev, "registered phy %s at address %i\n",
> -		 child->name, addr);
> +		child->name, addr);

Unrelated whitespace change. I wouldn't even bother with changing this.
It adds noise.

However, those are style concerns. The content looks fine.

Acked-by: Grant Likely <grant.likely@linaro.org>

g.
