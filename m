From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next v2 1/2] net: bcmgenet: update ring producer index
 and buffer count in xmit
Date: Fri, 13 Mar 2015 12:52:05 -0700
Message-ID: <CAGXr9JGrc=aGd026_hLTv3FCOy6fwNksH-85bnRUxMzSTYE4=Q@mail.gmail.com>
References: <1426273867-10874-1-git-send-email-f.fainelli@gmail.com>
	<1426273867-10874-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, edumazet@google.com,
	David Miller <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:38572 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717AbbCMTwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 15:52:06 -0400
Received: by qgdz60 with SMTP id z60so28576239qgd.5
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 12:52:05 -0700 (PDT)
In-Reply-To: <1426273867-10874-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2015 at 12:11 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
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
> Acked-by: Petri Gynther <pgynther@google.com>

Reviewed-by: Petri Gynther <pgynther@google.com>

> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 18 +++++-------------
>  1 file changed, 5 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index d3be1aeb7f47..f59427072a9b 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1130,11 +1130,6 @@ static int bcmgenet_xmit_single(struct net_device *dev,
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
> @@ -1173,11 +1168,6 @@ static int bcmgenet_xmit_frag(struct net_device *dev,
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
> @@ -1321,9 +1311,11 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
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
> 2.1.0
>
