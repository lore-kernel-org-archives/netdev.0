From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH 1/1] net: tcp: RTO restart
Date: Tue, 18 Feb 2014 10:46:18 -0800
Message-ID: <CAK6E8=ekVXA9JrajwmJk88bUKcJSi=T5+SFXs0VoG5iQkWBcRw@mail.gmail.com>
References: <20140218181205.GA7780@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Anna Brunstrom <anna.brunstrom@kau.se>,
	Andreas Petlund <apetlund@simula.no>,
	Michael Welzl <michawe@ifi.uio.no>,
	=?UTF-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:58772 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaBRSq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 13:46:58 -0500
Received: by mail-ie0-f180.google.com with SMTP id ar20so3899488iec.11
        for <netdev@vger.kernel.org>; Tue, 18 Feb 2014 10:46:58 -0800 (PST)
In-Reply-To: <20140218181205.GA7780@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 18, 2014 at 10:12 AM, Per Hurtig <per.hurtig@kau.se> wrote:
> This patch implements the RTO restart modification described in
> http://tools.ietf.org/html/draft-ietf-tcpm-rtorestart-02
>
> RTO Restart's goal is to provide quicker loss recovery for segments lost in the
> end of a burst/connection. To accomplish this the algorithm adjusts the RTO
> value on each rearm of the retransmission timer to be exactly RTO ms after the
> earliest outstanding segment was sent. The offsetting against the earliest
> outstanding segment is not done by the regular rearm algorithm, which causes
> RTOs to occur, on average, after RTO+RTT ms.
>
> As a faster timeout is only beneficial in scenarios where fast retransmit/early
> retransmit cannot be triggered the algorithm will only kick in when there is a
> small amount of outstanding segments.
(repost in plaine-text, sorry for the duplication)

I am not sure this works well with Linux min-RTO=200ms, and don't feel
comfortable this is default on without some real experiments.

I've implemented (a nearly identical version of) rto-restart on Google
web servers and found #timeouts increased by ~30%. Although the fast
timeout helps really short flows, it has a very negative side-effect:
resetting cwnd to 1. Thus the next HTTP response may start with a
small cwnd. In contrast, TCP loss probe has fast timeout (1.5RTT) to
do fast recovery to avoid the side-effect. In other words, I am
doubtful we need rto-restart with TCP loss probe, but applying
RTO-restart on TLP timer may be useful.

I've voiced this concern multiple times in ietf tcpm discussion when
we discuss this draft: that the idea itself is fine, but we'll need to
change Linux RTO algorithm together, not just the timer itself.

I am happy to post some more detailed data if people are interested.

>
> The RTO Restart proposal is accepted as a working group item in the IETF TCP
> Maintenance and Minor Extensions (tcpm) TCP wg and is intended for experimental
> RFC status.
>
> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
> ---
>  include/net/tcp.h          |    1 +
>  net/ipv4/sysctl_net_ipv4.c |    7 +++++++
>  net/ipv4/tcp_input.c       |   11 +++++++++++
>  3 files changed, 19 insertions(+)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 56fc366..575e82a 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -278,6 +278,7 @@ extern int sysctl_tcp_slow_start_after_idle;
>  extern int sysctl_tcp_thin_linear_timeouts;
>  extern int sysctl_tcp_thin_dupack;
>  extern int sysctl_tcp_early_retrans;
> +extern int sysctl_tcp_rto_restart;
>  extern int sysctl_tcp_limit_output_bytes;
>  extern int sysctl_tcp_challenge_ack_limit;
>  extern unsigned int sysctl_tcp_notsent_lowat;
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 44eba05..c605f4f 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -717,6 +717,13 @@ static struct ctl_table ipv4_table[] = {
>                 .extra2         = &four,
>         },
>         {
> +               .procname       = "tcp_rto_restart",
> +               .data           = &sysctl_tcp_rto_restart,
> +               .maxlen         = sizeof(int),
> +               .mode           = 0644,
> +               .proc_handler   = proc_dointvec,
> +       },
> +       {
>                 .procname       = "tcp_min_tso_segs",
>                 .data           = &sysctl_tcp_min_tso_segs,
>                 .maxlen         = sizeof(int),
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 227cba7..450ee30 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -98,6 +98,7 @@ int sysctl_tcp_thin_dupack __read_mostly;
>
>  int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
>  int sysctl_tcp_early_retrans __read_mostly = 3;
> +int sysctl_tcp_rto_restart __read_mostly = 1;
>
>  #define FLAG_DATA              0x01 /* Incoming frame contained data.          */
>  #define FLAG_WIN_UPDATE                0x02 /* Incoming ACK was a window update.       */
> @@ -2972,6 +2973,16 @@ void tcp_rearm_rto(struct sock *sk)
>                          */
>                         if (delta > 0)
>                                 rto = delta;
> +               } else if (icsk->icsk_pending == ICSK_TIME_RETRANS &&
> +                          sysctl_tcp_rto_restart &&
> +                          sk->sk_send_head == NULL &&
> +                          tp->packets_out < 4) {
> +                       struct sk_buff *skb = tcp_write_queue_head(sk);
> +                       const u32 rto_time_stamp = TCP_SKB_CB(skb)->when;
> +                       s32 delta = (s32)(tcp_time_stamp - rto_time_stamp);
> +
> +                       if (delta > 0)
> +                               rto -= delta;
>                 }
>                 inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, rto,
>                                           TCP_RTO_MAX);
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
