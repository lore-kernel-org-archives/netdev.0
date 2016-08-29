From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH] e1000: add initial XDP support
Date: Sun, 28 Aug 2016 22:33:56 -0700
Message-ID: <57C3C944.2050902@gmail.com>
References: <20160827071145.25345.84712.stgit@john-Precision-Tower-5810>
 <CAJ3xEMh_oXucmESb3w9Mevnu7Pb+zHkozF=WqxoWMY3FijTnDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>,
        David Miller <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33012 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbcH2FeM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 01:34:12 -0400
Received: by mail-pa0-f65.google.com with SMTP id vy10so8318426pac.0
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 22:34:12 -0700 (PDT)
In-Reply-To: <CAJ3xEMh_oXucmESb3w9Mevnu7Pb+zHkozF=WqxoWMY3FijTnDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-27 10:55 PM, Or Gerlitz wrote:
> On Sat, Aug 27, 2016 at 10:11 AM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> From: Alexei Starovoitov <ast@fb.com>
> 
>> This patch adds initial support for XDP on e1000 driver. Note e1000
>> driver does not support page recycling in general which could be
>> added as a further improvement. However for XDP_DROP and XDP_XMIT
>> the xdp code paths will recycle pages.
> 
>> @@ -4188,15 +4305,57 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
>>                 prefetch(next_rxd);
>>
>>                 next_buffer = &rx_ring->buffer_info[i];
>> -
> 
> nit, better to avoid random cleanups in a patch adding new (&& cool)
> functionality
> 

Yep thanks.

[...]

>> +                       case XDP_TX:
>> +                               dma_sync_single_for_device(&pdev->dev,
>> +                                                          dma,
>> +                                                          length,
>> +                                                          DMA_TO_DEVICE);
>> +                               e1000_xmit_raw_frame(buffer_info, length,
>> +                                                    netdev, adapter);
>> +                       /* Fallthrough to re-use mappedg page after xmit */
> 
> Did you want to say "mapped"? wasn't sure what's the role of "g" @ the end

Yep but see below...

> 
>> +                       case XDP_DROP:
>> +                       default:
>> +                               /* re-use mapped page. keep buffer_info->dma
>> +                                * as-is, so that e1000_alloc_jumbo_rx_buffers
>> +                                * only needs to put it back into rx ring
>> +                                */
> 
> if we're on the XDP_TX pass, don't we need to actually see that frame
> has been xmitted
> before re using the page?
> 

Agreed this seems to be too ambitious in the XDP_TX case. Thanks for
the help. Unless Alexei has some reason why it works I'll go ahead and
consume the buffer here.

I think setting

+                               bi->rxbuf.page = NULL;

at the end of the XDP_TX case should fix it but I'll test it again,

Thanks again I guess this is what I get for trying to push patches out
on Friday night.



>> +                               total_rx_bytes += length;
>> +                               total_rx_packets++;
>> +                               goto next_desc;
>> +                       }
>> +               }
>> +
>>                 dma_unmap_page(&pdev->dev, buffer_info->dma,
>>                                adapter->rx_buffer_len, DMA_FROM_DEVICE);
>>                 buffer_info->dma = 0;
