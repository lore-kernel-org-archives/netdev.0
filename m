From: Jason Wang <jasowang@redhat.com>
Subject: Re: DQL and TCQ_F_CAN_BYPASS destroy performance under virtualizaiton
 (Was: "Re: net_sched strange in 4.11")
Date: Thu, 11 May 2017 10:43:58 +0800
Message-ID: <c11c50db-4e66-f3c2-5ebb-519ad6dbc2fe@redhat.com>
References: <66c5c2d3-65df-8506-6934-5628e709e229@cambridgegreys.com>
 <27ae4e1c-7c6c-14c2-f3a4-9d0b1265d034@cambridgegreys.com>
 <20170509151109.GH16825@stefanha-x1.localdomain>
 <52801b17-d8af-eaba-3ecf-fa4495c352f5@redhat.com>
 <16de49b9-dec1-d1df-aa59-dedd90fffb92@cambridgegreys.com>
 <6accf7bd-fb21-604b-9586-ecd0f6830a65@redhat.com>
 <c9fe2748-0a14-17f4-3742-3184f0b2831b@cambridgegreys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        "Michael S. Tsirkin" <mst@redhat.com>
To: Anton Ivanov <anton.ivanov@cambridgegreys.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47148 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752398AbdEKCoI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 10 May 2017 22:44:08 -0400
In-Reply-To: <c9fe2748-0a14-17f4-3742-3184f0b2831b@cambridgegreys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年05月10日 17:42, Anton Ivanov wrote:
> On 10/05/17 09:56, Jason Wang wrote:
>>
>>
>> On 2017年05月10日 13:28, Anton Ivanov wrote:
>>> On 10/05/17 03:18, Jason Wang wrote:
>>>>
>>>> On 2017年05月09日 23:11, Stefan Hajnoczi wrote:
>>>>> On Tue, May 09, 2017 at 08:46:46AM +0100, Anton Ivanov wrote:
>>>>>> I have figured it out. Two issues.
>>>>>>
>>>>>> 1) skb->xmit_more is hardly ever set under virtualization because
>>>>>> the qdisc
>>>>>> is usually bypassed because of TCQ_F_CAN_BYPASS. Once
>>>>>> TCQ_F_CAN_BYPASS is
>>>>>> set a virtual NIC driver is not likely see skb->xmit_more (this
>>>>>> answers my
>>>>>> "how does this work at all" question).
>>>>>>
>>>>>> 2) If that flag is turned off (I patched sched_generic to turn it
>>>>>> off in
>>>>>> pfifo_fast while testing), DQL keeps xmit_more from being set. If
>>>>>> the driver
>>>>>> is not DQL enabled xmit_more is never ever set. If the driver is DQL
>>>>>> enabled
>>>>>> the queue is adjusted to ensure xmit_more stops happening within
>>>>>> 10-15 xmit
>>>>>> cycles.
>>>>>>
>>>>>> That is plain *wrong* for virtual NICs - virtio, emulated NICs, etc.
>>>>>> There,
>>>>>> the BIG cost is telling the hypervisor that it needs to "kick" the
>>>>>> packets.
>>>>>> The cost of putting them into the vNIC buffers is negligible. You 
>>>>>> want
>>>>>> xmit_more to happen - it makes between 50% and 300% (depending on 
>>>>>> vNIC
>>>>>> design) difference. If there is no xmit_more the vNIC will 
>>>>>> immediately
>>>>>> "kick" the hypervisor and try to signal that  the packet needs to 
>>>>>> move
>>>>>> straight away (as for example in virtio_net).
>>>> How do you measure the performance? TCP or just measure pps?
>>> In this particular case - tcp from guest. I have a couple of other
>>> benchmarks (forwarding, etc).
>>
>> One more question, is the number for virtio-net or other emulated vNIC?
>
> Other for now - you are cc-ed to keep you in the loop.
>
> Virtio is next on my list - I am revisiting the l2tpv3.c driver in 
> QEMU and looking at how to preserve bulking by adding back sendmmsg 
> (as well as a list of other features/transports).
>
> We had sendmmsg removed for the final inclusion in QEMU 2.1, it 
> presently uses only recvmmsg so for the time being it does not care. 
> That will most likely change once it starts using sendmmsg as well.

An issue is that qemu net API does not support bulking, do you plan to 
add it?

Thanks
