From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] wireless: adf702x: new driver for ADF7020/21 parts
Date: Tue, 22 Dec 2009 03:44:09 +0000
Message-ID: <1261453449.25157.367.camel@localhost>
References: <1261447929-17106-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org,
	Michael Hennerich <michael.hennerich@analog.com>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:47484 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbZLVDoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 22:44:19 -0500
In-Reply-To: <1261447929-17106-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-12-21 at 21:12 -0500, Mike Frysinger wrote:
> From: Michael Hennerich <michael.hennerich@analog.com>
> 
> This is a driver for Analog Devices series of ADF702x Narrow-Band
> Short-Range Radio Transceiver chipsets, including the ADF7021 and
> the ADF7025.  This Ethernet like driver implements a custom
> software PHY.
[...]
> diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
> index 56dd665..57974ac 100644
> --- a/drivers/net/wireless/Kconfig
> +++ b/drivers/net/wireless/Kconfig
> @@ -44,6 +44,17 @@ config LIBERTAS_THINFIRM_USB
>  	---help---
>  	  A driver for Marvell Libertas 8388 USB devices using thinfirm.
>  
> +config ADF702X
> +	tristate "ADF702x Narrow-Band Short-Range Radio Transceiver"
> +	depends on EXPERIMENTAL && SPI && BLACKFIN

Any particular reason this should be EXPERIMENTAL?

[...]
> diff --git a/drivers/net/wireless/adf702x.c b/drivers/net/wireless/adf702x.c
> new file mode 100644
> index 0000000..ada0cb9
> --- /dev/null
> +++ b/drivers/net/wireless/adf702x.c
[...]
> +struct adf702x_priv {
> +	struct spi_device *spi;
> +	struct net_device *ndev;
> +	struct sk_buff *tx_skb;
> +	struct delayed_work tx_work;
> +	struct work_struct tx_done_work;
> +	wait_queue_head_t waitq;
> +	dma_addr_t dma_handle;
> +	spinlock_t lock;
> +	unsigned rx_preample:1;

Shouldn't this be named "rx_preamble" ("b" not "p")?

> +	unsigned rx:1;
> +	unsigned rx_size;
> +	u32 *rx_buf;
> +	u32 *tx_buf;
> +
> +	/* Base reg base of SPORT controller */
> +	volatile struct sport_register *sport;

MMIO pointers should normally be declared like:

	struct sport_register __iomem *sport;

and used with readl, writel etc.

[...]
> +#define MAGIC		(0xA54662DA)

You could choose a more meaningful name for this!

[...]
> +/*
> + * ONES: A instruction only DSPs feature
> + * a XOR b -> return counted ONES (BIT Errors)
> + */
> +static inline unsigned short adf702x_xor_ones(unsigned int a, unsigned int b)
> +{
> +	unsigned short val;
> +
> +	__asm__ __volatile__ (
> +				"%0 = %1 ^ %2;"
> +				"%0.l = ONES %0;"
> +				: "=d"(val) : "d"(a), "d"(b)
> +				);
> +	return val;
> +}

This could be written as hweight16(a ^ b).  I don't think the hweight
functions have optimised implementations for Blackfin, but you can fix
that.

[...]
> +/*
> + * Get Packet size from header
> + * Returns: size or 42 in case of an unrecoverable error
> + */
> +inline unsigned short adf702x_getrxsize(struct adf702x_priv *lp, int offset)

Should be declared static inline, not just inline.

> +{
> +	int size = adf702x_getsymbol(lp->rx_buf[offset + 1]) << 8 |
> +			adf702x_getsymbol(lp->rx_buf[offset + 2]);
> +
> +	if (size > 0)
> +		return size;
> +
> +	DBG(1, "%s :BITERR\n", __func__);
> +	lp->ndev->stats.rx_errors++;
> +	return 64;	/* Keep the Receiver busy for some time */

64 != 42

[...]
> +static int adf702x_net_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct adf702x_priv *lp = netdev_priv(dev);
> +	unsigned char *buf_ptr = skb->data;
> +	int i;
> +	unsigned char delay;
> +
> +	DBG(2, "%s: %s(): transmitting %d bytes\n",
> +		 dev->name, __func__, skb->len);
> +
> +	if (!skb->len)
> +		return 0;

I don't think this is possible.

> +	/* Only one packet at a time. Once TXDONE interrupt is serviced, the
> +	 * queue will be restarted.
> +	 */
> +	netif_stop_queue(dev);
> +	/* save the timestamp */
> +	lp->ndev->trans_start = jiffies;

Don't set trans_start; the networking core does this now.

> +	/* Remember the skb for deferred processing */
> +	lp->tx_skb = skb;
> +
> +	BUG_ON(lp->tx_skb->len > 0xFFFF);

If you're going to make assertions about the length, it would probably
be more useful to check against the packet buffer size.

> +	lp->tx_buf[3] = adf702x_getchip(skb->len >> 8);
> +	lp->tx_buf[4] = adf702x_getchip(skb->len & 0xFF);
> +
> +	DBG(3, "TX TX: ");
> +	for (i = 0; i < skb->len; i++) {
> +		lp->tx_buf[TX_HEADERSIZE + i] = adf702x_getchip(buf_ptr[i]);
> +		DBG(3, "%x ", buf_ptr[i]);
> +	}
> +	DBG(3, "\n");
> +
> +	/* Avoid contentions
> +	 * Schedule transmission randomly (0..64ms)
> +	 * This allows other nodes to snip in
> +	 */
> +
> +	get_random_bytes(&delay, sizeof(delay));
> +	schedule_delayed_work(&lp->tx_work, msecs_to_jiffies(delay >> 2));

get_random_bytes() uses up entropy that should be reserved for
applications that really need it.  Instead of that, I think you should
call random32() and use the most significant bits.

[...]
> +static irqreturn_t adf702x_rx_interrupt(int irq, void *dev_id)
> +{
[...]
> +			lp->rx_size = adf702x_getrxsize(lp, offset);
> +			if (offset == 1) {
> +				set_dma_x_count(lp->dma_ch_rx, lp->rx_size);
> +				set_dma_start_addr(lp->dma_ch_rx,
> +					(unsigned long)lp->rx_buf);
> +			} else {
> +				lp->rx_buf[0] = lp->rx_buf[3];
> +				set_dma_x_count(lp->dma_ch_rx, lp->rx_size - 1);
> +				set_dma_start_addr(lp->dma_ch_rx,
> +					(unsigned long)&lp->rx_buf[1]);
> +			}
> +			enable_dma(lp->dma_ch_rx);
> +			SSYNC();

Is this some odd kind of memory barrier?

[...]
> +static int __devinit adf702x_probe(struct spi_device *spi)
> +{
[...]
> +	/*
> +	 * MAC address? we use a
> +	 * random one ...
> +	 */
> +
> +	random_ether_addr(ndev->dev_addr);

Assuming that the MAC address is not available in non-volatile memory or
set directly by firmware, it should be provided in platform data.

> +	ndev->mtu = 576;

Even though you use Ethernet frames?

> +	ndev->tx_queue_len = 10;
> +	ndev->watchdog_timeo = 0;
> +
> +	err = register_netdev(ndev);
> +	if (err) {
> +		dev_err(&spi->dev, "failed to register netdev\n");
> +		goto out1;
> +	}

Don't register the netdev yet!  It could be brought up immediately, even
though your private structure is not initialised.

[...]
> +	spin_lock_init(&lp->lock);
> +	INIT_DELAYED_WORK(&lp->tx_work, adf702x_tx_work);
> +	INIT_WORK(&lp->tx_done_work, adf702x_tx_done_work);
> +	init_waitqueue_head(&lp->waitq);

...and now you'll be ready to register the netdev.

> +static int __devexit adf702x_remove(struct spi_device *spi)
> +{
> +	struct adf702x_platform_data *pdata = spi->dev.platform_data;
> +	struct net_device *dev = dev_get_drvdata(&spi->dev);
> +	struct adf702x_priv *lp = netdev_priv(dev);

First things first:

	rtnl_lock();
	dev_close(dev);
	unregister_netdevice(dev);
	rtnl_unlock();

> +	dma_free_coherent(NULL, MAX_PACKET_SIZE, lp->rx_buf, lp->dma_handle);
> +	dma_free_coherent(NULL, MAX_PACKET_SIZE, lp->tx_buf, lp->dma_handle);
> +
> +	if (lp->irq_sport_err)
> +		free_irq(lp->irq_sport_err, dev);
> +
> +	gpio_free(lp->gpio_int_rfs);
> +	free_dma(lp->dma_ch_rx);
> +	free_dma(lp->dma_ch_tx);
> +	peripheral_free_list(pdata->pin_req);
> +
> +	unregister_netdev(dev);
[...]

This unregister_netdev() should be replaced by the above additions.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

