From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next 1/2] tcp: introduce TCP_SKB_CB(skb)->tcp_tw_isn
Date: Fri, 5 Sep 2014 15:50:31 -0700
Message-ID: <CAK6E8=cwWsEJZGK9E=NkWn-oUL9FA2YPTe14e3eXJ0G5PahzCg@mail.gmail.com>
References: <1409956413-29472-1-git-send-email-edumazet@google.com> <1409956413-29472-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:60383 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbaIEWvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 18:51:12 -0400
Received: by mail-ie0-f180.google.com with SMTP id at1so1392271iec.39
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 15:51:11 -0700 (PDT)
In-Reply-To: <1409956413-29472-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 5, 2014 at 3:33 PM, Eric Dumazet <edumazet@google.com> wrote:
> TCP_SKB_CB(skb)->when has different meaning in output and input paths.
>
> In output path, it contains a timestamp.
> In input path, it contains an ISN, chosen by tcp_timewait_state_process()
>
> Lets add a different name to ease code comprehension.
>
> Note that 'when' field will disappear in following patch,
> as skb_mstamp already contains timestamp, the anonymous
> union will promptly disappear as well.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

> ---
>  include/net/tcp.h        | 7 ++++++-
>  net/ipv4/tcp_input.c     | 2 +-
>  net/ipv4/tcp_ipv4.c      | 2 +-
>  net/ipv4/tcp_minisocks.c | 2 +-
>  net/ipv6/tcp_ipv6.c      | 4 ++--
>  5 files changed, 11 insertions(+), 6 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 590e01a476ac..0cd7d2c65dc0 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -698,7 +698,12 @@ struct tcp_skb_cb {
>         } header;       /* For incoming frames          */
>         __u32           seq;            /* Starting sequence number     */
>         __u32           end_seq;        /* SEQ + FIN + SYN + datalen    */
> -       __u32           when;           /* used to compute rtt's        */
> +       union {
> +               /* used in output path */
> +               __u32           when;   /* used to compute rtt's        */
> +               /* used in input path */
> +               __u32           tcp_tw_isn; /* isn chosen by tcp_timewait_state_process() */
> +       };
>         __u8            tcp_flags;      /* TCP header flags. (tcp[13])  */
>
>         __u8            sacked;         /* State flags for SACK/FACK.   */
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index aba4926ca095..9c8b9f1dcf69 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -5906,7 +5906,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
>         struct request_sock *req;
>         struct tcp_sock *tp = tcp_sk(sk);
>         struct dst_entry *dst = NULL;
> -       __u32 isn = TCP_SKB_CB(skb)->when;
> +       __u32 isn = TCP_SKB_CB(skb)->tcp_tw_isn;
>         bool want_cookie = false, fastopen;
>         struct flowi fl;
>         struct tcp_fastopen_cookie foc = { .len = -1 };
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 487e2a41667f..02e6cd29ebf1 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1627,7 +1627,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
>         TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
>                                     skb->len - th->doff * 4);
>         TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
> -       TCP_SKB_CB(skb)->when    = 0;
> +       TCP_SKB_CB(skb)->tcp_tw_isn = 0;
>         TCP_SKB_CB(skb)->ip_dsfield = ipv4_get_dsfield(iph);
>         TCP_SKB_CB(skb)->sacked  = 0;
>
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index 1649988bd1b6..a058f411d3a6 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -232,7 +232,7 @@ kill:
>                 u32 isn = tcptw->tw_snd_nxt + 65535 + 2;
>                 if (isn == 0)
>                         isn++;
> -               TCP_SKB_CB(skb)->when = isn;
> +               TCP_SKB_CB(skb)->tcp_tw_isn = isn;
>                 return TCP_TW_SYN;
>         }
>
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 29964c3d363c..5b3c70ff7a72 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -738,7 +738,7 @@ static void tcp_v6_init_req(struct request_sock *req, struct sock *sk,
>             ipv6_addr_type(&ireq->ir_v6_rmt_addr) & IPV6_ADDR_LINKLOCAL)
>                 ireq->ir_iif = inet6_iif(skb);
>
> -       if (!TCP_SKB_CB(skb)->when &&
> +       if (!TCP_SKB_CB(skb)->tcp_tw_isn &&
>             (ipv6_opt_accepted(sk, skb) || np->rxopt.bits.rxinfo ||
>              np->rxopt.bits.rxoinfo || np->rxopt.bits.rxhlim ||
>              np->rxopt.bits.rxohlim || np->repflow)) {
> @@ -1412,7 +1412,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
>         TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
>                                     skb->len - th->doff*4);
>         TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
> -       TCP_SKB_CB(skb)->when = 0;
> +       TCP_SKB_CB(skb)->tcp_tw_isn = 0;
>         TCP_SKB_CB(skb)->ip_dsfield = ipv6_get_dsfield(hdr);
>         TCP_SKB_CB(skb)->sacked = 0;
>
> --
> 2.1.0.rc2.206.gedb03e5
>
