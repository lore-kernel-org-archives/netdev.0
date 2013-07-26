From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net PATCH v2] 8139cp: Add dma_mapping_error checking
Date: Fri, 26 Jul 2013 22:06:30 +0200
Message-ID: <20130726200630.GA20690@electric-eye.fr.zoreil.com>
References: <1374516882-19131-1-git-send-email-nhorman@tuxdriver.com>
 <1374848918-17183-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60686 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab3GZUGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 16:06:44 -0400
Content-Disposition: inline
In-Reply-To: <1374848918-17183-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> :
[...]
> diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
> index 0352345..ba0570a 100644
> --- a/drivers/net/ethernet/realtek/8139cp.c
> +++ b/drivers/net/ethernet/realtek/8139cp.c
> @@ -533,6 +533,11 @@ rx_status_loop:
>  
>  		mapping = dma_map_single(&cp->pdev->dev, new_skb->data, buflen,
>  					 PCI_DMA_FROMDEVICE);
> +		if (dma_mapping_error(&cp->pdev->dev, mapping)) {
> +			kfree_skb(skb);

			dev->stats.rx_dropped++;

Sorry, I did not notice that skb contained newly received data :o/

> +			break;
> +		}
> +
[...]
> @@ -749,6 +754,12 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
>  
>  		len = skb->len;
>  		mapping = dma_map_single(&cp->pdev->dev, skb->data, len, PCI_DMA_TODEVICE);
> +		if (dma_mapping_error(&cp->pdev->dev, mapping)) {
> +			kfree_skb(skb);
> +			cp->dev->stats.tx_dropped++;
> +			goto out_unlock;

These lines appear several times. You may factor them out with a
goto out_drop or such.

> @@ -799,6 +816,21 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
>  			mapping = dma_map_single(&cp->pdev->dev,
>  						 skb_frag_address(this_frag),
>  						 len, PCI_DMA_TODEVICE);
> +			if (dma_mapping_error(&cp->pdev->dev, mapping)) {
> +				/* Unwind the mappnigs we have */
                                                  ^^

> +				for (frag = 0; frag+first_entry < entry; frag++) {
> +					cp->tx_skb[frag+first_entry] = NULL;
> +					txd = &cp->tx_ring[frag+first_entry];
> +					this_frag = &skb_shinfo(skb)->frags[frag];
> +					dma_unmap_single(&cp->pdev->dev, le64_to_cpu(txd->addr),
> +							 skb_frag_size(this_frag), PCI_DMA_TODEVICE);
> +				}

Imho, even with local &cp->pdev->dev and removal of whitespaces, it
calls for a separate xmit_frag helper or an out of line unwinder.

-- 
Ueimor
