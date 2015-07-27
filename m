From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] ravb: minimize TX data copying
Date: Mon, 27 Jul 2015 14:57:33 +0300
Message-ID: <55B61CAD.1010009@cogentembedded.com>
References: <6916181.NMDRL3LUfS@wasted.cogentembedded.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB6C651@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB6C651@AcuExch.aculab.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/27/2015 11:47 AM, David Laight wrote:

>> Renesas Ethernet AVB controller requires that all data are aligned on 4-byte
>> boundary.  While it's  easily achievable for  the RX  data with  the help of
>> skb_reserve() (we even align on 128-byte boundary as recommended by the manual),
>> we  can't  do the same with the TX data, and it always comes  unaligned from
>> the networking core. Originally we solved it an easy way, copying all packet
>> to  a  preallocated  aligned buffer; however, it's enough to copy only up to
>> 3 first bytes from each packet, doing the transfer using 2 TX descriptors
>> instead of just 1. Here's an implementation of the new  TX algorithm that
>> significantly reduces the driver's memory requirements.

> ...
>> -	buffer = PTR_ALIGN(priv->tx_buffers[q][entry], RAVB_ALIGN);
>> -	memcpy(buffer, skb->data, skb->len);
>> -	desc = &priv->tx_ring[q][entry];
>> -	desc->ds_tagl = cpu_to_le16(skb->len);
>> -	dma_addr = dma_map_single(&ndev->dev, buffer, skb->len, DMA_TO_DEVICE);
>> +	buffer = PTR_ALIGN(priv->tx_align[q], DPTR_ALIGN) +
>> +		 entry / NUM_TX_DESC * DPTR_ALIGN;

> The above would be clearer if tx_align was char[DPTR_ALIGN][].

    tx_align is a pointer, not an array.

>> +	len = PTR_ALIGN(skb->data, DPTR_ALIGN) - skb->data;
>> +	memcpy(buffer, skb->data, len);

> Does this imply there has been an skb_linearize() ???

    Sure, I don't support S/G (and it seems problematic given how the DMA 
descriptors are handled by the h/w).

> The old version didn't really need it (it was doing a copy anyway).

    It did since it copied the whole packet.

>> +	dma_addr = dma_map_single(&ndev->dev, buffer, len, DMA_TO_DEVICE);
>>   	if (dma_mapping_error(&ndev->dev, dma_addr))
>>   		goto drop;
>> +
>> +	desc = &priv->tx_ring[q][entry];
>> +	desc->ds_tagl = cpu_to_le16(len);
>> +	desc->dptr = cpu_to_le32(dma_addr);
>> +
>> +	buffer = skb->data + len;
>> +	len = skb->len - len;
>> +	dma_addr = dma_map_single(&ndev->dev, buffer, len, DMA_TO_DEVICE);
>> +	if (dma_mapping_error(&ndev->dev, dma_addr))
>> +		goto unmap;
>> +
>> +	desc++;
>> +	desc->ds_tagl = cpu_to_le16(len);

> What happens if a fragment is less than DPTR_ALIGN bytes ???

    It's always the case. If you mean a packet shorter than DPTR_ALIGN, it can 
happen due to call to skb_put_padto(skb, ETH_ZLEN).

> Actually is looks like you relying on having a linear skb.

    Yes, and I was relying on it even before this patch.

> 	David

WBR, Sergei

