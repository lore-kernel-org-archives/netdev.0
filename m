From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH] stmmac: fix init_dma_desc_rings() to handle errors
Date: Fri, 9 Aug 2013 23:51:19 +0400
Message-ID: <CAOJe8K0JasYtXZ7JaMGEYyzp8t=Gwj=p7EZT7=EwLVeERQLZGw@mail.gmail.com>
References: <1392383.ZcinuGX9SF@amdc1032>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>, netdev@vger.kernel.org
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:58738 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030877Ab3HITvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 15:51:20 -0400
Received: by mail-oa0-f43.google.com with SMTP id i10so7404338oag.16
        for <netdev@vger.kernel.org>; Fri, 09 Aug 2013 12:51:19 -0700 (PDT)
In-Reply-To: <1392383.ZcinuGX9SF@amdc1032>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/9/13, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com> wrote:
> In stmmac_init_rx_buffers():
> * add missing handling of dma_map_single() error
> * remove superfluous unlikely() optimization while at it
>
> Add stmmac_free_rx_buffers() helper and use it in dma_free_rx_skbufs().
>
> In init_dma_desc_rings():
> * add missing handling of kmalloc_array() errors
> * fix handling of dma_alloc_coherent() and stmmac_init_rx_buffers() errors
> * make function return an error value on error and 0 on success
>
> In stmmac_open():
> * add handling of init_dma_desc_rings() return value
>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |  111
> ++++++++++++++++++----
>  1 file changed, 92 insertions(+), 19 deletions(-)
>
> Index: b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> ===================================================================
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c	2013-08-08
> 14:36:44.000000000 +0200
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c	2013-08-08
> 15:31:27.015438117 +0200
> @@ -939,15 +939,20 @@ static int stmmac_init_rx_buffers(struct
>
>  	skb = __netdev_alloc_skb(priv->dev, priv->dma_buf_sz + NET_IP_ALIGN,
>  				 GFP_KERNEL);
> -	if (unlikely(skb == NULL)) {
> +	if (!skb) {
>  		pr_err("%s: Rx init fails; skb is NULL\n", __func__);
> -		return 1;
> +		return -ENOMEM;
>  	}
>  	skb_reserve(skb, NET_IP_ALIGN);
>  	priv->rx_skbuff[i] = skb;
>  	priv->rx_skbuff_dma[i] = dma_map_single(priv->device, skb->data,
>  						priv->dma_buf_sz,
>  						DMA_FROM_DEVICE);
> +	if (dma_mapping_error(priv->device, priv->rx_skbuff_dma[i])) {
> +		pr_err("%s: DMA mapping error\n", __func__);
> +		dev_kfree_skb_any(skb);
> +		return -EINVAL;
> +	}

If dma fail here then you can crash in stmmac_free_rx_buffers()
while touching priv->rx_skbuff[i]

>  	p->des2 = priv->rx_skbuff_dma[i];
>
> @@ -958,6 +963,16 @@ static int stmmac_init_rx_buffers(struct
>  	return 0;
>  }
>
> +static void stmmac_free_rx_buffers(struct stmmac_priv *priv, int i)
> +{
> +	if (priv->rx_skbuff[i]) {
> +		dma_unmap_single(priv->device, priv->rx_skbuff_dma[i],
> +				 priv->dma_buf_sz, DMA_FROM_DEVICE);
> +		dev_kfree_skb_any(priv->rx_skbuff[i]);
> +	}
> +	priv->rx_skbuff[i] = NULL;
> +}
> +
>  /**
>   * init_dma_desc_rings - init the RX/TX descriptor rings
>   * @dev: net device structure
> @@ -965,13 +980,14 @@ static int stmmac_init_rx_buffers(struct
>   * and allocates the socket buffers. It suppors the chained and ring
>   * modes.
>   */
> -static void init_dma_desc_rings(struct net_device *dev)
> +static int init_dma_desc_rings(struct net_device *dev)
>  {
>  	int i;
>  	struct stmmac_priv *priv = netdev_priv(dev);
>  	unsigned int txsize = priv->dma_tx_size;
>  	unsigned int rxsize = priv->dma_rx_size;
>  	unsigned int bfsize = 0;
> +	int ret = -ENOMEM;
>
>  	/* Set the max buffer size according to the DESC mode
>  	 * and the MTU. Note that RING mode allows 16KiB bsize.
> @@ -992,34 +1008,60 @@ static void init_dma_desc_rings(struct n
>  							  dma_extended_desc),
>  						   &priv->dma_rx_phy,
>  						   GFP_KERNEL);
> +		if (!priv->dma_erx)
> +			goto err_dma;
> +
>  		priv->dma_etx = dma_alloc_coherent(priv->device, txsize *
>  						   sizeof(struct
>  							  dma_extended_desc),
>  						   &priv->dma_tx_phy,
>  						   GFP_KERNEL);
> -		if ((!priv->dma_erx) || (!priv->dma_etx))
> -			return;
> +		if (!priv->dma_etx) {
> +			dma_free_coherent(priv->device, priv->dma_rx_size *
> +					sizeof(struct dma_extended_desc),
> +					priv->dma_erx, priv->dma_rx_phy);
> +			goto err_dma;
> +		}
>  	} else {
>  		priv->dma_rx = dma_alloc_coherent(priv->device, rxsize *
>  						  sizeof(struct dma_desc),
>  						  &priv->dma_rx_phy,
>  						  GFP_KERNEL);
> +		if (!priv->dma_rx)
> +			goto err_dma;
> +
>  		priv->dma_tx = dma_alloc_coherent(priv->device, txsize *
>  						  sizeof(struct dma_desc),
>  						  &priv->dma_tx_phy,
>  						  GFP_KERNEL);
> -		if ((!priv->dma_rx) || (!priv->dma_tx))
> -			return;
> +		if (!priv->dma_tx) {
> +			dma_free_coherent(priv->device, priv->dma_rx_size *
> +					sizeof(struct dma_desc),
> +					priv->dma_rx, priv->dma_rx_phy);
> +			goto err_dma;
> +		}
>  	}
>
>  	priv->rx_skbuff_dma = kmalloc_array(rxsize, sizeof(dma_addr_t),
>  					    GFP_KERNEL);
> +	if (!priv->rx_skbuff_dma)
> +		goto err_rx_skbuff_dma;
> +
>  	priv->rx_skbuff = kmalloc_array(rxsize, sizeof(struct sk_buff *),
>  					GFP_KERNEL);
> +	if (!priv->rx_skbuff)
> +		goto err_rx_skbuff;
> +
>  	priv->tx_skbuff_dma = kmalloc_array(txsize, sizeof(dma_addr_t),
>  					    GFP_KERNEL);
> +	if (!priv->tx_skbuff_dma)
> +		goto err_tx_skbuff_dma;
> +
>  	priv->tx_skbuff = kmalloc_array(txsize, sizeof(struct sk_buff *),
>  					GFP_KERNEL);
> +	if (!priv->tx_skbuff)
> +		goto err_tx_skbuff;
> +
>  	if (netif_msg_probe(priv)) {
>  		pr_debug("(%s) dma_rx_phy=0x%08x dma_tx_phy=0x%08x\n", __func__,
>  			 (u32) priv->dma_rx_phy, (u32) priv->dma_tx_phy);
> @@ -1034,8 +1076,9 @@ static void init_dma_desc_rings(struct n
>  		else
>  			p = priv->dma_rx + i;
>
> -		if (stmmac_init_rx_buffers(priv, p, i))
> -			break;
> +		ret = stmmac_init_rx_buffers(priv, p, i);
> +		if (ret)
> +			goto err_init_rx_buffers;
>
>  		if (netif_msg_probe(priv))
>  			pr_debug("[%p]\t[%p]\t[%x]\n", priv->rx_skbuff[i],
> @@ -1081,20 +1124,44 @@ static void init_dma_desc_rings(struct n
>
>  	if (netif_msg_hw(priv))
>  		stmmac_display_rings(priv);
> +
> +	return 0;
> +err_init_rx_buffers:
> +	while (--i >= 0)
> +		stmmac_free_rx_buffers(priv, i);
> +	kfree(priv->tx_skbuff);
> +err_tx_skbuff:
> +	kfree(priv->tx_skbuff_dma);
> +err_tx_skbuff_dma:
> +	kfree(priv->rx_skbuff);
> +err_rx_skbuff:
> +	kfree(priv->rx_skbuff_dma);
> +err_rx_skbuff_dma:
> +	if (priv->extend_desc) {
> +		dma_free_coherent(priv->device, priv->dma_tx_size *
> +				  sizeof(struct dma_extended_desc),
> +				  priv->dma_etx, priv->dma_tx_phy);
> +		dma_free_coherent(priv->device, priv->dma_rx_size *
> +				  sizeof(struct dma_extended_desc),
> +				  priv->dma_erx, priv->dma_rx_phy);
> +	} else {
> +		dma_free_coherent(priv->device,
> +				priv->dma_tx_size * sizeof(struct dma_desc),
> +				priv->dma_tx, priv->dma_tx_phy);
> +		dma_free_coherent(priv->device,
> +				priv->dma_rx_size * sizeof(struct dma_desc),
> +				priv->dma_rx, priv->dma_rx_phy);
> +	}
> +err_dma:
> +	return ret;
>  }
>
>  static void dma_free_rx_skbufs(struct stmmac_priv *priv)
>  {
>  	int i;
>
> -	for (i = 0; i < priv->dma_rx_size; i++) {
> -		if (priv->rx_skbuff[i]) {
> -			dma_unmap_single(priv->device, priv->rx_skbuff_dma[i],
> -					 priv->dma_buf_sz, DMA_FROM_DEVICE);
> -			dev_kfree_skb_any(priv->rx_skbuff[i]);
> -		}
> -		priv->rx_skbuff[i] = NULL;
> -	}
> +	for (i = 0; i < priv->dma_rx_size; i++)
> +		stmmac_free_rx_buffers(priv, i);
>  }
>
>  static void dma_free_tx_skbufs(struct stmmac_priv *priv)
> @@ -1560,12 +1627,17 @@ static int stmmac_open(struct net_device
>  	priv->dma_tx_size = STMMAC_ALIGN(dma_txsize);
>  	priv->dma_rx_size = STMMAC_ALIGN(dma_rxsize);
>  	priv->dma_buf_sz = STMMAC_ALIGN(buf_sz);
> -	init_dma_desc_rings(dev);
> +
> +	ret = init_dma_desc_rings(dev);
> +	if (ret < 0) {
> +		pr_err("%s: DMA descriptors initialization failed\n", __func__);
> +		goto dma_desc_error;
> +	}
>
>  	/* DMA initialization and SW reset */
>  	ret = stmmac_init_dma_engine(priv);
>  	if (ret < 0) {
> -		pr_err("%s: DMA initialization failed\n", __func__);
> +		pr_err("%s: DMA engine initialization failed\n", __func__);
>  		goto init_error;
>  	}
>
> @@ -1672,6 +1744,7 @@ wolirq_error:
>
>  init_error:
>  	free_dma_desc_resources(priv);
> +dma_desc_error:
>  	if (priv->phydev)
>  		phy_disconnect(priv->phydev);
>  phy_error:
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
