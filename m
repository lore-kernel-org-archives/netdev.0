From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Mon, 21 Aug 2017 11:41:19 -0400
Message-ID: <CAF=yD-LZ4=WAYfUtY7xRWi50FRSkrcOa+b7uc46xRnC4sbDCzQ@mail.gmail.com>
References: <20170819063854.27010-1-den@klaipeden.com> <5352c98a-fa48-fcf9-c062-9986a317a1b0@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Koichiro Den <den@klaipeden.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35568 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753930AbdHUPmB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 11:42:01 -0400
Received: by mail-oi0-f67.google.com with SMTP id q70so16178719oic.2
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 08:42:00 -0700 (PDT)
In-Reply-To: <5352c98a-fa48-fcf9-c062-9986a317a1b0@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 8:33 AM, Jason Wang <jasowang@redhat.com> wrote:
>
>
> On 2017=E5=B9=B408=E6=9C=8819=E6=97=A5 14:38, Koichiro Den wrote:
>>
>> Facing the possible unbounded delay relying on freeing on xmit path,
>> we also better to invoke and clear the upper layer zerocopy callback
>> beforehand to keep them from waiting for unbounded duration in vain.
>> For instance, this removes the possible deadlock in the case that the
>> upper layer is a zerocopy-enabled vhost-net.
>> This does not apply if napi_tx is enabled since it will be called in
>> reasonale time.
>>
>> Signed-off-by: Koichiro Den <den@klaipeden.com>
>> ---
>>   drivers/net/virtio_net.c | 8 ++++++++
>>   1 file changed, 8 insertions(+)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 4302f313d9a7..f7deaa5b7b50 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -1290,6 +1290,14 @@ static netdev_tx_t start_xmit(struct sk_buff *skb=
,
>> struct net_device *dev)
>>         /* Don't wait up for transmitted skbs to be freed. */
>>         if (!use_napi) {
>> +               if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
>> +                       struct ubuf_info *uarg;
>> +                       uarg =3D skb_shinfo(skb)->destructor_arg;
>> +                       if (uarg->callback)
>> +                           uarg->callback(uarg, true);
>> +                       skb_shinfo(skb)->destructor_arg =3D NULL;
>> +                       skb_shinfo(skb)->tx_flags &=3D ~SKBTX_DEV_ZEROCO=
PY;
>> +               }
>>                 skb_orphan(skb);
>>                 nf_reset(skb);
>>         }
>
>
>
> Interesting, deadlock could be treated as a a radical case of the discuss=
ion
> here https://patchwork.kernel.org/patch/3787671/.
>
> git grep tells more similar skb_orphan() cases. Do we need to change them
> all (or part)?

Most skb_orphan calls are not relevant to the issue of transmit delay.

> Actually, we may meet similar issues at many other places (e.g netem).

Netem is an interesting case. Because it is intended to mimic network
delay, at least in the case where it calls skb_orphan, it may make
sense to release all references, including calling skb_zcopy_clear.

In general, zerocopy reverts to copy on all paths that may cause
unbounded delay due to another process. Guarding against delay
induced by the administrator is infeasible. It is always possible to
just pause the nic. Netem is one instance of that, and not unbounded.

> Need
> to consider a complete solution for this. Figuring out all places that co=
uld
> delay a packet is a method.

The issue described in the referenced patch seems like head of line
blocking between two flows. If one flow delays zerocopy descriptor
release from the vhost-net pool, it blocks all subsequent descriptors
in that pool from being released, also delaying other flows that use
the same descriptor pool. If the pool is empty, all transmission stopped.

Reverting to copy tx when the pool reaches a low watermark, as the
patch does, fixes this. Perhaps the descriptor pool should also be
revised to allow out of order completions. Then there is no need to
copy zerocopy packets whenever they may experience delay.

On the point of counting copy vs zerocopy: the new msg_zerocopy
variant of ubuf_info has a field to record whether a deep copy was
made. This can be used with vhost-net zerocopy, too.
