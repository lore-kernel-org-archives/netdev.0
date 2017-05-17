From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next 04/15] tcp: use tcp_jiffies32 to feed tp->lsndtime
Date: Wed, 17 May 2017 09:43:54 -0400
Message-ID: <CACSApvZpP3w_nkJFPRtS2vd5v4tm-qXuDzkpXrL9neSvo2njeg@mail.gmail.com>
References: <20170516210014.31176-1-edumazet@google.com> <20170516210014.31176-5-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Wei Wang <weiwan@google.com>, netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:34884 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752978AbdEQNof (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 09:44:35 -0400
Received: by mail-it0-f49.google.com with SMTP id c15so81316430ith.0
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 06:44:35 -0700 (PDT)
In-Reply-To: <20170516210014.31176-5-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 5:00 PM, Eric Dumazet <edumazet@google.com> wrote:
> Use tcp_jiffies32 instead of tcp_time_stamp to feed
> tp->lsndtime.
>
> tcp_time_stamp will soon be a litle bit more expensive
> than simply reading 'jiffies'.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

> ---
>  include/net/tcp.h     | 2 +-
>  net/ipv4/tcp.c        | 2 +-
>  net/ipv4/tcp_cubic.c  | 2 +-
>  net/ipv4/tcp_input.c  | 4 ++--
>  net/ipv4/tcp_output.c | 4 ++--
>  net/ipv4/tcp_timer.c  | 4 ++--
>  6 files changed, 9 insertions(+), 9 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 4b45be5708215bae4551a5430b63ab2777baf447..feba4c0406e551d7e57da3411476735731b4d817 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1245,7 +1245,7 @@ static inline void tcp_slow_start_after_idle_check(struct sock *sk)
>         if (!sysctl_tcp_slow_start_after_idle || tp->packets_out ||
>             ca_ops->cong_control)
>                 return;
> -       delta = tcp_time_stamp - tp->lsndtime;
> +       delta = tcp_jiffies32 - tp->lsndtime;
>         if (delta > inet_csk(sk)->icsk_rto)
>                 tcp_cwnd_restart(sk, delta);
>  }
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 1e4c76d2b8278ba71d6cc2cf7ebfe483e241f76e..d0bb61ee28bbceff8f2e27416ce87fec94935973 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2841,7 +2841,7 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
>         info->tcpi_retrans = tp->retrans_out;
>         info->tcpi_fackets = tp->fackets_out;
>
> -       now = tcp_time_stamp;
> +       now = tcp_jiffies32;
>         info->tcpi_last_data_sent = jiffies_to_msecs(now - tp->lsndtime);
>         info->tcpi_last_data_recv = jiffies_to_msecs(now - icsk->icsk_ack.lrcvtime);
>         info->tcpi_last_ack_recv = jiffies_to_msecs(now - tp->rcv_tstamp);
> diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
> index 0683ba447d775b6101a929a6aca3eb255cff8932..2052ca740916d0872a41125ab61b769b334a314b 100644
> --- a/net/ipv4/tcp_cubic.c
> +++ b/net/ipv4/tcp_cubic.c
> @@ -155,7 +155,7 @@ static void bictcp_cwnd_event(struct sock *sk, enum tcp_ca_event event)
>  {
>         if (event == CA_EVENT_TX_START) {
>                 struct bictcp *ca = inet_csk_ca(sk);
> -               u32 now = tcp_time_stamp;
> +               u32 now = tcp_jiffies32;
>                 s32 delta;
>
>                 delta = now - tcp_sk(sk)->lsndtime;
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 06e2dbc2b4a212a054fd88e57bb902c55a171b11..c0b3f909df394214785749704f2760171fe9d160 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -5571,7 +5571,7 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
>         /* Prevent spurious tcp_cwnd_restart() on first data
>          * packet.
>          */
> -       tp->lsndtime = tcp_time_stamp;
> +       tp->lsndtime = tcp_jiffies32;
>
>         tcp_init_buffer_space(sk);
>
> @@ -6008,7 +6008,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
>                         tcp_update_pacing_rate(sk);
>
>                 /* Prevent spurious tcp_cwnd_restart() on first data packet */
> -               tp->lsndtime = tcp_time_stamp;
> +               tp->lsndtime = tcp_jiffies32;
>
>                 tcp_initialize_rcv_mss(sk);
>                 tcp_fast_path_on(tp);
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 4c8a6eaba6b39a2aea061dd6857ed8df954c5ca2..be9f8f483e21bdbb4d944fcdae8560f3ae11ee64 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -160,7 +160,7 @@ static void tcp_event_data_sent(struct tcp_sock *tp,
>                                 struct sock *sk)
>  {
>         struct inet_connection_sock *icsk = inet_csk(sk);
> -       const u32 now = tcp_time_stamp;
> +       const u32 now = tcp_jiffies32;
>
>         if (tcp_packets_in_flight(tp) == 0)
>                 tcp_ca_event(sk, CA_EVENT_TX_START);
> @@ -1918,7 +1918,7 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
>         /* Avoid bursty behavior by allowing defer
>          * only if the last write was recent.
>          */
> -       if ((s32)(tcp_time_stamp - tp->lsndtime) > 0)
> +       if ((s32)(tcp_jiffies32 - tp->lsndtime) > 0)
>                 goto send_now;
>
>         in_flight = tcp_packets_in_flight(tp);
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index ec7c5473c788d77ae459b38492f2f2606d00d1ba..5f6f219a431e41a90b3c5d667a1a22b50f4464cf 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -63,7 +63,7 @@ static int tcp_out_of_resources(struct sock *sk, bool do_reset)
>
>         /* If peer does not open window for long time, or did not transmit
>          * anything for long time, penalize it. */
> -       if ((s32)(tcp_time_stamp - tp->lsndtime) > 2*TCP_RTO_MAX || !do_reset)
> +       if ((s32)(tcp_jiffies32 - tp->lsndtime) > 2*TCP_RTO_MAX || !do_reset)
>                 shift++;
>
>         /* If some dubious ICMP arrived, penalize even more. */
> @@ -73,7 +73,7 @@ static int tcp_out_of_resources(struct sock *sk, bool do_reset)
>         if (tcp_check_oom(sk, shift)) {
>                 /* Catch exceptional cases, when connection requires reset.
>                  *      1. Last segment was sent recently. */
> -               if ((s32)(tcp_time_stamp - tp->lsndtime) <= TCP_TIMEWAIT_LEN ||
> +               if ((s32)(tcp_jiffies32 - tp->lsndtime) <= TCP_TIMEWAIT_LEN ||
>                     /*  2. Window is closed. */
>                     (!tp->snd_wnd && !tp->packets_out))
>                         do_reset = true;
> --
> 2.13.0.303.g4ebf302169-goog
>
