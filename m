From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [RFC PATCH net-next 1/2] tcp: RTO Restart (RTOR)
Date: Mon, 7 Dec 2015 18:05:13 -0800
Message-ID: <CAK6E8=efnk_bL-JP-6avUtqc1+Xnp7YM3=Tphw7B6oevO4jbeQ@mail.gmail.com>
References: <cover.1449478261.git.per.hurtig@kau.se> <4719073d7d8285006b2fe5f1b67a3fe5255c503e.1449478261.git.per.hurtig@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Tom Herbert <tom@herbertland.com>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	Florian Westphal <fw@strlen.de>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Willem de Bruijn <willemb@google.com>,
	=?UTF-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Pasi Sarolahti <pasi.sarolahti@iki.fi>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	Anna Brunstrom <anna.brunstrom@kau.se>,
	Andreas Petlund <apetlund@simula.no>,
	Michael Welzl <michawe@ifi.uio.no>, mohammad.rajiullah@kau.se
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35893 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932577AbbLHCFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 21:05:54 -0500
Received: by wmww144 with SMTP id w144so163640892wmw.1
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 18:05:53 -0800 (PST)
In-Reply-To: <4719073d7d8285006b2fe5f1b67a3fe5255c503e.1449478261.git.per.hurtig@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 7, 2015 at 1:00 AM, Per Hurtig <per.hurtig@kau.se> wrote:
> This patch implements the RTO restart modification (RTOR). When data is
> ACKed, and the RTO timer is restarted, the time elapsed since the last
> outstanding segment was transmitted is subtracted from the calculated RTO
> value. This way, the RTO timer will expire after exactly RTO seconds, and
> not RTO + RTT [+ delACK] seconds.
>
> This patch also implements a new sysctl (tcp_timer_restart) that is used
> to control the timer restart behavior.
>
> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
> ---
>  Documentation/networking/ip-sysctl.txt | 12 ++++++++++++
>  include/net/tcp.h                      |  4 ++++
>  net/ipv4/sysctl_net_ipv4.c             | 10 ++++++++++
>  net/ipv4/tcp_input.c                   | 24 ++++++++++++++++++++++++
>  4 files changed, 50 insertions(+)
>
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 2ea4c45..4094128 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -591,6 +591,18 @@ tcp_syn_retries - INTEGER
>         with the current initial RTO of 1second. With this the final timeout
>         for an active TCP connection attempt will happen after 127seconds.
>
> +tcp_timer_restart - INTEGER
> +       Controls how the RTO and PTO timers are restarted (RTOR and TLPR).
> +       If set (per timer or combined) the timers are restarted with
> +       respect to the earliest outstanding segment, to not extend tail loss
> +       latency unnecessarily.
> +       Possible values:
> +               0 disables RTOR and TLPR.
> +               1 enables RTOR.
> +               2 enables TLPR.
> +               3 enables RTOR and TLPR.
> +       Default: 3
> +
>  tcp_timestamps - BOOLEAN
>         Enable timestamps as defined in RFC1323.
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index f80e74c..bf98768 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -76,6 +76,9 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
>  /* After receiving this amount of duplicate ACKs fast retransmit starts. */
>  #define TCP_FASTRETRANS_THRESH 3
>
> +/* Disable RTO Restart if the number of outstanding segments is at least. */
> +#define TCP_RTORESTART_THRESH  4
> +
>  /* Maximal number of ACKs sent quickly to accelerate slow-start. */
>  #define TCP_MAX_QUICKACKS      16U
>
> @@ -284,6 +287,7 @@ extern int sysctl_tcp_autocorking;
>  extern int sysctl_tcp_invalid_ratelimit;
>  extern int sysctl_tcp_pacing_ss_ratio;
>  extern int sysctl_tcp_pacing_ca_ratio;
> +extern int sysctl_tcp_timer_restart;
>
>  extern atomic_long_t tcp_memory_allocated;
>  extern struct percpu_counter tcp_sockets_allocated;
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index a0bd7a5..dfb6968 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -28,6 +28,7 @@
>
>  static int zero;
>  static int one = 1;
> +static int three = 3;
>  static int four = 4;
>  static int thousand = 1000;
>  static int gso_max_segs = GSO_MAX_SEGS;
> @@ -745,6 +746,15 @@ static struct ctl_table ipv4_table[] = {
>                 .extra2         = &thousand,
>         },
>         {
> +               .procname       = "tcp_timer_restart",
> +               .data           = &sysctl_tcp_timer_restart,
> +               .maxlen         = sizeof(int),
> +               .mode           = 0644,
> +               .proc_handler   = proc_dointvec_minmax,
> +               .extra1         = &zero,
> +               .extra2         = &three,
> +       },
> +       {
>                 .procname       = "tcp_autocorking",
>                 .data           = &sysctl_tcp_autocorking,
>                 .maxlen         = sizeof(int),
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index fdd88c3..66e0425 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -101,6 +101,7 @@ int sysctl_tcp_thin_dupack __read_mostly;
>
>  int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
>  int sysctl_tcp_early_retrans __read_mostly = 3;
> +int sysctl_tcp_timer_restart __read_mostly = 3;
>  int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
>
>  #define FLAG_DATA              0x01 /* Incoming frame contained data.          */
> @@ -2997,6 +2998,18 @@ static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
>         tcp_sk(sk)->snd_cwnd_stamp = tcp_time_stamp;
>  }
>
> +static u32 tcp_unsent_pkts(const struct sock *sk)
> +{
> +       struct sk_buff *skb = tcp_send_head(sk);
> +       u32 pkts = 0;
> +
> +       if (skb)
> +               tcp_for_write_queue_from(skb, sk)
> +                       pkts += tcp_skb_pcount(skb);
> +
> +       return pkts;
> +}
> +
>  /* Restart timer after forward progress on connection.
>   * RFC2988 recommends to restart timer to now+rto.
>   */
> @@ -3027,6 +3040,17 @@ void tcp_rearm_rto(struct sock *sk)
>                          */
>                         if (delta > 0)
>                                 rto = delta;
> +               } else if (icsk->icsk_pending == ICSK_TIME_RETRANS &&
> +                          (sysctl_tcp_timer_restart == 1 ||
> +                           sysctl_tcp_timer_restart == 3) &&
> +                          (tp->packets_out + tcp_unsent_pkts(sk) <
We re-arm RTO every ACK. Do we really need a loop here to improve
short-transfer RTO performance?

Going one level up: what's the rationale to arm RTO differently
depending on the #packets in the write queue? if the idea is to offset
the elapsed of the first unacked packet in RTO, it should generally
apply to any packet w/ any inflight, and we can forgo another packet
counting heuristic.

While larger inflight can trigger more fast recoveries, tail drops can
happen at any time. This is why TLP is always enabled of any inflight.
Sounds like we can benefit if RTO-restart is always used too? I am
planning to experiment your patch w and w/o the packet count checks.


> +                           TCP_RTORESTART_THRESH)) {
> +                       struct sk_buff *skb = tcp_write_queue_head(sk);
> +                       const u32 rto_time_stamp = tcp_skb_timestamp(skb);
> +                       s32 delta = (s32)(tcp_time_stamp - rto_time_stamp);
> +
> +                       if (delta > 0 && rto > delta)
> +                               rto -= delta;
>                 }
>                 inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, rto,
>                                           TCP_RTO_MAX);
> --
> 1.9.1
>
>
