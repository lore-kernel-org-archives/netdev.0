From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: add tcpi_segs_in and tcpi_segs_out to tcp_info
Date: Thu, 21 May 2015 12:41:21 -0700
Message-ID: <CAK6E8=ebJDpUZeM=JHmqxgjcFEr1WLee2UeaKUjPg5vQwVL0tA@mail.gmail.com>
References: <1430260098-14127-1-git-send-email-edumazet@google.com>
 <20150512130855.GA29412@localhost.localdomain> <1431462713.566.95.camel@edumazet-glaptop2.roam.corp.google.com>
 <1432164941.4060.57.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Matt Mathis <mattmathis@google.com>,
	Craig Gallek <cgallek@google.com>, Martin Lau <kafai@fb.com>,
	Chris Rapier <rapier@psc.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:36168 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076AbbEUTmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 15:42:03 -0400
Received: by oihb142 with SMTP id b142so6573634oih.3
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 12:42:01 -0700 (PDT)
In-Reply-To: <1432164941.4060.57.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2015 at 4:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Marcelo Ricardo Leitner <mleitner@redhat.com>
>
> This patch tracks the total number of inbound and outbound segments on a
> TCP socket. One may use this number to have an idea on connection
> quality when compared against the retransmissions.
>
> RFC4898 named these : tcpEStatsPerfSegsIn and tcpEStatsPerfSegsOut
>
> These are a 32bit field each and can be fetched both from TCP_INFO
> getsockopt() if one has a handle on a TCP socket, or from inet_diag
> netlink facility (iproute2/ss patch will follow)
>
> Note that tp->segs_out was placed near tp->snd_nxt for good data
> locality and minimal performance impact, while tp->segs_in was placed
> near tp->bytes_received for the same reason.
>
> Join work with Eric Dumazet.
>
> Note that received SYN are accounted on the listener, but sent SYNACK
> are not accounted.
>
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/linux/tcp.h      |    7 ++++++-
>  include/uapi/linux/tcp.h |    4 +++-
>  net/ipv4/tcp.c           |    2 ++
>  net/ipv4/tcp_ipv4.c      |    1 +
>  net/ipv4/tcp_minisocks.c |    1 +
>  net/ipv4/tcp_output.c    |    1 +
>  net/ipv6/tcp_ipv6.c      |    1 +
>  7 files changed, 15 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index e6fb5df22db1fb3a2a902581d958e6d4881b399b..f0212026c77fc1d74db96c0312fe9892f56c2a64 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -149,11 +149,16 @@ struct tcp_sock {
>                                  * sum(delta(rcv_nxt)), or how many bytes
>                                  * were acked.
>                                  */
> +       u32     segs_in;        /* RFC4898 tcpEStatsPerfSegsIn
> +                                * total number of segments in.
> +                                */
>         u32     rcv_nxt;        /* What we want to receive next         */
>         u32     copied_seq;     /* Head of yet unread data              */
>         u32     rcv_wup;        /* rcv_nxt on last window update sent   */
>         u32     snd_nxt;        /* Next sequence we send                */
> -
> +       u32     segs_out;       /* RFC4898 tcpEStatsPerfSegsOut
> +                                * The total number of segments sent.
> +                                */
>         u64     bytes_acked;    /* RFC4898 tcpEStatsAppHCThruOctetsAcked
>                                  * sum(delta(snd_una)), or how many bytes
>                                  * were acked.
> diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
> index 51ebedba577f36e75b9aefd1cdf9e191f47f734f..65a77b071e22bec39225799e808b44b35bb1910c 100644
> --- a/include/uapi/linux/tcp.h
> +++ b/include/uapi/linux/tcp.h
> @@ -192,8 +192,10 @@ struct tcp_info {
>
>         __u64   tcpi_pacing_rate;
>         __u64   tcpi_max_pacing_rate;
> -       __u64   tcpi_bytes_acked; /* RFC4898 tcpEStatsAppHCThruOctetsAcked */
> +       __u64   tcpi_bytes_acked;    /* RFC4898 tcpEStatsAppHCThruOctetsAcked */
>         __u64   tcpi_bytes_received; /* RFC4898 tcpEStatsAppHCThruOctetsReceived */
> +       __u32   tcpi_segs_out;       /* RFC4898 tcpEStatsPerfSegsOut */
> +       __u32   tcpi_segs_in;        /* RFC4898 tcpEStatsPerfSegsIn */
>  };
>
>  /* for TCP_MD5SIG socket option */
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index bb9bb844204f9f0cf9197fe323f287dce5e5bbd9..f283aba62cf313651f54f0e63448e89e4bafa689 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2686,6 +2686,8 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
>         spin_lock_bh(&sk->sk_lock.slock);
>         info->tcpi_bytes_acked = tp->bytes_acked;
>         info->tcpi_bytes_received = tp->bytes_received;
> +       info->tcpi_segs_out = tp->segs_out;
> +       info->tcpi_segs_in = tp->segs_in;
>         spin_unlock_bh(&sk->sk_lock.slock);
>  }
>  EXPORT_SYMBOL_GPL(tcp_get_info);
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 0cc4b5a630cd49c60ea0767debf4ee171f41ad3e..feb875769b8d57dcdb85e12b782f3f5e0fb6193a 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1626,6 +1626,7 @@ process:
>         skb->dev = NULL;
>
>         bh_lock_sock_nested(sk);
> +       tcp_sk(sk)->segs_in += max_t(u16, 1, skb_shinfo(skb)->gso_segs);
>         ret = 0;
>         if (!sock_owned_by_user(sk)) {
>                 if (!tcp_prequeue(sk, skb))
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index ebe2ab2596ed3c2fbd27ecb3bf6f6b66c9e06e08..b62d15c8694679ed8688ab628f7edeb0b065dfe8 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -448,6 +448,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
>
>                 newtp->rcv_wup = newtp->copied_seq =
>                 newtp->rcv_nxt = treq->rcv_isn + 1;
> +               newtp->segs_in = 0;
It'd be nice to count SYN and SYNACKs for apps tracking the handshake stats.
For syn-cookies we can't do much. But for the rest we can account
req->num_retrans for SYN-ACKs sent, and perhaps track SYN received in
request sock?

>
>                 newtp->snd_sml = newtp->snd_una =
>                 newtp->snd_nxt = newtp->snd_up = treq->snt_isn + 1;
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index e29d43b5a0bb46305b0ab4af29bd05a61abd522d..e19594ac540a5c6091c43afc30c7510287260968 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1027,6 +1027,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
>                 TCP_ADD_STATS(sock_net(sk), TCP_MIB_OUTSEGS,
>                               tcp_skb_pcount(skb));
>
> +       tp->segs_out += tcp_skb_pcount(skb);
>         /* OK, its time to fill skb_shinfo(skb)->gso_segs */
>         skb_shinfo(skb)->gso_segs = tcp_skb_pcount(skb);
>
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index b6575d6655681e8e84993a5db929c7309d47d4d3..beac6bf840b9a9d1e2f281d2b1c71b5a3414b824 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1421,6 +1421,7 @@ process:
>         skb->dev = NULL;
>
>         bh_lock_sock_nested(sk);
> +       tcp_sk(sk)->segs_in += max_t(u16, 1, skb_shinfo(skb)->gso_segs);
some helper like e.g. tcp_event_pkt_recv() for v4/v6?
i am curious why use max instead of the ternary op?

>         ret = 0;
>         if (!sock_owned_by_user(sk)) {
>                 if (!tcp_prequeue(sk, skb))
>
>
