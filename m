From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Tue, 14 Apr 2015 02:49:01 +0200
Message-ID: <552C63FD.9010005@gmx.de>
References: <32501816.HtkLenWQpn@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <32501816.HtkLenWQpn@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 14.04.2015 00:07, Sergei Shtylyov wrote:

> +struct ravb_desc {
> +#ifdef __LITTLE_ENDIAN
> +	u32 ds: 12;	/* Descriptor size */
> +	u32 cc: 12;	/* Content control */
> +	u32 die: 4;	/* Descriptor interrupt enable */
> +			/* 0: disable, other: enable */
> +	u32 dt: 4;	/* Descriptor type */
> +#else
> +	u32 dt: 4;	/* Descriptor type */
> +	u32 die: 4;	/* Descriptor interrupt enable */
> +			/* 0: disable, other: enable */
> +	u32 cc: 12;	/* Content control */
> +	u32 ds: 12;	/* Descriptor size */
> +#endif
> +	u32 dptr;	/* Descriptor pointer */
> +};
> +
> +struct ravb_rx_desc {
> +#ifdef __LITTLE_ENDIAN
> +	u32 ds: 12;	/* Descriptor size */
> +	u32 ei: 1;	/* Error indication */
> +	u32 ps: 2;	/* Padding selection */
> +	u32 tr: 1;	/* Truncation indication */
> +	u32 msc: 8;	/* MAC status code */
> +	u32 die: 4;	/* Descriptor interrupt enable */
> +			/* 0: disable, other: enable */
> +	u32 dt: 4;	/* Descriptor type */
> +#else
> +	u32 dt: 4;	/* Descriptor type */
> +	u32 die: 4;	/* Descriptor interrupt enable */
> +			/* 0: disable, other: enable */
> +	u32 msc: 8;	/* MAC status code */
> +	u32 ps: 2;	/* Padding selection */
> +	u32 ei: 1;	/* Error indication */
> +	u32 tr: 1;	/* Truncation indication */
> +	u32 ds: 12;	/* Descriptor size */
> +#endif
> +	u32 dptr;	/* Descpriptor pointer */
> +};
> +
> +struct ravb_ex_rx_desc {
> +#ifdef __LITTLE_ENDIAN
> +	u32 ds: 12;	/* Descriptor size */
> +	u32 ei: 1;	/* Error indication */
> +	u32 ps: 2;	/* Padding selection */
> +	u32 tr: 1;	/* Truncation indication */
> +	u32 msc: 8;	/* MAC status code */
> +	u32 die: 4;	/* Descriptor interrupt enable */
> +			/* 0: disable, other: enable */
> +	u32 dt: 4;	/* Descriptor type */
> +#else
> +	u32 dt: 4;	/* Descriptor type */
> +	u32 die: 4;	/* Descriptor interrupt enable */
> +			/* 0: disable, other: enable */
> +	u32 msc: 8;	/* MAC status code */
> +	u32 ps: 2;	/* Padding selection */
> +	u32 ei: 1;	/* Error indication */
> +	u32 tr: 1;	/* Truncation indication */
> +	u32 ds: 12;	/* Descriptor size */
> +#endif
> +	u32 dptr;	/* Descpriptor pointer */
> +	u32 ts_n;	/* Timestampe nsec */
> +	u32 ts_sl;	/* Timestamp low */
> +#ifdef __LITTLE_ENDIAN
> +	u32 res: 16;	/* Reserved bits */
> +	u32 ts_sh: 16;	/* Timestamp high */
> +#else
> +	u32 ts_sh: 16;	/* Timestamp high */
> +	u32 res: 16;	/* Reserved bits */
> +#endif
> +};

I recall a thread in which the use of bitfields for structs that are
shared with the hardware was considered a bad idea (because the compiler
is free to reorder the fields). Shift operations are probably a better
choice here.

> +
> +struct ravb_tx_desc {
> +#ifdef __LITTLE_ENDIAN
> +	u32 ds: 12;	/* Descriptor size */
> +	u32 tag: 10;	/* Frame tag */
> +	u32 tsr: 1;	/* Timestamp storage request */
> +	u32 msc: 1;	/* MAC status storage request */
> +	u32 die: 4;	/* Descriptor interrupt enable */
> +			/* 0: disable, other: enable */
> +	u32 dt: 4;	/* Descriptor type */
> +#else
> +	u32 dt: 4;	/* Descriptor type */
> +	u32 die: 4;	/* Descriptor interrupt enable */
> +			/* 0: disable, other: enable */
> +	u32 msc: 1;	/* MAC status storage request */
> +	u32 tsr: 1;	/* Timestamp storage request */
> +	u32 tag: 10;	/* Frame tag */
> +	u32 ds: 12;	/* Descriptor size */
> +#endif
> +	u32 dptr;	/* Descpriptor pointer */
> +};
> +

Same as above.

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

freeing all the memory allocated in the former avb_ring_init calls is
missing.

> +out_napi_off:
> +	napi_disable(&priv->napi);
> +	return error;
> +}
> 



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

Does this really work? At least the hardware should be shut down before
the queues are freed, shouldn't it?


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
> +	desc = &priv->tx_ring[q][entry];
> +	desc->ds = skb->len;
> +	desc->dptr = dma_map_single(&ndev->dev, buffer, skb->len,
> +				    DMA_TO_DEVICE);
> +	if (dma_mapping_error(&ndev->dev, desc->dptr)) {
> +		dev_kfree_skb_any(skb);
> +		priv->tx_skb[q][entry] = NULL;
> +		return NETDEV_TX_OK;
> +	}
> +
> +	/* TX timestamp required */
> +	if (q == RAVB_NC) {
> +		ts_skb = kmalloc(sizeof(*ts_skb), GFP_ATOMIC);
> +		if (!ts_skb)
> +			return -ENOMEM;

Dma mapping has to be undone.

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

According to memory-barriers.txt this needs a mmiowb prior to unlock
(there are still a lot more of those candidates in this driver).

> +	return NETDEV_TX_OK;
> +}
> +
>



> +
> +static int ravb_probe(struct platform_device *pdev)
> +{
> +	struct device_node *np = pdev->dev.of_node;
> +	struct ravb_private *priv;
> +	struct net_device *ndev;
> +	int error, irq, q;
> +	struct resource *res;
> +
> +	if (!np) {
> +		dev_err(&pdev->dev,
> +			"this driver is required to be instantiated from device tree\n");
> +		return -EINVAL;
> +	}
> +
> +	/* Get base address */
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	if (!res) {
> +		dev_err(&pdev->dev, "invalid resource\n");
> +		return -EINVAL;
> +	}
> +
> +	ndev = alloc_etherdev(sizeof(struct ravb_private));
> +	if (!ndev)
> +		return -ENOMEM;
> +
> +	pm_runtime_enable(&pdev->dev);
> +	pm_runtime_get_sync(&pdev->dev);
> +
> +	/* The Ether-specific entries in the device structure. */
> +	ndev->base_addr = res->start;
> +	ndev->dma = -1;
> +	irq = platform_get_irq(pdev, 0);
> +	if (irq < 0) {
> +		error = -ENODEV;
> +		goto out_release;
> +	}
> +	ndev->irq = irq;
> +
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +
> +	priv = netdev_priv(ndev);
> +	priv->ndev = ndev;
> +	priv->pdev = pdev;
> +	priv->num_tx_ring[RAVB_BE] = BE_TX_RING_SIZE;
> +	priv->num_rx_ring[RAVB_BE] = BE_RX_RING_SIZE;
> +	priv->num_tx_ring[RAVB_NC] = NC_TX_RING_SIZE;
> +	priv->num_rx_ring[RAVB_NC] = NC_RX_RING_SIZE;
> +	priv->addr = devm_ioremap_resource(&pdev->dev, res);
> +	if (IS_ERR(priv->addr)) {
> +		error = PTR_ERR(priv->addr);
> +		goto out_release;
> +	}
> +
> +	spin_lock_init(&priv->lock);
> +
> +	priv->phy_interface = of_get_phy_mode(np);
> +
> +	priv->no_avb_link = of_property_read_bool(np, "renesas,no-ether-link");
> +	priv->avb_link_active_low =
> +		of_property_read_bool(np, "renesas,ether-link-active-low");
> +
> +	ndev->netdev_ops = &ravb_netdev_ops;
> +
> +	priv->rx_over_errors = 0;
> +	priv->rx_fifo_errors = 0;
> +	for (q = RAVB_BE; q < NUM_RX_QUEUE; q++) {
> +		struct net_device_stats *stats = &priv->stats[q];
> +
> +		stats->rx_packets = 0;
> +		stats->tx_packets = 0;
> +		stats->rx_bytes = 0;
> +		stats->tx_bytes = 0;
> +		stats->multicast = 0;
> +		stats->rx_errors = 0;
> +		stats->rx_crc_errors = 0;
> +		stats->rx_frame_errors = 0;
> +		stats->rx_length_errors = 0;
> +		stats->rx_missed_errors = 0;
> +		stats->rx_over_errors = 0;
> +	}

The memory returned by alloc_etherdev is already zeroed so this is not
necessary.

Also maybe it would be better to split the driver into more source
files. The result would be much easier to understand and to review. For
example all ptp related code could be put into its own file.


Regards,
Lino

