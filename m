From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 2/2] net: ethernet: nixge: Add support for National
 Instruments XGE netdev
Date: Fri, 14 Jul 2017 00:36:36 +0200
Message-ID: <20170713223636.GF3120@lunn.ch>
References: <1499980909-11702-1-git-send-email-mdf@kernel.org>
 <1499980909-11702-2-git-send-email-mdf@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Moritz Fischer <mdf-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1499980909-11702-2-git-send-email-mdf-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +++ b/drivers/net/ethernet/ni/nixge.c
> @@ -0,0 +1,1246 @@
> +/*
> + * Copyright (c) 2016-2017, National Instruments Corp.
> + *
> + * Network Driver for Ettus Research XGE MAC
> + *
> + * This is largely based on the Xilinx AXI Ethernet Driver,
> + * and uses the same DMA engine in the FPGA

Hi Moritz 

Is the DMA code the same as in the AXI driver? Should it be pulled out
into a library and shared?

> +struct nixge_priv {
> +	struct net_device *ndev;
> +	struct device *dev;
> +
> +	/* Connection to PHY device */
> +	struct phy_device *phy_dev;
> +	phy_interface_t		phy_interface;

> +	/* protecting link parameters */
> +	spinlock_t              lock;
> +	int link;
> +	int speed;
> +	int duplex;

All these seem to be pointless. They are set, but never used.

> +
> +static inline void nixge_dma_write_reg(struct nixge_priv *priv, off_t offset,
> +				       u32 val)

Please leave it up to the compile to inline.

> +static void __nixge_device_reset(struct nixge_priv *priv, off_t offset)
> +{
> +	u32 timeout;
> +	/* Reset Axi DMA. This would reset NIXGE Ethernet core as well.
> +	 * The reset process of Axi DMA takes a while to complete as all
> +	 * pending commands/transfers will be flushed or completed during
> +	 * this reset process.
> +	 */
> +	nixge_dma_write_reg(priv, offset, XAXIDMA_CR_RESET_MASK);
> +	timeout = DELAY_OF_ONE_MILLISEC;
> +	while (nixge_dma_read_reg(priv, offset) & XAXIDMA_CR_RESET_MASK) {
> +		udelay(1);

There is a link between the 1 and the value of DELAY_OF_ONE_MILLISEC.
It would be good to try to link these two together.

> +		if (--timeout == 0) {
> +			netdev_err(priv->ndev, "%s: DMA reset timeout!\n",
> +				   __func__);
> +			break;
> +		}
> +	}
> +}
> +

> +static void nixge_handle_link_change(struct net_device *ndev)
> +{
> +	struct nixge_priv *priv = netdev_priv(ndev);
> +	struct phy_device *phydev = ndev->phydev;
> +	unsigned long flags;
> +	int status_change = 0;
> +
> +	spin_lock_irqsave(&priv->lock, flags);
> +
> +	if (phydev->link != priv->link) {
> +		if (!phydev->link) {
> +			priv->speed = 0;
> +			priv->duplex = -1;
> +		}
> +		priv->link = phydev->link;
> +
> +		status_change = 1;
> +	}
> +
> +	spin_unlock_irqrestore(&priv->lock, flags);
> +
> +	if (status_change) {
> +		if (phydev->link) {
> +			netif_carrier_on(ndev);
> +			netdev_info(ndev, "link up (%d/%s)\n",
> +				    phydev->speed,
> +				    phydev->duplex == DUPLEX_FULL ?
> +				    "Full" : "Half");
> +		} else {
> +			netif_carrier_off(ndev);
> +			netdev_info(ndev, "link down\n");
> +		}

phy_print_status() should be used.

Also, the phylib will handle netif_carrier_off/on for you.

> +static int nixge_open(struct net_device *ndev)
> +{
> +	struct nixge_priv *priv = netdev_priv(ndev);
> +	int ret;
> +
> +	nixge_device_reset(ndev);
> +
> +	/* start netif carrier down */
> +	netif_carrier_off(ndev);
> +
> +	if (!ndev->phydev)
> +		netdev_err(ndev, "no phy, phy_start() failed\n");

Not really correct. You don't call phy_start(). And phy_start() cannot
indicate a failure, it is a void function.

It would be a lot better to bail out if there is no phy. Probably
during probe.

> +static s32 __nixge_set_mac_address(struct net_device *ndev, const void *addr)
> +{
> +	struct nixge_priv *priv = netdev_priv(ndev);
> +
> +	if (addr)
> +		memcpy(ndev->dev_addr, addr, ETH_ALEN);
> +	if (!is_valid_ether_addr(ndev->dev_addr))
> +		eth_random_addr(ndev->dev_addr);

Messy. I would change this. Make addr mandatory. If it is invalid,
return an error. That will make nixge_net_set_mac_address() do the
right thing. When called from nixge_probe() should verify what it gets
from the nvmem, and if it is invalid, pass a random MAC address.

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

> +static void nixge_ethtools_get_drvinfo(struct net_device *ndev,
> +				       struct ethtool_drvinfo *ed)
> +{
> +	strlcpy(ed->driver, "nixge", sizeof(ed->driver));
> +	strlcpy(ed->version, "1.00a", sizeof(ed->version));

Driver version is pretty pointless. What does 1.00a mean? Say it gets
backported into F26. Is it still 1.00a even though lots of things
around it have changed?


> +int nixge_mdio_read(struct mii_bus *bus, int phy_id, int reg)
> +{
> +	struct nixge_priv *priv = bus->priv;
> +	u32 status, tmp;
> +	int err;
> +	u16 device;
> +
> +	if (reg & MII_ADDR_C45) {
> +		device = (reg >> 16) & 0x1f;
> +
> +		nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_ADDR, reg & 0xffff);
> +
> +		tmp = NIXGE_MDIO_CLAUSE45 | NIXGE_MDIO_OP(NIXGE_MDIO_OP_ADDRESS)
> +			| NIXGE_MDIO_ADDR(phy_id) | NIXGE_MDIO_MMD(device);
> +
> +		nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_OP, tmp);
> +		nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_CTRL, 1);
> +
> +		err = nixge_ctrl_poll_timeout(priv, NIXGE_REG_MDIO_CTRL, status,
> +					      !status, 10, 1000);
> +		if (err) {
> +			dev_err(priv->dev, "timeout setting address");
> +			return -ETIMEDOUT;

Better to return err.

> +		}
> +
> +		tmp = NIXGE_MDIO_CLAUSE45 | NIXGE_MDIO_OP(NIXGE_MDIO_OP_READ) |
> +			NIXGE_MDIO_ADDR(phy_id) | NIXGE_MDIO_MMD(device);
> +	} else {
> +		device = reg & 0x1f;
> +
> +		tmp = NIXGE_MDIO_CLAUSE22 | NIXGE_MDIO_OP(MDIO_C22_READ) |
> +			NIXGE_MDIO_ADDR(phy_id) | NIXGE_MDIO_MMD(device);
> +	}
> +
> +	nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_OP, tmp);
> +	nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_CTRL, 1);
> +
> +	err = nixge_ctrl_poll_timeout(priv, NIXGE_REG_MDIO_CTRL, status,
> +				      !status, 10, 1000);
> +	if (err) {
> +		dev_err(priv->dev, "timeout setting read command");
> +		return -ETIMEDOUT;

Again, return err.

> +	}
> +
> +	status = nixge_ctrl_read_reg(priv, NIXGE_REG_MDIO_DATA);
> +
> +	dev_dbg(priv->dev, "%s: phy_id = %x reg = %x got %x\n", __func__,
> +		phy_id, reg & 0xffff, status);
> +
> +	return status;
> +}
> +
> +int nixge_mdio_write(struct mii_bus *bus, int phy_id, int reg, u16 val)
> +{
> +	struct nixge_priv *priv = bus->priv;
> +	u32 status, tmp;
> +	int err;
> +	u16 device;
> +
> +	/* FIXME: Currently don't do writes */
> +	if (reg & MII_ADDR_C45)
> +		return 0;

-EOPNOTSUPP would be better.

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
> +	}
> +
> +	dev_dbg(priv->dev, "%x %x <- %x\n", phy_id, reg, val);
> +
> +	return 0;
> +}
> +
> +int nixge_mdio_setup(struct nixge_priv *priv, struct device_node *np)
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
> +	snprintf(bus->id, MII_BUS_ID_SIZE, "%.8llx",
> +		 (unsigned long long)res.start);

There are more meaningful things you could use, e.g. dev_name(priv->dev)

> +	bus->priv = priv;
> +	bus->name = "NIXGE_MAC_mii_bus";
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
> +static void *nixge_get_nvmem_address(struct device *dev)
> +{
> +	struct nvmem_cell *cell;
> +	size_t cell_size;
> +	char *mac;
> +
> +	cell = nvmem_cell_get(dev, "address");
> +	if (IS_ERR(cell))
> +		return cell;
> +
> +	mac = nvmem_cell_read(cell, &cell_size);
> +	nvmem_cell_put(cell);
> +
> +	if (IS_ERR(mac))
> +		return mac;
> +
> +	return mac;

Pointless if()

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
> +	ndev->features = NETIF_F_SG;
> +	ndev->netdev_ops = &nixge_netdev_ops;
> +	ndev->ethtool_ops = &nixge_ethtool_ops;
> +
> +	/* MTU range: 64 - 9000 */
> +	ndev->min_mtu = 64;
> +	ndev->max_mtu = NIXGE_JUMBO_MTU;
> +
> +	mac_addr = nixge_get_nvmem_address(&pdev->dev);
> +	if (mac_addr)
> +		ether_addr_copy(ndev->dev_addr, mac_addr);
> +	else
> +		eth_hw_addr_random(ndev);
> +
> +	priv = netdev_priv(ndev);
> +	priv->ndev = ndev;
> +	priv->dev = &pdev->dev;
> +
> +	priv->features = 0;
> +	/* default to this for now ... */
> +	priv->rxmem = 10000;
> +
> +	dmares = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	priv->dma_regs = devm_ioremap_resource(&pdev->dev, dmares);
> +	if (IS_ERR(priv->dma_regs)) {
> +		dev_err(&pdev->dev, "failed to map dma regs\n");
> +		return PTR_ERR(priv->dma_regs);
> +	}
> +	priv->ctrl_regs = priv->dma_regs + 0x4000;
> +	__nixge_set_mac_address(ndev, mac_addr);
> +
> +	priv->tx_irq = platform_get_irq_byname(pdev, "tx-irq");
> +	if (priv->tx_irq < 0) {
> +		dev_err(&pdev->dev, "no tx irq available");
> +		return priv->tx_irq;
> +	}
> +
> +	priv->rx_irq = platform_get_irq_byname(pdev, "rx-irq");
> +	if (priv->rx_irq < 0) {
> +		dev_err(&pdev->dev, "no rx irq available");
> +		return priv->rx_irq;
> +	}
> +
> +	priv->coalesce_count_rx = XAXIDMA_DFT_RX_THRESHOLD;
> +	priv->coalesce_count_tx = XAXIDMA_DFT_TX_THRESHOLD;
> +
> +	spin_lock_init(&priv->lock);
> +
> +	err = nixge_mdio_setup(priv, pdev->dev.of_node);
> +	if (err) {
> +		dev_warn(&pdev->dev, "error registering mdio bus");
> +		goto free_netdev;
> +	}
> +
> +	priv->phy_dev = phy_find_first(priv->mii_bus);
> +	if (!priv->phy_dev) {
> +		dev_err(&pdev->dev, "error finding a phy ...");
> +		goto free_netdev;
> +	}

I don't recommend this. Enforce the binding has a phy-handle.

> +
> +	err = register_netdev(priv->ndev);
> +	if (err) {
> +		dev_err(priv->dev, "register_netdev() error (%i)\n", err);
> +		goto free_netdev;
> +	}
> +
> +	err = phy_connect_direct(ndev, priv->phy_dev, &nixge_handle_link_change,
> +				 priv->phy_interface);

and here use of_phy_connect().

And where do you set phy_interface? You should be reading it from
device tree.

> +	if (err) {
> +		dev_err(&pdev->dev, "failed to attach to phy ...");
> +		goto unregister_mdio;
> +	}
> +
> +	/* not sure if this is the correct way of dealing with this ... */
> +	ndev->phydev->supported &= ~(SUPPORTED_Autoneg);
> +	ndev->phydev->advertising = ndev->phydev->supported;
> +	ndev->phydev->autoneg = AUTONEG_DISABLE;

What are you trying to achieve?

     Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
