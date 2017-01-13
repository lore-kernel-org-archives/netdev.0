From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [net-next 01/13] tcp: new helper function for RACK loss detection
Date: Thu, 12 Jan 2017 22:07:31 -0800
Message-ID: <CAK6E8=dR7W6Y0fQA+XNw+9ib=fr6ByTkGJAEuE=EH1eY=C4j=Q@mail.gmail.com>
References: <20170113060354.85234-1-ycheng@google.com> <20170113060354.85234-2-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:36647 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750787AbdAMGIz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 01:08:55 -0500
Received: by mail-it0-f50.google.com with SMTP id c7so26945577itd.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 22:08:12 -0800 (PST)
In-Reply-To: <20170113060354.85234-2-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 10:03 PM, Yuchung Cheng <ycheng@google.com> wrote:
>
> Create a new helper tcp_rack_mark_skb_lost to prepare the
> upcoming RACK reordering timer support.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> ---
Oops I messed up the subject headers. Let me resubmit. Sorry.

>  net/ipv4/tcp_recovery.c | 21 ++++++++++++++-------
>  1 file changed, 14 insertions(+), 7 deletions(-)
>
> diff --git a/net/ipv4/tcp_recovery.c b/net/ipv4/tcp_recovery.c
> index e36df4fcfeba..f38dba5aed7a 100644
> --- a/net/ipv4/tcp_recovery.c
> +++ b/net/ipv4/tcp_recovery.c
> @@ -3,6 +3,19 @@
>
>  int sysctl_tcp_recovery __read_mostly = TCP_RACK_LOST_RETRANS;
>
> +static void tcp_rack_mark_skb_lost(struct sock *sk, struct sk_buff *skb)
> +{
> +       struct tcp_sock *tp = tcp_sk(sk);
> +
> +       tcp_skb_mark_lost_uncond_verify(tp, skb);
> +       if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) {
> +               /* Account for retransmits that are lost again */
> +               TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
> +               tp->retrans_out -= tcp_skb_pcount(skb);
> +               NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPLOSTRETRANSMIT);
> +       }
> +}
> +
>  /* Marks a packet lost, if some packet sent later has been (s)acked.
>   * The underlying idea is similar to the traditional dupthresh and FACK
>   * but they look at different metrics:
> @@ -61,13 +74,7 @@ int tcp_rack_mark_lost(struct sock *sk)
>                                 continue;
>
>                         /* skb is lost if packet sent later is sacked */
> -                       tcp_skb_mark_lost_uncond_verify(tp, skb);
> -                       if (scb->sacked & TCPCB_SACKED_RETRANS) {
> -                               scb->sacked &= ~TCPCB_SACKED_RETRANS;
> -                               tp->retrans_out -= tcp_skb_pcount(skb);
> -                               NET_INC_STATS(sock_net(sk),
> -                                             LINUX_MIB_TCPLOSTRETRANSMIT);
> -                       }
> +                       tcp_rack_mark_skb_lost(sk, skb);
>                 } else if (!(scb->sacked & TCPCB_RETRANS)) {
>                         /* Original data are sent sequentially so stop early
>                          * b/c the rest are all sent after rack_sent
> --
> 2.11.0.483.g087da7b7c-goog
>
