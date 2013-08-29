From: Rob Herring <rob.herring@calxeda.com>
Subject: Re: [PATCH] xgmac: use bufsz not dma_buf_sz in rx_refill
Date: Thu, 29 Aug 2013 15:24:30 -0500
Message-ID: <521FADFE.7040908@calxeda.com>
References: <20130829201151.GJ8764@redacted.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kyle McMartin <kyle@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp191.iad.emailsrvr.com ([207.97.245.191]:43100 "EHLO
	smtp191.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757351Ab3H2Ubl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 16:31:41 -0400
In-Reply-To: <20130829201151.GJ8764@redacted.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2013 03:11 PM, Kyle McMartin wrote:
> Noticed while debugging another issue that DMA debug turned up, looks
> like commit ef468d23 missed a case when switching to bufsz instead of
> priv->dma_buf_sz? (tbf, the whole handling of DMA buffers seems slightly
> suspect since we're not tracking the size, but trusting the hardware
> between map and unmap...)

Please see my patch series of fixes:

http://www.spinics.net/lists/netdev/msg248076.html

> Signed-off-by: Kyle McMartin <kyle@redhat.com>
> 
> --- a/drivers/net/ethernet/calxeda/xgmac.c
> +++ b/drivers/net/ethernet/calxeda/xgmac.c
> @@ -686,7 +686,7 @@ static void xgmac_rx_refill(struct xgmac_priv *priv)
>  			priv->rx_skbuff[entry] = skb;
>  			paddr = dma_map_single(priv->device, skb->data,
>  					       bufsz, DMA_FROM_DEVICE);
> -			desc_set_buf_addr(p, paddr, priv->dma_buf_sz);
> +			desc_set_buf_addr(p, paddr, bufsz);

This is not right because the h/w wants the size to include the 2 bytes
skipped at the beginning for NET_IP_ALIGN. The h/w may also corrupt 1-7
bytes of data at the head or tail if the frame is not 8 byte aligned and
padded. We are relying that skb allocations are aligned.

Rob
