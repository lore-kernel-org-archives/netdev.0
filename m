From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] can: add Renesas R-Car CAN driver
Date: Sat, 02 Nov 2013 01:24:15 +0300
Message-ID: <52742A0F.7040707@cogentembedded.com>
References: <201310250303.00695.sergei.shtylyov@cogentembedded.com> <526AC65B.5020203@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org,
	mkl@pengutronix.de, linux-can@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <526AC65B.5020203@grandegger.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/25/2013 11:28 PM, Wolfgang Grandegger wrote:

>> Add support for the CAN controller found in Renesas R-Car SoCs.

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

[...]

>> Index: linux-can-next/drivers/net/can/rcar_can.c
>> ===================================================================
>> --- /dev/null
>> +++ linux-can-next/drivers/net/can/rcar_can.c
>> @@ -0,0 +1,920 @@
[...]
>> +static bool autorecovery;
>> +module_param(autorecovery, bool, 0644);
>> +MODULE_PARM_DESC(autorecovery, "Automatic hardware recovery from bus-off");

> Software recovery is the preferred solution. No need to support
> automatic recovery by the hardware.

    OK, removed it.

>> +/* Mailbox registers structure */
>> +struct rcar_can_mbox_regs {
>> +	u32 id;		/* IDE and RTR bits, SID and EID */
>> +	u8 stub;	/* Not used */
>> +	u8 dlc;		/* Data Length Code - bits [0..3] */
>> +	u8 data[8];	/* Data Bytes */
>> +	u8 tsh;		/* Time Stamp Higher Byte */
>> +	u8 tsl;		/* Time Stamp Lower Byte */

> I would add padding bytes here to ensure alignment.

    What padding? This is how the hardware registers are laid out. I think I 
should rather add __packed after }.

>> +};
>> +
>> +struct rcar_can_regs {
>> +	struct rcar_can_mbox_regs mb[N_MBX];
>> +};

> Where are the other registers? Using a mix of struct and #define offsets
> is really ugly.

    OK, fixed. I just thought using {read|write}[bwl]() doesn't buy us any 
type checking anyway, so was being lazy here.

>> +struct rcar_can_priv {
>> +	struct can_priv can;	/* Must be the first member! */
>> +	struct net_device *ndev;
>> +	struct napi_struct napi;
>> +	struct rcar_can_regs __iomem *regs;
>> +	struct clk *clk;
>> +	spinlock_t mier_lock;
>> +	u8 clock_select;
>> +	u8 ier;

> s/ier/ier_shadow/ ?

    I'd rather leave it as is... hoping you won't insist.

>> +};

>> +static void rcar_can_start(struct net_device *ndev);

> Forward declarations should be avoided.

    Removed it since it's not needed anymore.

>> +
>> +static void rcar_can_error(struct net_device *ndev)
>> +{
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	struct net_device_stats *stats = &ndev->stats;
>> +	struct can_frame *cf;
>> +	struct sk_buff *skb;
>> +	u8 eifr, txerr = 0, rxerr = 0;
>> +
>> +	/* Propagate the error condition to the CAN stack */
>> +	skb = alloc_can_err_skb(ndev, &cf);
>> +	if (!skb)
>> +		return;
>> +	eifr = rcar_can_readb(priv, RCAR_CAN_EIFR);
>> +	if (eifr & (EIFR_EWIF | EIFR_EPIF)) {
>> +		cf->can_id |= CAN_ERR_CRTL;
>> +		txerr = rcar_can_readb(priv, RCAR_CAN_TECR);
>> +		rxerr = rcar_can_readb(priv, RCAR_CAN_RECR);

> Could you please add these values to data[6..7] as shown here:

> http://lxr.free-electrons.com/source/drivers/net/can/sja1000/sja1000.c#L475

    OK.

>> +	}
>> +	if (eifr & EIFR_BEIF) {
>> +		int rx_errors = 0, tx_errors = 0;
>> +		u8 ecsr;
>> +
>> +		if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT)
>> +			tx_failure_cleanup(ndev);
>> +		netdev_dbg(priv->ndev, "Bus error interrupt:\n");
>> +		cf->can_id |= CAN_ERR_BUSERROR | CAN_ERR_PROT;
>> +		cf->data[2] = CAN_ERR_PROT_UNSPEC;
>> +
>> +		ecsr = rcar_can_readb(priv, RCAR_CAN_ECSR);
>> +		if (ecsr & ECSR_ADEF) {
>> +			netdev_dbg(priv->ndev, "ACK Delimiter Error\n");
>> +			cf->data[3] |= CAN_ERR_PROT_LOC_ACK_DEL;
>> +			tx_errors++;
>> +			rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_ADEF);

> Please avoid casts here and below.

    These casts help avoid compiler warnings.

[...]
>> +	if (eifr & EIFR_BORIF) {
>> +		netdev_dbg(priv->ndev, "Bus-off recovery interrupt\n");
>> +		priv->can.state = CAN_STATE_ERROR_ACTIVE;
>> +		cf->can_id |= CAN_ERR_RESTARTED;

> Does this interrupt come when Bus-off recovery has compeleted (back to
> error-active?) CAN_ERR_RESTARTED should be reported when the bus-off
> recovery has been triggered. It takes some time before it is really
> completed.

    Removed the handler.

>> +	if (eifr & EIFR_OLIF) {
>> +		netdev_dbg(priv->ndev,
>> +			   "Overload Frame Transmission error interrupt\n");
>> +		cf->can_id |= CAN_ERR_PROT;
>> +		cf->data[2] |= CAN_ERR_PROT_OVERLOAD;
>> +		ndev->stats.rx_over_errors++;
>> +		ndev->stats.rx_errors++;
>> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_OLIF);

> No unnecessary casts please.

    Unfortunately, they are necessary.

[...]
>> +static irqreturn_t rcar_can_interrupt(int irq, void *dev_id)
>> +{
>> +	struct net_device *ndev = (struct net_device *)dev_id;
>> +	struct rcar_can_priv *priv = netdev_priv(ndev);
>> +	struct net_device_stats *stats = &ndev->stats;
>> +	u8 isr;
>> +
>> +	isr = rcar_can_readb(priv, RCAR_CAN_ISR);
>> +	if (!(isr & priv->ier))
>> +		return IRQ_NONE;
>> +
>> +	if (isr & ISR_ERSF)
>> +		rcar_can_error(ndev);
>> +
>> +	if (isr & ISR_TXMF) {
>> +		u32 ie_mask = 0;
>> +		int i;
>> +
>> +		/* Set Transmit Mailbox Search Mode */
>> +		rcar_can_writeb(priv, RCAR_CAN_MSMR, MSMR_TXMB);
>> +		for (i = 0; i < N_TX_MB; i++) {
>> +			u8 mctl, mbx;
>> +
>> +			mbx = rcar_can_readb(priv, RCAR_CAN_MSSR);
>> +			if (mbx & MSSR_SEST)
>> +				break;
>> +			mbx &= MSSR_MBNST;
>> +			stats->tx_bytes += readb(&priv->regs->mb[mbx].dlc);
>> +			stats->tx_packets++;
>> +			mctl = rcar_can_readb(priv, RCAR_CAN_MCTL(mbx));
>> +			/* Bits SENTDATA and TRMREQ cannot be
>> +			 * set to 0 simultaneously
>> +			 */
>> +			mctl &= ~MCTL_TRMREQ;
>> +			rcar_can_writeb(priv, RCAR_CAN_MCTL(mbx), mctl);
>> +			mctl &= ~MCTL_SENTDATA;
>> +			/* Clear interrupt */
>> +			rcar_can_writeb(priv, RCAR_CAN_MCTL(mbx), mctl);
>> +			ie_mask |= BIT(mbx - FIRST_TX_MB);
>> +			can_get_echo_skb(ndev, mbx - FIRST_TX_MB);
>> +			can_led_event(ndev, CAN_LED_EVENT_TX);
>> +		}
>> +		/* Set receive mailbox search mode */
>> +		rcar_can_writeb(priv, RCAR_CAN_MSMR, MSMR_RXMB);
>> +		/* Disable mailbox interrupt, mark mailbox as free */
>> +		if (ie_mask) {
>> +			u32 mier1;
>> +
>> +			spin_lock(&priv->mier_lock);
>> +			mier1 = rcar_can_readl(priv, RCAR_CAN_MIER1);
>> +			rcar_can_writel(priv, RCAR_CAN_MIER1, mier1 & ~ie_mask);
>> +			spin_unlock(&priv->mier_lock);
>> +			netif_wake_queue(ndev);
>> +		}
>> +	}

> Would be nice to have this in an (inline) function, like for the error
> handling above.

    OK, but I guess *inline* keyword is not necessary as gcc should figure it 
out itself, given only a single call.

[...]
>> +static int rcar_can_probe(struct platform_device *pdev)
>> +{
[...]
>> +	ndev->netdev_ops = &rcar_can_netdev_ops;
>> +	ndev->irq = irq;
>> +	ndev->flags |= IFF_ECHO;
>> +	priv->ndev = ndev;
>> +	priv->regs = (struct rcar_can_regs *)addr;

> Is this cast needed?

    Not really, removed it.

[...]

> Wolfgang.

WBR, Sergei

