From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH] pch_gbe: don't come up if we can't allocate buffers
Date: Thu, 25 Oct 2012 10:51:59 +0200
Message-ID: <20121025085159.GA26574@redhat.com>
References: <1351149005-13698-1-git-send-email-vfalico@redhat.com>
 <1351154458.6537.146.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	richardcochran@gmail.com, tshimizu818@gmail.com,
	andy.cress@us.kontron.com, erwan.velu@zodiacaerospace.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9599 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933663Ab2JYIwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 04:52:04 -0400
Content-Disposition: inline
In-Reply-To: <1351154458.6537.146.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 25, 2012 at 10:40:58AM +0200, Eric Dumazet wrote:
>On Thu, 2012-10-25 at 09:10 +0200, Veaceslav Falico wrote:
>> Currently, even if pch_gbe_alloc_tx/rx_buffers (even partially) fail, we
>> bring the interface up. It mihgt confuse the user (if he requested specific
>> amount of buffers) and can lead to different bugs.
>>
>> Add error handling to these functions and clean after them in case of
>> failure. It also resolves a possible NULL pointer dereference in
>> pch_gbe_alloc_tx_buffers(), in case of netdev_alloc_skb() failure. It's ok
>> to (paritally) fail for pch_gbe_alloc_rx_buffers() in some situation, so
>> don't clean inside and rather handle skb freeing outside of the function.
>>
>> This patch also adds tx_alloc_buff_failed ethtool counter.
>
>This should not be needed :
>
>> -static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
>> +static int pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
>>  					struct pch_gbe_tx_ring *tx_ring)
>>  {
>>  	struct pch_gbe_buffer *buffer_info;
>> @@ -1506,6 +1521,7 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
>>  	unsigned int i;
>>  	unsigned int bufsz;
>>  	struct pch_gbe_tx_desc *tx_desc;
>> +	int err;
>>
>>  	bufsz =
>>  	    adapter->hw.mac.max_frame_size + PCH_GBE_DMA_ALIGN + NET_IP_ALIGN;
>> @@ -1513,12 +1529,26 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
>>  	for (i = 0; i < tx_ring->count; i++) {
>>  		buffer_info = &tx_ring->buffer_info[i];
>>  		skb = netdev_alloc_skb(adapter->netdev, bufsz);
>> +		if (unlikely(!skb)) {
>> +			adapter->stats.tx_alloc_buff_failed++;
>> +			err = -ENOMEM;
>> +			goto freeall;
>> +		}
>
>Hmmm
>
>These skbs should be allocated using GFP_KERNEL, to lower risk of OOM,
>using a mere alloc_skb(bufsz, GFP_KERNEL)
>
>Only skbs for rx 'need' netdev_alloc_skb() to add a NET_SKB_PAD
>headroom.
>
>	skb = alloc_skb(bufsz, GFP_KERNEL);
>	if (!skb)
>		goto fail;
>	skb_reserve(skb, NET_IP_ALIGN);
>
>And BTW, we dont really need skbs here, only a bounce buffer so that we
>can copy frames on it... (kmalloc() instead of alloc_skb())
>
>>  		skb_reserve(skb, PCH_GBE_DMA_ALIGN);
>
>PCH_GBE_DMA_ALIGN is zero ...
>
>>  		buffer_info->skb = skb;
>>  		tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
>>  		tx_desc->gbec_status = (DSC_INIT16);
>>  	}
>> -	return;
>> +	return 0;
>> +
>> +freeall:
>> +	for (i--; i >= 0; i--) {
>> +		dev_kfree_skb_any(buffer_info->skb);
>> +		buffer_info->skb = NULL;
>> +		tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
>> +		tx_desc->gbec_status = 0;
>> +	}
>> +	return err;
>>  }
>>
>
>
>Also I would call pch_gbe_alloc_tx_buffers() _after_
>pch_gbe_alloc_rx_buffers() (Since rx allocations probably are using
>GFP_ATOMIC allocations)

Agree with all, will update the patch.

Thank you very much for the review!
