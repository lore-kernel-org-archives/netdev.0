From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: systemport: Support 64bit statistics
Date: Mon, 17 Jul 2017 12:53:46 -0700
Message-ID: <0199f2dd-5f79-8c45-0c10-0f3bcbe1d9c1@gmail.com>
References: <CACM3AaxXfTeVp5CHXqfmrid9gvBYydZeKjmUr4CB02vPYS4Sng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: kiki good <jqiaoulk@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33894 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751316AbdGQTxt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 15:53:49 -0400
Received: by mail-qt0-f194.google.com with SMTP id 19so7743qty.1
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 12:53:49 -0700 (PDT)
In-Reply-To: <CACM3AaxXfTeVp5CHXqfmrid9gvBYydZeKjmUr4CB02vPYS4Sng@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/2017 12:48 PM, kiki good wrote:
> Hi Florian:
> 
> I have created new patch based on you suggestion.

Please don't mix replies to earlier patches with actual code submissions.

> 
> BTW: When using ndo_get_stats64, ndo_get_stats won't be called,
> therefore, it is unnecessary to keep old bcm_sysport_get_stats64. The
> exact logic could be found in dev_get_stats() at net/core/dev.c.

Yes, which is why there is no harm in keeping bcm_sysport_get_stats, we
can always deprecate it later. The idea is just to minimize the amount
of changes to review.

> 
> Why:
> When using Broadcom Systemport device in 32bit Platform, ifconfig can
> only report up to 4G tx,rx status, which will be wrapped to 0 when the
> number of incoming or outgoing packets exceeds 4G.
> The patch is used to add 64bit support for Broadcom Systemport device
> in 32bit Platform.

Your patch is badly mangled by your email client, please send it with
git send-email to yourself, try to apply it with git am, and only when
you are successful in doing so, submit it upstream.

Since this is a second version of your patch, using [PATCH v2 net-next]
in the subject would be appropriate to indicate that this is not your
first submission/attempt at fixing this.

Thank you

> 
> Signed-off-by: Jianming Qiao <kiki-good@hotmail.com>
> ---
>  drivers/net/ethernet/broadcom/bcmsysport.c | 71 +++++++++++++++++++++---------
>  drivers/net/ethernet/broadcom/bcmsysport.h |  9 +++-
>  2 files changed, 56 insertions(+), 24 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c
> b/drivers/net/ethernet/broadcom/bcmsysport.c
> index 5274501..5c17965 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
> @@ -662,6 +662,7 @@ static int bcm_sysport_alloc_rx_bufs(struct
> bcm_sysport_priv *priv)
>  static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
>   unsigned int budget)
>  {
> + struct bcm_sysport_stats *stats64 = &priv->stats64;
>   struct net_device *ndev = priv->netdev;
>   unsigned int processed = 0, to_process;
>   struct bcm_sysport_cb *cb;
> @@ -765,6 +766,10 @@ static unsigned int bcm_sysport_desc_rx(struct
> bcm_sysport_priv *priv,
>   skb->protocol = eth_type_trans(skb, ndev);
>   ndev->stats.rx_packets++;
>   ndev->stats.rx_bytes += len;
> + u64_stats_update_begin(&stats64->syncp);
> + stats64->rx_packets++;
> + stats64->rx_bytes += len;
> + u64_stats_update_end(&stats64->syncp);
> 
>   napi_gro_receive(&priv->napi, skb);
>  next:
> @@ -784,24 +789,31 @@ static void bcm_sysport_tx_reclaim_one(struct
> bcm_sysport_tx_ring *ring,
>         unsigned int *pkts_compl)
>  {
>   struct bcm_sysport_priv *priv = ring->priv;
> + struct bcm_sysport_stats *stats64 = &priv->stats64;
>   struct device *kdev = &priv->pdev->dev;
> + unsigned int len = 0;
> 
>   if (cb->skb) {
> - ring->bytes += cb->skb->len;
> - *bytes_compl += cb->skb->len;
> + len = cb->skb->len;
> + *bytes_compl += len;
>   dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
>   dma_unmap_len(cb, dma_len),
>   DMA_TO_DEVICE);
> - ring->packets++;
>   (*pkts_compl)++;
>   bcm_sysport_free_cb(cb);
>   /* SKB fragment */
>   } else if (dma_unmap_addr(cb, dma_addr)) {
> - ring->bytes += dma_unmap_len(cb, dma_len);
> + len =  dma_unmap_len(cb, dma_len);
>   dma_unmap_page(kdev, dma_unmap_addr(cb, dma_addr),
>         dma_unmap_len(cb, dma_len), DMA_TO_DEVICE);
>   dma_unmap_addr_set(cb, dma_addr, 0);
>   }
> +
> + u64_stats_update_begin(&stats64->syncp);
> + ring->bytes += len;
> + if (cb->skb)
> + ring->packets++;
> + u64_stats_update_end(&stats64->syncp);
>  }
> 
>  /* Reclaim queued SKBs for transmission completion, lockless version */
> @@ -1671,23 +1683,6 @@ static int bcm_sysport_change_mac(struct
> net_device *dev, void *p)
>   return 0;
>  }
> 
> -static struct net_device_stats *bcm_sysport_get_nstats(struct net_device *dev)
> -{
> - struct bcm_sysport_priv *priv = netdev_priv(dev);
> - unsigned long tx_bytes = 0, tx_packets = 0;
> - struct bcm_sysport_tx_ring *ring;
> - unsigned int q;
> -
> - for (q = 0; q < dev->num_tx_queues; q++) {
> - ring = &priv->tx_rings[q];
> - tx_bytes += ring->bytes;
> - tx_packets += ring->packets;
> - }
> -
> - dev->stats.tx_bytes = tx_bytes;
> - dev->stats.tx_packets = tx_packets;
> - return &dev->stats;
> -}
> 
>  static void bcm_sysport_netif_start(struct net_device *dev)
>  {
> @@ -1923,6 +1918,37 @@ static int bcm_sysport_stop(struct net_device *dev)
>   return 0;
>  }
> 
> +static void bcm_sysport_get_stats64(struct net_device *dev,
> +    struct rtnl_link_stats64 *stats)
> +{
> + struct bcm_sysport_priv *priv = netdev_priv(dev);
> + struct bcm_sysport_stats *stats64 = &priv->stats64;
> + struct bcm_sysport_tx_ring *ring;
> + u64 tx_packets = 0, tx_bytes = 0;
> + unsigned int start;
> + unsigned int q;
> +
> + netdev_stats_to_stats64(stats, &dev->stats);
> +
> + for (q = 0; q < dev->num_tx_queues; q++) {
> + ring = &priv->tx_rings[q];
> + do {
> + start = u64_stats_fetch_begin_irq(&stats64->syncp);
> + tx_bytes += ring->bytes;
> + tx_packets += ring->packets;
> + } while (u64_stats_fetch_retry_irq(&stats64->syncp, start));
> + }
> +
> + stats->tx_packets = tx_packets;
> + stats->tx_bytes = tx_bytes;
> +
> + do {
> + start = u64_stats_fetch_begin_irq(&stats64->syncp);
> + stats->rx_packets = stats64->rx_packets;
> + stats->rx_bytes = stats64->rx_bytes;
> + } while (u64_stats_fetch_retry_irq(&stats64->syncp, start));
> +}
> +
>  static const struct ethtool_ops bcm_sysport_ethtool_ops = {
>   .get_drvinfo = bcm_sysport_get_drvinfo,
>   .get_msglevel = bcm_sysport_get_msglvl,
> @@ -1950,7 +1976,7 @@ static int bcm_sysport_stop(struct net_device *dev)
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>   .ndo_poll_controller = bcm_sysport_poll_controller,
>  #endif
> - .ndo_get_stats = bcm_sysport_get_nstats,
> + .ndo_get_stats64 = bcm_sysport_get_stats64,
>  };
> 
>  #define REV_FMT "v%2x.%02x"
> @@ -2137,6 +2163,7 @@ static int bcm_sysport_remove(struct
> platform_device *pdev)
>   dev_set_drvdata(&pdev->dev, NULL);
> 
>   return 0;
> +
>  }
> 
>  #ifdef CONFIG_PM_SLEEP
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h
> b/drivers/net/ethernet/broadcom/bcmsysport.h
> index 77a51c1..3480865 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.h
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.h
> @@ -657,6 +657,9 @@ struct bcm_sysport_stats {
>   enum bcm_sysport_stat_type type;
>   /* reg offset from UMAC base for misc counters */
>   u16 reg_offset;
> + u64     rx_packets;
> + u64     rx_bytes;
> + struct u64_stats_sync   syncp;
>  };
> 
>  /* Software house keeping helper structure */
> @@ -693,8 +696,8 @@ struct bcm_sysport_tx_ring {
>   struct bcm_sysport_cb *cbs; /* Transmit control blocks */
>   struct dma_desc *desc_cpu; /* CPU view of the descriptor */
>   struct bcm_sysport_priv *priv; /* private context backpointer */
> - unsigned long packets; /* packets statistics */
> - unsigned long bytes; /* bytes statistics */
> + u64 packets; /* packets statistics */
> + u64 bytes;/* bytes statistics */
>  };
> 
>  /* Driver private structure */
> @@ -743,5 +746,7 @@ struct bcm_sysport_priv {
> 
>   /* Ethtool */
>   u32 msg_enable;
> + /* 64bit stats on 32bit Machine */
> + struct bcm_sysport_stats stats64;
>  };
>  #endif /* __BCM_SYSPORT_H */
> 


-- 
Florian
