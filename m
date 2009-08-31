From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/3] Revert Backoff [v3]: Revert RTO on ICMP destination
 unreachable
Date: Mon, 31 Aug 2009 16:23:31 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.0908311619580.29341@wel-95.cs.helsinki.fi>
References: <4A950B7F.6000702@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-1121907741-1251724928=:29341"
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38752 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408AbZHaNX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 09:23:29 -0400
In-Reply-To: <4A950B7F.6000702@tvk.rwth-aachen.de>
Content-ID: <alpine.DEB.2.00.0908311623010.29341@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1121907741-1251724928=:29341
Content-Type: TEXT/PLAIN; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0908311623011.29341@wel-95.cs.helsinki.fi>

On Wed, 26 Aug 2009, Damian Lukowski wrote:

> Here, an ICMP host/network unreachable message, whose payload fits to
> TCP's SND.UNA, is taken as an indication that the RTO retransmission has
> not been lost due to congestion, but because of a route failure
> somewhere along the path.
> With true congestion, a router won't trigger such a message and the
> patched TCP will operate as standard TCP.
>
> This patch reverts one RTO backoff, if an ICMP host/network unreachable
> message, whose payload fits to TCP's SND.UNA, arrives.
> Based on the new RTO, the retransmission timer is reset to reflect the
> remaining time, or - if the revert clocked out the timer - a retransmission
> is sent out immediately.
> Backoffs are only reverted, if TCP is in RTO loss recovery, i.e. if
> there have been retransmissions and reversible backoffs, already.
>
> Changes from v2:
> 1) Renaming of skb in tcp_v4_err() moved to another patch.
> 2) Reintroduced tcp_bound_rto() and __tcp_set_rto().
> 3) Fixed code comments.
>
> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
> ---
> include/net/tcp.h    |   12 ++++++++++++
> net/ipv4/tcp_input.c |    5 ++---
> net/ipv4/tcp_ipv4.c  |   37 +++++++++++++++++++++++++++++++++++++
> net/ipv4/tcp_timer.c |    2 +-
> 4 files changed, 52 insertions(+), 4 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 88af843..c35b329 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -469,6 +469,7 @@ extern void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
> 				      int nonagle);
> extern int tcp_may_send_now(struct sock *sk);
> extern int tcp_retransmit_skb(struct sock *, struct sk_buff *);
> +extern void tcp_retransmit_timer(struct sock *sk);
> extern void tcp_xmit_retransmit_queue(struct sock *);
> extern void tcp_simple_retransmit(struct sock *);
> extern int tcp_trim_head(struct sock *, struct sk_buff *, u32);
> @@ -521,6 +522,17 @@ extern int tcp_mtu_to_mss(struct sock *sk, int pmtu);
> extern int tcp_mss_to_mtu(struct sock *sk, int mss);
> extern void tcp_mtup_init(struct sock *sk);
>
> +static inline void tcp_bound_rto(const struct sock *sk)
> +{
> +	if (inet_csk(sk)->icsk_rto > TCP_RTO_MAX)
> +		inet_csk(sk)->icsk_rto = TCP_RTO_MAX;
> +}
> +
> +static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
> +{
> +	return (tp->srtt >> 3) + tp->rttvar;
> +}
> +
> static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
> {
> 	tp->pred_flags = htonl((tp->tcp_header_len << 26) |
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 2bdb0da..af6d6fa 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -685,7 +685,7 @@ static inline void tcp_set_rto(struct sock *sk)
> 	 *    is invisible. Actually, Linux-2.4 also generates erratic
> 	 *    ACKs in some circumstances.
> 	 */
> -	inet_csk(sk)->icsk_rto = (tp->srtt >> 3) + tp->rttvar;
> +	inet_csk(sk)->icsk_rto = __tcp_set_rto(tp);
>
> 	/* 2. Fixups made earlier cannot be right.
> 	 *    If we do not estimate RTO correctly without them,
> @@ -696,8 +696,7 @@ static inline void tcp_set_rto(struct sock *sk)
> 	/* NOTE: clamping at TCP_RTO_MIN is not required, current algo
> 	 * guarantees that rto is higher.
> 	 */
> -	if (inet_csk(sk)->icsk_rto > TCP_RTO_MAX)
> -		inet_csk(sk)->icsk_rto = TCP_RTO_MAX;
> +	tcp_bound_rto(sk);
> }
>
> /* Save metrics learned by this TCP session.
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 6ca1bc8..6755e29 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -332,12 +332,15 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
> {
> 	struct iphdr *iph = (struct iphdr *)icmp_skb->data;
> 	struct tcphdr *th = (struct tcphdr *)(icmp_skb->data + (iph->ihl << 2));
> +	struct inet_connection_sock *icsk;
> 	struct tcp_sock *tp;
> 	struct inet_sock *inet;
> 	const int type = icmp_hdr(icmp_skb)->type;
> 	const int code = icmp_hdr(icmp_skb)->code;
> 	struct sock *sk;
> +	struct sk_buff *skb;
> 	__u32 seq;
> +	__u32 remaining;
> 	int err;
> 	struct net *net = dev_net(icmp_skb->dev);
>
> @@ -367,6 +370,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
> 	if (sk->sk_state == TCP_CLOSE)
> 		goto out;
>
> +	icsk = inet_csk(sk);
> 	tp = tcp_sk(sk);
> 	seq = ntohl(th->seq);
> 	if (sk->sk_state != TCP_LISTEN &&
> @@ -393,6 +397,39 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
> 		}
>
> 		err = icmp_err_convert[code].errno;
> +		/* check if icmp_skb allows revert of backoff
> +		 * (see draft-zimmermann-tcp-lcd) */
> +		if (code != ICMP_NET_UNREACH && code != ICMP_HOST_UNREACH)
> +			break;
> +		if (seq != tp->snd_una  || !icsk->icsk_retransmits ||
> +		    !icsk->icsk_backoff)
> +			break;
> +
> +		icsk->icsk_backoff--;
> +		inet_csk(sk)->icsk_rto = __tcp_set_rto(tp) <<
> +					 icsk->icsk_backoff;
> +		tcp_bound_rto(sk);
> +
> +		skb = tcp_write_queue_head(sk);
> +		BUG_ON(!skb);
> +
> +		remaining = icsk->icsk_rto - min(icsk->icsk_rto,
> +				tcp_time_stamp - TCP_SKB_CB(skb)->when);
> +
> +		if (remaining) {
> +			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
> +						  remaining, TCP_RTO_MAX);
> +		} else if (sock_owned_by_user(sk)) {
> +			/* RTO revert clocked out retransmission,
> +			 * but socket is locked. Will defer. */
> +			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
> +						  HZ/20, TCP_RTO_MAX);
> +		} else {
> +			/* RTO revert clocked out retransmission.
> +			 * Will retransmit now */
> +			tcp_retransmit_timer(sk);
> +		}
> +
> 		break;
> 	case ICMP_TIME_EXCEEDED:
> 		err = EHOSTUNREACH;
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index b144a26..a3ba494 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -279,7 +279,7 @@ static void tcp_probe_timer(struct sock *sk)
>  *	The TCP retransmit timer.
>  */
>
> -static void tcp_retransmit_timer(struct sock *sk)
> +void tcp_retransmit_timer(struct sock *sk)
> {
> 	struct tcp_sock *tp = tcp_sk(sk);
> 	struct inet_connection_sock *icsk = inet_csk(sk);
>

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

-- 
  i.
--8323329-1121907741-1251724928=:29341--
