From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: Hang: 2.6.32.4 sky2/DMAR (was [PATCH] sky2: Fix WARNING: at
 lib/dma-debug.c:902 check_sync)
Date: Wed, 27 Jan 2010 12:58:59 -0500
Message-ID: <4B607EE3.9010403@majjas.com>
References: <20100120094103.GA6225@ff.dom.local> <4B58B217.8030001@majjas.com>
 <20100121204133.GB3085@del.dom.local> <4B59E7EB.3050605@majjas.com>
 <20100122215304.GA3105@del.dom.local> <4B5A2362.6000306@majjas.com>
 <20100122230605.GB3105@del.dom.local> <4B5A33D8.90501@majjas.com>
 <20100122234656.GC3105@del.dom.local> <4B5A39BD.8020305@majjas.com>
 <20100123232133.GA3487@del.dom.local> <4B605D1B.60402@majjas.com>
 <20100127085049.5b5048e9@nehalam> <4B60707F.1000608@majjas.com>
 <20100127095614.14313677@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755925Ab0A0R7L@vger.kernel.org>
In-reply-to: <20100127095614.14313677@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/27/2010 12:56 PM, Stephen Hemminger wrote:
> On Wed, 27 Jan 2010 11:57:35 -0500
> Michael Breuer<mbreuer@majjas.com>  wrote:
>
>    
>> On 1/27/2010 11:50 AM, Stephen Hemminger wrote:
>>      
>>> On Wed, 27 Jan 2010 10:34:51 -0500
>>> Michael Breuer<mbreuer@majjas.com>   wrote:
>>>
>>>
>>>        
>>>> On 01/23/2010 06:21 PM, Jarek Poplawski wrote:
>>>>
>>>>          
>>>>> On Fri, Jan 22, 2010 at 06:50:21PM -0500, Michael Breuer wrote:
>>>>>
>>>>>
>>>>>            
>>>>>> When the packets were dropped, there was a different sequence in the
>>>>>> log - DISCOVER/OFFER repeated. The "normal" is that the sequence
>>>>>> appeared correct and complete - DISCOVER/OFFER/REQUEST/ACK - or
>>>>>> INFORM/ACK (vs. INFORM repeatedly sans ACK) as the case may be.
>>>>>>
>>>>>>
>>>>>>              
>>>>> Anyway, I'd be intersted if the switch matters here.
>>>>>
>>>>> Plus one more test: could you try to load sky2 with the parameter:
>>>>> "copybreak=1" (the rest as in any recent test, which gave you dmar
>>>>> errors; any switch).
>>>>>
>>>>> Thanks,
>>>>> Jarek P.
>>>>>
>>>>>
>>>>>            
>>>> Ok - now up 80+ hours with copybreak=1. I'm going to redo w/o copybreak
>>>> to confirm that I haven't inadvertently fixed something. However, given
>>>> that it might be copybreak-related, I looked at sky2.c again and I'm
>>>> wondering about the copybreak max size in sky2_rx_start:
>>>>
>>>>      size = roundup(sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN, 8);
>>>>
>>>>            /* Stopping point for hardware truncation */
>>>>            thresh = (size - 8) / sizeof(u32);
>>>>
>>>>            sky2->rx_nfrags = size>>   PAGE_SHIFT;
>>>>            BUG_ON(sky2->rx_nfrags>   ARRAY_SIZE(re->frag_addr));
>>>>
>>>>            /* Compute residue after pages */
>>>>            size -= sky2->rx_nfrags<<   PAGE_SHIFT;
>>>>
>>>>            /* Optimize to handle small packets and headers */
>>>>            if (size<   copybreak)
>>>>                    size = copybreak;
>>>>            if (size<   ETH_HLEN)
>>>>                    size = ETH_HLEN;
>>>>
>>>>
>>>> Why would increasing size to copybreak be valid here?
>>>>
>>>> Guessing a bit as I'm not sure about rx_nfrags, but if I read this
>>>> correctly, if size is ever less than copybreak it's because there isn't
>>>> enough space left for anything larger. If so, wouldn't increasing size
>>>> potentially corrupt something? I'd further guess that the resulting
>>>> condition manifests sooner (or at least with a more visible effect) when
>>>> using DMAR.
>>>>
>>>> In any event, why "copybreak" as the minimum buffer size? I'd suggest
>>>> that if it isn't possible to allocate at least MTU + overhead that
>>>> sky2_rx_start ought to be delayed until there is room.
>>>>
>>>>          
>>> This code is where driver decides how much data will be received in skb
>>> data area and the remaining data spills over into skb frags.
>>> Copybreak is the threshold so that packets less than size are copied
>>> to a new skb.  The code doing the copying there assumes the data is
>>> totally contained in the skb (not in frags). The size increase there
>>> is to make sure that assumption is always true.  I suppose you
>>> could do something perverse like setting copybreak really huge
>>> and confuse driver, but that is a user error.
>>>
>>>
>>>        
>> Ok - but I'm wondering under what circumstances size would be<
>> copybreak in the first place after computing the residue. If size ends
>> up being unreasonably small, is simply increasing the number to whatever
>> copybreak is correct? Assuming my testing is correct, then the crash
>> I've been experiencing when using dmar (only) seems related to the value
>> of copybreak. I don't think the other use (skb reuse) is the issue (but
>> hey, I could have missed something). The crash occurs when copybreak is
>> the default of 128, didn't happen when I set copybreak to 1.
>>      
> Does this change it? If so the dma code is (not sky2) is buggy and not
> rounding up properly.
>
> --- a/drivers/net/sky2.c	2010-01-27 09:46:10.940005248 -0800
> +++ b/drivers/net/sky2.c	2010-01-27 09:53:47.141267850 -0800
> @@ -2257,13 +2257,16 @@ static struct sk_buff *receive_copy(stru
>
>   	skb = netdev_alloc_skb_ip_align(sky2->netdev, length);
>   	if (likely(skb)) {
> +		unsigned dma_align = dma_get_cache_alignment();
> +		unsigned dma_size = ALIGN(length+1, dma_align);
> +
>   		pci_dma_sync_single_for_cpu(sky2->hw->pdev, re->data_addr,
> -					    length, PCI_DMA_FROMDEVICE);
> +					    dma_size, PCI_DMA_FROMDEVICE);
>   		skb_copy_from_linear_data(re->skb, skb->data, length);
>   		skb->ip_summed = re->skb->ip_summed;
>   		skb->csum = re->skb->csum;
>   		pci_dma_sync_single_for_device(sky2->hw->pdev, re->data_addr,
> -					       length, PCI_DMA_FROMDEVICE);
> +					       dma_size, PCI_DMA_FROMDEVICE);
>   		re->skb->ip_summed = CHECKSUM_NONE;
>   		skb_put(skb, length);
>   	}
>    
Ok - will queue this - want to reconfirm that the system still crashes 
w/o this (or copybreak). That should take a few days.
