From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [BUG] bcmgenet tx path
Date: Thu, 17 Mar 2016 10:00:24 -0700
Message-ID: <56EAE2A8.5000206@gmail.com>
References: <1458137881.7353.9.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opendmb@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36788 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030907AbcCQRCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 13:02:04 -0400
Received: by mail-pf0-f169.google.com with SMTP id u190so128361468pfb.3
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 10:02:03 -0700 (PDT)
In-Reply-To: <1458137881.7353.9.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On 16/03/16 07:18, Eric Dumazet wrote:
> Hi Florian
> 
> I was looking at drivers/net/ethernet/broadcom/genet/bcmgenet.c
> and found TX completion (__bcmgenet_tx_reclaim()) was freeing skb before
> frags were actually dma unmapped.
> 
> 
> Are you sure this is OK ? bnx2 and bnx2x actually do the reverse (unmap
> all frags before freeing skb)

It does not seem to be much of an issue right now because we put the skb
first, and the frags next in the order we want to transmit them, and we
reclaim in the same order, but it certainly makes more sense to revese
the operation.

> 
> A second problem is the dma_unmap_single() uses tx_cb_ptr->skb->len for
> the length, while it really should be the same thing that was used in
> bcmgenet_xmit_single()

Yes, that is indeed a bug, surprisingly the DMA-API debugging did not
seem to complain about that (should look into why). FWIW, we do not turn
on SG by default, so AFAIR we are not even hitting this path.

Can you submit a formal patch for this and we look into reversing the
mapping of fragments?

Thanks!

> 
> skb_len = skb_headlen(skb) < ETH_ZLEN ? ETH_ZLEN : skb_headlen(skb);
> 
> So maybe something like :
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index d7e01a7..9211b9c7 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1197,7 +1197,7 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
>  			dev->stats.tx_bytes += tx_cb_ptr->skb->len;
>  			dma_unmap_single(&dev->dev,
>  					 dma_unmap_addr(tx_cb_ptr, dma_addr),
> -					 tx_cb_ptr->skb->len,
> +					 dma_unmap_len(tx_cb_ptr, dma_len),
>  					 DMA_TO_DEVICE);
>  			bcmgenet_free_cb(tx_cb_ptr);
>  		} else if (dma_unmap_addr(tx_cb_ptr, dma_addr)) {
> @@ -1308,7 +1308,7 @@ static int bcmgenet_xmit_single(struct net_device *dev,
>  	}
>  
>  	dma_unmap_addr_set(tx_cb_ptr, dma_addr, mapping);
> -	dma_unmap_len_set(tx_cb_ptr, dma_len, skb->len);
> +	dma_unmap_len_set(tx_cb_ptr, dma_len, skb_len);
>  	length_status = (skb_len << DMA_BUFLENGTH_SHIFT) | dma_desc_flags |
>  			(priv->hw_params->qtag_mask << DMA_TX_QTAG_SHIFT) |
>  			DMA_TX_APPEND_CRC;
> 
> 


-- 
Florian
