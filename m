From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] w5300: add WIZnet W5300 Ethernet driver
Date: Tue, 27 Sep 2011 19:45:23 +0200
Message-ID: <20110927174523.GA12600@electric-eye.fr.zoreil.com>
References: <1316261666-28555-1-git-send-email-kth3321@gmail.com> <CAOkfWjcHxh60D9KvxLfgL0tw9XdPyDN9xr7q+9V+nM6B6g8tDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Taehun Kim <kth3321@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58031 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157Ab1I0Rqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 13:46:44 -0400
Content-Disposition: inline
In-Reply-To: <CAOkfWjcHxh60D9KvxLfgL0tw9XdPyDN9xr7q+9V+nM6B6g8tDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Taehun Kim <kth3321@gmail.com> :
[...]
> Please check this patch. Not only it had been finished testing, but
> also confirmed by WIZnet(http://wiznet.co.kr).

(please don't include 1080 lines of continuous quote)

> If any problems, please let me know.

> WIZnet W5300 is a network chip into which 10/100 Ethernet controller, MAC,
> and TCP/IP are integrated.
> This driver supports just Ethernet function in W5300.
> 
> Signed-off-by: Taehun Kim <kth3321@gmail.com>
> ---
>  drivers/net/Kconfig  |    5 +
>  drivers/net/Makefile |    1 +
>  drivers/net/w5300.c  |  669 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/w5300.h  |  350 ++++++++++++++++++++++++++

The layout has changed. See David Miller's -next tree at :

git://github.com/davem330/net-next.git

It should probably go into drivers/net/ethernet/wiznet.

> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2016,6 +2016,11 @@ config LANTIQ_ETOP
>  	help
>  	  Support for the MII0 inside the Lantiq SoC
>  
> +config W5300
> +	tristate "WIZnet W5300 ethernet driver"
> +	depends on ARM
> +	help

(nit)
	---help---
[...]
> diff --git a/drivers/net/w5300.c b/drivers/net/w5300.c
> new file mode 100644
> index 0000000..fcc2579
> --- /dev/null
> +++ b/drivers/net/w5300.c
[...]
> +#define DRV_VERSION "1.0"
> +#define DRV_RELDATE "Sept 17, 2011"
> +
> +static const char driver_info[] =
> +	KERN_INFO DEV_NAME ": Ethernet driver v" DRV_VERSION "("
> +	DRV_RELDATE ")\n";
> +
> +MODULE_AUTHOR("Taehun Kim <kth3321@gmail.com>");
> +MODULE_DESCRIPTION("WIZnet W5300 Ethernet driver");
> +MODULE_VERSION(DRV_VERSION);
> +MODULE_LICENSE("GPL");
> +
> +/* Transmit timeout, default 5 seconds. */
> +static int watchdog = 5000;
> +module_param(watchdog, int, 0400);
> +MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
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
> +	struct net_device_stats stats;
> +	struct napi_struct napi;
> +	spinlock_t lock;
> +};
> +
> +/* Default MAC address. */
> +static const u8 w5300_defmac[6] = {0x00, 0x08, 0xDC, 0xA0, 0x00, 0x01};

__initdata ?

> +
> +/* Default RX/TX buffer size(KByte). */
> +static const u8 w5300_rxbuf_conf[MAX_SOCK_NUM] = { 64, 0, 0, 0, 0, 0, 0, 0 };
> +static const u8 w5300_txbuf_conf[MAX_SOCK_NUM] = { 64, 0, 0, 0, 0, 0, 0, 0 };

__initdata ?

The size is known: you can save some 0.

> +/* Notifying packet size in the RX FIFO */
> +static int
> +w5300_get_rxsize(struct wiz_private *wp, int s)
> +{
> +	u32 val;
> +
> +	val = w5300_read(wp, Sn_RX_RSR(s));
> +	val = (val << 16) + w5300_read(wp, Sn_RX_RSR2(s));
> +	return val;
> +}
> +
> +/* Packet Receive Function. It reads received packet from the Rx FIFO. */
> +static int
> +w5300_recv_data(struct wiz_private *wp, int s,
> +		u8 *buf, ssize_t len, int swap_enable)

The status code that this method returns is never checked.

> +{
> +	int i;
> +	u16 recv_data;
> +
> +	if (unlikely(len <= 0))
> +		return 0;
> +
> +	if (swap_enable) {
> +		/* read from RX FIFO */
> +		for (i = 0; i < len; i += 2) {
> +			recv_data = w5300_read(wp, Sn_RX_FIFO(s));
> +			buf[i] = (u8) ((recv_data & 0xFF00) >> 8);
> +			buf[i + 1] = (u8) (recv_data & 0x00FF);
> +		}
> +	} else {
> +		for (i = 0; i < len; i += 2) {
> +			recv_data = w5300_read(wp, Sn_RX_FIFO(s));
> +			buf[i] = (u8) (recv_data & 0x00FF);
> +			buf[i + 1] = (u8) ((recv_data & 0xFF00) >> 8);
> +		}
> +	}

You should use le{16/32}_to_cpu, swab16/32 and friends in place of this
'swap_enable' thing.

> +	return len;
> +}
> +
> +/* Setting MAC address of W5300 */
> +static void
> +w5300_set_macaddr(struct wiz_private *wp, u8 * addr)
> +{
> +	w5300_write(wp, SHAR, (u16) (addr[0] << 8) | (u16) addr[1]);
> +	w5300_write(wp, SHAR2, (u16) (addr[2] << 8) | (u16) addr[3]);
> +	w5300_write(wp, SHAR4, (u16) (addr[4] << 8) | (u16) addr[5]);
> +}
> +
> +/* Opening channels of W5300 */
> +static int
> +w5300_open(struct wiz_private *wp, u32 type)

Name it w5300_channel_open or more adequately w5300_channel_0_open 
as it is hardwired to channel 0 ?

The status code that this method returns is never checked.

> +{
> +	/* Which type will be used for open? */
> +	switch (type) {
> +	case Sn_MR_MACRAW:
> +	case Sn_MR_MACRAW_MF:
> +		w5300_write(wp, Sn_MR(0), type);
> +		break;
> +	default:
> +		printk(KERN_ERR "%s: Unknown socket type (%d)\n",
> +		       DEV_NAME, type);
> +		return -EFAULT;
> +	}
> +	w5300_write(wp, Sn_PORTR(0), 5300);
> +
> +	w5300_write(wp, Sn_CR(0), Sn_CR_OPEN);
> +	while (w5300_read(wp, Sn_CR(0)))
> +		udelay(1);
> +
> +	return 0;
> +}
> +
> +/* Activating the interrupt of related channel */
> +static void
> +w5300_interrupt_enable(struct wiz_private *wp, int s)
> +{
> +	u16 mask;
> +	mask = w5300_read(wp, IMR);

Please insert an empty line after the declaration.

> +	mask |= (0x01 << s);
> +	w5300_write(wp, IMR, mask);
> +}

It could imho fit in a single line.

> +
> +/* De-activating the interrupt of related channel */
> +static void
> +w5300_interrupt_disable(struct wiz_private *wp, int s)
> +{
> +	u16 mask;
> +	mask = w5300_read(wp, IMR);
> +	mask &= ~(0x01 << s);
> +	w5300_write(wp, IMR, mask);
> +}
> +
> +/* W5300 initialization function */
> +static int
> +w5300_reset(struct net_device *dev)

The status code that this method returns is never checked.

> +{
> +	struct wiz_private *wp = netdev_priv(dev);
> +	u32 txbuf_total = 0, i;
> +	u16 mem_cfg = 0;
> +
> +	DPRINTK("%s: w5300 chip reset\n", __func__);
> +
> +	/* W5300 is initialized by sending RESET command. */
> +	w5300_write(wp, MR, MR_RST);
> +	mdelay(5);
> +
> +	/* Mode Register Setting
> +	 * Ping uses S/W stack of the Linux kernel. Set the Ping Block.*/
> +	w5300_write(wp, MR, MR_WDF(1) | MR_PB);
> +
> +	/* Setting MAC address */
> +	w5300_set_macaddr(wp, dev->dev_addr);
> +
> +	/* Setting the size of Rx/Tx FIFO */
> +	for (i = 0; i < MAX_SOCK_NUM; ++i) {
> +		if (wp->rxbuf_conf[i] > 64) {
> +			printk(KERN_ERR "%s: Illegal Channel(%d) RX memory size.\n",
> +			       DEV_NAME, i);

You can use nice netif_{err/info/...} helpers.

> +			return -EINVAL;
> +		}
> +		if (wp->txbuf_conf[i] > 64) {
> +			printk(KERN_ERR "%s: Illegal Channel(%d) TX memory size.\n",
> +			       DEV_NAME, i);
> +			return -EINVAL;
> +		}
> +		txbuf_total += wp->txbuf_conf[i];
> +	}
> +
> +	if (txbuf_total % 8) {
> +		printk(KERN_ERR "%s: Illegal memory size register setting.\n",
> +		       DEV_NAME);
> +		return -EINVAL;
> +	}
> +	w5300_write(wp, RMSR0,
> +		    (u16) (wp->rxbuf_conf[0] << 8) | (u16) wp->rxbuf_conf[1]);
> +	w5300_write(wp, RMSR2,
> +		    (u16) (wp->rxbuf_conf[2] << 8) | (u16) wp->rxbuf_conf[3]);
> +	w5300_write(wp, RMSR4,
> +		    (u16) (wp->rxbuf_conf[4] << 8) | (u16) wp->rxbuf_conf[5]);
> +	w5300_write(wp, RMSR6,
> +		    (u16) (wp->rxbuf_conf[6] << 8) | (u16) wp->rxbuf_conf[7]);
> +	w5300_write(wp, TMSR0,
> +		    (u16) (wp->txbuf_conf[0] << 8) | (u16) wp->txbuf_conf[1]);
> +	w5300_write(wp, TMSR2,
> +		    (u16) (wp->txbuf_conf[2] << 8) | (u16) wp->txbuf_conf[3]);
> +	w5300_write(wp, TMSR4,
> +		    (u16) (wp->txbuf_conf[4] << 8) | (u16) wp->txbuf_conf[5]);
> +	w5300_write(wp, TMSR6,
> +		    (u16) (wp->txbuf_conf[6] << 8) | (u16) wp->txbuf_conf[7]);

w5300_write expects an u16: the u8 will be correctly expanded before the shift
even if you remove the casts.

Btw this is nothing more than

	for (i = 0; i < 4; i++) {
		u16 size = (wp->rxbuf_conf[2*i] << 8) | wp->rxbuf_conf[2*i + 1];

		w5300_write(wp, RMSR0 + 2*i, size);
	}

It may even save a few bytes if you factor it out with a method accepting
{ wp->rxbuf_conf, RMSR0 } (resp. { wp->txbuf_conf, TMSR0 }) as parameters.

> +
> +	/* Setting FIFO Memory Type (TX&RX) */
> +	for (i = 0; i < txbuf_total / 8; ++i) {
> +		mem_cfg <<= 1;
> +		mem_cfg |= 1;
> +	}
> +	w5300_write(wp, MTYPER, mem_cfg);
> +
> +	/* Masking all interrupts */
> +	w5300_write(wp, IMR, 0x0000);
> +
> +	return 0;
> +}
> +
> +/* Interrupt Handler(ISR) */
> +static irqreturn_t
> +wiz_interrupt(int irq, void *dev_instance)
> +{
> +	struct net_device *dev = dev_instance;
> +	struct wiz_private *wp = netdev_priv(dev);
> +	unsigned long isr, ssr;

s/unsigned long/u16/

> +	int s;
> +
> +	isr = w5300_read(wp, IR);
> +
> +	/* Completing all interrupts at a time. */
> +	while (isr) {
> +		w5300_write(wp, IR, isr);
> +
> +		/* Finding the channel to create the interrupt */
> +		s = find_first_bit(&isr, sizeof(u16));
> +		ssr = w5300_read(wp, Sn_IR(s));
> +		/* socket interrupt is cleared. */
> +		w5300_write(wp, Sn_IR(s), ssr);
> +		DPRINTK("%s: ISR = %X, SSR = %X, s = %X\n",
> +			__func__, isr, ssr, s);
> +		if (likely(!s)) {
> +			if (ssr & Sn_IR_RECV) {
> +				/* De-activation of interrupt */
> +				w5300_interrupt_disable(wp, 0);
> +				/* Receiving by polling method */
> +				napi_schedule(&wp->napi);
> +			}
> +		}
> +
> +		/* Is there any interrupt to be processed? */
> +		isr = w5300_read(wp, IR);
> +	}
> +
> +	return IRQ_HANDLED;

The hardware implementation is supposed to enforce that the 'while' is
always entered, right ?

> +}
> +
> +static int
> +wiz_open(struct net_device *dev)
> +{
> +	struct wiz_private *wp = netdev_priv(dev);
> +	int ret;
> +
> +	napi_enable(&wp->napi);
> +
> +	ret = request_irq(dev->irq, wiz_interrupt,
> +			  IRQF_IRQPOLL, dev->name, dev);

Why do you use IRQF_IRQPOLL ?

> +	if (ret < 0) {
> +		printk(KERN_ERR "%s: request_irq() error!\n", DEV_NAME);
> +		return ret;
> +	}
> +
> +	/* Activating the interrupt of channel 0 that is used for MACRAW. */
> +	w5300_interrupt_enable(wp, 0);
> +
> +	/* Sending OPEN command to use channel 0 as MACRAW mode. */
> +	w5300_open(wp, Sn_MR_MACRAW_MF);
> +
> +	netif_start_queue(dev);
> +
> +	return 0;
> +}
> +
> +static int
> +wiz_close(struct net_device *dev)
> +{
> +	struct wiz_private *wp = netdev_priv(dev);
> +
> +	DPRINTK("%s\n", __func__);
> +
> +	napi_disable(&wp->napi);
> +
> +	/* Interrupt masking of all channels */
> +	w5300_write(wp, IMR, 0x0000);
> +	netif_stop_queue(dev);

The upperlayer takes care of netif_stop_queue. It is not needed.

> +	w5300_write(wp, Sn_CR(0), Sn_CR_CLOSE);
> +	free_irq(dev->irq, dev);
> +
> +	return 0;
> +}
> +
> +static int
> +w5300_send_data(struct wiz_private *wp, u8 * buf, ssize_t len)
> +{
> +	int i;
> +	u16 send_data;
> +
> +	/* Writing packets in to Tx FIFO */
> +	for (i = 0; i < len; i += 2) {
> +		send_data = (buf[i] << 8) | buf[i+1];
> +		w5300_write(wp, Sn_TX_FIFO(0), send_data);
> +	}
> +
> +	w5300_write(wp, Sn_TX_WRSR(0), (u16)(len >> 16));
> +	w5300_write(wp, Sn_TX_WRSR2(0), (u16)len);
> +	w5300_write(wp, Sn_CR(0), Sn_CR_SEND);
> +	while (w5300_read(wp, Sn_CR(0)))
> +		udelay(1);
> +
> +	return len;
> +}
> +
> +/* Function to transmit data at the MACRAW mode */
> +static int
> +wiz_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct wiz_private *wp = netdev_priv(dev);
> +	int ret;
> +
> +	DPRINTK("%s: MAC_RAW SEND packet size = %d\n", __func__, skb->len);
> +
> +	ret = w5300_send_data(wp, skb->data, skb->len);
> +
> +	/* Statistical Process */
> +	if (ret < 0) {

Something is pretty wrong if ret (= skb->len) is < 0.

> +		wp->stats.tx_dropped++;
> +	} else {
> +		wp->stats.tx_bytes += skb->len;
> +		wp->stats.tx_packets++;
> +		dev->trans_start = jiffies;
> +	}
> +	dev_kfree_skb(skb);
> +
> +	return 0;

s/0/NETDEV_TX_OK/

> +}
> +
> +static struct net_device_stats *
> +wiz_get_stats(struct net_device *dev)
> +{
> +	struct wiz_private *wp = netdev_priv(dev);
> +	DPRINTK("%s: get status\n", __func__);
> +	return &wp->stats;
> +}
> +
> +/* It is called when multi-cast list or flag is changed. */
> +static void
> +wiz_set_multicast(struct net_device *dev)
> +{
> +	struct wiz_private *wp = netdev_priv(dev);
> +
> +	DPRINTK("%s: multicast\n", __func__);
> +	if (dev->flags & IFF_PROMISC)
> +		w5300_open(wp, Sn_MR_MACRAW);
> +	else
> +		w5300_open(wp, Sn_MR_MACRAW_MF);

Use a ternary operator ?

> +}
> +
> +static int
> +wiz_set_mac_address(struct net_device *dev, void *addr)
> +{
> +	struct wiz_private *wp = netdev_priv(dev);
> +	struct sockaddr *sock_addr = addr;
> +
> +	DPRINTK("%s: set mac address\n", __func__);
> +
> +	spin_lock(&wp->lock);
> +	/* Changing MAC address of W5300 */
> +	w5300_set_macaddr(wp, sock_addr->sa_data);
> +	/* Changing MAC address of material structure to manage W5300 */
> +	memcpy(dev->dev_addr, sock_addr->sa_data, dev->addr_len);
> +	spin_unlock(&wp->lock);
> +
> +	return 0;
> +}
> +
> +static void
> +wiz_tx_timeout(struct net_device *dev)
> +{
> +	struct wiz_private *wp = netdev_priv(dev);
> +	unsigned long flags;
> +
> +	printk(KERN_WARNING "%s: Transmit timeout\n", dev->name);
> +
> +	spin_lock_irqsave(&wp->lock, flags);
> +	/* Initializing W5300 chip. */
> +	w5300_reset(dev);
> +	/* Waking up network interface */
> +	netif_wake_queue(dev);
> +	spin_unlock_irqrestore(&wp->lock, flags);
> +}
> +
> +/*
> + * Polling Function to process only receiving at the MACRAW mode.
> + * De-activating the interrupt when recv interrupt occurs,
> + * and processing the RECEIVE with this Function
> + * Activating the interrupt after completing RECEIVE process
> + * As recv interrupt often occurs at short intervals,
> + * there will system load in case that interrupt handler process the RECEIVE.
> + */
> +static int
> +wiz_rx_poll(struct napi_struct *napi, int budget)
> +{
> +	struct sk_buff *skb;

It should be declared in the 'while' loop below.

> +	struct wiz_private *wp = container_of(napi, struct wiz_private, napi);
> +	struct net_device *dev = wp->dev;
> +	u16 rxbuf_len, pktlen;

These should be declared in the 'while' loop below.
rxbuf_len can go away.

> +	u32 crc;

It should be declared in the 'while' loop below.

> +	int npackets = 0;
> +
> +	/* Processing the RECEIVE during Rx FIFO is containing any packet */
> +	while (w5300_get_rxsize(wp, 0) > 0) {
> +
> +		/* The first 2byte is the information about packet lenth. */
> +		w5300_recv_data(wp, 0, (u8 *)&pktlen, 2, 0);
> +		DPRINTK("%s: pktlen = %d\n", __func__, pktlen);
> +
> +		/*
> +		 * Allotting the socket buffer in which packet will be contained
> +		 * Ethernet packet is of 14byte.
> +		 * In order to make it multiplied by 2, the buffer allocation
> +		 * should be 2bytes bigger than the packet.
> +		 */
> +		skb = dev_alloc_skb(pktlen + 2);

netdev_alloc_skb_ip_align

> +		if (!skb) {
> +			u8 *temp;
> +			printk(KERN_ERR "%s: Memory squeeze, dropping packet.\n",
> +			       dev->name);
> +			temp = kmalloc(pktlen + 4, GFP_KERNEL);

- "Memory squeeze ? Let's allocate more..."
- unchecked kmalloc
- GFP_KERNEL in poll

Either you use an already allocated buffer (it could even be static) or
you loop with a small on-stack buffer.

> +			wp->stats.rx_dropped++;
> +			w5300_recv_data(wp, 0, temp, pktlen + 4, 1);
> +			kfree(temp);
> +			return -ENOMEM;

poll is supposed to return the work actually done, not -Exyz.

> +		}
> +
> +		/* Initializing the socket buffer */
> +		skb->dev = dev;
> +		skb_reserve(skb, 2);
> +		skb_put(skb, pktlen);
> +
> +		/* Reading packets from W5300 Rx FIFO into socket buffer. */
> +		w5300_recv_data(wp, 0, (u8 *)skb->data, pktlen, 1);
> +
> +		/* Reading and discarding 4byte CRC. */
> +		w5300_recv_data(wp, 0, (u8 *)&crc, 4, 0);
> +
> +		/* The packet type is Ethernet. */
> +		skb->protocol = eth_type_trans(skb, dev);
> +
> +		/* Passing packets to uppder stack (kernel). */
> +		netif_receive_skb(skb);
> +
> +		/* Processing statistical information */
> +		wp->stats.rx_packets++;
> +		wp->stats.rx_bytes += pktlen;
> +		wp->dev->last_rx = jiffies;
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
> +		spin_lock_irqsave(&wp->lock, flags);
> +		w5300_interrupt_enable(wp, 0);
> +		__napi_complete(napi);
> +		spin_unlock_irqrestore(&wp->lock, flags);
> +	}
> +	return npackets;
> +}
> +
> +static const struct net_device_ops wiz_netdev_ops = {
> +	.ndo_open       = wiz_open,
> +	.ndo_stop       = wiz_close,
> +	.ndo_validate_addr      = eth_validate_addr,
> +	.ndo_set_mac_address    = wiz_set_mac_address,
> +	.ndo_set_multicast_list = wiz_set_multicast,
> +	.ndo_get_stats      = wiz_get_stats,
> +	.ndo_start_xmit     = wiz_start_xmit,
> +	.ndo_tx_timeout     = wiz_tx_timeout,

Please add more tabs and align everything.

> +};
> +
> +/* Initialize W5300 driver. */
> +static int __devinit
> +w5300_drv_probe(struct platform_device *pdev)
> +{
> +	struct net_device *dev;
> +	struct wiz_private *wp;
> +	struct resource *res;
> +	void __iomem *addr;
> +	int ret;
> +
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	if (!res) {
> +		ret  = -ENODEV;
> +		goto out;
> +	}
> +
> +	/* Request the chip register regions. */
> +	if (!request_mem_region(res->start, SZ_1M, DEV_NAME)) {
> +		ret = -EBUSY;
> +		goto out;
> +	}
> +
> +	/* Allocatting struct net_device structure which is managing W5300 */
> +	dev = alloc_etherdev(sizeof(struct wiz_private));
> +	if (!dev) {
> +		ret = -ENOMEM;
> +		goto release_region;
> +	}
> +
> +	dev->dma = (unsigned char)-1;
> +	dev->irq = platform_get_irq(pdev, 0);
> +	wp = netdev_priv(dev);
> +	wp->dev = dev;
> +	addr = ioremap(res->start, SZ_1M);
> +	if (!addr) {
> +		ret = -ENOMEM;
> +		goto release_both;
> +	}
> +
> +	platform_set_drvdata(pdev, dev);
> +	wp->base = addr;
> +
> +	spin_lock_init(&wp->lock);
> +
> +	/* Initialization of Rx/Tx FIFO size */
> +	memcpy(wp->rxbuf_conf, w5300_rxbuf_conf, MAX_SOCK_NUM * sizeof(u8));
> +	memcpy(wp->txbuf_conf, w5300_txbuf_conf, MAX_SOCK_NUM * sizeof(u8));

You can spare the sizeof(u8).

> +
> +	dev->base_addr = res->start;

Please leave base_addr rest in peace.

> +	dev->addr_len = 6;	/* MAC address length. */

Useless, it's already done through alloc_etherdev->ether_setup.

> +	memcpy(dev->dev_addr, w5300_defmac, dev->addr_len);
> +
> +	ether_setup(dev);

Useless, see alloc_etherdev.

> +	dev->netdev_ops = &wiz_netdev_ops;
> +	/* Setting napi. Enabling to process max 16 packets at a time. */
> +	netif_napi_add(dev, &wp->napi, wiz_rx_poll, 16);
> +
> +	dev->watchdog_timeo = msecs_to_jiffies(watchdog);
> +
> +	strcpy(dev->name, "eth%d");

Useless.

> +
> +	w5300_reset(dev);
> +
> +	ret = register_netdev(dev);
> +	if (ret != 0) {
> +		platform_set_drvdata(pdev, NULL);
> +		iounmap(addr);
> +release_both:
> +		free_netdev(dev);
> +release_region:
> +		release_resource(res);
> +	}
> +out:
> +	return ret;
> +}
> +
> +static int __devexit
> +w5300_drv_remove(struct platform_device *pdev)
> +{
> +	struct net_device *dev = platform_get_drvdata(pdev);
> +	struct wiz_private *wp = netdev_priv(dev);
> +	struct resource *res;
> +
> +	platform_set_drvdata(pdev, NULL);
> +	unregister_netdev(dev);
> +
> +	if (wp->base != NULL)
> +		iounmap(wp->base);

wp->base can not be NULL here.

> +
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	if (res != NULL)
> +		release_resource(res);

release_resource is supposed to balance request_resource, not
request_mem_resource.

> +
> +	free_netdev(dev);
> +
> +	return 0;
> +}
> +
> +static int
> +w5300_drv_suspend(struct platform_device *pdev, pm_message_t state)
> +{
> +	struct net_device *dev = platform_get_drvdata(pdev);
> +
> +	if (dev) {

Useless.

> +		struct wiz_private *wp = netdev_priv(dev);
> +
> +		if (netif_running(dev)) {
> +			netif_device_detach(dev);
> +			w5300_write(wp, IMR, 0x0000);
> +			w5300_write(wp, Sn_CR(0), Sn_CR_CLOSE);
> +		}
> +	}
> +	return 0;
> +}
> +
> +static int
> +w5300_drv_resume(struct platform_device *pdev)
> +{
> +	struct net_device *dev = platform_get_drvdata(pdev);
> +
> +	if (dev) {

Useless.

> +		struct wiz_private *wp = netdev_priv(dev);
> +
> +		if (netif_running(dev)) {
> +			w5300_reset(dev);
> +			w5300_interrupt_enable(wp, 0);
> +			w5300_open(wp, Sn_MR_MACRAW_MF);
> +			netif_device_attach(dev);
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +static struct platform_driver w5300_driver = {
> +	.probe  = w5300_drv_probe,
> +	.remove = __devexit_p(w5300_drv_remove),
> +	.suspend	 = w5300_drv_suspend,
> +	.resume	 = w5300_drv_resume,
> +	.driver	 = {
> +		.name	 = DEV_NAME,
> +		.owner	= THIS_MODULE,
> +	},

Please fix the alignment and don't mix tabs and space.

> +};
> +
> +static int __init
> +wiz_module_init(void)

I don't get why you do not use the whole line length.

> +{
> +	return platform_driver_register(&w5300_driver);
> +}
> +
> +static void __exit
> +wiz_module_exit(void)
> +{
> +	platform_driver_unregister(&w5300_driver);
> +}
> +
> +module_init(wiz_module_init);
> +module_exit(wiz_module_exit);
> diff --git a/drivers/net/w5300.h b/drivers/net/w5300.h
> new file mode 100644
> index 0000000..d8583be
> --- /dev/null
> +++ b/drivers/net/w5300.h
[...]
> +#define Sn_IR_DISCON    0x02	/**< Disconnect bit of Sn_IR */
> +#define Sn_IR_CON       0x01	/**< Connect bit of Sn_IR */

So far, so good...

> +
> +/* Sn_SSR values */
> +#define SOCK_CLOSED      0x00	/**< SOCKETn is released */
> +#define SOCK_ARP         0x01	/**< ARP-request is transmitted in order to acquire destination hardware address. */
> +#define SOCK_INIT        0x13	/**< SOCKETn is open as TCP mode. */
[...]
> +/* IP PROTOCOL */
> +#define IPPROTO_IP	0	/* Dummy for IP */
> +#define IPPROTO_ICMP	1	/* Control message protocol */
> +#define IPPROTO_IGMP	2	/* Internet group management protocol */
> +#define IPPROTO_GGP	3	/* Gateway^2 (deprecated) */
> +#define IPPROTO_TCP	6	/* TCP */
> +#define IPPROTO_PUP	12	/* PUP */
> +#define IPPROTO_UDP	17	/* UDP */
> +#define IPPROTO_IDP	22	/* XNS idp */
> +#define IPPROTO_ND	77	/* UNOFFICIAL net disk protocol */
> +#define IPPROTO_RAW	255	/* Raw IP packet */

... but you can trim most of those.

No netif_carrier_{on/off} trough the whole driver ?

-- 
Ueimor
