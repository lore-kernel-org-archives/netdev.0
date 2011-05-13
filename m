From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 03/16] add driver for C64x+ ethernet driver
Date: Fri, 13 May 2011 16:30:18 +0100
Message-ID: <1305300618.2851.29.camel@bwh-desktop>
References: <1305144843-5058-1-git-send-email-msalter@redhat.com>
	 <1305144843-5058-2-git-send-email-msalter@redhat.com>
	 <1305144843-5058-3-git-send-email-msalter@redhat.com>
	 <1305144843-5058-4-git-send-email-msalter@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Mark Salter <msalter@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305144843-5058-4-git-send-email-msalter@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please send network drivers to netdev for review.

I haven't looked at this thoroughly, but I noticed a few things:

On Wed, 2011-05-11 at 16:13 -0400, Mark Salter wrote:
> From: Aurelien Jacquiot <a-jacquiot@ti.com>
> 
> This patch adds a network driver to support the ethernet interface found on
> several Texas Instruments C64X+ based System on Chips. In particular, this
> driver has been tested on the TMS320C6455, TMS320C6457, TMS320C6472, and
> TMS320C6474 parts.
[...]
> --- /dev/null
> +++ b/drivers/net/c6x_gemac.c
[...]
> +static int __init get_mac_addr_from_cmdline(char *str)
> +{
> +	const char *start = (const char *) str;
> +	const char *end;
> +	int count;
> +
> +	for (count = 0; count < 6; count++) {
> +		config.enetaddr[count] = _hex_strtoul(start, &end);
> +		if (end == start)
> +			return 0;
> +		if ((*end != ':') && (count != 5))
> +			return 0;
> +		start = end + 1;
> +	}
> +	return 1;
> +}
> +
> +__setup("emac_addr=", get_mac_addr_from_cmdline);
> +
> +static int __init set_emac_shared(char *str)
> +{
> +	emac_shared = 1;
> +	return 1;
> +}
> +
> +__setup("emac_shared", set_emac_shared);

These parameters should be provided by platform data.

> +/*
> + * Get the device statistic
> + */
> +static struct net_device_stats *emac_get_stats(struct net_device *dev)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +	unsigned int reg;
> +	unsigned int dummy;
> +	int i;
> +
> +	emac_set_stat(dev->stats.multicast,	    EMAC_RXMCASTFRAMES);
> +	emac_set_stat(dev->stats.collisions,	    EMAC_TXCOLLISION);
> +	emac_set_stat(dev->stats.rx_length_errors,  EMAC_RXOVERSIZED);
> +	emac_set_stat(dev->stats.rx_length_errors,  EMAC_RXUNDERSIZED);
> +	emac_set_stat(dev->stats.rx_crc_errors,     EMAC_RXCRCERRORS);
> +	emac_set_stat(dev->stats.rx_frame_errors,   EMAC_RXALIGNCODEERRORS);
> +	emac_set_stat(dev->stats.tx_carrier_errors, EMAC_TXCARRIERSLOSS);
> +	emac_set_stat(dev->stats.tx_fifo_errors,    EMAC_TXUNDERRUN);
> +	emac_set_stat(dev->stats.tx_window_errors,  EMAC_TXLATECOLL);
> +
> +	/* ACK statistic by write-to-decrement */
> +	reg = EMAC_RXGOODFRAMES;
> +	for (i = 0; i < EMAC_NUM_STATREGS; i++) {
> +		dummy = emac_get_reg(reg);
> +		emac_set_reg(reg, dummy);
> +		reg += 4;
> +	}

This looks wrong.  Surely you should be decrementing stats by the values
that were read above, not the 'dummy' value read later.

> +	return &dev->stats;
> +}
> +
> +/*
> + * Receive packets
> + */
> +static int emac_rx(struct net_device *dev, struct emac_desc *desc_ack)
> +{
[...]
> +			/* Give back old sk_buff */
> +			netif_rx(skb_old);
> +			dev->last_rx = jiffies;

No need to set last_rx; the networking core does it.

> +			/* Fill statistic */
> +			dev->stats.rx_packets++;
> +			dev->stats.rx_bytes += pkt_len;
> +		} else {
> +			printk(KERN_WARNING "%s: Memory squeeze, dropping packet.\n", dev->name);

Should be rate-limited or controlled by message-level (see netif_info()
and related macros in netdevice.h).

[...]
> +static int emac_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct emac_private	  *ep =  netdev_priv(dev);
> +	volatile struct emac_desc *desc;
> +	volatile struct emac_desc *prev_desc = NULL;
> +	ushort pkt_len = skb->len;
> +	unsigned long flags;
> +
> +	if (ep->tx_full) {
> +		printk(KERN_WARNING "%s: tx queue full\n", dev->name);

Definitely don't log this by default.

> +		dev->stats.tx_dropped++;

No, the packet is not dropped in this case.

> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	/* Pad short frame */
> +	if (unlikely(pkt_len < ETH_ZLEN)) {
> +		if (skb_padto(skb, ETH_ZLEN)) {
> +			netif_wake_queue(dev);

The queue is already awake!

And in this case you *are* dropping the packet, so you could increment
tx_dropped.

> +			return NETDEV_TX_OK;
> +		}
> +		pkt_len = ETH_ZLEN;
> +	}
[...]
> +static void emac_handle_host_interrupt(struct net_device *dev)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +	unsigned long	     status;
> +
> +	/* Handle host error */
> +	status = emac_get_reg(EMAC_MACSTATUS);
> +
> +	/* Check if the problem occurs on our channel when we are slave */
> +	if ((ep->slave)
> +	    && (((status & EMAC_M_RXERRCH) >> EMAC_S_RXERRCH) != IDX_TO_CHAN(emac_idx))
> +	    && (((status & EMAC_M_TXERRCH) >> EMAC_S_TXERRCH) != IDX_TO_CHAN(emac_idx)))
> +		return;
> +
> +	if ((status & EMAC_M_RXERRCODE) == (EMAC_V_OWNERSHIP <<  EMAC_S_RXERRCODE)) {
> +		printk(KERN_ERR "%s: EMAC rx ring full\n", dev->name);

Should be rate-limited or controlled by message-level.

> +		dev->stats.rx_fifo_errors++;
> +	} else
> +		printk(KERN_ERR "%s: EMAC fatal host error 0x%lx\n",
> +		       dev->name, status);
> +
> +	DPRINTK(KERN_ERR "%s: Error head=%p desc=%p dirty=%p skb_tx_dirty=%ld count=%ld\n",
> +		dev->name, ep->head_tx, ep->cur_tx,
> +		ep->dirty_tx, ep->skb_tx_dirty, ep->count_tx);
> +
> +	if (!ep->slave) {
> +		/* Reconfigure the device */
> +		ep->fatal_error = 1;
> +		emac_reconfigure_device(dev);
> +	}
> +}
[...]
> +#ifdef EMAC_HAS_ALE_SUPPORT
[...]
> +static void emac_set_rx_mode(struct net_device *dev)
[...]
> +		/* Set mcast from a list */
> +		for (i = 0; i < dev->mc_count; i++, dmi = dmi->next) {
> +			u8 *p_dmi = dmi->dmi_addr;

This is the old multicast list format; the code won't even compile now.

It needs to be updated like the !EMAC_HAS_ALE_SUPPORT version has been.

[...]
> +#ifdef EMAC_TIMER_TICK_MDIO
> +/*
> + * This function should be called for each device in the system on a
> + * periodic basis of 100mS (10 times a second). It is used to check the
> + * status of the EMAC and MDIO device.
> + */
> +static void emac_timer_tick(unsigned long data)

That seems excessive!  It might be worth checking whether this takes
significant CPU time, and increasing the period when all links are in a
steady state.

[...]
> +static const struct ethtool_ops gemac_ethtool_ops = {
> +};

We (that is, netdev regulars) should make more of the default ethtool
operations work without dev->ethtool_ops set, so you don't have to do
this!

[...]
> +#ifdef EMAC_ARCH_HAS_MAC_ADDR
> +	/* SoC or board hw has MAC address */
> +	if (config.enetaddr[0] == 0 && config.enetaddr[1] == 0 &&
> +	    config.enetaddr[2] == 0 && config.enetaddr[3] == 0 &&
> +	    config.enetaddr[4] == 0 && config.enetaddr[5] == 0) {
[...]

is_zero_ether_addr(config.enetaddr)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
