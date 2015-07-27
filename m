From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] ravb: minimize TX data copying
Date: Mon, 27 Jul 2015 08:47:37 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB6C651@AcuExch.aculab.com>
References: <6916181.NMDRL3LUfS@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>
To: 'Sergei Shtylyov' <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.190]:61718 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbbG0IuE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:50:04 -0400
In-Reply-To: <6916181.NMDRL3LUfS@wasted.cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov
> Sent: 25 July 2015 21:42
> Renesas Ethernet AVB controller requires that all data are aligned on 4-byte
> boundary.  While it's  easily achievable for  the RX  data with  the help of
> skb_reserve() (we even align on 128-byte boundary as recommended by the manual),
> we  can't  do the same with the TX data, and it always comes  unaligned from
> the networking core. Originally we solved it an easy way, copying all packet
> to  a  preallocated  aligned buffer; however, it's enough to copy only up to
> 3 first bytes from each packet, doing the transfer using 2 TX descriptors
> instead of just 1. Here's an implementation of the new  TX algorithm that
> significantly reduces the driver's memory requirements.
> 
...
> -	buffer = PTR_ALIGN(priv->tx_buffers[q][entry], RAVB_ALIGN);
> -	memcpy(buffer, skb->data, skb->len);
> -	desc = &priv->tx_ring[q][entry];
> -	desc->ds_tagl = cpu_to_le16(skb->len);
> -	dma_addr = dma_map_single(&ndev->dev, buffer, skb->len, DMA_TO_DEVICE);
> +	buffer = PTR_ALIGN(priv->tx_align[q], DPTR_ALIGN) +
> +		 entry / NUM_TX_DESC * DPTR_ALIGN;

The above would be clearer if tx_align was char[DPTR_ALIGN][].

> +	len = PTR_ALIGN(skb->data, DPTR_ALIGN) - skb->data;
> +	memcpy(buffer, skb->data, len);

Does this imply there has been an skb_linearize() ???
The old version didn't really need it (it was doing a copy anyway).

> +	dma_addr = dma_map_single(&ndev->dev, buffer, len, DMA_TO_DEVICE);
>  	if (dma_mapping_error(&ndev->dev, dma_addr))
>  		goto drop;
> +
> +	desc = &priv->tx_ring[q][entry];
> +	desc->ds_tagl = cpu_to_le16(len);
> +	desc->dptr = cpu_to_le32(dma_addr);
> +
> +	buffer = skb->data + len;
> +	len = skb->len - len;
> +	dma_addr = dma_map_single(&ndev->dev, buffer, len, DMA_TO_DEVICE);
> +	if (dma_mapping_error(&ndev->dev, dma_addr))
> +		goto unmap;
> +
> +	desc++;
> +	desc->ds_tagl = cpu_to_le16(len);

What happens if a fragment is less than DPTR_ALIGN bytes ???
Actually is looks like you relying on having a linear skb.

On systems with expensive dma_map it might be worth copying
small fragments.

	David
