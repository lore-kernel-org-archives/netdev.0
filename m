From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Fri, 1 Sep 2017 11:25:19 +0800
Message-ID: <5ef7fcf3-d4f0-be16-6ddb-724d954cfc68@redhat.com>
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
 <CAF=yD-+AjQLLUKdvnrwd2tqFtw4Hm81cR7WUJd65oLnziNGM8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Koichiro Den <den@klaipeden.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38270 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750868AbdIADZa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 23:25:30 -0400
In-Reply-To: <CAF=yD-+AjQLLUKdvnrwd2tqFtw4Hm81cR7WUJd65oLnziNGM8A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年08月31日 22:30, Willem de Bruijn wrote:
>> Incomplete results at this stage, but I do see this correlation between
>> flows. It occurs even while not running out of zerocopy descriptors,
>> which I cannot yet explain.
>>
>> Running two threads in a guest, each with a udp socket, each
>> sending up to 100 datagrams, or until EAGAIN, every msec.
>>
>> Sender A sends 1B datagrams.
>> Sender B sends VHOST_GOODCOPY_LEN, which is enough
>> to trigger zcopy_used in vhost net.
>>
>> A local receive process on the host receives both flows. To avoid
>> a deep copy when looping the packet onto the receive path,
>> changed skb_orphan_frags_rx to always return false (gross hack).
>>
>> The flow with the larger packets is redirected through netem on ifb0:
>>
>>    modprobe ifb
>>    ip link set dev ifb0 up
>>    tc qdisc add dev ifb0 root netem limit $LIMIT rate 1MBit
>>
>>    tc qdisc add dev tap0 ingress
>>    tc filter add dev tap0 parent ffff: protocol ip \
>>        u32 match ip dport 8000 0xffff \
>>        action mirred egress redirect dev ifb0
>>
>> For 10 second run, packet count with various ifb0 queue lengths $LIMIT:
>>
>> no filter
>>    rx.A: ~840,000
>>    rx.B: ~840,000
>>
>> limit 1
>>    rx.A: ~500,000
>>    rx.B: ~3100
>>    ifb0: 3273 sent, 371141 dropped
>>
>> limit 100
>>    rx.A: ~9000
>>    rx.B: ~4200
>>    ifb0: 4630 sent, 1491 dropped
>>
>> limit 1000
>>    rx.A: ~6800
>>    rx.B: ~4200
>>    ifb0: 4651 sent, 0 dropped
>>
>> Sender B is always correctly rate limited to 1 MBps or less. With a
>> short queue, it ends up dropping a lot and sending even less.
>>
>> When a queue builds up for sender B, sender A throughput is strongly
>> correlated with queue length. With queue length 1, it can send almost
>> at unthrottled speed. But even at limit 100 its throughput is on the
>> same order as sender B.
>>
>> What is surprising to me is that this happens even though the number
>> of ubuf_info in use at limit 100 is around 100 at all times. In other words,
>> it does not exhaust the pool.
>>
>> When forcing zcopy_used to be false for all packets, this effect of
>> sender A throughput being correlated with sender B does not happen.
>>
>> no filter
>>    rx.A: ~850,000
>>    rx.B: ~850,000
>>
>> limit 100
>>    rx.A: ~850,000
>>    rx.B: ~4200
>>    ifb0: 4518 sent, 876182 dropped
>>
>> Also relevant is that with zerocopy, the sender processes back off
>> and report the same count as the receiver. Without zerocopy,
>> both senders send at full speed, even if only 4200 packets from flow
>> B arrive at the receiver.
>>
>> This is with the default virtio_net driver, so without napi-tx.
>>
>> It appears that the zerocopy notifications are pausing the guest.
>> Will look at that now.
> It was indeed as simple as that. With 256 descriptors, queuing even
> a hundred or so packets causes the guest to stall the device as soon
> as the qdisc is installed.
>
> Adding this check
>
> +                       in_use = nvq->upend_idx - nvq->done_idx;
> +                       if (nvq->upend_idx < nvq->done_idx)
> +                               in_use += UIO_MAXIOV;
> +
> +                       if (in_use > (vq->num >> 2))
> +                               zcopy_used = false;
>
> Has the desired behavior of reverting zerocopy requests to copying.
>
> Without this change, the result is, as previously reported, throughput
> dropping to hundreds of packets per second on both flows.
>
> With the change, pps as observed for a few seconds at handle_tx is
>
> zerocopy=165 copy=168435
> zerocopy=0 copy=168500
> zerocopy=65 copy=168535
>
> Both flows continue to send at more or less normal rate, with only
> sender B observing massive drops at the netem.
>
> With the queue removed the rate reverts to
>
> zerocopy=58878 copy=110239
> zerocopy=58833 copy=110207
>
> This is not a 50/50 split, which impliesTw that some packets from the large
> packet flow are still converted to copying. Without the change the rate
> without queue was 80k zerocopy vs 80k copy, so this choice of
> (vq->num >> 2) appears too conservative.
>
> However, testing with (vq->num >> 1) was not as effective at mitigating
> stalls. I did not save that data, unfortunately. Can run more tests on fine
> tuning this variable, if the idea sounds good.

Looks like there're still two cases were left:

1) sndbuf is not INT_MAX
2) tx napi is used for virtio-net

1) could be a corner case, and for 2) what your suggest here may not 
solve the issue since it still do in order completion.

Thanks
