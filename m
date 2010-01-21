From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Thu, 21 Jan 2010 17:14:05 +0100
Message-ID: <4B587D4D.2010300@s5r6.in-berlin.de>
References: <20100118212516.GE3157@del.dom.local>	<4B54D50C.90608@majjas.com>	<20100118220814.GG3157@del.dom.local>	<20100118221747.GH3157@del.dom.local>	<4B54E4EF.8080602@majjas.com>	<4B554730.6090000@majjas.com>	<20100119104739.GA9088@ff.dom.local>	<4B55D40F.5080509@majjas.com>	<20100119195933.GA3060@del.dom.local>	<4B5610A9.7030902@majjas.com>	<20100119224508.GA3473@del.dom.local>	<4B5655D6.8090503@majjas.com> <20100119171013.207cac5c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Breuer <mbreuer@majjas.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753201Ab0AUQP7@vger.kernel.org>
In-Reply-To: <20100119171013.207cac5c@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 19 Jan 2010 20:01:10 -0500
> Michael Breuer <mbreuer@majjas.com> wrote:
>> On 1/19/2010 5:45 PM, Jarek Poplawski wrote:
[...]
>> > --- a/drivers/net/sky2.c
>> > +++ b/drivers/net/sky2.c
>> > @@ -2252,12 +2252,14 @@ static struct sk_buff *receive_copy(struct sky2_port *sky2,
>> >   	skb = netdev_alloc_skb_ip_align(sky2->netdev, length);
>> >   	if (likely(skb)) {
>> >   		pci_dma_sync_single_for_cpu(sky2->hw->pdev, re->data_addr,
>> > -					    length, PCI_DMA_FROMDEVICE);
>> > +					    pci_unmap_len(re, data_size),
>> > +					    PCI_DMA_FROMDEVICE);
>> >   		skb_copy_from_linear_data(re->skb, skb->data, length);
>> >   		skb->ip_summed = re->skb->ip_summed;
>> >   		skb->csum = re->skb->csum;
>> >   		pci_dma_sync_single_for_device(sky2->hw->pdev, re->data_addr,
>> > -					       length, PCI_DMA_FROMDEVICE);
>> > +					       pci_unmap_len(re, data_size),
>> > +					       PCI_DMA_FROMDEVICE);
>> >   		re->skb->ip_summed = CHECKSUM_NONE;
>> >   		skb_put(skb, length);
>> >   	}
>> >    
>> That not only compiled, but it cleared the error as well. Additionally, 
>> I used to see a bit of a delay receiving the login prompt when first 
>> connecting to the box by ssh. That delay is gone with this patch. I'd 
>> guess that the warning wasn't quite as innocuous as I thought.
>> Note: tested on 2.6.32.4.  I'll leave this up for a bit before 
>> attempting to move back to head.
> 
> Seems like an underlying bug in the DMA api. Maybe it just can't
> handle operations on partial mapping.
> 
> Other drivers with same problem:
>   bnx2, cassini, pcnet32, r8169, rrunner, skge, sungem, tg3, 

I didn't read the start of this thread and may misunderstand the issue,
but I comment anyway...:

Documentation/DMA-API.txt says the following about (pci_)dma_sync_single
and friends:  "All the parameters must be the same as those passed into
the single mapping API."
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=Documentation/DMA-API.txt;h=5aceb88b3f8b622c8c23ed288f37f42de705c904;hb=HEAD#l367

So, it might be considered an API bug --- but it is a documented one. :-)
-- 
Stefan Richter
-=====-==-=- ---= =-=-=
http://arcgraph.de/sr/
