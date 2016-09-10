From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH v2 2/2] e1000: bundle xdp xmit routines
Date: Fri, 9 Sep 2016 21:13:13 -0700
Message-ID: <CALx6S373K92E5uabb8MtyHpDvkpWUQmZRmoRF7pFnZ3wBW68Cw@mail.gmail.com>
References: <20160909212915.4001.25504.stgit@john-Precision-Tower-5810>
 <20160909212938.4001.40540.stgit@john-Precision-Tower-5810>
 <CALx6S35VCq9yPjcuhtx6jEJ78-WugkQZ6GSsqkcTr0Fa7edkVg@mail.gmail.com>
 <57D34D67.40804@gmail.com> <CALx6S36dH87e6TPxEBGsy0F-vD0fZzKyP8tbuuaAfLNSF1DGpw@mail.gmail.com>
 <57D35E08.8010204@gmail.com> <CALx6S36SM-wq6Fj8XK7GfMta1dVGr3RZ5uAgGdnxm7kgpVNFbw@mail.gmail.com>
 <20160910014032.GA83023@ast-mbp.thefacebook.com> <CALx6S36Xo4ZJJg5k2RT9rcT_1_zKRG1n_EOruU=JqvXBnq=E3w@mail.gmail.com>
 <57D37D79.1050806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        William Tu <u9012063@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:35274 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753490AbcIJENO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 00:13:14 -0400
Received: by mail-qt0-f169.google.com with SMTP id 93so50494514qtg.2
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 21:13:14 -0700 (PDT)
In-Reply-To: <57D37D79.1050806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 9, 2016 at 8:26 PM, John Fastabend <john.fastabend@gmail.com> wrote:
> On 16-09-09 08:12 PM, Tom Herbert wrote:
>> On Fri, Sep 9, 2016 at 6:40 PM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>>> On Fri, Sep 09, 2016 at 06:19:56PM -0700, Tom Herbert wrote:
>>>> On Fri, Sep 9, 2016 at 6:12 PM, John Fastabend <john.fastabend@gmail.com> wrote:
>>>>> On 16-09-09 06:04 PM, Tom Herbert wrote:
>>>>>> On Fri, Sep 9, 2016 at 5:01 PM, John Fastabend <john.fastabend@gmail.com> wrote:
>>>>>>> On 16-09-09 04:44 PM, Tom Herbert wrote:
>>>>>>>> On Fri, Sep 9, 2016 at 2:29 PM, John Fastabend <john.fastabend@gmail.com> wrote:
>>>>>>>>> e1000 supports a single TX queue so it is being shared with the stack
>>>>>>>>> when XDP runs XDP_TX action. This requires taking the xmit lock to
>>>>>>>>> ensure we don't corrupt the tx ring. To avoid taking and dropping the
>>>>>>>>> lock per packet this patch adds a bundling implementation to submit
>>>>>>>>> a bundle of packets to the xmit routine.
>>>>>>>>>
>>>>>>>>> I tested this patch running e1000 in a VM using KVM over a tap
>>>>>>>>> device using pktgen to generate traffic along with 'ping -f -l 100'.
>>>>>>>>>
>>>>>>>> Hi John,
>>>>>>>>
>>>>>>>> How does this interact with BQL on e1000?
>>>>>>>>
>>>>>>>> Tom
>>>>>>>>
>>>>>>>
>>>>>>> Let me check if I have the API correct. When we enqueue a packet to
>>>>>>> be sent we must issue a netdev_sent_queue() call and then on actual
>>>>>>> transmission issue a netdev_completed_queue().
>>>>>>>
>>>>>>> The patch attached here missed a few things though.
>>>>>>>
>>>>>>> But it looks like I just need to call netdev_sent_queue() from the
>>>>>>> e1000_xmit_raw_frame() routine and then let the tx completion logic
>>>>>>> kick in which will call netdev_completed_queue() correctly.
>>>>>>>
>>>>>>> I'll need to add a check for the queue state as well. So if I do these
>>>>>>> three things,
>>>>>>>
>>>>>>>         check __QUEUE_STATE_XOFF before sending
>>>>>>>         netdev_sent_queue() -> on XDP_TX
>>>>>>>         netdev_completed_queue()
>>>>>>>
>>>>>>> It should work agree? Now should we do this even when XDP owns the
>>>>>>> queue? Or is this purely an issue with sharing the queue between
>>>>>>> XDP and stack.
>>>>>>>
>>>>>> But what is the action for XDP_TX if the queue is stopped? There is no
>>>>>> qdisc to back pressure in the XDP path. Would we just start dropping
>>>>>> packets then?
>>>>>
>>>>> Yep that is what the patch does if there is any sort of error packets
>>>>> get dropped on the floor. I don't think there is anything else that
>>>>> can be done.
>>>>>
>>>> That probably means that the stack will always win out under load.
>>>> Trying to used the same queue where half of the packets are well
>>>> managed by a qdisc and half aren't is going to leave someone unhappy.
>>>> Maybe in the this case where we have to share the qdisc we can
>>>> allocate the skb on on returning XDP_TX and send through the normal
>>>> qdisc for the device.
>>>
>>> I wouldn't go to such extremes for e1k.
>>> The only reason to have xdp in e1k is to use it for testing
>>> of xdp programs. Nothing else. e1k is, best case, 1Gbps adapter.
>>
>> I imagine someone may want this for the non-forwarding use cases like
>> early drop for DOS mitigation. Regardless of the use case, I don't
>> think we can break the fundamental assumptions made for qdiscs or the
>> rest of the transmit path. If XDP must transmit on a queue shared with
>> the stack we need to abide by the stack's rules for transmitting on
>> the queue-- which would mean alloc skbuff and go through qdisc (which
>
> If we require XDP_TX to go up to qdisc layer its best not to implement
> it at all and just handle it in normal ingress path. That said I think
> users have to expect that XDP will interfere with qdisc schemes. Even
> with its own tx queue its going to interfere at the hardware level with
> bandwidth as the hardware round robins through the queues or uses
> whatever hardware strategy it is configured to use. Additionally it
> will bypass things like BQL, etc.
>
Right, but not all use cases involve XDP_TX (like DOS mitigation as I
pointed out). Since you've already done 95% of the work, can you take
a look at creating the skbuff and injecting into the stack for XDP_TX
so we can evaluate the performance and impact of that :-)

With separate TX queues it's explicit which queues are managed by the
stack. This is no different than what kernel bypass gives use, we are
relying on HW to do something reasonable in scheduling MQ.

>> really shouldn't be difficult to implement). Emulating various
>> functions of the stack in the XDP TX path, like this patch seems to be
>> doing for XMIT_MORE, potentially gets us into a wack-a-mole situation
>> trying to keep things coherent.
>
> I think bundling tx xmits is fair game as an internal optimization and
> doesn't need to be exposed at the XDP layer. Drivers already do this
> type of optimizations for allocating buffers. It likely doesn't matter
> much at the e1k level but doing a tail update on every pkt with the
> 40gbps drivers likely will be noticeable is my gut feeling.
>
How is this different than what XMIT_MORE gives us?

Tom

>
>>
>>> Existing stack with skb is perfectly fine as it is.
>>> No need to do recycling, batching or any other complex things.
>>> xdp for e1k cannot be used as an example for other drivers either,
>>> since there is only one tx ring and any high performance adapter
>>> has more which makes the driver support quite different.
>>>
>
