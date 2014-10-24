From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next 4/4] net: bcmgenet: update ring producer index
 and buffer count in xmit
Date: Fri, 24 Oct 2014 15:39:10 -0700
Message-ID: <CAGXr9JE1MLvYnRBCv0DWNvUwBeEqxnugvoY5P8a69sddBhNn-g@mail.gmail.com>
References: <1414180942-2132-1-git-send-email-f.fainelli@gmail.com>
	<1414180942-2132-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:40367 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932622AbaJXWjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 18:39:11 -0400
Received: by mail-qa0-f52.google.com with SMTP id v10so1635628qac.11
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 15:39:10 -0700 (PDT)
In-Reply-To: <1414180942-2132-5-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks good.

On Fri, Oct 24, 2014 at 1:02 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> There is no need to have both bcmgenet_xmit_single() and
> bcmgenet_xmit_frag() perform a free_bds decrement and a prod_index
> increment by one. In case one of these functions fails to map a SKB or
> fragment for transmit, we will return and exit bcmgenet_xmit() with an
> error.
>
> We can therefore safely use our local copy of nr_frags to know by how
> much we should decrement the number of free buffers available, and by
> how much the producer count must be incremented and do this in the tail
> of bcmgenet_xmit().
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Petri Gynther <pgynther@google.com>

> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 18 +++++-------------
>  1 file changed, 5 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index d6f4a7ace05e..3cd8c25a1120 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1012,11 +1012,6 @@ static int bcmgenet_xmit_single(struct net_device *dev,
>
>         dmadesc_set(priv, tx_cb_ptr->bd_addr, mapping, length_status);
>
> -       /* Decrement total BD count and advance our write pointer */
> -       ring->free_bds -= 1;
> -       ring->prod_index += 1;
> -       ring->prod_index &= DMA_P_INDEX_MASK;
> -
>         return 0;
>  }
>
> @@ -1054,11 +1049,6 @@ static int bcmgenet_xmit_frag(struct net_device *dev,
>                     (frag->size << DMA_BUFLENGTH_SHIFT) | dma_desc_flags |
>                     (priv->hw_params->qtag_mask << DMA_TX_QTAG_SHIFT));
>
> -
> -       ring->free_bds -= 1;
> -       ring->prod_index += 1;
> -       ring->prod_index &= DMA_P_INDEX_MASK;
> -
>         return 0;
>  }
>
> @@ -1202,9 +1192,11 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
>
>         skb_tx_timestamp(skb);
>
> -       /* we kept a software copy of how much we should advance the TDMA
> -        * producer index, now write it down to the hardware
> -        */
> +       /* Decrement total BD count and advance our write pointer */
> +       ring->free_bds -= nr_frags + 1;
> +       ring->prod_index += nr_frags + 1;
> +       ring->prod_index &= DMA_P_INDEX_MASK;
> +
>         bcmgenet_tdma_ring_writel(priv, ring->index,
>                                   ring->prod_index, TDMA_PROD_INDEX);
>
> --
> 1.9.1
>
