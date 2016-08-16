From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v6 3/3] net: phy: Add gmiitorgmii converter support
Date: Tue, 16 Aug 2016 18:53:20 +0200
Message-ID: <20160816165320.GP14446@lunn.ch>
References: <1470808208-32133-1-git-send-email-appanad@xilinx.com>
 <1470808208-32133-4-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, appanad@xilinx.com,
	f.fainelli@gmail.com, punnaia@xilinx.com,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1470808208-32133-4-git-send-email-appanad@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static int xgmiitorgmii_read_status(struct phy_device *phydev)
> +{
> +	struct gmii2rgmii *priv = phydev->priv;
> +	u16 val = 0;
> +
> +	priv->phy_drv->read_status(phydev);

This can return an error, in which case phydev->speed should not be
trusted.

I've not thought locking all the way through yet. I don't think you
need a lock here, but i need to think about it.

> +
> +	val = mdiobus_read(phydev->mdio.bus, priv->addr, XILINX_GMII2RGMII_REG);

You should check for an error here.

> +	val &= XILINX_GMII2RGMII_SPEED_MASK;
> +
> +	if (phydev->speed == SPEED_1000)
> +		val |= BMCR_SPEED1000;
> +	else if (phydev->speed == SPEED_100)
> +		val |= BMCR_SPEED100;
> +	else
> +		val |= BMCR_SPEED10;

What happens if for example the PHY is an aquantia and has negotiated
SPEED_2500? Some Marvell PHYs can also do odd speeds, like 200Mbps.
You probably want to return an error, rather than silently have things
go wrong.

> +
> +	mdiobus_write(phydev->mdio.bus, priv->addr, XILINX_GMII2RGMII_REG, val);

This can also return an error.

> +	return 0;
> +}
> +
> +int xgmiitorgmii_probe(struct mdio_device *mdiodev)
> +{
> +	struct device *dev = &mdiodev->dev;
> +	struct device_node *np = dev->of_node, *phy_node;
> +	struct gmii2rgmii *priv;
> +
> +	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
> +	if (!priv)
> +		return -ENOMEM;
> +
> +	phy_node = of_parse_phandle(np, "phy-handle", 0);
> +	if (IS_ERR(phy_node)) {
> +		dev_err(dev, "Couldn't parse phy-handle\n");
> +		return -ENODEV;
> +	}
> +
> +	priv->phy_dev = of_phy_find_device(phy_node);
> +	if (!priv->phy_dev) {
> +		dev_info(dev, "Couldn't find phydev\n");
> +		return -EPROBE_DEFER;
> +	}
> +
> +	priv->addr = mdiodev->addr;
> +	priv->phy_drv = priv->phy_dev->drv;
> +	memcpy(&priv->conv_phy_drv, priv->phy_dev->drv,
> +	       sizeof(struct phy_driver));
> +	priv->conv_phy_drv.read_status = xgmiitorgmii_read_status;
> +	priv->phy_dev->priv = priv;
> +	priv->phy_dev->drv = &priv->conv_phy_drv;

So from this point onward, the phy driver depends on the memory
allocated by this driver. If this driver goes away, freeing its
memory, the next call to read_status() is going to have a problem.

Also, i think this assignment should take the phy lock, just to be
safe.

There also needs to be some thought into what happens if the phy
driver is unloaded. Should this driver take a reference on the phy
driver to prevent that?

       Andrew
