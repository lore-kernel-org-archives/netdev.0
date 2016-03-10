From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next v4] tcp: Add RFC4898 tcpEStatsPerfDataSegsOut/In
Date: Thu, 10 Mar 2016 09:37:18 -0800
Message-ID: <CAK6E8=fUbyPK0buU70TvGhZHLc3_TfGuODwmxixyhoXeBFdecw@mail.gmail.com>
References: <1457630961-2809690-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Chris Rapier <rapier@psc.edu>,
	Eric Dumazet <edumazet@google.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Neal Cardwell <ncardwell@google.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37797 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618AbcCJRiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 12:38:00 -0500
Received: by mail-wm0-f52.google.com with SMTP id p65so38506084wmp.0
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 09:37:59 -0800 (PST)
In-Reply-To: <1457630961-2809690-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2016 at 9:29 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> Per RFC4898, they count segments sent/received
> containing a positive length data segment (that includes
> retransmission segments carrying data).  Unlike
> tcpi_segs_out/in, tcpi_data_segs_out/in excludes segments
> carrying no data (e.g. pure ack).
>
> The patch also updates the segs_in in tcp_fastopen_add_skb()
> so that segs_in >= data_segs_in property is kept.  If
> tcp_segs_in() helper is used in this fastopen case, tp->segs_in
> has to be 0 reset first to avoid double counting.  Also, it has
> to be done before __skb_pull(skb, tcp_hdrlen(skb)) while
> there is no need to check skb->len since skb has already
> been confirmed carrying data.  I found it more confusing
> and chose to directly set segs_in and data_segs_in in
> this special case.
>
> Together with retransmission data, tcpi_data_segs_out
> gives a better signal on the rxmit rate.
>
> v4: Add comment to the changes in tcp_fastopen_add_skb()
> and also add remark on this case in the commit message.
>
> v3: Add const modifier to the skb parameter in tcp_segs_in()
>
> v2: Rework based on recent fix by Eric:
> commit a9d99ce28ed3 ("tcp: fix tcpi_segs_in after connection establishment")
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Cc: Chris Rapier <rapier@psc.edu>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
Acked-by: Yuchung Cheng <ycheng@google.com>

Thanks for the clarification.

>  include/linux/tcp.h      |  6 ++++++
>  include/net/tcp.h        | 10 ++++++++++
>  include/uapi/linux/tcp.h |  2 ++
>  net/ipv4/tcp.c           |  2 ++
>  net/ipv4/tcp_fastopen.c  | 10 ++++++++++
>  net/ipv4/tcp_ipv4.c      |  2 +-
>  net/ipv4/tcp_minisocks.c |  2 +-
>  net/ipv4/tcp_output.c    |  4 +++-
>  net/ipv6/tcp_ipv6.c      |  2 +-
>  9 files changed, 36 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index bcbf51d..7be9b12 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -158,6 +158,9 @@ struct tcp_sock {
>         u32     segs_in;        /* RFC4898 tcpEStatsPerfSegsIn
>                                  * total number of segments in.
>                                  */
> +       u32     data_segs_in;   /* RFC4898 tcpEStatsPerfDataSegsIn
> +                                * total number of data segments in.
> +                                */
>         u32     rcv_nxt;        /* What we want to receive next         */
>         u32     copied_seq;     /* Head of yet unread data              */
>         u32     rcv_wup;        /* rcv_nxt on last window update sent   */
> @@ -165,6 +168,9 @@ struct tcp_sock {
>         u32     segs_out;       /* RFC4898 tcpEStatsPerfSegsOut
>                                  * The total number of segments sent.
>                                  */
> +       u32     data_segs_out;  /* RFC4898 tcpEStatsPerfDataSegsOut
> +                                * total number of data segments sent.
> +                                */
>         u64     bytes_acked;    /* RFC4898 tcpEStatsAppHCThruOctetsAcked
>                                  * sum(delta(snd_una)), or how many bytes
>                                  * were acked.
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index e90db85..24557a8 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1816,4 +1816,14 @@ static inline void skb_set_tcp_pure_ack(struct sk_buff *skb)
>         skb->truesize = 2;
>  }
>
> +static inline void tcp_segs_in(struct tcp_sock *tp, const struct sk_buff *skb)
> +{
> +       u16 segs_in;
> +
> +       segs_in = max_t(u16, 1, skb_shinfo(skb)->gso_segs);
> +       tp->segs_in += segs_in;
> +       if (skb->len > tcp_hdrlen(skb))
> +               tp->data_segs_in += segs_in;
> +}
> +
>  #endif /* _TCP_H */
> diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
> index fe95446..53e8e3f 100644
> --- a/include/uapi/linux/tcp.h
> +++ b/include/uapi/linux/tcp.h
> @@ -199,6 +199,8 @@ struct tcp_info {
>
>         __u32   tcpi_notsent_bytes;
>         __u32   tcpi_min_rtt;
> +       __u32   tcpi_data_segs_in;      /* RFC4898 tcpEStatsDataSegsIn */
> +       __u32   tcpi_data_segs_out;     /* RFC4898 tcpEStatsDataSegsOut */
>  };
>
>  /* for TCP_MD5SIG socket option */
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index f9faadb..6b01b48 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2728,6 +2728,8 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
>         info->tcpi_notsent_bytes = max(0, notsent_bytes);
>
>         info->tcpi_min_rtt = tcp_min_rtt(tp);
> +       info->tcpi_data_segs_in = tp->data_segs_in;
> +       info->tcpi_data_segs_out = tp->data_segs_out;
>  }
>  EXPORT_SYMBOL_GPL(tcp_get_info);
>
> diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
> index fdb286d..74068e6 100644
> --- a/net/ipv4/tcp_fastopen.c
> +++ b/net/ipv4/tcp_fastopen.c
> @@ -131,6 +131,7 @@ static bool tcp_fastopen_cookie_gen(struct request_sock *req,
>  void tcp_fastopen_add_skb(struct sock *sk, struct sk_buff *skb)
>  {
>         struct tcp_sock *tp = tcp_sk(sk);
> +       u16 segs_in;
>
>         if (TCP_SKB_CB(skb)->end_seq == tp->rcv_nxt)
>                 return;
> @@ -154,6 +155,15 @@ void tcp_fastopen_add_skb(struct sock *sk, struct sk_buff *skb)
>          * as we certainly are not changing upper 32bit value (0)
>          */
>         tp->bytes_received = skb->len;
> +       /* If tcp_segs_in() is used, we need
> +        * to reset segs_in = 0 first to avoid double counting.
> +        * Hence, segs_in and data_segs_in are direclty set here.
> +        * Also, there is no need to check the skb->len as tcp_segs_in()
> +        * does because skb is confirmed carrying data here.
> +        */
> +       segs_in = max_t(u16, 1, skb_shinfo(skb)->gso_segs);
> +       tp->segs_in = segs_in;
> +       tp->data_segs_in = segs_in;
>
>         if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
>                 tcp_fin(sk);
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 4c8d58d..0b02ef7 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1650,7 +1650,7 @@ process:
>         sk_incoming_cpu_update(sk);
>
>         bh_lock_sock_nested(sk);
> -       tcp_sk(sk)->segs_in += max_t(u16, 1, skb_shinfo(skb)->gso_segs);
> +       tcp_segs_in(tcp_sk(sk), skb);
>         ret = 0;
>         if (!sock_owned_by_user(sk)) {
>                 if (!tcp_prequeue(sk, skb))
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index ae90e4b..acb366d 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -812,7 +812,7 @@ int tcp_child_process(struct sock *parent, struct sock *child,
>         int ret = 0;
>         int state = child->sk_state;
>
> -       tcp_sk(child)->segs_in += max_t(u16, 1, skb_shinfo(skb)->gso_segs);
> +       tcp_segs_in(tcp_sk(child), skb);
>         if (!sock_owned_by_user(child)) {
>                 ret = tcp_rcv_state_process(child, skb);
>                 /* Wakeup parent, send SIGIO */
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 7d2c7a4..7d2dc01 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1003,8 +1003,10 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
>         if (likely(tcb->tcp_flags & TCPHDR_ACK))
>                 tcp_event_ack_sent(sk, tcp_skb_pcount(skb));
>
> -       if (skb->len != tcp_header_size)
> +       if (skb->len != tcp_header_size) {
>                 tcp_event_data_sent(tp, sk);
> +               tp->data_segs_out += tcp_skb_pcount(skb);
> +       }
>
>         if (after(tcb->end_seq, tp->snd_nxt) || tcb->seq == tcb->end_seq)
>                 TCP_ADD_STATS(sock_net(sk), TCP_MIB_OUTSEGS,
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 33f2820..9c16565 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1443,7 +1443,7 @@ process:
>         sk_incoming_cpu_update(sk);
>
>         bh_lock_sock_nested(sk);
> -       tcp_sk(sk)->segs_in += max_t(u16, 1, skb_shinfo(skb)->gso_segs);
> +       tcp_segs_in(tcp_sk(sk), skb);
>         ret = 0;
>         if (!sock_owned_by_user(sk)) {
>                 if (!tcp_prequeue(sk, skb))
> --
> 2.5.1
>
