From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] Add Support for Freescale FlexCAN CAN controller
Date: Tue, 28 Jul 2009 09:40:04 +0200
Message-ID: <20090728074004.GR2714@pengutronix.de>
References: <20090724131933.GL2714@pengutronix.de> <4A69CB46.1090704@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Socketcan-core@lists.berlios.de
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35546 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbZG1HkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 03:40:04 -0400
Content-Disposition: inline
In-Reply-To: <4A69CB46.1090704@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 24, 2009 at 04:55:02PM +0200, Wolfgang Grandegger wrote:

[snip]

> > +
> > +static void flexcan_error(struct net_device *ndev, u32 stat)
> > +{
> > +	struct can_frame *cf;
> > +	struct sk_buff *skb;
> > +	struct flexcan_priv *priv = netdev_priv(ndev);
> > +	struct net_device_stats *stats = &ndev->stats;
> > +	enum can_state state = priv->can.state;
> > +	int error_warning = 0, rx_errors = 0;
> > +
> > +	skb = dev_alloc_skb(sizeof(struct can_frame));
> > +	if (!skb)
> > +		return;
> > +
> > +	skb->dev = ndev;
> > +	skb->protocol = htons(ETH_P_CAN);
> 
> 	skb->protocol = __constant_htons(ETH_P_CAN);
> 	skb->ip_summed = CHECKSUM_UNNECESSARY;
> 
> as above?!
> 
> > +
> > +	cf = (struct can_frame *)skb_put(skb, sizeof(*cf));
> > +	memset(cf, 0, sizeof(*cf));
> > +
> > +	cf->can_id = CAN_ERR_FLAG;
> > +	cf->can_dlc = CAN_ERR_DLC;
> > +
> > +	if (stat & ERRSTAT_RWRNINT) {
> > +		error_warning = 1;
> > +		state = CAN_STATE_ERROR_WARNING;
> > +		cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
> > +	}
> > +
> > +	if (stat & ERRSTAT_TWRNINT) {
> > +		error_warning = 1;
> > +		state = CAN_STATE_ERROR_WARNING;

This state change here is bogus as it gets overwritten in the following
switch/case. We can't properly detect error warning state so I'll remove
it in the next version.


> > +		cf->data[1] |= CAN_ERR_CRTL_TX_WARNING;
> > +	}
> > +
> > +	switch ((stat >> 4) & 0x3) {
> > +	case 0:
> > +		state = CAN_STATE_ERROR_ACTIVE;
> > +		break;
> 
> Does the device recover autmatically from the bus-off state? Can
> automatic recovery be configured (switched off?).
> 
> > +	case 1:
> > +		state = CAN_STATE_ERROR_PASSIVE;
> > +		break;
> > +	default:
> > +		state = CAN_STATE_BUS_OFF;
> > +		break;
> > +	}
> 
> You seem to handle a state change to error passive like a change to
> error warning.
> 
> > +	if (stat & ERRSTAT_BOFFINT) {
> > +		cf->can_id |= CAN_ERR_BUSOFF;
> > +		can_bus_off(ndev);
> > +	}
> > +
> > +	if (stat & ERRSTAT_BIT1ERR) {
> 
> 		rx_error = 1; ???
> 
> > +		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
> > +		cf->data[2] |= CAN_ERR_PROT_BIT1;
> > +	}
> > +
> > +	if (stat & ERRSTAT_BIT0ERR) {
> 
> 		rx_error = 1; ???
> 
> > +		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
> > +		cf->data[2] |= CAN_ERR_PROT_BIT0;
> > +	}
> > +
> > +	if (stat & ERRSTAT_FRMERR) {
> > +		rx_errors = 1;
> > +		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
> > +		cf->data[2] |= CAN_ERR_PROT_FORM;
> > +	}
> > +
> > +	if (stat & ERRSTAT_STFERR) {
> > +		rx_errors = 1;
> > +		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
> > +		cf->data[2] |= CAN_ERR_PROT_STUFF;
> > +	}
> > +
> > +
> > +	if (stat & ERRSTAT_ACKERR) {
> > +		rx_errors = 1;
> > +		cf->can_id |= CAN_ERR_ACK;
> 
> Is ACK error a RX error?
> 
> > +	}
> > +
> > +	if (error_warning)
> > +		priv->can.can_stats.error_warning++;
> 
> What about priv->can.can_stats.error_passive;
> 
> > +	if (rx_errors)
> > +		stats->rx_errors++;
> > +	if (cf->can_id & CAN_ERR_BUSERROR)
> > +		priv->can.can_stats.bus_error++;
> 
> It gets incremented in can_bus_off() already!
> 
> > +	priv->can.state = state;
> > +
> > +	netif_rx(skb);
> > +
> > +	ndev->last_rx = jiffies;
> > +	stats->rx_packets++;
> > +	stats->rx_bytes += cf->can_dlc;
> > +}
> > +
> > +static irqreturn_t flexcan_isr(int irq, void *dev_id)
> > +{
> > +	struct net_device *ndev = dev_id;
> > +	struct net_device_stats *stats = &ndev->stats;
> > +	struct flexcan_priv *priv = netdev_priv(ndev);
> > +	struct flexcan_regs __iomem *regs = priv->base;
> > +	u32 iflags, errstat;
> > +
> > +	errstat = readl(&regs->errstat);
> > +	if (errstat & ERRSTAT_INT) {
> > +		flexcan_error(ndev, errstat);
> > +		writel(errstat & ERRSTAT_INT, &regs->errstat);
> > +	}
> > +
> > +	iflags = readl(&regs->iflag1);
> > +
> > +	if (iflags & IFLAG_RX_FIFO_OVERFLOW) {
> > +		writel(IFLAG_RX_FIFO_OVERFLOW, &regs->iflag1);
> > +		stats->rx_over_errors++;
> 
> 		stats->rx_errors++; ???
> 
> > +	}
> > +
> > +	while (iflags & IFLAG_RX_FIFO_AVAILABLE) {
> > +		struct flexcan_mb __iomem *mb = &regs->cantxfg[0];
> > +
> > +		flexcan_rx_frame(ndev, mb);
> > +		writel(IFLAG_RX_FIFO_AVAILABLE, &regs->iflag1);
> > +		readl(&regs->timer);
> > +		iflags = readl(&regs->iflag1);
> > +	}
> > +
> > +	if (iflags & (1 << TX_BUF_ID)) {
> > +		stats->tx_packets++;
> > +		writel((1 << TX_BUF_ID), &regs->iflag1);
> > +		netif_wake_queue(ndev);
> > +	}
> > +
> > +	return IRQ_HANDLED;
> > +}
> > +
> > +static int flexcan_set_bittiming(struct net_device *ndev)
> > +{
> > +	struct flexcan_priv *priv = netdev_priv(ndev);
> > +	struct can_bittiming *bt = &priv->can.bittiming;
> > +	struct flexcan_regs __iomem *regs = priv->base;
> > +	int ret = 0;
> > +	u32 reg;
> > +
> > +	dev_dbg(&ndev->dev, "%s: infreq: %ld brp: %d p1: %d p2: %d sample: %d"
> > +			" sjw: %d prop: %d\n",
> > +			__func__, clk_get_rate(priv->clk), bt->brp,
> > +			bt->phase_seg1, bt->phase_seg2, bt->sample_point,
> > +			bt->sjw, bt->prop_seg);
> 
> Could you replace this dev_dbg() in favor of a
> 
>         dev_info(dev->dev.parent, "setting CANCTRL=0x%x\n", reg);
> 
> before returning.
> 
> > +	reg = readl(&regs->canctrl);
> > +	reg &= ~(CANCTRL_SAMP | CANCTRL_PRESDIV(0xff) |
> > +			CANCTRL_PSEG1(7) | CANCTRL_PSEG2(7));
> > +	reg |= CANCTRL_PRESDIV(bt->brp - 1) |
> > +		CANCTRL_PSEG1(bt->phase_seg1 - 1) |
> > +		CANCTRL_PSEG2(bt->phase_seg2 - 1) |
> > +		CANCTRL_RJW(3) |
> > +		CANCTRL_PROPSEG(bt->prop_seg - 1);
> > +	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
> > +		reg |= CANCTRL_SAMP;
> > +	writel(reg, &regs->canctrl);
> > +
> > +	return ret;
> > +}
> > +
> > +
> 
> Two empty lines!
> 
> > +static int flexcan_open(struct net_device *ndev)
> > +{
> > +	int ret, i;
> > +	struct flexcan_priv *priv = netdev_priv(ndev);
> > +	struct flexcan_regs __iomem *regs = priv->base;
> > +	u32 reg;
> > +
> > +	ret = open_candev(ndev);
> > +	if (ret)
> > +		return ret;
> > +
> > +	ret = request_irq(ndev->irq, flexcan_isr, IRQF_DISABLED,
> > +			DRIVER_NAME, ndev);
> 
> Do you really need IRQF_DISABLED?
> 
> > +	if (ret)
> > +		goto err_irq;
> > +
> > +	clk_enable(priv->clk);
> > +
> > +	reg = CANMCR_SOFTRST | CANMCR_HALT;
> > +	writel(CANMCR_SOFTRST, &regs->canmcr);
> > +	udelay(10);
> > +
> > +	if (readl(&regs->canmcr) & CANMCR_SOFTRST) {
> > +		dev_err(&ndev->dev, "Failed to softreset can module.\n");
> > +		ret = -ENODEV;
> > +		goto err_reset;
> > +	}
> > +
> > +	/* Enable error and bus off interrupt */
> > +	reg = readl(&regs->canctrl);
> > +	reg |= CANCTRL_CLKSRC | CANCTRL_ERRMSK | CANCTRL_BOFFMSK |
> > +		CANCTRL_BOFFREC | CANCTRL_TWRN_MSK | CANCTRL_TWRN_MSK;
> > +	writel(reg, &regs->canctrl);
> > +
> > +	/* Set lowest buffer transmitted first */
> > +	reg |= CANCTRL_LBUF;
> > +	writel(reg, &regs->canctrl);
> > +
> > +	for (i = 0; i < 64; i++) {
> > +		writel(0, &regs->cantxfg[i].can_dlc);
> > +		writel(0, &regs->cantxfg[i].can_id);
> > +		writel(0, &regs->cantxfg[i].data[0]);
> > +		writel(0, &regs->cantxfg[i].data[1]);
> > +
> > +		/* Put MB into rx queue */
> > +		writel(MB_CNT_CODE(0x04), &regs->cantxfg[i].can_dlc);
> > +	}
> > +
> > +	/* acceptance mask/acceptance code (accept everything) */
> > +	writel(0x0, &regs->rxgmask);
> > +	writel(0x0, &regs->rx14mask);
> > +	writel(0x0, &regs->rx15mask);
> > +
> > +	/* Enable flexcan module */
> > +	reg = readl(&regs->canmcr);
> > +	reg &= ~(CANMCR_MDIS | CANMCR_FRZ);
> > +	reg |= CANMCR_IDAM_C | CANMCR_FEN;
> > +	writel(reg, &regs->canmcr);
> > +
> > +	/* Synchronize with the can bus */
> > +	reg &= ~CANMCR_HALT;
> > +	writel(reg, &regs->canmcr);
> > +
> > +	/* Enable interrupts */
> > +	writel(IFLAG_RX_FIFO_OVERFLOW | IFLAG_RX_FIFO_AVAILABLE |
> > +			IFLAG_BUF(TX_BUF_ID),
> > +			&regs->imask1);
> > +
> > +	netif_start_queue(ndev);
> > +
> > +	return 0;
> > +
> > +err_reset:
> > +	free_irq(ndev->irq, ndev);
> > +err_irq:
> > +	close_candev(ndev);
> > +
> > +	return ret;
> > +}
> > +
> > +static int flexcan_close(struct net_device *ndev)
> > +{
> > +	struct flexcan_priv *priv = netdev_priv(ndev);
> > +	struct flexcan_regs __iomem *regs = priv->base;
> > +
> > +	netif_stop_queue(ndev);
> > +
> > +	/* Disable all interrupts */
> > +	writel(0, &regs->imask1);
> > +	free_irq(ndev->irq, ndev);
> > +
> > +	close_candev(ndev);
> > +
> > +	/* Disable module */
> > +	writel(CANMCR_MDIS, &regs->canmcr);
> > +	clk_disable(priv->clk);
> > +	return 0;
> > +}
> > +
> > +static int flexcan_set_mode(struct net_device *ndev, enum can_mode mode)
> > +{
> > +	struct flexcan_priv *priv = netdev_priv(ndev);
> > +	struct flexcan_regs __iomem *regs = priv->base;
> > +	u32 reg;
> > +
> > +	switch (mode) {
> > +	case CAN_MODE_START:
> > +		reg = readl(&regs->canctrl);
> > +		reg &= ~CANCTRL_BOFFREC;
> > +		writel(reg, &regs->canctrl);
> > +		reg |= CANCTRL_BOFFREC;
> > +		writel(reg, &regs->canctrl);
> > +		priv->can.state = CAN_STATE_ERROR_ACTIVE;
> > +
> > +		if (netif_queue_stopped(ndev))
> > +			netif_wake_queue(ndev);
> > +		break;
> > +
> > +	default:
> > +		return -EOPNOTSUPP;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static const struct net_device_ops flexcan_netdev_ops = {
> > +       .ndo_open		= flexcan_open,
> > +       .ndo_stop		= flexcan_close,
> > +       .ndo_start_xmit		= flexcan_start_xmit,
> > +};
> > +
> > +static int register_flexcandev(struct net_device *ndev)
> > +{
> > +	struct flexcan_priv *priv = netdev_priv(ndev);
> > +	struct flexcan_regs __iomem *regs = priv->base;
> > +	u32 reg;
> > +
> > +	reg = readl(&regs->canmcr);
> > +	reg &= ~CANMCR_MDIS;
> > +	writel(reg, &regs->canmcr);
> > +	udelay(100);
> > +	reg |= CANMCR_FRZ | CANMCR_HALT | CANMCR_FEN;
> > +	writel(reg, &regs->canmcr);
> > +
> > +	reg = readl(&regs->canmcr);
> > +
> > +	/* Currently we only support newer versions of this core featuring
> > +	 * a RX FIFO. Older cores found on some Coldfire derivates are not
> > +	 * yet supported.
> > +	 */
> > +	if (!(reg & CANMCR_FEN)) {
> > +		dev_err(&ndev->dev, "Could not enable RX FIFO, unsupported core");
> 
> Line too long!
> 
> > +		return -ENODEV;
> > +	}
> > +
> > +	ndev->flags |= IFF_ECHO; /* we support local echo in hardware */
> > +	ndev->netdev_ops = &flexcan_netdev_ops;
> > +
> > +	return register_candev(ndev);
> > +}
> > +
> > +static void unregister_flexcandev(struct net_device *ndev)
> > +{
> > +	struct flexcan_priv *priv = netdev_priv(ndev);
> > +	struct flexcan_regs __iomem *regs = priv->base;
> > +	u32 reg;
> > +
> > +	reg = readl(&regs->canmcr);
> > +	reg |= CANMCR_FRZ | CANMCR_HALT | CANMCR_MDIS;
> > +	writel(reg, &regs->canmcr);
> > +
> > +	unregister_candev(ndev);
> > +}
> > +
> > +static int __devinit flexcan_probe(struct platform_device *pdev)
> > +{
> > +	struct resource *mem;
> > +	struct net_device *ndev;
> > +	struct flexcan_priv *priv;
> > +	u32 mem_size;
> > +	int ret;
> > +
> > +	ndev = alloc_candev(sizeof(struct flexcan_priv));
> > +	if (!ndev)
> > +		return -ENOMEM;
> > +
> > +	priv = netdev_priv(ndev);
> > +
> > +	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> > +
> > +	ndev->irq = platform_get_irq(pdev, 0);
> > +	if (!mem || !ndev->irq) {
> > +		ret = -ENODEV;
> > +		goto failed_req;
> > +	}
> > +
> > +	mem_size = resource_size(mem);
> > +
> > +	if (!request_mem_region(mem->start, mem_size, DRIVER_NAME)) {
> > +		ret = -EBUSY;
> > +		goto failed_req;
> > +	}
> > +
> > +	SET_NETDEV_DEV(ndev, &pdev->dev);
> > +
> > +	priv->base = ioremap(mem->start, mem_size);
> > +	if (!priv->base) {
> > +		ret = -ENOMEM;
> > +		goto failed_map;
> > +	}
> > +
> > +	priv->clk = clk_get(&pdev->dev, NULL);
> > +	if (IS_ERR(priv->clk)) {
> > +		ret = PTR_ERR(priv->clk);
> > +		goto failed_clock;
> > +	}
> > +	priv->can.clock.freq = clk_get_rate(priv->clk);
> > +
> > +	platform_set_drvdata(pdev, ndev);
> > +
> > +	priv->can.do_set_bittiming = flexcan_set_bittiming;
> > +	priv->can.bittiming_const = &flexcan_bittiming_const;
> > +	priv->can.do_set_mode = flexcan_set_mode;
> > +
> > +	ret = register_flexcandev(ndev);
> > +	if (ret)
> > +		goto failed_register;
> > +
> > +	return 0;
> > +
> > +failed_register:
> > +	clk_put(priv->clk);
> > +failed_clock:
> > +	iounmap(priv->base);
> > +failed_map:
> > +	release_mem_region(mem->start, mem_size);
> > +failed_req:
> > +	free_candev(ndev);
> > +
> > +	return ret;
> > +}
> > +
> > +static int __devexit flexcan_remove(struct platform_device *pdev)
> > +{
> > +	struct net_device *ndev = platform_get_drvdata(pdev);
> > +	struct flexcan_priv *priv = netdev_priv(ndev);
> > +	struct resource *mem;
> > +
> > +	unregister_flexcandev(ndev);
> > +	platform_set_drvdata(pdev, NULL);
> > +	iounmap(priv->base);
> > +	clk_put(priv->clk);
> > +
> > +	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> > +	release_mem_region(mem->start, resource_size(mem));
> > +	free_candev(ndev);
> > +
> > +	return 0;
> > +}
> > +
> > +static struct platform_driver flexcan_driver = {
> > +	.driver = {
> > +		   .name = DRIVER_NAME,
> > +		   },
> > +	.probe = flexcan_probe,
> > +	.remove = __devexit_p(flexcan_remove),
> > +};
> > +
> > +static int __init flexcan_init(void)
> > +{
> > +	return platform_driver_register(&flexcan_driver);
> > +}
> > +
> > +static void __exit flexcan_exit(void)
> > +{
> > +	platform_driver_unregister(&flexcan_driver);
> > +}
> > +
> > +module_init(flexcan_init);
> > +module_exit(flexcan_exit);
> > +
> > +MODULE_AUTHOR("Sascha Hauer <s.hauer@pengutronix.de>");
> > +MODULE_LICENSE("GPL v2");
> > +MODULE_DESCRIPTION("CAN port driver for flexcan based chip");
> 
> Apart from that, it already looks quite good.
> 
> Thanks for your contribution.
> 
> Wolfgang.
> 

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
