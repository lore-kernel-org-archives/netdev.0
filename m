From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next 1/2] tcp: prepare CC get_info() access from getsockopt()
Date: Wed, 29 Apr 2015 09:10:29 -0700
Message-ID: <CAK6E8=dDMSKfHPvf5zCASP+X7dYZ7E6UoY8JhGfboqfnYw0abQ@mail.gmail.com>
References: <1430263429-4069-1-git-send-email-edumazet@google.com> <1430263429-4069-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:38177 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753636AbbD2Qjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 12:39:36 -0400
Received: by igbhj9 with SMTP id hj9so54183366igb.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 09:39:35 -0700 (PDT)
In-Reply-To: <1430263429-4069-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 4:23 PM, Eric Dumazet <edumazet@google.com> wrote:
> We would like that optional info provided by Congestion Control
> modules using netlink can also be read using getsockopt()
>
> This patch changes get_info() to put this information in a buffer,
> instead of skb, like tcp_get_info(), so that following patch
> can reuse this common infrastructure.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

> ---
>  include/net/tcp.h              |  5 ++++-
>  include/uapi/linux/inet_diag.h |  4 ++++
>  net/ipv4/inet_diag.c           |  8 +++++---
>  net/ipv4/tcp_dctcp.c           | 20 ++++++++++----------
>  net/ipv4/tcp_illinois.c        | 21 +++++++++++----------
>  net/ipv4/tcp_vegas.c           | 19 ++++++++++---------
>  net/ipv4/tcp_vegas.h           |  3 ++-
>  7 files changed, 46 insertions(+), 34 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 051dc5c2802d..d5b3089317fb 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -804,6 +804,8 @@ enum tcp_ca_ack_event_flags {
>  /* Requires ECN/ECT set on all packets */
>  #define TCP_CONG_NEEDS_ECN     0x2
>
> +union tcp_cc_info;
> +
>  struct tcp_congestion_ops {
>         struct list_head        list;
>         u32 key;
> @@ -829,7 +831,8 @@ struct tcp_congestion_ops {
>         /* hook for packet ack accounting (optional) */
>         void (*pkts_acked)(struct sock *sk, u32 num_acked, s32 rtt_us);
>         /* get info for inet_diag (optional) */
> -       int (*get_info)(struct sock *sk, u32 ext, struct sk_buff *skb);
> +       size_t (*get_info)(struct sock *sk, u32 ext, int *attr,
> +                          union tcp_cc_info *info);
>
>         char            name[TCP_CA_NAME_MAX];
>         struct module   *owner;
> diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
> index d65c0a09efd3..c7093c75bdd6 100644
> --- a/include/uapi/linux/inet_diag.h
> +++ b/include/uapi/linux/inet_diag.h
> @@ -143,4 +143,8 @@ struct tcp_dctcp_info {
>         __u32   dctcp_ab_tot;
>  };
>
> +union tcp_cc_info {
> +       struct tcpvegas_info    vegas;
> +       struct tcp_dctcp_info   dctcp;
> +};
>  #endif /* _UAPI_INET_DIAG_H_ */
> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index bb77ebdae3b3..4d32262c7502 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -224,14 +224,16 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
>         handler->idiag_get_info(sk, r, info);
>
>         if (sk->sk_state < TCP_TIME_WAIT) {
> -               int err = 0;
> +               union tcp_cc_info info;
> +               size_t sz = 0;
> +               int attr;
>
>                 rcu_read_lock();
>                 ca_ops = READ_ONCE(icsk->icsk_ca_ops);
>                 if (ca_ops && ca_ops->get_info)
> -                       err = ca_ops->get_info(sk, ext, skb);
> +                       sz = ca_ops->get_info(sk, ext, &attr, &info);
>                 rcu_read_unlock();
> -               if (err < 0)
> +               if (sz && nla_put(skb, attr, sz, &info) < 0)
>                         goto errout;
>         }
>
> diff --git a/net/ipv4/tcp_dctcp.c b/net/ipv4/tcp_dctcp.c
> index 4376016f7fa5..4c41c1287197 100644
> --- a/net/ipv4/tcp_dctcp.c
> +++ b/net/ipv4/tcp_dctcp.c
> @@ -277,7 +277,8 @@ static void dctcp_cwnd_event(struct sock *sk, enum tcp_ca_event ev)
>         }
>  }
>
> -static int dctcp_get_info(struct sock *sk, u32 ext, struct sk_buff *skb)
> +static size_t dctcp_get_info(struct sock *sk, u32 ext, int *attr,
> +                            union tcp_cc_info *info)
>  {
>         const struct dctcp *ca = inet_csk_ca(sk);
>
> @@ -286,18 +287,17 @@ static int dctcp_get_info(struct sock *sk, u32 ext, struct sk_buff *skb)
>          */
>         if (ext & (1 << (INET_DIAG_DCTCPINFO - 1)) ||
>             ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
> -               struct tcp_dctcp_info info;
> -
> -               memset(&info, 0, sizeof(info));
> +               memset(info, 0, sizeof(struct tcp_dctcp_info));
>                 if (inet_csk(sk)->icsk_ca_ops != &dctcp_reno) {
> -                       info.dctcp_enabled = 1;
> -                       info.dctcp_ce_state = (u16) ca->ce_state;
> -                       info.dctcp_alpha = ca->dctcp_alpha;
> -                       info.dctcp_ab_ecn = ca->acked_bytes_ecn;
> -                       info.dctcp_ab_tot = ca->acked_bytes_total;
> +                       info->dctcp.dctcp_enabled = 1;
> +                       info->dctcp.dctcp_ce_state = (u16) ca->ce_state;
> +                       info->dctcp.dctcp_alpha = ca->dctcp_alpha;
> +                       info->dctcp.dctcp_ab_ecn = ca->acked_bytes_ecn;
> +                       info->dctcp.dctcp_ab_tot = ca->acked_bytes_total;
>                 }
>
> -               return nla_put(skb, INET_DIAG_DCTCPINFO, sizeof(info), &info);
> +               *attr = INET_DIAG_DCTCPINFO;
> +               return sizeof(*info);
>         }
>         return 0;
>  }
> diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
> index 67476f085e48..f71002e4db0b 100644
> --- a/net/ipv4/tcp_illinois.c
> +++ b/net/ipv4/tcp_illinois.c
> @@ -300,24 +300,25 @@ static u32 tcp_illinois_ssthresh(struct sock *sk)
>  }
>
>  /* Extract info for Tcp socket info provided via netlink. */
> -static int tcp_illinois_info(struct sock *sk, u32 ext, struct sk_buff *skb)
> +static size_t tcp_illinois_info(struct sock *sk, u32 ext, int *attr,
> +                               union tcp_cc_info *info)
>  {
>         const struct illinois *ca = inet_csk_ca(sk);
>
>         if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
> -               struct tcpvegas_info info = {
> -                       .tcpv_enabled = 1,
> -                       .tcpv_rttcnt = ca->cnt_rtt,
> -                       .tcpv_minrtt = ca->base_rtt,
> -               };
> +               info->vegas.tcpv_enabled = 1;
> +               info->vegas.tcpv_rttcnt = ca->cnt_rtt;
> +               info->vegas.tcpv_minrtt = ca->base_rtt;
> +               info->vegas.tcpv_rtt = 0;
>
> -               if (info.tcpv_rttcnt > 0) {
> +               if (info->vegas.tcpv_rttcnt > 0) {
>                         u64 t = ca->sum_rtt;
>
> -                       do_div(t, info.tcpv_rttcnt);
> -                       info.tcpv_rtt = t;
> +                       do_div(t, info->vegas.tcpv_rttcnt);
> +                       info->vegas.tcpv_rtt = t;
>                 }
> -               return nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
> +               *attr = INET_DIAG_VEGASINFO;
> +               return sizeof(struct tcpvegas_info);
>         }
>         return 0;
>  }
> diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
> index c71a1b8f7bde..a6cea1d5e20d 100644
> --- a/net/ipv4/tcp_vegas.c
> +++ b/net/ipv4/tcp_vegas.c
> @@ -286,18 +286,19 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 acked)
>  }
>
>  /* Extract info for Tcp socket info provided via netlink. */
> -int tcp_vegas_get_info(struct sock *sk, u32 ext, struct sk_buff *skb)
> +size_t tcp_vegas_get_info(struct sock *sk, u32 ext, int *attr,
> +                         union tcp_cc_info *info)
>  {
>         const struct vegas *ca = inet_csk_ca(sk);
> +
>         if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
> -               struct tcpvegas_info info = {
> -                       .tcpv_enabled = ca->doing_vegas_now,
> -                       .tcpv_rttcnt = ca->cntRTT,
> -                       .tcpv_rtt = ca->baseRTT,
> -                       .tcpv_minrtt = ca->minRTT,
> -               };
> -
> -               return nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
> +               info->vegas.tcpv_enabled = ca->doing_vegas_now,
> +               info->vegas.tcpv_rttcnt = ca->cntRTT,
> +               info->vegas.tcpv_rtt = ca->baseRTT,
> +               info->vegas.tcpv_minrtt = ca->minRTT,
> +
> +               *attr = INET_DIAG_VEGASINFO;
> +               return sizeof(struct tcpvegas_info);
>         }
>         return 0;
>  }
> diff --git a/net/ipv4/tcp_vegas.h b/net/ipv4/tcp_vegas.h
> index e8a6b33cc61d..ef9da5306c68 100644
> --- a/net/ipv4/tcp_vegas.h
> +++ b/net/ipv4/tcp_vegas.h
> @@ -19,6 +19,7 @@ void tcp_vegas_init(struct sock *sk);
>  void tcp_vegas_state(struct sock *sk, u8 ca_state);
>  void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, s32 rtt_us);
>  void tcp_vegas_cwnd_event(struct sock *sk, enum tcp_ca_event event);
> -int tcp_vegas_get_info(struct sock *sk, u32 ext, struct sk_buff *skb);
> +size_t tcp_vegas_get_info(struct sock *sk, u32 ext, int *attr,
> +                         union tcp_cc_info *info);
>
>  #endif /* __TCP_VEGAS_H */
> --
> 2.2.0.rc0.207.ga3a616c
>
