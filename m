From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3 net-next 2/2] wan: dscc4: convert to plain DMA API
Date: Fri, 11 Aug 2017 23:45:49 +0200
Message-ID: <20170811214549.GA8187@electric-eye.fr.zoreil.com>
References: <1502405721-27738-1-git-send-email-khoroshilov@ispras.ru>
 <1502405721-27738-2-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1502405721-27738-2-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Khoroshilov <khoroshilov@ispras.ru> :
[...]
> diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
> index 8480dbf..a043fb1 100644
> --- a/drivers/net/wan/dscc4.c
> +++ b/drivers/net/wan/dscc4.c
[...]
> @@ -506,8 +506,9 @@ static void dscc4_release_ring(struct dscc4_dev_priv *dpriv)
>  	skbuff = dpriv->rx_skbuff;
>  	for (i = 0; i < RX_RING_SIZE; i++) {
>  		if (*skbuff) {
> -			pci_unmap_single(pdev, le32_to_cpu(rx_fd->data),
> -				RX_MAX(HDLC_MAX_MRU), PCI_DMA_FROMDEVICE);
> +			dma_unmap_single(d, le32_to_cpu(rx_fd->data),
> +					 RX_MAX(HDLC_MAX_MRU),
> +					 DMA_FROM_DEVICE);

					 RX_MAX(HDLC_MAX_MRU), DMA_FROM_DEVICE);

[...]
> @@ -664,8 +665,8 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
>  		goto refill;
>  	}
>  	pkt_len = TO_SIZE(le32_to_cpu(rx_fd->state2));
> -	pci_unmap_single(pdev, le32_to_cpu(rx_fd->data),
> -			 RX_MAX(HDLC_MAX_MRU), PCI_DMA_FROMDEVICE);
> +	dma_unmap_single(d, le32_to_cpu(rx_fd->data),
> +			 RX_MAX(HDLC_MAX_MRU), DMA_FROM_DEVICE);

	dma_unmap_single(d, le32_to_cpu(rx_fd->data), RX_MAX(HDLC_MAX_MRU),
			 DMA_FROM_DEVICE);

[...]
> @@ -782,8 +783,8 @@ static int dscc4_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  
>  	rc = -ENOMEM;
>  
> -	priv->iqcfg = (__le32 *) pci_alloc_consistent(pdev,
> -		IRQ_RING_SIZE*sizeof(__le32), &priv->iqcfg_dma);
> +	priv->iqcfg = (__le32 *)dma_alloc_coherent(&pdev->dev,
> +		IRQ_RING_SIZE*sizeof(__le32), &priv->iqcfg_dma, GFP_KERNEL);

- the cast can go away
- please replace &pdev->dev with a local variable

	priv->iqcfg = dma_alloc_coherent(d, IRQ_RING_SIZE*sizeof(__le32),
					 &priv->iqcfg_dma, GFP_KERNEL);

Same thing for iqtx and iqrx (beware of copy&paste + tx/rx mismatch).

Thanks.

-- 
Ueimor
