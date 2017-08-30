From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Wed, 30 Aug 2017 09:45:50 +0800
Message-ID: <b8893b72-4d09-2492-0d31-5135286e6874@redhat.com>
References: <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
 <20170822204015-mutt-send-email-mst@kernel.org>
 <1503498504.8694.26.camel@klaipeden.com>
 <CAF=yD-+U_aWxSmPPY8v8t=JO0MRZ+N+DzVJTAMKYQ5F=pE1PfA@mail.gmail.com>
 <20170824014553-mutt-send-email-mst@kernel.org>
 <CAF=yD-KSek+LmZu0X0TXetmFEQ59iF3NpjZ4KugbwLo1BGfhaA@mail.gmail.com>
 <20170824160748-mutt-send-email-mst@kernel.org>
 <CAF=yD-+9Ah8pC9i2w3Ad3WnhQit7Yo479pMrToty7priL6BFLw@mail.gmail.com>
 <20170824234551-mutt-send-email-mst@kernel.org>
 <CAF=yD-+1wheMmC+HFKe_B_ULO0Mmh6HMSEbYY5D-HgqxVJee6A@mail.gmail.com>
 <20170826022744-mutt-send-email-mst@kernel.org>
 <CAF=yD-Lre0NATUVH8p0zS=G5CiY=WfKSefLmOZw940jZFgECgQ@mail.gmail.com>
 <CAF=yD-+Wk9sc9dXMUq1+x_hh=3ThTXa6BnZkygP3tgVpjbp93g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Koichiro Den <den@klaipeden.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28432 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751887AbdH3Bp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 21:45:59 -0400
In-Reply-To: <CAF=yD-+Wk9sc9dXMUq1+x_hh=3ThTXa6BnZkygP3tgVpjbp93g@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年08月30日 03:35, Willem de Bruijn wrote:
> On Fri, Aug 25, 2017 at 9:03 PM, Willem de Bruijn
> <willemdebruijn.kernel@gmail.com> wrote:
>> On Fri, Aug 25, 2017 at 7:32 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
>>> On Fri, Aug 25, 2017 at 06:44:36PM -0400, Willem de Bruijn wrote:
>>>>>>>>> We don't enable network watchdog on virtio but we could and maybe
>>>>>>>>> should.
>>>>>>>> Can you elaborate?
>>>>>>> The issue is that holding onto buffers for very long times makes guests
>>>>>>> think they are stuck. This is funamentally because from guest point of
>>>>>>> view this is a NIC, so it is supposed to transmit things out in
>>>>>>> a timely manner. If host backs the virtual NIC by something that is not
>>>>>>> a NIC, with traffic shaping etc introducing unbounded latencies,
>>>>>>> guest will be confused.
>>>>>> That assumes that guests are fragile in this regard. A linux guest
>>>>>> does not make such assumptions.
>>>>> Yes it does. Examples above:
>>>>>          > > - a single slow flow can occupy the whole ring, you will not
>>>>>          > >   be able to make any new buffers available for the fast flow
>>>> Oh, right. Though those are due to vring_desc pool exhaustion
>>>> rather than an upper bound on latency of any single packet.
>>>>
>>>> Limiting the number of zerocopy packets in flight to some fraction
>>>> of the ring ensures that fast flows can always grab a slot.
>>>> Running
>>>> out of ubuf_info slots reverts to copy, so indirectly does this. But
>>>> I read it correclty the zerocopy pool may be equal to or larger than
>>>> the descriptor pool. Should we refine the zcopy_used test
>>>>
>>>>      (nvq->upend_idx + 1) % UIO_MAXIOV != nvq->done_idx
>>>>
>>>> to also return false if the number of outstanding ubuf_info is greater
>>>> than, say, vq->num >> 1?
>>>
>>> We'll need to think about where to put the threshold, but I think it's
>>> a good idea.
>>>
>>> Maybe even a fixed number, e.g. max(vq->num >> 1, X) to limit host
>>> resources.
>>>
>>> In a sense it still means once you run out of slots zcopt gets disabled possibly permanently.
>>>
>>> Need to experiment with some numbers.
>> I can take a stab with two flows, one delayed in a deep host qdisc
>> queue. See how this change affects the other flow and also how
>> sensitive that is to the chosen threshold value.
> Incomplete results at this stage, but I do see this correlation between
> flows. It occurs even while not running out of zerocopy descriptors,
> which I cannot yet explain.
>
> Running two threads in a guest, each with a udp socket, each
> sending up to 100 datagrams, or until EAGAIN, every msec.
>
> Sender A sends 1B datagrams.
> Sender B sends VHOST_GOODCOPY_LEN, which is enough
> to trigger zcopy_used in vhost net.
>
> A local receive process on the host receives both flows. To avoid
> a deep copy when looping the packet onto the receive path,
> changed skb_orphan_frags_rx to always return false (gross hack).
>
> The flow with the larger packets is redirected through netem on ifb0:
>
>    modprobe ifb
>    ip link set dev ifb0 up
>    tc qdisc add dev ifb0 root netem limit $LIMIT rate 1MBit
>
>    tc qdisc add dev tap0 ingress
>    tc filter add dev tap0 parent ffff: protocol ip \
>        u32 match ip dport 8000 0xffff \
>        action mirred egress redirect dev ifb0
>
> For 10 second run, packet count with various ifb0 queue lengths $LIMIT:
>
> no filter
>    rx.A: ~840,000
>    rx.B: ~840,000

Just to make sure I understand the case here. What did rx.B mean here? I 
thought all traffic sent by Sender B has been redirected to ifb0?

>
> limit 1
>    rx.A: ~500,000
>    rx.B: ~3100
>    ifb0: 3273 sent, 371141 dropped
>
> limit 100
>    rx.A: ~9000
>    rx.B: ~4200
>    ifb0: 4630 sent, 1491 dropped
>
> limit 1000
>    rx.A: ~6800
>    rx.B: ~4200
>    ifb0: 4651 sent, 0 dropped
>
> Sender B is always correctly rate limited to 1 MBps or less. With a
> short queue, it ends up dropping a lot and sending even less.
>
> When a queue builds up for sender B, sender A throughput is strongly
> correlated with queue length. With queue length 1, it can send almost
> at unthrottled speed. But even at limit 100 its throughput is on the
> same order as sender B.
>
> What is surprising to me is that this happens even though the number
> of ubuf_info in use at limit 100 is around 100 at all times. In other words,
> it does not exhaust the pool.
>
> When forcing zcopy_used to be false for all packets, this effect of
> sender A throughput being correlated with sender B does not happen.
>
> no filter
>    rx.A: ~850,000
>    rx.B: ~850,000
>
> limit 100
>    rx.A: ~850,000
>    rx.B: ~4200
>    ifb0: 4518 sent, 876182 dropped
>
> Also relevant is that with zerocopy, the sender processes back off
> and report the same count as the receiver. Without zerocopy,
> both senders send at full speed, even if only 4200 packets from flow
> B arrive at the receiver.
>
> This is with the default virtio_net driver, so without napi-tx.

What kind of qdisc do you use in guest? I suspect we should use 
something which could do fair queueing (e.g sfq).

>
> It appears that the zerocopy notifications are pausing the guest.
> Will look at that now.

Another factor is the tx interrupt coalescing parameters of ifb0, maybe 
we should disable it during the test.

Thanks

>
> By the way, I have had an unrelated patch outstanding for a while
> to have virtio-net support the VIRTIO_CONFIG_S_NEEDS_RESET
> command. Will send that as RFC.
