From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Fri, 1 Sep 2017 12:15:06 -0400
Message-ID: <CAF=yD-JREJqpsRdCi31qo1QNFEE2DDCaTGYw1f1waPgtov8WEg@mail.gmail.com>
References: <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
 <20170822204015-mutt-send-email-mst@kernel.org> <1503498504.8694.26.camel@klaipeden.com>
 <CAF=yD-+U_aWxSmPPY8v8t=JO0MRZ+N+DzVJTAMKYQ5F=pE1PfA@mail.gmail.com>
 <20170824014553-mutt-send-email-mst@kernel.org> <CAF=yD-KSek+LmZu0X0TXetmFEQ59iF3NpjZ4KugbwLo1BGfhaA@mail.gmail.com>
 <20170824160748-mutt-send-email-mst@kernel.org> <CAF=yD-+9Ah8pC9i2w3Ad3WnhQit7Yo479pMrToty7priL6BFLw@mail.gmail.com>
 <20170824234551-mutt-send-email-mst@kernel.org> <CAF=yD-+1wheMmC+HFKe_B_ULO0Mmh6HMSEbYY5D-HgqxVJee6A@mail.gmail.com>
 <20170826022744-mutt-send-email-mst@kernel.org> <CAF=yD-Lre0NATUVH8p0zS=G5CiY=WfKSefLmOZw940jZFgECgQ@mail.gmail.com>
 <CAF=yD-+Wk9sc9dXMUq1+x_hh=3ThTXa6BnZkygP3tgVpjbp93g@mail.gmail.com>
 <CAF=yD-+AjQLLUKdvnrwd2tqFtw4Hm81cR7WUJd65oLnziNGM8A@mail.gmail.com> <5ef7fcf3-d4f0-be16-6ddb-724d954cfc68@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Koichiro Den <den@klaipeden.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:36651 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752005AbdIAQPs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 12:15:48 -0400
Received: by mail-oi0-f47.google.com with SMTP id t75so5658360oie.3
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 09:15:47 -0700 (PDT)
In-Reply-To: <5ef7fcf3-d4f0-be16-6ddb-724d954cfc68@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 11:25 PM, Jason Wang <jasowang@redhat.com> wrote:
>
>
> On 2017=E5=B9=B408=E6=9C=8831=E6=97=A5 22:30, Willem de Bruijn wrote:
>>>
>>> Incomplete results at this stage, but I do see this correlation between
>>> flows. It occurs even while not running out of zerocopy descriptors,
>>> which I cannot yet explain.
>>>
>>> Running two threads in a guest, each with a udp socket, each
>>> sending up to 100 datagrams, or until EAGAIN, every msec.
>>>
>>> Sender A sends 1B datagrams.
>>> Sender B sends VHOST_GOODCOPY_LEN, which is enough
>>> to trigger zcopy_used in vhost net.
>>>
>>> A local receive process on the host receives both flows. To avoid
>>> a deep copy when looping the packet onto the receive path,
>>> changed skb_orphan_frags_rx to always return false (gross hack).
>>>
>>> The flow with the larger packets is redirected through netem on ifb0:
>>>
>>>    modprobe ifb
>>>    ip link set dev ifb0 up
>>>    tc qdisc add dev ifb0 root netem limit $LIMIT rate 1MBit
>>>
>>>    tc qdisc add dev tap0 ingress
>>>    tc filter add dev tap0 parent ffff: protocol ip \
>>>        u32 match ip dport 8000 0xffff \
>>>        action mirred egress redirect dev ifb0
>>>
>>> For 10 second run, packet count with various ifb0 queue lengths $LIMIT:
>>>
>>> no filter
>>>    rx.A: ~840,000
>>>    rx.B: ~840,000
>>>
>>> limit 1
>>>    rx.A: ~500,000
>>>    rx.B: ~3100
>>>    ifb0: 3273 sent, 371141 dropped
>>>
>>> limit 100
>>>    rx.A: ~9000
>>>    rx.B: ~4200
>>>    ifb0: 4630 sent, 1491 dropped
>>>
>>> limit 1000
>>>    rx.A: ~6800
>>>    rx.B: ~4200
>>>    ifb0: 4651 sent, 0 dropped
>>>
>>> Sender B is always correctly rate limited to 1 MBps or less. With a
>>> short queue, it ends up dropping a lot and sending even less.
>>>
>>> When a queue builds up for sender B, sender A throughput is strongly
>>> correlated with queue length. With queue length 1, it can send almost
>>> at unthrottled speed. But even at limit 100 its throughput is on the
>>> same order as sender B.
>>>
>>> What is surprising to me is that this happens even though the number
>>> of ubuf_info in use at limit 100 is around 100 at all times. In other
>>> words,
>>> it does not exhaust the pool.
>>>
>>> When forcing zcopy_used to be false for all packets, this effect of
>>> sender A throughput being correlated with sender B does not happen.
>>>
>>> no filter
>>>    rx.A: ~850,000
>>>    rx.B: ~850,000
>>>
>>> limit 100
>>>    rx.A: ~850,000
>>>    rx.B: ~4200
>>>    ifb0: 4518 sent, 876182 dropped
>>>
>>> Also relevant is that with zerocopy, the sender processes back off
>>> and report the same count as the receiver. Without zerocopy,
>>> both senders send at full speed, even if only 4200 packets from flow
>>> B arrive at the receiver.
>>>
>>> This is with the default virtio_net driver, so without napi-tx.
>>>
>>> It appears that the zerocopy notifications are pausing the guest.
>>> Will look at that now.
>>
>> It was indeed as simple as that. With 256 descriptors, queuing even
>> a hundred or so packets causes the guest to stall the device as soon
>> as the qdisc is installed.
>>
>> Adding this check
>>
>> +                       in_use =3D nvq->upend_idx - nvq->done_idx;
>> +                       if (nvq->upend_idx < nvq->done_idx)
>> +                               in_use +=3D UIO_MAXIOV;
>> +
>> +                       if (in_use > (vq->num >> 2))
>> +                               zcopy_used =3D false;
>>
>> Has the desired behavior of reverting zerocopy requests to copying.
>>
>> Without this change, the result is, as previously reported, throughput
>> dropping to hundreds of packets per second on both flows.
>>
>> With the change, pps as observed for a few seconds at handle_tx is
>>
>> zerocopy=3D165 copy=3D168435
>> zerocopy=3D0 copy=3D168500
>> zerocopy=3D65 copy=3D168535
>>
>> Both flows continue to send at more or less normal rate, with only
>> sender B observing massive drops at the netem.
>>
>> With the queue removed the rate reverts to
>>
>> zerocopy=3D58878 copy=3D110239
>> zerocopy=3D58833 copy=3D110207
>>
>> This is not a 50/50 split, which impliesTw that some packets from the
>> large
>> packet flow are still converted to copying. Without the change the rate
>> without queue was 80k zerocopy vs 80k copy, so this choice of
>> (vq->num >> 2) appears too conservative.
>>
>> However, testing with (vq->num >> 1) was not as effective at mitigating
>> stalls. I did not save that data, unfortunately. Can run more tests on
>> fine
>> tuning this variable, if the idea sounds good.
>
>
> Looks like there're still two cases were left:

To be clear, this patch is not intended to fix all issues. It is a small
improvement to avoid HoL blocking due to queued zerocopy skbs.

The trade-off is that reverting to copying in these cases increases
cycle cost. I think that that is a trade-off worth making compared to
the alternative drop in throughput. It probably would be good to be
able to measure this without kernel instrumentation: export
counters similar to net->tx_zcopy_err and net->tx_packets (though
without reset to zero, as in vhost_net_tx_packet).

> 1) sndbuf is not INT_MAX

You mean the case where the device stalls, later zerocopy notifications
are queued, but these are never cleaned in free_old_xmit_skbs,
because it requires a start_xmit and by now the (only) socket is out of
descriptors?

A watchdog would help somewhat. With tx-napi, this case cannot occur,
either, as free_old_xmit_skbs no longer depends on a call to start_xmit.

> 2) tx napi is used for virtio-net

I am not aware of any issue specific to the use of tx-napi?

> 1) could be a corner case, and for 2) what your suggest here may not solv=
e
> the issue since it still do in order completion.

Somewhat tangential, but it might also help to break the in-order
completion processing in vhost_zerocopy_signal_used. Complete
all descriptors between done_idx and upend_idx. done_idx should
then only be forward to the oldest still not-completed descriptor.

In the test I ran, where the oldest descriptors are held in a queue and
all newer ones are tail-dropped, this would avoid blocking a full ring
of completions, when only a small number (or 1) is actually delayed.

Dynamic switching between copy and zerocopy using zcopy_used
already returns completions out-of-order, so this is not a huge leap.
