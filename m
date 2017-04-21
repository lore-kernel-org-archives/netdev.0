From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next v2 2/5] virtio-net: transmit napi
Date: Fri, 21 Apr 2017 10:50:12 -0400
Message-ID: <CAF=yD-KdtvXV+=ZROcLPHJxB55wbnJOmV0MJn2AJPHugoofR0g@mail.gmail.com>
References: <20170418202108.61920-1-willemdebruijn.kernel@gmail.com>
 <20170418202108.61920-3-willemdebruijn.kernel@gmail.com> <2ae5889b-69d4-3041-d7fd-a7ea38e8c4e2@redhat.com>
 <CAF=yD-K0Cwwcob+0nWXWTY_07_zwcae1GRHwdagF2pGrv8HwtA@mail.gmail.com> <118c5f96-6151-c012-7a31-16d24a835878@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        virtualization@lists.linux-foundation.org,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:36064 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424513AbdDUTLO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:11:14 -0400
Received: by mail-qk0-f175.google.com with SMTP id d80so14513397qke.3
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:11:14 -0700 (PDT)
In-Reply-To: <118c5f96-6151-c012-7a31-16d24a835878@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> Maybe I was wrong, but according to Michael's comment it looks like he
>>> want
>>> check affinity_hint_set just for speculative tx polling on rx napi
>>> instead
>>> of disabling it at all.
>>>
>>> And I'm not convinced this is really needed, driver only provide affinity
>>> hint instead of affinity, so it's not guaranteed that tx and rx interrupt
>>> are in the same vcpus.
>>
>> You're right. I made the restriction broader than the request, to really
>> err
>> on the side of caution for the initial merge of napi tx. And enabling
>> the optimization is always a win over keeping it off, even without irq
>> affinity.
>>
>> The cycle cost is significant without affinity regardless of whether the
>> optimization is used.
>
>
> Yes, I noticed this in the past too.
>
>> Though this is not limited to napi-tx, it is more
>> pronounced in that mode than without napi.
>>
>> 1x TCP_RR for affinity configuration {process, rx_irq, tx_irq}:
>>
>> upstream:
>>
>> 1,1,1: 28985 Mbps, 278 Gcyc
>> 1,0,2: 30067 Mbps, 402 Gcyc
>>
>> napi tx:
>>
>> 1,1,1: 34492 Mbps, 269 Gcyc
>> 1,0,2: 36527 Mbps, 537 Gcyc (!)
>> 1,0,1: 36269 Mbps, 394 Gcyc
>> 1,0,0: 34674 Mbps, 402 Gcyc
>>
>> This is a particularly strong example. It is also representative
>> of most RR tests. It is less pronounced in other streaming tests.
>> 10x TCP_RR, for instance:
>>
>> upstream:
>>
>> 1,1,1: 42267 Mbps, 301 Gcyc
>> 1,0,2: 40663 Mbps, 445 Gcyc
>>
>> napi tx:
>>
>> 1,1,1: 42420 Mbps, 303 Gcyc
>> 1,0,2:  42267 Mbps, 431 Gcyc
>>
>> These numbers were obtained with the virtqueue_enable_cb_delayed
>> optimization after xmit_skb, btw. It turns out that moving that before
>> increases 1x TCP_RR further to ~39 Gbps, at the cost of reducing
>> 100x TCP_RR a bit.
>
>
> I see, so I think we can leave the affinity hint optimization/check for
> future investigation:
>
> - to avoid endless optimization (e.g we may want to share a single
> vector/napi for tx/rx queue pairs in the future) for this series.
> - tx napi is disabled by default which means we can do optimization on top.

Okay. I'll drop the vi->affinity_hint_set from the patch set for now.
