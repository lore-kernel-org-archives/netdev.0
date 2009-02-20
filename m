From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 4/8] can: Driver for the SJA1000 CAN controller
Date: Thu, 19 Feb 2009 17:14:40 -0700
Message-ID: <20090219171440.0c8286a1@bike.lwn.net>
References: <1235070082-7069-1-git-send-email-wg@grandegger.com>
	<1235070082-7069-2-git-send-email-wg@grandegger.com>
	<1235070082-7069-3-git-send-email-wg@grandegger.com>
	<1235070082-7069-4-git-send-email-wg@grandegger.com>
	<1235070082-7069-5-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vena.lwn.net ([206.168.112.25]:52605 "EHLO vena.lwn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755803AbZBTAOm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 19:14:42 -0500
In-Reply-To: <1235070082-7069-5-git-send-email-wg@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I won't be able to look at all of these...

> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index d609895..78a412b 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -35,6 +35,17 @@ config CAN_CALC_BITTIMING
>  	  files "tq", "prop_seg", "phase_seg1", "phase_seg2" and "sjw".
>  	  If unsure, say Y.
>  
> +config CAN_SJA1000
> +	depends on CAN_DEV
> +	tristate "Philips SJA1000"
> +	---help---
> +	  The SJA1000 is one of the top CAN controllers out there. As it
> +	  has a multiplexed interface it fits directly to 8051
> +	  microcontrollers or into the PC I/O port space. The SJA1000
> +	  is a full CAN controller, with shadow registers for RX and TX.
> +	  It can send and receive any kinds of CAN frames (SFF/EFF/RTR)
> +	  with a single (simple) filter setup.

This sounds more like advertising text.  But what people need to know is
whether they should enable it or not.

[...]

> diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
> new file mode 100644
> index 0000000..6fe516d
> --- /dev/null
> +++ b/drivers/net/can/sja1000/sja1000.c
> @@ -0,0 +1,681 @@

[...]

> +static void sja1000_start(struct net_device *dev)
> +{
> +	struct sja1000_priv *priv = netdev_priv(dev);
> +
> +	/* leave reset mode */
> +	if (priv->can.state != CAN_STATE_STOPPED)
> +		set_reset_mode(dev);
> +
> +	/* Clear error counters and error code capture */
> +	priv->write_reg(dev, REG_TXERR, 0x0);
> +	priv->write_reg(dev, REG_RXERR, 0x0);
> +	priv->read_reg(dev, REG_ECC);
> +
> +	/* leave reset mode */
> +	set_normal_mode(dev);
> +}

It's about here that I begin to wonder about locking again.  What is
preventing concurrent access to the device?

[...]

> +static int sja1000_get_state(struct net_device *dev, enum can_state *state)
> +{
> +	struct sja1000_priv *priv = netdev_priv(dev);
> +	u8 status;
> +
> +	/* FIXME: inspecting the status register to get the current state
> +	 * is not really necessary, because state changes are handled by
> +	 * in the ISR and the variable priv->can.state gets updated. The
> +	 * CAN devicde interface needs fixing!
> +	 */
> +
> +	spin_lock_irq(&priv->can.irq_lock);

Interesting, here we do have a lock.  What is it protecting?  *state??  It
can't be the device registers, since they are accessed without locks in
many other places.

> +	if (priv->can.state == CAN_STATE_STOPPED) {
> +		*state =  CAN_STATE_STOPPED;
> +	} else {
> +		status = priv->read_reg(dev, REG_SR);
> +		if (status & SR_BS)
> +			*state = CAN_STATE_BUS_OFF;
> +		else if (status & SR_ES) {
> +			if (priv->read_reg(dev, REG_TXERR) > 127 ||
> +			    priv->read_reg(dev, REG_RXERR) > 127)
> +				*state = CAN_STATE_BUS_PASSIVE;
> +			else
> +				*state = CAN_STATE_BUS_WARNING;
> +		} else
> +			*state = CAN_STATE_ACTIVE;
> +	}
> +	/* Check state */
> +	if (*state != priv->can.state)
> +		dev_err(ND2D(dev),
> +			"Oops, state mismatch: hard %d != soft %d\n",
> +			*state, priv->can.state);
> +	spin_unlock_irq(&priv->can.irq_lock);
> +	return 0;
> +}

[...]

> +/*
> + * transmit a CAN message
> + * message layout in the sk_buff should be like this:
> + * xx xx xx xx	 ff	 ll   00 11 22 33 44 55 66 77
> + * [  can-id ] [flags] [len] [can data (up to 8 bytes]
> + */
> +static int sja1000_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct sja1000_priv *priv = netdev_priv(dev);
> +	struct net_device_stats *stats = &dev->stats;
> +	struct can_frame *cf = (struct can_frame *)skb->data;
> +	uint8_t fi;
> +	uint8_t dlc;
> +	canid_t id;
> +	uint8_t dreg;
> +	int i;
> +
> +	netif_stop_queue(dev);
> +
> +	fi = dlc = cf->can_dlc;
> +	id = cf->can_id;
> +
> +	if (id & CAN_RTR_FLAG)
> +		fi |= FI_RTR;
> +
> +	if (id & CAN_EFF_FLAG) {
> +		fi |= FI_FF;
> +		dreg = EFF_BUF;
> +		priv->write_reg(dev, REG_FI, fi);
> +		priv->write_reg(dev, REG_ID1, (id & 0x1fe00000) >> (5 + 16));
> +		priv->write_reg(dev, REG_ID2, (id & 0x001fe000) >> (5 + 8));
> +		priv->write_reg(dev, REG_ID3, (id & 0x00001fe0) >> 5);
> +		priv->write_reg(dev, REG_ID4, (id & 0x0000001f) << 3);
> +	} else {
> +		dreg = SFF_BUF;
> +		priv->write_reg(dev, REG_FI, fi);
> +		priv->write_reg(dev, REG_ID1, (id & 0x000007f8) >> 3);
> +		priv->write_reg(dev, REG_ID2, (id & 0x00000007) << 5);
> +	}
> +
> +	for (i = 0; i < dlc; i++)
> +		priv->write_reg(dev, dreg++, cf->data[i]);
> +
> +	stats->tx_bytes += dlc;
> +	dev->trans_start = jiffies;
> +
> +	can_put_echo_skb(skb, dev, 0);

Hmm...looking back at can_put_echo_skb(), I see that it expects dev->priv
to point to a struct can_priv.  Here, though, we see it pointing to a
struct sja1000_prive instead.  I begin to suspect dangerous trickery going
on behind our backs...

> +
> +	priv->write_reg(dev, REG_CMR, CMD_TR);
> +
> +	return 0;
> +}

[...]

> +irqreturn_t sja1000_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *dev = (struct net_device *)dev_id;
> +	struct sja1000_priv *priv = netdev_priv(dev);
> +	struct net_device_stats *stats = &dev->stats;
> +	uint8_t isrc, status;
> +	int n = 0;
> +
> +	/* Shared interrupts and IRQ off? */
> +	if (priv->read_reg(dev, REG_IER) == IRQ_OFF)
> +		return IRQ_NONE;
> +
> +	if (priv->pre_irq)
> +		priv->pre_irq(dev);
> +
> +	while ((isrc = priv->read_reg(dev, REG_IR)) && (n < SJA1000_MAX_IRQ)) {
> +		n++;
> +		status = priv->read_reg(dev, REG_SR);
> +
> +		if (isrc & IRQ_WUI) {
> +			/* wake-up interrupt */
> +			priv->can.can_stats.wakeup++;
> +		}
> +		if (isrc & IRQ_TI) {
> +			/* transmission complete interrupt */
> +			stats->tx_packets++;
> +			can_get_echo_skb(dev, 0);
> +			netif_wake_queue(dev);
> +		}
> +		if (isrc & IRQ_RI) {
> +			/* receive interrupt */
> +			while (status & SR_RBS) {
> +				sja1000_rx(dev);
> +				status = priv->read_reg(dev, REG_SR);
> +			}
> +		}
> +		if (isrc & (IRQ_DOI | IRQ_EI | IRQ_BEI | IRQ_EPI | IRQ_ALI)) {
> +			/* error interrupt */
> +			if (sja1000_err(dev, isrc, status))
> +				break;
> +		}
> +	}
> +
> +	if (priv->post_irq)
> +		priv->post_irq(dev);
> +
> +	if (n >= SJA1000_MAX_IRQ)
> +		dev_dbg(ND2D(dev), "%d messages handled in ISR", n);
> +
> +	return (n) ? IRQ_HANDLED : IRQ_NONE;
> +}
> +EXPORT_SYMBOL_GPL(sja1000_interrupt);

You used spin_lock_irq(&irq_lock) above, but the interrupt handler doesn't
take that lock?  So (above) you could acquire the lock while the interrupt
handler is running?  I hate to keep asking this question, but...what does
that lock protect?

[...]

> +static int sja1000_close(struct net_device *dev)
> +{
> +	struct sja1000_priv *priv = netdev_priv(dev);
> +
> +	set_reset_mode(dev);
> +	netif_stop_queue(dev);
> +	priv->open_time = 0;
> +	can_close_cleanup(dev);

What happens if your device interrupts right here?  Maybe you should
disconnect the handler earlier?

> +	if (!(priv->flags & SJA1000_CUSTOM_IRQ_HANDLER))
> +		free_irq(dev->irq, (void *)dev);
> +
> +	return 0;
> +}

[...]

> +int register_sja1000dev(struct net_device *dev)
> +{
> +	struct sja1000_priv *priv = netdev_priv(dev);
> +	int err;
> +
> +	if (!sja1000_probe_chip(dev))
> +		return -ENODEV;
> +
> +	dev->flags |= IFF_ECHO;	/* we support local echo */
> +
> +	dev->netdev_ops = &sja1000_netdev_ops;
> +
> +	priv->can.bittiming_const = &sja1000_bittiming_const;
> +	priv->can.do_set_bittiming = sja1000_set_bittiming;
> +	priv->can.do_get_state = sja1000_get_state;
> +	priv->can.do_set_mode = sja1000_set_mode;
> +	priv->dev = dev;
> +
> +	err = register_candev(dev);

Here we've registered our device with the CAN and networking core...

> +	if (err) {
> +		printk(KERN_INFO
> +		       "%s: registering netdev failed\n", DRV_NAME);
> +		free_netdev(dev);
> +		return err;
> +	}
> +
> +	set_reset_mode(dev);
> +	chipset_init(dev);

...but only here have we gotten it ready to operate.  If the higher levels
decide to do something with your device in the mean time, will the right
thing happen?

> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(register_sja1000dev);

[...]

> diff --git a/drivers/net/can/sja1000/sja1000.h b/drivers/net/can/sja1000/sja1000.h
> new file mode 100644
> index 0000000..60d4cd6
> --- /dev/null
> +++ b/drivers/net/can/sja1000/sja1000.h

[...]

> +/*
> + * SJA1000 private data structure
> + */
> +struct sja1000_priv {
> +	struct can_priv can;	/* must be the first member! */

AHA!  I knew it!

This kind of pointer trickery is fragile and dangerous, please don't do
it.  Much better would be something like:

	dev->priv = &dev_specific_priv->can;

Then the higher layers know they have a proper struct can_priv pointer.
Then you can use container_of() at this level to get the outer structure
pointer.  Much more robust and in line with normal kernel coding idiom.

> +	long open_time;
> +	struct sk_buff *echo_skb;
> +
> +	u8 (*read_reg) (struct net_device *dev, int reg);
> +	void (*write_reg) (struct net_device *dev, int reg, u8 val);
> +	void (*pre_irq) (struct net_device *dev);
> +	void (*post_irq) (struct net_device *dev);
> +
> +	void *priv;		/* for board-specific data */
> +	struct net_device *dev;
> +
> +	u8 ocr;
> +	u8 cdr;
> +	u32 flags;
