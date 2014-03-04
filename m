From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v7] can: add Renesas R-Car CAN driver
Date: Wed, 05 Mar 2014 01:18:21 +0300
Message-ID: <5316512D.7060802@cogentembedded.com>
References: <201402210222.50283.sergei.shtylyov@cogentembedded.com> <530F4B51.5020904@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org,
	wg@grandegger.com, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <530F4B51.5020904@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/27/2014 05:27 PM, Marc Kleine-Budde wrote:

>> Add support for the CAN controller found in Renesas R-Car SoCs.

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> See comments inline.

    Thanks.
    Had to cut out large fragments you didn't comment on. I think everybody 
would be grateful if you did it instead, and they didn't have to scroll thru 
the large mail searching for comments.

> Marc

[...]
>> Index: linux-can-next/drivers/net/can/rcar_can.c
>> ===================================================================
>> --- /dev/null
>> +++ linux-can-next/drivers/net/can/rcar_can.c
>> @@ -0,0 +1,858 @@
[...]
>> +struct rcar_can_regs {
>> +	struct rcar_can_mbox_regs mb[RCAR_CAN_N_MBX]; /* Mailbox registers */
>> +	u32 mkr_2_9[8];	/* Mask Registers 2-9 */
>> +	u32 fidcr[2];	/* FIFO Received ID Compare Register */
>> +	u32 mkivlr1;	/* Mask Invalid Register 1 */
>> +	u32 mier1;	/* Mailbox Interrupt Enable Register 1 */
>> +	u32 mkr_0_1[2];	/* Mask Registers 0-1 */
>> +	u32 mkivlr0;    /* Mask Invalid Register 0*/
>> +	u32 mier0;      /* Mailbox Interrupt Enable Register 0 */
>> +	u8 pad_440[0x3c0];
>> +	u8 mctl[64];	/* Message Control Registers */
>> +	u16 ctlr;	/* Control Register */
>> +	u16 str;	/* Status register */
>> +	u8 bcr[3];	/* Bit Configuration Register */
>> +	u8 clkr;	/* Clock Select Register */

> What about making this a u32?

    No, these are two distinct registers.

>> +	u8 rfcr;	/* Receive FIFO Control Register */
>> +	u8 rfpcr;	/* Receive FIFO Pointer Control Register */
>> +	u8 tfcr;	/* Transmit FIFO Control Register */
>> +	u8 tfpcr;       /* Transmit FIFO Pointer Control Register */
>> +	u8 eier;	/* Error Interrupt Enable Register */
>> +	u8 eifr;	/* Error Interrupt Factor Judge Register */
>> +	u8 recr;	/* Receive Error Count Register */
>> +	u8 tecr;        /* Transmit Error Count Register */
>> +	u8 ecsr;	/* Error Code Store Register */
>> +	u8 cssr;	/* Channel Search Support Register */
>> +	u8 mssr;	/* Mailbox Search Status Register */
>> +	u8 msmr;	/* Mailbox Search Mode Register */
>> +	u16 tsr;	/* Time Stamp Register */
>> +	u8 afsr;	/* Acceptance Filter Support Register */
>> +	u8 pad_857;
>> +	u8 tcr;		/* Test Control Register */
>> +	u8 pad_859[7];
>> +	u8 ier;		/* Interrupt Enable Register */
>> +	u8 isr;		/* Interrupt Status Register */
>> +	u8 pad_862;
>> +	u8 mbsmr;	/* Mailbox Search Mask Register */
>> +};
>> +
>> +struct rcar_can_priv {
>> +	struct can_priv can;	/* Must be the first member! */
>> +	struct net_device *ndev;
>> +	struct napi_struct napi;
>> +	struct rcar_can_regs __iomem *regs;
>> +	struct clk *clk;
>> +	u8 tx_dlc[RCAR_CAN_FIFO_DEPTH];
>> +	u8 echo_skb_head;
>> +	u8 echo_skb_tail;

> better make the head and tail unsinged int, please name them
> tx_{head,tail} as in the xilinx driver

    OK.

[...]
>> +static void rcar_can_tx_done(struct net_device *ndev)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	struct net_device_stats *stats = &ndev->stats;
>> +

> If you have a TX FIFO, there can more than one frame transmitted since
> you've been here, you should add some kind of loop here.

    So what? We'll just get more interrupts.

> The loop should looke like this:

>      while (priv->tx_head - priv->tx_tail > 0) {
> 	if (!check_hardware_if_frame_has_been_traansmitted())
> 		break;

    I can only use the interrupt bit (ISR.TXFF) in this check. I'm not sure 
what this achieves other than some micro-optimization.

>> +	stats->tx_packets++;
>> +	stats->tx_bytes += priv->tx_dlc[priv->echo_skb_tail];
> 		+= priv->tx_dlc[priv->tx_tail % RCAR_CAN_FIFO_DEPTH]

     Are you sure modulus used here and all over the code is more efficient 
than two *if* statements? It's not so obvious...

>> +	priv->tx_dlc[priv->echo_skb_tail] = 0;
>> +	can_get_echo_skb(ndev, priv->echo_skb_tail);
				priv->tx_tail % RCAR_CAN_FIFO_DEPTH
>> +	if (++priv->echo_skb_tail >= RCAR_CAN_FIFO_DEPTH)
>> +		priv->echo_skb_tail = 0;

> 		pric->tx_tail++;
> 	}

>> +	can_led_event(ndev, CAN_LED_EVENT_TX);
>> +	netif_wake_queue(ndev);
>> +}
>> +
>> +static irqreturn_t rcar_can_interrupt(int irq, void *dev_id)
>> +{
>> +	struct net_device *ndev = dev_id;
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	u8 isr;
>> +
>> +	isr = readb(&priv->regs->isr);
>> +	if (!(isr & priv->ier))
>> +		return IRQ_NONE;
>> +
>> +	if (isr & RCAR_CAN_ISR_ERSF)
>> +		rcar_can_error(ndev);
>> +
>> +	if (isr & RCAR_CAN_ISR_TXFF) {
>> +		/* Clear interrupt */
>> +		writeb(isr & ~RCAR_CAN_ISR_TXFF, &priv->regs->isr);

> Does this clean the IRQ for the just transmitted CAN frame or for all,
> if there is more then one frame transmitted successfully?

    In my understanding, this bit is set after each transmitted frame (as 
selected by MIER1.MB57. So clearing this bit should clear interrupt for all 
transmitted frames. So I have doubt in the current algorithm now: if for some 
reason (interrupt latency) we get this interrupt with 2 or more trasmitted 
frames, we only register one, and the loop you're suggesting above won't help 
here. I guess the previously used scheme with FIFO TX interrupt firing after 
FIFO was completely empty better suited this case.

>> +		rcar_can_tx_done(ndev);
>> +	}
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

> Why don't you do a 32 bit read - then modify - then write 32 bit?

    I hope I've cleared the matter enough now in another thread.

>> +	clkr = readb(&priv->regs->clkr);

    I'll consider using platform data instead of a hardware read...

>> +	bcr = RCAR_CAN_BCR_TSEG1(bt->phase_seg1 + bt->prop_seg - 1) |
>> +	      RCAR_CAN_BCR_BPR(bt->brp - 1) | RCAR_CAN_BCR_SJW(bt->sjw - 1) |
>> +	      RCAR_CAN_BCR_TSEG2(bt->phase_seg2 - 1);
>> +	/* All the registers are big-endian but they get byte-swapped on 32-bit
>> +	 * read/write (but not on 8-bit, contrary to the manuals)...
>> +	 */

> If you use 32bit for both read and write, there should be nothing
> special to worry abaut.

    I hope I've cleared the matter enough now in another thread.

>> +	writel((bcr << 8) | clkr, &priv->regs->bcr);
>> +}
>> +
>> +static void rcar_can_start(struct net_device *ndev)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	u16 ctlr;
>> +	int i;
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
>> +	for (i = 0; i < MAX_STR_READS; i++) {
>> +		if (readw(&priv->regs->str) & RCAR_CAN_STR_RSTST)

> How long does it take? Do you need some kind of usleep_range() here?

    Actually, single status read is enough, loop was added just in case.
So, no need to sleep.

>> +			break;
>> +	}
[...]
>> +static void rcar_can_stop(struct net_device *ndev)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	u16 ctlr;
>> +	int i;
>> +
>> +	/* Go to (force) reset mode */
>> +	ctlr = readw(&priv->regs->ctlr);
>> +	ctlr |= RCAR_CAN_CTLR_CANM_FORCE_RESET;
>> +	writew(ctlr, &priv->regs->ctlr);
>> +	for (i = 0; i < MAX_STR_READS; i++) {
>> +		if (readw(&priv->regs->str) & RCAR_CAN_STR_RSTST)

> sleep needed?

    No, see above.

>> +			break;
>> +	}
>> +	writel(0, &priv->regs->mier0);
>> +	writel(0, &priv->regs->mier1);
>> +	writeb(0, &priv->regs->ier);
>> +	writeb(0, &priv->regs->eier);
>> +	/* Go to sleep mode */
>> +	ctlr |= RCAR_CAN_CTLR_SLPM;
>> +	writew(ctlr, &priv->regs->ctlr);
>> +	priv->can.state = CAN_STATE_STOPPED;
>> +}
>> +
>> +static int rcar_can_close(struct net_device *ndev)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +
>> +	netif_stop_queue(ndev);

> A running interrupt may restart the queue.

    OK, should move this below the next call.

>> +	rcar_can_stop(ndev);
>> +	free_irq(ndev->irq, ndev);
>> +	napi_disable(&priv->napi);

> Better disable napi at first.

    No, it's not actually better. You'll risk RX interrupt storm if a packet 
arrives after NAPI is disabled.

[...]
>> +static netdev_tx_t rcar_can_start_xmit(struct sk_buff *skb,
>> +				       struct net_device *ndev)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	struct can_frame *cf = (struct can_frame *)skb->data;
>> +	u32 data, i;
>> +	u8 tfcr;
>> +
>> +	if (can_dropped_invalid_skb(ndev, skb))
>> +		return NETDEV_TX_OK;
>> +	tfcr = readb(&priv->regs->tfcr);
>> +	/* Stop queue if we are to fill the last FIFO entry */
>> +	if ((tfcr & RCAR_CAN_TFCR_TFUST) >> RCAR_CAN_TFCR_TFUST_SHIFT >= 3)

> Where does the magic "3" come from?

    Should have used RCAR_CAN_FIFO_DEPTH - 1...

> BTW: no need to read the hardware here, can rely on your own counting:
> 	if ((priv->tx_head - priv->tx_tail) == RCAR_CAN_FIFO_DEPTH)

>> +		netif_stop_queue(ndev);

> But move it to the end of this function, after you have incremented tx_head.

    OK.

WBR, Sergei

