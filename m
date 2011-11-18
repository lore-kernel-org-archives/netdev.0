From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: add calxeda xgmac ethernet driver
Date: Fri, 18 Nov 2011 22:36:30 +0000
Message-ID: <1321655790.2883.97.camel@bwh-desktop>
References: <1321411611-28839-1-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <devicetree-discuss@lists.ozlabs.org>,
	<joe@perches.com>, <saeed.bishara@gmail.com>,
	Rob Herring <rob.herring@calxeda.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:5417 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755754Ab1KRWgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 17:36:35 -0500
In-Reply-To: <1321411611-28839-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-15 at 20:46 -0600, Rob Herring wrote:
[...]
> +static int desc_get_rx_status(struct xgmac_priv *priv, struct xgmac_dma_desc *p)
> +{
[...]
> +	if (status & RXDESC_EXT_STATUS) {
> +		if (ext_status & RXDESC_IP_HEADER_ERR)
> +			x->rx_ip_header_error++;
> +		if (ext_status & RXDESC_IP_PAYLOAD_ERR)
> +			x->rx_payload_error++;
> +		netdev_dbg(priv->dev, "IP checksum error - stat %08x\n",
> +			   ext_status);
> +		return -1;

You must not drop packets with a checksum failure above the link level;
i.e. you should drop for bad Ethernet CRC but not bad IP checksum.  The
return value here should be CHECKSUM_NONE.

[...]
> +static int xgmac_dma_desc_rings_init(struct net_device *dev)
> +{
[...]
> +	/* The base address of the RX/TX descriptor lists must be written into
> +	 * DMA CSR3 and CSR4, respectively. */
> +	writel(priv->dma_tx_phy, priv->base + XGMAC_DMA_TX_BASE_ADDR);
> +	writel(priv->dma_rx_phy, priv->base + XGMAC_DMA_RX_BASE_ADDR);

The code doesn't use the names 'CSR3' or 'CSR4' (thankfully) so this
comment is redundant.

[...]
> +static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct xgmac_priv *priv = netdev_priv(dev);
> +	unsigned int entry;
> +	int i;
> +	int nfrags = skb_shinfo(skb)->nr_frags;
> +	struct xgmac_dma_desc *desc, *first;
> +	unsigned int desc_flags;
> +	unsigned int len;
> +	dma_addr_t paddr;
> +
> +	if (dma_ring_space(priv->tx_head, priv->tx_tail, DMA_TX_RING_SZ) <
> +	    (nfrags + 1)) {
> +		writel(DMA_INTR_DEFAULT_MASK | DMA_INTR_ENA_TIE,
> +			priv->base + XGMAC_DMA_INTR_ENA);
> +		netif_stop_queue(dev);
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	desc_flags = (skb->ip_summed == CHECKSUM_PARTIAL) ?
> +		TXDESC_CSUM_ALL : 0;
> +	entry = priv->tx_head;
> +	desc = priv->dma_tx + entry;
> +	first = desc;
> +
> +	priv->tx_skbuff[entry] = skb;
> +	len = skb_headlen(skb);
> +	paddr = dma_map_single(priv->device, skb->data, len, DMA_TO_DEVICE);

Don't you need to check for failure?

> +	desc_set_buf_addr_and_size(desc, paddr, len);
> +
> +	for (i = 0; i < nfrags; i++) {
> +		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
> +
> +		len = frag->size;
> +		entry = dma_ring_incr(entry, DMA_TX_RING_SZ);
> +		desc = priv->dma_tx + entry;
> +
> +		paddr = dma_map_page(priv->device, frag->page.p,
> +				frag->page_offset, len, DMA_TO_DEVICE);

Use skb_frag_dma_map() and check for failure.

> +		priv->tx_skbuff[entry] = NULL;
> +
> +		desc_set_buf_addr_and_size(desc, paddr, len);
> +		if (i < (nfrags - 1))
> +			desc_set_tx_owner(desc, desc_flags);
> +	}
[...]
> +static void xgmac_set_rx_mode(struct net_device *dev)
> +{
> +	int i;
> +	struct xgmac_priv *priv = netdev_priv(dev);
> +	void __iomem *ioaddr = priv->base;
> +	unsigned int value = 0;
> +	u32 mc_filter[XGMAC_NUM_HASH];

Maybe call this hash_filter since you may use it for matching large
numbers of unicast addresses as well?

[...]
> +static int xgmac_change_mtu(struct net_device *dev, int new_mtu)
> +{
> +	struct xgmac_priv *priv = netdev_priv(dev);
> +	int old_mtu;
> +
> +	if ((new_mtu < 46) || (new_mtu > MAX_MTU)) {
> +		netdev_err(priv->dev, "invalid MTU, max MTU is: %d\n", MAX_MTU);
> +		return -EINVAL;
> +	}
> +
> +	old_mtu = dev->mtu;
> +	dev->mtu = new_mtu;
> +
> +	/* return early if the buffer sizes will not change */
> +	if (old_mtu <= ETH_DATA_LEN && new_mtu <= ETH_DATA_LEN)
> +		return 0;
> +	if (old_mtu == new_mtu)
> +		return 0;
> +
> +	/* Stop everything, get ready to change the MTU */
> +	if (!netif_running(dev))
> +		return 0;
> +
> +	/* Bring the interface down and then back up */
> +	xgmac_release(dev);
> +	xgmac_open(dev);
> +
> +	return 0;
> +}

This function should end with return xgmac_open(dev) so that a failure
of that function is properly reported.

You also need to make sure that it's safe to call xgmac_release() a
second time if this call to xgmac_open() fails; I think at the moment
that will result in a crash.

[...]
> +struct rtnl_link_stats64 *
> +xgmac_get_stats64(struct net_device *dev,
> +		       struct rtnl_link_stats64 *storage)
> +{
> +	struct xgmac_priv *priv = netdev_priv(dev);
> +	void __iomem *base = priv->base;
> +	u64 count;

Calls to ndo_get_stats64 are *not* serialised and may be done in atomic
context.  You need to serialise calls yourself using a spinlock.

> +	storage->rx_packets = readl(base + XGMAC_MMC_RXFRAME_GB_LO);
> +	storage->rx_packets |=
> +		(u64)(readl(base + XGMAC_MMC_RXFRAME_GB_HI)) << 32;
> +	storage->rx_bytes = readl(base + XGMAC_MMC_RXOCTET_G_LO);
> +	storage->rx_bytes |= (u64)(readl(base + XGMAC_MMC_RXOCTET_G_HI)) << 32;

Does reading the 'LO' register latch the 'HI' value until you read that
as well?  If not, you need to detect a rollover here.

> +	storage->multicast = readl(base + XGMAC_MMC_RXMCFRAME_G);
> +	storage->rx_crc_errors = readl(base + XGMAC_MMC_RXCRCERR);
> +	storage->rx_length_errors = readl(base + XGMAC_MMC_RXLENGTHERR);
> +	storage->rx_missed_errors = readl(base + XGMAC_MMC_RXOVERFLOW);
> +
> +	storage->tx_packets = readl(base + XGMAC_MMC_TXFRAME_GB_LO);
> +	storage->tx_packets |=
> +		(u64)(readl(base + XGMAC_MMC_TXFRAME_GB_HI)) << 32;
> +	storage->tx_bytes = readl(base + XGMAC_MMC_TXOCTET_G_LO);
> +	storage->tx_bytes |= (u64)(readl(base + XGMAC_MMC_TXOCTET_G_HI)) << 32;
> +
> +	count = readl(base + XGMAC_MMC_TXFRAME_G_LO);
> +	count |= (__u64)(readl(base + XGMAC_MMC_TXFRAME_G_HI)) << 32;
> +	storage->tx_errors = storage->tx_packets - count;

This subtraction is problematic: unless the TX frame counters are *all*
latched until you finish reading them, tx_errors can jump backwards.

> +	storage->tx_fifo_errors = readl(base + XGMAC_MMC_TXUNDERFLOW);
> +
> +	return storage;
> +}
[...]
> +static int xgmac_ethtool_getsettings(struct net_device *dev,
> +					  struct ethtool_cmd *cmd)
> +{
> +	cmd->autoneg = 0;
> +	cmd->duplex = DUPLEX_FULL;
> +	ethtool_cmd_speed_set(cmd, 10000);
> +	cmd->supported = SUPPORTED_10000baseT_Full;
> +	cmd->advertising = 0;
> +	cmd->transceiver = XCVR_INTERNAL;
> +	return 0;
> +}

Please don't use SUPPORTED_10000baseT_Full.  I know there are a lot of
drivers currently using that to mean any 10G full-duplex mode, but it's
not really correct.  The supported mask really isn't that important in
the absence of autonegotiation, anyway.

[...]
> +static int xgmac_set_pauseparam(struct net_device *netdev,
> +				     struct ethtool_pauseparam *pause)
> +{
> +	struct xgmac_priv *priv = netdev_priv(netdev);
> +	return xgmac_set_flow_ctrl(priv, pause->rx_pause, pause->tx_pause);
> +}

This should reject requests to enable pause frame autonegotiation:

	if (pause->autoneg)
		return -EINVAL;

[...]
> +static const struct xgmac_stats xgmac_gstrings_stats[] = {
[...]
> +       XGMAC_STAT(tx_undeflow_irq),

'underflow' is missing an 'r'.

Also, I don't think it's helpful to include '_irq' in the names reported
through the ethtool API.

[...]
> +static int xgmac_get_sset_count(struct net_device *netdev, int sset)
> +{
> +	switch (sset) {
> +	case ETH_SS_STATS:
> +		return XGMAC_STATS_LEN;
> +	default:
> +		return -EOPNOTSUPP;

You support the get_sset_count operation, just not this argument value,
so I think EINVAL is the correct error code.

[...]
> +static int xgmac_set_wol(struct net_device *dev,
> +			      struct ethtool_wolinfo *wol)
> +{
> +	struct xgmac_priv *priv = netdev_priv(dev);
> +	u32 support = WAKE_MAGIC | WAKE_UCAST;
> +
> +	if (!device_can_wakeup(priv->device))
> +		return -EINVAL;

The error code should be EOPNOTSUPP, unless this capability can change
dynamically.

[...]
> +/**
> + * xgmac_probe
> + * @pdev: platform device pointer
> + * Description: the driver is initialized through platform_device.
> + */
> +static int xgmac_probe(struct platform_device *pdev)
> +{
[...]
> +	netif_napi_add(ndev, &priv->napi, xgmac_poll, 64);
> +	ret = register_netdev(ndev);
> +	if (ret)
> +		goto err_reg;
> +
> +	return 0;
> +
> +err_reg:
> +	free_irq(priv->pmt_irq, ndev);
[...]

You need to call netif_napi_del() on this error path, and in
xgmac_remove().

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
