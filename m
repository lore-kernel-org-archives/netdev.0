From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 13 Jan 2011 14:03:07 +0000
Message-ID: <1294927387.3044.76.camel@localhost>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-01-13 at 19:49 +0800, Po-Yu Chuang wrote:
> From: Po-Yu Chuang <ratbert@faraday-tech.com>
> 
> FTMAC100 Ethernet Media Access Controller supports 10/100 Mbps and
> MII.  This driver has been working on some ARM/NDS32 SoC including
> Faraday A320 and Andes AG101.
[...]
> diff --git a/drivers/net/ftmac100.c b/drivers/net/ftmac100.c
> new file mode 100644
> index 0000000..97d1f8d
> --- /dev/null
> +++ b/drivers/net/ftmac100.c
[...]
> +#include "ftmac100.h"
> +
> +#define USE_NAPI

All new network drivers should use NAPI only, so please remove the
definition of USE_NAPI and change the conditional code to use NAPI
always.

[...]
> +	struct napi_struct	napi;
> +#endif
> +
> +	struct net_device_stats	stats;

There is a net_device_stats structure in the net_device structure; you
should normally use that instead of adding another one.

[...]
> +static int ftmac100_reset(struct ftmac100 *priv)
> +{
> +	struct device *dev = &priv->netdev->dev;
> +	unsigned long flags;
> +	int i;
> +
> +	/* NOTE: reset clears all registers */
> +
> +	spin_lock_irqsave(&priv->hw_lock, flags);
> +	iowrite32(FTMAC100_MACCR_SW_RST, priv->base + FTMAC100_OFFSET_MACCR);
> +	spin_unlock_irqrestore(&priv->hw_lock, flags);
> +
> +	for (i = 0; i < 5; i++) {
> +		int maccr;
> +
> +		spin_lock_irqsave(&priv->hw_lock, flags);
> +		maccr = ioread32(priv->base + FTMAC100_OFFSET_MACCR);
> +		spin_unlock_irqrestore(&priv->hw_lock, flags);
> +		if (!(maccr & FTMAC100_MACCR_SW_RST)) {
> +			/*
> +			 * FTMAC100_MACCR_SW_RST cleared does not indicate
> +			 * that hardware reset completed (what the f*ck).
> +			 * We still need to wait for a while.
> +			 */
> +			usleep_range(500, 1000);

Sleeping here means this must be running in process context.  But you
used spin_lock_irqsave() above which implies you're not sure what the
context is.  One of these must be wrong.

I wonder whether hw_lock is even needed; you seem to acquire and release
it around each PIO (read or write).  This should be unnecessary since
each PIO is atomic.

[...]
> +static int ftmac100_rx_packet(struct ftmac100 *priv, int *processed)
> +{
> +	struct net_device *netdev = priv->netdev;
> +	struct device *dev = &netdev->dev;
> +	unsigned long flags;
> +	struct ftmac100_rxdes *rxdes;
> +	struct sk_buff *skb;
> +	int length;
> +	int copied = 0;
> +	int done = 0;
> +
> +	spin_lock_irqsave(&priv->rx_lock, flags);
> +	rxdes = ftmac100_rx_locate_first_segment(priv);
> +	spin_unlock_irqrestore(&priv->rx_lock, flags);
> +	if (!rxdes)
> +		return 0;
> +
> +	if (unlikely(ftmac100_rx_packet_error(priv, rxdes))) {
> +		spin_lock_irqsave(&priv->rx_lock, flags);
> +		ftmac100_rx_drop_packet(priv);
> +		spin_unlock_irqrestore(&priv->rx_lock, flags);

I think you can also get rid of rx_lock; it's only used in the RX data
path which is already serialised by NAPI.

[...]
> +	netif_rx(skb);
> +#endif
> +
> +	netdev->last_rx = jiffies;

Don't set last_rx; the networking core takes care of it now.

> +	priv->stats.rx_packets++;
> +	priv->stats.rx_bytes += skb->len;

This should be done earlier, so that these stats include packets that
are dropped for any reason.

[...]
> +static int ftmac100_xmit(struct ftmac100 *priv, struct sk_buff *skb,
> +		dma_addr_t map)
> +{
[...]
> +	ftmac100_txdma_start_polling(priv);
> +	spin_unlock_irqrestore(&priv->hw_lock, flags);
> +	netdev->trans_start = jiffies;

Don't set trans_start; the networking core takes care of it now.

[...]
> +static int ftmac100_alloc_buffers(struct ftmac100 *priv)
> +{
> +	int i;
> +
> +	priv->descs = dma_alloc_coherent(priv->dev,
> +		sizeof(struct ftmac100_descs), &priv->descs_dma_addr,
> +		GFP_KERNEL | GFP_DMA);

On x86, GFP_DMA means the memory must be within the ISA DMA range
(< 16 MB).  I don't know quite what it means on ARM but it may not be
what you want.

[...]
> +/******************************************************************************
> + * interrupt handler
> + *****************************************************************************/
> +static irqreturn_t ftmac100_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *netdev = dev_id;
> +	struct device *dev = &netdev->dev;
> +	struct ftmac100 *priv = netdev_priv(netdev);
> +	unsigned long flags;
> +	unsigned int status;
> +	unsigned int imr;
> +
> +	spin_lock_irqsave(&priv->hw_lock, flags);
> +	status = ioread32(priv->base + FTMAC100_OFFSET_ISR);
> +	imr = ioread32(priv->base + FTMAC100_OFFSET_IMR);
> +	spin_unlock_irqrestore(&priv->hw_lock, flags);
> +
> +	status &= imr;
> +	if (status & (FTMAC100_INT_RPKT_FINISH | FTMAC100_INT_NORXBUF)) {
> +		/*
> +		 * FTMAC100_INT_RPKT_FINISH:
> +		 *	RX DMA has received packets into RX buffer successfully
> +		 *
> +		 * FTMAC100_INT_NORXBUF:
> +		 *	RX buffer unavailable
> +		 */
> +#ifdef USE_NAPI
> +		/* Disable interrupts for polling */
> +		ftmac100_disable_rxint(priv);
> +
> +		napi_schedule(&priv->napi);
> +#else
> +		int rx = 0;
> +
> +		while (ftmac100_rx_packet(priv, &rx))
> +			;
> +#endif
> +	}
> +
> +	if (status & FTMAC100_INT_NORXBUF) {
> +		/* RX buffer unavailable */
> +		if (printk_ratelimit())
> +			dev_info(dev, "INT_NORXBUF\n");
> +
> +		priv->stats.rx_over_errors++;
> +	}
> +
> +	if (status & (FTMAC100_INT_XPKT_OK | FTMAC100_INT_XPKT_LOST)) {
> +		/*
> +		 * FTMAC100_INT_XPKT_OK:
> +		 *	 packet transmitted to ethernet successfully
> +		 *
> +		 * FTMAC100_INT_XPKT_LOST:
> +		 *	packet transmitted to ethernet lost due to late
> +		 *	collision or excessive collision
> +		 */
> +		ftmac100_tx_complete(priv);
> +	}

TX completions should also be handled through NAPI if possible.

[...]
> +static int ftmac100_open(struct net_device *netdev)
> +{
> +	struct device *dev = &netdev->dev;
> +	struct ftmac100 *priv = netdev_priv(netdev);
> +	int err;
> +
> +	err = ftmac100_alloc_buffers(priv);
> +	if (err) {
> +		dev_err(dev, "failed to allocate buffers\n");
> +		goto err_alloc;
> +	}
> +
> +	err = request_irq(priv->irq, ftmac100_interrupt, 0, netdev->name,
> +		netdev);
> +	if (err) {
> +		dev_err(dev, "failed to request irq %d\n", priv->irq);
> +		goto err_irq;
> +	}
> +
> +	priv->rx_pointer = 0;
> +	priv->tx_clean_pointer = 0;
> +	priv->tx_pointer = 0;
> +	spin_lock_init(&priv->hw_lock);
> +	spin_lock_init(&priv->rx_lock);
> +	spin_lock_init(&priv->tx_lock);

These locks should be initialised in your probe function.

[...]
> +/******************************************************************************
> + * struct platform_driver functions
> + *****************************************************************************/
> +static int ftmac100_remove(struct platform_device *pdev)
> +{
> +	struct net_device *netdev;
> +	struct ftmac100 *priv;
> +
> +	netdev = platform_get_drvdata(pdev);
> +	if (netdev == NULL)
> +		return 0;
> +
> +	platform_set_drvdata(pdev, NULL);
> +
> +	priv = netdev_priv(netdev);
> +
> +	unregister_netdev(netdev);
[...]

There should be a netif_napi_del() before this.

A general comment: please use netdev_err(), netdev_info() etc. for
logging.  This ensures that both the platform device address and the
network device name appears in the log messages.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
