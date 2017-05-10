From: Anton Ivanov <anton.ivanov@cambridgegreys.com>
Subject: Re: DQL and TCQ_F_CAN_BYPASS destroy performance under virtualizaiton
 (Was: "Re: net_sched strange in 4.11")
Date: Wed, 10 May 2017 10:42:44 +0100
Message-ID: <c9fe2748-0a14-17f4-3742-3184f0b2831b@cambridgegreys.com>
References: <66c5c2d3-65df-8506-6934-5628e709e229@cambridgegreys.com>
 <27ae4e1c-7c6c-14c2-f3a4-9d0b1265d034@cambridgegreys.com>
 <20170509151109.GH16825@stefanha-x1.localdomain>
 <52801b17-d8af-eaba-3ecf-fa4495c352f5@redhat.com>
 <16de49b9-dec1-d1df-aa59-dedd90fffb92@cambridgegreys.com>
 <6accf7bd-fb21-604b-9586-ecd0f6830a65@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab5.miniserver.com ([78.31.111.25]:41103 "EHLO
        www.kot-begemot.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751976AbdEJJmt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 05:42:49 -0400
In-Reply-To: <6accf7bd-fb21-604b-9586-ecd0f6830a65@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/17 09:56, Jason Wang wrote:
>
>
> On 2017年05月10日 13:28, Anton Ivanov wrote:
>> On 10/05/17 03:18, Jason Wang wrote:
>>>
>>> On 2017年05月09日 23:11, Stefan Hajnoczi wrote:
>>>> On Tue, May 09, 2017 at 08:46:46AM +0100, Anton Ivanov wrote:
>>>>> I have figured it out. Two issues.
>>>>>
>>>>> 1) skb->xmit_more is hardly ever set under virtualization because
>>>>> the qdisc
>>>>> is usually bypassed because of TCQ_F_CAN_BYPASS. Once
>>>>> TCQ_F_CAN_BYPASS is
>>>>> set a virtual NIC driver is not likely see skb->xmit_more (this
>>>>> answers my
>>>>> "how does this work at all" question).
>>>>>
>>>>> 2) If that flag is turned off (I patched sched_generic to turn it
>>>>> off in
>>>>> pfifo_fast while testing), DQL keeps xmit_more from being set. If
>>>>> the driver
>>>>> is not DQL enabled xmit_more is never ever set. If the driver is DQL
>>>>> enabled
>>>>> the queue is adjusted to ensure xmit_more stops happening within
>>>>> 10-15 xmit
>>>>> cycles.
>>>>>
>>>>> That is plain *wrong* for virtual NICs - virtio, emulated NICs, etc.
>>>>> There,
>>>>> the BIG cost is telling the hypervisor that it needs to "kick" the
>>>>> packets.
>>>>> The cost of putting them into the vNIC buffers is negligible. You 
>>>>> want
>>>>> xmit_more to happen - it makes between 50% and 300% (depending on 
>>>>> vNIC
>>>>> design) difference. If there is no xmit_more the vNIC will 
>>>>> immediately
>>>>> "kick" the hypervisor and try to signal that  the packet needs to 
>>>>> move
>>>>> straight away (as for example in virtio_net).
>>> How do you measure the performance? TCP or just measure pps?
>> In this particular case - tcp from guest. I have a couple of other
>> benchmarks (forwarding, etc).
>
> One more question, is the number for virtio-net or other emulated vNIC?

Other for now - you are cc-ed to keep you in the loop.

Virtio is next on my list - I am revisiting the l2tpv3.c driver in QEMU 
and looking at how to preserve bulking by adding back sendmmsg (as well 
as a list of other features/transports).

We had sendmmsg removed for the final inclusion in QEMU 2.1, it 
presently uses only recvmmsg so for the time being it does not care. 
That will most likely change once it starts using sendmmsg as well.

>
>>
>>>>> In addition to that, the perceived line rate is proportional to this
>>>>> cost,
>>>>> so I am not sure that the current dql math holds. In fact, I think
>>>>> it does
>>>>> not - it is trying to adjust something which influences the
>>>>> perceived line
>>>>> rate.
>>>>>
>>>>> So - how do we turn BOTH bypass and DQL adjustment while under
>>>>> virtualization and set them to be "always qdisc" + "always xmit_more
>>>>> allowed"
>>> Virtio-net net does not support BQL. Before commit ea7735d97ba9
>>> ("virtio-net: move free_old_xmit_skbs"), it's even impossible to
>>> support that since we don't have tx interrupt for each packet.  I
>>> haven't measured the impact of xmit_more, maybe I was wrong but I
>>> think it may help in some cases since it may improve the batching on
>>> host more or less.
>> If you do not support BQL, you might as well look the xmit_more part
>> kick code path. Line 1127.
>>
>> bool kick = !skb->xmit_more; effectively means kick = true;
>>
>> It will never be triggered. You will be kicking each packet and per
>> packet.
>
> Probably not, we have several ways to try to suppress this on the 
> virtio layer, host can give hints to disable the kicks through:
>
> - explicitly set a flag
> - implicitly by not publishing a new event idx
>
> FYI, I can get 100-200 packets per vm exit when testing 64 byte 
> TCP_STREAM using netperf.

I am aware of that. If, however, the host is providing a hint we might 
as well use it.

>
>> xmit_more is now set only out of BQL. If BQL is not enabled you
>> never get it. Now, will the current dql code work correctly if you do
>> not have a defined line rate and completion interrupts - no idea.
>> Probably not. IMHO instead of trying to fix it there should be a way for
>> a device or architecture to turn it off.
>
> In fact BQL is not the only user for xmit_more. Pktgen with burst is 
> another. Test does not show obvious difference if I set burst from 0 
> to 64 since we already had other ways to avoid kicking host.

That, as well as this not being wired to bulk transport.

>
>>
>> To be clear - I ran into this working on my own drivers for UML, you are
>> cc-ed because you are likely to be one of the most affected.
>
> I'm still not quite sure the issue. Looks like virtio-net is ok since 
> BQL is not supported and the impact of xmit_more could be ignored.

Presently - yes. If you have bulk aware transports to wire into that is 
likely to make a difference.

>
> Thanks
>
>>
>> A.
>>
>>> Thanks
>>>
>>>>> A.
>>>>>
>>>>> P.S. Cc-ing virtio maintainer
>>>> CCing Michael Tsirkin and Jason Wang, who are the core virtio and
>>>> virtio-net maintainers.  (I maintain the vsock driver - it's unrelated
>>>> to this discussion.)
>>>>
>>>>> A.
>>>>>
>>>>>
>>>>> On 08/05/17 08:15, Anton Ivanov wrote:
>>>>>> Hi all,
>>>>>>
>>>>>> I was revising some of my old work for UML to prepare it for
>>>>>> submission
>>>>>> and I noticed that skb->xmit_more does not seem to be set any more.
>>>>>>
>>>>>> I traced the issue as far as net/sched/sched_generic.c
>>>>>>
>>>>>> try_bulk_dequeue_skb() is never invoked (the drivers I am working
>>>>>> on are
>>>>>> dql enabled so that is not the problem).
>>>>>>
>>>>>> More interestingly, if I put a breakpoint and debug output into
>>>>>> dequeue_skb() around line 147 - right before the bulk: tag that skb
>>>>>> there is always NULL. ???
>>>>>>
>>>>>> Similarly, debug in pfifo_fast_dequeue shows only NULLs being
>>>>>> dequeued.
>>>>>> Again - ???
>>>>>>
>>>>>> First and foremost, I apologize for the silly question, but how can
>>>>>> this
>>>>>> work at all? I see the skbs showing up at the driver level, why are
>>>>>> NULLs being returned at qdisc dequeue and where do the skbs at the
>>>>>> driver level come from?
>>>>>>
>>>>>> Second, where should I look to fix it?
>>>>>>
>>>>>> A.
>>>>>>
>>>>> -- 
>>>>> Anton R. Ivanov
>>>>>
>>>>> Cambridge Greys Limited, England company No 10273661
>>>>> http://www.cambridgegreys.com/
>>>>>
>>>
>>
>
>


-- 
Anton R. Ivanov

Cambridge Greys Limited, England company No 10273661
http://www.cambridgegreys.com/
