From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next 2/2] tcp: remove TCP_SKB_CB(skb)->when
Date: Fri, 5 Sep 2014 15:49:31 -0700
Message-ID: <CAK6E8=dnVjZpe1jWUmmKb5uYJOU_Whn5zvVi2ZoNDPgLQzkvQg@mail.gmail.com>
References: <1409956413-29472-1-git-send-email-edumazet@google.com> <1409956413-29472-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:62753 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865AbaIEWuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 18:50:12 -0400
Received: by mail-ig0-f180.google.com with SMTP id hn18so154333igb.13
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 15:50:11 -0700 (PDT)
In-Reply-To: <1409956413-29472-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 5, 2014 at 3:33 PM, Eric Dumazet <edumazet@google.com> wrote:
> After commit 740b0f1841f6 ("tcp: switch rtt estimations to usec resolution"),
> we no longer need to maintain timestamps in two different fields.
>
> TCP_SKB_CB(skb)->when can be removed, as same information sits in skb_mstamp.stamp_jiffies
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

> ---
>  include/net/tcp.h     | 13 +++++++------
>  net/ipv4/tcp_input.c  |  3 ++-
>  net/ipv4/tcp_ipv4.c   |  5 +++--
>  net/ipv4/tcp_output.c | 39 ++++++++++++++++-----------------------
>  net/ipv4/tcp_timer.c  |  7 +++----
>  5 files changed, 31 insertions(+), 36 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 0cd7d2c65dc0..a4201ef216e8 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -672,6 +672,12 @@ void tcp_send_window_probe(struct sock *sk);
>   */
>  #define tcp_time_stamp         ((__u32)(jiffies))
>
> +static inline u32 tcp_skb_timestamp(const struct sk_buff *skb)
> +{
> +       return skb->skb_mstamp.stamp_jiffies;
> +}
> +
> +
>  #define tcp_flag_byte(th) (((u_int8_t *)th)[13])
>
>  #define TCPHDR_FIN 0x01
> @@ -698,12 +704,7 @@ struct tcp_skb_cb {
>         } header;       /* For incoming frames          */
>         __u32           seq;            /* Starting sequence number     */
>         __u32           end_seq;        /* SEQ + FIN + SYN + datalen    */
> -       union {
> -               /* used in output path */
> -               __u32           when;   /* used to compute rtt's        */
> -               /* used in input path */
> -               __u32           tcp_tw_isn; /* isn chosen by tcp_timewait_state_process() */
> -       };
> +       __u32           tcp_tw_isn;     /* isn chosen by tcp_timewait_state_process() */
>         __u8            tcp_flags;      /* TCP header flags. (tcp[13])  */
>
>         __u8            sacked;         /* State flags for SACK/FACK.   */
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 9c8b9f1dcf69..f97003ad0af5 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2967,7 +2967,8 @@ void tcp_rearm_rto(struct sock *sk)
>                 if (icsk->icsk_pending == ICSK_TIME_EARLY_RETRANS ||
>                     icsk->icsk_pending == ICSK_TIME_LOSS_PROBE) {
>                         struct sk_buff *skb = tcp_write_queue_head(sk);
> -                       const u32 rto_time_stamp = TCP_SKB_CB(skb)->when + rto;
> +                       const u32 rto_time_stamp =
> +                               tcp_skb_timestamp(skb) + rto;
>                         s32 delta = (s32)(rto_time_stamp - tcp_time_stamp);
>                         /* delta may not be positive if the socket is locked
>                          * when the retrans timer fires and is rescheduled.
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 02e6cd29ebf1..3f9bc3f0bba0 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -437,8 +437,9 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
>                 skb = tcp_write_queue_head(sk);
>                 BUG_ON(!skb);
>
> -               remaining = icsk->icsk_rto - min(icsk->icsk_rto,
> -                               tcp_time_stamp - TCP_SKB_CB(skb)->when);
> +               remaining = icsk->icsk_rto -
> +                           min(icsk->icsk_rto,
> +                               tcp_time_stamp - tcp_skb_timestamp(skb));
>
>                 if (remaining) {
>                         inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 5a7c41fbc6d3..3b22dcb7bb5c 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -550,7 +550,7 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
>
>         if (likely(sysctl_tcp_timestamps && *md5 == NULL)) {
>                 opts->options |= OPTION_TS;
> -               opts->tsval = TCP_SKB_CB(skb)->when + tp->tsoffset;
> +               opts->tsval = tcp_skb_timestamp(skb) + tp->tsoffset;
>                 opts->tsecr = tp->rx_opt.ts_recent;
>                 remaining -= TCPOLEN_TSTAMP_ALIGNED;
>         }
> @@ -618,7 +618,7 @@ static unsigned int tcp_synack_options(struct sock *sk,
>         }
>         if (likely(ireq->tstamp_ok)) {
>                 opts->options |= OPTION_TS;
> -               opts->tsval = TCP_SKB_CB(skb)->when;
> +               opts->tsval = tcp_skb_timestamp(skb);
>                 opts->tsecr = req->ts_recent;
>                 remaining -= TCPOLEN_TSTAMP_ALIGNED;
>         }
> @@ -647,7 +647,6 @@ static unsigned int tcp_established_options(struct sock *sk, struct sk_buff *skb
>                                         struct tcp_out_options *opts,
>                                         struct tcp_md5sig_key **md5)
>  {
> -       struct tcp_skb_cb *tcb = skb ? TCP_SKB_CB(skb) : NULL;
>         struct tcp_sock *tp = tcp_sk(sk);
>         unsigned int size = 0;
>         unsigned int eff_sacks;
> @@ -666,7 +665,7 @@ static unsigned int tcp_established_options(struct sock *sk, struct sk_buff *skb
>
>         if (likely(tp->rx_opt.tstamp_ok)) {
>                 opts->options |= OPTION_TS;
> -               opts->tsval = tcb ? tcb->when + tp->tsoffset : 0;
> +               opts->tsval = skb ? tcp_skb_timestamp(skb) + tp->tsoffset : 0;
>                 opts->tsecr = tp->rx_opt.ts_recent;
>                 size += TCPOLEN_TSTAMP_ALIGNED;
>         }
> @@ -886,8 +885,6 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
>                         skb = skb_clone(skb, gfp_mask);
>                 if (unlikely(!skb))
>                         return -ENOBUFS;
> -               /* Our usage of tstamp should remain private */
> -               skb->tstamp.tv64 = 0;
>         }
>
>         inet = inet_sk(sk);
> @@ -975,7 +972,10 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
>                 TCP_ADD_STATS(sock_net(sk), TCP_MIB_OUTSEGS,
>                               tcp_skb_pcount(skb));
>
> +       /* Our usage of tstamp should remain private */
> +       skb->tstamp.tv64 = 0;
>         err = icsk->icsk_af_ops->queue_xmit(sk, skb, &inet->cork.fl);
> +
>         if (likely(err <= 0))
>                 return err;
>
> @@ -1149,7 +1149,6 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
>         /* Looks stupid, but our code really uses when of
>          * skbs, which it never sent before. --ANK
>          */
Remove the comment above too?


> -       TCP_SKB_CB(buff)->when = TCP_SKB_CB(skb)->when;
>         buff->tstamp = skb->tstamp;
>         tcp_fragment_tstamp(skb, buff);
>
> @@ -1874,8 +1873,8 @@ static int tcp_mtu_probe(struct sock *sk)
>         tcp_init_tso_segs(sk, nskb, nskb->len);
>
>         /* We're ready to send.  If this fails, the probe will
> -        * be resegmented into mss-sized pieces by tcp_write_xmit(). */
> -       TCP_SKB_CB(nskb)->when = tcp_time_stamp;
> +        * be resegmented into mss-sized pieces by tcp_write_xmit().
> +        */
>         if (!tcp_transmit_skb(sk, nskb, 1, GFP_ATOMIC)) {
>                 /* Decrement cwnd here because we are sending
>                  * effectively two packets. */
> @@ -1935,8 +1934,8 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
>                 BUG_ON(!tso_segs);
>
>                 if (unlikely(tp->repair) && tp->repair_queue == TCP_SEND_QUEUE) {
> -                       /* "when" is used as a start point for the retransmit timer */
> -                       TCP_SKB_CB(skb)->when = tcp_time_stamp;
> +                       /* "skb_mstamp" is used as a start point for the retransmit timer */
> +                       skb_mstamp_get(&skb->skb_mstamp);
>                         goto repair; /* Skip network transmission */
>                 }
>
> @@ -2000,8 +1999,6 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
>                     unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
>                         break;
>
> -               TCP_SKB_CB(skb)->when = tcp_time_stamp;
> -
>                 if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp)))
>                         break;
>
> @@ -2499,7 +2496,6 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
>         /* Make a copy, if the first transmission SKB clone we made
>          * is still in somebody's hands, else make a clone.
>          */
> -       TCP_SKB_CB(skb)->when = tcp_time_stamp;
>
>         /* make sure skb->data is aligned on arches that require it
>          * and check if ack-trimming & collapsing extended the headroom
> @@ -2544,7 +2540,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
>
>                 /* Save stamp of the first retransmit. */
>                 if (!tp->retrans_stamp)
> -                       tp->retrans_stamp = TCP_SKB_CB(skb)->when;
> +                       tp->retrans_stamp = tcp_skb_timestamp(skb);
>
>                 /* snd_nxt is stored to detect loss of retransmitted segment,
>                  * see tcp_input.c tcp_sacktag_write_queue().
> @@ -2752,7 +2748,6 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
>         tcp_init_nondata_skb(skb, tcp_acceptable_seq(sk),
>                              TCPHDR_ACK | TCPHDR_RST);
>         /* Send it off. */
> -       TCP_SKB_CB(skb)->when = tcp_time_stamp;
>         if (tcp_transmit_skb(sk, skb, 0, priority))
>                 NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTFAILED);
>
> @@ -2791,7 +2786,6 @@ int tcp_send_synack(struct sock *sk)
>                 TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_ACK;
>                 TCP_ECN_send_synack(tcp_sk(sk), skb);
>         }
> -       TCP_SKB_CB(skb)->when = tcp_time_stamp;
>         return tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
>  }
>
> @@ -2835,10 +2829,10 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
>         memset(&opts, 0, sizeof(opts));
>  #ifdef CONFIG_SYN_COOKIES
>         if (unlikely(req->cookie_ts))
> -               TCP_SKB_CB(skb)->when = cookie_init_timestamp(req);
> +               skb->skb_mstamp.stamp_jiffies = cookie_init_timestamp(req);
>         else
>  #endif
> -       TCP_SKB_CB(skb)->when = tcp_time_stamp;
> +       skb_mstamp_get(&skb->skb_mstamp);
>         tcp_header_size = tcp_synack_options(sk, req, mss, skb, &opts, &md5,
>                                              foc) + sizeof(*th);
>
> @@ -3086,7 +3080,7 @@ int tcp_connect(struct sock *sk)
>         skb_reserve(buff, MAX_TCP_HEADER);
>
>         tcp_init_nondata_skb(buff, tp->write_seq++, TCPHDR_SYN);
> -       tp->retrans_stamp = TCP_SKB_CB(buff)->when = tcp_time_stamp;
> +       tp->retrans_stamp = tcp_time_stamp;
>         tcp_connect_queue_skb(sk, buff);
>         TCP_ECN_send_syn(sk, buff);
>
> @@ -3194,7 +3188,7 @@ void tcp_send_ack(struct sock *sk)
>         tcp_init_nondata_skb(buff, tcp_acceptable_seq(sk), TCPHDR_ACK);
>
>         /* Send it off, this clears delayed acks for us. */
> -       TCP_SKB_CB(buff)->when = tcp_time_stamp;
> +       skb_mstamp_get(&buff->skb_mstamp);
>         tcp_transmit_skb(sk, buff, 0, sk_gfp_atomic(sk, GFP_ATOMIC));
>  }
>
> @@ -3226,7 +3220,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
>          * send it.
>          */
>         tcp_init_nondata_skb(skb, tp->snd_una - !urgent, TCPHDR_ACK);
> -       TCP_SKB_CB(skb)->when = tcp_time_stamp;
> +       skb_mstamp_get(&skb->skb_mstamp);
>         return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
>  }
>
> @@ -3270,7 +3264,6 @@ int tcp_write_wakeup(struct sock *sk)
>                         tcp_set_skb_tso_segs(sk, skb, mss);
>
>                 TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_PSH;
> -               TCP_SKB_CB(skb)->when = tcp_time_stamp;
>                 err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
>                 if (!err)
>                         tcp_event_new_data_sent(sk, skb);
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index df90cd1ce37f..a339e7ba05a4 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -135,10 +135,9 @@ static bool retransmits_timed_out(struct sock *sk,
>         if (!inet_csk(sk)->icsk_retransmits)
>                 return false;
>
> -       if (unlikely(!tcp_sk(sk)->retrans_stamp))
> -               start_ts = TCP_SKB_CB(tcp_write_queue_head(sk))->when;
> -       else
> -               start_ts = tcp_sk(sk)->retrans_stamp;
> +       start_ts = tcp_sk(sk)->retrans_stamp;
> +       if (unlikely(!start_ts))
> +               start_ts = tcp_skb_timestamp(tcp_write_queue_head(sk));
>
>         if (likely(timeout == 0)) {
>                 linear_backoff_thresh = ilog2(TCP_RTO_MAX/rto_base);
> --
> 2.1.0.rc2.206.gedb03e5
>
