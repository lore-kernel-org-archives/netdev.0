From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 06/13] sis190: use netdev_alloc_skb
Date: Thu, 17 Apr 2008 09:04:55 +0800
Message-ID: <4806A237.2060601@cn.fujitsu.com>
References: <20080416233727.732025083@vyatta.com> <20080416233757.391517921@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61456 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751140AbYDQBGU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 21:06:20 -0400
In-Reply-To: <20080416233757.391517921@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger said the following on 2008-4-17 7:37:
> Use netdev_alloc_skb. This sets skb->dev and allows arch specific
> allocation. 
> 
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/drivers/net/sis190.c	2008-04-16 15:21:05.000000000 -0700
> +++ b/drivers/net/sis190.c	2008-04-16 16:31:30.000000000 -0700
> @@ -480,30 +480,28 @@ static inline void sis190_make_unusable_
>  	desc->status = 0x0;
>  }
>  
> -static int sis190_alloc_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
> -			       struct RxDesc *desc, u32 rx_buf_sz)
> +static struct sk_buff *sis190_alloc_rx_skb(struct pci_dev *pdev,
> +					   struct net_device *dev,
> +					   struct RxDesc *desc, u32 rx_buf_sz)
>  {
>  	struct sk_buff *skb;
>  	dma_addr_t mapping;
>  	int ret = 0;
>  

ret no longer be used.

> -	skb = dev_alloc_skb(rx_buf_sz);
> +	skb = netdev_alloc_skb(dev, rx_buf_sz);
>  	if (!skb)
>  		goto err_out;
>  
> -	*sk_buff = skb;
> -
>  	mapping = pci_map_single(pdev, skb->data, rx_buf_sz,
>  				 PCI_DMA_FROMDEVICE);
>  
>  	sis190_map_to_asic(desc, mapping, rx_buf_sz);
> -out:
> -	return ret;
> +	return skb;
>  
>  err_out:
>  	ret = -ENOMEM;

ret no longer be used.

>  	sis190_make_unusable_by_asic(desc);
> -	goto out;
> +	return NULL;
>  }
>  
>  static u32 sis190_rx_fill(struct sis190_private *tp, struct net_device *dev,
> @@ -512,30 +510,32 @@ static u32 sis190_rx_fill(struct sis190_
>  	u32 cur;
>  
>  	for (cur = start; cur < end; cur++) {
> -		int ret, i = cur % NUM_RX_DESC;
> +		int i = cur % NUM_RX_DESC;
>  
>  		if (tp->Rx_skbuff[i])
>  			continue;
>  
> -		ret = sis190_alloc_rx_skb(tp->pci_dev, tp->Rx_skbuff + i,
> -					  tp->RxDescRing + i, tp->rx_buf_sz);
> -		if (ret < 0)
> +		tp->Rx_skbuff[i] = sis190_alloc_rx_skb(tp->pci_dev, dev,
> +						       tp->RxDescRing + i,
> +						       tp->rx_buf_sz);
> +		if (!tp->Rx_skbuff[i])
>  			break;
>  	}
>  	return cur - start;
>  }
>  
> -static inline int sis190_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
> -				     struct RxDesc *desc, int rx_buf_sz)
> +static int sis190_try_rx_copy(struct net_device *dev,
> +			      struct sk_buff **sk_buff, int pkt_size,
> +			      struct RxDesc *desc, int rx_buf_sz)
>  {
> -	int ret = -1;
> +	int ret = 01;
>  
>  	if (pkt_size < rx_copybreak) {
>  		struct sk_buff *skb;
>  
> -		skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
> +		skb = netdev_alloc_skb(dev, pkt_size + 2);
>  		if (skb) {
> -			skb_reserve(skb, NET_IP_ALIGN);
> +			skb_reserve(skb, 2);
>  			skb_copy_to_linear_data(skb, sk_buff[0]->data, pkt_size);
>  			*sk_buff = skb;
>  			sis190_give_to_asic(desc, rx_buf_sz);
> @@ -610,7 +610,7 @@ static int sis190_rx_interrupt(struct ne
>  				le32_to_cpu(desc->addr), tp->rx_buf_sz,
>  				PCI_DMA_FROMDEVICE);
>  
> -			if (sis190_try_rx_copy(&skb, pkt_size, desc,
> +			if (sis190_try_rx_copy(dev, &skb, pkt_size, desc,
>  					       tp->rx_buf_sz)) {
>  				pci_action = pci_unmap_single;
>  				tp->Rx_skbuff[entry] = NULL;
> 

