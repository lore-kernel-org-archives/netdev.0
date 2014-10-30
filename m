From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH] net: gianfar: fix dma check map error when DMA_API_DEBUG
 is enabled
Date: Thu, 30 Oct 2014 18:28:01 +0200
Message-ID: <54526711.1080505@freescale.com>
References: <1414664727-21988-1-git-send-email-haokexin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: Kevin Hao <haokexin@gmail.com>, <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0112.outbound.protection.outlook.com ([157.56.110.112]:15410
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759765AbaJ3Q2d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 12:28:33 -0400
In-Reply-To: <1414664727-21988-1-git-send-email-haokexin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2014 12:25 PM, Kevin Hao wrote:

[...]

> @@ -2406,6 +2416,25 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   	spin_unlock_irqrestore(&tx_queue->txlock, flags);
>
>   	return NETDEV_TX_OK;
> +
> +dma_map_err:
> +	txbdp = next_txbd(txbdp_start, base, tx_queue->tx_ring_size);
> +	if (do_tstamp)
> +		txbdp = next_txbd(txbdp, base, tx_queue->tx_ring_size);
> +	for (i = 0; i < nr_frags; i++) {
> +		lstatus = txbdp->lstatus;
> +		if (!(lstatus & BD_LFLAG(TXBD_READY)))
> +			break;
> +
> +		txbdp->lstatus = lstatus & ~BD_LFLAG(TXBD_READY);
> +		bufaddr = txbdp->bufPtr;
> +		dma_unmap_page(priv->dev, bufaddr, txbdp->length,
> +			       DMA_TO_DEVICE);
> +		txbdp = next_txbd(txbdp, base, tx_queue->tx_ring_size);
> +	}
> +	gfar_wmb();

Why use the wmb() memory barrier here?

> +	dev_kfree_skb_any(skb);
> +	return NETDEV_TX_OK;
>   }
>

[...]

Hi Dave,

The patch seems ok at first glance (except a minor comment) but I'd like 
to have it tested first because it modifies sensitive code.
I can re-send it to netdev later, after we're done testing it.
Maybe it would be better to stack up a few more gianfar fixes in the 
meantime and send them all to netdev as a pull request, later on.

Thanks,
Claudiu
