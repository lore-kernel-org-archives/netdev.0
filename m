From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] Broadcom Sysport: Support 64bit net status report on
 32bit Platform
Date: Sat, 15 Jul 2017 10:04:00 -0700
Message-ID: <60cf14dc-d5f6-fe1a-6cdb-9316808ebf12@gmail.com>
References: <MWHPR19MB16139F2DAAD0BA622A6FF1EBE1A20@MWHPR19MB1613.namprd19.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
To: ?? ? <kiki-good@hotmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34356 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751088AbdGOREC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Jul 2017 13:04:02 -0400
Received: by mail-oi0-f67.google.com with SMTP id d77so13585861oig.1
        for <netdev@vger.kernel.org>; Sat, 15 Jul 2017 10:04:01 -0700 (PDT)
In-Reply-To: <MWHPR19MB16139F2DAAD0BA622A6FF1EBE1A20@MWHPR19MB1613.namprd19.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/2017 08:20 AM, ?? ? wrote:
> When using Broadcom Sysport device in 32bit Platform, ifconfig can only report up to 4G
> tx,rx status, which will be wrapped to 0 when the number of incoming or outgoing 
> packets exceeds 4G. 

The subject of this patch should be:

net: systemport: Support 64bit statistics

to be consistent with past submissions done to that driver and it should
be Broadcom SYSTEMPORT, Sysport is just the abbreviated name for the driver.

> 
> Signed-off-by: Jianming Qiao <kiki-good@hotmail.com>
> ---
>  drivers/net/ethernet/broadcom/bcmsysport.c | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---------------------
>  drivers/net/ethernet/broadcom/bcmsysport.h |  8 ++++++++
>  2 files changed, 68 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
> index 5274501..263512f 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
> @@ -663,6 +663,7 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
>  					unsigned int budget)
>  {
>  	struct net_device *ndev = priv->netdev;
> +	struct bcmsysport_netstats *bsysport_netstats = priv->bsysport_netstats;

Please keep the reverse christmas tree declarations order, from longest
to shortest and I am not a fan of the name "bsysort_netstats" it's
already in the driver private structure, so just name the new member
"stats64" for instance, see at the very bottom for a complete suggestion.

>  	unsigned int processed = 0, to_process;
>  	struct bcm_sysport_cb *cb;
>  	struct sk_buff *skb;
> @@ -763,8 +764,10 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
>  		}
>  
>  		skb->protocol = eth_type_trans(skb, ndev);
> -		ndev->stats.rx_packets++;
> -		ndev->stats.rx_bytes += len;
> +		u64_stats_update_begin(&bsysport_netstats->syncp);
> +		bsysport_netstats->rx_packets++;
> +		bsysport_netstats->rx_bytes += len;
> +		u64_stats_update_end(&bsysport_netstats->syncp);
>  
>  		napi_gro_receive(&priv->napi, skb);
>  next:
> @@ -785,19 +788,26 @@ static void bcm_sysport_tx_reclaim_one(struct bcm_sysport_tx_ring *ring,
>  {
>  	struct bcm_sysport_priv *priv = ring->priv;
>  	struct device *kdev = &priv->pdev->dev;
> +	struct bcmsysport_netstats *bsysport_netstats = priv->bsysport_netstats;
>  
>  	if (cb->skb) {
> +		u64_stats_update_begin(&bsysport_netstats->syncp);
>  		ring->bytes += cb->skb->len;
> +		u64_stats_update_end(&bsysport_netstats->syncp);
>  		*bytes_compl += cb->skb->len;
>  		dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
>  				 dma_unmap_len(cb, dma_len),
>  				 DMA_TO_DEVICE);
> +		u64_stats_update_begin(&bsysport_netstats->syncp);
>  		ring->packets++;
> +		u64_stats_update_end(&bsysport_netstats->syncp);
>  		(*pkts_compl)++;
>  		bcm_sysport_free_cb(cb);
>  	/* SKB fragment */
>  	} else if (dma_unmap_addr(cb, dma_addr)) {
> +		u64_stats_update_begin(&bsysport_netstats->syncp);
>  		ring->bytes += dma_unmap_len(cb, dma_len);
> +		u64_stats_update_end(&bsysport_netstats->syncp);
>  		dma_unmap_page(kdev, dma_unmap_addr(cb, dma_addr),
>  			       dma_unmap_len(cb, dma_len), DMA_TO_DEVICE);
>  		dma_unmap_addr_set(cb, dma_addr, 0);

Can you find a way to avoid putting 3 different
u64_stats_update_begin()/end() sections and instead just one, that would
be clearer.

> @@ -1671,23 +1681,6 @@ static int bcm_sysport_change_mac(struct net_device *dev, void *p)
>  	return 0;
>  }
>  
> -static struct net_device_stats *bcm_sysport_get_nstats(struct net_device *dev)
> -{
> -	struct bcm_sysport_priv *priv = netdev_priv(dev);
> -	unsigned long tx_bytes = 0, tx_packets = 0;
> -	struct bcm_sysport_tx_ring *ring;
> -	unsigned int q;
> -
> -	for (q = 0; q < dev->num_tx_queues; q++) {
> -		ring = &priv->tx_rings[q];
> -		tx_bytes += ring->bytes;
> -		tx_packets += ring->packets;
> -	}
> -
> -	dev->stats.tx_bytes = tx_bytes;
> -	dev->stats.tx_packets = tx_packets;
> -	return &dev->stats;
> -}

Is there a problem if we keep both get_nstats and get_nstats64?

>  
>  static void bcm_sysport_netif_start(struct net_device *dev)
>  {
> @@ -1923,6 +1916,49 @@ static int bcm_sysport_stop(struct net_device *dev)
>  	return 0;
>  }
>  
> +static int bcm_sysport_init(struct net_device *dev)
> +{
> +	struct bcm_sysport_priv *priv = netdev_priv(dev);
> +
> +	priv->bsysport_netstats = kzalloc(sizeof(*priv->bsysport_netstats),
> +					  GFP_KERNEL);
> +	if (!priv->bsysport_netstats)
> +		return -ENOMEM;
> +
> +	return 0;

This seems unnecessary, just extend bcm_sysport_priv to have the network
stats included in bcm_sysport_priv and do not allocate this structure
separately.

> +}
> +
> +static void bcm_sysport_get_stats64(struct net_device *dev,
> +				    struct rtnl_link_stats64 *stats)
> +{
> +	struct bcm_sysport_priv *priv = netdev_priv(dev);
> +	struct bcmsysport_netstats *bsysport_netstats = priv->bsysport_netstats;
> +	struct bcm_sysport_tx_ring *ring;
> +	unsigned int q;
> +	u64 tx_packets = 0, tx_bytes = 0;
> +	unsigned int start;
> +
> +	netdev_stats_to_stats64(stats, &dev->stats);
> +
> +	for (q = 0; q < dev->num_tx_queues; q++) {
> +		ring = &priv->tx_rings[q];
> +		do {
> +			start = u64_stats_fetch_begin_irq(&bsysport_netstats->syncp);
> +			tx_bytes += ring->bytes;
> +			tx_packets += ring->packets;
> +		} while (u64_stats_fetch_retry_irq(&bsysport_netstats->syncp, start));
> +	}
> +
> +	stats->tx_packets = tx_packets;
> +	stats->tx_bytes = tx_bytes;
> +
> +	do {
> +		start = u64_stats_fetch_begin_irq(&bsysport_netstats->syncp);
> +		stats->rx_packets = bsysport_netstats->rx_packets;
> +		stats->rx_bytes = bsysport_netstats->rx_bytes;
> +	} while (u64_stats_fetch_retry_irq(&bsysport_netstats->syncp, start));
> +}
> +
>  static const struct ethtool_ops bcm_sysport_ethtool_ops = {
>  	.get_drvinfo		= bcm_sysport_get_drvinfo,
>  	.get_msglevel		= bcm_sysport_get_msglvl,
> @@ -1942,6 +1978,7 @@ static int bcm_sysport_stop(struct net_device *dev)
>  static const struct net_device_ops bcm_sysport_netdev_ops = {
>  	.ndo_start_xmit		= bcm_sysport_xmit,
>  	.ndo_tx_timeout		= bcm_sysport_tx_timeout,
> +	.ndo_init		= bcm_sysport_init,
>  	.ndo_open		= bcm_sysport_open,
>  	.ndo_stop		= bcm_sysport_stop,
>  	.ndo_set_features	= bcm_sysport_set_features,
> @@ -1950,7 +1987,7 @@ static int bcm_sysport_stop(struct net_device *dev)
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller	= bcm_sysport_poll_controller,
>  #endif
> -	.ndo_get_stats		= bcm_sysport_get_nstats,
> +	.ndo_get_stats64	= bcm_sysport_get_stats64,
>  };
>  
>  #define REV_FMT	"v%2x.%02x"
> @@ -2126,10 +2163,12 @@ static int bcm_sysport_remove(struct platform_device *pdev)
>  {
>  	struct net_device *dev = dev_get_drvdata(&pdev->dev);
>  	struct device_node *dn = pdev->dev.of_node;
> -
> +	struct bcm_sysport_priv *priv = netdev_priv(dev);
>  	/* Not much to do, ndo_close has been called
>  	 * and we use managed allocations
>  	 */
> +	kfree(priv->bsysport_netstats);
> +	priv->bsysport_netstats = NULL;

Unnecessary.

>  	unregister_netdev(dev);
>  	if (of_phy_is_fixed_link(dn))
>  		of_phy_deregister_fixed_link(dn);
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
> index 77a51c1..29a7442 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.h
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.h
> @@ -697,6 +697,12 @@ struct bcm_sysport_tx_ring {
>  	unsigned long	bytes;		/* bytes statistics */
>  };
>  
> +struct bcmsysport_netstats {
> +	u64	rx_packets;
> +	u64	rx_bytes;
> +	struct u64_stats_sync   syncp;
> +};

As indicated earlier just use a name that is both consistent and shorter:

struct bcm_sysport_stats stats64 would be a better choice.

> +
>  /* Driver private structure */
>  struct bcm_sysport_priv {
>  	void __iomem		*base;
> @@ -743,5 +749,7 @@ struct bcm_sysport_priv {
>  
>  	/* Ethtool */
>  	u32			msg_enable;
> +	/* 64bit stats on 32bit Machine */
> +	struct bcmsysport_netstats *bsysport_netstats;
>  };
>  #endif /* __BCM_SYSPORT_H */
> 

-- 
Florian
