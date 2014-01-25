From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Sat, 25 Jan 2014 04:34:06 +0300
Message-ID: <52E3148E.2010608@cogentembedded.com>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com> <52DCE9E4.7010209@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org,
	wg@grandegger.com, linux-can@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <52DCE9E4.7010209@pengutronix.de>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01/20/2014 12:18 PM, Marc Kleine-Budde wrote:

>> Add support for the CAN controller found in Renesas R-Car SoCs.

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>> ---
>> The patch is against the 'linux-can-next.git' repo.

[...]
>> Index: linux-can-next/drivers/net/can/rcar_can.c
>> ===================================================================
>> --- /dev/null
>> +++ linux-can-next/drivers/net/can/rcar_can.c
>> @@ -0,0 +1,857 @@
[...]
>> +/* Mailbox registers structure */
>> +struct rcar_can_mbox_regs {
>> +	u32 id;		/* IDE and RTR bits, SID and EID */
>> +	u8 stub;	/* Not used */
>> +	u8 dlc;		/* Data Length Code - bits [0..3] */
>> +	u8 data[8];	/* Data Bytes */
>> +	u8 tsh;		/* Time Stamp Higher Byte */
>> +	u8 tsl;		/* Time Stamp Lower Byte */
>> +} __packed;

> If you have contact to the hardware designer please blame him for

    Unfortunately, we don't.

> placing the data register unaligned into the register space. :)

    It's not even the only one or worst example of questionable register 
design in this module IMO.

[...]
>> +static void rcar_can_tx_done(struct net_device *ndev)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	struct net_device_stats *stats = &ndev->stats;
>> +	int i;
>> +
>> +	spin_lock(&priv->skb_lock);
>> +	for (i = 0; i < priv->frames_queued; i++)
>> +		can_get_echo_skb(ndev, i);
>> +	stats->tx_bytes += priv->bytes_queued;
>> +	stats->tx_packets += priv->frames_queued;
>> +	priv->bytes_queued = 0;
>> +	priv->frames_queued = 0;
>> +	spin_unlock(&priv->skb_lock);

> This looks broken. What happens if you send 2 CAN frames in a row, the
> first one is send, a TX complete interrupt is issued and you handle it
> here? You assume, that all CAN frames have been sent.

    TX interrupt will be issued only when TX FIFO gets empty (all 2 frames
have been transmitted in this case). Please see the comment to the 
RCAR_CAN_MIER1_TXFIT bit.

>> +static irqreturn_t rcar_can_interrupt(int irq, void *dev_id)
>> +{
>> +	struct net_device *ndev = (struct net_device *)dev_id;

> the cast is not needed

    Removed.

[...]
>> +static void rcar_can_set_bittiming(struct net_device *dev)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(dev);
>> +	struct can_bittiming *bt = &priv->can.bittiming;
>> +	u32 bcr;
>> +	u8 clkr;
>> +
>> +	/* Don't overwrite CLKR with 32-bit BCR access */
>> +	/* CLKR has 8-bit access */

> Can you explain the register layout here? Why do you access BCR with 32
> bits when the register is defined as 3x8 bit? Can't you make it a
> standard 32 bit register?

1. According to documentation BCR is the 24-bit register.
Actually we can consider some 32-bit register that combines BCR and
CLKR but according to documentation there are two separate registers.
2. BCR has 8- ,16-, and 32-bit access (according to documentation).
3. This is the algorithm that the documentation suggests.
4. We had a driver version with byte access but 32-bit access seems shorter.

>> +static void rcar_can_start(struct net_device *ndev)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	u16 ctlr, str;
>> +
>> +	/* Set controller to known mode:
>> +	 * - FIFO mailbox mode
>> +	 * - accept all messages
>> +	 * - overrun mode
>> +	 * CAN is in sleep mode after MCU hardware or software reset.
>> +	 */
>> +	ctlr = readw(&priv->regs->ctlr);
>> +	ctlr &= ~RCAR_CAN_CTLR_SLPM;
>> +	writew(ctlr, &priv->regs->ctlr);
>> +	/* Go to reset mode */
>> +	ctlr |= RCAR_CAN_CTLR_CANM_FORCE_RESET;
>> +	writew(ctlr, &priv->regs->ctlr);
>> +	do {
>> +		str = readw(&priv->regs->str);
>> +	} while (!(str & RCAR_CAN_STR_RSTST));

> Please add a timeout for this loop and the loop below.

    Added a counter, converted the loop to *for*.

>> +static int rcar_can_open(struct net_device *ndev)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	int err;
>> +
>> +	clk_prepare_enable(priv->clk);

> clk_prepare_enable can fail

    Added check.

>> +	err = open_candev(ndev);
>> +	if (err) {
>> +		netdev_err(ndev, "open_candev() failed %d\n", err);
>> +		goto out;

> please adjust the jump label, you have to disable the clock.

    Fixed.

[...]
>> +static void rcar_can_stop(struct net_device *ndev)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	u16 ctlr, str;
>> +
>> +	/* Go to (force) reset mode */
>> +	ctlr = readw(&priv->regs->ctlr);
>> +	ctlr |= RCAR_CAN_CTLR_CANM_FORCE_RESET;
>> +	writew(ctlr, &priv->regs->ctlr);
>> +	do {
>> +		str = readw(&priv->regs->str);
>> +	} while (!(str & RCAR_CAN_STR_RSTST));

> please add a timeout to the loop

    Added a counter and converted to *for*.

[...]
>> +static netdev_tx_t rcar_can_start_xmit(struct sk_buff *skb,
>> +				       struct net_device *ndev)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	struct can_frame *cf = (struct can_frame *)skb->data;
>> +	u32 data, i;
>> +	unsigned long flags;
>> +	u8 tfcr;
>> +
>> +	if (can_dropped_invalid_skb(ndev, skb))
>> +		return NETDEV_TX_OK;
>> +	tfcr = readb(&priv->regs->tfcr);
>> +	if ((tfcr & RCAR_CAN_TFCR_TFUST) >> RCAR_CAN_TFCR_TFUST_SHIFT > 2)
>> +		netif_stop_queue(ndev);

> Can you explain what's checked here?

    if (<Number of unsent massages in Transmit FIFO> > 2)

FIFO depth = 4.

    Added a comment. Changed to >= 3.

>> +
>> +	if (cf->can_id & CAN_EFF_FLAG) {
>> +		/* Extended frame format */
>> +		data = (cf->can_id & CAN_EFF_MASK) | RCAR_CAN_IDE;
>> +	} else {
>> +		/* Standard frame format */
>> +		data = (cf->can_id & CAN_SFF_MASK) << RCAR_CAN_SID_SHIFT;
>> +	}
>> +	if (cf->can_id & CAN_RTR_FLAG) {
>> +		/* Remote transmission request */
>> +		data |= RCAR_CAN_RTR;
>> +	}

> You can move the comments into the line of if and else and remove the {
> & } as there is only one line after if and else.

    Done.

>> +	writel(data, &priv->regs->mb[RCAR_CAN_TX_FIFO_MBX].id);
>> +
>> +	writeb(cf->can_dlc, &priv->regs->mb[RCAR_CAN_TX_FIFO_MBX].dlc);
>> +
>> +	for (i = 0; i < cf->can_dlc; i++)
>> +		writeb(cf->data[i],
>> +		       &priv->regs->mb[RCAR_CAN_TX_FIFO_MBX].data[i]);
>> +
>> +	spin_lock_irqsave(&priv->skb_lock, flags);
>> +	can_put_echo_skb(skb, ndev, priv->frames_queued++);
>> +	priv->bytes_queued += cf->can_dlc;

> How does the frames_queued and bytes_queued mechanism work?

    Explained above, we get TX interrupt only after all queued packets are sent.

>> +	spin_unlock_irqrestore(&priv->skb_lock, flags);
>> +	/* Start Tx: write 0xFF to the TFPCR register to increment
>> +	 * the CPU-side pointer for the transmit FIFO to the next
>> +	 * mailbox location
>> +	 */
>> +	writeb(0xFF, &priv->regs->tfpcr);

> please use lowercase for hex.

    Done here ind in comment above.

>> +
>> +	return NETDEV_TX_OK;

> I'm missing flow control here. You have to stop the queue if there isn't
> any room in the tx fifo.

    You've seen it above.

[...]
>> +static int rcar_can_rx_poll(struct napi_struct *napi, int quota)
>> +{
>> +	struct rcar_can_priv *priv = container_of(napi,
>> +						  struct rcar_can_priv, napi);
>> +	int num_pkts = 0;
>> +
>> +	while (num_pkts < quota) {
>> +		u8 i, rfcr, nframes, isr;
>> +
>> +		isr = readb(&priv->regs->isr);
>> +		/* Clear interrupt bit */
>> +		if (isr & RCAR_CAN_ISR_RXFF)
>> +			writeb(isr & ~RCAR_CAN_ISR_RXFF, &priv->regs->isr);
>> +		rfcr = readb(&priv->regs->rfcr);
>> +		if (rfcr & RCAR_CAN_RFCR_RFEST)
>> +			break;
>> +		nframes = (rfcr & RCAR_CAN_RFCR_RFUST) >>
>> +			  RCAR_CAN_RFCR_RFUST_SHIFT;
>> +		for (i = 0; i < nframes; i++) {
>> +			rcar_can_rx_pkt(priv);
>> +			/* Write 0xFF to the RFPCR register to increment
>> +			 * the CPU-side pointer for the receive FIFO
>> +			 * to the next mailbox location
>> +			 */
>> +			writeb(0xFF, &priv->regs->rfpcr);
>> +			++num_pkts;
>> +		}

> The for loop inside the while loop makes no sense if you increment
> num_pkts. You are not allowed to receive more than quota CAN frames.

    Removed the *for* loop. Stupid me. :-)

>> +static int rcar_can_get_berr_counter(const struct net_device *dev,
>> +				     struct can_berr_counter *bec)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(dev);
>> +
>> +	clk_prepare_enable(priv->clk);

> clk_prepare_enable can fail

    Fixed.

[...]
>> +static int rcar_can_resume(struct device *dev)
>> +{
>> +	struct net_device *ndev = dev_get_drvdata(dev);
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	u16 ctlr;
>> +
>> +	clk_enable(priv->clk);

    Added error check.

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

> Please make it an enum

    Done.

WBR, Sergei

