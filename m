From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Wed, 15 Apr 2015 00:37:28 +0300
Message-ID: <552D8898.3060905@cogentembedded.com>
References: <32501816.HtkLenWQpn@wasted.cogentembedded.com> <552C4554.2070608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
To: Florian Fainelli <f.fainelli@gmail.com>, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <552C4554.2070608@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/14/2015 01:38 AM, Florian Fainelli wrote:

> [snip]

>> +struct ravb_private {
>> +	struct net_device *ndev;
>> +	struct platform_device *pdev;
>> +	void __iomem *addr;
>> +	struct mdiobb_ctrl mdiobb;
>> +	u32 num_rx_ring[NUM_RX_QUEUE];
>> +	u32 num_tx_ring[NUM_TX_QUEUE];
>> +	u32 desc_bat_size;
>> +	dma_addr_t desc_bat_dma;
>> +	struct ravb_desc *desc_bat;
>> +	dma_addr_t rx_desc_dma[NUM_RX_QUEUE];
>> +	dma_addr_t tx_desc_dma[NUM_TX_QUEUE];

> As a future optimization, you could try to group the variables by
> direction: RX and TX such that you have better cache locality.

    Thanks for the idea.

> [snip]

>> +static void ravb_set_duplex(struct net_device *ndev)
>> +{
>> +	struct ravb_private *priv = netdev_priv(ndev);
>> +
>> +	if (priv->duplex)	/* Full */
>> +		ravb_write(ndev, ravb_read(ndev, ECMR) | ECMR_DM, ECMR);
>> +	else			/* Half */
>> +		ravb_write(ndev, ravb_read(ndev, ECMR) & ~ECMR_DM, ECMR);

> 	reg = ravb_read(ndev, ECMR);
> 	if (priv->duplex)
> 		reg |= ECMR_DM;
> 	else
> 		reg &= ~ECMR_DM;
> 	ravb_writel(ndev, reg, ECMR);

    OK, missed this.

>> +}
>> +
>> +static void ravb_set_rate(struct net_device *ndev)
>> +{
>> +	struct ravb_private *priv = netdev_priv(ndev);
>> +
>> +	switch (priv->speed) {
>> +	case 100:		/* 100BASE */
>> +		ravb_write(ndev, GECMR_SPEED_100, GECMR);
>> +		break;
>> +	case 1000:		/* 1000BASE */
>> +		ravb_write(ndev, GECMR_SPEED_1000, GECMR);
>> +		break;
>> +	default:
>> +		break;
>> +	}

> That still won't quite work with 10Mbits/sec will it? Or is this
> controller 100/1000 only (which would be extremely surprising).

    Yes, only 100/1000, at least so says the manual.

> [snip]

>> +		if (desc_status & (MSC_CRC | MSC_RFE | MSC_RTSF | MSC_RTLF |
>> +				   MSC_CEEF)) {
>> +			stats->rx_errors++;
>> +			if (desc_status & MSC_CRC)
>> +				stats->rx_crc_errors++;
>> +			if (desc_status & MSC_RFE)
>> +				stats->rx_frame_errors++;
>> +			if (desc_status & (MSC_RTLF | MSC_RTSF))
>> +				stats->rx_length_errors++;
>> +			if (desc_status & MSC_CEEF)
>> +				stats->rx_missed_errors++;

> The flow after the else condition, while refiling might deserve some
> explanation.

>> +		} else {
>> +			u32 get_ts = priv->tstamp_rx_ctrl & RAVB_RXTSTAMP_TYPE;
>> +
>> +			skb = priv->rx_skb[q][entry];

> Based on the refill logic below, it seems to me like you could leave
> holes in your ring where rx_skb[q][entry] is NULL, should not that be
> checked here?

    We don't set the descriptor type to FEMPTY for such cases, so the AVB-DMAC 
shouldn't handle such descriptors.

[...]
>> +			skb_put(skb, pkt_len);
>> +			skb->protocol = eth_type_trans(skb, ndev);
>> +			if (q == RAVB_NC)
>> +				netif_rx(skb);
>> +			else
>> +				netif_receive_skb(skb);

> Can't you always invoke netif_receive_skb() here? Why is there a special
> queue?

    The comments in ravb_interrupt() say that the network control queue should 
be handled ASAP, due to timestamping.

>> +			stats->rx_packets++;
>> +			stats->rx_bytes += pkt_len;
>> +		}
>> +
>> +		entry = (++priv->cur_rx[q]) % priv->num_rx_ring[q];
>> +		desc = &priv->rx_ring[q][entry];
>> +	}
>> +
>> +	/* Refill the RX ring buffers. */
>> +	for (; priv->cur_rx[q] - priv->dirty_rx[q] > 0; priv->dirty_rx[q]++) {
>> +		entry = priv->dirty_rx[q] % priv->num_rx_ring[q];
>> +		desc = &priv->rx_ring[q][entry];
>> +		/* The size of the buffer should be on 16-byte boundary. */
>> +		desc->ds = ALIGN(priv->rx_buffer_size, 16);
>> +
>> +		if (!priv->rx_skb[q][entry]) {
>> +			skb = netdev_alloc_skb(ndev, skb_size);
>> +			if (!skb)
>> +				break;	/* Better luck next round. */

> Should this really be a break or a continue?

    We don't expect the allocation to succeed after it failed, so the *break* 
is appropriate, I think.

> [snip]

>> +/* function for waiting dma process finished */
>> +static void ravb_wait_stop_dma(struct net_device *ndev)
>> +{

> Should not you stop the MAC TX here as well for consistency?

    Perhaps, though the manual doesn't say so...

>> +	/* Wait for stopping the hardware TX process */
>> +	ravb_wait(ndev, TCCR, TCCR_TSRQ0 | TCCR_TSRQ1 | TCCR_TSRQ2 | TCCR_TSRQ3,
>> +		  0);
>> +
>> +	ravb_wait(ndev, CSR, CSR_TPO0 | CSR_TPO1 | CSR_TPO2 | CSR_TPO3, 0);
>> +
>> +	/* Stop the E-MAC's RX processes. */
>> +	ravb_write(ndev, ravb_read(ndev, ECMR) & ~ECMR_RE, ECMR);

> [snip]

>> +		/* Transmited network control queue */
>> +		if (tis & TIS_FTF1) {
>> +			ravb_tx_free(ndev, RAVB_NC);
>> +			netif_wake_queue(ndev);

> This would be better moved to the NAPI handler.

    Maybe, not sure...

>> +			result = IRQ_HANDLED;
>> +		}

> [snip]

>> +	if (ecmd->duplex == DUPLEX_FULL)
>> +		priv->duplex = 1;
>> +	else
>> +		priv->duplex = 0;

> Why not use what priv->phydev->duplex has cached for you?

    Because we compare 'priv->duplex' with 'priv->phydev->duplex' in 
ravb_adjust_link(). Or what did you mean?

[...]

>> +static int ravb_nway_reset(struct net_device *ndev)
>> +{
>> +	struct ravb_private *priv = netdev_priv(ndev);
>> +	int error = -ENODEV;
>> +	unsigned long flags;
>> +
>> +	if (priv->phydev) {

> Is checking against priv->phydev really necessary, it does not look like
> the driver will work or accept an invalid PHY device at all anyway?

    You still can run 'ethtool' on a closed network device.

[...]

>> +/* Network device open function for Ethernet AVB */
>> +static int ravb_open(struct net_device *ndev)
>> +{
>> +	struct ravb_private *priv = netdev_priv(ndev);
>> +	int error;
>> +
>> +	napi_enable(&priv->napi);
>> +
>> +	error = request_irq(ndev->irq, ravb_interrupt, IRQF_SHARED, ndev->name,
>> +			    ndev);
>> +	if (error) {
>> +		netdev_err(ndev, "cannot request IRQ\n");
>> +		goto out_napi_off;
>> +	}
>> +
>> +	/* Descriptor set */
>> +	/* +26 gets the maximum ethernet encapsulation, +7 & ~7 because the
>> +	 * card needs room to do 8 byte alignment, +2 so we can reserve
>> +	 * the first 2 bytes, and +16 gets room for the status word from the
>> +	 * card.
>> +	 */
>> +	priv->rx_buffer_size = (ndev->mtu <= 1492 ? PKT_BUF_SZ :
>> +				(((ndev->mtu + 26 + 7) & ~7) + 2 + 16));

> Is not that something that should be moved to a local ndo_change_mtu()

    That was copied from sh_eth.c verbatim, I even doubt that the formula is 
correct for EtherAVB...

> function? What happens if I change the MTU of an interface running, does
> not that completely break this RX buffer estimation?

    Well, not completely, I think. eth_change_mtu() doesn't allow MTU > 1500 
bytes, so it looks like we just need to change 1492 to 1500 here.

[...]

>> +static int ravb_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>> +{
>> +	struct ravb_private *priv = netdev_priv(ndev);
>> +	struct ravb_tstamp_skb *ts_skb = NULL;
>> +	struct ravb_tx_desc *desc;
>> +	unsigned long flags;
>> +	void *buffer;
>> +	u32 entry;
>> +	u32 tccr;
>> +	int q;
>> +
>> +	/* If skb needs TX timestamp, it is handled in network control queue */
>> +	q = (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) ? RAVB_NC : RAVB_BE;
>> +
>> +	spin_lock_irqsave(&priv->lock, flags);
>> +	if (priv->cur_tx[q] - priv->dirty_tx[q] >= priv->num_tx_ring[q] - 4) {

> What's so special about 4 here, you don't seem to be using 4 descriptors

    Not sure, this was clearly copied from sh_eth.c. Perhaps it's just a 
threshold for calling ravb_tx_free()...

>> +		if (!ravb_tx_free(ndev, q)) {
>> +			netif_warn(priv, tx_queued, ndev, "TX FD exhausted.\n");
>> +			netif_stop_queue(ndev);
>> +			spin_unlock_irqrestore(&priv->lock, flags);
>> +			return NETDEV_TX_BUSY;
>> +		}
>> +	}
>> +	entry = priv->cur_tx[q] % priv->num_tx_ring[q];
>> +	priv->cur_tx[q]++;
>> +	spin_unlock_irqrestore(&priv->lock, flags);
>> +
>> +	if (skb_put_padto(skb, ETH_ZLEN))
>> +		return NETDEV_TX_OK;
>> +
>> +	priv->tx_skb[q][entry] = skb;
>> +	buffer = PTR_ALIGN(priv->tx_buffers[q][entry], RAVB_ALIGN);
>> +	memcpy(buffer, skb->data, skb->len);

> ~1500 bytes memcpy(), not good...

    I'm looking in the manual and not finding the hard requirement to have the 
buffer address aligned to 128 bytes (RAVB_ALIGN), sigh... Kimura-san?

>> +	desc = &priv->tx_ring[q][entry];

> Since we have released the spinlock few lines above, is there something
> protecting ravb_tx_free() from concurrently running with this xmit()
> call and trashing this entry?

    Probably nothing... :-)

>> +	desc->ds = skb->len;
>> +	desc->dptr = dma_map_single(&ndev->dev, buffer, skb->len,
>> +				    DMA_TO_DEVICE);
>> +	if (dma_mapping_error(&ndev->dev, desc->dptr)) {
>> +		dev_kfree_skb_any(skb);
>> +		priv->tx_skb[q][entry] = NULL;

> Don't you need to make sure this NULL is properly seen by ravb_tx_free()?

    You mean doing this before releasing the spinlock? Or what?

[...]

WBR, Sergei

