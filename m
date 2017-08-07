From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] wan: dscc4: add checks for dma mapping errors
Date: Mon, 7 Aug 2017 23:59:43 +0200
Message-ID: <20170807215943.GA22433@electric-eye.fr.zoreil.com>
References: <1501878204-24270-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58719 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751662AbdHGV74 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 17:59:56 -0400
Content-Disposition: inline
In-Reply-To: <1501878204-24270-1-git-send-email-khoroshilov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Khoroshilov <khoroshilov@ispras.ru> :
> The driver does not check if mapping dma memory succeed.
> The patch adds the checks and failure handling.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Please amend your subject line as:

Subject: [PATCH net-next v2 1/1] dscc4: add checks for dma mapping errors.

Rationale: davem is not supposed to guess the branch the patch should be
applied to.

[...]
> diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
> index 799830ffcae2..1a94f0a95b2c 100644
> --- a/drivers/net/wan/dscc4.c
> +++ b/drivers/net/wan/dscc4.c
> @@ -522,19 +522,27 @@ static inline int try_get_rx_skb(struct dscc4_dev_priv *dpriv,
>  	struct RxFD *rx_fd = dpriv->rx_fd + dirty;
>  	const int len = RX_MAX(HDLC_MAX_MRU);
>  	struct sk_buff *skb;
> -	int ret = 0;
> +	dma_addr_t addr;
>  
>  	skb = dev_alloc_skb(len);
>  	dpriv->rx_skbuff[dirty] = skb;
> -	if (skb) {
> -		skb->protocol = hdlc_type_trans(skb, dev);
> -		rx_fd->data = cpu_to_le32(pci_map_single(dpriv->pci_priv->pdev,
> -					  skb->data, len, PCI_DMA_FROMDEVICE));
> -	} else {
> -		rx_fd->data = 0;
> -		ret = -1;
> -	}
> -	return ret;
> +	if (!skb)
> +		goto err_out;
> +
> +	skb->protocol = hdlc_type_trans(skb, dev);
> +	addr = pci_map_single(dpriv->pci_priv->pdev,
> +			      skb->data, len, PCI_DMA_FROMDEVICE);
> +	if (pci_dma_mapping_error(dpriv->pci_priv->pdev, addr))
> +		goto err_free_skb;

Nit: please use a local 'struct pci_dev *pdev = dpriv->pci_priv->pdev;'

[...]
> @@ -1147,14 +1155,22 @@ static netdev_tx_t dscc4_start_xmit(struct sk_buff *skb,
>  	struct dscc4_dev_priv *dpriv = dscc4_priv(dev);
>  	struct dscc4_pci_priv *ppriv = dpriv->pci_priv;
>  	struct TxFD *tx_fd;
> +	dma_addr_t addr;
>  	int next;
>  
> +	addr = pci_map_single(ppriv->pdev, skb->data, skb->len,
> +			      PCI_DMA_TODEVICE);
> +	if (pci_dma_mapping_error(ppriv->pdev, addr)) {
> +		dev_kfree_skb_any(skb);
> +		dev->stats.tx_errors++;

It should read 'dev->stats.tx_dropped++'.

-- 
Ueimor
