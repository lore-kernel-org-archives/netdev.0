From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v2 4/7] [PATCH 4/8] can: Driver for the SJA1000 CAN
 controller
Date: Wed, 13 May 2009 15:52:05 -0600
Message-ID: <20090513155205.4bf06c25@bike.lwn.net>
References: <20090512092757.048938233@denx.de>
	<20090512092757.756749047@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vena.lwn.net ([206.168.112.25]:60598 "EHLO vena.lwn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752280AbZEMVwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 17:52:06 -0400
In-Reply-To: <20090512092757.756749047@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Quick drive-by review continues...]

> +
> +static int sja1000_probe_chip(struct net_device *dev)
> +{
> +	struct sja1000_priv *priv = netdev_priv(dev);

Looking down toward the bottom, I see:

> +struct sja1000_priv {
> +	struct can_priv can;

So you're still using the "put the higher-level structure at the top so we
can treat it like either kind of pointer" trick.  I'd still recommend
against that.  Far better to do something like:

	struct can_priv *canpriv = netdev_priv(dev);
	struct sja_1000_priv *priv = container_of(canpriv, struct sja_1000_priv, can);

Of course, you can put that dance into a helper function.

> +	if (dev->base_addr && (priv->read_reg(dev, 0) == 0xFF)) {
> +		printk(KERN_INFO "%s: probing @0x%lX failed\n",
> +		       DRV_NAME, dev->base_addr);
> +		return 0;
> +	}
> +	return 1;
> +}

So zero is an error return?  That's contrary to usual practice.

> +static int set_reset_mode(struct net_device *dev)
> +{
> +	struct sja1000_priv *priv = netdev_priv(dev);
> +	unsigned char status = priv->read_reg(dev, REG_MOD);
> +	int i;
> +
> +	/* disable interrupts */
> +	priv->write_reg(dev, REG_IER, IRQ_OFF);
> +
> +	for (i = 0; i < 100; i++) {
> +		/* check reset bit */
> +		if (status & MOD_RM) {
> +			priv->can.state = CAN_STATE_STOPPED;
> +			return 0;
> +		}
> +
> +		priv->write_reg(dev, REG_MOD, MOD_RM);	/* reset chip */
> +		status = priv->read_reg(dev, REG_MOD);
> +		udelay(10);

Wouldn't you want to read the new state *after* the delay?

> +	}
> +
> +	dev_err(dev->dev.parent, "setting SJA1000 into reset mode failed!\n");
> +	return 1;
> +
> +}
> +
> +static int set_normal_mode(struct net_device *dev)
> +{
> +	struct sja1000_priv *priv = netdev_priv(dev);
> +	unsigned char status = priv->read_reg(dev, REG_MOD);
> +	int i;
> +
> +	for (i = 0; i < 100; i++) {
> +		/* check reset bit */
> +		if ((status & MOD_RM) == 0) {
> +			priv->can.state = CAN_STATE_ERROR_ACTIVE;
> +			/* enable all interrupts */
> +			priv->write_reg(dev, REG_IER, IRQ_ALL);
> +
> +			return 0;
> +		}
> +
> +		/* set chip to normal mode */
> +		priv->write_reg(dev, REG_MOD, 0x00);
> +		status = priv->read_reg(dev, REG_MOD);
> +		udelay(10);

Here too?

> +	}
> +
> +	dev_err(dev->dev.parent, "setting SJA1000 into normal mode failed!\n");
> +	return 1;
> +
> +}
> +

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
> +		if (isrc & IRQ_WUI)
> +			dev_warn(dev->dev.parent, "wakeup interrupt\n");

How many of these might you get?  Should this be rate limited?

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
> +		dev_dbg(dev->dev.parent, "%d messages handled in ISR", n);
> +
> +	return (n) ? IRQ_HANDLED : IRQ_NONE;
> +}
> +EXPORT_SYMBOL_GPL(sja1000_interrupt);
> +
> +static int sja1000_open(struct net_device *dev)
> +{
> +	struct sja1000_priv *priv = netdev_priv(dev);
> +	int err;
> +
> +	/* set chip into reset mode */
> +	set_reset_mode(dev);
> +
> +	/* common open */
> +	err = open_candev(dev);
> +	if (err)
> +		return err;
> +
> +	/* register interrupt handler, if not done by the device driver */
> +	if (!(priv->flags & SJA1000_CUSTOM_IRQ_HANDLER)) {
> +		err = request_irq(dev->irq, &sja1000_interrupt, IRQF_SHARED,
> +				  dev->name, (void *)dev);
> +		if (err)
> +			return -EAGAIN;

If you return here you fail, but you've not undone open_candev().  Looking
there, it seems no harm will be done - until somebody changes open_candev()
someday. 

> +	}
> +
> +	/* init and start chi */
> +	sja1000_start(dev);
> +	priv->open_time = jiffies;
> +
> +	netif_start_queue(dev);
> +
> +	return 0;
> +}
> +

[...]

> +/*
> + * SJA1000 private data structure
> + */
> +struct sja1000_priv {
> +	struct can_priv can;
> +	long open_time;
> +	struct sk_buff *echo_skb;
> +
> +	u8 (*read_reg) (const struct net_device *dev, int reg);
> +	void (*write_reg) (const struct net_device *dev, int reg, u8 val);
> +	void (*pre_irq) (const struct net_device *dev);
> +	void (*post_irq) (const struct net_device *dev);

What are the locking rules for functions like ->read_reg() now?  Entirely
up to the lower level?  Would be good to document that near the structure
definition. 

> +
> +	void *priv;		/* for board-specific data */
> +	struct net_device *dev;
> +
> +	u8 ocr;
> +	u8 cdr;
> +	u32 flags;

The meaning of these fields is not exactly clear.

> +};

jon
