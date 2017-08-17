From: Matthew Dawson <matthew@mjdsystems.ca>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0 don't skip empty skbs
Date: Thu, 17 Aug 2017 11:47:04 -0400
Message-ID: <2020045.ridbXvZZ6f@ring00>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1502914822.2796.6.camel@redhat.com> <CAF=yD-JryS8g=8nB7yq9WVdCOjqSb7uNwncrRfWPmMQbdYrh3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart6834365.OyLZrkps4k"; micalg="pgp-sha256"; protocol="application/pgp-signature"
Cc: Paolo Abeni <pabeni@redhat.com>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from scadrial.mjdsystems.ca ([198.100.154.185]:36589 "EHLO
        scadrial.mjdsystems.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752587AbdHQPrL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 11:47:11 -0400
In-Reply-To: <CAF=yD-JryS8g=8nB7yq9WVdCOjqSb7uNwncrRfWPmMQbdYrh3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart6834365.OyLZrkps4k
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"

On Wednesday, August 16, 2017 7:27:17 PM EDT Willem de Bruijn wrote:
> On Wed, Aug 16, 2017 at 4:20 PM, Paolo Abeni <pabeni@redhat.com> wrote:
> > On Wed, 2017-08-16 at 11:18 -0400, Willem de Bruijn wrote:
> >> > If I read the above correctly, you are arguining in favor of the
> >> > addittional flag version, right?
> >> 
> >> I was. Though if we are going to thread the argument from the caller
> >> to __skb_try_recv_from_queue to avoid rereading sk->sk_peek_off,
> > 
> >> on second thought it might be simpler to do it through off:
> > [...]
> > 
> >> This, of course, requires restricting sk_peek_off to protect against
> >> overflow.> 
> > Ok, even if I'm not 100% sure overall this will be simpler when adding
> > also the overflow check.
> 
> Actually, it is safe even without the check. Overflow of the signed integer
> is benign here.
> 
> >> If I'm not mistaken, the test in udp_recvmsg currently incorrectly sets
> >> 
> >> peeking to false when peeking at offset zero:
> >>         peeking = off = sk_peek_offset(sk, flags);
> > 
> > I think you are right, does not look correct.
> 
> By shifting the offset by two, we could even make both assignments
> become correct. Return 0 without peek, 1 on peek without SO_PEEK_OFF,
> 2+ otherwise, including overflow up to INT_MIN + 1.
> 
> But the end result is more readable if we just separate those two
> assignments.
> 
> @@ -1574,7 +1574,8 @@ int udp_recvmsg(struct sock *sk, struct msghdr
> *msg, size_t len, int noblock,
>                 return ip_recv_error(sk, msg, len, addr_len);
> 
>  try_again:
> -       peeking = off = sk_peek_offset(sk, flags);
> +       peeking = flags & MSG_PEEK;
> +       off = sk_peek_offset(sk, flags);
>         skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
>         if (!skb)
>                 return err;
> 
> @@ -362,7 +362,8 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr
> *msg, size_t len,
>                 return ipv6_recv_rxpmtu(sk, msg, len, addr_len);
> 
>  try_again:
> -       peeking = off = sk_peek_offset(sk, flags);
> +       peeking = flags & MSG_PEEK;
> +       off = sk_peek_offset(sk, flags);
>         skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
>         if (!skb)
>                 return err;
> 
> At which point there is also no longer a need for the variable shift
> at sk_peek_offset. Just pass the raw value down to
> __skb_try_recv_from_queue and disambiguate there:
> 
> @@ -506,11 +506,8 @@ int sk_set_peek_off(struct sock *sk, int val);
> 
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
> 
> @@ -169,14 +169,20 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock
> *sk, int *peeked, int *off, int *err, struct sk_buff **last)
>  {
> +       bool peek_at_off = false;
>         struct sk_buff *skb;
> -       int _off = *off;
> +       int _off = 0;
> +
> +       if (flags & MSG_PEEK && (*off) >= 0) {
> +               peek_at_off = true;
> +               _off = *off;
> +       }
> 
>         *last = queue->prev;
>         skb_queue_walk(queue, skb) {
>                 if (flags & MSG_PEEK) {
> -                       if (_off >= skb->len && (skb->len || _off ||
> -                                                skb->peeked)) {
> +                       if (peek_at_off && _off >= skb->len &&
> +                           (skb->len || _off || skb->peeked)) {
                                ^ I'm pretty sure we can remove this check 
(that skb->len is not zero) in this if statement.  If _off is zero, then skb-
>len must also be zero (since _off >= skb->len, if _off is 0, skb->len <= 0.  
If skb->len can't be negative, then skb->len <= 0 => skb->len == 0).  If _off 
is not zero, then checking skb->len is redundant.
>                                 _off -= skb->len;
>                                 continue;
>                         }
Is this queued to go in already?  Or can I help by updating my patch with what 
was discussed here?  I can do that today if wanted.

-- 
Matthew
--nextPart6834365.OyLZrkps4k
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEkRWwpe7qWxgM14Ep+0kv31Jtww0FAlmVungACgkQ+0kv31Jt
ww0hvBAAhOihLcfD0GOAJB3+VqnrkF4/anr2PPL0U/VwRS9S/JJ76nK0F3ng29k4
SrMY5FoYoL8UdtCeoym2XmXLzMoA27yBQ3Q0UMUzkFMydCRq7ZU099O8kiry+u1h
yFExa0Q0ZZuwoNynV02Kp5rApXKK4LBIQN4Yz+zfMQrOjUQUd33+yUWIuNT8BEXq
yrpQB1HBIkhRPomf91b3nkttSIfZ5vcZ3zkNvVDEo78kk57yFyAGPIWkKCYD+gT6
nYVJKRsosBNRNye5gZp+Fwraa50/fgDVbex6toK7P4aIEcqR9c6aa4DhRSGOpYzv
HYlchqkRhAyFnuDqfN2vJzv18bKWAmfnl2rF2cGbqrirkBPunmZifcn30L5ZTvwh
O9mWdPjA0ltygkUGjzBuN+szA91QuF5GGLlW3/kj+ulYqpvruW7CSh6hrkbhPHg2
1I7twyJ+lGVa2uL7gF1tmgrDo5vqukohft3P3FoehlzWouMn9wRsbf+l+F/Wod5p
qR2nBz/jW/jy7a9CXE93GDw7khXKP4fdqnz8xaEebYKNcbGmqpv22zZtD0H8cEqF
kjsidzUdY3S7ntbHu7FbV2fYP8J7dX0eupkJBrUAy08U8n1UgdTdQhoEqkXy+pm0
/6iV2WXl4OAnkoO9DYGEMw++yFb8lgA+NVkGPBgtIgE0m6X7LaY=
=KbmB
-----END PGP SIGNATURE-----

--nextPart6834365.OyLZrkps4k--
