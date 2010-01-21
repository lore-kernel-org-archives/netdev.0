From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2: Fix WARNING: at lib/dma-debug.c:902 check_sync
Date: Thu, 21 Jan 2010 15:46:50 -0500
Message-ID: <4B58BD3A.1000705@majjas.com>
References: <20100120094103.GA6225@ff.dom.local> <4B58B217.8030001@majjas.com>
 <20100121204133.GB3085@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754991Ab0AUUqv@vger.kernel.org>
In-reply-to: <20100121204133.GB3085@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/21/2010 3:41 PM, Jarek Poplawski wrote:
> On Thu, Jan 21, 2010 at 02:59:19PM -0500, Michael Breuer wrote:
>    
>> On 1/20/2010 4:41 AM, Jarek Poplawski wrote:
>>      
>>> [ previously: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit() ]
>>> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
>>> index 7650f73..cdebdd3 100644
>>> --- a/drivers/net/sky2.c
>>> +++ b/drivers/net/sky2.c
>>> @@ -2252,12 +2252,14 @@ static struct sk_buff *receive_copy(struct sky2_port *sky2,
>>>   	skb = netdev_alloc_skb_ip_align(sky2->netdev, length);
>>>   	if (likely(skb)) {
>>>   		pci_dma_sync_single_for_cpu(sky2->hw->pdev, re->data_addr,
>>> -					    length, PCI_DMA_FROMDEVICE);
>>> +					    pci_unmap_len(re, data_size),
>>> +					    PCI_DMA_FROMDEVICE);
>>>   		skb_copy_from_linear_data(re->skb, skb->data, length);
>>>   		skb->ip_summed = re->skb->ip_summed;
>>>   		skb->csum = re->skb->csum;
>>>   		pci_dma_sync_single_for_device(sky2->hw->pdev, re->data_addr,
>>> -					       length, PCI_DMA_FROMDEVICE);
>>> +					       pci_unmap_len(re, data_size),
>>> +					       PCI_DMA_FROMDEVICE);
>>>   		re->skb->ip_summed = CHECKSUM_NONE;
>>>   		skb_put(skb, length);
>>>   	}
>>>        
>> Just a testing update: I went back to CONFIG_DMAR=Y yesterday and
>> have not (yet) encountered the sky2 crash I'd been having prior to
>> this fix. I've been pumping traffic through, and based on pre-patch
>> experience, it would likely have crashed by now.
>>
>> Will keep the system up for the next couple of days w/o reboot to
>> confirm that the sky2 lockup I'd been seeing has stopped happening
>> with this patch.
>>
>> Test notes:
>>
>> 1) Warning previously apparent on start (dma_debug check_sync) with
>> CONFIG_DMAR=n is gone.
>> 2) W/o the above patch, I was getting sky2 DMAR errors and
>> subsequent TX hangs requiring reboot to clear. The hangs happened
>> after at least 12 hours of uptime, and under RX load at the time of
>> the hang.
>> 3) With the above patch (and no other changes) I have not been able
>> to recreate the crash - the system is stable.
>>      
> Btw, could you remind us if during last dmar bugs jumbo frames might
> have been used or maybe mtu was changed, and the current test setting?
>
>    
I've hit this with and without Jumbo frames enabled. Last couple of 
recreations were with mtu = 1500, which is how I'm running now.
>> I have been following the discussion about the DMA api would suggest
>> that the length issue when DMAR is enabled is less innocuous than
>> previously believed.
>>      
> Actually, the last conclusions are - it's more innocuous than ever
> believed, and I completely agree with this (at least until the next
> week ;-).
>    
I stand grammatically corrected.
> Thanks,
> Jarek P.
>    
