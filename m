From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net:fec: fix WARNING caused by lack of calls to
 dma_mapping_error()
Date: Wed, 13 Nov 2013 01:00:53 +0000
Message-ID: <1384304453.3802.62.camel@bwh-desktop.uk.level5networks.com>
References: <1384224889-8316-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <b20596@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Fugang Duan <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50563 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754978Ab3KMBA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 20:00:57 -0500
In-Reply-To: <1384224889-8316-1-git-send-email-B38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-12 at 10:54 +0800, Fugang Duan wrote:
> Enable CONFIG_HAVE_DMA_API_DEBUG, the kernel dump warning:
[...]
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index b2793b9..d93cb0c 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -386,7 +386,11 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  	 */
>  	bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, bufaddr,
>  			FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
> -
> +	if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
> +		bdp->cbd_bufaddr = 0;
> +		netdev_err(ndev, "Tx DMA memory map failed\n");
> +		return NETDEV_TX_OK;

This error path must free the skb.

> +	}
>  	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
>  	 * it's the last BD of the frame, and to put the CRC on the end.
>  	 */
> @@ -1001,6 +1005,9 @@ fec_enet_rx(struct net_device *ndev, int budget)
>  
>  		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, data,
>  				FEC_ENET_TX_FRSIZE, DMA_FROM_DEVICE);
> +		/* here dma mapping shouldn't be error, just avoid kernel dump */
> +		if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr))
> +			netdev_err(ndev, "Rx DMA memory map failed\n");

This is not handling the error.

>  rx_processing_done:
>  		/* Clear the status flags for this buffer */
>  		status &= ~BD_ENET_RX_STATS;
> @@ -1719,6 +1726,11 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
>  
>  		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, skb->data,
>  				FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
> +		if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
> +			fec_enet_free_buffers(ndev);
> +			netdev_err(ndev, "Rx DMA memory map failed\n");
> +			return -ENOMEM;
> +		}
>  		bdp->cbd_sc = BD_ENET_RX_EMPTY;
>  
>  		if (fep->bufdesc_ex) {

Error logging should be rate-limited.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
