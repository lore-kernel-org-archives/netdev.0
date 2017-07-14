From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/2] net: ethernet: nixge: Add support for National
 Instruments XGE netdev
Date: Fri, 14 Jul 2017 15:16:25 -0700
Message-ID: <4796f41e-f6d5-ccc3-43bf-03913f71d29f@gmail.com>
References: <1500065326-26182-1-git-send-email-mdf@kernel.org>
 <1500065326-26182-2-git-send-email-mdf@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, mark.rutland@arm.com, robh+dt@kernel.org,
        andrew@lunn.ch
To: Moritz Fischer <mdf@kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500065326-26182-2-git-send-email-mdf@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/14/2017 01:48 PM, Moritz Fischer wrote:
> Add support for the National Instruments XGE 1/10G network device.
> 
> It uses the EEPROM on the board via NVMEM.
> 
> Signed-off-by: Moritz Fischer <mdf@kernel.org>
> ---

> +
> +static void nixge_handle_link_change(struct net_device *ndev)
> +{
> +	struct nixge_priv *priv = netdev_priv(ndev);
> +	struct phy_device *phydev = ndev->phydev;
> +	unsigned long flags;
> +	int status_change = 0;
> +
> +	spin_lock_irqsave(&priv->lock, flags);

The adjust_link function is called with the PHY device mutex held so the
spinlock here looks completely unnecessary.

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

It's fine to print what changed, but surely the hardware should also
react to link changes, like change of duplex, speed, pause etc.

> +}
> +
> +static void nixge_start_xmit_done(struct net_device *ndev)
> +{

This should be done in a NAPI context (soft IRQ) as well, except that
for TX you don't need to bind the reclaiming process against the NAPI
budget.

> +	u32 size = 0;
> +	u32 packets = 0;
> +	struct nixge_priv *priv = netdev_priv(ndev);
> +	struct nixge_dma_bd *cur_p;
> +	unsigned int status = 0;
> +
> +	cur_p = &priv->tx_bd_v[priv->tx_bd_ci];
> +	status = cur_p->status;
> +
> +	while (status & XAXIDMA_BD_STS_COMPLETE_MASK) {
> +		dma_unmap_single(ndev->dev.parent, cur_p->phys,
> +				 (cur_p->cntrl & XAXIDMA_BD_CTRL_LENGTH_MASK),
> +				DMA_TO_DEVICE);

Fragments are unmapped with dma_unmap_page(), how are you unmapping them
at the moment?

> +		if (cur_p->app4)
> +			dev_kfree_skb_irq((struct sk_buff *)cur_p->app4);
> +		/*cur_p->phys = 0;*/
> +		cur_p->app0 = 0;
> +		cur_p->app1 = 0;
> +		cur_p->app2 = 0;
> +		cur_p->app4 = 0;
> +		cur_p->status = 0;

Is this really necessary? Your descriptor is in coherent memory which
means that you are doing slow uncached/writethrough accesses to the
memory that holds them. Can't you just set status to 0 for the HW to
ignore this descriptor?

> +
> +		size += status & XAXIDMA_BD_STS_ACTUAL_LEN_MASK;
> +		packets++;
> +
> +		++priv->tx_bd_ci;
> +		priv->tx_bd_ci %= TX_BD_NUM;
> +		cur_p = &priv->tx_bd_v[priv->tx_bd_ci];
> +		status = cur_p->status;
> +	}
> +
> +	ndev->stats.tx_packets += packets;
> +	ndev->stats.tx_bytes += size;
> +	netif_wake_queue(ndev);

You can only wake the queue if you were successful transmitting packets.

> +}
> +
> +static inline int nixge_check_tx_bd_space(struct nixge_priv *priv,
> +					  int num_frag)
> +{
> +	struct nixge_dma_bd *cur_p;
> +
> +	cur_p = &priv->tx_bd_v[(priv->tx_bd_tail + num_frag) % TX_BD_NUM];
> +	if (cur_p->status & XAXIDMA_BD_STS_ALL_MASK)
> +		return NETDEV_TX_BUSY;

You are not propagating this to the caller, so just return a boolean for
this.

> +	return 0;
> +}
> +
> +static int nixge_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	u32 ii;
> +	u32 num_frag;
> +	skb_frag_t *frag;
> +	dma_addr_t tail_p;
> +	struct nixge_priv *priv = netdev_priv(ndev);
> +	struct nixge_dma_bd *cur_p;
> +
> +	num_frag = skb_shinfo(skb)->nr_frags;
> +	cur_p = &priv->tx_bd_v[priv->tx_bd_tail];
> +
> +	if (nixge_check_tx_bd_space(priv, num_frag)) {
> +		if (!netif_queue_stopped(ndev))
> +			netif_stop_queue(ndev);
> +		return NETDEV_TX_BUSY;

NETDEV_TX_OK is what you should return since you properly asserted flow
contro with netif_stop_queue().

> +	}
> +
> +	cur_p->cntrl = skb_headlen(skb) | XAXIDMA_BD_CTRL_TXSOF_MASK;
> +	cur_p->phys = dma_map_single(ndev->dev.parent, skb->data,
> +				     skb_headlen(skb), DMA_TO_DEVICE);

This needs to be checked with dma_mapping_error().

> +
> +	for (ii = 0; ii < num_frag; ii++) {
> +		++priv->tx_bd_tail;
> +		priv->tx_bd_tail %= TX_BD_NUM;
> +		cur_p = &priv->tx_bd_v[priv->tx_bd_tail];
> +		frag = &skb_shinfo(skb)->frags[ii];
> +		cur_p->phys = dma_map_single(ndev->dev.parent,
> +					     skb_frag_address(frag),
> +					     skb_frag_size(frag),
> +					     DMA_TO_DEVICE);

Needs to be checked against dma_mapping_error() and you would have to
unwind the whole SKB linear + fragments mappings and buffer descriptors.

> +		cur_p->cntrl = skb_frag_size(frag);
> +	}
> +
> +	cur_p->cntrl |= XAXIDMA_BD_CTRL_TXEOF_MASK;
> +	cur_p->app4 = (unsigned long)skb;
> +
> +	tail_p = priv->tx_bd_p + sizeof(*priv->tx_bd_v) * priv->tx_bd_tail;
> +	/* Start the transfer */

You might be able to check for (!skb->xmit_more ||
netif_queue_stopped()) here to only do the write when you know for sure
there is nothing more coming.

> +	nixge_dma_write_reg(priv, XAXIDMA_TX_TDESC_OFFSET, tail_p);
> +	++priv->tx_bd_tail;
> +	priv->tx_bd_tail %= TX_BD_NUM;
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static void nixge_recv(struct net_device *ndev)
> +{
> +	u32 length;
> +	u32 size = 0;
> +	u32 packets = 0;
> +	dma_addr_t tail_p = 0;
> +	struct nixge_priv *priv = netdev_priv(ndev);
> +	struct sk_buff *skb, *new_skb;
> +	struct nixge_dma_bd *cur_p;
> +
> +	cur_p = &priv->rx_bd_v[priv->rx_bd_ci];

Please do this in a NAPI context and bound the reception to the NAPI budget.

> +
> +	while ((cur_p->status & XAXIDMA_BD_STS_COMPLETE_MASK)) {
> +		tail_p = priv->rx_bd_p
> +			+ sizeof(*priv->rx_bd_v) * priv->rx_bd_ci;
> +		skb = (struct sk_buff *)(cur_p->sw_id_offset);
> +
> +		length = cur_p->status & 0x7fffff;

You can't trust the HW to return a length that is correct, you need to
check that length is smaller than or equal to priv->max_frm_size here,
otherwise you will overflow your skb size.

> +		dma_unmap_single(ndev->dev.parent, cur_p->phys,
> +				 priv->max_frm_size,
> +				 DMA_FROM_DEVICE);
> +
> +		skb_put(skb, length);
> +
> +		skb->protocol = eth_type_trans(skb, ndev);
> +		skb_checksum_none_assert(skb);
> +
> +		/* For now mark them as CHECKSUM_NONE since
> +		 * we don't have offload capabilities
> +		 */
> +		skb->ip_summed = CHECKSUM_NONE;
> +
> +		netif_rx(skb);

napi_gro_receive() or netif_receive_skb() at the very least, but that
needs a conversion to NAPI first.

> +
> +		size += length;
> +		packets++;
> +
> +		new_skb = netdev_alloc_skb_ip_align(ndev, priv->max_frm_size);
> +		if (!new_skb)
> +			return;
> +
> +		cur_p->phys = dma_map_single(ndev->dev.parent, new_skb->data,
> +					     priv->max_frm_size,
> +					     DMA_FROM_DEVICE);

You need to check for dma_maping_error() here.

> +		cur_p->cntrl = priv->max_frm_size;
> +		cur_p->status = 0;
> +		cur_p->sw_id_offset = (u32)new_skb;
> +
> +		++priv->rx_bd_ci;
> +		priv->rx_bd_ci %= RX_BD_NUM;
> +		cur_p = &priv->rx_bd_v[priv->rx_bd_ci];
> +	}
> +
> +	ndev->stats.rx_packets += packets;
> +	ndev->stats.rx_bytes += size;
> +
> +	if (tail_p)
> +		nixge_dma_write_reg(priv, XAXIDMA_RX_TDESC_OFFSET, tail_p);
> +}

> +static int nixge_open(struct net_device *ndev)
> +{
> +	struct nixge_priv *priv = netdev_priv(ndev);
> +	struct phy_device *phy;
> +	int ret;
> +
> +	nixge_device_reset(ndev);
> +
> +	phy = of_phy_connect(ndev, priv->phy_node,
> +			     &nixge_handle_link_change, 0, priv->phy_mode);
> +	if (!phy)
> +		return -ENODEV;
> +
> +	phy_start(phy);
> +
> +	/* Enable tasklets for Axi DMA error handling */
> +	tasklet_init(&priv->dma_err_tasklet, nixge_dma_err_handler,
> +		     (unsigned long)priv);
> +
> +	/* Enable interrupts for Axi DMA Tx */
> +	ret = request_irq(priv->tx_irq, nixge_tx_irq, 0, ndev->name, ndev);
> +	if (ret)
> +		goto err_tx_irq;
> +	/* Enable interrupts for Axi DMA Rx */
> +	ret = request_irq(priv->rx_irq, nixge_rx_irq, 0, ndev->name, ndev);
> +	if (ret)
> +		goto err_rx_irq;

netif_start_queue() is missing, if your queues were stopped before (try
several up/down/up/down sequences to check) then it would never transmit.

> +
> +	return 0;
> +
> +err_rx_irq:
> +	free_irq(priv->tx_irq, ndev);
> +err_tx_irq:
> +	tasklet_kill(&priv->dma_err_tasklet);
> +	netdev_err(ndev, "request_irq() failed\n");

You are not stopping nor disconnecting the PHY in case of error.

> +	return ret;
> +}
> +
> +static int nixge_stop(struct net_device *ndev)
> +{
> +	u32 cr;
> +	struct nixge_priv *priv = netdev_priv(ndev);

First thing is probably to stop the transmit queue(s) with
netif_stop_queue() to avoid submitting new packets.

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
> +		phy_stop(ndev->phydev);
> +		phy_disconnect(ndev->phydev);
> +	}
> +
> +	return 0;
> +}
> +

> +
> +static void nixge_ethtools_get_drvinfo(struct net_device *ndev,
> +				       struct ethtool_drvinfo *ed)
> +{
> +	strlcpy(ed->driver, "nixge", sizeof(ed->driver));

You might want to return the bus type as well (e.g: platform).

> +}
> +
> +static int nixge_ethtools_get_coalesce(struct net_device *ndev,
> +				       struct ethtool_coalesce *ecoalesce)
> +{
> +	u32 regval = 0;
> +	struct nixge_priv *priv = netdev_priv(ndev);

Reverse christmas tree declarations.

> +
> +	regval = nixge_dma_read_reg(priv, XAXIDMA_RX_CR_OFFSET);
> +	ecoalesce->rx_max_coalesced_frames = (regval & XAXIDMA_COALESCE_MASK)
> +					     >> XAXIDMA_COALESCE_SHIFT;
> +	regval = nixge_dma_read_reg(priv, XAXIDMA_TX_CR_OFFSET);
> +	ecoalesce->tx_max_coalesced_frames = (regval & XAXIDMA_COALESCE_MASK)
> +					     >> XAXIDMA_COALESCE_SHIFT;
> +	return 0;
> +}
> +
> +static int nixge_ethtools_set_coalesce(struct net_device *ndev,
> +				       struct ethtool_coalesce *ecoalesce)
> +{
> +	struct nixge_priv *priv = netdev_priv(ndev);
> +
> +	if (netif_running(ndev)) {
> +		netdev_err(ndev,
> +			   "Please stop netif before applying configuration\n");
> +		return -EFAULT;

-EBUSY may be, or -EINVAL? You are supposed to be able to allow changing
coalescing parameters while the interface is running.

> +	}

> +	err = nixge_ctrl_poll_timeout(priv, NIXGE_REG_MDIO_CTRL, status,
> +				      !status, 10, 1000);
> +	if (err) {
> +		dev_err(priv->dev, "timeout setting read command");
> +		return err;
> +	}
> +
> +	status = nixge_ctrl_read_reg(priv, NIXGE_REG_MDIO_DATA);
> +
> +	dev_dbg(priv->dev, "%s: phy_id = %x reg = %x got %x\n", __func__,
> +		phy_id, reg & 0xffff, status);

mdiobus_read() already contains trace points that would return the same
information.

> +
> +	return status;
> +}
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

Then you might as well remove Clause 45 read support, because it's not
going to be very useful if you can't do writes. I could see how this
allows you to get e.g: a 10GB PHY working with little to no intervention.

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

You don't appear to be using this resource.

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

This is redundant with what you can obtain from of_mdiobus_register()
and a "... MDIO bus probed type of message.

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
> +	return mac;
> +}

I would if this could be a candidate for some kind of generic helper
function that would retrieve the MAC address, food for thought.

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
> +	if (mac_addr && is_valid_ether_addr(mac_addr))
> +		ether_addr_copy(ndev->dev_addr, mac_addr);
> +	else
> +		eth_hw_addr_random(ndev);
> +
> +	priv = netdev_priv(ndev);
> +	priv->ndev = ndev;
> +	priv->dev = &pdev->dev;
> +	priv->rxmem = NIXGE_DEFAULT_RX_MEM;
> +
> +	dmares = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	priv->dma_regs = devm_ioremap_resource(&pdev->dev, dmares);
> +	if (IS_ERR(priv->dma_regs)) {
> +		netdev_err(ndev, "failed to map dma regs\n");
> +		return PTR_ERR(priv->dma_regs);
> +	}
> +	priv->ctrl_regs = priv->dma_regs + NIXGE_REG_CTRL_OFFSET;
> +	__nixge_hw_set_mac_address(ndev);
> +
> +	priv->tx_irq = platform_get_irq_byname(pdev, "tx-irq");
> +	if (priv->tx_irq < 0) {
> +		netdev_err(ndev, "no tx irq available");
> +		return priv->tx_irq;
> +	}
> +
> +	priv->rx_irq = platform_get_irq_byname(pdev, "rx-irq");
> +	if (priv->rx_irq < 0) {
> +		netdev_err(ndev, "no rx irq available");
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
> +		netdev_err(ndev, "error registering mdio bus");
> +		goto free_netdev;
> +	}
> +
> +	priv->phy_mode = of_get_phy_mode(pdev->dev.of_node);
> +	if (priv->phy_mode < 0) {
> +		netdev_err(ndev, "not find phy-mode\n");

"Could not find \"phy-mode\" property" maybe?

> +		err = -EINVAL;
> +		goto unregister_mdio;
> +	}
> +
> +	priv->phy_node = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
> +	if (!priv->phy_node) {
> +		netdev_err(ndev, "not find phy-handle\n");

Same here.

> +		err = -EINVAL;
> +		goto unregister_mdio;
> +	}
> +
> +	err = register_netdev(priv->ndev);
> +	if (err) {
> +		netdev_err(ndev, "register_netdev() error (%i)\n", err);
> +		goto unregister_mdio;
> +	}
> +
> +	return 0;
> +
> +unregister_mdio:
> +	mdiobus_unregister(priv->mii_bus);
> +	mdiobus_free(priv->mii_bus);
> +
> +free_netdev:
> +	free_netdev(ndev);
> +
> +	return err;
> +}
> +
> +static int nixge_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +	struct nixge_priv *priv = netdev_priv(ndev);
> +
> +	if (ndev->phydev)
> +		phy_disconnect(ndev->phydev);

You should consider moving this to the ndo_stop() for mainly two reasons:

- to be strictly symmetrical with your ndo_open() function which does
the of_phy_connect() call
- to leverage possible power savings by suspending the PHY when the
interface is not used

> +	ndev->phydev = NULL;

phy_disconnect() does NULLify dev->phydev already

> +
> +	mdiobus_unregister(priv->mii_bus);
> +	mdiobus_free(priv->mii_bus);
> +	priv->mii_bus = NULL;

This is not necessary, probe() and remove() won't be called with
partially initialized private structure data.

> +
> +	unregister_netdev(ndev);
> +
> +	free_netdev(ndev);
> +
> +	return 0;
> +}
> +
> +/* Match table for of_platform binding */
> +static const struct of_device_id nixge_dt_ids[] = {
> +	{ .compatible = "ni,xge-enet-2.00", },
> +	{},
> +};
> +MODULE_DEVICE_TABLE(of, nixge_dt_ids);
> +
> +static struct platform_driver nixge_driver = {
> +	.probe		= nixge_probe,
> +	.remove		= nixge_remove,
> +	.driver		= {
> +		.name		= "nixge",
> +		.of_match_table	= of_match_ptr(nixge_dt_ids),
> +	},
> +};
> +module_platform_driver(nixge_driver);
> +
> +MODULE_LICENSE("GPL");
> +MODULE_DESCRIPTION("National Instruments XGE Management MAC");
> +MODULE_AUTHOR("Moritz Fischer <mdf@kernel.org>");
> 


-- 
Florian
