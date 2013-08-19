From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 3/3] net/mlx4_en: Fix handling of dma_map failure
Date: Mon, 19 Aug 2013 22:42:00 +0200
Message-ID: <20130819204200.GA30818@electric-eye.fr.zoreil.com>
References: <1376894542-27854-1-git-send-email-amirv@mellanox.com>
 <1376894542-27854-4-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34346 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137Ab3HSUmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 16:42:07 -0400
Content-Disposition: inline
In-Reply-To: <1376894542-27854-4-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amir Vadai <amirv@mellanox.com> :
[...]
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 157bcd1..92d7097 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -673,6 +673,64 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>  	tx_info->skb = skb;
>  	tx_info->nr_txbb = nr_txbb;
>  
> +	if (lso_header_size)
> +		data = ((void *)&tx_desc->lso + ALIGN(lso_header_size + 4,
> +						      DS_SIZE));
> +	else
> +		data = &tx_desc->data;
> +
> +	/* valid only for none inline segments */
> +	tx_info->data_offset = (void *)data - (void *)tx_desc;
> +
> +	tx_info->linear = (lso_header_size < skb_headlen(skb) &&
> +			   !is_inline(skb, NULL)) ? 1 : 0;
> +
> +	data += skb_shinfo(skb)->nr_frags + tx_info->linear - 1;
> +
> +	if (is_inline(skb, &fragptr)) {
> +		tx_info->inl = 1;
> +	} else {
> +		/* Map fragments */
> +		for (i = skb_shinfo(skb)->nr_frags - 1; i >= 0; i--) {
> +			frag = &skb_shinfo(skb)->frags[i];
> +			dma = skb_frag_dma_map(priv->ddev, frag,
> +					       0, skb_frag_size(frag),
> +					       DMA_TO_DEVICE);
> +			if (dma_mapping_error(priv->ddev, dma)) {

				goto err_unmap_frags;

You have a lot of huge scope variables. At least use these to hide
the 80 cols problems.

> +				for (i++; i < skb_shinfo(skb)->nr_frags; i++) {
> +					frag = &skb_shinfo(skb)->frags[i];
> +					en_err(priv, "DMA mapping error\n");
> +					dma_unmap_page(priv->ddev,
> +						       (dma_addr_t) be64_to_cpu(data[i].addr),
> +						       skb_frag_size(frag), PCI_DMA_TODEVICE);
> +				}
> +				goto tx_drop;
> +			}
> +
> +			data->addr = cpu_to_be64(dma);
> +			data->lkey = cpu_to_be32(mdev->mr.key);
> +			wmb();
> +			data->byte_count = cpu_to_be32(skb_frag_size(frag));
> +			--data;
> +		}
> +
> +		/* Map linear part */
> +		if (tx_info->linear) {
> +			u32 byte_count = skb_headlen(skb) - lso_header_size;
> +			dma = dma_map_single(priv->ddev, skb->data +
> +					     lso_header_size, byte_count,
> +					     PCI_DMA_TODEVICE);
> +			if (dma_mapping_error(priv->ddev, dma))
> +				goto tx_drop;

(frags dma leak)
				goto err_unmap_frags;

You may consider a local variable for 'priv->ddev' btw.

-- 
Ueimor
