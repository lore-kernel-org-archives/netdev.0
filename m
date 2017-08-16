From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Wed, 16 Aug 2017 11:18:16 -0400
Message-ID: <CAF=yD-K8FMicoSS6u-0r_J0p0fTyn4GNwhXn7_gRSSMYmAzw5g@mail.gmail.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1502702846.8411.25.camel@redhat.com>
 <1846443.VTclhqQinN@ring00> <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
 <1502724662.8411.53.camel@redhat.com> <CAF=yD-+ZNPtF1h1OT=_4yuE7=XtireP_OtbyBefHGdwtJ_ontQ@mail.gmail.com>
 <1502811641.3475.7.camel@redhat.com> <CAF=yD-Lacw9T7G0XZBdHZwEb6HgRuaBoyUN1oTvWixu4a0Fy6Q@mail.gmail.com>
 <CAF=yD-+jBim==ktwYUNAFkn-N4eabqgNME8NXM77v9-U_bfWPg@mail.gmail.com> <1502875722.3548.11.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:34816 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdHPPS5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 11:18:57 -0400
Received: by mail-oi0-f50.google.com with SMTP id e124so39264277oig.2
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 08:18:57 -0700 (PDT)
In-Reply-To: <1502875722.3548.11.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If I read the above correctly, you are arguining in favor of the
> addittional flag version, right?

I was. Though if we are going to thread the argument from the caller
to __skb_try_recv_from_queue to avoid rereading sk->sk_peek_off,
on second thought it might be simpler to do it through off:

@@ -511,7 +511,9 @@ static inline int sk_peek_offset(struct sock *sk, int flags)
        if (unlikely(flags & MSG_PEEK)) {
                s32 off = READ_ONCE(sk->sk_peek_off);
                if (off >= 0)
-                       return off;
+                       return off + 1;
+               else
+                       return 0;
        }

        return 0;

In __skb_try_recv_from_queue we can then disambiguate the two as follows:

@@ -170,13 +170,19 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
                                          struct sk_buff **last)
 {
        struct sk_buff *skb;
-       int _off = *off;
+       bool peek_at_off = false;
+       int _off = 0;
+
+       if (flags & MSG_PEEK && *off) {
+               peek_at_off = true;
+               _off = (*off) - 1;
+       }

        *last = queue->prev;
        skb_queue_walk(queue, skb) {
                if (flags & MSG_PEEK) {
-                       if (_off >= skb->len && (skb->len || _off ||
-                                                skb->peeked)) {
+                       if (peek_at_off && _off >= skb->len &&
+                           (skb->len || _off || skb->peeked)) {


This, of course, requires restricting sk_peek_off to protect against overflow.

If I'm not mistaken, the test in udp_recvmsg currently incorrectly sets
peeking to false when peeking at offset zero:

        peeking = off = sk_peek_offset(sk, flags);


> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -2408,9 +2408,7 @@ EXPORT_SYMBOL(__sk_mem_reclaim);
>
>  int sk_set_peek_off(struct sock *sk, int val)
>  {
> -       if (val < 0)
> -               return -EINVAL;
> -
> +       /* a negative value will disable peeking with offset */
>         sk->sk_peek_off = val;
>         return 0;
>  }

Separate patch to net-next?
