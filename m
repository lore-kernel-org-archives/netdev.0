From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] vhost_net: do not stall on zerocopy depletion
Date: Thu, 28 Sep 2017 12:05:52 -0400
Message-ID: <CAF=yD-LG9HN1rYsLLM9Odiia7SdHGKzB3NJP5fZorvfGKGf6zQ@mail.gmail.com>
References: <20170928002556.41240-1-willemdebruijn.kernel@gmail.com> <a574875f-cea7-e769-ff41-c337c9720d7a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Koichiro Den <den@klaipeden.com>,
        virtualization@lists.linux-foundation.org,
        Willem de Bruijn <willemb@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:51576 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751531AbdI1QGd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 12:06:33 -0400
Received: by mail-oi0-f68.google.com with SMTP id n82so3047063oib.8
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 09:06:33 -0700 (PDT)
In-Reply-To: <a574875f-cea7-e769-ff41-c337c9720d7a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 28, 2017 at 3:41 AM, Jason Wang <jasowang@redhat.com> wrote:
>
>
> On 2017=E5=B9=B409=E6=9C=8828=E6=97=A5 08:25, Willem de Bruijn wrote:
>>
>> From: Willem de Bruijn <willemb@google.com>
>>
>> Vhost-net has a hard limit on the number of zerocopy skbs in flight.
>> When reached, transmission stalls. Stalls cause latency, as well as
>> head-of-line blocking of other flows that do not use zerocopy.
>>
>> Instead of stalling, revert to copy-based transmission.
>>
>> Tested by sending two udp flows from guest to host, one with payload
>> of VHOST_GOODCOPY_LEN, the other too small for zerocopy (1B). The
>> large flow is redirected to a netem instance with 1MBps rate limit
>> and deep 1000 entry queue.
>>
>>    modprobe ifb
>>    ip link set dev ifb0 up
>>    tc qdisc add dev ifb0 root netem limit 1000 rate 1MBit
>>
>>    tc qdisc add dev tap0 ingress
>>    tc filter add dev tap0 parent ffff: protocol ip \
>>        u32 match ip dport 8000 0xffff \
>>        action mirred egress redirect dev ifb0
>>
>> Before the delay, both flows process around 80K pps. With the delay,
>> before this patch, both process around 400. After this patch, the
>> large flow is still rate limited, while the small reverts to its
>> original rate. See also discussion in the first link, below.
>>
>> The limit in vhost_exceeds_maxpend must be carefully chosen. When
>> vq->num >> 1, the flows remain correlated. This value happens to
>> correspond to VHOST_MAX_PENDING for vq->num =3D=3D 256.
>
>
> Have you tested e.g vq->num =3D 512 or 1024?

I did test with 1024 previously, but let me run that again
with this patch applied.

>
>
>>   Allow smaller
>> fractions and ensure correctness also for much smaller values of
>> vq->num, by testing the min() of both explicitly. See also the
>> discussion in the second link below.
>>
>>
>> Link:http://lkml.kernel.org/r/CAF=3DyD-+Wk9sc9dXMUq1+x_hh=3D3ThTXa6BnZky=
gP3tgVpjbp93g@mail.gmail.com
>> Link:http://lkml.kernel.org/r/20170819064129.27272-1-den@klaipeden.com
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>> ---
>>   drivers/vhost/net.c | 14 ++++----------
>>   1 file changed, 4 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>> index 58585ec8699e..50758602ae9d 100644
>> --- a/drivers/vhost/net.c
>> +++ b/drivers/vhost/net.c
>> @@ -436,8 +436,8 @@ static bool vhost_exceeds_maxpend(struct vhost_net
>> *net)
>>         struct vhost_net_virtqueue *nvq =3D &net->vqs[VHOST_NET_VQ_TX];
>>         struct vhost_virtqueue *vq =3D &nvq->vq;
>>   -     return (nvq->upend_idx + vq->num - VHOST_MAX_PEND) % UIO_MAXIOV
>> -               =3D=3D nvq->done_idx;
>> +       return (nvq->upend_idx + UIO_MAXIOV - nvq->done_idx) % UIO_MAXIO=
V
>> >
>> +              min(VHOST_MAX_PEND, vq->num >> 2);
>>   }
>>     /* Expects to be always run from workqueue - which acts as
>> @@ -480,12 +480,6 @@ static void handle_tx(struct vhost_net *net)
>>                 if (zcopy)
>>                         vhost_zerocopy_signal_used(net, vq);
>>   -             /* If more outstanding DMAs, queue the work.
>> -                * Handle upend_idx wrap around
>> -                */
>> -               if (unlikely(vhost_exceeds_maxpend(net)))
>> -                       break;
>> -
>>                 head =3D vhost_net_tx_get_vq_desc(net, vq, vq->iov,
>>                                                 ARRAY_SIZE(vq->iov),
>>                                                 &out, &in);
>> @@ -509,6 +503,7 @@ static void handle_tx(struct vhost_net *net)
>>                 len =3D iov_length(vq->iov, out);
>>                 iov_iter_init(&msg.msg_iter, WRITE, vq->iov, out, len);
>>                 iov_iter_advance(&msg.msg_iter, hdr_size);
>> +
>
>
> Looks unnecessary. Other looks good.

Oops, indeed. Thanks.
