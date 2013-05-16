From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] tcp: gso: do not generate out of order packets
Date: Wed, 15 May 2013 20:58:28 -0700
Message-ID: <CAHo-OozZz4yx5iuoEWcq5vTJvJ0b_5bNbiQuc4PMw22jBZOxpg@mail.gmail.com>
References: <1368668281.4519.75.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f47.google.com ([209.85.212.47]:34042 "EHLO
	mail-vb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754128Ab3EPD63 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 23:58:29 -0400
Received: by mail-vb0-f47.google.com with SMTP id x14so1040246vbb.6
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 20:58:28 -0700 (PDT)
In-Reply-To: <1368668281.4519.75.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'd be worried that calling the destructor that many times would cause
performance problems
(and only call the destructor and do memory accounting on the last segm=
ent).

Could we instead move the queue mapping into the skb somehow instead?

On Wed, May 15, 2013 at 6:38 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> GSO TCP handler has following issues :
>
> 1) ooo_okay from original GSO packet is duplicated to all segments
> 2) segments (but the last one) are orphaned, so transmit path can not
> get transmit queue number from the socket. This happens if GSO
> segmentation is done before stacked device for example.
>
> Result is we can send packets from a given TCP flow to different TX
> queues (if using multiqueue NICS). This generates OOO problems and
> spurious SACK & retransmits.
>
> Fix this by keeping socket pointer set for all segments.
>
> This means that every segment must also have a destructor, and the
> original gso skb truesize must be split on all segments, to keep
> precise sk->sk_wmem_alloc accounting.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp.c |   22 +++++++++++++++++++++-
>  1 file changed, 21 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index dcb116d..0b6276f 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2887,6 +2887,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff =
*skb,
>         unsigned int mss;
>         struct sk_buff *gso_skb =3D skb;
>         __sum16 newcheck;
> +       bool ooo_okay, copy_destructor;
>
>         if (!pskb_may_pull(skb, sizeof(*th)))
>                 goto out;
> @@ -2927,10 +2928,18 @@ struct sk_buff *tcp_tso_segment(struct sk_buf=
f *skb,
>                 goto out;
>         }
>
> +       copy_destructor =3D gso_skb->destructor =3D=3D tcp_wfree;
> +       ooo_okay =3D gso_skb->ooo_okay;
> +       /* All segments but the first should have ooo_okay cleared */
> +       skb->ooo_okay =3D 0;
> +
>         segs =3D skb_segment(skb, features);
>         if (IS_ERR(segs))
>                 goto out;
>
> +       /* Only first segment might have ooo_okay set */
> +       segs->ooo_okay =3D ooo_okay;
> +
>         delta =3D htonl(oldlen + (thlen + mss));
>
>         skb =3D segs;
> @@ -2950,6 +2959,17 @@ struct sk_buff *tcp_tso_segment(struct sk_buff=
 *skb,
>                                                     thlen, skb->csum)=
);
>
>                 seq +=3D mss;
> +               if (copy_destructor) {
> +                       skb->destructor =3D gso_skb->destructor;
> +                       skb->sk =3D gso_skb->sk;
> +                       /* {tcp|sock}_wfree() use exact truesize acco=
unting :
> +                        * sum(skb->truesize) MUST be exactly be gso_=
skb->truesize
> +                        * So we account mss bytes of 'true size' for=
 each segment.
> +                        * The last segment will contain the remainin=
g.
> +                        */
> +                       skb->truesize =3D mss;
> +                       gso_skb->truesize -=3D mss;
> +               }
>                 skb =3D skb->next;
>                 th =3D tcp_hdr(skb);
>
> @@ -2962,7 +2982,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff =
*skb,
>          * is freed at TX completion, and not right now when gso_skb
>          * is freed by GSO engine
>          */
> -       if (gso_skb->destructor =3D=3D tcp_wfree) {
> +       if (copy_destructor) {
>                 swap(gso_skb->sk, skb->sk);
>                 swap(gso_skb->destructor, skb->destructor);
>                 swap(gso_skb->truesize, skb->truesize);
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
