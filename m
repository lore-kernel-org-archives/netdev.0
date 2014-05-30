From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1 5/6] net: fec: Add Scatter/gather support
Date: Thu, 29 May 2014 21:37:52 -0700
Message-ID: <1401424672.3645.68.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
	 <1401415552-2263-6-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: b20596@freescale.com, davem@davemloft.net,
	ezequiel.garcia@free-electrons.com, netdev@vger.kernel.org,
	shawn.guo@linaro.org, bhutchings@solarflare.com,
	stephen@networkplumber.org
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:60892 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbaE3Ehy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 00:37:54 -0400
Received: by mail-pa0-f52.google.com with SMTP id bj1so946023pad.39
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 21:37:53 -0700 (PDT)
In-Reply-To: <1401415552-2263-6-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-30 at 10:05 +0800, Fugang Duan wrote:
> Add Scatter/gather support for FEC.
> This feature allows to improve outbound throughput performance.
> Running iperf tests shows a 55.4% improvement, tested on imx6dl sabresd
> board.


> +			bufaddr = fep->tx_bounce[index];
> +		}
> +		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
> +			swap_buffer(bufaddr, frag_len);


bufaddr is a page fragment and can be shared (using sendfile() for
example), we cannot modify the content using swap_buffer().

In order to do the swap, you need to force the copy to tx_bounce buffer.



> +		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, bufaddr,
> +						frag_len, DMA_TO_DEVICE);
> +		if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
> +			dev_kfree_skb_any(skb);
> +			if (net_ratelimit())
> +				netdev_err(ndev, "Tx DMA memory map failed\n");
> +			goto dma_mapping_error;
> +		}
> +
> +		bdp->cbd_datlen = frag_len;
> +		bdp->cbd_sc = status;
> +	}
> +
> +	fep->cur_tx = bdp;
> +
> +	return 0;
> +
> +dma_mapping_error:
>  	bdp = fep->cur_tx;
> +	for (i = 0; i < frag; i++) {
> +		bdp = fec_enet_get_nextdesc(bdp, fep);
> +		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
> +				bdp->cbd_datlen, DMA_TO_DEVICE);
> +	}
> +	return NETDEV_TX_OK;
> +}
>  
> -	status = bdp->cbd_sc;
> +static int fec_enet_txq_submit_skb(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	struct fec_enet_private *fep = netdev_priv(ndev);
> +	const struct platform_device_id *id_entry =
> +				platform_get_device_id(fep->pdev);
> +	int nr_frags = skb_shinfo(skb)->nr_frags;
> +	struct bufdesc *bdp, *last_bdp;
> +	void *bufaddr;
> +	unsigned short status;
> +	unsigned short buflen;
> +	unsigned int estatus = 0;
> +	unsigned int index;
> +	int ret;
>  
>  	/* Protocol checksum off-load for TCP and UDP. */
>  	if (fec_enet_clear_csum(skb, ndev)) {
> @@ -349,17 +462,18 @@ static int txq_submit_skb(struct sk_buff *skb, struct net_device *ndev)
>  		return NETDEV_TX_OK;
>  	}
>  
> -	/* Clear all of the status flags */
> +	/* Fill in a Tx ring entry */
> +	bdp = fep->cur_tx;
> +	status = bdp->cbd_sc;
>  	status &= ~BD_ENET_TX_STATS;
>  
>  	/* Set buffer length and buffer pointer */
>  	bufaddr = skb->data;
> -	bdp->cbd_datlen = skb->len;
> +	buflen = skb_headlen(skb);
>  
>  	index = fec_enet_get_bd_index(bdp, fep);
> -
>  	if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
> -		memcpy(fep->tx_bounce[index], skb->data, skb->len);
> +		memcpy(fep->tx_bounce[index], skb->data, buflen);
>  		bufaddr = fep->tx_bounce[index];
>  	}
>  
> @@ -369,62 +483,66 @@ static int txq_submit_skb(struct sk_buff *skb, struct net_device *ndev)
>  	 * swap every frame going to and coming from the controller.
>  	 */
>  	if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
> -		swap_buffer(bufaddr, skb->len);
> -
> -	/* Save skb pointer */
> -	fep->tx_skbuff[index] = skb;
> +		swap_buffer(bufaddr, buflen);

Same problem here, a driver is certainly not allowed to mess with
skb->data.
