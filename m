From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Tue, 19 Jan 2010 20:01:10 -0500
Message-ID: <4B5655D6.8090503@majjas.com>
References: <20100118212516.GE3157@del.dom.local> <4B54D50C.90608@majjas.com>
 <20100118220814.GG3157@del.dom.local> <20100118221747.GH3157@del.dom.local>
 <4B54E4EF.8080602@majjas.com> <4B554730.6090000@majjas.com>
 <20100119104739.GA9088@ff.dom.local> <4B55D40F.5080509@majjas.com>
 <20100119195933.GA3060@del.dom.local> <4B5610A9.7030902@majjas.com>
 <20100119224508.GA3473@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta3.srv.hcvlny.cv.net ([167.206.4.198]:39900 "EHLO
	mta3.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141Ab0ATBBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 20:01:44 -0500
In-reply-to: <20100119224508.GA3473@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/19/2010 5:45 PM, Jarek Poplawski wrote:
> On Tue, Jan 19, 2010 at 03:06:01PM -0500, Michael Breuer wrote:
>    
>> On 1/19/2010 2:59 PM, Jarek Poplawski wrote:
>>      
>>> On Tue, Jan 19, 2010 at 10:47:27AM -0500, Michael Breuer wrote:
>>> ...
>>>        
>>>> Still get the warning... but now 60 bytes.
>>>> Jan 19 10:43:50 mail kernel: ------------[ cut here ]------------
>>>> Jan 19 10:43:50 mail kernel: WARNING: at lib/dma-debug.c:902
>>>>          
>>> Thanks for trying this.
>>> Jarek P.
>>>        
>> NP. Let me know what else I can do to help with this one. Note that
>> it seems innocuous. I'll continue with the older set and no dmar for
>> now and see if I get another crash.
>>      
> Maybe one more idea to try (not compiled).
>
> Jarek P.
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
That not only compiled, but it cleared the error as well. Additionally, 
I used to see a bit of a delay receiving the login prompt when first 
connecting to the box by ssh. That delay is gone with this patch. I'd 
guess that the warning wasn't quite as innocuous as I thought.
Note: tested on 2.6.32.4.  I'll leave this up for a bit before 
attempting to move back to head.
