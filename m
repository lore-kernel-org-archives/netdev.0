From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] [CLEANUP] tcp: remove unused min_cwnd member of tcp_congestion_ops
Date: Wed, 12 Feb 2014 07:42:11 -0800
Message-ID: <CAK6E8=cc+TKht-dBXkpCxccqTR9bAUA=d18N8LtdwRRqmHdRZw@mail.gmail.com>
References: <1392212121-28574-1-git-send-email-stfomichev@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	netdev <netdev@vger.kernel.org>
To: Stanislav Fomichev <stfomichev@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:44587 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002AbaBLPmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 10:42:52 -0500
Received: by mail-ob0-f181.google.com with SMTP id va2so10422430obc.26
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 07:42:51 -0800 (PST)
In-Reply-To: <1392212121-28574-1-git-send-email-stfomichev@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 12, 2014 at 5:35 AM, Stanislav Fomichev
<stfomichev@yandex-team.ru> wrote:
> Commit 684bad110757 "tcp: use PRR to reduce cwin in CWR state" removed all
> calls to min_cwnd, so we can safely remove it.
> Also, remove tcp_reno_min_cwnd because it was only used for min_cwnd.
>
> Signed-off-by: Stanislav Fomichev <stfomichev@yandex-team.ru>
Acked-by: Yuchung Cheng <ycheng@google.com>

> ---
>  Documentation/networking/tcp.txt |  2 +-
>  include/net/tcp.h                |  3 ---
>  net/ipv4/tcp_cong.c              | 10 ----------
>  net/ipv4/tcp_highspeed.c         |  1 -
>  net/ipv4/tcp_hybla.c             |  1 -
>  net/ipv4/tcp_illinois.c          |  1 -
>  net/ipv4/tcp_lp.c                |  1 -
>  net/ipv4/tcp_scalable.c          |  1 -
>  net/ipv4/tcp_vegas.c             |  1 -
>  net/ipv4/tcp_westwood.c          |  1 -
>  net/ipv4/tcp_yeah.c              |  1 -
>  11 files changed, 1 insertion(+), 22 deletions(-)
>
> diff --git a/Documentation/networking/tcp.txt b/Documentation/networking/tcp.txt
> index 7d11bb5dc30a..bdc4c0db51e1 100644
> --- a/Documentation/networking/tcp.txt
> +++ b/Documentation/networking/tcp.txt
> @@ -30,7 +30,7 @@ A congestion control mechanism can be registered through functions in
>  tcp_cong.c. The functions used by the congestion control mechanism are
>  registered via passing a tcp_congestion_ops struct to
>  tcp_register_congestion_control. As a minimum name, ssthresh,
> -cong_avoid, min_cwnd must be valid.
> +cong_avoid must be valid.
>
>  Private data for a congestion control mechanism is stored in tp->ca_priv.
>  tcp_ca(tp) returns a pointer to this space.  This is preallocated space - it
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 70e55d200610..8ccc431f7269 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -793,8 +793,6 @@ struct tcp_congestion_ops {
>
>         /* return slow start threshold (required) */
>         u32 (*ssthresh)(struct sock *sk);
> -       /* lower bound for congestion window (optional) */
> -       u32 (*min_cwnd)(const struct sock *sk);
>         /* do new cwnd calculation (required) */
>         void (*cong_avoid)(struct sock *sk, u32 ack, u32 acked, u32 in_flight);
>         /* call before changing ca_state (optional) */
> @@ -829,7 +827,6 @@ void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w);
>  extern struct tcp_congestion_ops tcp_init_congestion_ops;
>  u32 tcp_reno_ssthresh(struct sock *sk);
>  void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked, u32 in_flight);
> -u32 tcp_reno_min_cwnd(const struct sock *sk);
>  extern struct tcp_congestion_ops tcp_reno;
>
>  static inline void tcp_set_ca_state(struct sock *sk, const u8 ca_state)
> diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
> index ad37bf18ae4b..f49351edf97d 100644
> --- a/net/ipv4/tcp_cong.c
> +++ b/net/ipv4/tcp_cong.c
> @@ -362,21 +362,12 @@ u32 tcp_reno_ssthresh(struct sock *sk)
>  }
>  EXPORT_SYMBOL_GPL(tcp_reno_ssthresh);
>
> -/* Lower bound on congestion window with halving. */
> -u32 tcp_reno_min_cwnd(const struct sock *sk)
> -{
> -       const struct tcp_sock *tp = tcp_sk(sk);
> -       return tp->snd_ssthresh/2;
> -}
> -EXPORT_SYMBOL_GPL(tcp_reno_min_cwnd);
> -
>  struct tcp_congestion_ops tcp_reno = {
>         .flags          = TCP_CONG_NON_RESTRICTED,
>         .name           = "reno",
>         .owner          = THIS_MODULE,
>         .ssthresh       = tcp_reno_ssthresh,
>         .cong_avoid     = tcp_reno_cong_avoid,
> -       .min_cwnd       = tcp_reno_min_cwnd,
>  };
>
>  /* Initial congestion control used (until SYN)
> @@ -388,6 +379,5 @@ struct tcp_congestion_ops tcp_init_congestion_ops  = {
>         .owner          = THIS_MODULE,
>         .ssthresh       = tcp_reno_ssthresh,
>         .cong_avoid     = tcp_reno_cong_avoid,
> -       .min_cwnd       = tcp_reno_min_cwnd,
>  };
>  EXPORT_SYMBOL_GPL(tcp_init_congestion_ops);
> diff --git a/net/ipv4/tcp_highspeed.c b/net/ipv4/tcp_highspeed.c
> index 8ed9305dfdf4..8b9e7bad77c0 100644
> --- a/net/ipv4/tcp_highspeed.c
> +++ b/net/ipv4/tcp_highspeed.c
> @@ -162,7 +162,6 @@ static struct tcp_congestion_ops tcp_highspeed __read_mostly = {
>         .init           = hstcp_init,
>         .ssthresh       = hstcp_ssthresh,
>         .cong_avoid     = hstcp_cong_avoid,
> -       .min_cwnd       = tcp_reno_min_cwnd,
>
>         .owner          = THIS_MODULE,
>         .name           = "highspeed"
> diff --git a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
> index 478fe82611bf..2a1a9e2a4e51 100644
> --- a/net/ipv4/tcp_hybla.c
> +++ b/net/ipv4/tcp_hybla.c
> @@ -166,7 +166,6 @@ static void hybla_cong_avoid(struct sock *sk, u32 ack, u32 acked,
>  static struct tcp_congestion_ops tcp_hybla __read_mostly = {
>         .init           = hybla_init,
>         .ssthresh       = tcp_reno_ssthresh,
> -       .min_cwnd       = tcp_reno_min_cwnd,
>         .cong_avoid     = hybla_cong_avoid,
>         .set_state      = hybla_state,
>
> diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
> index 8a520996f3d2..560d9879b89c 100644
> --- a/net/ipv4/tcp_illinois.c
> +++ b/net/ipv4/tcp_illinois.c
> @@ -329,7 +329,6 @@ static struct tcp_congestion_ops tcp_illinois __read_mostly = {
>         .flags          = TCP_CONG_RTT_STAMP,
>         .init           = tcp_illinois_init,
>         .ssthresh       = tcp_illinois_ssthresh,
> -       .min_cwnd       = tcp_reno_min_cwnd,
>         .cong_avoid     = tcp_illinois_cong_avoid,
>         .set_state      = tcp_illinois_state,
>         .get_info       = tcp_illinois_info,
> diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
> index 991d62a2f9bb..503798f2fcd6 100644
> --- a/net/ipv4/tcp_lp.c
> +++ b/net/ipv4/tcp_lp.c
> @@ -319,7 +319,6 @@ static struct tcp_congestion_ops tcp_lp __read_mostly = {
>         .init = tcp_lp_init,
>         .ssthresh = tcp_reno_ssthresh,
>         .cong_avoid = tcp_lp_cong_avoid,
> -       .min_cwnd = tcp_reno_min_cwnd,
>         .pkts_acked = tcp_lp_pkts_acked,
>
>         .owner = THIS_MODULE,
> diff --git a/net/ipv4/tcp_scalable.c b/net/ipv4/tcp_scalable.c
> index 19ea6c2951f3..0ac50836da4d 100644
> --- a/net/ipv4/tcp_scalable.c
> +++ b/net/ipv4/tcp_scalable.c
> @@ -39,7 +39,6 @@ static u32 tcp_scalable_ssthresh(struct sock *sk)
>  static struct tcp_congestion_ops tcp_scalable __read_mostly = {
>         .ssthresh       = tcp_scalable_ssthresh,
>         .cong_avoid     = tcp_scalable_cong_avoid,
> -       .min_cwnd       = tcp_reno_min_cwnd,
>
>         .owner          = THIS_MODULE,
>         .name           = "scalable",
> diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
> index 06cae62bf208..a022c17c9cf1 100644
> --- a/net/ipv4/tcp_vegas.c
> +++ b/net/ipv4/tcp_vegas.c
> @@ -310,7 +310,6 @@ static struct tcp_congestion_ops tcp_vegas __read_mostly = {
>         .init           = tcp_vegas_init,
>         .ssthresh       = tcp_reno_ssthresh,
>         .cong_avoid     = tcp_vegas_cong_avoid,
> -       .min_cwnd       = tcp_reno_min_cwnd,
>         .pkts_acked     = tcp_vegas_pkts_acked,
>         .set_state      = tcp_vegas_state,
>         .cwnd_event     = tcp_vegas_cwnd_event,
> diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
> index 76a1e23259e1..b94a04ae2ed5 100644
> --- a/net/ipv4/tcp_westwood.c
> +++ b/net/ipv4/tcp_westwood.c
> @@ -276,7 +276,6 @@ static struct tcp_congestion_ops tcp_westwood __read_mostly = {
>         .init           = tcp_westwood_init,
>         .ssthresh       = tcp_reno_ssthresh,
>         .cong_avoid     = tcp_reno_cong_avoid,
> -       .min_cwnd       = tcp_westwood_bw_rttmin,
>         .cwnd_event     = tcp_westwood_event,
>         .get_info       = tcp_westwood_info,
>         .pkts_acked     = tcp_westwood_pkts_acked,
> diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
> index a347a078ee07..5d2d15c5295f 100644
> --- a/net/ipv4/tcp_yeah.c
> +++ b/net/ipv4/tcp_yeah.c
> @@ -231,7 +231,6 @@ static struct tcp_congestion_ops tcp_yeah __read_mostly = {
>         .init           = tcp_yeah_init,
>         .ssthresh       = tcp_yeah_ssthresh,
>         .cong_avoid     = tcp_yeah_cong_avoid,
> -       .min_cwnd       = tcp_reno_min_cwnd,
>         .set_state      = tcp_vegas_state,
>         .cwnd_event     = tcp_vegas_cwnd_event,
>         .get_info       = tcp_vegas_get_info,
> --
> 1.8.3.2
>
