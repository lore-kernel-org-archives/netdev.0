From: Jason Wang <jasowang@redhat.com>
Subject: Re: DQL and TCQ_F_CAN_BYPASS destroy performance under virtualizaiton
 (Was: "Re: net_sched strange in 4.11")
Date: Wed, 10 May 2017 10:18:22 +0800
Message-ID: <52801b17-d8af-eaba-3ecf-fa4495c352f5@redhat.com>
References: <66c5c2d3-65df-8506-6934-5628e709e229@cambridgegreys.com>
 <27ae4e1c-7c6c-14c2-f3a4-9d0b1265d034@cambridgegreys.com>
 <20170509151109.GH16825@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        "Michael S. Tsirkin" <mst@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>,
        Anton Ivanov <anton.ivanov@cambridgegreys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48278 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750733AbdEJCSe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 22:18:34 -0400
In-Reply-To: <20170509151109.GH16825@stefanha-x1.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年05月09日 23:11, Stefan Hajnoczi wrote:
> On Tue, May 09, 2017 at 08:46:46AM +0100, Anton Ivanov wrote:
>> I have figured it out. Two issues.
>>
>> 1) skb->xmit_more is hardly ever set under virtualization because the qdisc
>> is usually bypassed because of TCQ_F_CAN_BYPASS. Once TCQ_F_CAN_BYPASS is
>> set a virtual NIC driver is not likely see skb->xmit_more (this answers my
>> "how does this work at all" question).
>>
>> 2) If that flag is turned off (I patched sched_generic to turn it off in
>> pfifo_fast while testing), DQL keeps xmit_more from being set. If the driver
>> is not DQL enabled xmit_more is never ever set. If the driver is DQL enabled
>> the queue is adjusted to ensure xmit_more stops happening within 10-15 xmit
>> cycles.
>>
>> That is plain *wrong* for virtual NICs - virtio, emulated NICs, etc. There,
>> the BIG cost is telling the hypervisor that it needs to "kick" the packets.
>> The cost of putting them into the vNIC buffers is negligible. You want
>> xmit_more to happen - it makes between 50% and 300% (depending on vNIC
>> design) difference. If there is no xmit_more the vNIC will immediately
>> "kick" the hypervisor and try to signal that  the packet needs to move
>> straight away (as for example in virtio_net).

How do you measure the performance? TCP or just measure pps?

>>
>> In addition to that, the perceived line rate is proportional to this cost,
>> so I am not sure that the current dql math holds. In fact, I think it does
>> not - it is trying to adjust something which influences the perceived line
>> rate.
>>
>> So - how do we turn BOTH bypass and DQL adjustment while under
>> virtualization and set them to be "always qdisc" + "always xmit_more
>> allowed"

Virtio-net net does not support BQL. Before commit ea7735d97ba9 
("virtio-net: move free_old_xmit_skbs"), it's even impossible to support 
that since we don't have tx interrupt for each packet.  I haven't 
measured the impact of xmit_more, maybe I was wrong but I think it may 
help in some cases since it may improve the batching on host more or less.

Thanks

>>
>> A.
>>
>> P.S. Cc-ing virtio maintainer
> CCing Michael Tsirkin and Jason Wang, who are the core virtio and
> virtio-net maintainers.  (I maintain the vsock driver - it's unrelated
> to this discussion.)
>
>> A.
>>
>>
>> On 08/05/17 08:15, Anton Ivanov wrote:
>>> Hi all,
>>>
>>> I was revising some of my old work for UML to prepare it for submission
>>> and I noticed that skb->xmit_more does not seem to be set any more.
>>>
>>> I traced the issue as far as net/sched/sched_generic.c
>>>
>>> try_bulk_dequeue_skb() is never invoked (the drivers I am working on are
>>> dql enabled so that is not the problem).
>>>
>>> More interestingly, if I put a breakpoint and debug output into
>>> dequeue_skb() around line 147 - right before the bulk: tag that skb
>>> there is always NULL. ???
>>>
>>> Similarly, debug in pfifo_fast_dequeue shows only NULLs being dequeued.
>>> Again - ???
>>>
>>> First and foremost, I apologize for the silly question, but how can this
>>> work at all? I see the skbs showing up at the driver level, why are
>>> NULLs being returned at qdisc dequeue and where do the skbs at the
>>> driver level come from?
>>>
>>> Second, where should I look to fix it?
>>>
>>> A.
>>>
>>
>> -- 
>> Anton R. Ivanov
>>
>> Cambridge Greys Limited, England company No 10273661
>> http://www.cambridgegreys.com/
>>
