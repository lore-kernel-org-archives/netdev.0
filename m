From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH V10 2/7] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Fri, 21 Mar 2014 21:22:29 -0700
Message-ID: <007a01cf4586$58a02c20$09e08460$@samsung.com>
References: <005b01cf4530$56a1ba20$03e52e60$@samsung.com>
 <20140321235526.GA7727@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org, 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:39649 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbaCVEWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 00:22:37 -0400
In-reply-to: <20140321235526.GA7727@electric-eye.fr.zoreil.com>
Content-language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
> Byungho An <bh74.an@samsung.com> :
> [...]
> > +static int sxgbe_hw_init(struct sxgbe_priv_data * const priv) {
> 
> 	struct sxgbe_ops *hw = priv->hw;
> 
> > +	u32 ctrl_ids;
> [...]
> > +struct sxgbe_priv_data *sxgbe_dvr_probe(struct device *device,
> 
> nit: s/dvr/drv/ ?
Yes, it is tiriva. but drv is looks better.

> 
> (several occurences in the driver)
> 
> > +					struct sxgbe_plat_data *plat_dat,
> > +					void __iomem *addr)
> > +{
> > +	int ret = 0;
> 
> Useless init.
> 
OK

> > +	struct net_device *ndev = NULL;
> 
> Useless init.
OK

> 
> > +	struct sxgbe_priv_data *priv;
> 
> Nit: you may consider reorganizing the variables in an inverted xmas tree
> fashion at some point.
Does it look better? No problem.

> 
> > +
> > +	ndev = alloc_etherdev_mqs(sizeof(struct sxgbe_priv_data),
> > +				  SXGBE_TX_QUEUES, SXGBE_RX_QUEUES);
> > +	if (!ndev)
> > +		return NULL;
> > +
> > +	SET_NETDEV_DEV(ndev, device);
> > +
> > +	priv = netdev_priv(ndev);
> > +	priv->device = device;
> > +	priv->dev = ndev;
> > +
> > +	ether_setup(ndev);
> 
> Useless.
> 
> (see alloc_etherdev_mqs vs alloc_netdev_mqs)
OK, removal.

> 
> > +
> > +	sxgbe_set_ethtool_ops(ndev);
> > +	priv->plat = plat_dat;
> > +	priv->ioaddr = addr;
> > +
> > +	/* Init MAC and get the capabilities */
> > +	ret = sxgbe_hw_init(priv);
> 
> sxgbe_hw_init can't fail. It should return void.
OK

> 
> [...]
> > +	/* MDIO bus Registration */
> > +	ret = sxgbe_mdio_register(ndev);
> > +	if (ret < 0) {
> > +		netdev_dbg(ndev, "%s: MDIO bus (id: %d) registration
> failed\n",
> > +			   __func__, priv->plat->bus_id);
> > +		goto error_mdio_register;
> > +	}
> > +
> > +	ret = register_netdev(ndev);
> > +	if (ret) {
> > +		pr_err("%s: ERROR %i registering the device\n", __func__,
ret);
> > +		goto error_netdev_register;
> 
> sxgbe_mdio_register is left unbalanced in the error path.
> 
> I am more used to 'goto what_should_be_done' style than 'goto
> where_it_comes_from' (both require to check if the label are correctly
ordered
> in the unwind path though).
I think it seems that current style has no problem.

> 
> > +	}
> > +
> > +	sxgbe_check_ether_addr(priv);
> > +
> > +	return priv;
> > +
> > +error_mdio_register:
> > +	clk_put(priv->sxgbe_clk);
> > +error_clk_get:
> > +	unregister_netdev(ndev);
> 
> There's no failure point past register_netdev: unregister_netdev can't be
> needed.
OK

> 
> > +error_netdev_register:
> > +	netif_napi_del(&priv->napi);
> > +error_free_netdev:
> > +	free_netdev(ndev);
> > +
> > +	return NULL;
> 
> Nit: you may use ERR_PTR and always return 'priv'. The caller could thus
> propagate the error code.
I'll consider it, not for this patch set.

> 
> > +}
> > +
> > +/**
> > + * sxgbe_dvr_remove
> > + * @ndev: net device pointer
> > + * Description: this function resets the TX/RX processes, disables
> > +the MAC RX/TX
> > + * changes the link status, releases the DMA descriptor rings.
> > + */
> > +int sxgbe_dvr_remove(struct net_device *ndev) {
> > +	struct sxgbe_priv_data *priv = netdev_priv(ndev);
> 
> 	struct sxgbe_ops *hw = priv->hw;
> 
> > +
> > +	netdev_info(ndev, "%s: removing driver\n", __func__);
> > +
> > +	priv->hw->dma->stop_rx(priv->ioaddr, SXGBE_RX_QUEUES);
> > +	priv->hw->dma->stop_tx(priv->ioaddr, SXGBE_TX_QUEUES);
> > +
> > +	priv->hw->mac->enable_tx(priv->ioaddr, false);
> > +	priv->hw->mac->enable_rx(priv->ioaddr, false);
> [...]
> > +static int sxgbe_mdio_read(struct mii_bus *bus, int phyaddr, int
> > +phyreg) {
> > +	struct net_device *ndev = bus->priv;
> > +	struct sxgbe_priv_data *priv = netdev_priv(ndev);
> > +	u32 devaddr, reg_val;
> 
> Excess scope for devaddr.
> 
> > +	u32 mii_addr = priv->hw->mii.addr;
> > +	u32 mii_data = priv->hw->mii.data;
> 
> const ?
Those can be const

> 
> > +
> > +	/* check for busy wait */
> 
> Useless comment. Pure noise for the reviewer / maintainer.
Really?

> 
> > +	if (sxgbe_mdio_busy_wait(priv->ioaddr, mii_data))
> > +		return -EBUSY;
> 
> sxgbe_mdio_busy_wait already returns -EBUSY when it fails. Please use it.
OK

> 
> > +
> > +	if (phyreg & MII_ADDR_C45) {
> > +		devaddr = (phyreg >> 16) & 0x1F;
> > +		/* set mdio address register */
> > +		reg_val = (phyaddr << 16) | (devaddr << 21) | (phyreg &
> 0xFFFF);
> > +		writel(reg_val, priv->ioaddr + mii_addr);
> > +
> > +		/* set mdio control/data register */
> > +		reg_val = ((SXGBE_SMA_READ_CMD << 16) |
> SXGBE_SMA_SKIP_ADDRFRM |
> > +			   ((priv->clk_csr & 0x7) << 19) | SXGBE_MII_BUSY);
> 
> Excess parenthesis:
OK.

> 		reg_val = (SXGBE_SMA_READ_CMD << 16) |
> SXGBE_SMA_SKIP_ADDRFRM |
> 			  ((priv->clk_csr & 0x7) << 19) | SXGBE_MII_BUSY;
> 
> > +		writel(reg_val, priv->ioaddr + mii_data);
> > +	} else {
> > +		/* configure the port for C22
> > +		 * ports 0-3 only supports C22
> > +		 */
> > +		if (phyaddr >= 4)
> > +			return -ENODEV;
> > +		writel((1 << phyaddr),
> 
> Excess parenthesis.
OK

> 
> > +		       priv->ioaddr + SXGBE_MDIO_CLAUSE22_PORT_REG);
> > +		/* set mdio address register */
> > +		reg_val = (phyaddr << 16) | (phyreg & 0x1F);
> > +		writel(reg_val, priv->ioaddr + mii_addr);
> > +
> > +		/* set mdio control/data register */
> > +		reg_val = ((SXGBE_SMA_READ_CMD << 16) |
> SXGBE_SMA_SKIP_ADDRFRM |
> > +			   ((priv->clk_csr & 0x7) << 19) | SXGBE_MII_BUSY);
> > +		writel(reg_val, priv->ioaddr + mii_data);
> > +	}
> 
> The whole 'if (phyreg & MII_ADDR_C45) { ... } else { ... }' chunk is shared
with
> sxgbe_mdio_write(..., phydata = 0). Factor out ?
Not exactly same.

> 
> > +
> > +	/* wait till operation succeds */
> > +	if (sxgbe_mdio_busy_wait(priv->ioaddr, mii_data))
> > +		return -EBUSY;
> > +
> > +	/* read and return the data from mmi Data register */
> > +	reg_val = readl(priv->ioaddr + mii_data) & 0xFFFF;
> > +	return reg_val;
> 
> 	return readl(priv->ioaddr + mii_data) & 0xffff;
> 
> Then reduce scope of reg_val.
> 
> > +}
> > +/**
> > + * sxgbe_mdio_write
> > + * @bus: points to the mii_bus structure
> > + * @phyaddr: address of phy port
> > + * @phyreg: address of phy registers
> > + * @phydata: data to be written into phy register
> > + * Description: this function is used for C45 and C22 MDIO write  */
> > +static int sxgbe_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
> > +			    u16 phydata)
> > +{
> 
> See sxgbe_mdio_read for comments.
OK

> 
> [...]
> > +	if (sxgbe_mdio_busy_wait(priv->ioaddr, mii_data))
> > +		return -EBUSY;
> > +
> > +	return 0;
> 
> 	return sxgbe_mdio_busy_wait(priv->ioaddr, mii_data);
> 
> > +}
> > +
> > +int sxgbe_mdio_register(struct net_device *ndev) {
> > +	int err, phy_addr, act;
> 
> Excess scope for act.
OK

> 
> > +	int *irqlist;
> > +	u8 phy_found = 0;
> > +	struct mii_bus *mdio_bus;
> > +	struct sxgbe_priv_data *priv = netdev_priv(ndev);
> > +	struct sxgbe_mdio_bus_data *mdio_data = priv->plat-
> >mdio_bus_data;
> > +
> > +	/* allocate the new mdio bus */
> > +	mdio_bus = mdiobus_alloc();
> > +	if (!mdio_bus) {
> > +		netdev_err(ndev, "%s: mii bus allocation failed\n", __func__);
> > +		return -ENOMEM;
> > +	}
> > +
> > +	if (mdio_data->irqs)
> > +		irqlist = mdio_data->irqs;
> > +	else
> > +		irqlist = priv->mii_irq;
> > +
> > +	/* assign mii bus fields */
> > +	mdio_bus->name = "samsxgbe";
> > +	mdio_bus->read = &sxgbe_mdio_read;
> > +	mdio_bus->write = &sxgbe_mdio_write;
> > +	snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%s-%x",
> > +		 mdio_bus->name, priv->plat->bus_id);
> > +	mdio_bus->priv = ndev;
> > +	mdio_bus->phy_mask = mdio_data->phy_mask;
> > +	mdio_bus->parent = priv->device;
> > +
> > +	/* register with kernel subsystem */
> > +	err = mdiobus_register(mdio_bus);
> > +	if (err != 0) {
> > +		netdev_err(ndev, "mdiobus register failed\n");
> > +		goto mdiobus_err;
> > +	}
> > +
> > +	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
> > +		struct phy_device *phy = mdio_bus->phy_map[phy_addr];
> > +		if (phy) {
> 
> Missing empty line after the declaration.
OK

> 
> [...]
> > +			phy_found = 1;
> > +		}
> > +	}
> > +
> > +	if (!phy_found) {
> > +		netdev_err(ndev, "PHY not found\n");
> > +		mdiobus_unregister(mdio_bus);
> > +		mdiobus_free(mdio_bus);
> > +		return -ENODEV;
> 
> You may remove phy_found, use "err" instead and gotoize on top of
> mdiobus_err.
OK

> 
> > +	}
> > +
> > +	priv->mii = mdio_bus;
> > +
> > +	return 0;
> > +
> > +mdiobus_err:
> > +	mdiobus_free(mdio_bus);
> > +	return err;
> > +}
> [...]
> > +static void sxgbe_mtl_set_txfifosize(void __iomem *ioaddr, int queue_num,
> > +				     int queue_fifo)
> > +{
> > +	u32 fifo_bits, reg_val;
> > +	/* 0 means 256 bytes */
> > +	fifo_bits = (queue_fifo / SXGBE_MTL_TX_FIFO_DIV)-1;
> 
> - Missing empty line after declaration.
> - ')-1' -> ') - 1'
OK

> 
> > +	reg_val = readl(ioaddr +
> SXGBE_MTL_TXQ_OPMODE_REG(queue_num));
> > +	reg_val |= (fifo_bits << SXGBE_MTL_FIFO_LSHIFT);
> > +	writel(reg_val, ioaddr +
> SXGBE_MTL_TXQ_OPMODE_REG(queue_num));
> > +}
> > +
> > +static void sxgbe_mtl_set_rxfifosize(void __iomem *ioaddr, int queue_num,
> > +				     int queue_fifo)
> > +{
> > +	u32 fifo_bits, reg_val;
> > +	/* 0 means 256 bytes */
> > +	fifo_bits = (queue_fifo / SXGBE_MTL_RX_FIFO_DIV)-1;
> 
> Missing empty line after declaration.
OK

> 
> [...]
> > +static const struct sxgbe_mtl_ops mtl_ops = {
> > +	.mtl_set_txfifosize = sxgbe_mtl_set_txfifosize,
> > +	.mtl_set_rxfifosize = sxgbe_mtl_set_rxfifosize,
> > +	.mtl_enable_txqueue = sxgbe_mtl_enable_txqueue,
> > +	.mtl_disable_txqueue = sxgbe_mtl_disable_txqueue,
> > +	.mtl_dynamic_dma_rxqueue = sxgbe_mtl_dma_dm_rxqueue,
> > +	.set_tx_mtl_mode = sxgbe_set_tx_mtl_mode,
> > +	.set_rx_mtl_mode = sxgbe_set_rx_mtl_mode,
> > +	.mtl_init = sxgbe_mtl_init,
> > +	.mtl_fc_active = sxgbe_mtl_fc_active,
> > +	.mtl_fc_deactive = sxgbe_mtl_fc_deactive,
> > +	.mtl_fc_enable = sxgbe_mtl_fc_enable,
> > +	.mtl_fep_enable = sxgbe_mtl_fep_enable,
> > +	.mtl_fep_disable = sxgbe_mtl_fep_disable,
> > +	.mtl_fup_enable = sxgbe_mtl_fup_enable,
> > +	.mtl_fup_disable = sxgbe_mtl_fup_disable
> 
> Please use tabs before "=".
OK

> 
> [...]
> > +static int sxgbe_platform_probe(struct platform_device *pdev) {
> > +	int ret = 0;
> > +	int loop = 0;
> > +	int index1, index2;
> > +	struct resource *res;
> > +	struct device *dev = &pdev->dev;
> > +	void __iomem *addr = NULL;
> 
> Useless init.
OK

> 
> [...]
> > +	priv = sxgbe_dvr_probe(&(pdev->dev), plat_dat, addr);
> > +	if (!priv) {
> > +		pr_err("%s: main driver probe failed\n", __func__);
> > +		return -ENODEV;
> > +	}
> > +
> > +	/* Get MAC address if available (DT) */
> > +	if (mac)
> > +		ether_addr_copy(priv->dev->dev_addr, mac);
> > +
> > +	/* Get the SXGBE common INT information */
> > +	priv->irq  = platform_get_irq(pdev, loop++);
> > +	if (priv->irq <= 0) {
> > +		dev_err(dev, "sxgbe common irq parsing failed\n");
> > +		return -EINVAL;
> 
> No sxgbe_dvr_remove ?
> 
> > +	}
> > +
> > +	/* Get the TX/RX IRQ numbers */
> > +	for (index1 = 0, index2 = 0 ; loop < total_dma_channels; loop++) {
> > +		if (loop < SXGBE_TX_QUEUES) {
> > +			(priv->txq[index1])->irq_no  =
> > +				irq_of_parse_and_map(dev->of_node, loop);
> > +			if ((priv->txq[index1++])->irq_no <= 0) {
> > +				dev_err(dev, "sxgbe tx irq parsing failed\n");
> > +				return -EINVAL;
> > +			}
> > +		} else {
> > +			(priv->rxq[index2])->irq_no  =
> > +				irq_of_parse_and_map(dev->of_node, loop);
> > +			if ((priv->rxq[index2++])->irq_no <= 0) {
> > +				dev_err(dev, "sxgbe rx irq parsing failed\n");
> > +				return -EINVAL;
> > +			}
> > +		}
> > +	}
> 
> (yucky)
> 
> 	struct device_node *node = dev->of_node;
> 
> 	for (i = 0, chan = 0; i < SXGBE_TX_QUEUES; i++) {
> 		priv->txq[i]->irq_no = irq_of_parse_and_map(node, chan++);
> 		if (priv->txq[i]->irq_no <= 0) {
> 			dev_err(dev, "sxgbe tx irq parsing failed\n");
> 			return -EINVAL;
> 		}
> 	}
> 
> 	for (i = 0; i < SXGBE_RX_QUEUES; i++) {
> 		priv->rxq[i]->irq_no = irq_of_parse_and_map(node, chan++);
> 		if (priv->rxq[i]->irq_no <= 0) {
> 			dev_err(dev, "sxgbe rx irq parsing failed\n");
> 			return -EINVAL;
> 		}
> 	}
> 
> It should imho use irq_dispose_mapping in the error path (and balance in
> sxgbe_platform_remove as well).
OK.

> 
> > +
> > +	platform_set_drvdata(pdev, priv->dev);
> > +
> > +	pr_debug("platform driver registration completed\n");
> > +
> > +	return 0;
> > +}
> > +
> > +/**
> > + * sxgbe_platform_remove
> > + * @pdev: platform device pointer
> > + * Description: this function calls the main to free the net
> > +resources
> > + * and calls the platforms hook and release the resources (e.g. mem).
> > + */
> > +static int sxgbe_platform_remove(struct platform_device *pdev) {
> > +	struct net_device *ndev = platform_get_drvdata(pdev);
> > +	int ret = sxgbe_dvr_remove(ndev);
> 
> Declaration, empty line.
> 
> [...]
> > +int sxgbe_platform_freeze(struct device *dev) {
> > +	int ret;
> > +	struct net_device *ndev = dev_get_drvdata(dev);
> > +
> > +	ret = sxgbe_freeze(ndev);
> > +
> > +	return ret;
> 
> Is 'ret' really needed ?
OK

> 
> [...]
> > +static const struct dev_pm_ops sxgbe_platform_pm_ops = {
> > +	.suspend = sxgbe_platform_suspend,
> > +	.resume = sxgbe_platform_resume,
> > +	.freeze = sxgbe_platform_freeze,
> > +	.thaw = sxgbe_platform_restore,
> > +	.restore = sxgbe_platform_restore,
> 
> Please use tabs before '=' to line things up.
OK

> 
> /megotobed
> 
> --
> Ueimor
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of
> a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
