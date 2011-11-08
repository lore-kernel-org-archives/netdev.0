From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] W5300: Add WIZnet W5300 Ethernet driver
Date: Tue, 8 Nov 2011 19:09:28 +0000
Message-ID: <1320779368.2799.55.camel@bwh-desktop>
References: <1320676661-19138-1-git-send-email-kth3321@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <suhwan@wiznet.co.kr>,
	<bongbong@wiznet.co.kr>
To: Taehun Kim <kth3321@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320676661-19138-1-git-send-email-kth3321@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-11-07 at 23:37 +0900, Taehun Kim wrote: 
> I have modified W5300 driver by applying the David Miller's feedback
> (http://www.spinics.net/lists/netdev/msg177862.html).
> 
> Please review this driver and apply it if do not have any problems.
[...] 
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
> index 6dff5a0..6325d85 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -173,5 +173,6 @@ source "drivers/net/ethernet/tundra/Kconfig"
>  source "drivers/net/ethernet/via/Kconfig"
>  source "drivers/net/ethernet/xilinx/Kconfig"
>  source "drivers/net/ethernet/xircom/Kconfig"
> +source "drivers/net/ethernet/wiznet/Kconfig"
>  
>  endif # ETHERNET
> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
> index c53ad3a..7bd5211 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -72,3 +72,4 @@ obj-$(CONFIG_NET_VENDOR_TUNDRA) += tundra/
>  obj-$(CONFIG_NET_VENDOR_VIA) += via/
>  obj-$(CONFIG_NET_VENDOR_XILINX) += xilinx/
>  obj-$(CONFIG_NET_VENDOR_XIRCOM) += xircom/
> +obj-$(CONFIG_NET_VENDOR_WIZNET) += wiznet/

These two files currently include their subdirectories in (mostly)
alphabetical order, so please maintain that.

> diff --git a/drivers/net/ethernet/wiznet/Kconfig b/drivers/net/ethernet/wiznet/Kconfig
> new file mode 100644
> index 0000000..b5925bd
> --- /dev/null
> +++ b/drivers/net/ethernet/wiznet/Kconfig
> @@ -0,0 +1,32 @@
> +#
> +# WIZnet device configuration
> +#
> +
> +config NET_VENDOR_WIZNET
> +	bool "WIZnet devices"
> +	default y

I don't think this should have 'default y'.  The other vendor Kconfig
files have 'default y' for compatibility with old kernel config files.

It should possibly have 'depends on ARM'.

> +	---help---
> +	  If you have a network (Ethernet) card belonging to this class, say Y
> +	  and read the Ethernet-HOWTO, available from
> +	  <http://www.tldp.org/docs.html#howto>.
> +
> +	  Note that the answer to this question doesn't directly affect the
> +	  kernel: saying N will just cause the configurator to skip all
> +	  the questions about WIZnet devices. If you say Y, you will be asked for
> +	  your specific card in the following questions.
> +
> +if NET_VENDOR_WIZNET
> +
> +config W5300
> +	tristate "WIZnet W5300 Ethernet support"
> +	depends on ARM
> +	---help---
> +	  This driver supports the Ethernet in the WIZnet W5300 chips.
> +	  W5300 supports hardwired TCP/IP stack. But this driver is limited to
> +	  the Ethernet function. To use hardwired TCP/IP stack, need to modify
> +	  the TCP/IP stack in linux kerenl.

Don't mention features that don't exist in this driver.  Just the first
line is enough.

> +	  To compile this driver as a module, choose M here: the module
> +	  will be called w5300.
> +
> +endif # NET_VENDOR_WIZNET
> diff --git a/drivers/net/ethernet/wiznet/Makefile b/drivers/net/ethernet/wiznet/Makefile
> new file mode 100644
> index 0000000..53120bc
> --- /dev/null
> +++ b/drivers/net/ethernet/wiznet/Makefile
> @@ -0,0 +1,5 @@
> +#
> +# Makefile for the WIZnet device drivers.
> +#
> +
> +obj-$(CONFIG_W5300) += w5300.o
> diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
> new file mode 100644
> index 0000000..6fe3b57
> --- /dev/null
> +++ b/drivers/net/ethernet/wiznet/w5300.c
> @@ -0,0 +1,697 @@
> +/* w5300.c: A Linux Ethernet driver for the WIZnet W5300 chip. */
> +/*
> +  Copyright (C) 2011 Taehun Kim <kth3321@gmail.com>
> +
> +  This software may be used and distributed according to the terms of
> +  the GNU General Public License (GPL), incorporated herein by reference.

Which version.

> +  Drivers based on or derived from this code fall under the GPL and must
> +  retain the authorship, copyright and license notice.  This file is not
> +  a complete program and may only be used when the entire operating
> +  system is licensed under the GPL.

I think that condition is problematic.  'The operating system' may be
taken to include more than just the kernel, but kernel developers have
not attempted to put any restriction on licencing of user-space.

> +*/
[...] 
> +/* Transmit timeout, default 5 seconds. */
> +static int watchdog = 5000;
> +module_param(watchdog, int, 0400);
> +MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");

Is it really necessary for this to be configurable?

> +static int debug = -1;
> +module_param(debug, int, 0);
> +MODULE_PARM_DESC(debug, "W5300: bitmapped message enable number");
> +
> +/*
> + * This is W5300 information structure.
> + * Additional information is included in struct net_device.
> + */
> +struct wiz_private {
> +	void __iomem *base;
> +	struct net_device *dev;
> +	u8 rxbuf_conf[MAX_SOCK_NUM];
> +	u8 txbuf_conf[MAX_SOCK_NUM];
> +	struct napi_struct napi;
> +	spinlock_t lock;
> +	u32 msg_enable;
> +};
> +
> +/* Default MAC address. */
> +static __initdata u8 w5300_defmac[6] = {0x00, 0x08, 0xDC, 0xA0, 0x00, 0x01};

This is not suitable as a default MAC address.

> +/* Default RX/TX buffer size(KByte). */
> +static u8 w5300_rxbuf_conf[MAX_SOCK_NUM] __initdata = {
> +	64, 0, 0, 0, 0, 0, 0, 0
> +};
> +
> +static u8 w5300_txbuf_conf[MAX_SOCK_NUM] __initdata = {
> +	64, 0, 0, 0, 0, 0, 0, 0
> +};

These are used in device initialisation so they should be __devinitdata,
not __initdata.  But also, they aren't changed anywhere so they should
be declared const and __devinitconst.

Though really I can't see why you need these arrays at all when you are
only using one channel.

[...]
> +/* Opening channels of W5300 */
> +static int w5300_channel_open(struct wiz_private *wp, u32 type)
> +{
> +	int timeout = 1000;
> +
> +	/* Which type will be used for open? */
> +	switch (type) {
> +	case Sn_MR_MACRAW:
> +	case Sn_MR_MACRAW_MF:
> +		w5300_write(wp, Sn_MR(0), type);
> +		break;
> +	default:
> +		netif_err(wp, ifup, wp->dev,
> +				"Unknown socket type (%d)\n", type);

Wouldn't this case indicate a bug in the driver?  In which case you
should use BUG().

> +		return -EFAULT;

EFAULT means that user-space passed an invalid memory address.

> +	}
> +
> +	w5300_write(wp, Sn_CR(0), Sn_CR_OPEN);
> +
> +	while (timeout--) {
> +		if (!w5300_read(wp, Sn_CR(0)))
> +			return 0;
> +		udelay(1);
> +	}
> +
> +	return -EBUSY;
> +}
[...] 
> +/* W5300 initialization function */
> +static int w5300_reset(struct net_device *dev)
> +{
[...]
> +	/* Setting the size of Rx/Tx FIFO */
> +	for (i = 0; i < MAX_SOCK_NUM; ++i) {
> +		if (wp->rxbuf_conf[i] > 64) {
> +			netif_err(wp, drv, wp->dev,
> +			"Illegal Channel(%d) RX memory size.\n", i);
> +
> +			return -EINVAL;
> +		}
> +		if (wp->txbuf_conf[i] > 64) {
> +			netif_err(wp, drv, wp->dev,
> +			"Illegal Channel(%d) TX memory size.\n", i);
> +
> +			return -EINVAL;
> +		}
> +		txbuf_total += wp->txbuf_conf[i];
> +	}
> +
> +	if (txbuf_total % 8) {
> +		netif_err(wp, drv, wp->dev,
> +			      "Illegal memory size register setting.\n");
> +
> +		return -EINVAL;
> +	}

Again, an invalid buffer configuration would be a bug in the driver and
not a run-time configuration error, so use BUG_ON() instead.

[...]
> +/* Interrupt Handler(ISR) */
> +static irqreturn_t wiz_interrupt(int irq, void *dev_instance)
> +{
> +	struct net_device *dev = dev_instance;
> +	struct wiz_private *wp = netdev_priv(dev);
> +	int timeout = 100;
> +	u16 isr, ssr;
> +	int s;
> +
> +	isr = w5300_read(wp, IR);
> +
> +	/* Completing all interrupts at a time. */
> +	while (isr && timeout--) {

Why would you need to repeat this?  You disable the interrupt 

> +		w5300_write(wp, IR, isr);
> +
> +		/* Finding the channel to create the interrupt */
> +		s = find_first_bit((ulong *)&isr, sizeof(u16));

find_first_bit() is unnecessary in this case; __ffs(isr) should be more
efficient and doesn't require the ugly cast.

Can multiple bits be set in isr, or does the hardware ensure that you
only see one bit set?

> +		ssr = w5300_read(wp, Sn_IR(s));
> +		/* socket interrupt is cleared. */
> +		w5300_write(wp, Sn_IR(s), ssr);
> +
> +		netif_dbg(wp, intr, wp->dev,
> +			"ISR = %X, SSR = %X, s = %X\n",
> +			isr, ssr, s);
> +
> +		if (likely(!s)) {
> +			if (ssr & Sn_IR_RECV) {
> +				/* Interrupt disable. */
> +				w5300_interrupt_disable(wp);
> +				/* Receiving by polling method */
> +				napi_schedule(&wp->napi);

These comments are redundant.

> +			}
> +		}
> +
> +		/* Is there any interrupt to be processed? */
> +		isr = w5300_read(wp, IR);
> +	}
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static int wiz_open(struct net_device *dev)
> +{
> +	struct wiz_private *wp = netdev_priv(dev);
> +	int ret;
> +
> +	napi_enable(&wp->napi);
> +
> +	ret = request_irq(dev->irq, wiz_interrupt, IRQF_SHARED,
> +			dev->name, dev);
> +	if (ret < 0) {
> +		netif_err(wp, ifup, wp->dev, "request_irq() error!\n");
> +		return ret;
> +	}
> +
> +	w5300_interrupt_enable(wp);
> +
> +	/* Sending OPEN command to use channel 0 as MACRAW mode. */
> +	ret = w5300_channel_open(wp, Sn_MR_MACRAW_MF);
> +	if (ret < 0) {
> +		netif_err(wp, ifup, wp->dev, "w5300 channel open fail!\n");
> +		return ret;

You need to tear down the interrupt in this case.

> +	}
> +
> +	netif_carrier_on(dev);

Either implement link detection or don't.  But don't fake it by calling
netif_carrier_{on,off}() in control functions.

> +	netif_start_queue(dev);
> +
> +	return 0;
> +}
> +
> +static int wiz_close(struct net_device *dev)
> +{
> +	struct wiz_private *wp = netdev_priv(dev);
> +	int timeout = 1000;
> +
> +	napi_disable(&wp->napi);
> +	netif_carrier_off(dev);
> +
> +	/* Interrupt masking of all channels */
> +	w5300_write(wp, IMR, 0x0000);
> +	w5300_write(wp, Sn_CR(0), Sn_CR_CLOSE);
> +
> +	while (timeout--) {
> +		if (!w5300_read(wp, Sn_CR(0)))
> +			break;
> +		udelay(1);
> +	}

You need to call synchronize_irq() between masking the interrupt sources
and calling free_irq(), otherwise this can race with the interrupt
handler on an SMP system.

> +	free_irq(dev->irq, dev);
> +
> +	return 0;
> +}
[...]
> +/* Function to transmit data at the MACRAW mode */
> +static int wiz_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct wiz_private *wp = netdev_priv(dev);
> +	int ret;
> +
> +	ret = w5300_send_data(wp, skb->data, skb->len);
> +
> +	/* Statistical Process */
> +	if (ret < 0) {
> +		dev->stats.tx_dropped++;

Will the hardware generate an interrupt when there is space in the TX
FIFO?  If so then you should use netif_{stop,wake}_queue() to avoid
dropping packets.

> +	} else {
> +		dev->stats.tx_bytes += skb->len;
> +		dev->stats.tx_packets++;
> +		dev->trans_start = jiffies;

Don't update trans_start; that's not the driver's responsibility any more.

> +		netif_dbg(wp, tx_done, wp->dev,
> +			"tx done, packet size = %d\n", skb->len);
> +	}
> +	dev_kfree_skb(skb);
> +
> +	return NETDEV_TX_OK;
> +}
[...]
> +/* It is called when multi-cast list or flag is changed. */
> +static void wiz_set_multicast(struct net_device *dev)
> +{
> +	struct wiz_private *wp = netdev_priv(dev);
> +	int ret;
> +	u32 type = dev->flags & IFF_PROMISC ? Sn_MR_MACRAW : Sn_MR_MACRAW_MF;
> +
> +	ret = w5300_channel_open(wp, type);
> +	if (ret < 0) {
> +		netif_err(wp, ifup, wp->dev,
> +			"w5300 channel open fail!\n");
> +	}
> +}

You don't seem to be adjusting multicast filtering.

> +static int wiz_set_mac_address(struct net_device *dev, void *addr)
> +{
> +	struct wiz_private *wp = netdev_priv(dev);
> +	struct sockaddr *sock_addr = addr;
> +
> +	netif_dbg(wp, drv, wp->dev, "set mac address");
> +
> +	spin_lock(&wp->lock);
> +	w5300_set_macaddr(wp, sock_addr->sa_data);
> +	memcpy(dev->dev_addr, sock_addr->sa_data, dev->addr_len);
> +	spin_unlock(&wp->lock);
> +
> +	return 0;
> +}

You're supposed to validate the address with is_valid_ether_addr().

This is called in process context so it needs to use
spin_{,un}lock_bh().  Though I'm not sure what you think this lock is
protecting, as it's not used in any sort of consistent way.

> +static void wiz_tx_timeout(struct net_device *dev)
> +{
> +	struct wiz_private *wp = netdev_priv(dev);
> +	unsigned long flags;
> +
> +	netif_dbg(wp, timer, wp->dev, "Transmit timeout");
> +
> +	spin_lock_irqsave(&wp->lock, flags);
> +
> +	/* Initializing W5300 chip. */
> +	if (w5300_reset(dev) < 0) {
> +		netif_err(wp, timer, wp->dev, "w5300 reset fail!\n");
> +		return;
> +	}
> +
> +	/* Waking up network interface */
> +	netif_wake_queue(dev);
> +	spin_unlock_irqrestore(&wp->lock, flags);
> +}

This can never be called because you never stop the TX queue.

And since you do not implement link detection, it is impossible for the
TX watchdog to work properly.

> +/*
> + * Polling Function to process only receiving at the MACRAW mode.
> + * De-activating the interrupt when recv interrupt occurs,
> + * and processing the RECEIVE with this Function
> + * Activating the interrupt after completing RECEIVE process
> + * As recv interrupt often occurs at short intervals,
> + * there will system load in case that interrupt handler process the RECEIVE.
> + */
> +static int wiz_rx_poll(struct napi_struct *napi, int budget)
> +{
> +	struct wiz_private *wp = container_of(napi, struct wiz_private, napi);
> +	struct net_device *dev = wp->dev;
> +	int npackets = 0;
> +
> +	/* Processing the RECEIVE during Rx FIFO is containing any packet */
> +	while (w5300_get_rxsize(wp, 0) > 0) {
> +		struct sk_buff *skb;
> +		u16 rxbuf_len, pktlen;
> +		u32 crc;
> +
> +		/* The first 2byte is the information about packet lenth. */
> +		w5300_recv_data(wp, 0, (u8 *)&pktlen, 2);
> +		pktlen = be16_to_cpu(pktlen);
> +
> +		netif_dbg(wp, rx_err, wp->dev, "pktlen = %d\n", pktlen);
> +
> +		/*
> +		 * Allotting the socket buffer in which packet will be contained
> +		 * Ethernet packet is of 14byte.
> +		 * In order to make it multiplied by 2, the buffer allocation

You mean, in order to align the network header on a multiple of *4*.

> +		 * should be 2bytes bigger than the packet.
> +		 */
> +		skb = netdev_alloc_skb_ip_align(dev, pktlen);
> +		if (!skb) {
> +			u8 temp[pktlen + 4];

No, you mustn't allocate arbitary amounts of stack space like this!
Either pre-allocate a discard buffer when the device is opened, or
change w5300_recv_data() so that it can work without a buffer to write
to.

> +			dev->stats.rx_dropped++;
> +			w5300_recv_data(wp, 0, temp, pktlen + 4);
> +			continue;
> +		}
> +
> +		/* Initializing the socket buffer */
> +		skb->dev = dev;
> +		skb_reserve(skb, 2);

netdev_alloc_skb_ip_align() already reserves padding for alignment.

> +		skb_put(skb, pktlen);
> +
> +		/* Reading packets from W5300 Rx FIFO into socket buffer. */
> +		w5300_recv_data(wp, 0, (u8 *)skb->data, pktlen);
> +
> +		/* Reading and discarding 4byte CRC. */
> +		w5300_recv_data(wp, 0, (u8 *)&crc, 4);
> +		crc = be32_to_cpu(crc);

Does the MAC discard packets with a bad CRC?  If not, you have to do
that here.

> +		/* The packet type is Ethernet. */
> +		skb->protocol = eth_type_trans(skb, dev);
> +
> +		/* Passing packets to uppder stack (kernel). */
> +		netif_receive_skb(skb);
> +
> +		/* Processing statistical information */
> +		dev->stats.rx_packets++;
> +		dev->stats.rx_bytes += pktlen;
> +		dev->last_rx = jiffies;
> +		rxbuf_len -= pktlen;
> +		npackets++;
> +
> +		if (npackets >= budget)
> +			break;
> +	}
> +
> +	/* If packet number is smaller than budget when getting out of loopback,
> +	 * the RECEIVE process is completed. */
> +	if (npackets < budget) {
> +		unsigned long flags;
> +
> +		spin_lock_irqsave(&wp->lock, flags);
> +		w5300_interrupt_enable(wp);
> +		__napi_complete(napi);

You must enable interrupts only after marking the NAPI context complete,
otherwise there is a race condition where the NAPI context will not be
rescheduled by an interrupt.

> +		spin_unlock_irqrestore(&wp->lock, flags);

This is always called in tasklet ('bottom half') context, so just use
spin_{,un}lock().

Again, I'm not sure what you think you're protecting here.  You probably
do need locking to serialise calls to
w5300_interrupt_{disable,enable}(), but you're not doing so
consistently.

[...]
> +/* Initialize W5300 driver. */
> +static int __devinit w5300_drv_probe(struct platform_device *pdev)
> +{
[...]
> +	wp->msg_enable = (debug < 0 ? W5300_DEF_MSG_ENABLE : debug);

Why not just initialise debug to W5300_DEF_MSG_ENABLE and set
wp->msg_enable = debug here?

[...]
> +	ret = w5300_reset(dev);
> +	if (ret < 0)
> +		goto release_both;

At this point you need to free the MMIO mapping on error.

> +	ret = register_netdev(dev);
> +	if (ret != 0) {
> +		platform_set_drvdata(pdev, NULL);
> +		iounmap(addr);
> +release_both:
> +		free_netdev(dev);
> +release_region:
> +		release_mem_region(res->start, resource_size(res));
> +	}
> +out:
> +	return ret;
> +}
[...]
> +#ifdef CONFIG_PM
> +
> +static int w5300_drv_suspend(struct platform_device *pdev, pm_message_t state)
> +{
> +	struct net_device *dev = platform_get_drvdata(pdev);
> +
> +	if (dev) {
> +		struct wiz_private *wp = netdev_priv(dev);
> +
> +		if (netif_running(dev)) {
> +			int timeout = 1000;
> +
> +			netif_carrier_off(dev);
> +			netif_device_detach(dev);

Even if you do implement link detection, there is no need to call
netif_carrier_off() here.

[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/wiznet/w5300.h
> @@ -0,0 +1,121 @@
> +#ifndef	_W5300_H_
> +#define	_W5300_H_
> +
> +/* Maximum socket number. W5300 supports max 8 channels. */
> +#define MAX_SOCK_NUM	8
> +
> +/* socket register */
> +#define CH_BASE		(0x200)

Please refer consistently to channels, not sockets.  The in-tree driver
will never be using the TCP offload functionality of the device.

[...]
> +/* W5300 Register READ/WRITE funtions(Just 16 bit interface). */
> +#define w5300_write(wp, addr, val) writew(val, (wp->base + addr))
> +#define w5300_read(wp, addr) readw((wp->base + addr))

This is not how you write safe macro definitions.  You generally need to
put parentheses directly around references to the parameters, not the
expressions that use them:

#define w5300_write(wp, addr, val) writew(val, (wp)->base + (addr))
#define w5300_read(wp, addr) readw((wp)->base + (addr))

Ben.

> +#endif /* _W5300_H_ */

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
