From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next 2/4] net: bcmgenet: return number of packets
 completed in TX reclaim
Date: Fri, 24 Oct 2014 15:20:18 -0700
Message-ID: <CAGXr9JHNRFsXXT+_tfM=ye5k5YwjmJ6s5YP+qaTdGMOLKZxPwA@mail.gmail.com>
References: <1414180942-2132-1-git-send-email-f.fainelli@gmail.com>
	<1414180942-2132-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:45068 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755906AbaJXWUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 18:20:19 -0400
Received: by mail-qc0-f171.google.com with SMTP id m20so1488528qcx.2
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 15:20:18 -0700 (PDT)
In-Reply-To: <1414180942-2132-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Fri, Oct 24, 2014 at 1:02 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> In preparation for reclaiming transmitted buffers in NAPI context,
> update __bcmgenet_tx_reclaim() and bcmgenet_tx_reclaim() to return the
> number of packets completed per call.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 20 +++++++++++++-------
>  1 file changed, 13 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index ee4d5baf09b6..70f2fb366375 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -876,14 +876,14 @@ static inline void bcmgenet_tx_ring_int_disable(struct bcmgenet_priv *priv,
>  }
>
>  /* Unlocked version of the reclaim routine */
> -static void __bcmgenet_tx_reclaim(struct net_device *dev,
> -                                 struct bcmgenet_tx_ring *ring)
> +static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
> +                                         struct bcmgenet_tx_ring *ring)
>  {
>         struct bcmgenet_priv *priv = netdev_priv(dev);
>         int last_tx_cn, last_c_index, num_tx_bds;
>         struct enet_cb *tx_cb_ptr;
>         struct netdev_queue *txq;
> -       unsigned int bds_compl;
> +       unsigned int bds_compl, pkts_compl = 0;

bcmgenet_desc_rx() uses "rxpktprocessed", so I'd go with "txpktprocessed" here.

>         unsigned int c_index;
>
>         /* Compute how many buffers are transmitted since last xmit call */
> @@ -928,6 +928,7 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
>                 }
>                 dev->stats.tx_packets++;
>                 ring->free_bds += bds_compl;
> +               pkts_compl += bds_compl;

This change doesn't look correct. The number of cleaned packets is not
necessarily equal to the number of cleaned TxBDs.

I think that the while-loop should be:

        while (last_tx_cn-- > 0) {
                tx_cb_ptr = ring->cbs + last_c_index;

                if (tx_cb_ptr->skb) {
                        pkts_compl++;
                        dev->stats.tx_packets++;
                        dev->stats.tx_bytes += tx_cb_ptr->skb->len;
                        dma_unmap_single(&dev->dev,
                                         dma_unmap_addr(tx_cb_ptr, dma_addr),
                                         tx_cb_ptr->skb->len,
                                         DMA_TO_DEVICE);
                        bcmgenet_free_cb(tx_cb_ptr);
                } else if (dma_unmap_addr(tx_cb_ptr, dma_addr)) {
                        dev->stats.tx_bytes +=
                                dma_unmap_len(tx_cb_ptr, dma_len);
                        dma_unmap_page(&dev->dev,
                                       dma_unmap_addr(tx_cb_ptr, dma_addr),
                                       dma_unmap_len(tx_cb_ptr, dma_len),
                                       DMA_TO_DEVICE);
                        dma_unmap_addr_set(tx_cb_ptr, dma_addr, 0);
                }
                ring->free_bds++;
                last_c_index++;
                last_c_index &= (num_tx_bds - 1);
        }

>
>                 last_c_index++;
>                 last_c_index &= (num_tx_bds - 1);
> @@ -936,20 +937,25 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
>         if (ring->free_bds > (MAX_SKB_FRAGS + 1))
>                 ring->int_disable(priv, ring);
>
> -       if (netif_tx_queue_stopped(txq))
> +       if (netif_tx_queue_stopped(txq) && pkts_compl)

bcmgenet_xmit() stops the Tx queue when:
ring->free_bds <= (MAX_SKB_FRAGS + 1)

So, shouldn't this check be:
netif_tx_queue_stopped(txq) && (ring->free_bds > (MAX_SKB_FRAGS + 1))

Having said that --
Why does the driver stop the Tx queue when there are still
(MAX_SKB_FRAGS + 1) TxBDs left?
It leaves 17 or so TxBDs unused on the Tx ring, and most of the
packets are not fragmented.

I feel that bcmgenet_xmit() should stop the Tx queue only when there
is 1 TxBD left after putting a new packet on the ring.

>                 netif_tx_wake_queue(txq);
>
>         ring->c_index = c_index;
> +
> +       return pkts_compl;
>  }
>
> -static void bcmgenet_tx_reclaim(struct net_device *dev,
> -                               struct bcmgenet_tx_ring *ring)
> +static unsigned int bcmgenet_tx_reclaim(struct net_device *dev,
> +                                       struct bcmgenet_tx_ring *ring)
>  {
>         unsigned long flags;
> +       unsigned int pkts_compl;
>
>         spin_lock_irqsave(&ring->lock, flags);
> -       __bcmgenet_tx_reclaim(dev, ring);
> +       pkts_compl = __bcmgenet_tx_reclaim(dev, ring);
>         spin_unlock_irqrestore(&ring->lock, flags);
> +
> +       return pkts_compl;
>  }
>
>  static void bcmgenet_tx_reclaim_all(struct net_device *dev)
> --
> 1.9.1
>
