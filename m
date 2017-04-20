From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next v2 2/5] virtio-net: transmit napi
Date: Thu, 20 Apr 2017 09:58:06 -0400
Message-ID: <CAF=yD-K0Cwwcob+0nWXWTY_07_zwcae1GRHwdagF2pGrv8HwtA@mail.gmail.com>
References: <20170418202108.61920-1-willemdebruijn.kernel@gmail.com>
 <20170418202108.61920-3-willemdebruijn.kernel@gmail.com> <2ae5889b-69d4-3041-d7fd-a7ea38e8c4e2@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        virtualization@lists.linux-foundation.org,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34954 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031721AbdDTN6s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 09:58:48 -0400
Received: by mail-qk0-f194.google.com with SMTP id k139so7903625qke.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 06:58:48 -0700 (PDT)
In-Reply-To: <2ae5889b-69d4-3041-d7fd-a7ea38e8c4e2@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 2:27 AM, Jason Wang <jasowang@redhat.com> wrote:
>
>
> On 2017=E5=B9=B404=E6=9C=8819=E6=97=A5 04:21, Willem de Bruijn wrote:
>>
>> +static void virtnet_napi_tx_enable(struct virtnet_info *vi,
>> +                                  struct virtqueue *vq,
>> +                                  struct napi_struct *napi)
>> +{
>> +       if (!napi->weight)
>> +               return;
>> +
>> +       if (!vi->affinity_hint_set) {
>> +               napi->weight =3D 0;
>> +               return;
>> +       }
>> +
>> +       return virtnet_napi_enable(vq, napi);
>> +}
>> +
>>   static void refill_work(struct work_struct *work)
>
>
> Maybe I was wrong, but according to Michael's comment it looks like he wa=
nt
> check affinity_hint_set just for speculative tx polling on rx napi instea=
d
> of disabling it at all.
>
> And I'm not convinced this is really needed, driver only provide affinity
> hint instead of affinity, so it's not guaranteed that tx and rx interrupt
> are in the same vcpus.

You're right. I made the restriction broader than the request, to really er=
r
on the side of caution for the initial merge of napi tx. And enabling
the optimization is always a win over keeping it off, even without irq
affinity.

The cycle cost is significant without affinity regardless of whether the
optimization is used. Though this is not limited to napi-tx, it is more
pronounced in that mode than without napi.

1x TCP_RR for affinity configuration {process, rx_irq, tx_irq}:

upstream:

1,1,1: 28985 Mbps, 278 Gcyc
1,0,2: 30067 Mbps, 402 Gcyc

napi tx:

1,1,1: 34492 Mbps, 269 Gcyc
1,0,2: 36527 Mbps, 537 Gcyc (!)
1,0,1: 36269 Mbps, 394 Gcyc
1,0,0: 34674 Mbps, 402 Gcyc

This is a particularly strong example. It is also representative
of most RR tests. It is less pronounced in other streaming tests.
10x TCP_RR, for instance:

upstream:

1,1,1: 42267 Mbps, 301 Gcyc
1,0,2: 40663 Mbps, 445 Gcyc

napi tx:

1,1,1: 42420 Mbps, 303 Gcyc
1,0,2:  42267 Mbps, 431 Gcyc

These numbers were obtained with the virtqueue_enable_cb_delayed
optimization after xmit_skb, btw. It turns out that moving that before
increases 1x TCP_RR further to ~39 Gbps, at the cost of reducing
100x TCP_RR a bit.
