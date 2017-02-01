From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 1/2] af_packet: direct dma for packet ineterface
Date: Tue, 31 Jan 2017 21:01:54 -0800
Message-ID: <58916BC2.9020005@gmail.com>
References: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
 <20170127213344.14162.59976.stgit@john-Precision-Tower-5810>
 <20170130191607.14d964e4@redhat.com> <588FB57B.1060507@gmail.com>
 <20170131132015.68e7d631@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bjorn.topel@gmail.com, jasowang@redhat.com, ast@fb.com,
        alexander.duyck@gmail.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33652 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750946AbdBAFCR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 00:02:17 -0500
Received: by mail-pg0-f68.google.com with SMTP id 194so33023924pgd.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 21:02:16 -0800 (PST)
In-Reply-To: <20170131132015.68e7d631@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>>>   
>>>> The ndo operations and new socket option PACKET_RX_DIRECT work by
>>>> giving a queue_index to run the direct dma operations over. Once
>>>> setsockopt returns successfully the indicated queue is mapped
>>>> directly to the requesting application and can not be used for
>>>> other purposes. Also any kernel layers such as tc will be bypassed
>>>> and need to be implemented in the hardware via some other mechanism
>>>> such as tc offload or other offload interfaces.  
>>>
>>> Will this also need to bypass XDP too?  
>>
>> There is nothing stopping this from working with XDP but why would
>> you want to run XDP here?
>>
>> Dropping a packet for example is not really useful because its
>> already in memory user space can read. Modifying the packet seems
>> pointless user space can modify it. 
>>
>> Maybe pushing a copy of the packet
>> to kernel stack is useful in some case? But I can't see where I would
>> want this.
> 
> Wouldn't it be useful to pass ARP packets to kernel stack?
> (E.g. if your HW filter is based on MAC addr match)
> 

Problem is we already zero-copied the packet into user space. I really
don't want to have a packet in user space and kernel space at the same
time. That seems like a big mess to me around security and isolation.

Much better to have the hardware push arp packet onto the correct hardware
queue so that arp packets get sent into the stack. With the ARP example
its easy enough to put a high priority rule in hardware to match the
protocol.

> 
>>> E.g. how will you support XDP_TX?  AFAIK you cannot remove/detach a
>>> packet with this solution (and place it on a TX queue and wait for DMA
>>> TX completion).
>>>   
>>
>> This is something worth exploring. tpacket_v2 uses a fixed ring with
>> slots so all the pages are allocated and assigned to the ring at init
>> time. To xmit a packet in this case the user space application would
>> be required to leave the packet descriptor on the rx side pinned
>> until the tx side DMA has completed. Then it can unpin the rx side
>> and return it to the driver. This works if the TX/RX processing is
>> fast enough to keep up. For many things this is good enough.
> 
> Sounds tricky.
>  
>> For some work loads though this may not be sufficient. In which
>> case a tpacket_v4 would be useful that can push down a new set
>> of "slots" every n packets. Where n is sufficiently large to keep
>> the workload running. This is similar in many ways to virtio/vhost
>> interaction.
> 
> This starts to sound like to need a page pool like facility with
> pages premapped DMA and premapped to userspace...
> 

I'm not sure what premapped to userspace means in this case. Here the
application uses mmap or some other mechanism to get a set of pages and
then pushes them down to the device. I think a mechanism such as that
used in virtio would solve this problem nicely. I'll take a look at it
and send another RFC out.

>>>   
> [...]
>>>
>>> Guess, I don't understand the details of the af_packet versions well
>>> enough, but can you explain to me, how userspace knows what slots it
>>> can read/fetch, and how it marks when it is complete/finished so the
>>> kernel knows it can reuse this slot?
>>>   
>>
>> At init time user space allocates a ring of buffers. Each buffer has
>> space to hold the packet descriptor + packet payload. The API gives this
>> to the driver to initialize DMA engine and assign addresses. At init
>> time all buffers are "owned" by the driver which is indicated by a status bit
>> in the descriptor header.
>>
>> Userspace can spin on the status bit to know when the driver has handed
>> it to userspace. The driver will check the status bit before returning
>> the buffer to the hardware. Then a series of kicks are used to wake up
>> userspace (if its not spinning) and to wake up the driver if it is overrun
>> and needs to return buffers into its pool (not implemented yet). The
>> kick to wake up the driver could in a future v4 be used to push new
>> buffers to the driver if needed.
> 
> As I wrote above, this status bit spinning approach is good and actually
> achieving a bulking effect indirectly.
> 

Yep.

Thanks,
John
