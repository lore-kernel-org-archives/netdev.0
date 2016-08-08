From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [PATCH RESEND] net: can: Introduce MEN 16Z192-00 CAN controller
 driver
Date: Sun, 7 Aug 2016 20:58:14 -0700
Message-ID: <20160808035814.ulqx4hnbtkkd2iko@f1.synalogic.ca>
References: <20160726091555.GA26227@awelinux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wg@grandegger.com, mkl@pengutronix.de, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, jthumshirn@suse.de, andy@wernerandy.de
To: Andreas Werner <andreas.werner@men.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160726091555.GA26227@awelinux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/07/26 11:16, Andreas Werner wrote:
[...]
> +
> +	/* Lock for CTL_BTR register access.
> +	 * This register combines bittiming bits
> +	 * and the operation mode bits.
> +	 * It is also used for bit r/m/w access
> +	 * to all registers.
> +	 */
> +	spinlock_t lock;

Why not use 80 cols for comments?

[...]
> +
> +static int men_z192_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	struct can_frame *cf = (struct can_frame *)skb->data;
> +	struct men_z192 *priv = netdev_priv(ndev);
> +	struct men_z192_regs __iomem *regs = priv->regs;
> +	struct net_device_stats *stats = &ndev->stats;
> +	struct men_z192_cf_buf __iomem *cf_buf;
> +	u32 data[2] = {0, 0};
> +	int status;
> +	u32 id;
> +
> +	if (can_dropped_invalid_skb(ndev, skb))
> +		return NETDEV_TX_OK;
> +
> +	status = readl(&regs->rx_tx_sts);
> +
> +	if (MEN_Z192_TX_BUF_CNT(status) >= 255) {
> +		netif_stop_queue(ndev);
> +		netdev_err(ndev, "not enough space in TX buffer\n");
> +
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	cf_buf = priv->dev_base + MEN_Z192_TX_BUF_START;
> +
> +	if (cf->can_id & CAN_EFF_FLAG) {
> +		/* Extended frame */
> +		id = ((cf->can_id & CAN_EFF_MASK) <<
> +			MEN_Z192_CFBUF_ID2_SHIFT) & MEN_Z192_CFBUF_ID2;
> +
> +		id |= (((cf->can_id & CAN_EFF_MASK) >>
> +			(CAN_EFF_ID_BITS - CAN_SFF_ID_BITS)) <<
> +			 MEN_Z192_CFBUF_ID1_SHIFT) & MEN_Z192_CFBUF_ID1;
> +
> +		id |= MEN_Z192_CFBUF_IDE;
> +		id |= MEN_Z192_CFBUF_SRR;
> +
> +		if (cf->can_id & CAN_RTR_FLAG)
> +			id |= MEN_Z192_CFBUF_E_RTR;
> +	} else {
> +		/* Standard frame */
> +		id = ((cf->can_id & CAN_SFF_MASK) <<
> +		       MEN_Z192_CFBUF_ID1_SHIFT) & MEN_Z192_CFBUF_ID1;
> +
> +		if (cf->can_id & CAN_RTR_FLAG)
> +			id |= MEN_Z192_CFBUF_S_RTR;
> +	}
> +
> +	if (cf->can_dlc > 0)
> +		data[0] = be32_to_cpup((__be32 *)(cf->data));
> +	if (cf->can_dlc > 3)
> +		data[1] = be32_to_cpup((__be32 *)(cf->data + 4));
> +
> +	writel(id, &cf_buf->can_id);
> +	writel(cf->can_dlc, &cf_buf->length);
> +
> +	if (!(cf->can_id & CAN_RTR_FLAG)) {
> +		writel(data[0], &cf_buf->data[0]);
> +		writel(data[1], &cf_buf->data[1]);
> +
> +		stats->tx_bytes += cf->can_dlc;
> +	}
> +
> +	/* be sure everything is written to the
> +	 * device before acknowledge the data.
> +	 */
> +	mmiowb();
> +
> +	/* trigger the transmission */
> +	men_z192_ack_tx_pkg(priv, 1);
> +
> +	stats->tx_packets++;
> +
> +	kfree_skb(skb);

What prevents the skb data to be freed/reused before the device has
accessed it?

[...]
> +
> +static int men_z192_probe(struct mcb_device *mdev,
> +			  const struct mcb_device_id *id)
> +{
> +	struct device *dev = &mdev->dev;
> +	struct men_z192 *priv;
> +	struct net_device *ndev;
> +	void __iomem *dev_base;
> +	struct resource *mem;
> +	u32 timebase;
> +	int ret = 0;
> +	int irq;
> +
> +	mem = mcb_request_mem(mdev, dev_name(dev));
> +	if (IS_ERR(mem)) {
> +		dev_err(dev, "failed to request device memory");
> +		return PTR_ERR(mem);
> +	}
> +
> +	dev_base = ioremap(mem->start, resource_size(mem));
> +	if (!dev_base) {
> +		dev_err(dev, "failed to ioremap device memory");
> +		ret = -ENXIO;
> +		goto out_release;
> +	}
> +
> +	irq = mcb_get_irq(mdev);
> +	if (irq <= 0) {
> +		ret = -ENODEV;
> +		goto out_unmap;
> +	}
> +
> +	ndev = alloc_candev(sizeof(struct men_z192), 1);
> +	if (!ndev) {
> +		dev_err(dev, "failed to allocate the can device");
> +		ret = -ENOMEM;
> +		goto out_unmap;
> +	}
> +
> +	ndev->netdev_ops = &men_z192_netdev_ops;
> +	ndev->irq = irq;
> +
> +	priv = netdev_priv(ndev);
> +	priv->ndev = ndev;
> +	priv->dev = dev;
> +
> +	priv->mem = mem;
> +	priv->dev_base = dev_base;
> +	priv->regs = priv->dev_base + MEN_Z192_REGS_OFFS;
> +
> +	timebase = readl(&priv->regs->timebase);
> +	if (!timebase) {
> +		dev_err(dev, "invalid timebase configured (timebase=%d)\n",
> +			timebase);
> +		ret = -EINVAL;
> +		goto out_unmap;

free_candev is missing in this error path

> +	}
> +
> +	priv->can.clock.freq = timebase;
> +	priv->can.bittiming_const = &men_z192_bittiming_const;
> +	priv->can.do_set_mode = men_z192_set_mode;
> +	priv->can.do_get_berr_counter = men_z192_get_berr_counter;
> +	priv->can.ctrlmode_supported = CAN_CTRLMODE_LISTENONLY |
> +				       CAN_CTRLMODE_3_SAMPLES |
> +				       CAN_CTRLMODE_LOOPBACK;
> +
> +	spin_lock_init(&priv->lock);
> +
> +	netif_napi_add(ndev, &priv->napi, men_z192_poll,
> +		       MEN_Z192_NAPI_WEIGHT);
> +
> +	mcb_set_drvdata(mdev, ndev);
> +	SET_NETDEV_DEV(ndev, dev);
> +
> +	ret = men_z192_register(ndev);
> +	if (ret) {
> +		dev_err(dev, "failed to register CAN device");
> +		goto out_free_candev;
> +	}
> +
> +	dev_info(dev, "MEN 16z192 CAN driver successfully registered\n");
> +
> +	return 0;
> +
> +out_free_candev:
> +	netif_napi_del(&priv->napi);
> +	free_candev(ndev);
> +out_unmap:
> +	iounmap(dev_base);
> +out_release:
> +	mcb_release_mem(mem);
> +	return ret;
> +}
> +
