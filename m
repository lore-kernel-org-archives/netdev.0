From: Amir Vadai <amirv.mellanox@gmail.com>
Subject: Re: [PATCH net-next 3/3] net/mlx4_en: Fix handling of dma_map failure
Date: Tue, 20 Aug 2013 11:17:36 +0300
Message-ID: <52132620.6020809@gmail.com>
References: <1376894542-27854-1-git-send-email-amirv@mellanox.com> <1376894542-27854-4-git-send-email-amirv@mellanox.com> <20130819204200.GA30818@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:39323 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321Ab3HTIRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 04:17:40 -0400
Received: by mail-ee0-f48.google.com with SMTP id l10so53137eei.21
        for <netdev@vger.kernel.org>; Tue, 20 Aug 2013 01:17:39 -0700 (PDT)
In-Reply-To: <20130819204200.GA30818@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/08/2013 23:42, Francois Romieu wrote:
> Amir Vadai <amirv@mellanox.com> :
> [...]
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> index 157bcd1..92d7097 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> @@ -673,6 +673,64 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>>  	tx_info->skb = skb;
>>  	tx_info->nr_txbb = nr_txbb;
>>  
>> +	if (lso_header_size)
>> +		data = ((void *)&tx_desc->lso + ALIGN(lso_header_size + 4,
>> +						      DS_SIZE));
>> +	else
>> +		data = &tx_desc->data;
>> +
>> +	/* valid only for none inline segments */
>> +	tx_info->data_offset = (void *)data - (void *)tx_desc;
>> +
>> +	tx_info->linear = (lso_header_size < skb_headlen(skb) &&
>> +			   !is_inline(skb, NULL)) ? 1 : 0;
>> +
>> +	data += skb_shinfo(skb)->nr_frags + tx_info->linear - 1;
>> +
>> +	if (is_inline(skb, &fragptr)) {
>> +		tx_info->inl = 1;
>> +	} else {
>> +		/* Map fragments */
>> +		for (i = skb_shinfo(skb)->nr_frags - 1; i >= 0; i--) {
>> +			frag = &skb_shinfo(skb)->frags[i];
>> +			dma = skb_frag_dma_map(priv->ddev, frag,
>> +					       0, skb_frag_size(frag),
>> +					       DMA_TO_DEVICE);
>> +			if (dma_mapping_error(priv->ddev, dma)) {
> 
> 				goto err_unmap_frags;
> 
> You have a lot of huge scope variables. At least use these to hide
> the 80 cols problems.
Will try to re-arrange a bit this code - I think I will add another patch.
Split this one into:
1. Code re-arrange
2. Move and handle dma_map_failure

> 
>> +				for (i++; i < skb_shinfo(skb)->nr_frags; i++) {
>> +					frag = &skb_shinfo(skb)->frags[i];
>> +					en_err(priv, "DMA mapping error\n");
>> +					dma_unmap_page(priv->ddev,
>> +						       (dma_addr_t) be64_to_cpu(data[i].addr),
>> +						       skb_frag_size(frag), PCI_DMA_TODEVICE);
>> +				}
>> +				goto tx_drop;
>> +			}
>> +
>> +			data->addr = cpu_to_be64(dma);
>> +			data->lkey = cpu_to_be32(mdev->mr.key);
>> +			wmb();
>> +			data->byte_count = cpu_to_be32(skb_frag_size(frag));
>> +			--data;
>> +		}
>> +
>> +		/* Map linear part */
>> +		if (tx_info->linear) {
>> +			u32 byte_count = skb_headlen(skb) - lso_header_size;
>> +			dma = dma_map_single(priv->ddev, skb->data +
>> +					     lso_header_size, byte_count,
>> +					     PCI_DMA_TODEVICE);
>> +			if (dma_mapping_error(priv->ddev, dma))
>> +				goto tx_drop;
> 
> (frags dma leak)
Thanks for the catch.

> 				goto err_unmap_frags;
> 
> You may consider a local variable for 'priv->ddev' btw.
Will do
> 

Amir.
