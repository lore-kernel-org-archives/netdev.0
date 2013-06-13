From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3] ethernet/arc/arc_emac - Add new driver
Date: Fri, 14 Jun 2013 00:19:46 +0200
Message-ID: <20130613221946.GA16632@electric-eye.fr.zoreil.com>
References: <1371134239-4531-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Joe Perches <joe@perches.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1371134239-4531-1-git-send-email-abrodkin@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Brodkin <Alexey.Brodkin@synopsys.com> :
[...]
> diff --git a/drivers/net/ethernet/arc/arc_emac.h b/drivers/net/ethernet/arc/arc_emac.h
> new file mode 100644
> index 0000000..6691db2
> --- /dev/null
> +++ b/drivers/net/ethernet/arc/arc_emac.h
[...]
> +struct arc_emac_priv {
> +	struct net_device_stats stats;
> +	unsigned int clock_frequency;
> +	unsigned int max_speed;
> +
> +	/* Pointers to BD rings - CPU side */
> +	struct arc_emac_bd_t *rxbd;

There does not seem to be much need for rxbd->data.

> +	struct arc_emac_bd_t *txbd;

[...]
> +static int arc_emac_get_settings(struct net_device *ndev,
> +				 struct ethtool_cmd *cmd)
> +{
> +	struct arc_emac_priv *priv = netdev_priv(ndev);
> +
> +	if (priv->phy_dev)
> +		return phy_ethtool_gset(priv->phy_dev, cmd);

arc_emac_probe() succeeded : priv->phy_dev can't be NULL.

[...]
> +static int arc_emac_set_settings(struct net_device *ndev,
> +				 struct ethtool_cmd *cmd)
> +{
> +	struct arc_emac_priv *priv = netdev_priv(ndev);
> +
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +
> +	if (priv->phy_dev)
> +		return phy_ethtool_sset(priv->phy_dev, cmd);

priv->phy_dev can't be NULL either.

[...]
> +static int arc_emac_poll(struct napi_struct *napi, int budget)
> +{
> +	struct net_device *ndev = napi->dev;
> +	struct arc_emac_priv *priv = netdev_priv(ndev);
> +	unsigned int i, loop, work_done = 0;
> +	struct sk_buff *skb;
> +
> +	/* Loop thru the BD chain, but not always from 0.
> +	 * Start from right after where we last saw a packet.
> +	 */
> +	i = priv->last_rx_bd;
> +
> +	for (loop = 0; loop < RX_BD_NUM; loop++) {
> +		struct net_device_stats *stats = &priv->stats;
> +		struct buffer_state *rx_buff;
> +		struct arc_emac_bd_t *rxbd;
> +		dma_addr_t addr;
> +		unsigned int info, pktlen;
> +		unsigned int buflen = ndev->mtu + EMAC_BUFFER_PAD;
> +
> +		i = (i + 1) % RX_BD_NUM;
> +		rx_buff = &priv->rx_buff[i];
> +		rxbd = &priv->rxbd[i];
> +		info = rxbd->info;

You may / should update 'i' so that you can:

		struct buffer_state *rx_buff = priv->rx_buff + i;
		struct arc_emac_bd_t *rxbd = priv->rxbd + i;
		unsigned int pktlen, info = rxbd->info;

> +
> +		/* Process current BD */
> +
> +		if (unlikely((info & OWN_MASK) == FOR_EMAC)) {
> +			/* BD is still owned by EMAC */
> +			continue;
> +		}

Processing starts at priv->last_rx_bd. Could it not be a 'break' ?

[...]
> +		pktlen = info & LEN_MASK;
> +		stats->rx_packets++;
> +		stats->rx_bytes += pktlen;
> +		skb = rx_buff->skb;
> +		skb_put(skb, pktlen);
> +		skb->dev = ndev;
> +		skb->protocol = eth_type_trans(skb, ndev);
> +		netif_receive_skb(skb);
> +
> +		dma_unmap_single(&ndev->dev,
> +				 dma_unmap_addr(&rx_buff, addr),
> +				 dma_unmap_len(&rx_buff, len),
> +				 DMA_FROM_DEVICE);

		dma_unmap_single(&ndev->dev, dma_unmap_addr(&rx_buff, addr),
				 dma_unmap_len(&rx_buff, len), DMA_FROM_DEVICE);

Please unmap before netif_receive_skb.

> +
> +		/* Prepare the BD for next cycle */
> +		rx_buff->skb = netdev_alloc_skb_ip_align(ndev, buflen);
> +		if (unlikely(!rx_buff->skb)) {
> +			if (net_ratelimit())
> +				netdev_err(ndev, "cannot allocate skb\n");
> +			stats->rx_errors++;
> +			continue;
> +		}

The descriptor entry is left unchanged. Afaiu the driver will move to the
next descriptor and crash on dereferencing NULL (rx_buff->)skb next time
it wraps.

I suggest avoiding holes: don't netif_receive_skb if you can't alloc a new
skb.

[...]
> +static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
> +{
> +	struct net_device *ndev = dev_instance;
> +	struct arc_emac_priv *priv = netdev_priv(ndev);
> +	struct net_device_stats *stats = &priv->stats;
> +	unsigned int status;
> +
> +	status = arc_reg_get(priv, R_STATUS);
> +	status &= ~MDIO_MASK;
> +
> +	/* Reset all flags except "MDIO complete"*/
> +	arc_reg_set(priv, R_STATUS, status);
> +
> +	if (status & RXINT_MASK) {
> +		if (likely(napi_schedule_prep(&priv->napi))) {
> +			arc_reg_clr(priv, R_ENABLE, RXINT_MASK);
> +			__napi_schedule(&priv->napi);
> +		}
> +	}
> +
> +	if (status & TXINT_MASK) {

You may consider moving everything into the napi poll handler.

[...]
> +static int arc_emac_open(struct net_device *ndev)
> +{
> +	struct arc_emac_priv *priv = netdev_priv(ndev);
> +	struct phy_device *phy_dev = priv->phy_dev;
> +	struct arc_emac_bd_t *bd;
> +	struct sk_buff *skb;
> +	int i;
> +
> +	phy_dev->autoneg = AUTONEG_ENABLE;
> +	phy_dev->speed = 0;
> +	phy_dev->duplex = 0;
> +	phy_dev->advertising = phy_dev->supported;
> +
> +	if (priv->max_speed > 100) {
> +		phy_dev->advertising &= PHY_GBIT_FEATURES;
> +	} else if (priv->max_speed <= 100) {
> +		phy_dev->advertising &= PHY_BASIC_FEATURES;
> +		if (priv->max_speed <= 10) {
> +			phy_dev->advertising &= ~SUPPORTED_100baseT_Half;
> +			phy_dev->advertising &= ~SUPPORTED_100baseT_Full;
> +		}
> +	}
> +
> +	/* Allocate and set buffers for Rx BD's */
> +	bd = priv->rxbd;
> +	for (i = 0; i < RX_BD_NUM; i++) {
> +		skb = netdev_alloc_skb_ip_align(ndev, ndev->mtu +
> +						EMAC_BUFFER_PAD);
> +

Missing NULL check.

[...]
> +	/* Set BD ring pointers for device side */
> +	arc_reg_set(priv, R_RX_RING,
> +		     (unsigned int)priv->rxbd_dma_hdl);

	arc_reg_set(priv, R_RX_RING, (unsigned int)priv->rxbd_dma_hdl);

> +
> +	arc_reg_set(priv, R_TX_RING,
> +		     (unsigned int)priv->rxbd_dma_hdl + RX_RING_SZ);

Forgot priv->txbd_dma_hdl ?

> +
> +	/* Set Poll rate so that it polls every 1 ms */
> +	arc_reg_set(priv, R_POLLRATE,
> +		     priv->clock_frequency / 1000000);

	arc_reg_set(priv, R_POLLRATE, priv->clock_frequency / 1000000);

> +
> +	/* Enable interrupts */
> +	arc_reg_set(priv, R_ENABLE,
> +		     TXINT_MASK | RXINT_MASK | ERR_MASK);

	arc_reg_set(priv, R_ENABLE, TXINT_MASK | RXINT_MASK | ERR_MASK);

> +
> +	/* Set CONTROL */
> +	arc_reg_set(priv, R_CTRL,
> +		     (RX_BD_NUM << 24) |	/* RX BD table length */
> +		     (TX_BD_NUM << 16) |	/* TX BD table length */
> +		     TXRN_MASK | RXRN_MASK);
> +
> +	/* Enable EMAC */
> +	arc_reg_or(priv, R_CTRL, EN_MASK);
> +
> +	phy_start_aneg(priv->phy_dev);
> +
> +	netif_start_queue(ndev);
> +	napi_enable(&priv->napi);

napi must be enabled before the first rx packet / irq kicks in.

[...]
> +static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	struct arc_emac_priv *priv = netdev_priv(ndev);
> +	unsigned int info, len, *txbd_curr = &priv->txbd_curr;
> +	dma_addr_t addr;
> +	char *pkt = skb->data;
> +
> +	len = max_t(unsigned int, ETH_ZLEN, skb->len);

The device automatically pads, right ?

> +	info = priv->txbd[*txbd_curr].info;
> +
> +	/* EMAC still holds this buffer in its possession.
> +	 * CPU must not modify this buffer descriptor
> +	 */
> +	if (unlikely((info & OWN_MASK) == FOR_EMAC)) {
> +		netif_stop_queue(ndev);
> +		return NETDEV_TX_BUSY;

It is more than unlikely: you may check for it as a bug but you should
stop_queue when the tx ring is full (before returning below).

> +	}
> +
> +	addr = dma_map_single(&ndev->dev, (void *)pkt, len, DMA_TO_DEVICE);
> +	if (unlikely(dma_mapping_error(&ndev->dev, addr))) {
> +		dev_kfree_skb(skb);
> +		return NETDEV_TX_OK;

Please update tx_dropped stats.

> +	}
> +	dma_unmap_addr_set(&priv->tx_buff[*txbd_curr], mapping, addr);
> +	dma_unmap_len_set(&priv->tx_buff[*txbd_curr], len, len);
> +
> +	priv->tx_buff[*txbd_curr].skb = skb;
> +	priv->txbd[*txbd_curr].data = pkt;

Insert memory barrier.

> +	priv->txbd[*txbd_curr].info = FOR_EMAC | FRST_MASK | LAST_MASK | len;
> +
> +	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
> +
> +	arc_reg_set(priv, R_STATUS, TXPL_MASK);
> +
> +	skb_tx_timestamp(skb);
> +
> +	return NETDEV_TX_OK;
> +}

[...]
> +static int arc_emac_probe(struct platform_device *pdev)
> +{
[...]
> +	err = arc_mdio_probe(pdev->dev.of_node, priv);
> +	if (err) {
> +		dev_err(&pdev->dev, "failed to probe MII bus\n");
> +		goto out;
> +	}
> +
> +
> +	priv->phy_dev = of_phy_connect(ndev, priv->phy_node,
> +				       arc_emac_adjust_link, 0,
> +				       PHY_INTERFACE_MODE_MII);
> +	if (!priv->phy_dev) {
> +		netdev_err(ndev, "of_phy_connect() failed\n");
> +		return -ENODEV;

arc_mdio_remove leak.

-- 
Ueimor
