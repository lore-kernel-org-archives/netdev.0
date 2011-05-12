From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 03/16] add driver for C64x+ ethernet driver
Date: Wed, 11 May 2011 17:49:00 -0700
Message-ID: <1305161340.19586.223.camel@Joe-Laptop>
References: <1305144843-5058-1-git-send-email-msalter@redhat.com>
	 <1305144843-5058-2-git-send-email-msalter@redhat.com>
	 <1305144843-5058-3-git-send-email-msalter@redhat.com>
	 <1305144843-5058-4-git-send-email-msalter@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Mark Salter <msalter@redhat.com>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305144843-5058-4-git-send-email-msalter@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-05-11 at 16:13 -0400, Mark Salter wrote:
> From: Aurelien Jacquiot <a-jacquiot@ti.com>
> 
> This patch adds a network driver to support the ethernet interface found on
> several Texas Instruments C64X+ based System on Chips. In particular, this
> driver has been tested on the TMS320C6455, TMS320C6457, TMS320C6472, and
> TMS320C6474 parts.

I'd rather you put this in a new ti_c6x subdirectory in drivers/net/
Please CC network drivers to netdev@vger.kernel.org (added)

And some comments below.

> Signed-off-by: Aurelien Jacquiot <a-jacquiot@ti.com>
> Signed-off-by: Mark Salter <msalter@redhat.com>
> ---
>  drivers/net/Kconfig     |    8 +
>  drivers/net/Makefile    |    2 +
>  drivers/net/c6x_gemac.c | 1582 +++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/c6x_gmdio.c |  514 +++++++++++++++
>  4 files changed, 2106 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/c6x_gemac.c
>  create mode 100644 drivers/net/c6x_gmdio.c
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index dc280bc..5eb46a1 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2910,6 +2910,14 @@ config BNA
>  
>  	  <http://support.brocade.com>
>  
> +config TMS320C64X_GEMAC
> +	tristate "TMS320C64X GEMAC Ethernet Driver Support"
> +	depends on TMS320C64XPLUS
> +	default n
> +	help
> +	  This driver supports the C64X+ SoC family ethernet
> +	  interface.
> +
>  source "drivers/net/sfc/Kconfig"
>  
>  source "drivers/net/benet/Kconfig"
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 01b604a..d768fde 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -259,6 +259,8 @@ obj-$(CONFIG_MLX4_CORE) += mlx4/
>  obj-$(CONFIG_ENC28J60) += enc28j60.o
>  obj-$(CONFIG_ETHOC) += ethoc.o
>  obj-$(CONFIG_GRETH) += greth.o
> +obj-$(CONFIG_TMS320C64X_GEMAC) += gemac.o
> +gemac-objs := c6x_gemac.o c6x_gmdio.o
>  
>  obj-$(CONFIG_XTENSA_XT2000_SONIC) += xtsonic.o
>  
> diff --git a/drivers/net/c6x_gemac.c b/drivers/net/c6x_gemac.c
> new file mode 100644
> index 0000000..40124df
> --- /dev/null
> +++ b/drivers/net/c6x_gemac.c
> @@ -0,0 +1,1582 @@
> +/*
> + *  Port on Texas Instruments TMS320C6x architecture
> + *
> + *  Copyright (C) 2006, 2007, 2008, 2009, 2010 Texas Instruments Incorporated
> + *  Authors: Nicolas Videau (nicolas.videau@virtuallogix.com)
> + *	     Aurelien Jacquiot (a-jacquiot@ti.com)
> + *
> + *  This program is free software; you can redistribute it and/or modify
> + *  it under the terms of the GNU General Public License version 2 as
> + *  published by the Free Software Foundation.
> + */

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

> +#include <linux/kernel.h>
> +#include <linux/sched.h>
> +#include <linux/delay.h>
> +#include <linux/interrupt.h>
> +#include <linux/init.h>
> +#include <linux/slab.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/skbuff.h>
> +#include <linux/spinlock.h>
> +#include <linux/timer.h>
> +#include <linux/platform_device.h>
> +#include <linux/io.h>
> +
> +#include <asm/setup.h>
> +#include <asm/irq.h>
> +#include <asm/gmdio.h>
> +#include <asm/gemac.h>
> +
> +#undef EMAC_DEBUG
> +
> +#ifdef EMAC_DEBUG
> +#define DPRINTK(fmt, args...) printk(KERN_DEBUG "GEMAC: [%s] " fmt, __func__, ## args)

pr_debug(foo)

> +#define ASSERT(cond)	      if (!(cond)) DPRINTK("ASSERT %s FAILURE\n", # cond)
> +#else
> +#define ASSERT(cond)
> +#define DPRINTK(fmt, args...)
> +#endif
> +
> +static int emac_open(struct net_device *dev);
> +static int emac_close(struct net_device *dev);
> +static int emac_reset(struct net_device *dev, int reset_mode);
> +static void emac_set_modes(struct net_device *dev);
> +static void emac_fixup_modes(struct net_device *dev);
> +static void emac_reset_filter(struct net_device *dev,
> +			      int channel,
> +			      int reset_mode);
> +static void emac_set_filter(struct net_device *dev, int channel);
> +static int emac_reconfigure_device(struct net_device *dev);
> +
> +#ifdef EMAC_TIMER_TICK_MDIO
> +static struct timer_list  emac_timer;
> +#endif
> +
> +static struct emac_config config = { 0, { 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 } };
> +
> +static int emac_shared;
> +static int emac_idx;
> +
> +inline long _hex_chartol(char c)
> +{
> +	if (c >= '0' && c <= '9')
> +		return c - '0';
> +	if (c >= 'A' && c <= 'F')
> +		return c - 'A' + 10;
> +	if (c >= 'a' && c <= 'f')
> +		return c - 'a' + 10;
> +
> +	return -1;
> +}

kstrtol

> +
> +static unsigned long _hex_strtoul(const char *str, const char **end)
> +{
> +	unsigned long ul = 0;
> +	long	      ud;
> +	while ((ud = _hex_chartol(*str)) >= 0) {
> +		ul = (ul << 4) | ud;
> +		str++;
> +	}
> +	*end = str;
> +	return ul;
> +}

kstrtoul

> +
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
> +
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
> +
> +	return &dev->stats;
> +}
> +
> +/*
> + * Receive packets
> + */
> +static int emac_rx(struct net_device *dev, struct emac_desc *desc_ack)
> +{
> +	struct emac_private	    *ep = netdev_priv(dev);
> +	volatile struct emac_desc *desc = ep->cur_rx;
> +	ushort pkt_len;
> +	u32 pkt_flags = desc->packet_flags_len & 0xffff0000;
> +	int loop = 1;
> +	struct sk_buff *skb, *skb_old;
> +
> +	DPRINTK("%s: RX desc_ack = 0x%x, cur_rx = 0x%x, num = %d\n",
> +	       dev->name, desc_ack, desc, (desc_ack - desc));

netdev_dbg(dev, etc)

> +
> +	if ((desc == desc_ack) && (desc->packet_flags_len == EMAC_DESC_FLAG_OWNER))
> +		loop = 0;
> +
> +	while (loop) {
> +		skb_old = ep->rx_skbuff[ep->skb_rx_dirty];
> +
> +		pkt_len   = desc->packet_flags_len & EMAC_PACKET_LEN_MASK;
> +		pkt_flags = desc->packet_flags_len & 0xffff0000;
> +
> +		skb = netdev_alloc_skb_ip_align(dev, ep->packet_mtu);
> +		if (skb != NULL) {
> +			/* Prepare old sk_buff */
> +			skb_old->dev = dev;
> +			skb_put(skb_old, pkt_len);
> +
> +			/* No coherency is assumed between EDMA and L2 cache */
> +			L2_cache_block_invalidate((u32) desc->buff,
> +						  (u32) desc->buff + pkt_len);
> +
> +			skb_old->protocol = eth_type_trans(skb_old, dev);
> +
> +			/* Attach new sk_buff to RX ring */
> +			desc->buff = (u8 *) skb->data;
> +			ep->rx_skbuff[ep->skb_rx_dirty] = skb;
> +
> +			DPRINTK("%s: receiving packet of %d len, proto 0x%x\n",
> +			       dev->name, pkt_len, skb->protocol);
> +
> +			/* Give back old sk_buff */
> +			netif_rx(skb_old);
> +			dev->last_rx = jiffies;
> +
> +			/* Fill statistic */
> +			dev->stats.rx_packets++;
> +			dev->stats.rx_bytes += pkt_len;
> +		} else {
> +			printk(KERN_WARNING "%s: Memory squeeze, dropping packet.\n", dev->name);

	netdev_warn(dev, "Memory squeeze, dropping packet\n");

Maybe ratelimited too.

> +			dev->stats.rx_dropped++;
> +		}
> +
> +		/* Update RX dirty */
> +		if (ep->skb_rx_dirty >= RX_RING_MOD_MAX)
> +			ep->skb_rx_dirty = 0;
> +		else
> +			ep->skb_rx_dirty = ep->skb_rx_dirty + 1;
> +
> +		/* Descriptor is now available */
> +		desc->buff_offset_len = ep->packet_mtu;
> +		desc->packet_flags_len = EMAC_DESC_FLAG_OWNER;
> +
> +		/* Check if it is the last descriptor which has been received */
> +		if (desc == desc_ack)
> +			loop = 0;
> +
> +		/* Loop in the ring */
> +		desc = HW_TO_PTR(desc->next);
> +	}
> +	ep->cur_rx = (struct emac_desc *) desc;
> +
> +	/* Check if the receiver stopped */
> +	if (pkt_flags & EMAC_DESC_FLAG_EOQ)
> +		emac_set_reg(EMAC_RX0HDP + (IDX_TO_CHAN(emac_idx) << 2),
> +			     PTR_TO_HW((u32) ep->cur_rx));
> +
> +	return 0;
> +}
> +
> +/*
> + * Transmit packets ACK
> + */
> +static int emac_tx(struct net_device *dev, struct emac_desc *desc_ack)
> +{
> +	struct emac_private	    *ep = netdev_priv(dev);
> +	volatile struct emac_desc *desc = ep->dirty_tx;
> +	int loop = 1;
> +
> +	while (loop) {
> +		DPRINTK("%s: TX desc_ack = 0x%x, desc = 0x%x, num = %d\n",
> +			dev->name, desc_ack, desc, (desc_ack - desc));
> +
> +		if (ep->tx_skbuff[ep->skb_tx_dirty] == NULL) {
> +			printk(KERN_ERR "%s: SKB NULL desc =%p desc_ack =%p, skb_tx_dirty=%ld count=%ld\n",
> +			       dev->name, desc, desc_ack, ep->skb_tx_dirty, ep->count_tx);

			netdev_err("SKB NULL, etc...
Almost all of your printks should use netdev_<level>

> +			break;
> +		}
> +
> +		/* Free the skbuff associated to this packet */
> +		dev_kfree_skb_irq(ep->tx_skbuff[ep->skb_tx_dirty]);
> +
> +		ep->tx_skbuff[ep->skb_tx_dirty] = NULL;
> +		ep->skb_tx_dirty = (ep->skb_tx_dirty + 1) & TX_RING_MOD_MASK;
> +		ep->count_tx--;
> +
> +		/* Check if it is the last acknowledged descriptor */
> +		if (desc++ == desc_ack)
> +			loop = 0;
> +
> +		/* Check end of the ring */
> +		if (desc > ep->tx_desc_base + (TX_RING_SIZE - 1))
> +			desc = ep->tx_desc_base;
> +	}
> +
> +	if (netif_running(dev))
> +		netif_wake_queue(dev);
> +
> +	/* Since we have freed up a buffer, the ring is no longer full */
> +	if (ep->tx_full) {
> +		ep->tx_full = 0;
> +
> +		DPRINTK("%s: wake up queue count_tx = %d cur_tx = 0x%x head_tx\n",
> +			dev->name, ep->count_tx, ep->cur_tx, ep->head_tx);
> +
> +		if (netif_queue_stopped(dev))
> +			netif_wake_queue(dev);
> +	}
> +
> +	/* If this is the end of the queue */
> +	if (desc_ack->packet_flags_len & EMAC_DESC_FLAG_EOQ) {
> +
> +		/* If there are some waiting packets, start the new queue */
> +		if (ep->count_tx > 0)
> +			emac_set_reg(EMAC_TX0HDP + (IDX_TO_CHAN(emac_idx) << 2),
> +				     PTR_TO_HW(ep->head_tx));
> +
> +		/* Set the new head */
> +		ep->head_tx = ep->cur_tx;
> +	}
> +
> +	/* Update dirty tx */
> +	ep->dirty_tx = (struct emac_desc *) desc;
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +/*
> + * Transmit the content of a skbuff
> + */
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
> +		dev->stats.tx_dropped++;
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	/* Pad short frame */
> +	if (unlikely(pkt_len < ETH_ZLEN)) {
> +		if (skb_padto(skb, ETH_ZLEN)) {
> +			netif_wake_queue(dev);
> +			return NETDEV_TX_OK;
> +		}
> +		pkt_len = ETH_ZLEN;
> +	}
> +
> +	spin_lock_irqsave(&ep->lock, flags);
> +
> +	desc = ep->cur_tx;
> +
> +	/* Set buffer length and pointer */
> +	desc->buff	       = skb->data;
> +	desc->packet_flags_len = pkt_len;
> +	desc->buff_offset_len  = pkt_len;
> +	desc->next	       = NULL;	       /* close the queue*/
> +
> +	/* No coherency is assumed between EDMA and L2 cache */
> +	L2_cache_block_writeback((u32) skb->data,
> +				 (u32) skb->data + pkt_len);
> +
> +	DPRINTK("%s: sending packet of %d len, skb_cur = %x, buffer = 0x%x\n",
> +		dev->name, pkt_len, ep->skb_cur, skb->data);
> +
> +	/* Save skb */
> +	ep->tx_skbuff[ep->skb_cur] = skb;
> +	ep->skb_cur = (ep->skb_cur + 1) & TX_RING_MOD_MASK;
> +	dev->stats.tx_packets++;
> +	dev->stats.tx_bytes += pkt_len;
> +	dev->trans_start = jiffies;
> +
> +	desc->packet_flags_len |= EMAC_DESC_FLAG_SOP
> +		| EMAC_DESC_FLAG_EOP
> +		| EMAC_DESC_FLAG_OWNER;
> +
> +	/* Get the previous element of the ring if we are not the head */
> +	if (desc != ep->head_tx) {
> +		if (desc == ep->tx_desc_base)
> +			prev_desc = ep->tx_desc_base + (TX_RING_SIZE - 1);
> +		else
> +			prev_desc = desc - 1;
> +
> +		/* Link the buffer to the previous one in the list */
> +		prev_desc->next = (struct emac_desc *) PTR_TO_HW(desc);
> +	}
> +
> +	ep->count_tx++;
> +
> +	/* Update current pointer */
> +	ep->cur_tx = (struct emac_desc *) desc + 1;
> +
> +	/* Check end of ring */
> +	if (ep->cur_tx > ep->tx_desc_base + (TX_RING_SIZE - 1))
> +		ep->cur_tx = ep->tx_desc_base;
> +
> +	/*
> +	 * If we are the new head and there is no descriptor to acknowledge, start
> +	 * the new head.
> +	 */
> +	if ((desc == ep->head_tx) && (ep->count_tx == 1)) {
> +		emac_set_reg(EMAC_TX0HDP + (IDX_TO_CHAN(emac_idx) << 2),
> +			     PTR_TO_HW(ep->head_tx));
> +		ep->head_tx = ep->cur_tx; /* set the new head */
> +	}
> +
> +	/* Check ring oll over: do not reach the not yet acknowledged packets */
> +	if (ep->count_tx == TX_RING_SIZE) {
> +		ep->tx_full = 1;
> +
> +		DPRINTK("%s: tx queue full count_tx = %d cur_tx = 0x%x head_tx\n",
> +			dev->name, ep->count_tx, ep->cur_tx, ep->head_tx);
> +
> +		netif_stop_queue(dev);
> +	}
> +	spin_unlock_irqrestore(&ep->lock, flags);
> +
> +	return NETDEV_TX_OK;
> +}
> +
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
> +
> +/*
> + * Receive EMAC interrupt management
> + */
> +
> +#ifdef EMAC_HAS_SEPARATE_RXTX_IRQS
> +
> +static irqreturn_t emac_rx_interrupt(int irq, void *netdev_id)
> +{
> +	struct net_device *dev = netdev_id;
> +	struct emac_private *ep = netdev_priv(dev);
> +	struct emac_desc *desc;
> +	unsigned long irq_flags;
> +
> +	ectl_arch_rx_irq_enter(IDX_TO_CHAN(emac_idx));
> +
> +	irq_flags = emac_arch_get_int_vector();
> +
> +	if (irq_flags & EMAC_B_STATPEND)
> +		(void) emac_get_stats(dev);
> +
> +	if (irq_flags & EMAC_B_HOSTPEND)
> +		emac_handle_host_interrupt(dev);
> +
> +	if (emac_arch_get_pending_irq(irq_flags,
> +				      EMAC_B_RXPEND0,
> +				      IDX_TO_CHAN(emac_idx))) {
> +
> +		/* ACK the interrupt */
> +		desc = (struct emac_desc *) emac_get_reg(EMAC_RX0INTACK
> +							 + (IDX_TO_CHAN(emac_idx) << 2));
> +		emac_set_reg(EMAC_RX0INTACK + (IDX_TO_CHAN(emac_idx) << 2), desc);
> +
> +		/* Handle receive event */
> +		emac_rx(netdev_id, HW_TO_PTR(desc));
> +	}
> +
> +	ectl_arch_rx_irq_leave(IDX_TO_CHAN(emac_idx));
> +
> +	return IRQ_HANDLED;
> +}
> +
> +/*
> + * Transmit EMAC interrupt management
> + */
> +static irqreturn_t emac_tx_interrupt(int irq, void *netdev_id)
> +{
> +	struct net_device   *dev = netdev_id;
> +	struct emac_private *ep  = netdev_priv(dev);
> +	struct emac_desc    *desc;
> +	unsigned long irq_flags;
> +
> +	ectl_arch_tx_irq_enter(IDX_TO_CHAN(emac_idx));
> +
> +	irq_flags = emac_arch_get_int_vector();
> +
> +	if (irq_flags & EMAC_B_STATPEND)
> +		(void) emac_get_stats(dev);
> +
> +	if (irq_flags & EMAC_B_HOSTPEND)
> +		emac_handle_host_interrupt(dev);
> +
> +	if (emac_arch_get_pending_irq(irq_flags,
> +				      EMAC_B_TXPEND0,
> +				      IDX_TO_CHAN(emac_idx))) {
> +
> +		/* ACK the interrupt */
> +		desc = (struct emac_desc *) emac_get_reg(EMAC_TX0INTACK
> +							 + (IDX_TO_CHAN(emac_idx) << 2));
> +		emac_set_reg(EMAC_TX0INTACK + (IDX_TO_CHAN(emac_idx) << 2), desc);
> +
> +		/* Handle transmit ACK event */
> +		emac_tx(netdev_id, HW_TO_PTR(desc));
> +	}
> +
> +	ectl_arch_tx_irq_leave(IDX_TO_CHAN(emac_idx));
> +
> +	return IRQ_HANDLED;
> +}
> +
> +#else
> +
> +/*
> + * Main EMAC interrupt management
> + */
> +static irqreturn_t emac_interrupt(int irq, void *netdev_id)
> +{
> +	struct net_device   *dev = netdev_id;
> +	struct emac_private *ep  = netdev_priv(dev);
> +	struct emac_desc    *desc;
> +	unsigned long irq_flags;
> +
> +	/* Disable EMAC/MDIO interrupts  */
> +	emac_clearbit_reg(EMAC_EWCTL, EMAC_B_INTEN);
> +
> +	irq_flags = emac_get_reg(EMAC_MACINVECTOR);
> +
> +	if (irq_flags & EMAC_B_STATPEND)
> +		(void) emac_get_stats(dev);
> +
> +	if (irq_flags & EMAC_B_HOSTPEND) {
> +		emac_handle_host_interrupt(dev);
> +
> +		/* EMAC/MDIO interrupts already enabled by emac_open() */
> +		return IRQ_HANDLED;
> +	}
> +
> +	if (irq_flags & EMAC_B_TXPEND0) {
> +		/* ACK the interrupt */
> +		desc = (struct emac_desc *) emac_get_reg(EMAC_TX0INTACK);
> +		emac_set_reg(EMAC_TX0INTACK, desc);
> +
> +		/* Handle transmit ACK event */
> +		emac_tx(netdev_id, desc);
> +	}
> +
> +	if (irq_flags & EMAC_B_RXPEND0) {
> +		/* ACK the interrupt */
> +		desc = (struct emac_desc *) emac_get_reg(EMAC_RX0INTACK);
> +		emac_set_reg(EMAC_RX0INTACK, desc);
> +
> +		/* Handle receive event */
> +		emac_rx(netdev_id, desc);
> +	}
> +
> +	/* Enable EMAC/MDIO interrupts */
> +	emac_setbit_reg(EMAC_EWCTL, EMAC_B_INTEN);
> +
> +	return IRQ_HANDLED;
> +}
> +#endif
> +
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +/*
> + * EMAC poll
> + */
> +static void emac_poll(struct net_device *dev)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +
> +	ectl_arch_disable_irq(IDX_TO_CHAN(emac_idx));
> +
> +#ifdef EMAC_HAS_SEPARATE_RXTX_IRQS
> +	emac_tx_interrupt(dev->irq + 1, dev);
> +	emac_rx_interrupt(dev->irq, dev);
> +#else
> +	emac_interrupt(dev->irq, dev);
> +#endif
> +
> +	ectl_arch_enable_irq(IDX_TO_CHAN(emac_idx), !ep->slave);
> +}
> +#endif
> +
> +/*
> + * Register the MAC address
> + */
> +
> +static void emac_register_mac_addr(struct net_device *dev, int idx)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +	u32 val;
> +	int i;
> +
> +	/* Copy the config MAC address to the dev_addr */
> +	for (i = 4; i >= 0; i--)
> +		dev->dev_addr[i] = config.enetaddr[i];
> +	/*
> +	 * Compute MAC addr low for all for the given EMAC instances if several.
> +	 * Each device consume n MAC addresses where n is the number cores.
> +	 * This value is for GEM0, this value + 2 is for GEM1, etc
> +	 * The number programmed in this field will be incremented by n * 2 from
> +	 * device to device
> +	 */
> +	dev->dev_addr[5] = (config.enetaddr[5] +
> +			    (IDX_TO_MAC(idx)) + DEV_TO_MAC(dev->dev_id)) & 0xff;
> +
> +	/* Choose MAC address index between 0 and 31 */
> +	emac_arch_set_mac_addr_index(idx);
> +
> +	/* Compute and store MAC addr high */
> +	val = 0;
> +	for (i = 3; i >= 0; i--)
> +		val = (val << 8) | dev->dev_addr[i];

Inconsistent style with low portion below
and function emac_reset.

This might be better as:

	val = (dev->dev_addr[3] << 24) |
	      (dev->dev_addr[2] << 16) |
	      (dev->dev_addr[1] << 8) |
	      (dev->dev_addr[0] << 0);

> +	emac_arch_set_mac_addr_high(val);
> +
> +	val  = (dev->dev_addr[5] << 8) | dev->dev_addr[4];

	
> +	val |= (1 << EMAC_S_VALID)
> +		| (1 << EMAC_S_MATCHFILTER)
> +		| (IDX_TO_CHAN(idx) << EMAC_S_CHANNEL);
> +
> +	emac_arch_set_mac_addr_low(val);
> +}
> +
> +/*
> + * Reset the EMAC software ring.
> + */
> +static void emac_reset_ring(struct emac_private *ep)
> +{
> +	struct emac_desc *desc;
> +	int i;
> +
> +	desc = (struct emac_desc *) ep->emac_dsc_base;
> +
> +	/* Reset rx ring */
> +	ep->cur_rx	 = desc;
> +	ep->skb_rx_dirty = 0;
> +
> +	for (i = 0; i < RX_RING_SIZE; desc++, i++)
> +		desc->packet_flags_len = EMAC_DESC_FLAG_OWNER;
> +
> +	/* Reset tx ring */
> +	desc = (struct emac_desc *) (ep->emac_dsc_base + (RX_RING_SIZE << 4));
> +	ep->cur_tx	 = desc;
> +	ep->dirty_tx	 = desc;
> +	ep->head_tx	 = desc;
> +	ep->skb_cur	 = 0;
> +	ep->skb_tx_dirty = 0;
> +	ep->tx_full	 = 0;
> +	ep->fatal_error  = 0;
> +	ep->count_tx	 = 0;
> +
> +	for (i = 0; i < TX_RING_SIZE; i++) {
> +		desc->buff	       = NULL;
> +		desc->buff_offset_len  = 0;
> +		desc->packet_flags_len = 0;
> +		desc->next	       = NULL;
> +		ep->tx_skbuff[i]       = NULL;

	memset?

> +		desc++;
> +	}
> +}
> +
> +/*
> + * Reconfigure the EMAC device
> + */
> +static int emac_reconfigure_device(struct net_device *dev)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +
> +	if (!ep->slave) {
> +		unsigned int  hash1;
> +		unsigned int  hash2;
> +		unsigned int  promisc;
> +		unsigned int  control;
> +		unsigned int  rx_intmask;
> +		unsigned int  tx_intmask;
> +		unsigned int  unicast;
> +		unsigned int *mac_ctx;
> +		int	      i;
> +
> +		/* Get state */
> +		hash1	= emac_arch_get_hash1();
> +		hash2	= emac_arch_get_hash2();
> +		promisc = emac_arch_get_promisc();
> +		control = emac_arch_get_control();
> +
> +		unicast    = emac_get_reg(EMAC_RXUNICASTSET);
> +		rx_intmask = emac_get_reg(EMAC_RXINTMASKSET);
> +		tx_intmask = emac_get_reg(EMAC_TXINTMASKSET);
> +
> +		/* Save MAC addresses */
> +		mac_ctx = kmalloc((sizeof(u32) << 1) * MAC_ADDR_NUM, GFP_KERNEL);
> +		for (i = 0; i < MAC_ADDR_NUM; i++) {
> +			emac_arch_set_mac_addr_index(i);
> +			mac_ctx[i << 1]       = emac_arch_get_mac_addr_high();
> +			mac_ctx[(i << 1) + 1] = emac_arch_get_mac_addr_low();
> +		}
> +
> +		/* Reset the EMAC */
> +		if (netif_running(dev)) {
> +			emac_close(dev);
> +			emac_reset(dev, GEMAC_RESET_WARM);
> +			emac_open(dev);
> +		} else {
> +			emac_reset(dev, GEMAC_RESET_WARM);
> +		}
> +
> +		/* Restore MAC addresses */
> +		for (i = 0; i < MAC_ADDR_NUM; i++) {
> +			emac_arch_set_mac_addr_index(i);
> +			emac_arch_set_mac_addr_high(mac_ctx[i << 1]);
> +			emac_arch_set_mac_addr_low(mac_ctx[(i << 1) + 1]);
> +		}
> +		kfree(mac_ctx);
> +
> +		/* Restore state */
> +		emac_arch_set_hash1(hash1);
> +		emac_arch_set_hash2(hash2);
> +		emac_arch_set_promisc(hash2);
> +		emac_arch_set_control(hash2);
> +
> +		emac_set_reg(EMAC_RXINTMASKSET, rx_intmask);
> +		emac_set_reg(EMAC_TXINTMASKSET, tx_intmask);
> +		emac_set_reg(EMAC_RXUNICASTSET, unicast);
> +	} else
> +		/* Only master core can reset the device */
> +		return -EBUSY;
> +
> +	return 0;
> +}
> +
> +/*
> + * Reset the EMAC hardware.
> + */
> +static int emac_reset(struct net_device *dev, int reset_mode)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +	volatile u32	    *preg;

volatile?

> +	int		     i;
> +
> +	if (!ep->slave) {
> +
> +		if (reset_mode == GEMAC_RESET_COLD) {
> +			/* Reset integrated switch if any */
> +			emac_arch_reset_switch();
> +
> +			/* Reset EMAC control Module */
> +			emac_arch_reset_ectl();
> +		}
> +
> +		/* Reset EMAC */
> +		emac_setbit_reg(EMAC_SOFTRESET, EMAC_B_SOFTRST);
> +
> +		/* Wait until reset has occured or timeout */
> +		for (i = 0; i <= HZ / 2; i++) {
> +			if (emac_get_reg(EMAC_SOFTRESET) == 0x0)
> +				break;
> +			if (i == HZ / 2)
> +				return 1;
> +			msleep_interruptible(1);
> +		}
> +	}
> +
> +	/* Set interrupt pacing */
> +	emac_arch_set_pacing();
> +
> +	if (!ep->slave) {
> +		/* Reset MAC, TX, RX Control */
> +		emac_set_reg(EMAC_MACCONTROL, 0);
> +		emac_set_reg(EMAC_TXCONTROL, 0);
> +		emac_set_reg(EMAC_RXCONTROL, 0);
> +
> +		if (reset_mode == GEMAC_RESET_COLD) {
> +#ifdef EMAC_DO_INIT_MDIO
> +			/* MII/MDIO setup */
> +			mdio_init(emac_get_reg(EMAC_TXIDVER));
> +#endif
> +
> +			/* Init HDPs to NULL for all channels */
> +			emac_set_reg(EMAC_TX0HDP, 0);
> +			emac_set_reg(EMAC_TX1HDP, 0);
> +			emac_set_reg(EMAC_TX2HDP, 0);
> +			emac_set_reg(EMAC_TX3HDP, 0);
> +			emac_set_reg(EMAC_TX4HDP, 0);
> +			emac_set_reg(EMAC_TX5HDP, 0);
> +			emac_set_reg(EMAC_TX6HDP, 0);
> +			emac_set_reg(EMAC_TX7HDP, 0);
> +			emac_set_reg(EMAC_RX0HDP, 0);
> +			emac_set_reg(EMAC_RX1HDP, 0);
> +			emac_set_reg(EMAC_RX2HDP, 0);
> +			emac_set_reg(EMAC_RX3HDP, 0);
> +			emac_set_reg(EMAC_RX4HDP, 0);
> +			emac_set_reg(EMAC_RX5HDP, 0);
> +			emac_set_reg(EMAC_RX6HDP, 0);
> +			emac_set_reg(EMAC_RX7HDP, 0);
> +
> +			/* Clear statistic registers */
> +			if (reset_mode == GEMAC_RESET_COLD) {
> +				preg = emac_addr_reg(EMAC_RXGOODFRAMES);
> +				for (i = 0; i < EMAC_NUM_STATREGS; i++)
> +					*preg++ = 0;
> +			}
> +
> +			/* Clear all MAC addresses */
> +			emac_arch_clear_mac_addr();
> +		}
> +	}
> +
> +	/* Register my MAC address */
> +	emac_register_mac_addr(dev, emac_idx);
> +
> +	if (!ep->slave) {
> +
> +		/* Used for pause frame (IEEE 802.3x) but not working for MC */
> +		emac_set_reg(EMAC_MACSRCADDRLO,
> +			     (dev->dev_addr[0] << 8) | dev->dev_addr[1]);
> +		emac_set_reg(EMAC_MACSRCADDRHI,
> +			     (dev->dev_addr[2] << 24) | (dev->dev_addr[3] << 16) |
> +			     (dev->dev_addr[4] << 8)  | (dev->dev_addr[5]));
> +
> +		if (reset_mode == GEMAC_RESET_COLD) {
> +
> +			/* Init completion pointers to NULL */
> +			emac_set_reg(EMAC_RX0INTACK, 0x0);
> +			emac_set_reg(EMAC_RX1INTACK, 0x0);
> +			emac_set_reg(EMAC_RX2INTACK, 0x0);
> +			emac_set_reg(EMAC_RX3INTACK, 0x0);
> +			emac_set_reg(EMAC_RX4INTACK, 0x0);
> +			emac_set_reg(EMAC_RX5INTACK, 0x0);
> +			emac_set_reg(EMAC_RX6INTACK, 0x0);
> +			emac_set_reg(EMAC_RX7INTACK, 0x0);
> +			emac_set_reg(EMAC_TX0INTACK, 0x0);
> +			emac_set_reg(EMAC_TX1INTACK, 0x0);
> +			emac_set_reg(EMAC_TX2INTACK, 0x0);
> +			emac_set_reg(EMAC_TX3INTACK, 0x0);
> +			emac_set_reg(EMAC_TX4INTACK, 0x0);
> +			emac_set_reg(EMAC_TX5INTACK, 0x0);
> +			emac_set_reg(EMAC_TX6INTACK, 0x0);
> +			emac_set_reg(EMAC_TX7INTACK, 0x0);
> +		}
> +
> +		/* Reset unicast, multicast, broadcast Rx */
> +		emac_reset_filter(dev, IDX_TO_CHAN(emac_idx), reset_mode);
> +
> +		/* Set device modes */
> +		emac_set_modes(dev);
> +
> +		/* Disable all channel interrupts */
> +		if (reset_mode == GEMAC_RESET_COLD) {
> +			emac_set_reg(EMAC_RXINTMASKCLEAR, 0xff);
> +			emac_set_reg(EMAC_TXINTMASKCLEAR, 0xff);
> +		}
> +
> +		/* Enable host and stat interrupts */
> +		emac_set_reg(EMAC_MACINTMASKSET, EMAC_B_HOSTINT | EMAC_B_STATINT);
> +	} else {
> +		/* Fixup mode according to hw configuration */
> +		emac_fixup_modes(dev);
> +	}
> +
> +	/* Enable TX and RX interrupts for a given channel */
> +	emac_arch_enable_irq(EMAC_TXINTMASKSET, IDX_TO_CHAN(emac_idx));
> +	emac_arch_enable_irq(EMAC_RXINTMASKSET, IDX_TO_CHAN(emac_idx));
> +
> +	/* Reset transmit/receive buffers */
> +	if (reset_mode == GEMAC_RESET_WARM)
> +		(void) emac_reset_ring(ep);
> +
> +	/* Set default receive filter: unicast, multicast and broadcast */
> +	emac_set_filter(dev, IDX_TO_CHAN(emac_idx));
> +
> +	return 0;
> +}
> +
> +/*
> + * Open the device
> + */
> +static int emac_open(struct net_device *dev)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +
> +	if (!ep->slave) {
> +		/* Set MAC mode (Gigabyte, xxMII, pacing, etc) */
> +		emac_arch_init_control(ep->mode_flags & EMAC_CONFIG_PACING);
> +
> +		/* Enable RX and TX */
> +		emac_set_reg(EMAC_TXCONTROL, 1);
> +		emac_set_reg(EMAC_RXCONTROL, 1);
> +	}
> +
> +	/* Ready for RX */
> +	emac_set_reg(EMAC_RX0HDP + (IDX_TO_CHAN(emac_idx) << 2),
> +		     PTR_TO_HW(ep->cur_rx));
> +
> +	/* Enable interrupts at the ECTL level (misc int only for master) */
> +	ectl_arch_enable_irq(IDX_TO_CHAN(emac_idx), !ep->slave);
> +
> +	netif_start_queue(dev);
> +
> +	return 0;
> +}
> +
> +/*
> + * Close the device
> + */
> +static int emac_close(struct net_device *dev)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +
> +	netif_stop_queue(dev);
> +
> +	/* Disable interrupt at the ECTL level */
> +	ectl_arch_disable_irq(IDX_TO_CHAN(emac_idx));
> +
> +	/* Teardown RX and TX */
> +	emac_set_reg(EMAC_RXTEARDOWN, IDX_TO_CHAN(emac_idx));
> +	emac_set_reg(EMAC_TXTEARDOWN, IDX_TO_CHAN(emac_idx));
> +
> +	if (!ep->fatal_error) {
> +		unsigned int tmp;
> +
> +		/* Wait for the teardown to complete */
> +		for (tmp = 0; tmp != 0xfffffffc;
> +		     tmp = emac_get_reg(EMAC_RX0INTACK +		\

Don't use line continuations unnecessarily please.

> +				       (IDX_TO_CHAN(emac_idx) << 2)))
> +			emac_set_reg(EMAC_RX0INTACK + \
> +				     (IDX_TO_CHAN(emac_idx) << 2), tmp);
> +
> +		for (tmp = 0; tmp != 0xfffffffc;
> +		     tmp = emac_get_reg(EMAC_TX0INTACK +		\
> +					(IDX_TO_CHAN(emac_idx) << 2)))
> +			emac_set_reg(EMAC_TX0INTACK +			\
> +				     (IDX_TO_CHAN(emac_idx) << 2), tmp);
> +	}
> +
> +	if (!ep->slave) {
> +		/* Disable Rx, Tx and MII */
> +		emac_set_reg(EMAC_TXCONTROL, 0);
> +		emac_set_reg(EMAC_RXCONTROL, 0);
> +		emac_set_reg(EMAC_MACCONTROL, 0);
> +	}
> +
> +	/* Clean up the software ring */
> +	emac_reset_ring(ep);
> +
> +	return 0;
> +}
> +
> +/*
> + * Initialize the EMAC software ring.
> + * For the rx ring, we initialize the packet descriptors with pre-allocated
> + * skbuff to the packet MTU size.
> + * For the tx ring, we only initialize it with NULL values.
> + */
> +static int emac_setup_ring(struct emac_private *ep)
> +{
> +	struct emac_desc *desc;
> +	int		  i;
> +	struct sk_buff	 *skb;
> +
> +	/* Setup rx ring*/
> +	desc = (struct emac_desc *) ep->emac_dsc_base;
> +	ep->rx_desc_base = desc;
> +	ep->cur_rx	 = desc;
> +	ep->skb_rx_dirty = 0;
> +
> +	/* Allocate ring buffers via sk buffers */
> +	for (i = 0; i < RX_RING_SIZE; i++) {
> +		skb = netdev_alloc_skb_ip_align(ep->dev, ep->packet_mtu);
> +		if (!skb)
> +			return 1;
> +
> +		ep->rx_skbuff[i]       = skb;
> +		desc->buff	       = (u8 *) skb->data;
> +		desc->buff_offset_len  = ep->packet_mtu;
> +		desc->packet_flags_len = EMAC_DESC_FLAG_OWNER;
> +		desc->next	       = PTR_TO_HW(desc + 1);
> +		desc++;
> +	}
> +
> +	/* Loop the ring */
> +	(desc - 1)->next = PTR_TO_HW(ep->rx_desc_base);
> +
> +	/* Setup tx ring */
> +	desc = (struct emac_desc *) (ep->emac_dsc_base + (RX_RING_SIZE << 4));
> +	ep->tx_desc_base = desc;
> +	ep->cur_tx	 = desc;
> +	ep->dirty_tx	 = desc;
> +	ep->head_tx	 = desc;
> +	ep->skb_cur	 = 0;
> +	ep->skb_tx_dirty = 0;
> +	ep->tx_full	 = 0;
> +	ep->fatal_error  = 0;
> +	ep->count_tx	 = 0;
> +
> +	for (i = 0; i < TX_RING_SIZE; i++) {
> +		desc->buff	       = NULL;
> +		desc->buff_offset_len  = 0;
> +		desc->packet_flags_len = 0;
> +		desc->next	       = NULL;
> +		ep->tx_skbuff[i]       = NULL;
> +		desc++;
> +	}
> +	return 0;
> +}
> +
> +/*
> + * Called by the kernel to send a packet out into the void
> + * of the net.
> + */
> +static void emac_timeout(struct net_device *dev)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +
> +	printk(KERN_WARNING "%s: transmit timed out\n", dev->name);
> +	dev->stats.tx_errors++;
> +	dev->trans_start = jiffies;
> +	if (!ep->tx_full)
> +		netif_wake_queue(dev);
> +}
> +
> +/*
> + * Set or clear the multicast filter for this adaptor.
> + */
> +#ifdef EMAC_HAS_ALE_SUPPORT
> +static void emac_reset_filter(struct net_device *dev,
> +			      int channel,
> +			      int reset_mode)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +	int i;
> +
> +	if (reset_mode == GEMAC_RESET_COLD) {
> +		/* Alloc mcast list */
> +		ep->mcast_infos = kmalloc(3 * EMAC_V_ALE_MAX_MCAST, GFP_KERNEL);
> +		/* Init mcast table */
> +		if (ep->mcast_infos) {
> +			memset(ep->mcast_infos, 0x0, 3 * EMAC_V_ALE_MAX_MCAST);
> +			/* Clear device multicast list */
> +			for (i = 0; i < EMAC_V_ALE_MAX_MCAST; i++) {
> +				emac_set_reg(EMAC_ALETBLW0, 0);
> +				emac_set_reg(EMAC_ALETBLW1, 0);
> +				emac_set_reg(EMAC_ALETBLW2, 0);
> +				emac_set_reg(EMAC_ALETBLCTL,
> +					     i | EMAC_B_ALE_WRITE_RDZ);
> +			}
> +		}
> +	}
> +	if ((reset_mode == GEMAC_RESET_WARM) && (ep->mcast_infos)) {
> +		/* Re-set device multicast list */
> +		for (i = 0; i < ep->mcast_valid_len; i++) {
> +			emac_set_reg(EMAC_ALETBLW0, ep->mcast_infos[3*i]);
> +			emac_set_reg(EMAC_ALETBLW1, ep->mcast_infos[3*i+1]);
> +			emac_set_reg(EMAC_ALETBLW2, ep->mcast_infos[3*i+2]);
> +			emac_set_reg(EMAC_ALETBLCTL,
> +				     i | EMAC_B_ALE_WRITE_RDZ);
> +		}
> +		/* Set mcast mode if needed */
> +		if (ep->mcast_valid_len)
> +			emac_setbit_reg(EMAC_ALEUNKNOWNVLAN,
> +					EMAC_B_REG_MCAST_FLOOD_ON);
> +	}
> +}
> +
> +static void emac_set_modes(struct net_device *dev)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +
> +	if (ep->mode_flags & EMAC_CONFIG_RXCRC)
> +		ep->packet_mtu = PKT_MTU_CRC;
> +	else
> +		ep->packet_mtu = PKT_MTU_NOCRC;
> +
> +	/* If PASSERROR is set, enable both ERROR and short frames */
> +	if (ep->mode_flags & EMAC_CONFIG_PASSERROR)
> +		emac_setbit_reg(EMAC_MACCONTROL,
> +				EMAC_B_RXCEFEN | EMAC_B_RXCSFEN);
> +
> +	/* If PASSCONTROL is set, enable control frames */
> +	if (ep->mode_flags & EMAC_CONFIG_PASSCONTROL)
> +		emac_setbit_reg(EMAC_MACCONTROL, EMAC_B_RXCMFEN);
> +
> +	/* Set MAC loopback if requested */
> +	if (ep->mode_flags & EMAC_CONFIG_MACLOOPBACK)
> +		emac_setbit_reg(EMAC_MACCONTROL, EMAC_B_LOOPBACK);
> +}
> +
> +static void emac_set_filter(struct net_device *dev, int channel)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +
> +	emac_set_reg(CPSW_SW_CTL, 0x000000F4);	  /* Enable switch flow control */
> +	emac_set_reg(CPSW_RX_CH_MAP, 0x11110000); /* RX switch priority */
> +
> +	emac_set_reg(EMAC_ALECONTROL, 0x80000004); /* ALE enable and bypass */
> +	emac_set_reg(EMAC_ALEPRESCALE, 0x0); /* no mcat/broadcast limit */
> +	emac_set_reg(EMAC_ALEUNKNOWNVLAN, 0x07030307); /* need it!!! */
> +	emac_set_reg(EMAC_ALEPORTCTL0, 0x3); /* Port 0 in forward state */
> +	emac_set_reg(EMAC_ALEPORTCTL1, 0x3); /* Port 1 in forward state */
> +	emac_set_reg(EMAC_ALEPORTCTL2, 0x3); /* Port 2 in forward state */
> +}
> +
> +static void emac_set_rx_mode(struct net_device *dev)
> +{
> +	struct emac_private *ep  = netdev_priv(dev);
> +	struct dev_mc_list  *dmi = dev->mc_list;
> +	u8     hashval, tmpval;
> +	u32    info0, info1, info2;
> +	int    i;
> +
> +	/* Only master can use promiscuous or multicast */
> +	if (ep->slave)
> +		return;
> +
> +	if (dev->flags & IFF_PROMISC)
> +		/* Set promiscuous mode */
> +		emac_setbit_reg(EMAC_ALECONTROL, EMAC_B_ALEBYPASS);
> +	else
> +		/* Reset promiscuous mode */
> +		emac_clearbit_reg(EMAC_ALECONTROL, EMAC_B_ALEBYPASS);
> +
> +	/* Clear multicast config */
> +	emac_clearbit_reg(EMAC_ALEUNKNOWNVLAN, EMAC_B_MCAST_FLOOD_ON |
> +			  EMAC_B_REG_MCAST_FLOOD_ON);
> +
> +	/* Clear old multicast list that will not be reused */
> +	for (i = dev->mc_count; i < ep->mcast_valid_len; i++) {
> +		emac_setbit_reg(EMAC_ALETBLW0, 0);
> +		emac_setbit_reg(EMAC_ALETBLW1, 0);
> +		emac_setbit_reg(EMAC_ALETBLW2, 0);
> +		emac_setbit_reg(EMAC_ALETBLCTL,
> +				i | EMAC_B_ALE_WRITE_RDZ);
> +	}
> +
> +	if ((dev->flags & IFF_ALLMULTI) ||
> +	    (dev->mc_count > EMAC_V_ALE_MAX_MCAST)) {
> +		/* Set all multicast */
> +		emac_setbit_reg(EMAC_ALEUNKNOWNVLAN, EMAC_B_MCAST_FLOOD_ON |
> +				EMAC_B_REG_MCAST_FLOOD_ON);
> +	} else {
> +		/* Set mcast from a list */
> +		for (i = 0; i < dev->mc_count; i++, dmi = dmi->next) {
> +			u8 *p_dmi = dmi->dmi_addr;
> +
> +			info0 = (((p_dmi[2]&0x0ff)<<24) |
> +				 ((p_dmi[3]&0x0ff)<<16) |
> +				 ((p_dmi[4]&0x0ff)<<8) | ((p_dmi[5]&0x0ff)<<0));
> +			info1 = ((3<<30) | (0<<29) | (1<<28) |
> +				 ((0&0x0fff)<<16) |
> +				 ((p_dmi[0]&0x0ff)<<8) | ((p_dmi[1]&0x0ff)<<0));
> +			info2 = (0 << 3) | (7 & 0x7);
> +
> +			/* Only support group multicast */
> +			if (!(*p_dmi & 1)) {
> +				/* don't use this entry */
> +				info0 = 0;
> +				info1 = 1;
> +				info2 = 2;
> +			}
> +
> +			emac_set_reg(EMAC_ALETBLW0, info0);
> +			emac_set_reg(EMAC_ALETBLW1, info1);
> +			emac_set_reg(EMAC_ALETBLW2, info2);
> +			emac_set_reg(EMAC_ALETBLCTL,
> +					i | EMAC_B_ALE_WRITE_RDZ);
> +
> +			/* Copy mcast list */
> +			if (ep->mcast_infos) {
> +				ep->mcast_infos[3*i]   = info0;
> +				ep->mcast_infos[3*i+1] = info1;
> +				ep->mcast_infos[3*i+2] = info2;
> +			}
> +		}
> +
> +		/* set multicast mode if needed */
> +		if (dev->mc_count)
> +			emac_setbit_reg(EMAC_ALEUNKNOWNVLAN,
> +					EMAC_B_REG_MCAST_FLOOD_ON);
> +
> +		/* Remember mcast valid addrs count */
> +		ep->mcast_valid_len = dev->mc_count;
> +	}
> +}
> +
> +#else /* !EMAC_HAS_ALE_SUPPORT */
> +
> +static void emac_reset_filter(struct net_device *dev,
> +			      int channel,
> +			      int reset_mode)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +
> +	/* Reset multicast hash table */
> +	emac_set_reg(EMAC_MACHASH1, 0);
> +	emac_set_reg(EMAC_MACHASH2, 0);
> +
> +	/* Set buffer offset */
> +	emac_set_reg(EMAC_RXBUFFEROFFSET, 0);
> +
> +	/* Reset RX (M)ulticast (B)roadcast (P)romiscuous Enable register */
> +	emac_set_reg(EMAC_RXMBPENABLE, 0);
> +
> +	if (reset_mode == GEMAC_RESET_COLD) {
> +		/* Clear unicast RX on channel 0-7 */
> +		emac_set_reg(EMAC_RXUNICASTCLEAR, 0xff);
> +	} else
> +		emac_set_reg(EMAC_RXUNICASTCLEAR, (1 << channel));
> +}
> +
> +static void emac_fixup_modes(struct net_device *dev)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +
> +	if (emac_get_reg(EMAC_RXMBPENABLE) & EMAC_B_RXPASSCRC)
> +		ep->packet_mtu = PKT_MTU_CRC;
> +	else
> +		ep->packet_mtu = PKT_MTU_NOCRC;
> +}
> +
> +static void emac_set_modes(struct net_device *dev)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +
> +	if (ep->slave)
> +		return;
> +
> +	if (ep->mode_flags & EMAC_CONFIG_RXCRC) {
> +		emac_setbit_reg(EMAC_RXMBPENABLE, EMAC_B_RXPASSCRC);
> +		ep->packet_mtu = PKT_MTU_CRC;
> +	} else
> +		ep->packet_mtu = PKT_MTU_NOCRC;
> +
> +	/* If PASSERROR is set, enable both ERROR and short frames */
> +	if (ep->mode_flags & EMAC_CONFIG_PASSERROR)
> +		emac_setbit_reg(EMAC_RXMBPENABLE,
> +				EMAC_B_RXCEFEN | EMAC_B_RXCSFEN);
> +
> +	/* If PASSCONTROL is set, enable control frames */
> +	if (ep->mode_flags & EMAC_CONFIG_PASSCONTROL)
> +		emac_setbit_reg(EMAC_RXMBPENABLE, EMAC_B_RXCMFEN);
> +
> +	/* Set the channel configuration to priority if requested */
> +	if (ep->mode_flags & EMAC_CONFIG_CHPRIORITY)
> +			emac_setbit_reg(EMAC_MACCONTROL, EMAC_B_TXPTYPE);
> +
> +	/* Set MAC loopback if requested */
> +	if (ep->mode_flags & EMAC_CONFIG_MACLOOPBACK)
> +		emac_setbit_reg(EMAC_MACCONTROL, EMAC_B_LOOPBACK);
> +}
> +
> +static void emac_set_filter(struct net_device *dev, int channel)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +
> +	/* Set unicast for the given channel */
> +	emac_set_reg(EMAC_RXUNICASTSET, 1 << channel);
> +
> +	if (!ep->slave) {
> +		emac_set_reg(EMAC_RXMBPENABLE, 0);
> +		emac_setbit_reg(EMAC_RXMBPENABLE, EMAC_B_MULTEN);
> +		emac_setbit_reg(EMAC_RXMBPENABLE, EMAC_B_BROADEN);
> +		emac_setbit_reg(EMAC_RXMBPENABLE, (channel | (channel << 8)));
> +	}
> +}
> +
> +static void emac_set_rx_mode(struct net_device *dev)
> +{
> +	struct emac_private *ep = netdev_priv(dev);
> +	struct netdev_hw_addr *ha;
> +	u8     hashval, tmpval;
> +	u32    machash1, machash2;
> +	int    i;
> +
> +	/* Only master can use promiscuous or multicast */
> +	if (ep->slave)
> +		return;
> +
> +	if (dev->flags & IFF_PROMISC) {
> +		/* Set promiscuous mode */
> +		emac_setbit_reg(EMAC_RXMBPENABLE, EMAC_B_RXCAFEN);
> +	} else {
> +		/* Reset promiscuous mode */
> +		emac_clearbit_reg(EMAC_RXMBPENABLE, EMAC_B_RXCAFEN);
> +	}
> +
> +	if (dev->flags & IFF_ALLMULTI) {
> +
> +		/* Set all multicast filter */
> +		emac_setbit_reg(EMAC_MACHASH1, 0xffffffff);
> +		emac_setbit_reg(EMAC_MACHASH2, 0xffffffff);
> +
> +	} else {
> +
> +		hashval  = 0;
> +		machash1 = 0;
> +		machash2 = 0;
> +
> +		netdev_for_each_mc_addr(ha, dev) {
> +			u8 *addr = ha->addr;
> +
> +			/* Only support group multicast */
> +			if (!(*addr & 1))
> +				continue;

I believe you don't need to test the multicast address again.
If you _really_ do, is_multicast_ether_addr.

> +
> +			for (i = 0; i < 2; i++) {
> +				tmpval   = (u8) *addr++;
> +				hashval ^= (u8) (tmpval >> 2) ^ (tmpval << 4);
> +				tmpval   = (u8) *addr++;
> +				hashval ^= (u8) (tmpval >> 4) ^ (tmpval << 2);
> +				tmpval   = (u8) *addr++;
> +				hashval ^= (u8) (tmpval >> 6) ^ (tmpval);
> +			}
> +
> +			if (hashval & 0x20)
> +				machash2 |= (1 << (hashval & 0x1f));
> +			else
> +				machash1 |= (1 << (hashval & 0x1f));
> +		}
> +
> +		/* Set computed multicast filter */
> +		emac_setbit_reg(EMAC_MACHASH1, machash1);
> +		emac_setbit_reg(EMAC_MACHASH2, machash2);
> +	}
> +}
> +#endif /* !EMAC_HAS_ALE_SUPPORT */
> +
> +#ifdef EMAC_TIMER_TICK_MDIO
> +/*
> + * This function should be called for each device in the system on a
> + * periodic basis of 100mS (10 times a second). It is used to check the
> + * status of the EMAC and MDIO device.
> + */
> +static void emac_timer_tick(unsigned long data)
> +{
> +	struct net_device   *dev = (struct net_device *)data;
> +	struct emac_private *ep  = netdev_priv(dev);
> +	unsigned int link_status;
> +	unsigned int link_event = mdio_timer_tick();
> +	unsigned int intfmacsel = mdio_get_macsel();
> +
> +	/*
> +	 * Signal the MDIO
> +	 */
> +	if (link_event == MDIO_EVENT_LINKUP) {
> +		link_status = mdio_get_status();
> +		if (link_status == MDIO_LINKSTATUS_FD10 ||
> +		    link_status == MDIO_LINKSTATUS_FD100 ||
> +		    link_status == MDIO_LINKSTATUS_FD1000) {
> +			emac_setbit_reg(EMAC_MACCONTROL, EMAC_B_FULLDUPLEX);
> +			if (intfmacsel == DEVSTAT_MACSEL_RMII)
> +				emac_setbit_reg(EMAC_MACCONTROL,
> +						EMAC_B_RMIIDUPLEXMODE);
> +		} else {
> +			emac_clearbit_reg(EMAC_MACCONTROL, EMAC_B_FULLDUPLEX);
> +			if (intfmacsel == DEVSTAT_MACSEL_RMII)
> +				emac_clearbit_reg(EMAC_MACCONTROL,
> +						  EMAC_B_RMIIDUPLEXMODE);
> +		}
> +
> +		if (link_status == MDIO_LINKSTATUS_FD1000)
> +			emac_setbit_reg(EMAC_MACCONTROL, EMAC_B_GIG);
> +
> +		if ((link_status == MDIO_LINKSTATUS_FD10 ||
> +		     link_status == MDIO_LINKSTATUS_HD10) &&
> +		    (intfmacsel == DEVSTAT_MACSEL_RMII))
> +			/* Clear bit to set clock to 2.5 MHz */
> +			emac_clearbit_reg(EMAC_MACCONTROL, EMAC_B_RMIISPEED);
> +
> +		if ((link_status == MDIO_LINKSTATUS_FD100 ||
> +		     link_status == MDIO_LINKSTATUS_HD100) &&
> +		    (intfmacsel == DEVSTAT_MACSEL_RMII))
> +			/* Set bit to set clock to 25 MHz */
> +			emac_setbit_reg(EMAC_MACCONTROL, EMAC_B_RMIISPEED);
> +
> +		/* eventually call platform hook for RMII out of reset */
> +		rmii_arch_fix();
> +
> +		/* Put RGMII in forced link mode */
> +		if (intfmacsel == DEVSTAT_MACSEL_RGMII)
> +			emac_clearbit_reg(EMAC_MACCONTROL, EMAC_B_RGMIIEN);
> +	}
> +	mod_timer(&emac_timer, jiffies + EMAC_TIMER_PERIOD);
> +}
> +#endif /* EMAC_TIMER_TICK_MDIO */
> +
> +static const char emac_driver_name[] = "EMAC";

EMAC?  Shouldn't this be c6x_gmac?

> +static const struct net_device_ops gemac_netdev_ops = {
> +	.ndo_open		= emac_open,
> +	.ndo_stop		= emac_close,
> +	.ndo_start_xmit		= emac_start_xmit,
> +	.ndo_tx_timeout		= emac_timeout,
> +	.ndo_set_multicast_list	= emac_set_rx_mode,
> +	.ndo_set_mac_address	= eth_mac_addr,
> +	.ndo_get_stats		= emac_get_stats,
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	.ndo_poll_controller	= emac_poll,
> +#endif
> +	.ndo_change_mtu		= eth_change_mtu,
> +	.ndo_validate_addr	= eth_validate_addr,
> +};
> +
> +static const struct ethtool_ops gemac_ethtool_ops = {
> +};
> +
> +static int __init emac_probe(struct platform_device *pdev)
> +{
> +	struct net_device      *netdev;
> +	struct emac_private    *ep;
> +	int			res = -EINVAL;
> +	int			i;
> +#ifdef EMAC_ARCH_HAS_MAC_ADDR
> +	char			hw_emac_addr[6];
> +#endif
> +	struct resource        *cur_res;
> +	static int		ndevs;
> +	int			irq   = 0;
> +
> +	emac_idx = get_emac_idx();
> +
> +	if (ndevs >= EMAC_MAX_INSTANCE) {
> +		printk(KERN_ERR "gemac: Invalid instance: %d (max=%d)\n",
> +		       ndevs, EMAC_MAX_INSTANCE);

		pr_err("Invalid instance: %d (max=%d)\n",
		       ndevs, EMAC_MAX_INSTANCE);

> +		return -EINVAL;
> +	}
> +
> +	/* Allocate private information */
> +	netdev = alloc_etherdev(sizeof(struct emac_private));
> +	if (!netdev)
> +		return -ENOMEM;
> +
> +	SET_NETDEV_DEV(netdev, &pdev->dev);
> +
> +	ep	= netdev_priv(netdev);
> +	ep->dev = netdev;
> +
> +	spin_lock_init(&ep->lock);
> +
> +	/* Get irqs numbers */
> +	cur_res = platform_get_resource_byname(pdev, IORESOURCE_IRQ, "IRQ_SRC");
> +	if (cur_res)
> +		irq = cur_res->start;
> +
> +	/* Get EMAC I/O addresses */
> +	ep->emac_reg_base = 0;
> +	ep->ectl_reg_base = 0;
> +	ep->emac_dsc_base = 0;
> +	ep->mdio_reg_base = 0;
> +
> +	cur_res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
> +					       "EMAC_REG_BASE");
> +	if (cur_res)
> +		ep->emac_reg_base = cur_res->start;
> +
> +	cur_res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
> +					       "ECTL_REG_BASE");
> +	if (cur_res)
> +		ep->ectl_reg_base = cur_res->start;
> +
> +	cur_res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
> +					       "EMAC_DSC_BASE");
> +	if (cur_res)
> +		ep->emac_dsc_base = cur_res->start
> +			+ ((IDX_TO_CHAN(emac_idx) * QUEUE_DESC_NUM) << 4);
> +
> +#ifdef EMAC_DO_INIT_MDIO
> +	cur_res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
> +					       "MDIO_REG_BASE");
> +	if (cur_res)
> +		ep->mdio_reg_base = cur_res->start;
> +#endif
> +
> +	if (!irq || !ep->emac_reg_base || !ep->ectl_reg_base || !ep->emac_dsc_base) {
> +		printk(KERN_ERR "%s: Unable to get hardware resources\n",
> +		       netdev->name);
> +		goto error;
> +	}
> +
> +	ep->mode_flags = config.flags;
> +
> +	if (emac_check_shared_capability())
> +		ep->slave = emac_shared;
> +
> +	netdev->base_addr = ep->emac_reg_base;
> +	netdev->dev_id	  = pdev->id;
> +
> +#ifdef EMAC_ARCH_HAS_MAC_ADDR
> +	/* SoC or board hw has MAC address */
> +	if (config.enetaddr[0] == 0 && config.enetaddr[1] == 0 &&
> +	    config.enetaddr[2] == 0 && config.enetaddr[3] == 0 &&
> +	    config.enetaddr[4] == 0 && config.enetaddr[5] == 0) {
> +		if (!emac_arch_get_mac_addr(hw_emac_addr))
> +			for (i = 0; i <= 5; i++)
> +				config.enetaddr[i] = hw_emac_addr[i] & 0xff;
> +	}
> +#endif
> +	/* Setup the device */
> +	res = emac_reset(netdev, GEMAC_RESET_COLD);
> +	if (res) {
> +		free_netdev(netdev);
> +		goto error;
> +	}
> +
> +	/* driver system function */
> +	ether_setup(netdev);
> +
> +	/* Set generic Ethernet operations */
> +	netdev->netdev_ops	= &gemac_netdev_ops;
> +	netdev->watchdog_timeo	= TX_TIMEOUT;
> +	netdev->ethtool_ops	= &gemac_ethtool_ops;
> +
> +	platform_set_drvdata(pdev, netdev);
> +
> +	/* Register Ethernet device */
> +	res = register_netdev(netdev);
> +	if (res) {
> +		printk(KERN_ERR "%s: Unable to register netdev\n",
> +		       netdev->name);
> +		goto error;
> +	}
> +
> +	/* Setup transmit/receive buffers */
> +	res = emac_setup_ring(ep);
> +	if (res) {
> +		printk(KERN_ERR "%s: Unable to allocate memory\n",
> +		       netdev->name);
> +		goto error;
> +	}
> +
> +#ifdef EMAC_TIMER_TICK_MDIO
> +	/* Set EMAC timer */
> +	init_timer(&emac_timer);
> +	emac_timer.function = emac_timer_tick;
> +	emac_timer.data = (unsigned long)netdev;
> +	mod_timer(&emac_timer, jiffies + EMAC_TIMER_PERIOD);
> +#endif
> +
> +	/* Install our interrupt handler(s) */
> +#ifdef EMAC_HAS_SEPARATE_RXTX_IRQS
> +	if ((request_irq(irq, emac_rx_interrupt, _INTFLAG, "GEMAC RX", netdev) == 0) &&
> +	    (request_irq(irq + 1, emac_tx_interrupt, _INTFLAG, "GEMAC TX", netdev) == 0))
> +		netdev->irq = irq;
> +#else
> +	if (request_irq(irq, emac_interrupt, 0, "GEMAC", netdev) == 0)
> +		netdev->irq = irq;
> +#endif
> +
> +	printk(KERN_INFO "%s: EMAC(%d) driver version 2.1 IRQ=%d queue=%d %s",
> +	       netdev->name, pdev->id, netdev->irq, IDX_TO_CHAN(emac_idx),
> +	       emac_shared ? "shared\n" : "\n");
> +
> +	printk(KERN_INFO "%s: MAC address=", netdev->name);
> +	for (i = 0; i < 5; i++)
> +		printk(KERN_CONT "%02x:", netdev->dev_addr[i]);
> +#ifdef CONFIG_SGMII
> +	printk(KERN_CONT "%02x PHY=SGMII\n", netdev->dev_addr[i]);
> +#else
> +	printk(KERN_CONT "%02x PHY=%s%sMII\n", netdev->dev_addr[i],
> +	       ((mdio_get_macsel() & DEVSTAT_MACSEL_RMII) ? "R" : ""),
> +	       ((mdio_get_macsel() & DEVSTAT_MACSEL_GMII) ? "G" : ""));
> +#endif
> +	++ndevs;
> +	return 0;
> +
> + error:
> +	free_netdev(netdev);
> +	return res;
> +}
> +
> +static struct platform_driver emac_driver = {
> +	.driver = {
> +		.name	= (char *) emac_driver_name,
> +		.owner	= THIS_MODULE,
> +	},
> +	.probe	= emac_probe,
> +};
> +
> +static void __exit emac_cleanup(void)
> +{
> +	platform_driver_unregister(&emac_driver);
> +}
> +module_exit(emac_cleanup);
> +
> +/*
> + * Initialize GEMAC controller
> + */
> +static int emac_init(void)
> +{
> +	return platform_driver_register(&emac_driver);
> +}
> +
> +module_init(emac_init);
> +
> diff --git a/drivers/net/c6x_gmdio.c b/drivers/net/c6x_gmdio.c
> new file mode 100644
> index 0000000..6a82519
> --- /dev/null
> +++ b/drivers/net/c6x_gmdio.c
> @@ -0,0 +1,514 @@
> +/*
> + *  Port on Texas Instruments TMS320C6x architecture
> + *
> + *  Copyright (C) 2006, 2009, 2010 Texas Instruments Incorporated
> + *  Author: Nicolas Videau (nicolas.videau@jaluna.com)
> + *
> + *  This program is free software; you can redistribute it and/or modify
> + *  it under the terms of the GNU General Public License version 2 as
> + *  published by the Free Software Foundation.
> + */
> +#include <linux/kernel.h>
> +#include <linux/sched.h>
> +#include <linux/delay.h>
> +#include <linux/init.h>
> +#include <linux/spinlock.h>
> +#include <linux/io.h>
> +
> +#include <asm/setup.h>
> +#include <asm/irq.h>
> +#include <asm/gmdio.h>
> +#include <asm/pll.h>
> +
> +static struct mdio_status mdios;
> +
> +/*
> + * Tick counts for timeout of each state
> + * Note that NWAYSTART falls through to NWAYWAIT which falls through
> + * to LINKWAIT. The timeout is not reset progressing from one state
> + * to the next, so the system has 5 seconds total to find a link.
> + */
> +static unsigned int phy_timeout[] = { 2,  /* MDIO_PHY_MDIOINIT	- min-delay  */
> +				      6,  /* MDIO_PHY_RESET	- .5 sec max */
> +				      41, /* MDIO_PHY_NWAYSTART - 4 seconds  */
> +				      41, /* MDIO_PHY_NWAYWAIT	- 4 seconds  */
> +				      51, /* MDIO_PHY_LINKWAIT	- 5 seconds  */
> +				      0 };/* MDIO_PHY_LINKED	- no timeout */
> +
> +static void mdio_init_state_machine(void)
> +{
> +	mdios.phy_addr	  = 0;
> +	mdios.phy_state   = MDIO_PHY_MDIOINIT;
> +	mdios.phy_ticks   = 0;
> +	mdios.link_status = MDIO_LINKSTATUS_NOLINK;
> +}
> +
> +/*
> + * Initialize the MDIO
> + */
> +int mdio_init(unsigned int txid_version)
> +{
> +#ifdef CONFIG_SOC_TMS320C6455
> +	/* Get MAC interface */
> +	mdios.macsel = (DSCR_DEVSTAT >> DEVSTAT_MACSEL_OFFSET) &
> +		DEVSTAT_MACSEL_MASK;
> +#else
> +	/* Default (no gigabit support) */
> +	mdios.macsel = DEVSTAT_MACSEL_MII;
> +#endif
> +
> +	/* Get Transmit identification and version */
> +	mdios.emac_txidver = txid_version;
> +
> +	mdios.mode = MDIO_MODE_AUTONEG; /* autonegotiate */
> +	mdio_init_state_machine();
> +	mdio_set_reg(MDIO_CONTROL, EMAC_B_ENABLE | (VBUSCLK & EMAC_M_CLKDIV));
> +	return 0;
> +}
> +
> +/*
> + * Return the current MDIO/PHY status
> + */
> +unsigned int mdio_get_status(void)
> +{
> +	return mdios.link_status;
> +}
> +
> +/*
> + * Return the current MDIO/PHY interface
> + */
> +unsigned int mdio_get_macsel(void)
> +{
> +	mdios.macsel = (DSCR_DEVSTAT >> DEVSTAT_MACSEL_OFFSET) &
> +		DEVSTAT_MACSEL_MASK;
> +
> +	return mdios.macsel;
> +}
> +
> +/*
> + * Force a switch to the specified PHY, and start the negotiation process
> + */
> +static unsigned int mdio_init_phy_1(volatile unsigned int phy_addr)
> +{
> +	unsigned short	 val, ack;
> +	unsigned int	 lval;
> +	unsigned int	 i;
> +
> +	mdios.phy_addr	  = phy_addr;
> +	mdios.link_status = MDIO_LINKSTATUS_NOLINK;
> +
> +	/* Shutdown all other PHYs */
> +	lval = mdio_get_reg(MDIO_ALIVE);
> +	for (i = 0; lval; i++, lval >>= 1)
> +		if ((lval & 1) && (i != phy_addr)) {
> +			mdio_phy_write(MDIO_PHY_REG_CONTROL,
> +				       i,
> +				       (MDIO_PHY_B_ISOLATE |
> +					MDIO_PHY_B_POWERDOWN));
> +			mdio_phy_wait();
> +		}
> +
> +#ifdef CONFIG_ARCH_BOARD_DSK6455
> +	/* Settings for Broadcom phys */
> +	if (mdios.macsel == DEVSTAT_MACSEL_RGMII) {
> +		/* Put phy in copper mode */
> +		mdio_phy_write(MDIO_PHY_REG_ACCESS, phy_addr,
> +			       MDIO_PHY_B_COPPER);
> +		mdio_phy_wait_res_ack(val, ack);
> +
> +		/* If the PHY did not ACK the write, return zero */
> +		if (!ack)
> +			return 0;
> +
> +		mdio_phy_write(0x10, phy_addr, 0x0000);
> +		mdio_phy_wait();
> +
> +		/* Put phy in RGMII mode/in-band status data for PG 2.0 */
> +		if (mdios.emac_txidver != 0x000C1207) {
> +			mdio_phy_write(MDIO_PHY_REG_SHADOW, phy_addr,
> +				       MDIO_PHY_B_INBAND);
> +			mdio_phy_wait_res_ack(val, ack);
> +
> +			/* If the PHY did not ACK the write, return zero */
> +			if (!ack)
> +				return 0;
> +		}
> +
> +		/* Patch for (older) board revB with R822 soldered */
> +		mdio_phy_write(MDIO_PHY_REG_ACCESS, phy_addr, 0x8C00);
> +		mdio_phy_wait_res_ack(val, ack);
> +		/* End of patch */
> +	}
> +#endif
> +
> +	if (mdios.macsel == DEVSTAT_MACSEL_GMII) {
> +		/* Put phy in copper mode */
> +		mdio_phy_write(MDIO_PHY_REG_ACCESS, phy_addr,
> +			       MDIO_PHY_B_COPPER);
> +		mdio_phy_wait_res_ack(val, ack);
> +
> +		/* If the PHY did not ACK the write, return zero */
> +		if (!ack)
> +			return 0;
> +	}
> +
> +	/* Ready for next init step */
> +	mdios.phy_state   = MDIO_PHY_RESET;
> +	mdios.phy_ticks   = 0;
> +
> +	return 1;
> +}
> +
> +static unsigned int mdio_init_phy_2(volatile unsigned int phy_addr)
> +{
> +	unsigned short	 val, val2, valgig = 0;
> +
> +	mdios.phy_addr	  = phy_addr;
> +
> +	/* Read the STATUS reg to check autonegotiation capability */
> +	mdio_phy_read(MDIO_PHY_REG_STATUS, phy_addr);
> +	mdio_phy_wait_res(val);
> +
> +	if ((mdios.macsel == DEVSTAT_MACSEL_GMII) ||
> +	    (mdios.macsel == DEVSTAT_MACSEL_RGMII)) {
> +		mdio_phy_read(MDIO_PHY_REG_EXTSTATUS, phy_addr);
> +		mdio_phy_wait_res(valgig);
> +	}
> +
> +	/* See if we auto-neg or not */
> +	if ((mdios.mode & MDIO_MODE_AUTONEG) &&
> +	    (val & MDIO_PHY_B_AUTOCAPABLE)) {
> +		/* We will use NWAY */
> +
> +		/* Advertise 1000 for supported interfaces */
> +		if ((mdios.macsel == DEVSTAT_MACSEL_GMII) ||
> +		    (mdios.macsel == DEVSTAT_MACSEL_RGMII)) {
> +			valgig >>= 4;
> +			valgig &= MDIO_PHY_ADV_FD1000;
> +
> +			mdio_phy_write(MDIO_PHY_REG_1000CONTROL, phy_addr,
> +				       valgig);
> +			mdio_phy_wait();
> +		}
> +
> +		/* Shift down the capability bits */
> +		val >>= 6;
> +
> +		/* Mask with the capabilities */
> +		val &= (MDIO_PHY_B_AFD100 | MDIO_PHY_B_AHD100 |
> +			MDIO_PHY_B_AFD10 | MDIO_PHY_B_AHD10);
> +
> +		/* Set Ethernet message bit */
> +		val |= MDIO_PHY_B_MSG;
> +
> +		/* Write out advertisement */
> +		mdio_phy_write(MDIO_PHY_REG_ADVERTISE, phy_addr, val);
> +		mdio_phy_wait();
> +
> +		/* Start NWAY */
> +		mdio_phy_write(MDIO_PHY_REG_CONTROL,
> +			       phy_addr,
> +			       MDIO_PHY_B_AUTONEGEN);
> +		mdio_phy_wait();
> +
> +		mdio_phy_write(MDIO_PHY_REG_CONTROL,
> +			       phy_addr,
> +			       (MDIO_PHY_B_AUTONEGEN | MDIO_PHY_B_AUTORESTART));
> +		mdio_phy_wait();
> +
> +		/* Setup current state */
> +		mdios.mode |= MDIO_MODE_NWAYACTIVE;
> +		mdios.phy_state = MDIO_PHY_NWAYSTART;
> +		mdios.phy_ticks = 0;
> +
> +	} else {
> +		/* Otherwise use a fixed configuration */
> +
> +		/* Shift down the capability bits */
> +		val >>= 10;
> +
> +		/* Mask with possible modes */
> +		val &= (MDIO_MODE_HD10 | MDIO_MODE_FD10 |
> +			MDIO_MODE_HD100 | MDIO_MODE_FD100);
> +
> +		if ((mdios.macsel == DEVSTAT_MACSEL_GMII) ||
> +		    (mdios.macsel == DEVSTAT_MACSEL_RGMII)) {
> +			valgig >>= 8;
> +			valgig &= MDIO_MODE_FD1000;
> +
> +			valgig &= mdios.mode;
> +		}
> +
> +		/* Mask with what the User wants to allow */
> +		val &= mdios.mode;
> +
> +		/* If nothing if left, move on */
> +		if ((!val) && (!valgig))
> +			return 0;
> +
> +		/* Setup Control word and pending status */
> +		if (valgig) {
> +			val2 = MDIO_PHY_B_SPEEDMSB | MDIO_PHY_B_DUPLEXFULL;
> +			mdios.pending_status = MDIO_LINKSTATUS_FD1000;
> +		} else if (val & MDIO_MODE_FD100) {
> +			val2 = MDIO_PHY_B_SPEEDLSB | MDIO_PHY_B_DUPLEXFULL;
> +			mdios.pending_status = MDIO_LINKSTATUS_FD100;
> +		} else if (val & MDIO_MODE_HD100) {
> +			val2 = MDIO_PHY_B_SPEEDLSB;
> +			mdios.pending_status = MDIO_LINKSTATUS_HD100;
> +		} else if (val & MDIO_MODE_FD10) {
> +			val2 = MDIO_PHY_B_DUPLEXFULL;
> +			mdios.pending_status = MDIO_PHY_B_FD10;
> +		} else {
> +			val2 = 0;
> +			mdios.pending_status = MDIO_LINKSTATUS_HD10;
> +		}
> +
> +		/* Add in loopback if user wanted it */
> +		if (mdios.mode & MDIO_MODE_LOOPBACK)
> +			val2 |= MDIO_PHY_B_LOOPBACK;
> +
> +		/* Configure PHY */
> +		mdio_phy_write(MDIO_PHY_REG_CONTROL, phy_addr,
> +			       (val2 | MDIO_PHY_B_AUTORESTART));
> +		mdio_phy_wait();
> +
> +		/* Add in external loopback with plug if user wanted it */
> +		if (mdios.mode & MDIO_MODE_EXTLOOPBACK) {
> +			mdio_phy_write(MDIO_PHY_REG_SHADOW, phy_addr,
> +				       MDIO_PHY_B_EXTLOOPBACK);
> +			mdio_phy_wait();
> +		}
> +
> +		/* Setup current state */
> +		mdios.mode &= ~MDIO_MODE_NWAYACTIVE;
> +		mdios.phy_state = MDIO_PHY_LINKWAIT;
> +		mdios.phy_ticks = 0;
> +	}
> +	return 1;
> +}
> +
> +
> +/*
> + * Called each 100mS to check if MDIO status has changed.
> + * A MDIO event is returned.
> + */
> +unsigned int mdio_timer_tick(void)
> +{
> +	unsigned int res = MDIO_EVENT_NOCHANGE;
> +	unsigned short val, val2, valgig = 0, valgig2 = 0, ack;
> +	unsigned int lval;
> +
> +	if (mdios.phy_state == MDIO_PHY_LINKED) {
> +		/*
> +		 * Check for a "link-change" status indication or a link
> +		 * down indication.
> +		 */
> +		lval = mdio_get_reg(MDIO_LINKINTRAW) & 1;
> +		mdio_set_reg(MDIO_LINKINTRAW, lval);
> +		if (lval || !(mdio_get_reg(MDIO_LINK) & (1 << mdios.phy_addr))) {
> +
> +			mdios.link_status = MDIO_LINKSTATUS_NOLINK;
> +			mdios.phy_ticks = 0;
> +			res = MDIO_EVENT_LINKDOWN;
> +
> +			/* If not NWAY, just wait for link */
> +			if (!(mdios.mode & MDIO_MODE_NWAYACTIVE))
> +				mdios.phy_state = MDIO_PHY_LINKWAIT;
> +			else {
> +				/* Handle NWAY condition */
> +				mdio_phy_read(MDIO_PHY_REG_STATUS,
> +					      mdios.phy_addr);
> +				mdio_phy_wait();
> +				mdio_phy_read(MDIO_PHY_REG_STATUS,
> +					      mdios.phy_addr);
> +				mdio_phy_wait_res_ack(val, ack);
> +				if (!ack)
> +					mdio_init_state_machine();
> +
> +				else if (!(val & MDIO_PHY_B_LINKSTATUS)) {
> +					/* No Link - restart NWAY */
> +					mdios.phy_state = MDIO_PHY_NWAYSTART;
> +
> +					mdio_phy_write(MDIO_PHY_REG_CONTROL,
> +						       mdios.phy_addr,
> +						       (MDIO_PHY_B_AUTONEGEN |
> +							MDIO_PHY_B_AUTORESTART));
> +					mdio_phy_wait();
> +				} else
> +					/* We have a Link - re-read NWAY params */
> +					mdios.phy_state = MDIO_PHY_NWAYWAIT;
> +			}
> +		}
> +	}
> +
> +	if (mdios.phy_state != MDIO_PHY_LINKED) {
> +		/* Bump the time counter */
> +		mdios.phy_ticks++;
> +
> +		/* Process differently based on state */
> +		switch (mdios.phy_state) {
> +#if !(defined(CONFIG_SOC_TMS3206472) || defined(CONFIG_SOC_TMS3206474)) && \
> +	!defined(CONFIG_SOC_TMS3206457)
> +		case MDIO_PHY_RESET:
> +			/* Don't read reset status for the first 100 to 200 ms */
> +			if (mdios.phy_ticks < 2)
> +				break;
> +
> +			/* See if the PHY has come out of reset */
> +			mdio_phy_read(MDIO_PHY_REG_CONTROL,
> +				      mdios.phy_addr);
> +			mdio_phy_wait_res_ack(val, ack);
> +
> +			if (ack && !(val & MDIO_PHY_B_RESET)) {
> +				/* PHY is not reset.
> +				 * If the PHY init is going well, break out */
> +				if (mdio_init_phy_2(mdios.phy_addr))
> +					break;
> +				/* Else, this PHY is toast.
> +				 * Manually trigger a timeout */
> +				mdios.phy_ticks = phy_timeout[mdios.phy_state];
> +			}
> +
> +			/* Fall through to timeout check */
> +#endif
> +		case MDIO_PHY_MDIOINIT:
> + check_timeout:
> +			/* Here we just check timeout and try to find a PHY */
> +			if (mdios.phy_ticks >= phy_timeout[mdios.phy_state]) {
> +				/* Try the next PHY if anything but
> +				 * a MDIOINIT condition */
> +				if (mdios.phy_state != MDIO_PHY_MDIOINIT)
> +					if (++mdios.phy_addr == 32)
> +						mdios.phy_addr = 0;
> +
> +				lval = mdio_get_reg(MDIO_ALIVE);
> +
> +				for (val = 0; val < 32; val++) {
> +
> +					if ((lval & (1 << mdios.phy_addr)) &&
> +					    (mdio_init_phy_1(mdios.phy_addr)))
> +						break;
> +
> +					if (++mdios.phy_addr == 32)
> +						mdios.phy_addr = 0;
> +				}
> +
> +				/* If we didn't find a PHY, try again */
> +				if (val == 32) {
> +					mdios.phy_addr	  = 0;
> +					mdios.phy_state   = MDIO_PHY_MDIOINIT;
> +					mdios.phy_ticks   = 0;
> +					res = MDIO_EVENT_PHYERROR;
> +				}
> +			}
> +			break;
> +
> +		case MDIO_PHY_NWAYSTART:
> +			/* Start NWAY */
> +
> +			/* Read the CONTROL reg to verify "restart" is not set */
> +			mdio_phy_read(MDIO_PHY_REG_CONTROL, mdios.phy_addr);
> +			mdio_phy_wait_res_ack(val, ack);
> +			if (!ack) {
> +				mdio_init_state_machine();
> +				break;
> +			}
> +
> +			if (val & MDIO_PHY_B_AUTORESTART)
> +				goto check_timeout;
> +
> +			/* Flush latched "link status" from the STATUS reg */
> +			mdio_phy_read(MDIO_PHY_REG_STATUS, mdios.phy_addr);
> +			mdio_phy_wait();
> +
> +			mdios.phy_state = MDIO_PHY_NWAYWAIT;
> +
> +			/* Fallthrough */
> +
> +		case MDIO_PHY_NWAYWAIT:
> +			/* Waiting NWAY to complete */
> +
> +			/* Read the STATUS reg to check for "complete" */
> +			mdio_phy_read(MDIO_PHY_REG_STATUS, mdios.phy_addr);
> +			mdio_phy_wait_res_ack(val, ack);
> +			if (!ack) {
> +				mdio_init_state_machine();
> +				break;
> +			}
> +
> +			if (!(val & MDIO_PHY_B_AUTOCOMPLETE))
> +				goto check_timeout;
> +#if !(defined(CONFIG_SOC_TMS3206472) || defined(CONFIG_SOC_TMS3206474)) && !defined(CONFIG_SOC_TMS3206457)
> +			/* We can now check the negotiation results */
> +			if ((mdios.macsel == DEVSTAT_MACSEL_GMII) ||
> +			    (mdios.macsel == DEVSTAT_MACSEL_RGMII)) {
> +				mdio_phy_read(MDIO_PHY_REG_1000CONTROL,
> +					      mdios.phy_addr);
> +				mdio_phy_wait_res(valgig);
> +				mdio_phy_read(MDIO_PHY_REG_1000STATUS,
> +					      mdios.phy_addr);
> +				mdio_phy_wait_res(valgig2);
> +			}
> +#endif
> +			mdio_phy_read(MDIO_PHY_REG_ADVERTISE, mdios.phy_addr);
> +			mdio_phy_wait_res(val);
> +			mdio_phy_read(MDIO_PHY_REG_PARTNER, mdios.phy_addr);
> +			mdio_phy_wait_res(val2);
> +
> +			val2 &= val;
> +#if !(defined(CONFIG_SOC_TMS3206472) || defined(CONFIG_SOC_TMS3206474)) && !defined(CONFIG_SOC_TMS3206457)
> +			if ((valgig & MDIO_PHY_ADV_FD1000) &&
> +			    (valgig2 & MDIO_PHY_PRT_FD1000))
> +				mdios.pending_status = MDIO_LINKSTATUS_FD1000;
> +			else if (val2 & MDIO_PHY_B_AFD100)
> +				mdios.pending_status = MDIO_LINKSTATUS_FD100;
> +#else
> +			if (val2 & MDIO_PHY_B_AFD100)
> +				mdios.pending_status = MDIO_LINKSTATUS_FD100;
> +#endif
> +			else if (val2 & MDIO_PHY_B_AHD100)
> +				mdios.pending_status = MDIO_LINKSTATUS_HD100;
> +			else if (val2 & MDIO_PHY_B_AFD10)
> +				mdios.pending_status = MDIO_LINKSTATUS_FD10;
> +			else if (val2 & MDIO_PHY_B_AHD10)
> +				mdios.pending_status = MDIO_LINKSTATUS_HD10;
> +			else if (val & MDIO_PHY_B_AHD100)
> +				mdios.pending_status = MDIO_LINKSTATUS_HD100;
> +			else
> +				mdios.pending_status = MDIO_LINKSTATUS_HD10;
> +
> +			mdios.phy_state = MDIO_PHY_LINKWAIT;
> +
> +		case MDIO_PHY_LINKWAIT:
> +			/* Waiting for LINK */
> +			mdio_phy_read(MDIO_PHY_REG_STATUS, mdios.phy_addr);
> +			mdio_phy_wait_res_ack(val, ack);
> +			if (!ack) {
> +				mdio_init_state_machine();
> +				break;
> +			}
> +
> +			if (!(val & MDIO_PHY_B_LINKSTATUS))
> +				goto check_timeout;
> +
> +			/* Make sure we're linked in the MDIO module as well */
> +			lval = mdio_get_reg(MDIO_LINK);
> +			if (!(lval & (1 << mdios.phy_addr)))
> +				goto check_timeout;
> +
> +			/* Start monitoring this PHY */
> +			mdio_set_reg(MDIO_USERPHYSEL0, mdios.phy_addr);
> +
> +			/* Clear the link change flag so we can detect a "re-link" later */
> +			mdio_set_reg(MDIO_LINKINTRAW, 1);
> +
> +			/* Setup our linked state */
> +			mdios.phy_state   = MDIO_PHY_LINKED;
> +			mdios.link_status = mdios.pending_status;
> +			res = MDIO_EVENT_LINKUP;
> +			break;
> +		}
> +	}
> +	return res;
> +}
