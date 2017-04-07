From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 11/12] ftgmac100: Add support for fragmented tx
Date: Fri, 7 Apr 2017 06:26:36 -0700
Message-ID: <13383518-1602-e3e4-3ac5-4d44ac91be20@gmail.com>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
 <20170407033105.29558-12-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33182 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755455AbdDGN0k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 09:26:40 -0400
Received: by mail-it0-f67.google.com with SMTP id w11so7527093itb.0
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 06:26:39 -0700 (PDT)
In-Reply-To: <20170407033105.29558-12-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/06/2017 08:31 PM, Benjamin Herrenschmidt wrote:
> Add NETIF_F_SG and create multiple TX ring entries for skb fragments.
> 
> On reclaim, the skb is only freed on the segment marked as "last".
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> 
[snip]
>  
> -	dma_unmap_single(priv->dev, map, skb_headlen(skb), DMA_TO_DEVICE);
> +		if (skb_shinfo(skb)->nr_frags == 0 && len < ETH_ZLEN)
> +			len = ETH_ZLEN;

This is where skb_put_padto() would help you eliminate this test since
you'd be dealing skb->len >= ETH_ZLEN.

> +		dma_unmap_single(priv->dev, map, len, DMA_TO_DEVICE);
> +	} else {
> +		dma_unmap_page(priv->dev, map,
> +			       ftgmac100_txdes_get_buffer_size(txdes),
> +			       DMA_TO_DEVICE);
> +	}
>  
> -	dev_kfree_skb(skb);
> +	if (ftgmac100_txdes_get_last_segment(txdes))
> +		dev_kfree_skb(skb);

This makes you do an uncached access to the descriptor, right? is there
a way you could use bookeeping information to free the last fragment?

>  	priv->tx_skbs[pointer] = NULL;
>  
>  	/* Clear txdes0 except end of ring bit, clear txdes1 as we
> @@ -623,10 +642,9 @@ static void ftgmac100_tx_complete(struct ftgmac100 *priv)
>  static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
>  				     struct net_device *netdev)
>  {
> -	unsigned int len = (skb->len < ETH_ZLEN) ? ETH_ZLEN : skb->len;
>  	struct ftgmac100 *priv = netdev_priv(netdev);
> -	struct ftgmac100_txdes *txdes;
> -	unsigned int pointer;
> +	struct ftgmac100_txdes *txdes, *first;
> +	unsigned int pointer, nfrags, len, i, j;
>  	dma_addr_t map;
>  
>  	/* The HW doesn't pad small frames */
> @@ -642,26 +660,35 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
>  		goto drop;
>  	}
>  
> -	map = dma_map_single(priv->dev, skb->data, skb_headlen(skb), DMA_TO_DEVICE);
> -	if (unlikely(dma_mapping_error(priv->dev, map))) {
> -		/* drop packet */
> +	/* Do we have a limit on #fragments ? I yet have to get a reply
> +	 * from Aspeed. If there's one I haven't hit it.
> +	 */
> +	nfrags = skb_shinfo(skb)->nr_frags;
> +
> +	/* Get header len and pad for non-fragmented packets */
> +	len = skb_headlen(skb);
> +	if (nfrags == 0 && len < ETH_ZLEN)
> +		len = ETH_ZLEN;

Same here skb_put_padto() would eliminate the test.

[snip]

>  
> + dma_err:
> +	if (net_ratelimit())
> +		netdev_err(netdev, "map tx fragment failed\n");

You may consider adding a software counter that tracks mapping failures
(few drivers do that) in a subsequent set of changes.
-- 
Florian
