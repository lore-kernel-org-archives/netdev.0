From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH V2] CAN: Add Flexcan CAN controller driver
Date: Tue, 28 Jul 2009 15:37:19 +0200
Message-ID: <20090728133719.GU2714@pengutronix.de>
References: <20090728120624.GS2714@pengutronix.de> <4A6EFB64.8070804@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Socketcan-core@lists.berlios.de,
	Linux Netdev List <netdev@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46107 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754130AbZG1NhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 09:37:20 -0400
Content-Disposition: inline
In-Reply-To: <4A6EFB64.8070804@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Oliver,

On Tue, Jul 28, 2009 at 03:21:40PM +0200, Oliver Hartkopp wrote:
> Sascha Hauer wrote:
> > Hi,
> > 
> > Here is the second version of the flexcan driver.
> 
> Hi Sascha,
> 
> some more points i forgot to mention, sorry ...
> 
> 
> > +/* Structure of the message buffer */
> > +struct flexcan_mb {
> > +	u32	can_dlc;
> > +	u32	can_id;
> > +	u32	data[2];
> > +};
> 
> This looks really hackish and does not reflect the structure of a flexcan
> message buffer! The data is 'u8' and the name of 'dlc' for the
> description/flag register is bad.
> 

see below..

> 
> > +
> > +static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
> > +{
> > +	struct can_frame *frame = (struct can_frame *)skb->data;
> > +	struct flexcan_priv *priv = netdev_priv(dev);
> > +	struct flexcan_regs __iomem *regs = priv->base;
> 
> > +	u32 can_id;
> > +	u32 dlc = MB_CNT_CODE(0xc) | (frame->can_dlc << 16);
> 
> Naming this variable 'dlc' does not hit the point. See below.
> 
> > +	u32 *can_data;
> 
> Really this needs to be fixed up by defining a proper mailbox struct.
> 
> 
> > +
> > +	netif_stop_queue(dev);
> > +
> > +	if (frame->can_id & CAN_EFF_FLAG) {
> > +		can_id = frame->can_id & MB_ID_EXT;
> 
> Please use CAN_EFF_MASK here.

I used MX_ID_EXT intentionally because it it flexcan specific and just
happens to be the same as CAN_EFF_MASK. I can change it if you like.

> 
> 
> > +		dlc |= MB_CNT_IDE | MB_CNT_SRR;
> > +	} else {
> > +		can_id = (frame->can_id & CAN_SFF_MASK) << 18;
> > +	}
> 
> Just nitpicking for Kernel coding style:
> remove the last '{' and '}' pair.

No, Documentation/CondingStyle suggests that if one branch needs braces
the other branch should use them, too.

> 
> > +
> > +	if (frame->can_id & CAN_RTR_FLAG)
> > +		dlc |= MB_CNT_RTR;
> > +
> > +	writel(dlc, &regs->cantxfg[TX_BUF_ID].can_dlc);
> > +	writel(can_id, &regs->cantxfg[TX_BUF_ID].can_id);
> > +
> > +	can_data = (u32 *)frame->data;
> > +	writel(cpu_to_be32(*can_data), &regs->cantxfg[TX_BUF_ID].data[0]);
> > +	writel(cpu_to_be32(*(can_data + 1)), &regs->cantxfg[TX_BUF_ID].data[1]);
> 
> IMHO it is not really transparent, that this is a correct handling to copy the
>   can_frame.data[] on all architectures. I bet creating a for-statement
> regarding the dlc is not slower and makes really clear, what's going on here.

This is indeed a problem here. The original Coldfire code I used as a
template used a loop around unsigned char * which did the wrong thing
for me. So yes, this is not generic here, but I have no idea how the
generic code looks like. As Coldfire is big endian this doesn't seem
that wrong.

> 
> > +
> > +	writel(dlc, &regs->cantxfg[TX_BUF_ID].can_dlc);
> > +
> > +	kfree_skb(skb);
> > +
> > +	return NETDEV_TX_OK;
> > +}
> > +
> > +static void flexcan_rx_frame(struct net_device *ndev,
> > +		struct flexcan_mb __iomem *mb)
> > +{
> > +	struct net_device_stats *stats = &ndev->stats;
> > +	struct sk_buff *skb;
> > +	struct can_frame *frame;
> > +	int ctrl = readl(&mb->can_dlc);
> 
> 'ctrl' is much better than 'dlc' naming above :-)

ok, will change it above.

> 
> > +	int length = (ctrl >> 16) & 0x0f;
> 
> is probably not enough ... use %9 or an additional check.

ok, I'll add a sanity check.

> 
> > +	u32 id;
> > +
> > +	skb = dev_alloc_skb(sizeof(struct can_frame));
> > +	if (!skb) {
> > +		stats->rx_dropped++;
> > +		return;
> > +	}
> > +
> > +	frame = (struct can_frame *)skb_put(skb,
> > +			sizeof(struct can_frame));
> > +
> > +	frame->can_dlc = length;
> > +	id = readl(&mb->can_id) & MB_ID_EXT;
> 
> like above use CAN_EFF_MASK
> 
> or at least rename MB_ID_EXT to MB_ID_EXT_MASK
> 
> > +
> > +	if (ctrl & MB_CNT_IDE) {
> > +		frame->can_id = id & CAN_EFF_MASK;
> > +		frame->can_id |= CAN_EFF_FLAG;
> > +		if (ctrl & MB_CNT_RTR)
> > +			frame->can_id |= CAN_RTR_FLAG;
> > +	} else {
> > +		frame->can_id  = id >> 18;
> > +		if (ctrl & MB_CNT_RTR)
> > +			frame->can_id |= CAN_RTR_FLAG;
> > +	}
> > +
> > +	*(u32 *)frame->data = be32_to_cpu(readl(&mb->data[0]));
> > +	*((u32 *)frame->data + 1) = be32_to_cpu(readl(&mb->data[1]));
> 
> Same as above.
> 
> Please write readable an maintainable code and let the compiler do his job.
> 
> Thanks,
> Oliver
> 

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
