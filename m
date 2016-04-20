From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [RFC PATCH v3 net-next 2/3] tcp: Handle eor bit when coalescing skb
Date: Wed, 20 Apr 2016 16:04:54 -0400
Message-ID: <CACSApvbyD7wFy+y2MrShKRMCTg-zF6UkP-Le867N=ssCYa-Yng@mail.gmail.com>
References: <1461133497-1515104-1-git-send-email-kafai@fb.com> <1461133497-1515104-3-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:36454 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbcDTUFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 16:05:35 -0400
Received: by mail-oi0-f43.google.com with SMTP id x201so52958844oif.3
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 13:05:35 -0700 (PDT)
In-Reply-To: <1461133497-1515104-3-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 20, 2016 at 2:24 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> This patch:
> 1. Prevent next_skb from coalescing to the prev_skb if
>    TCP_SKB_CB(prev_skb)->eor is set
> 2. Update the TCP_SKB_CB(prev_skb)->eor if coalescing is
>    allowed
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_input.c  | 4 ++++
>  net/ipv4/tcp_output.c | 4 ++++
>  2 files changed, 8 insertions(+)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 75e8336..68c55e5 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1303,6 +1303,7 @@ static bool tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
>         }
>
>         TCP_SKB_CB(prev)->tcp_flags |= TCP_SKB_CB(skb)->tcp_flags;
> +       TCP_SKB_CB(prev)->eor = TCP_SKB_CB(skb)->eor;
>         if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
>                 TCP_SKB_CB(prev)->end_seq++;
>
> @@ -1368,6 +1369,9 @@ static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
>         if ((TCP_SKB_CB(prev)->sacked & TCPCB_TAGBITS) != TCPCB_SACKED_ACKED)
>                 goto fallback;
>
> +       if (TCP_SKB_CB(prev)->eor)
> +               goto fallback;
> +

nit: You might want to add unlikely around all checks for "tcp_skb_cb->eor"s.

>         in_sack = !after(start_seq, TCP_SKB_CB(skb)->seq) &&
>                   !before(end_seq, TCP_SKB_CB(skb)->end_seq);
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index a6e4a83..96bdf98 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2494,6 +2494,7 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
>          * packet counting does not break.
>          */
>         TCP_SKB_CB(skb)->sacked |= TCP_SKB_CB(next_skb)->sacked & TCPCB_EVER_RETRANS;
> +       TCP_SKB_CB(skb)->eor = TCP_SKB_CB(next_skb)->eor;
>
>         /* changed transmit queue under us so clear hints */
>         tcp_clear_retrans_hints_partial(tp);
> @@ -2545,6 +2546,9 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
>                 if (!tcp_can_collapse(sk, skb))
>                         break;
>
> +               if (TCP_SKB_CB(to)->eor)
> +                       break;
> +

nit: Perhaps a better place to check for eor is right after entering
the loop? to skip a few instructions and tcp_can_collapse, in an
unlikely case eor is set.

>                 space -= skb->len;
>
>                 if (first) {
> --
> 2.5.1
>
