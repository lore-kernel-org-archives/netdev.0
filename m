From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [RFC PATCH v6 net-next 1/4] tcp: replace cnt & rtt with struct in pkts_acked()
Date: Thu, 27 Aug 2015 14:42:30 -0700
Message-ID: <CAK6E8=ceviJ+PPOO2HkBu+ZG0hApbQWERmimHb-hyc8U7YoF-g@mail.gmail.com>
References: <1440545634-3901299-1-git-send-email-brakmo@fb.com> <1440545634-3901299-2-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f49.google.com ([209.85.213.49]:33760 "EHLO
	mail-vk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbbH0VnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 17:43:11 -0400
Received: by vkgi6 with SMTP id i6so1324627vkg.0
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 14:43:10 -0700 (PDT)
In-Reply-To: <1440545634-3901299-2-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2015 at 4:33 PM, Lawrence Brakmo <brakmo@fb.com> wrote:
> Replace 2 arguments (cnt and rtt) in the congestion control modules'
> pkts_acked() function with a struct. This will allow adding more
> information without having to modify existing congestion control
> modules (tcp_nv in particular needs bytes in flight when packet
> was sent).
>
> As proposed by Neal Cardwell in his comments to the tcp_nv patch.
>
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

> ---
>  include/net/tcp.h       |  7 ++++++-
>  net/ipv4/tcp_bic.c      |  6 +++---
>  net/ipv4/tcp_cdg.c      | 14 +++++++-------
>  net/ipv4/tcp_cubic.c    |  6 +++---
>  net/ipv4/tcp_htcp.c     | 10 +++++-----
>  net/ipv4/tcp_illinois.c | 20 ++++++++++----------
>  net/ipv4/tcp_input.c    |  7 +++++--
>  net/ipv4/tcp_lp.c       |  6 +++---
>  net/ipv4/tcp_vegas.c    |  6 +++---
>  net/ipv4/tcp_vegas.h    |  2 +-
>  net/ipv4/tcp_veno.c     |  7 ++++---
>  net/ipv4/tcp_westwood.c |  7 ++++---
>  net/ipv4/tcp_yeah.c     |  7 ++++---
>  13 files changed, 58 insertions(+), 47 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 364426a..0121529 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -834,6 +834,11 @@ enum tcp_ca_ack_event_flags {
>
>  union tcp_cc_info;
>
> +struct ack_sample {
> +       u32 pkts_acked;
> +       s32 rtt_us;
> +};
> +
>  struct tcp_congestion_ops {
>         struct list_head        list;
>         u32 key;
> @@ -857,7 +862,7 @@ struct tcp_congestion_ops {
>         /* new value of cwnd after loss (optional) */
>         u32  (*undo_cwnd)(struct sock *sk);
>         /* hook for packet ack accounting (optional) */
> -       void (*pkts_acked)(struct sock *sk, u32 num_acked, s32 rtt_us);
> +       void (*pkts_acked)(struct sock *sk, const struct ack_sample *sample);
>         /* get info for inet_diag (optional) */
>         size_t (*get_info)(struct sock *sk, u32 ext, int *attr,
>                            union tcp_cc_info *info);
> diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
> index fd1405d..f469f1b 100644
> --- a/net/ipv4/tcp_bic.c
> +++ b/net/ipv4/tcp_bic.c
> @@ -197,15 +197,15 @@ static void bictcp_state(struct sock *sk, u8 new_state)
>  /* Track delayed acknowledgment ratio using sliding window
>   * ratio = (15*ratio + sample) / 16
>   */
> -static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt)
> +static void bictcp_acked(struct sock *sk, const struct ack_sample *sample)
>  {
>         const struct inet_connection_sock *icsk = inet_csk(sk);
>
>         if (icsk->icsk_ca_state == TCP_CA_Open) {
>                 struct bictcp *ca = inet_csk_ca(sk);
>
> -               cnt -= ca->delayed_ack >> ACK_RATIO_SHIFT;
> -               ca->delayed_ack += cnt;
> +               ca->delayed_ack += sample->pkts_acked -
> +                       (ca->delayed_ack >> ACK_RATIO_SHIFT);
>         }
>  }
>
> diff --git a/net/ipv4/tcp_cdg.c b/net/ipv4/tcp_cdg.c
> index 167b6a3..b4e5af7 100644
> --- a/net/ipv4/tcp_cdg.c
> +++ b/net/ipv4/tcp_cdg.c
> @@ -294,12 +294,12 @@ static void tcp_cdg_cong_avoid(struct sock *sk, u32 ack, u32 acked)
>         ca->shadow_wnd = max(ca->shadow_wnd, ca->shadow_wnd + incr);
>  }
>
> -static void tcp_cdg_acked(struct sock *sk, u32 num_acked, s32 rtt_us)
> +static void tcp_cdg_acked(struct sock *sk, const struct ack_sample *sample)
>  {
>         struct cdg *ca = inet_csk_ca(sk);
>         struct tcp_sock *tp = tcp_sk(sk);
>
> -       if (rtt_us <= 0)
> +       if (sample->rtt_us <= 0)
>                 return;
>
>         /* A heuristic for filtering delayed ACKs, adapted from:
> @@ -307,20 +307,20 @@ static void tcp_cdg_acked(struct sock *sk, u32 num_acked, s32 rtt_us)
>          * delay and rate based TCP mechanisms." TR 100219A. CAIA, 2010.
>          */
>         if (tp->sacked_out == 0) {
> -               if (num_acked == 1 && ca->delack) {
> +               if (sample->pkts_acked == 1 && ca->delack) {
>                         /* A delayed ACK is only used for the minimum if it is
>                          * provenly lower than an existing non-zero minimum.
>                          */
> -                       ca->rtt.min = min(ca->rtt.min, rtt_us);
> +                       ca->rtt.min = min(ca->rtt.min, sample->rtt_us);
>                         ca->delack--;
>                         return;
> -               } else if (num_acked > 1 && ca->delack < 5) {
> +               } else if (sample->pkts_acked > 1 && ca->delack < 5) {
>                         ca->delack++;
>                 }
>         }
>
> -       ca->rtt.min = min_not_zero(ca->rtt.min, rtt_us);
> -       ca->rtt.max = max(ca->rtt.max, rtt_us);
> +       ca->rtt.min = min_not_zero(ca->rtt.min, sample->rtt_us);
> +       ca->rtt.max = max(ca->rtt.max, sample->rtt_us);
>  }
>
>  static u32 tcp_cdg_ssthresh(struct sock *sk)
> diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
> index 28011fb..c5d0ba5 100644
> --- a/net/ipv4/tcp_cubic.c
> +++ b/net/ipv4/tcp_cubic.c
> @@ -416,21 +416,21 @@ static void hystart_update(struct sock *sk, u32 delay)
>  /* Track delayed acknowledgment ratio using sliding window
>   * ratio = (15*ratio + sample) / 16
>   */
> -static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt_us)
> +static void bictcp_acked(struct sock *sk, const struct ack_sample *sample)
>  {
>         const struct tcp_sock *tp = tcp_sk(sk);
>         struct bictcp *ca = inet_csk_ca(sk);
>         u32 delay;
>
>         /* Some calls are for duplicates without timetamps */
> -       if (rtt_us < 0)
> +       if (sample->rtt_us < 0)
>                 return;
>
>         /* Discard delay samples right after fast recovery */
>         if (ca->epoch_start && (s32)(tcp_time_stamp - ca->epoch_start) < HZ)
>                 return;
>
> -       delay = (rtt_us << 3) / USEC_PER_MSEC;
> +       delay = (sample->rtt_us << 3) / USEC_PER_MSEC;
>         if (delay == 0)
>                 delay = 1;
>
> diff --git a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp_htcp.c
> index 82f0d9e..4a4d8e7 100644
> --- a/net/ipv4/tcp_htcp.c
> +++ b/net/ipv4/tcp_htcp.c
> @@ -99,7 +99,7 @@ static inline void measure_rtt(struct sock *sk, u32 srtt)
>  }
>
>  static void measure_achieved_throughput(struct sock *sk,
> -                                       u32 pkts_acked, s32 rtt)
> +                                       const struct ack_sample *sample)
>  {
>         const struct inet_connection_sock *icsk = inet_csk(sk);
>         const struct tcp_sock *tp = tcp_sk(sk);
> @@ -107,10 +107,10 @@ static void measure_achieved_throughput(struct sock *sk,
>         u32 now = tcp_time_stamp;
>
>         if (icsk->icsk_ca_state == TCP_CA_Open)
> -               ca->pkts_acked = pkts_acked;
> +               ca->pkts_acked = sample->pkts_acked;
>
> -       if (rtt > 0)
> -               measure_rtt(sk, usecs_to_jiffies(rtt));
> +       if (sample->rtt_us > 0)
> +               measure_rtt(sk, usecs_to_jiffies(sample->rtt_us));
>
>         if (!use_bandwidth_switch)
>                 return;
> @@ -122,7 +122,7 @@ static void measure_achieved_throughput(struct sock *sk,
>                 return;
>         }
>
> -       ca->packetcount += pkts_acked;
> +       ca->packetcount += sample->pkts_acked;
>
>         if (ca->packetcount >= tp->snd_cwnd - (ca->alpha >> 7 ? : 1) &&
>             now - ca->lasttime >= ca->minRTT &&
> diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
> index 2ab9bbb..77ad119 100644
> --- a/net/ipv4/tcp_illinois.c
> +++ b/net/ipv4/tcp_illinois.c
> @@ -82,30 +82,30 @@ static void tcp_illinois_init(struct sock *sk)
>  }
>
>  /* Measure RTT for each ack. */
> -static void tcp_illinois_acked(struct sock *sk, u32 pkts_acked, s32 rtt)
> +static void tcp_illinois_acked(struct sock *sk, const struct ack_sample *sample)
>  {
>         struct illinois *ca = inet_csk_ca(sk);
>
> -       ca->acked = pkts_acked;
> +       ca->acked = sample->pkts_acked;
>
>         /* dup ack, no rtt sample */
> -       if (rtt < 0)
> +       if (sample->rtt_us < 0)
>                 return;
>
>         /* ignore bogus values, this prevents wraparound in alpha math */
> -       if (rtt > RTT_MAX)
> -               rtt = RTT_MAX;
> +       if (sample->rtt_us > RTT_MAX)
> +               sample->rtt_us = RTT_MAX;
>
>         /* keep track of minimum RTT seen so far */
> -       if (ca->base_rtt > rtt)
> -               ca->base_rtt = rtt;
> +       if (ca->base_rtt > sample->rtt_us)
> +               ca->base_rtt = sample->rtt_us;
>
>         /* and max */
> -       if (ca->max_rtt < rtt)
> -               ca->max_rtt = rtt;
> +       if (ca->max_rtt < sample->rtt_us)
> +               ca->max_rtt = sample->rtt_us;
>
>         ++ca->cnt_rtt;
> -       ca->sum_rtt += rtt;
> +       ca->sum_rtt += sample->rtt_us;
>  }
>
>  /* Maximum queuing delay */
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 4e4d6bc..f506a0a 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3196,8 +3196,11 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
>                 tcp_rearm_rto(sk);
>         }
>
> -       if (icsk->icsk_ca_ops->pkts_acked)
> -               icsk->icsk_ca_ops->pkts_acked(sk, pkts_acked, ca_rtt_us);
> +       if (icsk->icsk_ca_ops->pkts_acked) {
> +               struct ack_sample sample = {pkts_acked, ca_rtt_us};
> +
> +               icsk->icsk_ca_ops->pkts_acked(sk, &sample);
> +       }
>
>  #if FASTRETRANS_DEBUG > 0
>         WARN_ON((int)tp->sacked_out < 0);
> diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
> index 1e70fa8..c67ece1 100644
> --- a/net/ipv4/tcp_lp.c
> +++ b/net/ipv4/tcp_lp.c
> @@ -260,13 +260,13 @@ static void tcp_lp_rtt_sample(struct sock *sk, u32 rtt)
>   * newReno in increase case.
>   * We work it out by following the idea from TCP-LP's paper directly
>   */
> -static void tcp_lp_pkts_acked(struct sock *sk, u32 num_acked, s32 rtt_us)
> +static void tcp_lp_pkts_acked(struct sock *sk, const struct ack_sample *sample)
>  {
>         struct tcp_sock *tp = tcp_sk(sk);
>         struct lp *lp = inet_csk_ca(sk);
>
> -       if (rtt_us > 0)
> -               tcp_lp_rtt_sample(sk, rtt_us);
> +       if (sample->rtt_us > 0)
> +               tcp_lp_rtt_sample(sk, sample->rtt_us);
>
>         /* calc inference */
>         if (tcp_time_stamp > tp->rx_opt.rcv_tsecr)
> diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
> index 13951c4..4c4bac1 100644
> --- a/net/ipv4/tcp_vegas.c
> +++ b/net/ipv4/tcp_vegas.c
> @@ -107,16 +107,16 @@ EXPORT_SYMBOL_GPL(tcp_vegas_init);
>   *   o min-filter RTT samples from a much longer window (forever for now)
>   *     to find the propagation delay (baseRTT)
>   */
> -void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, s32 rtt_us)
> +void tcp_vegas_pkts_acked(struct sock *sk, const struct ack_sample *sample)
>  {
>         struct vegas *vegas = inet_csk_ca(sk);
>         u32 vrtt;
>
> -       if (rtt_us < 0)
> +       if (sample->rtt_us < 0)
>                 return;
>
>         /* Never allow zero rtt or baseRTT */
> -       vrtt = rtt_us + 1;
> +       vrtt = sample->rtt_us + 1;
>
>         /* Filter to find propagation delay: */
>         if (vrtt < vegas->baseRTT)
> diff --git a/net/ipv4/tcp_vegas.h b/net/ipv4/tcp_vegas.h
> index ef9da53..248cfc0 100644
> --- a/net/ipv4/tcp_vegas.h
> +++ b/net/ipv4/tcp_vegas.h
> @@ -17,7 +17,7 @@ struct vegas {
>
>  void tcp_vegas_init(struct sock *sk);
>  void tcp_vegas_state(struct sock *sk, u8 ca_state);
> -void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, s32 rtt_us);
> +void tcp_vegas_pkts_acked(struct sock *sk, const struct ack_sample *sample);
>  void tcp_vegas_cwnd_event(struct sock *sk, enum tcp_ca_event event);
>  size_t tcp_vegas_get_info(struct sock *sk, u32 ext, int *attr,
>                           union tcp_cc_info *info);
> diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
> index 0d094b9..40171e1 100644
> --- a/net/ipv4/tcp_veno.c
> +++ b/net/ipv4/tcp_veno.c
> @@ -69,16 +69,17 @@ static void tcp_veno_init(struct sock *sk)
>  }
>
>  /* Do rtt sampling needed for Veno. */
> -static void tcp_veno_pkts_acked(struct sock *sk, u32 cnt, s32 rtt_us)
> +static void tcp_veno_pkts_acked(struct sock *sk,
> +                               const struct ack_sample *sample)
>  {
>         struct veno *veno = inet_csk_ca(sk);
>         u32 vrtt;
>
> -       if (rtt_us < 0)
> +       if (sample->rtt_us < 0)
>                 return;
>
>         /* Never allow zero rtt or baseRTT */
> -       vrtt = rtt_us + 1;
> +       vrtt = sample->rtt_us + 1;
>
>         /* Filter to find propagation delay: */
>         if (vrtt < veno->basertt)
> diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
> index c10732e..4b03a2e 100644
> --- a/net/ipv4/tcp_westwood.c
> +++ b/net/ipv4/tcp_westwood.c
> @@ -99,12 +99,13 @@ static void westwood_filter(struct westwood *w, u32 delta)
>   * Called after processing group of packets.
>   * but all westwood needs is the last sample of srtt.
>   */
> -static void tcp_westwood_pkts_acked(struct sock *sk, u32 cnt, s32 rtt)
> +static void tcp_westwood_pkts_acked(struct sock *sk,
> +                                   const struct ack_sample *sample)
>  {
>         struct westwood *w = inet_csk_ca(sk);
>
> -       if (rtt > 0)
> -               w->rtt = usecs_to_jiffies(rtt);
> +       if (sample->rtt_us > 0)
> +               w->rtt = usecs_to_jiffies(sample->rtt_us);
>  }
>
>  /*
> diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
> index 17d3566..1b9d013 100644
> --- a/net/ipv4/tcp_yeah.c
> +++ b/net/ipv4/tcp_yeah.c
> @@ -56,15 +56,16 @@ static void tcp_yeah_init(struct sock *sk)
>         tp->snd_cwnd_clamp = min_t(u32, tp->snd_cwnd_clamp, 0xffffffff/128);
>  }
>
> -static void tcp_yeah_pkts_acked(struct sock *sk, u32 pkts_acked, s32 rtt_us)
> +static void tcp_yeah_pkts_acked(struct sock *sk,
> +                               const struct ack_sample *sample)
>  {
>         const struct inet_connection_sock *icsk = inet_csk(sk);
>         struct yeah *yeah = inet_csk_ca(sk);
>
>         if (icsk->icsk_ca_state == TCP_CA_Open)
> -               yeah->pkts_acked = pkts_acked;
> +               yeah->pkts_acked = sample->pkts_acked;
>
> -       tcp_vegas_pkts_acked(sk, pkts_acked, rtt_us);
> +       tcp_vegas_pkts_acked(sk, sample);
>  }
>
>  static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack, u32 acked)
> --
> 1.8.1
>
