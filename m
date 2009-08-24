From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCHv2] Revert TCP retransmission backoff on ICMP destination
 unreachable
Date: Mon, 24 Aug 2009 18:34:43 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.0908241808300.10654@wel-95.cs.helsinki.fi>
References: <4A928016.8090804@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1286246791-1251128083=:10654"
Cc: Netdev <netdev@vger.kernel.org>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41795 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532AbZHXPem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 11:34:42 -0400
In-Reply-To: <4A928016.8090804@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1286246791-1251128083=:10654
Content-Type: TEXT/PLAIN; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 8BIT

On Mon, 24 Aug 2009, Damian Lukowski wrote:

> This patch implements the TCP improvement of the Internet Draft
> "Make TCP more Robust to Long Connectivity Disruptions"
> (http://tools.ietf.org/html/draft-zimmermann-tcp-lcd-01).
>
> Exponential backoff is TCP's standard behaviour during long connectivity
> disruptions, which is a countermeasure against network congestion.
> If congestion can be excluded as the reason for RTO retransmission loss,
> backoff is not desirable, as it yields longer TCP recovery times, when
> the communication path is repaired shortly after an unsuccessful
> retransmission probe.
> Here, an ICMP host/network unreachable message, whose payload fits to
> TCP's SND.UNA, is taken as an indication that the RTO retransmission has
> not been lost due to congestion, but because of a route failure
> somewhere along the path. On receipt of such a message, the timeout is
> halved (in order to revert the doubling after the retransmission).
> With true congestion, a router won't trigger such a message and the
> patched TCP will operate as standard TCP.
>
> Changes from v1:
> 1) Calling tcp_retransmit_timer() instead tcp_retransmit_skb().
>   This fixes problems with SACK and a inconsistency with the draft.
> 2) If the socket is locked, retransmission is deferred by using the
>   formula as in tcp_write_timer().
> 3) Removed the sysctl_tcp_retries modifications, which will be
>   sent in a different patch request.
> 4) Recalculating the RTO from rtt, rttvar and icsk_backoff,
>   not simply halving. This prevents, that an RTO of RTO_MAX-epsilon
>   is "doubled" to RTO_MAX and then "reverted" to RTO_MAX/2 instead of
>   RTO_MAX-epsilon. Currently, this is not what the draft specifies,
>   but the draft will be changed accordingly.
> 5) Renamed skb to icmp_skb in tcp_v4_err in codebase code.
> 6) Different coding-style and indentation changes, as suggested
>   by Ilpo Järvinen.
> 7) Using net-next-2.6 git-branch as codebase.
>
> Thanks for the review, so far.
>
> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
> ---
> include/net/tcp.h    |    1 +
> net/ipv4/tcp_ipv4.c  |   54 ++++++++++++++++++++++++++++++++++++++++++-------
> net/ipv4/tcp_timer.c |    2 +-
> 3 files changed, 48 insertions(+), 9 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 88af843..58c5b39 100644
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
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 6d88219..d1d73ac 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -328,26 +328,29 @@ static void do_pmtu_discovery(struct sock *sk, struct iphdr *iph, u32 mtu)
>  *
>  */
>
> -void tcp_v4_err(struct sk_buff *skb, u32 info)
> +void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
> {
> -	struct iphdr *iph = (struct iphdr *)skb->data;
> -	struct tcphdr *th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
> +	struct iphdr *iph = (struct iphdr *)icmp_skb->data;
> +	struct tcphdr *th = (struct tcphdr *)(icmp_skb->data + (iph->ihl << 2));
> +	struct inet_connection_sock *icsk;
> 	struct tcp_sock *tp;
> 	struct inet_sock *inet;
> -	const int type = icmp_hdr(skb)->type;
> -	const int code = icmp_hdr(skb)->code;
> +	const int type = icmp_hdr(icmp_skb)->type;
> +	const int code = icmp_hdr(icmp_skb)->code;
> 	struct sock *sk;
> +	struct sk_buff *skb;
> 	__u32 seq;
> +	__u32 remaining;
> 	int err;
> -	struct net *net = dev_net(skb->dev);
> +	struct net *net = dev_net(icmp_skb->dev);
>
> -	if (skb->len < (iph->ihl << 2) + 8) {
> +	if (icmp_skb->len < (iph->ihl << 2) + 8) {
> 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
> 		return;
> 	}
>
> 	sk = inet_lookup(net, &tcp_hashinfo, iph->daddr, th->dest,
> -			iph->saddr, th->source, inet_iif(skb));
> +			iph->saddr, th->source, inet_iif(icmp_skb));
> 	if (!sk) {
> 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
> 		return;
> @@ -367,6 +370,7 @@ void tcp_v4_err(struct sk_buff *skb, u32 info)
> 	if (sk->sk_state == TCP_CLOSE)
> 		goto out;
>
> +	icsk = inet_csk(sk);
> 	tp = tcp_sk(sk);
> 	seq = ntohl(th->seq);
> 	if (sk->sk_state != TCP_LISTEN &&
> @@ -393,6 +397,40 @@ void tcp_v4_err(struct sk_buff *skb, u32 info)
> 		}
>
> 		err = icmp_err_convert[code].errno;
> +		/* check if ICMP unreach message allows revert of backoff */

Putting a reference to the ID here into the comment wouldn't hurt btw.

> +		if (code != ICMP_NET_UNREACH && code != ICMP_HOST_UNREACH)
> +			break;
> +		if (seq != tp->snd_una  || !icsk->icsk_retransmits ||
> +		    !icsk->icsk_backoff)
> +			break;
> +
> +		icsk->icsk_backoff--;
> +		inet_csk(sk)->icsk_rto = ((tp->srtt >> 3) + tp->rttvar) <<

Please create static inline u32 __tcp_set_rto(tp) into include/net/tcp.h 
for this RTO formula and call for that in the both places.

> +					 icsk->icsk_backoff;
> +		if (inet_csk(sk)->icsk_rto > TCP_RTO_MAX)
> +			inet_csk(sk)->icsk_rto = TCP_RTO_MAX;

Probably useful for this too to add back the tcp_bound_rto() into 
include/net/tcp.h and call instead of copy pasting (I recently removed 
it).

> +		skb = tcp_write_queue_head(sk);
> +		BUG_ON(!skb);
> +
> +		remaining = icsk->icsk_rto - min(icsk->icsk_rto,
> +				tcp_time_stamp - TCP_SKB_CB(skb)->when);
> +
> +		if (remaining) {
> +			/* RTO revert shortened timer. */

Not that useful comment; the same was said earlier already.

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

Other than that, it looks quite clean solution now. It would be nearly 
perfect if you could make that skb -> icmp_skb into a separate preparatory 
patch (1/3), the main change to 2/3 and then the most controversial 
stuff related to those retrans sysctl as 3/3, each with proper reasoning 
why it needs to be done (and not with the same subject but a summary of 
the particular change in question). ...And send them as a series.

-- 
  i.
--8323329-1286246791-1251128083=:10654--
