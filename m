From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Wed, 16 Aug 2017 19:40:04 -0400
Message-ID: <CAF=yD-+8CrTx=JNj4hVnn8B5cmCFRJttsdRx5Ab-2mW6LgCayg@mail.gmail.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1502702846.8411.25.camel@redhat.com>
 <1846443.VTclhqQinN@ring00> <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
 <1502724662.8411.53.camel@redhat.com> <CAF=yD-+ZNPtF1h1OT=_4yuE7=XtireP_OtbyBefHGdwtJ_ontQ@mail.gmail.com>
 <1502811641.3475.7.camel@redhat.com> <CAF=yD-Lacw9T7G0XZBdHZwEb6HgRuaBoyUN1oTvWixu4a0Fy6Q@mail.gmail.com>
 <CAF=yD-+jBim==ktwYUNAFkn-N4eabqgNME8NXM77v9-U_bfWPg@mail.gmail.com>
 <1502875722.3548.11.camel@redhat.com> <CAF=yD-K8FMicoSS6u-0r_J0p0fTyn4GNwhXn7_gRSSMYmAzw5g@mail.gmail.com>
 <1502914822.2796.6.camel@redhat.com> <CAF=yD-JryS8g=8nB7yq9WVdCOjqSb7uNwncrRfWPmMQbdYrh3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:38317 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752417AbdHPXkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 19:40:45 -0400
Received: by mail-oi0-f68.google.com with SMTP id s21so4980958oie.5
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 16:40:45 -0700 (PDT)
In-Reply-To: <CAF=yD-JryS8g=8nB7yq9WVdCOjqSb7uNwncrRfWPmMQbdYrh3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  static inline int sk_peek_offset(struct sock *sk, int flags)
>  {
> -       if (unlikely(flags & MSG_PEEK)) {
> -               s32 off = READ_ONCE(sk->sk_peek_off);
> -               if (off >= 0)
> -                       return off;
> -       }
> +       if (unlikely(flags & MSG_PEEK))
> +               return READ_ONCE(sk->sk_peek_off);
>
>         return 0;
>  }

I noticed too late that this function is used in one case where the
result is not blindly passed to __skb_try_recv_from_queue.

The AF_UNIX stream case will need a floor on its offset.

-               skip = sk_peek_offset(sk, flags);
+               skip = max(sk_peek_offset(sk, flags), 0);
