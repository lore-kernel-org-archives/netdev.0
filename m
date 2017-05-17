From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next 08/15] tcp: use tcp_jiffies32 for rcv_tstamp and lrcvtime
Date: Wed, 17 May 2017 09:46:19 -0400
Message-ID: <CACSApvYgVe+TJY=wwycbvcQjvdeCW=x=GYtG2SxPSwTRAVz4ug@mail.gmail.com>
References: <20170516210014.31176-1-edumazet@google.com> <20170516210014.31176-9-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Wei Wang <weiwan@google.com>, netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:37538 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752199AbdEQNrA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 09:47:00 -0400
Received: by mail-it0-f47.google.com with SMTP id g126so9248019ith.0
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 06:47:00 -0700 (PDT)
In-Reply-To: <20170516210014.31176-9-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 5:00 PM, Eric Dumazet <edumazet@google.com> wrote:
> Use tcp_jiffies32 instead of tcp_time_stamp, since
> tcp_time_stamp will soon be only used for TCP TS option.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

> ---
>  include/net/tcp.h        | 4 ++--
>  net/ipv4/tcp_input.c     | 6 +++---
>  net/ipv4/tcp_minisocks.c | 2 +-
>  net/ipv4/tcp_output.c    | 2 +-
>  net/ipv4/tcp_timer.c     | 2 +-
>  5 files changed, 8 insertions(+), 8 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index feba4c0406e551d7e57da3411476735731b4d817..5b2932b8363fb8546322ebff7c74663139b3371d 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1307,8 +1307,8 @@ static inline u32 keepalive_time_elapsed(const struct tcp_sock *tp)
>  {
>         const struct inet_connection_sock *icsk = &tp->inet_conn;
>
> -       return min_t(u32, tcp_time_stamp - icsk->icsk_ack.lrcvtime,
> -                         tcp_time_stamp - tp->rcv_tstamp);
> +       return min_t(u32, tcp_jiffies32 - icsk->icsk_ack.lrcvtime,
> +                         tcp_jiffies32 - tp->rcv_tstamp);
>  }
>
>  static inline int tcp_fin_time(const struct sock *sk)
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 6a15c9b80b09829799dc37d89ecdbf11ec9ff904..eeb4967df25a8dc35128d0a0848b5ae7ee6d63e3 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -672,7 +672,7 @@ static void tcp_event_data_recv(struct sock *sk, struct sk_buff *skb)
>
>         tcp_rcv_rtt_measure(tp);
>
> -       now = tcp_time_stamp;
> +       now = tcp_jiffies32;
>
>         if (!icsk->icsk_ack.ato) {
>                 /* The _first_ data packet received, initialize
> @@ -3636,7 +3636,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
>          */
>         sk->sk_err_soft = 0;
>         icsk->icsk_probes_out = 0;
> -       tp->rcv_tstamp = tcp_time_stamp;
> +       tp->rcv_tstamp = tcp_jiffies32;
>         if (!prior_packets)
>                 goto no_queue;
>
> @@ -5554,7 +5554,7 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
>         struct inet_connection_sock *icsk = inet_csk(sk);
>
>         tcp_set_state(sk, TCP_ESTABLISHED);
> -       icsk->icsk_ack.lrcvtime = tcp_time_stamp;
> +       icsk->icsk_ack.lrcvtime = tcp_jiffies32;
>
>         if (skb) {
>                 icsk->icsk_af_ops->sk_rx_dst_set(sk, skb);
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index 717be4de53248352c758b50557987d898340dd4f..59c32e0086c0e46d7955dffe211ec03bb18dcb12 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -447,7 +447,7 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
>                 newtp->mdev_us = jiffies_to_usecs(TCP_TIMEOUT_INIT);
>                 minmax_reset(&newtp->rtt_min, tcp_time_stamp, ~0U);
>                 newicsk->icsk_rto = TCP_TIMEOUT_INIT;
> -               newicsk->icsk_ack.lrcvtime = tcp_time_stamp;
> +               newicsk->icsk_ack.lrcvtime = tcp_jiffies32;
>
>                 newtp->packets_out = 0;
>                 newtp->retrans_out = 0;
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 4bd50f0b236ba23fe521a76dd9d35ee16acb061f..cbda5de164495cf318960489bd8edf98fe3a5033 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -3324,7 +3324,7 @@ static void tcp_connect_init(struct sock *sk)
>         if (likely(!tp->repair))
>                 tp->rcv_nxt = 0;
>         else
> -               tp->rcv_tstamp = tcp_time_stamp;
> +               tp->rcv_tstamp = tcp_jiffies32;
>         tp->rcv_wup = tp->rcv_nxt;
>         tp->copied_seq = tp->rcv_nxt;
>
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index 5f6f219a431e41a90b3c5d667a1a22b50f4464cf..9e0616cb8c17a6385ac97fc0cd657ef9413a1749 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -451,7 +451,7 @@ void tcp_retransmit_timer(struct sock *sk)
>                                             tp->snd_una, tp->snd_nxt);
>                 }
>  #endif
> -               if (tcp_time_stamp - tp->rcv_tstamp > TCP_RTO_MAX) {
> +               if (tcp_jiffies32 - tp->rcv_tstamp > TCP_RTO_MAX) {
>                         tcp_write_err(sk);
>                         goto out;
>                 }
> --
> 2.13.0.303.g4ebf302169-goog
>
