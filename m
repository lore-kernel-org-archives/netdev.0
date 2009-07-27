From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] Add Support for Freescale FlexCAN CAN controller
Date: Mon, 27 Jul 2009 10:30:31 +0200
Message-ID: <4A6D65A7.4080805@grandegger.com>
References: <20090724131933.GL2714@pengutronix.de>	<4A69CB46.1090704@grandegger.com> <20090727062559.GP2714@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core@lists.berlios.de,
	Linux Netdev List <netdev@vger.kernel.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:41804 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbZG0Iaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 04:30:35 -0400
In-Reply-To: <20090727062559.GP2714@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha Hauer wrote:
> On Fri, Jul 24, 2009 at 04:55:02PM +0200, Wolfgang Grandegger wrote:
>> Hi Sascha,
>>
>> Sascha Hauer wrote:
>>> Hi,
>>>
>>> This patch adds support for the Freescale FlexCAN CAN controller.
>>> The driver has been tested on an i.MX25 SoC with bitrates up to
>>> 1Mbit, remote frames and standard and extenden frames.
>>>
>>> Please review and consider for inclusion.
>> See below...
>>
>>> Sascha
[snip]
>>> +static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
>>> +{
>>> +	struct can_frame *frame = (struct can_frame *)skb->data;
>>> +	struct flexcan_priv *priv = netdev_priv(dev);
>>> +	struct flexcan_regs __iomem *regs = priv->base;
>>> +	u32 can_id;
>>> +	u32 dlc = MB_CNT_CODE(0xc) | (frame->can_dlc << 16);
>>> +	u32 *can_data;
>>> +
>>> +	netif_stop_queue(dev);
>>> +
>>> +	if (frame->can_id & CAN_EFF_FLAG) {
>>> +		can_id = frame->can_id & MB_ID_EXT;
>>> +		dlc |= MB_CNT_IDE | MB_CNT_SRR;
>>> +	} else {
>>> +		can_id = (frame->can_id & CAN_SFF_MASK) << 18;
>>> +	}
>>> +
>>> +	if (frame->can_id & CAN_RTR_FLAG)
>>> +		dlc |= MB_CNT_RTR;
>>> +
>>> +	writel(dlc, &regs->cantxfg[TX_BUF_ID].can_dlc);
>>> +	writel(can_id, &regs->cantxfg[TX_BUF_ID].can_id);
>>> +
>>> +	can_data = (u32 *)frame->data;
>>> +	writel(cpu_to_be32(*can_data), &regs->cantxfg[TX_BUF_ID].data[0]);
>>> +	writel(cpu_to_be32(*(can_data + 1)), &regs->cantxfg[TX_BUF_ID].data[1]);
>>> +
>>> +	writel(dlc, &regs->cantxfg[TX_BUF_ID].can_dlc);
>>> +
>>> +	kfree_skb(skb);
>> Support for echo skb using can_put/get_echo_skb() is missing. It should
>> not be a big deal to add it.
> 
> In fact it's not missing, but the hardware is configured to receive its
> own packets, so this isn't needed.

Ah, OK, I assume that the message is looped back not before it went out
to the bus to ensure proper time ordering.

>>> +
>>> +	return NETDEV_TX_OK;
>>> +}
>>> +
>>> +static void flexcan_rx_frame(struct net_device *ndev,
>>> +		struct flexcan_mb __iomem *mb)
>>> +{
>>> +	struct net_device_stats *stats = &ndev->stats;
>>> +	struct sk_buff *skb;
>>> +	struct can_frame *frame;
>>> +	int ctrl = readl(&mb->can_dlc);
>>> +	int length = (ctrl >> 16) & 0x0f;
>>> +	u32 id;
>>> +
>>> +	skb = dev_alloc_skb(sizeof(struct can_frame));
>>> +	if (!skb) {
>>> +		stats->rx_dropped++;
>>> +		return;
>>> +	}
>>> +
>>> +	frame = (struct can_frame *)skb_put(skb,
>>> +			sizeof(struct can_frame));
>>> +
>>> +	frame->can_dlc = length;
>>> +	id = readl(&mb->can_id) & MB_ID_EXT;
>>> +
>>> +	if (ctrl & MB_CNT_IDE) {
>>> +		frame->can_id = id & CAN_EFF_MASK;
>>> +		frame->can_id |= CAN_EFF_FLAG;
>>> +		if (ctrl & MB_CNT_RTR)
>>> +			frame->can_id |= CAN_RTR_FLAG;
>>> +	} else {
>>> +		frame->can_id  = id >> 18;
>>> +		if (ctrl & MB_CNT_RTR)
>>> +			frame->can_id |= CAN_RTR_FLAG;
>>> +	}
>>> +
>>> +	*(u32 *)frame->data = be32_to_cpu(readl(&mb->data[0]));
>>> +	*((u32 *)frame->data + 1) = be32_to_cpu(readl(&mb->data[1]));
>>> +
>>> +	stats->rx_packets++;
>>> +	stats->rx_bytes += frame->can_dlc;
>>> +	skb->dev = ndev;
>>> +	skb->protocol = __constant_htons(ETH_P_CAN);
>>> +	skb->ip_summed = CHECKSUM_UNNECESSARY;
>>> +
>>> +	netif_rx(skb);
>>> +}
>>> +
>>> +static void flexcan_error(struct net_device *ndev, u32 stat)
>>> +{
>>> +	struct can_frame *cf;
>>> +	struct sk_buff *skb;
>>> +	struct flexcan_priv *priv = netdev_priv(ndev);
>>> +	struct net_device_stats *stats = &ndev->stats;
>>> +	enum can_state state = priv->can.state;
>>> +	int error_warning = 0, rx_errors = 0;
>>> +
>>> +	skb = dev_alloc_skb(sizeof(struct can_frame));
>>> +	if (!skb)
>>> +		return;
>>> +
>>> +	skb->dev = ndev;
>>> +	skb->protocol = htons(ETH_P_CAN);
>> 	skb->protocol = __constant_htons(ETH_P_CAN);
>> 	skb->ip_summed = CHECKSUM_UNNECESSARY;
>>
>> as above?!
> 
> Ok
> 
>>> +
>>> +	cf = (struct can_frame *)skb_put(skb, sizeof(*cf));
>>> +	memset(cf, 0, sizeof(*cf));
>>> +
>>> +	cf->can_id = CAN_ERR_FLAG;
>>> +	cf->can_dlc = CAN_ERR_DLC;
>>> +
>>> +	if (stat & ERRSTAT_RWRNINT) {
>>> +		error_warning = 1;
>>> +		state = CAN_STATE_ERROR_WARNING;
>>> +		cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
>>> +	}
>>> +
>>> +	if (stat & ERRSTAT_TWRNINT) {
>>> +		error_warning = 1;
>>> +		state = CAN_STATE_ERROR_WARNING;
>>> +		cf->data[1] |= CAN_ERR_CRTL_TX_WARNING;
>>> +	}
>>> +
>>> +	switch ((stat >> 4) & 0x3) {
>>> +	case 0:
>>> +		state = CAN_STATE_ERROR_ACTIVE;
>>> +		break;
>> Does the device recover autmatically from the bus-off state? Can
>> automatic recovery be configured (switched off?).
> 
> The device *can* be configured to automatically recover from bus off,
> but I didn't use this feature to be more conform to the Linux CAN API.

Good.

>>> +	case 1:
>>> +		state = CAN_STATE_ERROR_PASSIVE;
>>> +		break;
>>> +	default:
>>> +		state = CAN_STATE_BUS_OFF;
>>> +		break;
>>> +	}
>> You seem to handle a state change to error passive like a change to
>> error warning.
>>
>>> +	if (stat & ERRSTAT_BOFFINT) {
>>> +		cf->can_id |= CAN_ERR_BUSOFF;
>>> +		can_bus_off(ndev);
>>> +	}
>>> +
>>> +	if (stat & ERRSTAT_BIT1ERR) {
>> 		rx_error = 1; ???
>>
>>> +		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>> +		cf->data[2] |= CAN_ERR_PROT_BIT1;
>>> +	}
>>> +
>>> +	if (stat & ERRSTAT_BIT0ERR) {
>> 		rx_error = 1; ???
>>
>>> +		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>> +		cf->data[2] |= CAN_ERR_PROT_BIT0;
>>> +	}
>>> +
>>> +	if (stat & ERRSTAT_FRMERR) {
>>> +		rx_errors = 1;
>>> +		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>> +		cf->data[2] |= CAN_ERR_PROT_FORM;
>>> +	}
>>> +
>>> +	if (stat & ERRSTAT_STFERR) {
>>> +		rx_errors = 1;
>>> +		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>> +		cf->data[2] |= CAN_ERR_PROT_STUFF;
>>> +	}
>>> +
>>> +
>>> +	if (stat & ERRSTAT_ACKERR) {
>>> +		rx_errors = 1;
>>> +		cf->can_id |= CAN_ERR_ACK;
>> Is ACK error a RX error?
>>
>>> +	}
>>> +
>>> +	if (error_warning)
>>> +		priv->can.can_stats.error_warning++;
>> What about priv->can.can_stats.error_passive;
>>
>>> +	if (rx_errors)
>>> +		stats->rx_errors++;
>>> +	if (cf->can_id & CAN_ERR_BUSERROR)
>>> +		priv->can.can_stats.bus_error++;
>> It gets incremented in can_bus_off() already!
> 
> ok, I will rework the error handling.
> 
>>> +	priv->can.state = state;
>>> +
>>> +	netif_rx(skb);
>>> +
>>> +	ndev->last_rx = jiffies;
>>> +	stats->rx_packets++;
>>> +	stats->rx_bytes += cf->can_dlc;
>>> +}
>>> +
>>> +static irqreturn_t flexcan_isr(int irq, void *dev_id)
>>> +{
>>> +	struct net_device *ndev = dev_id;
>>> +	struct net_device_stats *stats = &ndev->stats;
>>> +	struct flexcan_priv *priv = netdev_priv(ndev);
>>> +	struct flexcan_regs __iomem *regs = priv->base;
>>> +	u32 iflags, errstat;
>>> +
>>> +	errstat = readl(&regs->errstat);
>>> +	if (errstat & ERRSTAT_INT) {
>>> +		flexcan_error(ndev, errstat);
>>> +		writel(errstat & ERRSTAT_INT, &regs->errstat);
>>> +	}
>>> +
>>> +	iflags = readl(&regs->iflag1);
>>> +
>>> +	if (iflags & IFLAG_RX_FIFO_OVERFLOW) {
>>> +		writel(IFLAG_RX_FIFO_OVERFLOW, &regs->iflag1);
>>> +		stats->rx_over_errors++;
>> 		stats->rx_errors++; ???
>>
>>> +	}
>>> +
>>> +	while (iflags & IFLAG_RX_FIFO_AVAILABLE) {
>>> +		struct flexcan_mb __iomem *mb = &regs->cantxfg[0];
>>> +
>>> +		flexcan_rx_frame(ndev, mb);
>>> +		writel(IFLAG_RX_FIFO_AVAILABLE, &regs->iflag1);
>>> +		readl(&regs->timer);
>>> +		iflags = readl(&regs->iflag1);
>>> +	}
>>> +
>>> +	if (iflags & (1 << TX_BUF_ID)) {
>>> +		stats->tx_packets++;
>>> +		writel((1 << TX_BUF_ID), &regs->iflag1);
>>> +		netif_wake_queue(ndev);
>>> +	}
>>> +
>>> +	return IRQ_HANDLED;
>>> +}
>>> +
>>> +static int flexcan_set_bittiming(struct net_device *ndev)
>>> +{
>>> +	struct flexcan_priv *priv = netdev_priv(ndev);
>>> +	struct can_bittiming *bt = &priv->can.bittiming;
>>> +	struct flexcan_regs __iomem *regs = priv->base;
>>> +	int ret = 0;
>>> +	u32 reg;
>>> +
>>> +	dev_dbg(&ndev->dev, "%s: infreq: %ld brp: %d p1: %d p2: %d sample: %d"
>>> +			" sjw: %d prop: %d\n",
>>> +			__func__, clk_get_rate(priv->clk), bt->brp,
>>> +			bt->phase_seg1, bt->phase_seg2, bt->sample_point,
>>> +			bt->sjw, bt->prop_seg);
>> Could you replace this dev_dbg() in favor of a
>>
>>         dev_info(dev->dev.parent, "setting CANCTRL=0x%x\n", reg);
>>
>> before returning.
> 
> The dev_dbg is redundant as the output of 'ip' already shows this
> information. But shouldn't this be a dev_dbg, too?

For SJA1000 and MSCAN we currently use dev_info() here. I found it
useful to show the bittiming registers as there is no other method to
retrieve them, but that's debatable.

[...]
>>> +MODULE_AUTHOR("Sascha Hauer <s.hauer@pengutronix.de>");
>>> +MODULE_LICENSE("GPL v2");
>>> +MODULE_DESCRIPTION("CAN port driver for flexcan based chip");
>> Apart from that, it already looks quite good.
>>
>> Thanks for your contribution.
> 
> Thanks for review, I will send an updated version soon.

Wolfgang.
