From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH v4] TCP: avoid to send keepalive probes if receiving
 data
Date: Tue, 27 Apr 2010 09:08:08 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1004270906320.13989@melkinpaasi.cs.helsinki.fi>
References: <20100426.112422.246526700.davem@davemloft.net> <1272342807-13379-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696250871-1557010612-1272348488=:13989"
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38027 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571Ab0D0GIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 02:08:10 -0400
In-Reply-To: <1272342807-13379-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696250871-1557010612-1272348488=:13989
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Tue, 27 Apr 2010, Flavio Leitner wrote:

> RFC 1122 says the following:
> ...
>   Keep-alive packets MUST only be sent when no data or
>   acknowledgement packets have been received for the
>   connection within an interval.
> ...
> 
> The acknowledgement packet is reseting the keepalive
> timer but the data packet isn't. This patch fixes it by
> checking the timestamp of the last received data packet
> too when the keepalive timer expires.
> 
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> ---
>  include/net/tcp.h    |    8 ++++++++
>  net/ipv4/tcp.c       |    2 +-
>  net/ipv4/tcp_timer.c |    4 ++--
>  3 files changed, 11 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 75be5a2..305810e 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1032,6 +1032,14 @@ static inline int keepalive_probes(const struct tcp_sock *tp)
>  	return tp->keepalive_probes ? : sysctl_tcp_keepalive_probes;
>  }
>  
> +static inline u32 keepalive_time_elapsed(const struct tcp_sock *tp)
> +{
> +	const struct inet_connection_sock *icsk = &tp->inet_conn;
> +
> +	return min_t(u32, tcp_time_stamp - icsk->icsk_ack.lrcvtime,
> +			  tcp_time_stamp - tp->rcv_tstamp);
> +}
> +
>  static inline int tcp_fin_time(const struct sock *sk)
>  {
>  	int fin_timeout = tcp_sk(sk)->linger2 ? : sysctl_tcp_fin_timeout;
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 0f8caf6..48a6f33 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2298,7 +2298,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>  			if (sock_flag(sk, SOCK_KEEPOPEN) &&
>  			    !((1 << sk->sk_state) &
>  			      (TCPF_CLOSE | TCPF_LISTEN))) {
> -				__u32 elapsed = tcp_time_stamp - tp->rcv_tstamp;
> +				u32 elapsed = keepalive_time_elapsed(tp);
>  				if (tp->keepalive_time > elapsed)
>  					elapsed = tp->keepalive_time - elapsed;
>  				else
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index 8a0ab29..a9155f9 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -517,7 +517,7 @@ static void tcp_keepalive_timer (unsigned long data)
>  	struct sock *sk = (struct sock *) data;
>  	struct inet_connection_sock *icsk = inet_csk(sk);
>  	struct tcp_sock *tp = tcp_sk(sk);
> -	__u32 elapsed;
> +	u32 elapsed;
>  
>  	/* Only process if socket is not in use. */
>  	bh_lock_sock(sk);
> @@ -554,7 +554,7 @@ static void tcp_keepalive_timer (unsigned long data)
>  	if (tp->packets_out || tcp_send_head(sk))
>  		goto resched;
>  
> -	elapsed = tcp_time_stamp - tp->rcv_tstamp;
> +	elapsed = keepalive_time_elapsed(tp);
>  
>  	if (elapsed >= keepalive_time_when(tp)) {
>  		if (icsk->icsk_probes_out >= keepalive_probes(tp)) {

Thanks. Looks very nice now.

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

-- 
 i.
---696250871-1557010612-1272348488=:13989--
