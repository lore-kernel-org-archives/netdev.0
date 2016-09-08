From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next 1/2] net: phy: Add Edge-rate driver for
 Microsemi PHYs.
Date: Thu, 8 Sep 2016 15:14:15 +0200
Message-ID: <20160908131415.GG26445@lunn.ch>
References: <20160824125934.GC13406@lunn.ch>
 <1473326242-4198-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1473326242-4198-2-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38832 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932307AbcIHNOR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 09:14:17 -0400
Content-Disposition: inline
In-Reply-To: <1473326242-4198-2-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 08, 2016 at 02:47:21PM +0530, Raju Lakkaraju wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> Used Device Tree to configure the Edge-rate as per review comments and
> re-sending code for review
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> ---
>  drivers/net/phy/mscc.c | 76 ++++++++++++++++++++++++++++++++++++++++++++++++++

Hi Raju

You need to also document the new property in the device tree binding
documentation.

> +static int vsc85xx_edge_rate_cntl_set(struct phy_device *phydev,
> +				      u8     edge_rate)

No spaces place.

> +#ifdef CONFIG_OF_MDIO
> +static int vsc8531_of_init(struct phy_device *phydev)
> +{
> +	int rc;
> +	struct vsc8531_private *vsc8531 = phydev->priv;
> +	struct device *dev = &phydev->mdio.dev;
> +	struct device_node *of_node = dev->of_node;
> +
> +	if (!of_node)
> +		return -ENODEV;
> +
> +	rc = of_property_read_u8(of_node, "vsc8531,edge-rate",
> +				 &vsc8531->edge_rate);

Until you have written the Documentation, it is hard for me to tell,
but device tree bindings should use real units, like seconds, Ohms,
Farads, etc. Is the edge rate in nS? Or is it some magic value which
just gets written into the register?

> +
> +	return rc;
> +}
> +#else
> +static int vsc8531_of_init(struct phy_device *phydev)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_OF_MDIO */
> +
>  static int vsc85xx_config_init(struct phy_device *phydev)
>  {
>  	int rc;
> +	struct vsc8531_private *vsc8531;
> +
> +	if (!phydev->priv) {

How can this happen?

> +		vsc8531 = devm_kzalloc(&phydev->mdio.dev, sizeof(*vsc8531),
> +				       GFP_KERNEL);
> +		if (!vsc8531)
> +			return -ENOMEM;
> +
> +		phydev->priv = vsc8531;
> +		rc = vsc8531_of_init(phydev);
> +		if (rc)
> +			return rc;
> +	} else {
> +		vsc8531 = (struct vsc8531_private *)phydev->priv;
> +	}
>  
>  	rc = vsc85xx_default_config(phydev);
>  	if (rc)
>  		return rc;
> +
> +	rc = vsc85xx_edge_rate_cntl_set(phydev, vsc8531->edge_rate);

If there is no vsc8531,edge-rate property in device tree, is the phy
going to work O.K, if you configure it for 0nS edges? Or should there
be some default value assigned?

Thanks
	Andrew
