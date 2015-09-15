From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/2] tcp: provide skb->hash to synack packets
Date: Tue, 15 Sep 2015 16:29:07 -0700
Message-ID: <CALx6S36_me9ObP770SwRoZWfoFgaSW5uAXi8T-Ps=tyPh75ANw@mail.gmail.com>
References: <1442355860.4116.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32919 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbbIOX3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 19:29:08 -0400
Received: by iofh134 with SMTP id h134so20741428iof.0
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 16:29:07 -0700 (PDT)
In-Reply-To: <1442355860.4116.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2015 at 3:24 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> In commit b73c3d0e4f0e ("net: Save TX flow hash in sock and set in skbuf
> on xmit"), Tom provided a l4 hash to most outgoing TCP packets.
>
> We'd like to provide one as well for SYNACK packets, so that all packets
> of a given flow share same txhash, to later enable bonding driver to
> also use skb->hash to perform slave selection.
>
> Note that a SYNACK retransmit shuffles the tx hash, as Tom did
> in commit 265f94ff54d62 ("net: Recompute sk_txhash on negative routing
> advice") for established sockets.
>
> This has nice effect making TCP flows resilient to some kind of black
> holes, even at connection establish phase.
>
Acked-by: Tom Herbert <tom@herbertland.com>

> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> ---
>  include/linux/tcp.h   |    1 +
>  include/net/sock.h    |   12 ++++++++----
>  net/ipv4/tcp_input.c  |    1 +
>  net/ipv4/tcp_ipv4.c   |    2 +-
>  net/ipv4/tcp_output.c |    2 ++
>  net/ipv6/tcp_ipv6.c   |    2 +-
>  6 files changed, 14 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 48c3696..937b978 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -113,6 +113,7 @@ struct tcp_request_sock {
>         struct inet_request_sock        req;
>         const struct tcp_request_sock_ops *af_specific;
>         bool                            tfo_listener;
> +       u32                             txhash;
>         u32                             rcv_isn;
>         u32                             snt_isn;
>         u32                             snt_synack; /* synack sent time */
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 7aa7844..94dff7f 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1654,12 +1654,16 @@ static inline void sock_graft(struct sock *sk, struct socket *parent)
>  kuid_t sock_i_uid(struct sock *sk);
>  unsigned long sock_i_ino(struct sock *sk);
>
> -static inline void sk_set_txhash(struct sock *sk)
> +static inline u32 net_tx_rndhash(void)
>  {
> -       sk->sk_txhash = prandom_u32();
> +       u32 v = prandom_u32();
> +
> +       return v ?: 1;
> +}
>
> -       if (unlikely(!sk->sk_txhash))
> -               sk->sk_txhash = 1;
> +static inline void sk_set_txhash(struct sock *sk)
> +{
> +       sk->sk_txhash = net_tx_rndhash();
>  }
>
>  static inline void sk_rethink_txhash(struct sock *sk)
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index a8f515b..a62e9c7 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -6228,6 +6228,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
>         }
>
>         tcp_rsk(req)->snt_isn = isn;
> +       tcp_rsk(req)->txhash = net_tx_rndhash();
>         tcp_openreq_init_rwin(req, sk, dst);
>         fastopen = !want_cookie &&
>                    tcp_try_fastopen(sk, skb, req, &foc, dst);
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 93898e0..d671d74 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1276,8 +1276,8 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
>         newinet->mc_index     = inet_iif(skb);
>         newinet->mc_ttl       = ip_hdr(skb)->ttl;
>         newinet->rcv_tos      = ip_hdr(skb)->tos;
> +       newsk->sk_txhash      = tcp_rsk(req)->txhash;
>         inet_csk(newsk)->icsk_ext_hdr_len = 0;
> -       sk_set_txhash(newsk);
>         if (inet_opt)
>                 inet_csk(newsk)->icsk_ext_hdr_len = inet_opt->opt.optlen;
>         newinet->inet_id = newtp->write_seq ^ jiffies;
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index f9a8a12..d0ad355 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2987,6 +2987,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
>         rcu_read_lock();
>         md5 = tcp_rsk(req)->af_specific->req_md5_lookup(sk, req_to_sk(req));
>  #endif
> +       skb_set_hash(skb, tcp_rsk(req)->txhash, PKT_HASH_TYPE_L4);
>         tcp_header_size = tcp_synack_options(sk, req, mss, skb, &opts, md5,
>                                              foc) + sizeof(*th);
>
> @@ -3505,6 +3506,7 @@ int tcp_rtx_synack(struct sock *sk, struct request_sock *req)
>         struct flowi fl;
>         int res;
>
> +       tcp_rsk(req)->txhash = net_tx_rndhash();
>         res = af_ops->send_synack(sk, NULL, &fl, req, 0, NULL);
>         if (!res) {
>                 TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 97d9314..f9c0e26 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1090,7 +1090,7 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
>         newsk->sk_v6_rcv_saddr = ireq->ir_v6_loc_addr;
>         newsk->sk_bound_dev_if = ireq->ir_iif;
>
> -       sk_set_txhash(newsk);
> +       newsk->sk_txhash = tcp_rsk(req)->txhash;
>
>         /* Now IPv6 options...
>
>
>
