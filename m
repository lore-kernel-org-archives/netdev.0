From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH 3/5] net/packet: fix overflow in check for tp_frame_nr
Date: Tue, 28 Mar 2017 11:54:58 -0400
Message-ID: <CAEfhGizS=cwEka=ouphw2S6yL-n4OzZ8msX=FOBO_UjnSAB+cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        netdev <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33214 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751957AbdC1Pzg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 11:55:36 -0400
Received: by mail-qk0-f195.google.com with SMTP id p22so12941510qka.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 08:55:11 -0700 (PDT)
Received: from mail-qt0-f179.google.com (mail-qt0-f179.google.com. [209.85.216.179])
        by smtp.gmail.com with ESMTPSA id c10sm2874886qka.1.2017.03.28.08.54.59
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 08:54:59 -0700 (PDT)
Received: by mail-qt0-f179.google.com with SMTP id n21so67806839qta.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 08:54:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 10:00 AM, Andrey Konovalov
<andreyknvl@google.com> wrote:
> When calculating rb->frames_per_block * req->tp_block_nr the result
> can overflow.
>
> Add a check that tp_block_size * tp_block_nr <= UINT_MAX.
>
> Since frames_per_block <= tp_block_size, the expression would
> never overflow.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  net/packet/af_packet.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 506348abdf2f..c5c43fff8c01 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -4197,6 +4197,9 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
>                         goto out;
>                 if (unlikely(req->tp_frame_size == 0))
>                         goto out;
> +               if (unlikely((u64)req->tp_block_size * req->tp_block_nr >
> +                                       UINT_MAX))
> +                       goto out;
So this may be pedantic, but really the only guarantee that you have
for the 'unsigned int' type of these fields is that they are _at
least_ 16 bits.  There is no guarantee on the upper bound size, so
casting to a u64 will be problematic on a compiler that happens to use
64 bits for 'unsigned int'.  I'm not aware of any that use greater
than 32 bits right now and using one that does may very well break
other things in the kernel, but here we are...  Perhaps a alternative
fix would be to do the multiplication into an 'unsigned int' type and
ensure that the result is larger than each of the original two values?

The real issue is that explicit size types should have been used in
this userspace structure.
