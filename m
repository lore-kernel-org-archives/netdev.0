From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/3] Revert Backoff [v3]: Calculate TCP's connection
 close threshold as a time value.
Date: Mon, 31 Aug 2009 16:26:10 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.0908311555230.29341@wel-95.cs.helsinki.fi>
References: <4A950B82.1070807@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-1750292372-1251724786=:29341"
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39596 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbZHaN0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 09:26:09 -0400
In-Reply-To: <4A950B82.1070807@tvk.rwth-aachen.de>
Content-ID: <alpine.DEB.2.00.0908311623320.29341@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1750292372-1251724786=:29341
Content-Type: TEXT/PLAIN; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0908311623321.29341@wel-95.cs.helsinki.fi>

On Wed, 26 Aug 2009, Damian Lukowski wrote:

> RFC 1122 specifies two threshold values R1 and R2 for connection timeouts,
> which may represent a number of allowed retransmissions or a timeout value.
> Currently linux uses sysctl_tcp_retries{1,2} to specify the thresholds
> in number of allowed retransmissions.
>
> For any desired threshold R2 (by means of time) one can specify tcp_retries2
> (by means of number of retransmissions) such that TCP will not time out
> earlier than R2. This is the case, because the RTO schedule follows a fixed
> pattern, namely exponential backoff.
>
> However, the RTO behaviour is not predictable any more if RTO backoffs can be
> reverted, as it is the case in the draft
> "Make TCP more Robust to Long Connectivity Disruptions"
> (http://tools.ietf.org/html/draft-zimmermann-tcp-lcd).
>
> In the worst case TCP would time out a connection after 3.2 seconds, if the
> initial RTO equaled MIN_RTO and each backoff has been reverted.
>
> This patch introduces a function retransmits_timed_out(N),
> which calculates the timeout of a TCP connection, assuming an initial
> RTO of MIN_RTO and N unsuccessful, exponentially backed-off retransmissions.
>
> Whenever timeout decisions are made by comparing the retransmission counter
> to some value N, this function can be used, instead.
>
> The meaning of tcp_retries2 will be changed, as many more RTO retransmissions
> can occur than the value indicates. However, it yields a timeout which is
> similar to the one of an unpatched, exponentially backing off TCP in the same
> scenario. As no application could rely on an RTO greater than MIN_RTO, there
> should be no risk of a regression.
>
> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
> ---
> include/net/tcp.h    |   18 ++++++++++++++++++
> net/ipv4/tcp_timer.c |   11 +++++++----
> 2 files changed, 25 insertions(+), 4 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index c35b329..17d1a88 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1247,6 +1247,24 @@ static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, struct sk_bu
> #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
> 	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
>

IMHO, having an introductionary comment here wouldn't hurt as this is a 
bit tricky thing we end up doing here :-).

> +static inline bool retransmits_timed_out(const struct sock *sk,
> +					 unsigned int boundary)
> +{
> +	int limit, K;

An empty line after local variables. Just rename the K to max_backoff or 
something like that (more meaningful).

> +	if (!inet_csk(sk)->icsk_retransmits)
> +		return false;
> +
> +	K = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
> +
> +	if (boundary <= K)
> +		limit = ((2 << boundary) - 1) * TCP_RTO_MIN;
> +	else
> +		limit = ((2 << K) - 1) * TCP_RTO_MIN +
> +			(boundary - K) * TCP_RTO_MAX;
> +
> +	return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >= limit;
> +}
> +
> static inline struct sk_buff *tcp_send_head(struct sock *sk)
> {
> 	return sk->sk_send_head;
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index a3ba494..2972d7b 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -137,13 +137,14 @@ static int tcp_write_timeout(struct sock *sk)
> {
> 	struct inet_connection_sock *icsk = inet_csk(sk);
> 	int retry_until;
> +	bool do_reset;
>
> 	if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
> 		if (icsk->icsk_retransmits)
> 			dst_negative_advice(&sk->sk_dst_cache);
> 		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
> 	} else {
> -		if (icsk->icsk_retransmits >= sysctl_tcp_retries1) {
> +		if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
> 			/* Black hole detection */
> 			tcp_mtu_probing(icsk, sk);
>
> @@ -155,13 +156,15 @@ static int tcp_write_timeout(struct sock *sk)
> 			const int alive = (icsk->icsk_rto < TCP_RTO_MAX);
>
> 			retry_until = tcp_orphan_retries(sk, alive);
> +			do_reset = alive ||
> +				   !retransmits_timed_out(sk, retry_until);
>
> -			if (tcp_out_of_resources(sk, alive || icsk->icsk_retransmits < retry_until))
> +			if (tcp_out_of_resources(sk, do_reset))
> 				return 1;
> 		}
> 	}
>
> -	if (icsk->icsk_retransmits >= retry_until) {
> +	if (retransmits_timed_out(sk, retry_until)) {
> 		/* Has it gone just too far? */
> 		tcp_write_err(sk);
> 		return 1;
> @@ -385,7 +388,7 @@ void tcp_retransmit_timer(struct sock *sk)
> out_reset_timer:
> 	icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
> 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
> -	if (icsk->icsk_retransmits > sysctl_tcp_retries1)
> +	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1))
> 		__sk_dst_reset(sk);
>
> out:;

The implementation itself seems ok. I was a bit concerned that the use of 
retrans_stamp would result in considerably different behavior than the use 
of icsk_retransmits but it seems I was wrong.

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

I'm fine with this approach as no matter what we would do the previous 
approach just isn't fitting the new model that breaks the assumptions 
behind the previous model. I don't expect the change in the timing to be 
significant for anybody unless one did copy our code exactly somewhere 
(including rtt calculation). ...but if somebody has some objections in 
this, please speak up! After all, it will change how the sysctl behaves.

Perhaps we should mention this artificial timing change in 
ip-sysctl.txt too...?

It would be worth to do a trivial pull-the-plug testing comparing this and 
the previous approach in the rto < TCP_RTO_MIN region without any icmps to 
verify that this didn't change the timing a bit, afaict, it shouldn't (If 
you didn't do that already). Just to be on very sure grounds.


-- 
  i.
--8323329-1750292372-1251724786=:29341--
