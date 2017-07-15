From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 2/2] net: ethernet: nixge: Add support for National
 Instruments XGE netdev
Date: Sat, 15 Jul 2017 18:46:29 +0200
Message-ID: <20170715164629.GB25966@lunn.ch>
References: <1500065326-26182-1-git-send-email-mdf@kernel.org>
 <1500065326-26182-2-git-send-email-mdf@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net,
        mark.rutland@arm.com, robh+dt@kernel.org
To: Moritz Fischer <mdf@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1500065326-26182-2-git-send-email-mdf@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +++ b/drivers/net/ethernet/ni/Kconfig
> @@ -0,0 +1,27 @@
> +#
> +# National Instuments network device configuration
> +#
> +
> +config NET_VENDOR_NI
> +	bool "National Instruments Devices"
> +	default y
> +	---help---
> +	  If you have a network (Ethernet) device belonging to this class, say Y.
> +
> +	  Note that the answer to this question doesn't directly affect the
> +	  kernel: saying N will just cause the configurator to skip all
> +	  the questions about National Instrument devices.
> +	  If you say Y, you will be asked for your specific device in the
> +	  following questions.
> +
> +if NET_VENDOR_NI
> +
> +config NI_XGE_MANAGEMENT_ENET
> +	tristate "National Instruments XGE management enet support"
> +	depends on ARCH_ZYNQ

Consider also adding COMPILE_TEST, if possible.

> +#define nixge_ctrl_poll_timeout(priv, addr, val, cond, sleep_us, timeout_us) \
> +	readl_poll_timeout((priv)->ctrl_regs + (addr), (val), cond, \
> +			   (sleep_us), (timeout_us))

Seems odd not having cond inside (), especially since cond could be a
complex expression.

> +static void nixge_handle_link_change(struct net_device *ndev)
> +{
> +	struct nixge_priv *priv = netdev_priv(ndev);
> +	struct phy_device *phydev = ndev->phydev;
> +	unsigned long flags;
> +	int status_change = 0;
> +
> +	spin_lock_irqsave(&priv->lock, flags);
> +
> +	if (phydev->link != priv->link || phydev->speed != priv->speed ||
> +	    phydev->duplex != priv->duplex) {
> +		priv->link = phydev->link;
> +		priv->speed = phydev->speed;
> +		priv->duplex = phydev->duplex;
> +		status_change = 1;
> +	}
> +
> +	spin_unlock_irqrestore(&priv->lock, flags);
> +
> +	if (status_change)
> +		phy_print_status(phydev);
> +}

As Florian pointed out, you don't make use of any of this
information. So maybe don't bother, just have a return statement.

> +static int nixge_stop(struct net_device *ndev)
> +{
> +	u32 cr;
> +	struct nixge_priv *priv = netdev_priv(ndev);
> +
> +	cr = nixge_dma_read_reg(priv, XAXIDMA_RX_CR_OFFSET);
> +	nixge_dma_write_reg(priv, XAXIDMA_RX_CR_OFFSET,
> +			    cr & (~XAXIDMA_CR_RUNSTOP_MASK));
> +	cr = nixge_dma_read_reg(priv, XAXIDMA_TX_CR_OFFSET);
> +	nixge_dma_write_reg(priv, XAXIDMA_TX_CR_OFFSET,
> +			    cr & (~XAXIDMA_CR_RUNSTOP_MASK));
> +
> +	tasklet_kill(&priv->dma_err_tasklet);
> +
> +	free_irq(priv->tx_irq, ndev);
> +	free_irq(priv->rx_irq, ndev);
> +
> +	nixge_dma_bd_release(ndev);
> +
> +	if (ndev->phydev) {

Do you need this condition? You bail out with ENODEV if of_phy_connect fails?

> +		phy_stop(ndev->phydev);
> +		phy_disconnect(ndev->phydev);
> +	}
> +
> +	return 0;
> +}
> +
> +static int nixge_change_mtu(struct net_device *ndev, int new_mtu)
> +{
> +	struct nixge_priv *priv = netdev_priv(ndev);
> +
> +	if (netif_running(ndev))
> +		return -EBUSY;
> +
> +	if ((new_mtu + VLAN_ETH_HLEN +
> +		NIXGE_TRL_SIZE) > priv->rxmem)
> +		return -EINVAL;
> +
> +	ndev->mtu = new_mtu;
> +
> +	return 0;
> +}
> +
> +static s32 __nixge_hw_set_mac_address(struct net_device *ndev)
> +{
> +	struct nixge_priv *priv = netdev_priv(ndev);
> +
> +	nixge_ctrl_write_reg(priv, NIXGE_REG_MAC_LSB,
> +			     (ndev->dev_addr[2]) << 24 |
> +			     (ndev->dev_addr[3] << 16) |
> +			     (ndev->dev_addr[4] << 8) |
> +			     (ndev->dev_addr[5] << 0));
> +
> +	nixge_ctrl_write_reg(priv, NIXGE_REG_MAC_MSB,
> +			     (ndev->dev_addr[1] | (ndev->dev_addr[0] << 8)));
> +
> +	return 0;
> +}
> +
> +static int nixge_net_set_mac_address(struct net_device *ndev, void *p)
> +{
> +	int err;
> +
> +	err = eth_mac_addr(ndev, p);
> +	if (!err)
> +		__nixge_hw_set_mac_address(ndev);
> +
> +	return err;
> +}

Much better, thanks.

> +
> +static int nixge_mdio_write(struct mii_bus *bus, int phy_id, int reg, u16 val)
> +{
> +	struct nixge_priv *priv = bus->priv;
> +	u32 status, tmp;
> +	int err;
> +	u16 device;
> +
> +	/* FIXME: Currently don't do writes */
> +	if (reg & MII_ADDR_C45)
> +		return -EOPNOTSUPP;
> +
> +	device = reg & 0x1f;
> +
> +	tmp = NIXGE_MDIO_CLAUSE22 | NIXGE_MDIO_OP(MDIO_C22_WRITE) |
> +		NIXGE_MDIO_ADDR(phy_id) | NIXGE_MDIO_MMD(device);
> +
> +	nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_DATA, val);
> +	nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_OP, tmp);
> +	nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_CTRL, 1);
> +
> +	err = nixge_ctrl_poll_timeout(priv, NIXGE_REG_MDIO_CTRL, status,
> +				      !status, 10, 1000);
> +	if (err) {
> +		dev_err(priv->dev, "timeout setting write command");
> +		return -ETIMEDOUT;

return err;

> +	}
> +
> +	dev_dbg(priv->dev, "%x %x <- %x\n", phy_id, reg, val);
> +
> +	return 0;
> +}
> +
> +static int nixge_mdio_setup(struct nixge_priv *priv, struct device_node *np)
> +{
> +	struct mii_bus *bus;
> +	struct resource res;
> +	int err;
> +
> +	bus = mdiobus_alloc();
> +	if (!bus)
> +		return -ENOMEM;
> +
> +	of_address_to_resource(np, 0, &res);

This can fail.

Err, why are you actually doing it anyway? You don't make use of res,
you don't ioremap() it, etc.

> +	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-mii", dev_name(priv->dev));
> +	bus->priv = priv;
> +	bus->name = "nixge_mii_bus";
> +	bus->read = nixge_mdio_read;
> +	bus->write = nixge_mdio_write;
> +	bus->parent = priv->dev;
> +
> +	priv->mii_bus = bus;
> +	err = of_mdiobus_register(bus, np);
> +	if (err)
> +		goto err_register;
> +
> +	dev_info(priv->dev, "MDIO bus registered\n");
> +
> +	return 0;
> +
> +err_register:
> +	mdiobus_free(bus);
> +	return err;
> +}
> +

> +static int nixge_probe(struct platform_device *pdev)
> +{
> +	int err;
> +	struct nixge_priv *priv;
> +	struct net_device *ndev;
> +	struct resource *dmares;
> +	const char *mac_addr;
> +
> +	ndev = alloc_etherdev(sizeof(*priv));
> +	if (!ndev)
> +		return -ENOMEM;
> +
> +	platform_set_drvdata(pdev, ndev);
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +
> +	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */

Could you explain this a bit better please. Does this imply that IPv6
neighbour discovery is not supported? That is a severe restriction.


> +static int nixge_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +	struct nixge_priv *priv = netdev_priv(ndev);
> +
> +	if (ndev->phydev)
> +		phy_disconnect(ndev->phydev);

nixge_stop() disconnects the phy. I don't think you need it twice.

> +	ndev->phydev = NULL;
> +
> +	mdiobus_unregister(priv->mii_bus);
> +	mdiobus_free(priv->mii_bus);
> +	priv->mii_bus = NULL;
> +
> +	unregister_netdev(ndev);
> +
> +	free_netdev(ndev);
> +
> +	return 0;

  Andrew
