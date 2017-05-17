From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next 03/15] dccp: do not use tcp_time_stamp
Date: Wed, 17 May 2017 09:43:28 -0400
Message-ID: <CACSApvYySTJydoECVnu0VP08+MU=0BYKUiyqP426L+deoCBi4w@mail.gmail.com>
References: <20170516210014.31176-1-edumazet@google.com> <20170516210014.31176-4-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Wei Wang <weiwan@google.com>, netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:35715 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753692AbdEQNoK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 09:44:10 -0400
Received: by mail-it0-f50.google.com with SMTP id c15so81308294ith.0
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 06:44:10 -0700 (PDT)
In-Reply-To: <20170516210014.31176-4-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 5:00 PM, Eric Dumazet <edumazet@google.com> wrote:
> Use our own macro instead of abusing tcp_time_stamp
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

> ---
>  net/dccp/ccids/ccid2.c | 8 ++++----
>  net/dccp/ccids/ccid2.h | 2 +-
>  2 files changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
> index 5e3a7302f7747e4c4f3134eacab2f2c65b13402f..e1295d5f2c562e8785f59a0f5bd7064f471e85ab 100644
> --- a/net/dccp/ccids/ccid2.c
> +++ b/net/dccp/ccids/ccid2.c
> @@ -233,7 +233,7 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, unsigned int len)
>  {
>         struct dccp_sock *dp = dccp_sk(sk);
>         struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
> -       const u32 now = ccid2_time_stamp;
> +       const u32 now = ccid2_jiffies32;
>         struct ccid2_seq *next;
>
>         /* slow-start after idle periods (RFC 2581, RFC 2861) */
> @@ -466,7 +466,7 @@ static void ccid2_new_ack(struct sock *sk, struct ccid2_seq *seqp,
>          * The cleanest solution is to not use the ccid2s_sent field at all
>          * and instead use DCCP timestamps: requires changes in other places.
>          */
> -       ccid2_rtt_estimator(sk, ccid2_time_stamp - seqp->ccid2s_sent);
> +       ccid2_rtt_estimator(sk, ccid2_jiffies32 - seqp->ccid2s_sent);
>  }
>
>  static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
> @@ -478,7 +478,7 @@ static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
>                 return;
>         }
>
> -       hc->tx_last_cong = ccid2_time_stamp;
> +       hc->tx_last_cong = ccid2_jiffies32;
>
>         hc->tx_cwnd      = hc->tx_cwnd / 2 ? : 1U;
>         hc->tx_ssthresh  = max(hc->tx_cwnd, 2U);
> @@ -731,7 +731,7 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
>
>         hc->tx_rto       = DCCP_TIMEOUT_INIT;
>         hc->tx_rpdupack  = -1;
> -       hc->tx_last_cong = hc->tx_lsndtime = hc->tx_cwnd_stamp = ccid2_time_stamp;
> +       hc->tx_last_cong = hc->tx_lsndtime = hc->tx_cwnd_stamp = ccid2_jiffies32;
>         hc->tx_cwnd_used = 0;
>         setup_timer(&hc->tx_rtotimer, ccid2_hc_tx_rto_expire,
>                         (unsigned long)sk);
> diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
> index 18c97543e522a6b9a5c8a3c817d4b40224adde48..6e50ef2898fb9dd9080217cc167defea6a2e9021 100644
> --- a/net/dccp/ccids/ccid2.h
> +++ b/net/dccp/ccids/ccid2.h
> @@ -27,7 +27,7 @@
>   * CCID-2 timestamping faces the same issues as TCP timestamping.
>   * Hence we reuse/share as much of the code as possible.
>   */
> -#define ccid2_time_stamp       tcp_time_stamp
> +#define ccid2_jiffies32        ((u32)jiffies)
>
>  /* NUMDUPACK parameter from RFC 4341, p. 6 */
>  #define NUMDUPACK      3
> --
> 2.13.0.303.g4ebf302169-goog
>
