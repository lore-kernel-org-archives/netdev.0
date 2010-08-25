From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH -next-2.6] r6040: Free irq line on error path
Date: Wed, 25 Aug 2010 12:05:08 +0200
Message-ID: <201008251205.09065.florian@openwrt.org>
References: <20100825095755.GA8103@hera.kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Denis Kirjanov <dkirjanov@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60865 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069Ab0HYKHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 06:07:24 -0400
Received: by wyb35 with SMTP id 35so490916wyb.19
        for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 03:07:22 -0700 (PDT)
In-Reply-To: <20100825095755.GA8103@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 25 August 2010 11:57:55 Denis Kirjanov wrote:
> Free irq line on error path.
> 
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>

Acked-by: Florian Fainelli <florian@openwrt.org>


> ---
>  drivers/net/r6040.c |   33 ++++++++++++++++++++-------------
>  1 files changed, 20 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
> index 7d482a2..dc54aff 100644
> --- a/drivers/net/r6040.c
> +++ b/drivers/net/r6040.c
> @@ -751,7 +751,7 @@ static int r6040_open(struct net_device *dev)
>  	ret = request_irq(dev->irq, r6040_interrupt,
>  		IRQF_SHARED, dev->name, dev);
>  	if (ret)
> -		return ret;
> +		goto out;
> 
>  	/* Set MAC address */
>  	r6040_mac_address(dev);
> @@ -759,30 +759,37 @@ static int r6040_open(struct net_device *dev)
>  	/* Allocate Descriptor memory */
>  	lp->rx_ring =
>  		pci_alloc_consistent(lp->pdev, RX_DESC_SIZE, &lp->rx_ring_dma);
> -	if (!lp->rx_ring)
> -		return -ENOMEM;
> +	if (!lp->rx_ring) {
> +		ret = -ENOMEM;
> +		goto err_free_irq;
> +	}
> 
>  	lp->tx_ring =
>  		pci_alloc_consistent(lp->pdev, TX_DESC_SIZE, &lp->tx_ring_dma);
>  	if (!lp->tx_ring) {
> -		pci_free_consistent(lp->pdev, RX_DESC_SIZE, lp->rx_ring,
> -				     lp->rx_ring_dma);
> -		return -ENOMEM;
> +		ret = -ENOMEM;
> +		goto err_free_rx_ring;
>  	}
> 
>  	ret = r6040_up(dev);
> -	if (ret) {
> -		pci_free_consistent(lp->pdev, TX_DESC_SIZE, lp->tx_ring,
> -							lp->tx_ring_dma);
> -		pci_free_consistent(lp->pdev, RX_DESC_SIZE, lp->rx_ring,
> -							lp->rx_ring_dma);
> -		return ret;
> -	}
> +	if (ret)
> +		goto err_free_tx_ring;
> 
>  	napi_enable(&lp->napi);
>  	netif_start_queue(dev);
> 
>  	return 0;
> +
> +err_free_tx_ring:
> +	pci_free_consistent(lp->pdev, TX_DESC_SIZE, lp->tx_ring,
> +			lp->tx_ring_dma);
> +err_free_rx_ring:
> +	pci_free_consistent(lp->pdev, RX_DESC_SIZE, lp->rx_ring,
> +			lp->rx_ring_dma);
> +err_free_irq:
> +	free_irq(dev->irq, dev);
> +out:
> +	return ret;
>  }
> 
>  static netdev_tx_t r6040_start_xmit(struct sk_buff *skb,
