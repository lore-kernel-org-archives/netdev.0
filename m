From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/3] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Thu, 22 Oct 2015 17:31:53 -0700
Message-ID: <56297FF9.4070801@gmail.com>
References: <1445522558-5808-1-git-send-email-mans@mansr.com> <1445522558-5808-3-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Mans Rullgard <mans@mansr.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33997 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758130AbbJWAc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 20:32:29 -0400
In-Reply-To: <1445522558-5808-3-git-send-email-mans@mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/10/15 07:02, Mans Rullgard wrote:
> This adds a driver for the Aurora VLSI NB8800 Ethernet controller.
> It is an almost complete rewrite of a driver originally found in
> a Sigma Designs 2.6.22 tree.

Some reviews here and there, mostly related to how you use the PHY library.

[snip]

> +	buf->page = virt_to_head_page(data);
> +	buf->offset = data - page_address(buf->page);
> +
> +	rx->s_addr = dma_map_page(&dev->dev, buf->page, buf->offset,
> +				  RX_BUF_SIZE, DMA_FROM_DEVICE);

Missing dma_mapping_error() check here?

[snip]

> +	dma_len = skb->len - cpsz;
> +	dma_addr = dma_map_single(&dev->dev, skb->data + cpsz,
> +				  dma_len, DMA_TO_DEVICE);

Ditto, missing dma_mapping_error() check.

[snip]

> +	nb8800_tx_dma_start(dev, next);
> +
> +	if (!skb->xmit_more && !timer_pending(&priv->tx_reclaim_timer))
> +		mod_timer(&priv->tx_reclaim_timer, jiffies + HZ / 20);

You do not have a TX completion interrupt? Using a timer to reclaim TX
buffers is really not great for latency.

> +
> +	if (atomic_read(&priv->tx_free) <= NB8800_DESC_LOW)
> +		netif_stop_queue(dev);
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static void nb8800_tx_reclaim(unsigned long data)
> +{
> +	struct net_device *dev = (struct net_device *)data;
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +	int packets = 0, bytes = 0;
> +	int reclaimed = 0;
> +	int dirty, limit;
> +
> +	dirty = xchg(&priv->tx_dirty, -1);
> +	if (dirty < 0)
> +		return;
> +
> +	limit = priv->tx_reclaim_limit;
> +	if (dirty == limit)
> +		goto end;
> +
> +	while (dirty != limit) {
> +		struct nb8800_dma_desc *tx = &priv->tx_descs[dirty];
> +		struct tx_buf *tx_buf = &priv->tx_bufs[dirty];
> +		struct sk_buff *skb = tx_buf->skb;
> +		struct tx_skb_data *skb_data = (struct tx_skb_data *)skb->cb;
> +		int frags = tx_buf->frags;
> +
> +		packets++;
> +		bytes += skb->len;
> +
> +		dma_unmap_single(&dev->dev, skb_data->dma_addr,
> +				 skb_data->dma_len, DMA_TO_DEVICE);
> +		dev_kfree_skb(skb);
> +
> +		tx->report = 0;
> +		tx_buf->skb = NULL;
> +		tx_buf->frags = 0;
> +
> +		dirty = (dirty + frags) & (TX_DESC_COUNT - 1);
> +		reclaimed += frags;
> +	}
> +
> +	priv->stats.tx_packets += packets;
> +	priv->stats.tx_bytes += bytes;
> +
> +	smp_mb__before_atomic();
> +	atomic_add(reclaimed, &priv->tx_free);
> +
> +	netif_wake_queue(dev);

You can only wake up your queue if you have successfully reclaimed
transmitted buffers, otherwise this is giving false information to the
stack that there is room to push more packets.

[snip]

> +static irqreturn_t nb8800_isr(int irq, void *dev_id)
> +{
> +	struct net_device *dev = dev_id;
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +	u32 val;
> +
> +	/* tx interrupt */
> +	val = nb8800_readl(priv, NB8800_TXC_SR);
> +	if (val) {
> +		nb8800_writel(priv, NB8800_TXC_SR, val);
> +
> +		if (likely(val & TSR_TI))
> +			nb8800_tx_done(dev);

Ok, so there is a TX interrupt, so what is the timer used for?

> +
> +		if (unlikely(val & TSR_DE))
> +			netdev_err(dev, "TX DMA error\n");
> +
> +		if (unlikely(val & TSR_TO))
> +			netdev_err(dev, "TX Status FIFO overflow\n");
> +	}
> +
> +	/* rx interrupt */
> +	val = nb8800_readl(priv, NB8800_RXC_SR);
> +	if (val) {
> +		nb8800_writel(priv, NB8800_RXC_SR, val);
> +
> +		if (likely(val & RSR_RI))
> +			napi_schedule_irqoff(&priv->napi);
> +
> +		if (unlikely(val & RSR_DE))
> +			netdev_err(dev, "RX DMA error\n");
> +
> +		if (unlikely(val & RSR_RO)) {
> +			int i;
> +
> +			netdev_err(dev, "RX Status FIFO overflow\n");
> +
> +			for (i = 0; i < 4; i++)
> +				nb8800_readl(priv, NB8800_RX_FIFO_SR);
> +		}
> +	}
> +
> +	/* wake on lan */
> +	val = nb8800_readb(priv, NB8800_WAKEUP);
> +	if (val == 1) {
> +		nb8800_writeb(priv, NB8800_SLEEP_MODE, 0);
> +		nb8800_writeb(priv, NB8800_WAKEUP, 0);

It is nice to account for such wake-up events by calling
pm_wakeup_event(). Since you do not support configuring Wake-on-LAN yet,
you might as well drop this, unless such interrupt needs to be cleared?

> +	}
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static void nb8800_mac_config(struct net_device *dev)
> +{
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +
> +	if (priv->duplex)
> +		nb8800_clear_bits(b, priv, NB8800_MAC_MODE, HALF_DUPLEX);
> +	else
> +		nb8800_set_bits(b, priv, NB8800_MAC_MODE, HALF_DUPLEX);
> +
> +	if (priv->speed == SPEED_1000) {
> +		nb8800_set_bits(b, priv, NB8800_MAC_MODE,
> +				RGMII_MODE | GMAC_MODE);
> +		nb8800_writeb(priv, NB8800_IC_THRESHOLD, 3);

What is the IC_THRESHOLD value for? Is this some form of interrupt
coalescing? If so, there is a proper ethtool interface to configure that.

> +		nb8800_writeb(priv, NB8800_SLOT_TIME, 255);
> +	} else {
> +		nb8800_clear_bits(b, priv, NB8800_MAC_MODE,
> +				  RGMII_MODE | GMAC_MODE);
> +		nb8800_writeb(priv, NB8800_IC_THRESHOLD, 1);
> +		nb8800_writeb(priv, NB8800_SLOT_TIME, 127);

What about if you link at 10Mbits/sec, would the slot time value still
make sense here?

> +	}
> +}
> +
> +static void nb8800_link_reconfigure(struct net_device *dev)
> +{
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +	struct phy_device *phydev = priv->phydev;
> +
> +	if (phydev->speed == priv->speed && phydev->duplex == priv->duplex &&
> +	    phydev->link == priv->link)
> +		return;
> +
> +	if (phydev->link != priv->link || phydev->link)
> +		phy_print_status(priv->phydev);
> +
> +	priv->speed = phydev->speed;
> +	priv->duplex = phydev->duplex;
> +	priv->link = phydev->link;
> +
> +	if (priv->link)
> +		nb8800_mac_config(dev);
> +}
> +
> +static void nb8800_update_mac_addr(struct net_device *dev)
> +{
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +
> +	nb8800_writeb(priv, NB8800_MAC_ADDR1, dev->dev_addr[0]);
> +	nb8800_writeb(priv, NB8800_MAC_ADDR2, dev->dev_addr[1]);
> +	nb8800_writeb(priv, NB8800_MAC_ADDR3, dev->dev_addr[2]);
> +	nb8800_writeb(priv, NB8800_MAC_ADDR4, dev->dev_addr[3]);
> +	nb8800_writeb(priv, NB8800_MAC_ADDR5, dev->dev_addr[4]);
> +	nb8800_writeb(priv, NB8800_MAC_ADDR6, dev->dev_addr[5]);

How about a for loop and make the NB8800_MAC_ADDR take an optional
offset argument?

> +
> +	nb8800_writeb(priv, NB8800_UC_ADDR1, dev->dev_addr[0]);
> +	nb8800_writeb(priv, NB8800_UC_ADDR2, dev->dev_addr[1]);
> +	nb8800_writeb(priv, NB8800_UC_ADDR3, dev->dev_addr[2]);
> +	nb8800_writeb(priv, NB8800_UC_ADDR4, dev->dev_addr[3]);
> +	nb8800_writeb(priv, NB8800_UC_ADDR5, dev->dev_addr[4]);
> +	nb8800_writeb(priv, NB8800_UC_ADDR6, dev->dev_addr[5]);

Same here.

[snip]

> +
> +static void nb8800_set_rx_mode(struct net_device *dev)
> +{
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +	struct netdev_hw_addr *ha;
> +	int af_en;
> +
> +	if ((dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) ||
> +	    netdev_mc_count(dev) > 64)

64, that's pretty generous for a perfect match filter, nice.

> +		af_en = 0;
> +	else
> +		af_en = 1;
> +
> +	nb8800_mac_af(dev, af_en);
> +
> +	if (!af_en)
> +		return;
> +
> +	nb8800_mc_init(dev, 0);
> +
> +	netdev_for_each_mc_addr(ha, dev) {
> +		char *addr = ha->addr;
> +
> +		nb8800_writeb(priv, NB8800_MC_ADDR1, addr[0]);
> +		nb8800_writeb(priv, NB8800_MC_ADDR2, addr[1]);
> +		nb8800_writeb(priv, NB8800_MC_ADDR3, addr[2]);
> +		nb8800_writeb(priv, NB8800_MC_ADDR4, addr[3]);
> +		nb8800_writeb(priv, NB8800_MC_ADDR5, addr[4]);
> +		nb8800_writeb(priv, NB8800_MC_ADDR6, addr[5]);

And here.

> +
> +		nb8800_mc_init(dev, 0xff);
> +	}
> +}
> +
> +static void nb8800_dma_reinit(struct net_device *dev)
> +{
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +	struct nb8800_dma_desc *rx;
> +	int i;
> +
> +	priv->tx_pending = -1;
> +	priv->tx_reclaim_limit = 0;
> +	priv->tx_dirty = 0;
> +	priv->tx_next = 0;
> +	priv->tx_done = 0;
> +	atomic_set(&priv->tx_free, TX_DESC_COUNT);
> +
> +	priv->rx_eoc = RX_DESC_COUNT - 1;
> +
> +	for (i = 0; i < RX_DESC_COUNT - 1; i++) {
> +		rx = &priv->rx_descs[i];
> +		rx->report = 0;
> +		rx->config &= ~DESC_EOC;
> +	}
> +
> +	rx = &priv->rx_descs[i];
> +	rx->report = 0;
> +	rx->config |= DESC_EOC;
> +
> +	nb8800_writel(priv, NB8800_TX_DESC_ADDR, priv->tx_desc_dma);
> +	nb8800_writel(priv, NB8800_RX_DESC_ADDR, priv->rx_desc_dma);
> +}
> +
> +static int nb8800_open(struct net_device *dev)
> +{
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +
> +	phy_resume(priv->phydev);

Unnecessary, phy_start() would take care of that if you PHY was already
suspended.

> +	phy_start(priv->phydev);

Usually, this is one of the last things you do.

> +
> +	nb8800_writel(priv, NB8800_RXC_SR, 0xf);
> +	nb8800_writel(priv, NB8800_TXC_SR, 0xf);
> +
> +	nb8800_dma_reinit(dev);
> +	wmb();		/* ensure all setup is written before starting */
> +	nb8800_start_rx(dev);
> +
> +	nb8800_mac_rx(dev, 1);
> +	nb8800_mac_tx(dev, 1);
> +
> +	napi_enable(&priv->napi);
> +	netif_start_queue(dev);
> +
> +	return 0;
> +}
> +
> +static int nb8800_stop(struct net_device *dev)
> +{
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +
> +	netif_stop_queue(dev);
> +	napi_disable(&priv->napi);
> +
> +	nb8800_stop_rx(dev);
> +
> +	nb8800_mac_rx(dev, 0);
> +	nb8800_mac_tx(dev, 0);
> +
> +	phy_stop(priv->phydev);

Since you seem to support clock reference, phy_stop() is not
synchronous, only phy_disconnect() is, so there could still be work
pending after nb8800_stop() which triggers a deferred MDIO read/write
operation.

> +	phy_suspend(priv->phydev);
> +
> +	return 0;
> +}
> +
> +static struct net_device_stats *nb8800_get_stats(struct net_device *dev)
> +{
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +
> +	return &priv->stats;

Cannot you return dev->stats directly?

[snip]

> +static u32 nb8800_get_link(struct net_device *dev)
> +{
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +
> +	phy_read_status(priv->phydev);
> +
> +	return priv->phydev->link;

	return ethtool_op_get_link(dev);

> +}
> +
> +static struct ethtool_ops nb8800_ethtool_ops = {
> +	.get_settings		= nb8800_get_settings,
> +	.set_settings		= nb8800_set_settings,
> +	.nway_reset		= nb8800_nway_reset,
> +	.get_link		= nb8800_get_link,

ethtool_op_get_link() here actually.

[snip]

> +
> +static void nb8800_tangox_init(struct net_device *dev)
> +{
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +	u32 val;
> +
> +	val = nb8800_readb(priv, NB8800_TANGOX_PAD_MODE) & 0x78;
> +	if (priv->phydev->supported & PHY_1000BT_FEATURES)
> +		val |= 1;
> +	nb8800_writeb(priv, NB8800_TANGOX_PAD_MODE, val);

Is this possibly a RGMII delay setting? If so, you need to look at
phydev->interface, not whether Gigabit is supported or not.

[snip]

> +	ret = mdiobus_register(bus);
> +	if (ret) {
> +		dev_err(&pdev->dev, "failed to register MII bus\n");
> +		goto err_disable_clk;
> +	}

How about of_mdiobus_register() here instead such that if you have
Ethernet PHY nodes in your Device Tree, they get registered as PHY devices?

> +
> +	phydev = phy_find_first(bus);
> +	if (!phydev || phy_read(phydev, MII_BMSR) <= 0) {

What is this additional MII_MBSR read used for?

> +		dev_err(&pdev->dev, "no PHY detected\n");
> +		ret = -ENODEV;
> +		goto err_free_bus;
> +	}
> +
> +	priv->mii_bus = bus;
> +	priv->phydev = phydev;
> +
> +	phydev->irq = PHY_POLL;
> +
> +	ret = phy_connect_direct(dev, phydev, nb8800_link_reconfigure,
> +				 phy_mode);
> +	if (ret)
> +		goto err_free_bus;

phy_connect_direct() starts the PHY state machine (unlike
phy_attach_direct), so you should rather move this to the ndo_open()
function to avoid having the PHY being polled before your network device
is ready. In case your network interface is not brought up, you might
end-up polling the PHY for nothing.

> +
> +	dev_info(&pdev->dev, "PHY: found %s at 0x%x\n",
> +		 phydev->drv->name, phydev->addr);
> +
> +	if (ops && ops->init)
> +		ops->init(dev);
> +
> +	ret = nb8800_hw_init(dev);
> +	if (ret)
> +		goto err_detach_phy;
> +
> +	ret = nb8800_dma_init(dev);
> +	if (ret)
> +		goto err_detach_phy;

This allocates buffer, so same thing, if your interface is never brough
up, you are potentially wasting some memory which is there sitting for
the network interface to be there.

> +
> +	ret = request_irq(irq, nb8800_isr, 0, dev_name(&pdev->dev), dev);
> +	if (ret)
> +		goto err_free_dma;

Most drivers do request_irq() in their ndo_open() function, for the same
reason as above.

> +
> +	dev->netdev_ops = &nb8800_netdev_ops;
> +	dev->ethtool_ops = &nb8800_ethtool_ops;
> +	dev->tx_queue_len = TX_DESC_COUNT;

Why do you need to override this? Is not 1000 good enough?

[snip]

> +
> +static int nb8800_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +	struct nb8800_priv *priv = netdev_priv(ndev);
> +
> +	unregister_netdev(ndev);
> +	free_irq(ndev->irq, ndev);
> +
> +	phy_detach(priv->phydev);
> +	mdiobus_unregister(priv->mii_bus);
> +
> +	clk_disable_unprepare(priv->clk);
> +
> +	nb8800_dma_free(ndev);
> +	free_netdev(ndev);

Should not there be a tangox specific callback here to de-initialize the HW?
-- 
Florian
