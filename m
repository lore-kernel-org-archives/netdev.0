From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 net-next 1/2] net: ethernet: slicoss: add slicoss
 gigabit ethernet driver
Date: Tue, 29 Nov 2016 09:14:02 -0800
Message-ID: <34c8e4b3-ccbc-082e-1dd0-3893b56e475a@gmail.com>
References: <1480162850-8014-1-git-send-email-LinoSanfilippo@gmx.de>
 <1480162850-8014-2-git-send-email-LinoSanfilippo@gmx.de>
 <a6f99dc8-60e4-7727-0764-abdfac81c713@gmail.com>
 <6b7de79d-b149-9888-2d0f-2acee5c2905e@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>, davem@davemloft.net,
 charrer@alacritech.com, liodot@gmail.com, gregkh@linuxfoundation.org,
 andrew@lunn.ch
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <6b7de79d-b149-9888-2d0f-2acee5c2905e@gmx.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On 11/28/2016 01:41 PM, Lino Sanfilippo wrote:
> The problem is that the HW does not provide a tx completion index. Instead we have to 
> iterate the status descriptors until we get an invalid idx which indicates that there 
> are no further tx descriptors done for now. I am afraid that if we do not limit the 
> number of descriptors processed in the tx completion handler, a continuous transmission 
> of frames could keep the loop in xmit_complete() run endlessly. I dont know if this 
> can actually happen but I wanted to make sure that this is avoided.

OK, it might be a good idea to put that comment somewhere around the tx
completion handler to understand why it is bounded with a specific value.

> 
>> [snip]
>>
>>> +	while (slic_get_free_rx_descs(rxq) > SLIC_MAX_REQ_RX_DESCS) {
>>> +		skb = alloc_skb(maplen + ALIGN_MASK, gfp);
>>> +		if (!skb)
>>> +			break;
>>> +
>>> +		paddr = dma_map_single(&sdev->pdev->dev, skb->data, maplen,
>>> +				       DMA_FROM_DEVICE);
>>> +		if (dma_mapping_error(&sdev->pdev->dev, paddr)) {
>>> +			netdev_err(dev, "mapping rx packet failed\n");
>>> +			/* drop skb */
>>> +			dev_kfree_skb_any(skb);
>>> +			break;
>>> +		}
>>> +		/* ensure head buffer descriptors are 256 byte aligned */
>>> +		offset = 0;
>>> +		misalign = paddr & ALIGN_MASK;
>>> +		if (misalign) {
>>> +			offset = SLIC_RX_BUFF_ALIGN - misalign;
>>> +			skb_reserve(skb, offset);
>>> +		}
>>> +		/* the HW expects dma chunks for descriptor + frame data */
>>> +		desc = (struct slic_rx_desc *)skb->data;
>>> +		memset(desc, 0, sizeof(*desc));
>>
>> Do you really need to zero-out the prepending RX descriptor? Are not you
>> missing a write barrier here?
> 
> Indeed, it should be sufficient to make sure that the bit SLIC_IRHDDR_SVALID is not set.
> I will adjust it. 
> Concerning the write barrier: You mean a wmb() before slic_write() to ensure that the zeroing
>  of the status desc is done before the descriptor is passed to the HW, right?

Correct, that's what I meant here.

> 
> 
>> [snip]
>>
>>> +
>>> +		dma_sync_single_for_cpu(&sdev->pdev->dev,
>>> +					dma_unmap_addr(buff, map_addr),
>>> +					buff->addr_offset + sizeof(*desc),
>>> +					DMA_FROM_DEVICE);
>>> +
>>> +		status = le32_to_cpu(desc->status);
>>> +		if (!(status & SLIC_IRHDDR_SVALID))
>>> +			break;
>>> +
>>> +		buff->skb = NULL;
>>> +
>>> +		dma_unmap_single(&sdev->pdev->dev,
>>> +				 dma_unmap_addr(buff, map_addr),
>>> +				 dma_unmap_len(buff, map_len),
>>> +				 DMA_FROM_DEVICE);
>>
>> This is potentially inefficient, you already did a cache invalidation
>> for the RX descriptor here, you could be more efficient with just
>> invalidating the packet length, minus the descriptor length.
>>
> 
> I am not sure I understand: We have to unmap the complete dma area, no matter if we synced
> part of it before, dont we? AFAIK a dma sync is different from unmapping dma, or do I miss
> something?

Sorry, I was not very clear, what I meant is that you can allocate and
do the initial dma_map_single() of your RX skbs during ndo_open(), and
then, in your RX path, you can only do dma_sync_single_for_cpu() twice
(once for the RX descriptor status, second time for the actual packet
contents), and when you return the SKB to the HW, do a
dma_sync_single_for_device(). The advantage of doing that, is that if
your cache operations are slow, you only do them on exactly packet
length, and not the actual RX buffer size (e.g: 2KB).
-- 
Florian
