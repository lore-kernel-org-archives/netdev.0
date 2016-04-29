From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: macb: do not scan PHYs manually
Date: Fri, 29 Apr 2016 14:49:06 +0200
Message-ID: <20160429124906.GD4053@lunn.ch>
References: <20160428155556.GA8333@nathan3500-linux-VM>
 <20160428163207.GP29024@lunn.ch>
 <20160428175619.GA8791@nathan3500-linux-VM>
 <20160428184303.GR29024@lunn.ch>
 <20160428185527.GA8851@nathan3500-linux-VM>
 <20160428185932.GU29024@lunn.ch>
 <20160428210357.GB30217@jcartwri.amer.corp.natinst.com>
 <20160428212315.GC12753@lunn.ch>
 <20160429003459.GC30217@jcartwri.amer.corp.natinst.com>
 <20160429122501.GD30217@jcartwri.amer.corp.natinst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nathan Sullivan <nathan.sullivan@ni.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Josh Cartwright <joshc@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160429122501.GD30217@jcartwri.amer.corp.natinst.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index eec3200..d843bc9 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -419,11 +419,62 @@ static int macb_mii_probe(struct net_device *dev)
>  	return 0;
>  }
>  
> +static int macb_mii_of_init(struct macb *bp, struct device_node *np)
> +{
> +	struct device_node *mdio;
> +	int err, i;
> +
> +	mdio = of_get_child_by_name(np, "mdio");
> +	if (mdio)
> +		return of_mdiobus_register(bp->mii_bus, mdio);

We want to encourage driver writers to use an mdio subnode inside
there MAC node. So i wounder if this looking for the child and using
it should go into the core code?

Florian: What do you think?

> +
> +	dev_warn(&bp->pdev->dev,
> +		 "using deprecated PHY probing mechanism.  Please update device tree.");
> +
> +	/* try dt phy registration */
> +	err = of_mdiobus_register(bp->mii_bus, np);
> +	if (err)
> +		return err;
> +
> +	/* fallback to standard phy registration if no phy were
> +	 * found during dt phy registration
> +	 */
> +	if (!phy_find_first(bp->mii_bus)) {

I would also suggest putting a warning here, saying that PHYs should
be listed in the device tree.

> +		for (i = 0; i < PHY_MAX_ADDR; i++) {
> +			struct phy_device *phydev;
> +
> +			phydev = mdiobus_scan(bp->mii_bus, i);
> +			if (IS_ERR(phydev)) {
> +				err = PTR_ERR(phydev);

FYI: There is a change making its way through which will mean
mdiobus_scan() will return -ENODEV where there is nothing on the bus
at that address, rather than the current NULL. You will need to adopt
this here.

     Andrew
