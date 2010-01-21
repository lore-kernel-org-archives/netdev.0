From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2: Fix WARNING: at lib/dma-debug.c:902 check_sync
Date: Thu, 21 Jan 2010 14:59:19 -0500
Message-ID: <4B58B217.8030001@majjas.com>
References: <20100120094103.GA6225@ff.dom.local>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta5.srv.hcvlny.cv.net ([167.206.4.200]:42359 "EHLO
	mta5.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436Ab0AUT7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 14:59:21 -0500
In-reply-to: <20100120094103.GA6225@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/20/2010 4:41 AM, Jarek Poplawski wrote:
> [ previously: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit() ]
> On Tue, Jan 19, 2010 at 05:10:13PM -0800, Stephen Hemminger wrote:
>    
>> On Tue, 19 Jan 2010 20:01:10 -0500
>> Michael Breuer<mbreuer@majjas.com>  wrote:
>>
>>      
>>> On 1/19/2010 5:45 PM, Jarek Poplawski wrote:
>>>        
>>>> On Tue, Jan 19, 2010 at 03:06:01PM -0500, Michael Breuer wrote:
>>>>
>>>>          
>>>>> On 1/19/2010 2:59 PM, Jarek Poplawski wrote:
>>>>>
>>>>>            
>>>>>> On Tue, Jan 19, 2010 at 10:47:27AM -0500, Michael Breuer wrote:
>>>>>> ...
>>>>>>
>>>>>>              
>>>>>>> Still get the warning... but now 60 bytes.
>>>>>>> Jan 19 10:43:50 mail kernel: ------------[ cut here ]------------
>>>>>>> Jan 19 10:43:50 mail kernel: WARNING: at lib/dma-debug.c:902
>>>>>>>                
> ...
>    
>>> That not only compiled, but it cleared the error as well. Additionally,
>>> I used to see a bit of a delay receiving the login prompt when first
>>> connecting to the box by ssh. That delay is gone with this patch. I'd
>>> guess that the warning wasn't quite as innocuous as I thought.
>>> Note: tested on 2.6.32.4.  I'll leave this up for a bit before
>>> attempting to move back to head.
>>>        
>> Seems like an underlying bug in the DMA api. Maybe it just can't
>> handle operations on partial mapping.
>>
>> Other drivers with same problem:
>>    bnx2, cassini, pcnet32, r8169, rrunner, skge, sungem, tg3,
>>      
> It seems using the same length (even without pci_unmap_len()) is
> crucial here, but I hope maintainers (added to CC) will take care.
>
> Btw, it's not tested yet, but it might affect CONFIG_DMAR problems.
>
> Thanks,
> Jarek P.
> ----------------------->
>
> Using pci_unmap_len(), with the same length as pci_map_single(), with
> pci_dma_sync_single_for_cpu()/_device() fixes this warning (2.6.32.4):
>
>    
>> Jan 19 10:43:50 mail kernel: WARNING: at lib/dma-debug.c:902
>> check_sync+0xc1/0x43f()
>> Jan 19 10:43:50 mail kernel: Hardware name: System Product Name
>> Jan 19 10:43:50 mail kernel: sky2 0000:04:00.0: DMA-API: device driver
>> tries to sync DMA memory it has not allocated [device
>> address=0x0000000320a0b022] [size=60 bytes]
>>      
> Reported-by: Michael Breuer<mbreuer@majjas.com>
> Tested-by: Michael Breuer<mbreuer@majjas.com>
> Signed-off-by: Jarek Poplawski<jarkao2@gmail.com>
> ---
>
>   drivers/net/sky2.c |    6 ++++--
>   1 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 7650f73..cdebdd3 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -2252,12 +2252,14 @@ static struct sk_buff *receive_copy(struct sky2_port *sky2,
>   	skb = netdev_alloc_skb_ip_align(sky2->netdev, length);
>   	if (likely(skb)) {
>   		pci_dma_sync_single_for_cpu(sky2->hw->pdev, re->data_addr,
> -					    length, PCI_DMA_FROMDEVICE);
> +					    pci_unmap_len(re, data_size),
> +					    PCI_DMA_FROMDEVICE);
>   		skb_copy_from_linear_data(re->skb, skb->data, length);
>   		skb->ip_summed = re->skb->ip_summed;
>   		skb->csum = re->skb->csum;
>   		pci_dma_sync_single_for_device(sky2->hw->pdev, re->data_addr,
> -					       length, PCI_DMA_FROMDEVICE);
> +					       pci_unmap_len(re, data_size),
> +					       PCI_DMA_FROMDEVICE);
>   		re->skb->ip_summed = CHECKSUM_NONE;
>   		skb_put(skb, length);
>   	}
>    
Just a testing update: I went back to CONFIG_DMAR=Y yesterday and have 
not (yet) encountered the sky2 crash I'd been having prior to this fix. 
I've been pumping traffic through, and based on pre-patch experience, it 
would likely have crashed by now.

Will keep the system up for the next couple of days w/o reboot to 
confirm that the sky2 lockup I'd been seeing has stopped happening with 
this patch.

Test notes:

1) Warning previously apparent on start (dma_debug check_sync) with 
CONFIG_DMAR=n is gone.
2) W/o the above patch, I was getting sky2 DMAR errors and subsequent TX 
hangs requiring reboot to clear. The hangs happened after at least 12 
hours of uptime, and under RX load at the time of the hang.
3) With the above patch (and no other changes) I have not been able to 
recreate the crash - the system is stable.

I have been following the discussion about the DMA api would suggest 
that the length issue when DMAR is enabled is less innocuous than 
previously believed.
