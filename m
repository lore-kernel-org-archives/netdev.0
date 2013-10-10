From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: tcp_transmit_skb() optimizations
Date: Thu, 10 Oct 2013 08:54:32 -0700
Message-ID: <CAK6E8=eATKMhsdKJaRQsO_E4k9s6H==kTz=6k6++3iAu3PP_1Q@mail.gmail.com>
References: <1381419780.4971.84.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, MF Nowlan <fitz@cs.yale.edu>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:48821 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756049Ab3JJPyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 11:54:54 -0400
Received: by mail-ie0-f182.google.com with SMTP id as1so4392490iec.27
        for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 08:54:52 -0700 (PDT)
In-Reply-To: <1381419780.4971.84.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 10, 2013 at 8:43 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> 1) We need to take a timestamp only for skb that should be cloned.
>
> Other skbs are not in write queue and no rtt estimation is done on them.
>
> 2) the unlikely() hint is wrong for receivers (they send pure ACK)
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: MF Nowlan <fitz@cs.yale.edu>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
Acked-By: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_output.c |   14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index faec813..c40f608 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -850,15 +850,15 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
>
>         BUG_ON(!skb || !tcp_skb_pcount(skb));
>
> -       /* If congestion control is doing timestamping, we must
> -        * take such a timestamp before we potentially clone/copy.
> -        */
> -       if (icsk->icsk_ca_ops->flags & TCP_CONG_RTT_STAMP)
> -               __net_timestamp(skb);
> -
> -       if (likely(clone_it)) {
> +       if (clone_it) {
>                 const struct sk_buff *fclone = skb + 1;
>
> +               /* If congestion control is doing timestamping, we must
> +                * take such a timestamp before we potentially clone/copy.
> +                */
> +               if (icsk->icsk_ca_ops->flags & TCP_CONG_RTT_STAMP)
> +                       __net_timestamp(skb);
> +
>                 if (unlikely(skb->fclone == SKB_FCLONE_ORIG &&
>                              fclone->fclone == SKB_FCLONE_CLONE))
>                         NET_INC_STATS_BH(sock_net(sk),
>
>
