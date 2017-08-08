From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v2] wan: dscc4: add checks for dma mapping errors
Date: Wed, 9 Aug 2017 01:21:47 +0200
Message-ID: <20170808232147.GA27445@electric-eye.fr.zoreil.com>
References: <20170807215943.GA22433@electric-eye.fr.zoreil.com>
 <1502220499-18351-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1502220499-18351-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Khoroshilov <khoroshilov@ispras.ru> :
[...]
> diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
> index 799830f..6a9ffac 100644
> --- a/drivers/net/wan/dscc4.c
> +++ b/drivers/net/wan/dscc4.c
> @@ -518,23 +518,31 @@ static void dscc4_release_ring(struct dscc4_dev_priv *dpriv)
>  static inline int try_get_rx_skb(struct dscc4_dev_priv *dpriv,
>  				 struct net_device *dev)
>  {
> +	struct pci_dev *pdev = dpriv->pci_priv->pdev;
>  	unsigned int dirty = dpriv->rx_dirty%RX_RING_SIZE;
>  	struct RxFD *rx_fd = dpriv->rx_fd + dirty;
>  	const int len = RX_MAX(HDLC_MAX_MRU);

For the edification of the masses, you may follow a strict inverted
xmas tree style (aka longer lines first as long as it does not bug).

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

Use a local struct pci_dev *pdev and it fits on a single line.

At some point it will probably be converted to plain dma api and use a 'd' dev.

[...]
> @@ -1887,16 +1903,22 @@ static struct sk_buff *dscc4_init_dummy_skb(struct dscc4_dev_priv *dpriv)
>  
>  	skb = dev_alloc_skb(DUMMY_SKB_SIZE);
>  	if (skb) {
> +		struct pci_dev *pdev = dpriv->pci_priv->pdev;
>  		int last = dpriv->tx_dirty%TX_RING_SIZE;
>  		struct TxFD *tx_fd = dpriv->tx_fd + last;
> +		dma_addr_t addr;
>  
>  		skb->len = DUMMY_SKB_SIZE;
>  		skb_copy_to_linear_data(skb, version,
>  					strlen(version) % DUMMY_SKB_SIZE);
>  		tx_fd->state = FrameEnd | TO_STATE_TX(DUMMY_SKB_SIZE);
> -		tx_fd->data = cpu_to_le32(pci_map_single(dpriv->pci_priv->pdev,
> -					     skb->data, DUMMY_SKB_SIZE,
> -					     PCI_DMA_TODEVICE));
> +		addr = pci_map_single(pdev, skb->data, DUMMY_SKB_SIZE,
> +				      PCI_DMA_TODEVICE);
> +		if (pci_dma_mapping_error(pdev, addr)) {
> +			dev_kfree_skb_any(skb);
> +			return NULL;
> +		}
> +		tx_fd->data = cpu_to_le32(addr);
>  		dpriv->tx_skbuff[last] = skb;
>  	}
>  	return skb;

It isn't technically wrong but please don't update tx_fd before the mapping
succeeds. It will look marginally better.

Thanks.

-- 
Ueimor
