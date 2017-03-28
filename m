From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH 4/5] net/packet: fix overflow in check for tp_reserve
Date: Tue, 28 Mar 2017 11:00:44 -0400
Message-ID: <CAF=yD-JJVYj0szu2=Pod2MtK6kYpoU=agwnNnn4yQegk6t4u7Q@mail.gmail.com>
References: <cover.1490709552.git.andreyknvl@google.com> <0f3f9342c09be4d97a820cf9abeb9dabed8eb69f.1490709552.git.andreyknvl@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>,
        Network Development <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35208 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752371AbdC1PCS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 11:02:18 -0400
Received: by mail-qt0-f194.google.com with SMTP id r5so12472424qtb.2
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 08:01:44 -0700 (PDT)
In-Reply-To: <0f3f9342c09be4d97a820cf9abeb9dabed8eb69f.1490709552.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 10:00 AM, Andrey Konovalov
<andreyknvl@google.com> wrote:
> When calculating po->tp_hdrlen + po->tp_reserve the result can overflow.
>
> Fix by checking that tp_reserve <= INT_MAX on assign.
>
> This also takes cared of an overflow when calculating
>  macoff = TPACKET_ALIGN(po->tp_hdrlen) + 16 + po->tp_reserve
>  snaplen = skb->len
>  macoff + snaplen
> since macoff ~ INT_MAX and snaplen < SKB_MAX_ALLOC.

This refers to the overflow of macoff + snaplen?

Note that macoff is unsigned short, so will truncate any overflow from
tp_reserve.

> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  net/packet/af_packet.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index c5c43fff8c01..28b49749d1af 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -3665,6 +3665,8 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
>                         return -EBUSY;
>                 if (copy_from_user(&val, optval, sizeof(val)))
>                         return -EFAULT;
> +               if (val > INT_MAX)
> +                       return -EINVAL;

This change on its own is sufficient to avoid the overflow. For net
and backports to stable, this minimal patch is preferable.

>                 po->tp_reserve = val;
>                 return 0;
>         }
> @@ -4200,6 +4202,8 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
>                 if (unlikely((u64)req->tp_block_size * req->tp_block_nr >
>                                         UINT_MAX))
>                         goto out;
> +               if (unlikely(po->tp_reserve >= req->tp_frame_size))
> +                       goto out;
>
>                 if (unlikely(!PAGE_ALIGNED(req->tp_block_size)))
>                         goto out;
> @@ -4207,9 +4211,6 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
>                     req->tp_block_size <=
>                           BLK_PLUS_PRIV((u64)req_u->req3.tp_sizeof_priv))
>                         goto out;
> -               if (unlikely(req->tp_frame_size < po->tp_hdrlen +
> -                                       po->tp_reserve))
> -                       goto out;

Is there a reason that the test is moved up? It is probably not
correct to remove tp_hdrlen from the test.

>                 if (unlikely(req->tp_frame_size & (TPACKET_ALIGNMENT - 1)))
>                         goto out;
>
> --
> 2.12.2.564.g063fe858b8-goog
>
