From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Mon, 13 Apr 2015 15:38:12 -0700
Message-ID: <552C4554.2070608@gmail.com>
References: <32501816.HtkLenWQpn@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:32801 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754016AbbDMWjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 18:39:14 -0400
In-Reply-To: <32501816.HtkLenWQpn@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/04/15 15:07, Sergei Shtylyov wrote:
[snip]

> +struct ravb_private {
> +	struct net_device *ndev;
> +	struct platform_device *pdev;
> +	void __iomem *addr;
> +	struct mdiobb_ctrl mdiobb;
> +	u32 num_rx_ring[NUM_RX_QUEUE];
> +	u32 num_tx_ring[NUM_TX_QUEUE];
> +	u32 desc_bat_size;
> +	dma_addr_t desc_bat_dma;
> +	struct ravb_desc *desc_bat;
> +	dma_addr_t rx_desc_dma[NUM_RX_QUEUE];
> +	dma_addr_t tx_desc_dma[NUM_TX_QUEUE];

As a future optimization, you could try to group the variables by
direction: RX and TX such that you have better cache locality.

[snip]

> +static void ravb_set_duplex(struct net_device *ndev)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +
> +	if (priv->duplex)	/* Full */
> +		ravb_write(ndev, ravb_read(ndev, ECMR) | ECMR_DM, ECMR);
> +	else			/* Half */
> +		ravb_write(ndev, ravb_read(ndev, ECMR) & ~ECMR_DM, ECMR);

	reg = ravb_read(ndev, ECMR);
	if (priv->duplex)
		reg |= ECMR_DM;
	else
		reg &= ~ECMR_DM;
	ravb_writel(ndev, reg, ECMR);

> +}
> +
> +static void ravb_set_rate(struct net_device *ndev)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +
> +	switch (priv->speed) {
> +	case 100:		/* 100BASE */
> +		ravb_write(ndev, GECMR_SPEED_100, GECMR);
> +		break;
> +	case 1000:		/* 1000BASE */
> +		ravb_write(ndev, GECMR_SPEED_1000, GECMR);
> +		break;
> +	default:
> +		break;
> +	}

That still won't quite work with 10Mbits/sec will it? Or is this
controller 100/1000 only (which would be extremely surprising).

[snip]

> +		if (desc_status & (MSC_CRC | MSC_RFE | MSC_RTSF | MSC_RTLF |
> +				   MSC_CEEF)) {
> +			stats->rx_errors++;
> +			if (desc_status & MSC_CRC)
> +				stats->rx_crc_errors++;
> +			if (desc_status & MSC_RFE)
> +				stats->rx_frame_errors++;
> +			if (desc_status & (MSC_RTLF | MSC_RTSF))
> +				stats->rx_length_errors++;
> +			if (desc_status & MSC_CEEF)
> +				stats->rx_missed_errors++;

The flow after the else condition, while refiling might deserve some
explanation.

> +		} else {
> +			u32 get_ts = priv->tstamp_rx_ctrl & RAVB_RXTSTAMP_TYPE;
> +
> +			skb = priv->rx_skb[q][entry];

Based on the refill logic below, it seems to me like you could leave
holes in your ring where rx_skb[q][entry] is NULL, should not that be
checked here?

> +			priv->rx_skb[q][entry] = NULL;
> +			dma_sync_single_for_cpu(&ndev->dev, desc->dptr,
> +						ALIGN(priv->rx_buffer_size, 16),
> +						DMA_FROM_DEVICE);
> +			get_ts &= (q == RAVB_NC) ?
> +					RAVB_RXTSTAMP_TYPE_V2_L2_EVENT :
> +					~RAVB_RXTSTAMP_TYPE_V2_L2_EVENT;
> +			if (get_ts) {
> +				struct skb_shared_hwtstamps *shhwtstamps;
> +
> +				shhwtstamps = skb_hwtstamps(skb);
> +				memset(shhwtstamps, 0, sizeof(*shhwtstamps));
> +				ts.tv_sec = ((u64)desc->ts_sh << 32) |
> +					    desc->ts_sl;
> +				ts.tv_nsec = (u64)desc->ts_n;
> +				shhwtstamps->hwtstamp = timespec64_to_ktime(ts);
> +			}
> +			skb_put(skb, pkt_len);
> +			skb->protocol = eth_type_trans(skb, ndev);
> +			if (q == RAVB_NC)
> +				netif_rx(skb);
> +			else
> +				netif_receive_skb(skb);

Can't you always invoke netif_receive_skb() here? Why is there a special
queue?

> +			stats->rx_packets++;
> +			stats->rx_bytes += pkt_len;
> +		}
> +
> +		entry = (++priv->cur_rx[q]) % priv->num_rx_ring[q];
> +		desc = &priv->rx_ring[q][entry];
> +	}
> +
> +	/* Refill the RX ring buffers. */
> +	for (; priv->cur_rx[q] - priv->dirty_rx[q] > 0; priv->dirty_rx[q]++) {
> +		entry = priv->dirty_rx[q] % priv->num_rx_ring[q];
> +		desc = &priv->rx_ring[q][entry];
> +		/* The size of the buffer should be on 16-byte boundary. */
> +		desc->ds = ALIGN(priv->rx_buffer_size, 16);
> +
> +		if (!priv->rx_skb[q][entry]) {
> +			skb = netdev_alloc_skb(ndev, skb_size);
> +			if (!skb)
> +				break;	/* Better luck next round. */

Should this really be a break or a continue?

[snip]

> +/* function for waiting dma process finished */
> +static void ravb_wait_stop_dma(struct net_device *ndev)
> +{

Should not you stop the MAC TX here as well for consistency?

> +	/* Wait for stopping the hardware TX process */
> +	ravb_wait(ndev, TCCR, TCCR_TSRQ0 | TCCR_TSRQ1 | TCCR_TSRQ2 | TCCR_TSRQ3,
> +		  0);
> +
> +	ravb_wait(ndev, CSR, CSR_TPO0 | CSR_TPO1 | CSR_TPO2 | CSR_TPO3, 0);
> +
> +	/* Stop the E-MAC's RX processes. */
> +	ravb_write(ndev, ravb_read(ndev, ECMR) & ~ECMR_RE, ECMR);

[snip]

> +		/* Transmited network control queue */
> +		if (tis & TIS_FTF1) {
> +			ravb_tx_free(ndev, RAVB_NC);
> +			netif_wake_queue(ndev);

This would be better moved to the NAPI handler.

> +			result = IRQ_HANDLED;
> +		}

[snip]

> +	if (ecmd->duplex == DUPLEX_FULL)
> +		priv->duplex = 1;
> +	else
> +		priv->duplex = 0;

Why not use what priv->phydev->duplex has cached for you?

> +
> +	ravb_set_duplex(ndev);
> +
> +error_exit:
> +	mdelay(1);
> +
> +	/* Enable TX and RX */
> +	ravb_rcv_snd_enable(ndev);
> +
> +	spin_unlock_irqrestore(&priv->lock, flags);
> +
> +	return error;
> +}
> +
> +static int ravb_nway_reset(struct net_device *ndev)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +	int error = -ENODEV;
> +	unsigned long flags;
> +
> +	if (priv->phydev) {

Is checking against priv->phydev really necessary, it does not look like
the driver will work or accept an invalid PHY device at all anyway?

> +		spin_lock_irqsave(&priv->lock, flags);
> +		error = phy_start_aneg(priv->phydev);
> +		spin_unlock_irqrestore(&priv->lock, flags);
> +	}
> +
> +	return error;
> +}
> +
> +static u32 ravb_get_msglevel(struct net_device *ndev)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +
> +	return priv->msg_enable;
> +}
> +
> +static void ravb_set_msglevel(struct net_device *ndev, u32 value)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +
> +	priv->msg_enable = value;
> +}
> +
> +static const char ravb_gstrings_stats[][ETH_GSTRING_LEN] = {
> +	"rx_queue_0_current",
> +	"tx_queue_0_current",
> +	"rx_queue_0_dirty",
> +	"tx_queue_0_dirty",
> +	"rx_queue_0_packets",
> +	"tx_queue_0_packets",
> +	"rx_queue_0_bytes",
> +	"tx_queue_0_bytes",
> +	"rx_queue_0_mcast_packets",
> +	"rx_queue_0_errors",
> +	"rx_queue_0_crc_errors",
> +	"rx_queue_0_frame_errors",
> +	"rx_queue_0_length_errors",
> +	"rx_queue_0_missed_errors",
> +	"rx_queue_0_over_errors",
> +
> +	"rx_queue_1_current",
> +	"tx_queue_1_current",
> +	"rx_queue_1_dirty",
> +	"tx_queue_1_dirty",
> +	"rx_queue_1_packets",
> +	"tx_queue_1_packets",
> +	"rx_queue_1_bytes",
> +	"tx_queue_1_bytes",
> +	"rx_queue_1_mcast_packets",
> +	"rx_queue_1_errors",
> +	"rx_queue_1_crc_errors",
> +	"rx_queue_1_frame_errors_",
> +	"rx_queue_1_length_errors",
> +	"rx_queue_1_missed_errors",
> +	"rx_queue_1_over_errors",
> +};
> +
> +#define RAVB_STATS_LEN	ARRAY_SIZE(ravb_gstrings_stats)
> +
> +static int ravb_get_sset_count(struct net_device *netdev, int sset)
> +{
> +	switch (sset) {
> +	case ETH_SS_STATS:
> +		return RAVB_STATS_LEN;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +}
> +
> +static void ravb_get_ethtool_stats(struct net_device *ndev,
> +				   struct ethtool_stats *stats, u64 *data)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +	int i = 0;
> +	int q;
> +
> +	/* Device-specific stats */
> +	for (q = RAVB_BE; q < NUM_RX_QUEUE; q++) {
> +		struct net_device_stats *stats = &priv->stats[q];
> +
> +		data[i++] = priv->cur_rx[q];
> +		data[i++] = priv->cur_tx[q];
> +		data[i++] = priv->dirty_rx[q];
> +		data[i++] = priv->dirty_tx[q];
> +		data[i++] = stats->rx_packets;
> +		data[i++] = stats->tx_packets;
> +		data[i++] = stats->rx_bytes;
> +		data[i++] = stats->tx_bytes;
> +		data[i++] = stats->multicast;
> +		data[i++] = stats->rx_errors;
> +		data[i++] = stats->rx_crc_errors;
> +		data[i++] = stats->rx_frame_errors;
> +		data[i++] = stats->rx_length_errors;
> +		data[i++] = stats->rx_missed_errors;
> +		data[i++] = stats->rx_over_errors;
> +	}
> +}
> +
> +static void ravb_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
> +{
> +	switch (stringset) {
> +	case ETH_SS_STATS:
> +		memcpy(data, *ravb_gstrings_stats, sizeof(ravb_gstrings_stats));
> +		break;
> +	}
> +}
> +
> +static void ravb_get_ringparam(struct net_device *ndev,
> +			       struct ethtool_ringparam *ring)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +
> +	ring->rx_max_pending = BE_RX_RING_MAX;
> +	ring->tx_max_pending = BE_TX_RING_MAX;
> +	ring->rx_pending = priv->num_rx_ring[RAVB_BE];
> +	ring->tx_pending = priv->num_tx_ring[RAVB_BE];
> +}
> +
> +static int ravb_set_ringparam(struct net_device *ndev,
> +			      struct ethtool_ringparam *ring)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +	int error;
> +
> +	if (ring->tx_pending > BE_TX_RING_MAX ||
> +	    ring->rx_pending > BE_RX_RING_MAX ||
> +	    ring->tx_pending < BE_TX_RING_MIN ||
> +	    ring->rx_pending < BE_RX_RING_MIN)
> +		return -EINVAL;
> +	if (ring->rx_mini_pending || ring->rx_jumbo_pending)
> +		return -EINVAL;
> +
> +	if (netif_running(ndev)) {
> +		netif_device_detach(ndev);
> +		netif_tx_disable(ndev);
> +		/* Wait for DMA stopping */
> +		ravb_wait_stop_dma(ndev);
> +
> +		/* Stop AVB-DMAC process */
> +		error = ravb_config(ndev);
> +		if (error < 0) {
> +			netdev_err(ndev,
> +				   "cannot set ringparam! Any AVB processes are still running?\n");
> +			return error;
> +		}
> +		synchronize_irq(ndev->irq);
> +
> +		/* Free all the skbuffs in the RX queue. */
> +		ravb_ring_free(ndev, RAVB_BE);
> +		ravb_ring_free(ndev, RAVB_NC);
> +		/* Free DMA buffer */
> +		ravb_free_dma_buffer(priv);
> +	}
> +
> +	/* Set new parameters */
> +	priv->num_rx_ring[RAVB_BE] = ring->rx_pending;
> +	priv->num_tx_ring[RAVB_BE] = ring->tx_pending;
> +	priv->num_rx_ring[RAVB_NC] = NC_RX_RING_SIZE;
> +	priv->num_tx_ring[RAVB_NC] = NC_TX_RING_SIZE;
> +
> +	if (netif_running(ndev)) {
> +		error = ravb_ring_init(ndev, RAVB_BE);
> +		if (error < 0) {
> +			netdev_err(ndev, "%s: ravb_ring_init(RAVB_BE) failed\n",
> +				   __func__);
> +			return error;
> +		}
> +
> +		error = ravb_ring_init(ndev, RAVB_NC);
> +		if (error < 0) {
> +			netdev_err(ndev, "%s: ravb_ring_init(RAVB_NC) failed\n",
> +				   __func__);
> +			return error;
> +		}
> +
> +		error = ravb_dmac_init(ndev);
> +		if (error < 0) {
> +			netdev_err(ndev, "%s: ravb_dmac_init() failed\n",
> +				   __func__);
> +			return error;
> +		}
> +
> +		ravb_emac_init(ndev);
> +
> +		netif_device_attach(ndev);
> +	}
> +
> +	return 0;
> +}
> +
> +static int ravb_get_ts_info(struct net_device *ndev,
> +			    struct ethtool_ts_info *info)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +
> +	info->so_timestamping =
> +		SOF_TIMESTAMPING_TX_SOFTWARE |
> +		SOF_TIMESTAMPING_RX_SOFTWARE |
> +		SOF_TIMESTAMPING_SOFTWARE |
> +		SOF_TIMESTAMPING_TX_HARDWARE |
> +		SOF_TIMESTAMPING_RX_HARDWARE |
> +		SOF_TIMESTAMPING_RAW_HARDWARE;
> +	info->tx_types = (1 << HWTSTAMP_TX_OFF) | (1 << HWTSTAMP_TX_ON);
> +	info->rx_filters =
> +		(1 << HWTSTAMP_FILTER_NONE) |
> +		(1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
> +		(1 << HWTSTAMP_FILTER_ALL);
> +	info->phc_index = ptp_clock_index(priv->ptp.clock);
> +
> +	return 0;
> +}
> +
> +static const struct ethtool_ops ravb_ethtool_ops = {
> +	.get_settings		= ravb_get_settings,
> +	.set_settings		= ravb_set_settings,
> +	.nway_reset		= ravb_nway_reset,
> +	.get_msglevel		= ravb_get_msglevel,
> +	.set_msglevel		= ravb_set_msglevel,
> +	.get_link		= ethtool_op_get_link,
> +	.get_strings		= ravb_get_strings,
> +	.get_ethtool_stats	= ravb_get_ethtool_stats,
> +	.get_sset_count		= ravb_get_sset_count,
> +	.get_ringparam		= ravb_get_ringparam,
> +	.set_ringparam		= ravb_set_ringparam,
> +	.get_ts_info		= ravb_get_ts_info,
> +};
> +
> +/* Network device open function for Ethernet AVB */
> +static int ravb_open(struct net_device *ndev)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +	int error;
> +
> +	napi_enable(&priv->napi);
> +
> +	error = request_irq(ndev->irq, ravb_interrupt, IRQF_SHARED, ndev->name,
> +			    ndev);
> +	if (error) {
> +		netdev_err(ndev, "cannot request IRQ\n");
> +		goto out_napi_off;
> +	}
> +
> +	/* Descriptor set */
> +	/* +26 gets the maximum ethernet encapsulation, +7 & ~7 because the
> +	 * card needs room to do 8 byte alignment, +2 so we can reserve
> +	 * the first 2 bytes, and +16 gets room for the status word from the
> +	 * card.
> +	 */
> +	priv->rx_buffer_size = (ndev->mtu <= 1492 ? PKT_BUF_SZ :
> +				(((ndev->mtu + 26 + 7) & ~7) + 2 + 16));

Is not that something that should be moved to a local ndo_change_mtu()
function? What happens if I change the MTU of an interface running, does
not that completely break this RX buffer estimation?

> +
> +	error = ravb_ring_init(ndev, RAVB_BE);
> +	if (error)
> +		goto out_free_irq;
> +	error = ravb_ring_init(ndev, RAVB_NC);
> +	if (error)
> +		goto out_free_irq;
> +
> +	/* Device init */
> +	error = ravb_dmac_init(ndev);
> +	if (error)
> +		goto out_free_irq;
> +	ravb_emac_init(ndev);
> +
> +	netif_start_queue(ndev);
> +
> +	/* PHY control start */
> +	error = ravb_phy_start(ndev);
> +	if (error)
> +		goto out_free_irq;
> +
> +	return 0;
> +
> +out_free_irq:
> +	free_irq(ndev->irq, ndev);
> +out_napi_off:
> +	napi_disable(&priv->napi);
> +	return error;
> +}
> +
> +/* Timeout function for Ethernet AVB */
> +static void ravb_tx_timeout(struct net_device *ndev)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +	int i, q;
> +
> +	netif_stop_queue(ndev);
> +
> +	netif_err(priv, tx_err, ndev,
> +		  "transmit timed out, status %8.8x, resetting...\n",
> +		  ravb_read(ndev, ISS));
> +
> +	/* tx_errors count up */
> +	ndev->stats.tx_errors++;
> +
> +	/* Free all the skbuffs */
> +	for (q = RAVB_BE; q < NUM_RX_QUEUE; q++) {
> +		for (i = 0; i < priv->num_rx_ring[q]; i++) {
> +			dev_kfree_skb(priv->rx_skb[q][i]);
> +			priv->rx_skb[q][i] = NULL;
> +		}
> +	}
> +	for (q = RAVB_BE; q < NUM_TX_QUEUE; q++) {
> +		for (i = 0; i < priv->num_tx_ring[q]; i++) {
> +			dev_kfree_skb(priv->tx_skb[q][i]);
> +			priv->tx_skb[q][i] = NULL;
> +			kfree(priv->tx_buffers[q][i]);
> +			priv->tx_buffers[q][i] = NULL;
> +		}
> +	}
> +
> +	/* Device init */
> +	ravb_dmac_init(ndev);
> +	ravb_emac_init(ndev);
> +	netif_start_queue(ndev);
> +}
> +
> +/* Packet transmit function for Ethernet AVB */
> +static int ravb_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +	struct ravb_tstamp_skb *ts_skb = NULL;
> +	struct ravb_tx_desc *desc;
> +	unsigned long flags;
> +	void *buffer;
> +	u32 entry;
> +	u32 tccr;
> +	int q;
> +
> +	/* If skb needs TX timestamp, it is handled in network control queue */
> +	q = (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) ? RAVB_NC : RAVB_BE;
> +
> +	spin_lock_irqsave(&priv->lock, flags);
> +	if (priv->cur_tx[q] - priv->dirty_tx[q] >= priv->num_tx_ring[q] - 4) {

What's so special about 4 here, you don't seem to be using 4 descriptors

> +		if (!ravb_tx_free(ndev, q)) {
> +			netif_warn(priv, tx_queued, ndev, "TX FD exhausted.\n");
> +			netif_stop_queue(ndev);
> +			spin_unlock_irqrestore(&priv->lock, flags);
> +			return NETDEV_TX_BUSY;
> +		}
> +	}
> +	entry = priv->cur_tx[q] % priv->num_tx_ring[q];
> +	priv->cur_tx[q]++;
> +	spin_unlock_irqrestore(&priv->lock, flags);
> +
> +	if (skb_put_padto(skb, ETH_ZLEN))
> +		return NETDEV_TX_OK;
> +
> +	priv->tx_skb[q][entry] = skb;
> +	buffer = PTR_ALIGN(priv->tx_buffers[q][entry], RAVB_ALIGN);
> +	memcpy(buffer, skb->data, skb->len);

~1500 bytes memcpy(), not good...

> +	desc = &priv->tx_ring[q][entry];

Since we have released the spinlock few lines above, is there something
protecting ravb_tx_free() from concurrently running with this xmit()
call and trashing this entry?

> +	desc->ds = skb->len;
> +	desc->dptr = dma_map_single(&ndev->dev, buffer, skb->len,
> +				    DMA_TO_DEVICE);
> +	if (dma_mapping_error(&ndev->dev, desc->dptr)) {
> +		dev_kfree_skb_any(skb);
> +		priv->tx_skb[q][entry] = NULL;

Don't you need to make sure this NULL is properly seen by ravb_tx_free()?

> +		return NETDEV_TX_OK;
> +	}
> +
> +	/* TX timestamp required */
> +	if (q == RAVB_NC) {
> +		ts_skb = kmalloc(sizeof(*ts_skb), GFP_ATOMIC);
> +		if (!ts_skb)
> +			return -ENOMEM;
> +		ts_skb->skb = skb;
> +		ts_skb->tag = priv->ts_skb_tag++;
> +		priv->ts_skb_tag %= 0x400;
> +		list_add_tail(&ts_skb->list, &priv->ts_skb_list);
> +
> +		/* TAG and timestamp required flag */
> +		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
> +		skb_tx_timestamp(skb);
> +		desc->tsr = 1;
> +		desc->tag = ts_skb->tag;
> +	}
> +
> +	/* Descriptor type must be set after all the above writes */
> +	dma_wmb();
> +	desc->dt = DT_FSINGLE;
> +
> +	spin_lock_irqsave(&priv->lock, flags);
> +	tccr = ravb_read(ndev, TCCR);
> +	if (!(tccr & (TCCR_TSRQ0 << q)))
> +		ravb_write(ndev, tccr | (TCCR_TSRQ0 << q), TCCR);
> +	spin_unlock_irqrestore(&priv->lock, flags);
> +
> +	return NETDEV_TX_OK;

-- 
Florian
