From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] forcedeth: Fix WARNINGS that result when DMA mapping
 is not checked
Date: Thu, 27 Dec 2012 14:38:49 -0600
Message-ID: <50DCB1D9.50906@lwfinger.net>
References: <1356637327-4884-1-git-send-email-Larry.Finger@lwfinger.net> <1356638715.30414.1349.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1356638715.30414.1349.camel@edumazet-glaptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/27/2012 02:05 PM, Eric Dumazet wrote:
> On Thu, 2012-12-27 at 13:42 -0600, Larry Finger wrote:
>> With 3.8-rc1, the first call of pci_map_single() that is not checked
>> with a corresponding pci_dma_mapping_error() call results in a warning
>> with a splat as follows:
>>
>> WARNING: at lib/dma-debug.c:933 check_unmap+0x480/0x950()
>> Hardware name: HP Pavilion dv2700 Notebook PC
>> forcedeth 0000:00:0a.0: DMA-API: device driver failed to check
>>   map error[device address=0x00000000b176e002] [size=90 bytes] [mapped as single]
>>
>> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
>> ---
>>   drivers/net/ethernet/nvidia/forcedeth.c |   23 +++++++++++++++++++++++
>>   1 file changed, 23 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
>> index 653487d..de39cf2 100644
>> --- a/drivers/net/ethernet/nvidia/forcedeth.c
>> +++ b/drivers/net/ethernet/nvidia/forcedeth.c
>> @@ -1821,6 +1821,11 @@ static int nv_alloc_rx(struct net_device *dev)
>>   							     skb->data,
>>   							     skb_tailroom(skb),
>>   							     PCI_DMA_FROMDEVICE);
>> +			if (pci_dma_mapping_error(np->pci_dev,
>> +						  np->put_rx_ctx->dma)) {
>> +				dev_kfree_skb_any(skb);
>
> skb has no destructor yet, kfree_skb(skb) should be fine

OK.

>
>> +				goto packet_dropped;
>> +			}
>>   			np->put_rx_ctx->dma_len = skb_tailroom(skb);
>>   			np->put_rx.orig->buf = cpu_to_le32(np->put_rx_ctx->dma);
>>   			wmb();
>> @@ -1830,6 +1835,7 @@ static int nv_alloc_rx(struct net_device *dev)
>>   			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
>>   				np->put_rx_ctx = np->first_rx_ctx;
>>   		} else {
>> +packet_dropped:
>>   			u64_stats_update_begin(&np->swstats_rx_syncp);
>>   			np->stat_rx_dropped++;
>>   			u64_stats_update_end(&np->swstats_rx_syncp);
>> @@ -1856,6 +1862,11 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
>>   							     skb->data,
>>   							     skb_tailroom(skb),
>>   							     PCI_DMA_FROMDEVICE);
>> +			if (pci_dma_mapping_error(np->pci_dev,
>> +						  np->put_rx_ctx->dma)) {
>> +				dev_kfree_skb_any(skb);
>> +				goto packet_dropped;
>> +			}
>>   			np->put_rx_ctx->dma_len = skb_tailroom(skb);
>>   			np->put_rx.ex->bufhigh = cpu_to_le32(dma_high(np->put_rx_ctx->dma));
>>   			np->put_rx.ex->buflow = cpu_to_le32(dma_low(np->put_rx_ctx->dma));
>> @@ -1866,6 +1877,7 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
>>   			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
>>   				np->put_rx_ctx = np->first_rx_ctx;
>>   		} else {
>> +packet_dropped:
>>   			u64_stats_update_begin(&np->swstats_rx_syncp);
>>   			np->stat_rx_dropped++;
>>   			u64_stats_update_end(&np->swstats_rx_syncp);
>> @@ -2217,6 +2229,9 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
>>   		bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
>>   		np->put_tx_ctx->dma = pci_map_single(np->pci_dev, skb->data + offset, bcnt,
>>   						PCI_DMA_TODEVICE);
>> +		if (pci_dma_mapping_error(np->pci_dev,
>> +					  np->put_tx_ctx->dma))
>> +			return NETDEV_TX_BUSY;
>
> Really this is not going to work very well : caller will call this in a
> loop.

Any suggestions on what value should be returned, or does the caller need to be 
modified?

Thanks for the review,

Larry

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
