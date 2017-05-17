From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next 13/15] tcp_lp: cache tcp_time_stamp
Date: Wed, 17 May 2017 09:47:28 -0400
Message-ID: <CACSApvY7j-DZdy-=zG6QrH9SEq2Xz=5RrC5Q74xF4fHBHtv_Pw@mail.gmail.com>
References: <20170516210014.31176-1-edumazet@google.com> <20170516210014.31176-14-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Wei Wang <weiwan@google.com>, netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:35963 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751423AbdEQNsP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 09:48:15 -0400
Received: by mail-it0-f51.google.com with SMTP id o5so81431567ith.1
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 06:48:14 -0700 (PDT)
In-Reply-To: <20170516210014.31176-14-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 5:00 PM, Eric Dumazet <edumazet@google.com> wrote:
> tcp_time_stamp will become slightly more expensive soon,
> cache its value.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

> ---
>  net/ipv4/tcp_lp.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
> index d6fb6c067af4641f232b94e7c590c212648e8173..ef3122abb3734a63011fba035f7a7aae431da8de 100644
> --- a/net/ipv4/tcp_lp.c
> +++ b/net/ipv4/tcp_lp.c
> @@ -264,18 +264,19 @@ static void tcp_lp_pkts_acked(struct sock *sk, const struct ack_sample *sample)
>  {
>         struct tcp_sock *tp = tcp_sk(sk);
>         struct lp *lp = inet_csk_ca(sk);
> +       u32 now = tcp_time_stamp;
>         u32 delta;
>
>         if (sample->rtt_us > 0)
>                 tcp_lp_rtt_sample(sk, sample->rtt_us);
>
>         /* calc inference */
> -       delta = tcp_time_stamp - tp->rx_opt.rcv_tsecr;
> +       delta = now - tp->rx_opt.rcv_tsecr;
>         if ((s32)delta > 0)
>                 lp->inference = 3 * delta;
>
>         /* test if within inference */
> -       if (lp->last_drop && (tcp_time_stamp - lp->last_drop < lp->inference))
> +       if (lp->last_drop && (now - lp->last_drop < lp->inference))
>                 lp->flag |= LP_WITHIN_INF;
>         else
>                 lp->flag &= ~LP_WITHIN_INF;
> @@ -312,7 +313,7 @@ static void tcp_lp_pkts_acked(struct sock *sk, const struct ack_sample *sample)
>                 tp->snd_cwnd = max(tp->snd_cwnd >> 1U, 1U);
>
>         /* record this drop time */
> -       lp->last_drop = tcp_time_stamp;
> +       lp->last_drop = now;
>  }
>
>  static struct tcp_congestion_ops tcp_lp __read_mostly = {
> --
> 2.13.0.303.g4ebf302169-goog
>
