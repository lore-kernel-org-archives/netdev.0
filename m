From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] WAN: Adding support for Infineon PEF2256 E1 chipset
 (FALC56)
Date: Sat, 2 Nov 2013 23:26:39 +0100
Message-ID: <20131102222639.GA17924@electric-eye.fr.zoreil.com>
References: <201311011501.rA1F1suj007279@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Grant Likely <grant.likely@linaro.org>,
	Krzysztof Halasa <khc@pm.waw.pl>, devicetree@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jerome.chantelauze.ext@c-s.fr
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201311011501.rA1F1suj007279@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christophe Leroy <christophe.leroy@c-s.fr> :
> The patch adds WAN support for Infineon FALC56 - PEF2256 E1 Chipset.
> 
> Signed-off-by: Jerome Chantelauze <jerome.chantelauze.ext@c-s.fr>
> Acked-by: Christophe Leroy <christophe.leroy@c-s.fr>
> 
> diff -urN a/drivers/net/wan/pef2256.c b/drivers/net/wan/pef2256.c
> --- a/drivers/net/wan/pef2256.c	1970-01-01 01:00:00.000000000 +0100
> +++ b/drivers/net/wan/pef2256.c	2013-10-13 13:05:01.000000000 +0200
[...]
> +static irqreturn_t pef2256_irq(int irq, void *dev_priv);
> +static int Config_HDLC(struct pef2256_dev_priv *priv);
> +static int init_FALC(struct pef2256_dev_priv *priv);
> +static int pef2256_open(struct net_device *netdev);
> +static int pef2256_close(struct net_device *netdev);

You should avoid mixed case function names.

You can reorder and remove the forward declarations: none of pef2256_irq,
Config_HDLC, init_FALC or pef2256_close exhibits any external dependency.
pef2256_open only needs the three former.

> +void print_regs(struct device *dev)
> +{
> +	struct net_device *ndev = dev_get_drvdata(dev);
> +	struct pef2256_dev_priv *priv = dev_to_hdlc(ndev)->priv;
> +	unsigned char *base_addr = priv->base_addr;
> +
> +	netdev_info(ndev, "	MODE = 0x%02x\n", readb(base_addr + MODE));
[...]
> +static DEVICE_ATTR(regs, S_IRUGO, fs_attr_regs_show, NULL);

It duplicates an existing API. See ETHTOOL_GREGS in net/core/ethtool.c.

[...]
> +static ssize_t fs_attr_mode_store(struct device *dev,
> +			struct device_attribute *attr,  const char *buf,
> +			size_t count)
> +{
> +	struct net_device *ndev = dev_get_drvdata(dev);
> +	struct pef2256_dev_priv *priv = dev_to_hdlc(ndev)->priv;
> +	long int value;
> +	int ret = kstrtol(buf, 10, &value);
> +	int reconfigure = (value != priv->mode);
> +
> +	if (value != MASTER_MODE && value != SLAVE_MODE)
> +		ret = -EINVAL;
> +
> +	if (ret < 0)
> +		netdev_info(ndev, "Invalid mode (0 or 1 expected\n");
> +	else {
> +		priv->mode = value;
> +		if (reconfigure && priv->init_done) {
> +			pef2256_close(ndev);
> +			init_FALC(priv);
> +			pef2256_open(ndev);

*ouch*

This code badly races with normal uses of ndev->{open / close}. You can't
do that.

You may split the pef2256_open function in several parts and share the
relevant one with the sysfs functions (assuming some extra mutex based
locking).

You want to update the hardware configuration. You don't need any software
data housekeeping and you don't want a complete close (free_irq, hdlc unreg,
etc.) / open cycle. It seems simple but most of time it's a pain to get the
error processing part right and once you get there one realizes that it
does a lot of useless work.

[...]
> +/* Setting up HDLC channel */
> +int Config_HDLC(struct pef2256_dev_priv *priv)

Missing 'static'.

> +{
> +	int i;

Excess scope.

> +	int TS_idx;
> +	unsigned char *base_addr;
> +	u8 dummy;
> +
> +	/* Set framer E1 address */
> +	base_addr = priv->base_addr;

Usually done in a single line:

	unsigned char *base_addr = priv->base_addr;

> +
> +	/* Read to remove pending IT */
> +	dummy = readb(base_addr + ISR0);
> +	dummy = readb(base_addr + ISR1);
> +
> +	/* Mask HDLC 1 Transmit IT */
> +	writeb(readb(base_addr + IMR1) | 1, base_addr + IMR1);
> +	writeb(readb(base_addr + IMR1) | (1 << 4), base_addr + IMR1);
> +	writeb(readb(base_addr + IMR1) | (1 << 5), base_addr + IMR1);

Two points:

1.
#define	IMR1		... (ok, you did it in the .h file)
#define	 IMR1_XDU	...
#define	 IMR1_ALLS	...

Please use more #define and remove the redundant part in the comments
(the "Receiver inactive", "CRC on", etc. is imho welcome though).

2.
You may consider adding a few functions / define

static u8 pef_r8(struct pef2256 *pp, u32 offset)
static void pef_w8(struct pef2256 *pp, u32 offset, u8 val)
static void pef_rwm8(struct pef2256 *pp, u32 offset, u8 val)

> +
> +	/* Mask HDLC 1 Receive IT */
> +	writeb(readb(base_addr + IMR0) | 1, base_addr + IMR0);
> +	writeb(readb(base_addr + IMR0) | (1 << 7), base_addr + IMR0);
> +	writeb(readb(base_addr + IMR1) | (1 << 6), base_addr + IMR1);
> +
> +	/* The hardware requires a delay up to 2*32*125 usec to take commands
> +	 * into account
> +	 */
> +	udelay((2 * 32) * 125);
> +
> +	/* MODE.HRAC = 0 (Receiver inactive)
> +	 * MODE.DIV = 0 (Data normal operation)
> +	 * for FALC V2.2 : MODE.HDLCI = 0 (normal operation)
> +	 * MODE.MDS2:0 = 100 (No address comparison)
> +	 * MODE.HRAC = 1 (Receiver active)
> +	 */
> +	writeb(1 << 3, base_addr + MODE);
> +	/* CCR1.EITS = 1 (Enable internal Time Slot 31:0 Signaling)
> +	 * CCR1.XMFA = 0 (No transmit multiframe alignment)
> +	 * CCR1.RFT1:0 = 00 (RFIFO is 32 bytes)
> +	 * setting up Interframe Time Fill
> +	 * CCR1.ITF = 1 (Interframe Time Fill Continuous flag)
> +	 */
> +	writeb(0x10 | (1 << 3), base_addr + CCR1);
> +	/* CCR2.XCRC = 0 (Transmit CRC ON)
> +	 * CCR2.RCRC = 0 (Receive CRC ON, no write in RFIFO)
> +	 * CCR2.RADD = 0 (No write address in RFIFO)
> +	 */
> +	writeb(0x00, base_addr + CCR2);
> +
> +	/* The hardware requires a delay up to 2*32*125 usec to take commands
> +	 * into account
> +	 */
> +	udelay((2 * 32) * 125);
> +
> +	/* MODE.HRAC = 0 (Receiver inactive)
> +	 * MODE.DIV = 0 (Data normal operation)
> +	 * for FALC V2.2 : MODE.HDLCI = 0 (normal operation)
> +	 * MODE.MDS2:0 = 100 (No address comparison)
> +	 * MODE.HRAC = 1 (Receiver active)
> +	 */
> +	writeb(1 << 3, base_addr + MODE);
> +	/* CCR1.EITS = 1 (Enable internal Time Slot 31:0 Signaling)
> +	 * CCR1.XMFA = 0 (No transmit multiframe alignment)
> +	 * CCR1.RFT1:0 = 00 (RFIFO is 32 bytes)
> +	 * setting up Interframe Time Fill
> +	 * CCR1.ITF = 1 (Interframe Time Fill Continuous flag)
> +	 */
> +	writeb(0x10 | (1 << 3), base_addr + CCR1);
> +	/* CCR2.XCRC = 0 (Transmit CRC ON)
> +	 * CCR2.RCRC = 0 (Receive CRC ON, no write in RFIFO)
> +	 * CCR2.RADD = 0 (No write address in RFIFO)
> +	 */
> +	writeb(0x00, base_addr + CCR2);
> +
> +	/* The hardware requires a delay up to 2*32*125 usec to take commands
> +	 * into account
> +	 */
> +	udelay((2 * 32) * 125);
> +
> +	/* MODE.HRAC = 0 (Receiver inactive)
> +	 * MODE.DIV = 0 (Data normal operation)
> +	 * for FALC V2.2 : MODE.HDLCI = 0 (normal operation)
> +	 * MODE.MDS2:0 = 100 (No address comparison)
> +	 * MODE.HRAC = 1 (Receiver active)
> +	 */
> +	writeb(1 << 3, base_addr + MODE);
> +	/* CCR1.EITS = 1 (Enable internal Time Slot 31:0 Signaling)
> +	 * CCR1.XMFA = 0 (No transmit multiframe alignment)
> +	 * CCR1.RFT1:0 = 00 (RFIFO is 32 bytes)
> +	 * setting up Interframe Time Fill
> +	 * CCR1.ITF = 1 (Interframe Time Fill Continuous flag)
> +	 */
> +	writeb(0x10 | (1 << 3), base_addr + CCR1);
> +	/* CCR2.XCRC = 0 (Transmit CRC ON)
> +	 * CCR2.RCRC = 0 (Receive CRC ON, no write in RFIFO)
> +	 * CCR2.RADD = 0 (No write address in RFIFO)
> +	 */
> +	writeb(0x00, base_addr + CCR2);
> +
> +	/* The hardware requires a delay up to 2*32*125 usec to take commands
> +	 * into account
> +	 */
> +	udelay((2 * 32) * 125);
> +
> +	/* Init  Time Slot select */
> +	writeb(0x00, base_addr + TTR1);
> +	writeb(0x00, base_addr + TTR2);
> +	writeb(0x00, base_addr + TTR3);
> +	writeb(0x00, base_addr + TTR4);
> +	writeb(0x00, base_addr + RTR1);
> +	writeb(0x00, base_addr + RTR2);
> +	writeb(0x00, base_addr + RTR3);
> +	writeb(0x00, base_addr + RTR4);
> +	/* Set selected TS bits */
> +	/* Starting at TS 1, TS 0 is reserved */
> +	for (TS_idx = 1; TS_idx < 32; TS_idx++) {
> +		i = 7 - (TS_idx % 8);
> +		switch (TS_idx / 8) {
> +		case 0:
> +			if (priv->Tx_TS & (1 << (31 - TS_idx)))
> +				writeb(readb(base_addr + TTR1) | (1 << i),
> +					base_addr + TTR1);
> +			if (priv->Rx_TS & (1 << (31 - TS_idx)))
> +				writeb(readb(base_addr + RTR1) | (1 << i),
> +					base_addr + RTR1);
> +			break;
> +		case 1:
> +			if (priv->Tx_TS & (1 << (31 - TS_idx)))
> +				writeb(readb(base_addr + TTR2) | (1 << i),
> +					base_addr + TTR2);
> +			if (priv->Rx_TS & (1 << (31 - TS_idx)))
> +				writeb(readb(base_addr + RTR2) | (1 << i),
> +					base_addr + RTR2);
> +			break;
> +		case 2:
> +			if (priv->Tx_TS & (1 << (31 - TS_idx)))
> +				writeb(readb(base_addr + TTR3) | (1 << i),
> +					base_addr + TTR3);
> +			if (priv->Rx_TS & (1 << (31 - TS_idx)))
> +				writeb(readb(base_addr + RTR3) | (1 << i),
> +					base_addr + RTR3);
> +			break;
> +		case 3:
> +			if (priv->Tx_TS & (1 << (31 - TS_idx)))
> +				writeb(readb(base_addr + TTR4) | (1 << i),
> +					base_addr + TTR4);
> +			if (priv->Rx_TS & (1 << (31 - TS_idx)))
> +				writeb(readb(base_addr + RTR4) | (1 << i),
> +					base_addr + RTR4);
> +			break;

May I suggest some slightly less yank pasted code ?

	for (i = 1; i < 32; i++)
		config_hdlc_timeslot(struct pef2256_dev_priv *priv, i);
		
static void config_hdlc_timeslot(struct pef2256_dev_priv *priv, int ts)
{
	static struct {
		u32 ttr;
		u32 rtr;
	} regs [] = {
		{ TTR1, RTR1},
		{ TTR2, RTR2},
		{ TTR3, RTR3},
		{ TTR4, RTR4}
	};
	int cfg_bit = 1 << (31 - ts);
	int reg_bit = 1 << (7 - (ts % 8));
	int j = ts / 8;

	if (j >= 4)
		return;

	if (priv->Tx_TS & cfg_bit)
		writeb(readb(base_addr + regs[j].ttr) | reg_bit,
		       base_addr + regs[j].ttr);

	if (priv->Rx_TS & cfg_bit)
		writeb(readb(base_addr + regs[j].rtr) | reg_bit,
		       base_addr + regs[j].rtr);
}

It should reduce to single line statements once you introduce the
relevant readb / writeb helpers.

> +		}
> +	}
> +
> +	/* The hardware requires a delay up to 2*32*125 usec to take commands
> +	 * into account
> +	 */
> +	udelay((2 * 32) * 125);

#define FALC_HW_CMD_DELAY_US ...

(it appears several times and you will save a comment)

> +
> +	/* Unmask HDLC 1 Transmit IT */
> +	writeb(readb(base_addr + IMR1) & ~1, base_addr + IMR1);
> +	writeb(readb(base_addr + IMR1) & ~(1 << 4), base_addr + IMR1);
> +	writeb(readb(base_addr + IMR1) & ~(1 << 5), base_addr + IMR1);
> +
> +	/* Unmask HDLC 1 Receive IT */
> +	writeb(readb(base_addr + IMR0) & ~1, base_addr + IMR0);
> +	writeb(readb(base_addr + IMR0) & ~(1 << 7), base_addr + IMR0);
> +	writeb(readb(base_addr + IMR1) & ~(1 << 6), base_addr + IMR1);
> +
> +	/* The hardware requires a delay up to 2*32*125 usec to take commands
> +	 * into account
> +	 */

Bis repetita.

> +	udelay((2 * 32) * 125);

(I assume the device won't ever be behind a write posting bus so there is
no point in flushing write before the udelay)

> +
> +	return 0;
> +}
> +
> +
> +/* Init FALC56 */

Useless comment.

> +static int init_FALC(struct pef2256_dev_priv *priv)

Why does it return anything ? It always return 0.

> +{
> +	unsigned char *base_addr;

	unsigned char __iomem *base_addr = priv->base_addr;

> +	int Version;

No caps.

[...]
> +	/* channel phase for FALC56 */
> +	if ((priv->channel_phase == CHANNEL_PHASE_1)
> +		|| (priv->channel_phase == CHANNEL_PHASE_3))

|| should stay at the end of the previous line

You don't all-tabs indent: you use the required tabs, then spaces, so
that the code lines up nicely. For instance:

	if ((priv->channel_phase == CHANNEL_PHASE_1) ||
	    (priv->channel_phase == CHANNEL_PHASE_3))

(you can remove the excess parenthesis btw)

[...]
> +static int pef2256_open(struct net_device *netdev)
> +{
> +	struct pef2256_dev_priv *priv = dev_to_hdlc(netdev)->priv;
> +	unsigned char *base_addr = priv->base_addr;
> +	int ret;
> +
> +	if (hdlc_open(netdev))
> +		return -EAGAIN;

hdlc_open status code should be propagated:

	rc = hdlc_open(netdev);
	if (rc < 0)
		goto out;

> +
> +	ret = request_irq(priv->irq, pef2256_irq, 0, "e1-wan", priv);
> +	if (ret) {
> +		dev_err(priv->dev, "Cannot request irq. Device seems busy.\n");
> +		return -EBUSY;

Leak.
		goto err_hdlc_close;

> +	}
> +
> +	if (priv->component_id != VERSION_UNDEF) {
> +		ret = init_FALC(priv);

Actually init_FALC never fails.

> +	} else {
> +		dev_err(priv->dev, "Composant ident (%X/%X) = %d\n",
> +			readb(base_addr + VSTR), readb(base_addr + WID),
> +				priv->component_id);
> +		ret = -ENODEV;

Please unbalance and move the priv->component_id == VERSION_UNDEF test
to the start of the function.

> +	}
> +
> +	if (ret < 0)
> +		return ret;

Leak.

> +
> +	priv->tx_skb = NULL;
> +	priv->rx_len = 0;
> +
> +	Config_HDLC(priv);
> +
> +	netif_carrier_on(netdev);

Nit: I am a bit surprized that the driver does not seem to detect signal
losses.

> +	netif_start_queue(netdev);
> +
> +	priv->init_done = 1;

Why don't you rely on the net_device up / down state ?

[...]
> +static int pef2256_rx(struct pef2256_dev_priv *priv)

The error status is never checked.

> +{
> +	struct sk_buff *skb;
> +	int idx, size;

Please reduce the scope of 'skb' and 'size'.

> +	unsigned char *base_addr;
> +
> +	base_addr = priv->base_addr;

(see above)

> +
> +	/* RDO has been received -> wait for RME */
> +	if (priv->rx_len == -1) {
> +		/* Acknowledge the FIFO */
> +		writeb(readb(base_addr + CMDR) | (1 << 7), base_addr + CMDR);
> +
> +		if (priv->R_ISR0 & (1 << 7))
> +			priv->rx_len = 0;
> +
> +		return 0;
> +	}
> +
> +	/* RPF : a block is available in the receive FIFO */
> +	if (priv->R_ISR0 & 1) {

More #define please.

> +		for (idx = 0; idx < 32; idx++)
> +			priv->rx_buff[priv->rx_len + idx] =
> +				readb(base_addr + RFIFO + (idx & 1));
> +
> +		/* Acknowledge the FIFO */
> +		writeb(readb(base_addr + CMDR) | (1 << 7), base_addr + CMDR);
> +
> +		priv->rx_len += 32;
> +	}
> +
> +	/* RME : Message end : Read the receive FIFO */
> +	if (priv->R_ISR0 & (1 << 7)) {

More #define please.

> +		/* Get size of last block */
> +		size = readb(base_addr + RBCL) & 0x1F;
> +
> +		/* Read last block */
> +		for (idx = 0; idx < size; idx++)
> +			priv->rx_buff[priv->rx_len + idx] =
> +				readb(base_addr + RFIFO + (idx & 1));
> +
> +		/* Acknowledge the FIFO */
> +		writeb(readb(base_addr + CMDR) | (1 << 7), base_addr + CMDR);

static void pef2256_fifo_ack(...)

> +
> +		priv->rx_len += size;
> +
> +		/* Packet received */
> +		if (priv->rx_len > 0) {

Please add a local priv->netdev->stats variable.

[...]
> +static int pef2256_tx(struct pef2256_dev_priv *priv)
> +{
> +	int idx, size;
> +	unsigned char *base_addr;
> +	u8 *tx_buff = priv->tx_skb->data;
> +
> +	base_addr = priv->base_addr;
> +
> +	/* ALLS : transmit all done */
> +	if (priv->R_ISR1 & (1 << 5)) {
> +		priv->netdev->stats.tx_packets++;
> +		priv->netdev->stats.tx_bytes += priv->tx_skb->len;
> +		/* dev_kfree_skb(priv->tx_skb); */

Please remove.

> +		priv->tx_skb = NULL;
> +		priv->tx_len = 0;
> +		netif_wake_queue(priv->netdev);
> +	}
> +	/* XPR : write a new block in transmit FIFO */
> +	else if (priv->tx_len < priv->tx_skb->len) {

	} else ...

> +		size = priv->tx_skb->len - priv->tx_len;
> +		if (size > 32)
> +			size = 32;
> +
> +		for (idx = 0; idx < size; idx++)
> +			writeb(tx_buff[priv->tx_len + idx],
> +				base_addr + XFIFO + (idx & 1));
> +
> +		priv->tx_len += size;
> +
> +		if (priv->tx_len == priv->tx_skb->len)
> +			writeb(readb(base_addr + CMDR) | ((1 << 3) | (1 << 1)),
> +				base_addr + CMDR);
> +		else
> +			writeb(readb(base_addr + CMDR) | (1 << 3),
> +				base_addr + CMDR);

Please add more #define for the bits and use a single writeb(readb(...
statement with some "u8 mask" variable

> +	}
> +
> +	return 0;
> +}
> +
> +
> +irqreturn_t pef2256_irq(int irq, void *dev_priv)

static

> +{
> +	struct pef2256_dev_priv *priv = (struct pef2256_dev_priv *)dev_priv;
> +	unsigned char *base_addr;
> +	u8 R_GIS;

No caps.

> +
> +	base_addr = priv->base_addr;
> +	R_GIS = readb(base_addr + GIS);
> +
> +	priv->R_ISR0 = priv->R_ISR1 = 0;
> +
> +	/* We only care about ISR0 and ISR1 */
> +	/* ISR0 */
> +	if (R_GIS & 1)
> +		priv->R_ISR0 =
> +			readb(base_addr + ISR0) & ~(readb(base_addr + IMR0));
> +
> +	/* ISR1 */
> +	if (R_GIS & (1 << 1))
> +		priv->R_ISR1 =
> +			readb(base_addr + ISR1) & ~(readb(base_addr + IMR1));
> +
> +	/* Don't do anything else before init is done */
> +	if (!priv->init_done)
> +		return IRQ_HANDLED;

Gross (and probably SMP unsafe, etc.).

The driver doesn't request an IRQF_SHARED handler. This hack should not be
needed if the driver properly disables the device before registering the
irq handler.

> +
> +	/* RDO : Receive data overflow -> RX error */
> +	if (priv->R_ISR1 & (1 << 6)) {
> +		/* Acknowledge the FIFO */
> +		writeb(readb(base_addr + CMDR) | (1 << 7), base_addr + CMDR);
> +		priv->netdev->stats.rx_errors++;
> +		/* RME received ? */
> +		if (priv->R_ISR0 & (1 << 7))
> +			priv->rx_len = 0;
> +		else
> +			priv->rx_len = -1;
> +		return IRQ_HANDLED;
> +	}
> +
> +	/* XDU : Transmit data underrun -> TX error */
> +	if (priv->R_ISR1 & (1 << 4)) {
> +		priv->netdev->stats.tx_errors++;
> +		/* dev_kfree_skb(priv->tx_skb); */

Please remove.

> +		priv->tx_skb = NULL;
> +		netif_wake_queue(priv->netdev);
> +		return IRQ_HANDLED;
> +	}

Is it impossible to be notified of both RDO and XDU at the same time ?

[...]
> +/* Loading module */
> +static int pef2256_probe(struct platform_device *pdev)

Useless comment.

> +{
[...]
> +	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
> +	if (!priv)
> +		return ret;
[...]
> +	priv->irq = platform_get_irq(pdev, 0);
> +	if (!priv->irq) {
> +		dev_err(priv->dev, "no irq defined\n");
> +		return -EINVAL;

Leak.

[...]
> +	priv->init_done = 0;

priv comes from kzalloc. init_done is already 0.

[...]
> diff -urN a/drivers/net/wan/pef2256.h b/drivers/net/wan/pef2256.h
> --- a/drivers/net/wan/pef2256.h	1970-01-01 01:00:00.000000000 +0100
> +++ b/drivers/net/wan/pef2256.h	2013-10-13 13:06:00.000000000 +0200
[...]
> +struct pef2256_dev_priv {
> +	struct sk_buff *tx_skb;
> +	u16 tx_len;
> +	struct device *dev;
> +
> +	int init_done;
> +
> +	unsigned char *base_addr;

It should be __iomem annotated.

It may be void *

Nit: I'd welcome a different name - 'ioaddr' or such - as base_addr is
already (ab)used in struct net_device.

-- 
Ueimor
