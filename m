From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] can: add Renesas R-Car CAN driver
Date: Fri, 18 Oct 2013 01:54:23 +0400
Message-ID: <52605C8F.5090606@cogentembedded.com>
References: <201309280211.39068.sergei.shtylyov@cogentembedded.com> <52487991.6000209@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org, linux-sh@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:56112 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763190Ab3JQVz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 17:55:26 -0400
Received: by mail-lb0-f170.google.com with SMTP id w7so2438408lbi.15
        for <netdev@vger.kernel.org>; Thu, 17 Oct 2013 14:55:24 -0700 (PDT)
In-Reply-To: <52487991.6000209@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/29/2013 11:03 PM, Marc Kleine-Budde wrote:

    Sorry for the belated reply -- was on vacations.

>> Add support for the CAN controller found in Renesas R-Car SoCs.

> Is there a public available datasheet for the CAN core?

    I don't think so.

> What architecture are the Renesas R-Car SoCs? They're ARM, aren't they?

    ARM/SH, to be precise.

> What's R-Car's status on device tree conversion?

    Ongoing, but at quite an early stage yet.

> More comments inline

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

[...]

>> Index: linux-can-next/drivers/net/can/rcar_can.c
>> ===================================================================
>> --- /dev/null
>> +++ linux-can-next/drivers/net/can/rcar_can.c
>> @@ -0,0 +1,898 @@
[...]
>> +#define RCAR_CAN_MIER1	0x42C	/* CANi Mailbox Interrupt Enable Register 1 */
>> +#define RCAR_CAN_MKR(n)	((n) < 2 ? 0x430 + 4 * (n) : 0x400 + 4 * ((n) - 2))
>> +				/* CANi Mask Register */
>> +#define RCAR_CAN_MKIVLR0 0x438	/* CANi Mask Invalid Register 0 */
>> +#define RCAR_CAN_MIER0	 0x43C	/* CANi Mailbox Interrupt Enable Register 0 */
>> +
>> +#define RCAR_CAN_MCTL(n) (0x800 + (n)) /* CANi Message Control Register */
>> +#define RCAR_CAN_CTLR	0x840	/* CANi Control Register */
>> +#define RCAR_CAN_STR	0x842	/* CANi Status Register */
>> +#define RCAR_CAN_BCR	0x844	/* CANi Bit Configuration Register */
>> +#define RCAR_CAN_CLKR	0x847	/* CANi Clock Select Register */
>> +#define RCAR_CAN_EIER	0x84C	/* CANi Error Interrupt Enable Register */
>> +#define RCAR_CAN_EIFR	0x84D	/* CANi Err Interrupt Factor Judge Register */
>> +#define RCAR_CAN_RECR	0x84E	/* CANi Receive Error Count Register */
>> +#define RCAR_CAN_TECR	0x84F	/* CANi Transmit Error Count Register */
>> +#define RCAR_CAN_ECSR	0x850	/* CANi Error Code Store Register */
>> +#define RCAR_CAN_MSSR	0x852	/* CANi Mailbox Search Status Register */
>> +#define RCAR_CAN_MSMR	0x853	/* CANi Mailbox Search Mode Register */
>> +#define RCAR_CAN_TCR	0x858	/* CANi Test Control Register */
>> +#define RCAR_CAN_IER	0x860	/* CANi Interrupt Enable Register */
>> +#define RCAR_CAN_ISR	0x861	/* CANi Interrupt Status Register */

> You might consider using an enum for the register offsets.

    Doesn't seem a good idea to me, given the parametrized macros above 
(corresponding to sequentially numbered registers).

>> +
>> +/* Offsets of RCAR_CAN Mailbox Registers */
>> +#define MBX_HDR_OFFSET	0x0
>> +#define MBX_DLC_OFFSET	0x5
>> +#define MBX_DATA_OFFSET	0x6

> can you please add the RCAR_ prefix to all defines.

    I think they would look clumsy but if you insist on *all* defines, I'd do 
it. I'm getting rid of the #define's above based on Wolfgang's feedback.

[...]

>> +static inline u32 rcar_can_mbx_readl(struct rcar_can_priv *priv,
>> +				     u32 mbxno, u8 offset)
>> +{
>> +	return rcar_can_readl(priv, RCAR_CAN_MBX_SIZE * mbxno + offset);

> Can you define hide the RCAR_CAN_MBX_SIZE * mbxno into a macro?
> Something like:

>      RCAR_CAN_MBX(mbxno)

    Used a structure there based on Wolfgang's suggestion.

[...]
>> +static void rcar_can_error(struct net_device *ndev)
>> +{
[...]
>> +	eifr = rcar_can_readb(priv, RCAR_CAN_EIFR);
>> +	if (eifr & EIFR_EWIF) {
>> +		netdev_dbg(priv->ndev, "Error warning interrupt\n");
>> +		priv->can.state = CAN_STATE_ERROR_WARNING;
>> +		priv->can.can_stats.error_warning++;
>> +		cf->can_id |= CAN_ERR_CRTL;
>> +		if (rcar_can_readb(priv, RCAR_CAN_TECR) > 96)
>> +			cf->data[1] |= CAN_ERR_CRTL_TX_WARNING;
>> +		if (rcar_can_readb(priv, RCAR_CAN_RECR) > 96)
>> +			cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
>> +		/* Clear interrupt condition */
>> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_EWIF);

> The cast is not needed.

    Unfortunately, I get a compiler warning without it.

>> +	}
>> +	if (eifr & EIFR_EPIF) {
>> +		netdev_dbg(priv->ndev, "Error passive interrupt\n");
>> +		priv->can.state = CAN_STATE_ERROR_PASSIVE;
>> +		priv->can.can_stats.error_passive++;
>> +		cf->can_id |= CAN_ERR_CRTL;
>> +		if (rcar_can_readb(priv, RCAR_CAN_TECR) > 127)
>> +			cf->data[1] |= CAN_ERR_CRTL_TX_PASSIVE;
>> +		if (rcar_can_readb(priv, RCAR_CAN_RECR) > 127)
>> +			cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
>> +		/* Clear interrupt condition */
>> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_EPIF);
>> +	}
>> +	if (eifr & EIFR_BOEIF) {
>> +		netdev_dbg(priv->ndev, "Bus-off entry interrupt\n");
>> +		priv->can.state = CAN_STATE_BUS_OFF;
>> +		cf->can_id |= CAN_ERR_BUSOFF;
>> +		/* Clear interrupt condition */
>> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_BOEIF);
>> +		/* Disable all interrupts in bus-off to avoid int hog */
>> +		rcar_can_writeb(priv, RCAR_CAN_EIER, 0);
>> +		rcar_can_writeb(priv, RCAR_CAN_IER, 0);
>> +		can_bus_off(ndev);

> How does the rcan recover from bus off?

    Good question... this needs additional work.

[...]

>> +static irqreturn_t rcar_can_interrupt(int irq, void *dev_id)
>> +{
>> +	struct net_device *ndev = (struct net_device *)dev_id;
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	struct net_device_stats *stats = &ndev->stats;
>> +	u8 isr;
>> +
>> +	isr = rcar_can_readb(priv, RCAR_CAN_ISR);
>> +	if (isr & ISR_ERSF)
>> +		rcar_can_error(ndev);
>> +
>> +	if (isr & ISR_TXMF) {
>> +		u32 ie_mask = 0;
>> +
>> +		/* Set Transmit Mailbox Search Mode */
>> +		rcar_can_writeb(priv, RCAR_CAN_MSMR, MSMR_TXMB);

> Can you please outline how to mailbox search mode works? What happens if
> you activate tx mailbox search mode here and rx mailbox search mode below?

    Work of the search is not well documented. The controller has 4 search 
modes, only one can be enabled at the moment.
    I just don't know what happens if we get TX interrupt while handling RX.
Either we painlessly switch to TX search, finish it and return to RX search,
and it continues where we are interrupted... or we lose some RX packets.

>> +		while (1) {

> I presonally don't like while (1) loops in an interrupt handler, can you
> rearange the code, so that you have an explizid loop termination?

    It was done in order to avoid assignment in the *while* expression.
Although checkpatch.pl didn't complain about it, it does complain about such 
in the *if* expression, so I thought it consistent to avoid this in the 
*while* too.

>> +			u8 mctl, mbx;
>> +
>> +			mbx = rcar_can_readb(priv, RCAR_CAN_MSSR);
>> +			if (mbx & MSSR_SEST)
>> +				break;
>> +			mbx &= MSSR_MBNST;
>> +			mctl = rcar_can_readb(priv, RCAR_CAN_MCTL(mbx));
>> +			/* Bits SENTDATA and TRMREQ cannot be
>> +			 * set to 0 simultaneously
>> +			 */
>> +			mctl &= ~MCTL_TRMREQ;
>> +			rcar_can_writeb(priv, RCAR_CAN_MCTL(mbx), mctl);
>> +			mctl &= ~MCTL_SENTDATA;
>> +			/* Clear interrupt */
>> +			rcar_can_writeb(priv, RCAR_CAN_MCTL(mbx), mctl);

> Can you combine both writes to RCAR_CAN_MCTL(mbx) or does the hardware
> require two separate writes?

    Yes, it does. Haven't you seen the comment above the writes?

>> +			ie_mask |= BIT(mbx - FIRST_TX_MB);
>> +			stats->tx_bytes += can_get_echo_skb(ndev,
>> +							    mbx - FIRST_TX_MB);

> Can you guarantee that you call can_get_echo_skb in the same order the
> frames get send?

    Another good question...

[...]
>> +		/* Disable mailbox interrupt, mark mailbox as free */
>> +		if (ie_mask) {
>> +			u32 mier1;
>> +
>> +			spin_lock(&priv->mier_lock);
>> +			mier1 = rcar_can_readl(priv, RCAR_CAN_MIER1);
>> +			rcar_can_writel(priv, RCAR_CAN_MIER1, mier1 & ~ie_mask);
>> +			spin_unlock(&priv->mier_lock);
>> +			if (unlikely(netif_queue_stopped(ndev)))
>> +				netif_wake_queue(ndev);

> You can call netif_wake_queue() unconditionally, it does the check for
> queue stopped anyway.

    Indeed.

>> +		}
>> +	}
>> +	if (isr & ISR_RXM1F) {
>> +		if (napi_schedule_prep(&priv->napi)) {
>> +			/* Disable Rx interrupts */
>> +			rcar_can_writeb(priv, RCAR_CAN_IER,
>> +					rcar_can_readb(priv, RCAR_CAN_IER) &
>> +						       ~IER_RXM1IE);
>> +			__napi_schedule(&priv->napi);
>> +		}
>> +	}
>> +	return IRQ_HANDLED;

> Do not return IRQ_HANDLED unconditionally. You should return IRQ_HANDLED
> only if there really was a interrupt for your device.

    Yes, people have already complained about this. I'll add a check of the 
interrupt status.

>> +static int rcar_can_set_bittiming(struct net_device *dev)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(dev);
>> +	struct can_bittiming *bt = &priv->can.bittiming;
>> +	u32 bcr;
>> +	u16 ctlr;
>> +	u8 clkr;
>> +
>> +	ctlr = rcar_can_readw(priv, RCAR_CAN_CTLR);
>> +	if (ctlr & CTLR_SLPM) {
>> +		/* Write to BCR in CAN reset mode or CAN halt mode */
>> +		return -EBUSY;

> The framework guarantees that set_bittiming is only called when the
> interface is down.

    Exactly. With the current driver code we get rcar_can_set_bittiming() 
called when device is not opened. It is in the sleep mode and we can not touch 
CTLR register in the sleep mode. I call this function when opening device 
explicitly.

[...]
>> +static void rcar_can_start(struct net_device *ndev)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	u16 ctlr, n;
>> +
>> +	/* Set controller to known mode:
>> +	 * - normal mailbox mode (no FIFO);

> Does the controller support FIFO?

    Yes.

[...]

>> +static netdev_tx_t rcar_can_start_xmit(struct sk_buff *skb,
>> +				       struct net_device *ndev)
>> +{
[...]
>> +	spin_lock_irqsave(&priv->mier_lock, flags);
>> +	mier1 = rcar_can_readl(priv, RCAR_CAN_MIER1);
>> +	if (unlikely(mier1 == ~0U)) {
>> +		spin_unlock_irqrestore(&priv->mier_lock, flags);
>> +		netif_stop_queue(ndev);
>> +		return NETDEV_TX_BUSY;
>> +	}
>> +	rcar_can_writel(priv, RCAR_CAN_MIER1, mier1 | (mier1 + 1));
>> +	spin_unlock_irqrestore(&priv->mier_lock, flags);
>> +	mbxno = ffz(mier1) + FIRST_TX_MB;
>
> This smells fishy, for several reasons:
> The driver should guarantee that the frames are send in the same order
> as this function is called. If you pick the first free mailbox I suspect
> the hardware send the first mailbox ready to send. I don't know the
> hardware, but several CAN controllers I've worked with, function in that
> way.

    There are two TX priority modes: ID priority transmit mode and mailbox 
number transmit mode. Currently, ID priority mode is selected -- I didn't 
realize that "the driver should guarantee that the frames are send in the same 
order as this function is called". Still driver can work in the mailbox number 
priority mode.
    ffz(mier1) selects first free mailbox with lowest number. It will have 
higher priority.

> Then you should rethink your flow control. You should call
> netif_stop_queue if all your hardware buffers are full, then the above
> NETDEV_TX_BUSY should not happen.

    You mean that I should check the state of mailboxes at end of this 
function? OK.

[...]
>> +	mctl = rcar_can_readb(priv, RCAR_CAN_MCTL(mbxno));

> Do you have to read mctl here?

    Hm, possibly not. Need to re-check...

[...]
>> +static void rcar_can_rx_pkt(struct rcar_can_priv *priv, int mbx)
>> +{
[...]
>> +	data = rcar_can_mbx_readl(priv, mbx, MBX_HDR_OFFSET);
>> +	if (data & RCAR_CAN_IDE)
>> +		cf->can_id = (data & CAN_EFF_MASK) | CAN_EFF_FLAG;
>> +	else
>> +		cf->can_id = (data >> RCAR_CAN_SID_SHIFT) & CAN_SFF_MASK;
>> +	if (data & RCAR_CAN_RTR)
>> +		cf->can_id |= CAN_RTR_FLAG;
>> +
>> +	dlc = rcar_can_mbx_readb(priv, mbx, MBX_DLC_OFFSET);
>> +	cf->can_dlc = get_can_dlc(dlc);

> Please don't copy data on received RTR frames.

    OK.

>> +	for (dlc = 0; dlc < cf->can_dlc; dlc++)
>> +		cf->data[dlc] = rcar_can_mbx_readb(priv, mbx,
>> +						   MBX_DATA_OFFSET + dlc);
[...]
>> +static int rcar_can_rx_poll(struct napi_struct *napi, int quota)
>> +{
>> +	struct rcar_can_priv *priv = container_of(napi,
>> +						  struct rcar_can_priv, napi);
>> +	u32 num_pkts = 0;

> please make it an int

    OK, overlooked this.

>> +
>> +	/* Find mailbox */
>> +	while (1) {

> please put the quota check into the while()

    OK.

>> +		u8 mctl, mbx;
>> +
>> +		mbx = rcar_can_readb(priv, RCAR_CAN_MSSR);
>> +		if (mbx & MSSR_SEST || num_pkts >= quota)
>> +			break;
>> +		mbx &= MSSR_MBNST;
>> +		mctl = rcar_can_readb(priv, RCAR_CAN_MCTL(mbx));
>> +		/* Clear interrupt */
>> +		rcar_can_writeb(priv, RCAR_CAN_MCTL(mbx),
>> +				mctl & ~MCTL_NEWDATA);
>> +		rcar_can_rx_pkt(priv, mbx);

> Which instruction reenables the mailbox?

    Good question. It's not clear from documentation. For sure we can toggle 
RECREQ bit. My current understanding is: mailbox is not ready to receive while 
MCTL.NEWDATA is set. If so, need to clear interrupt after receive. May need to 
check MSGLOST flag -- need to find out how to report overwritten messages.

>> +	/* All packets processed */
>> +	if (num_pkts < quota) {
>> +		u8 ier;
>> +
>> +		napi_complete(napi);
>> +		ier = rcar_can_readb(priv, RCAR_CAN_IER);
>> +		rcar_can_writeb(priv, RCAR_CAN_IER, ier | IER_RXM1IE);

> I the hardware doesn't modify the IER register, you can work on a shadow
> copy and only write, but never need to read from the hardware.

    OK.

[...]
>> +static int rcar_can_probe(struct platform_device *pdev)
>> +{
[...]
>> +	pdata = pdev->dev.platform_data;

> please use dev_get_platdata()

    OK. I saw the patches converting the drivers to using this helper.

>> +	clk_enable(priv->clk);

> You are missing the clock's prepare step.

    We are not supporting common clock framework yet, so this step should be a 
NOP AFAIU.

> You should call
> clk_prepare_enable(). Please move clock_prepare_enable() to the open()
> (and the disable_unprepare() to the close() function) so tha the core is
> not powered as long as the interface is down. You might have to enable
> the clock in the rcar_can_get_berr_counter() as it may be called if the
> interface is still down.

    OK, will do.

>> +
>> +	ndev->netdev_ops = &rcar_can_netdev_ops;
>> +	ndev->irq = irq;
>> +	ndev->flags |= IFF_ECHO;
>> +	priv->ndev = ndev;
>> +	priv->reg_base = addr;
>> +	priv->clock_select = pdata->clock_select;
>> +	priv->can.clock.freq = clk_get_rate(priv->clk);
>> +	priv->can.bittiming_const = &rcar_can_bittiming_const;
>> +	priv->can.do_set_bittiming = rcar_can_set_bittiming;

> No need to set this callback, as you're calling rcar_can_set_bittiming
> explizidly.

    OK.

>> +	priv->can.do_set_mode = rcar_can_do_set_mode;
>> +	priv->can.do_get_berr_counter = rcar_can_get_berr_counter;
>> +	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES |
>> +				       CAN_CTRLMODE_ONE_SHOT;

> You don't handle 3_SAMPLES. Have you tested your driver in ONE_SHOT

    I've tested in ONE_SHOT but the controller was forced into that mode.
Didn't find application that sets this mode.

> mode? How does the controller react if a frame cannot be send? Do you
> clear the skb that has previously been can_put_echo_skb()?

    Another thing to look at -- maybe related to bus-off question.

>> +static int rcar_can_remove(struct platform_device *pdev)
>> +{
>> +	struct net_device *ndev = platform_get_drvdata(pdev);
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	u16 ctlr;
>> +
>> +	unregister_candev(ndev);
>> +	netif_napi_del(&priv->napi);
>> +	/* Go to sleep mode */
>> +	ctlr = rcar_can_readw(priv, RCAR_CAN_CTLR);
>> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr | CTLR_SLPM);

> You should put the controller in to sleep mode in close()

    Seems OK to do this.

[...]
>> Index: linux-can-next/include/linux/can/platform/rcar_can.h
>> ===================================================================
>> --- /dev/null
>> +++ linux-can-next/include/linux/can/platform/rcar_can.h
>> @@ -0,0 +1,15 @@
>> +#ifndef _CAN_PLATFORM_RCAR_CAN_H_
>> +#define _CAN_PLATFORM_RCAR_CAN_H_
>> +
>> +#include <linux/types.h>
>> +
>> +/* Clock Select Register settings */
>> +#define CLKR_CLKEXT	3	/* Externally input clock */
>> +#define CLKR_CLKP2	1	/* Peripheral clock (clkp2) */
>> +#define CLKR_CLKP1	0	/* Peripheral clock (clkp1) */

> Can this be handled by the clock framework

    No.

> and or Device Tree?

    Yes.

> Marc

WBR, Sergei
