From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Fri, 1 Sep 2017 11:08:06 +0800
Message-ID: <f8dcf5de-4862-042c-3bb5-00e52cbd2c83@redhat.com>
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
 <b8893b72-4d09-2492-0d31-5135286e6874@redhat.com>
 <CAF=yD-KUoW6hxZtpAmyVrJXCY+=Fq1FOcbD3h=HmDQaPoC1MLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Koichiro Den <den@klaipeden.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55686 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750925AbdIADIO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 23:08:14 -0400
In-Reply-To: <CAF=yD-KUoW6hxZtpAmyVrJXCY+=Fq1FOcbD3h=HmDQaPoC1MLg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年08月30日 11:11, Willem de Bruijn wrote:
> On Tue, Aug 29, 2017 at 9:45 PM, Jason Wang <jasowang@redhat.com> wrote:
>>
>> On 2017年08月30日 03:35, Willem de Bruijn wrote:
>>> On Fri, Aug 25, 2017 at 9:03 PM, Willem de Bruijn
>>> <willemdebruijn.kernel@gmail.com> wrote:
>>>> On Fri, Aug 25, 2017 at 7:32 PM, Michael S. Tsirkin <mst@redhat.com>
>>>> wrote:
>>>>> On Fri, Aug 25, 2017 at 06:44:36PM -0400, Willem de Bruijn wrote:

[...]

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
>>>     modprobe ifb
>>>     ip link set dev ifb0 up
>>>     tc qdisc add dev ifb0 root netem limit $LIMIT rate 1MBit
>>>
>>>     tc qdisc add dev tap0 ingress
>>>     tc filter add dev tap0 parent ffff: protocol ip \
>>>         u32 match ip dport 8000 0xffff \
>>>         action mirred egress redirect dev ifb0
>>>
>>> For 10 second run, packet count with various ifb0 queue lengths $LIMIT:
>>>
>>> no filter
>>>     rx.A: ~840,000
>>>     rx.B: ~840,000
>>
>> Just to make sure I understand the case here. What did rx.B mean here? I
>> thought all traffic sent by Sender B has been redirected to ifb0?
> It has been, but the packet still arrives at the destination socket.
> IFB is a special virtual device that applies traffic shaping and
> then reinjects it back at the point it was intercept by mirred.
>
> rx.B is indeed arrival rate at the receiver, similar to rx.A.
>

I see, then ifb looks pretty fit to the test.
