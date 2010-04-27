From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] TCP: avoid to send keepalive probes if receiving
 data
Date: Tue, 27 Apr 2010 07:06:51 +0200
Message-ID: <1272344811.4861.4.camel@edumazet-laptop>
References: <20100426.112422.246526700.davem@davemloft.net>
	 <1272342807-13379-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Ilpo <ilpo.jarvinen@helsinki.fi>
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:47012 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936Ab0D0FG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 01:06:57 -0400
Received: by bwz19 with SMTP id 19so127437bwz.21
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 22:06:56 -0700 (PDT)
In-Reply-To: <1272342807-13379-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 avril 2010 =C3=A0 01:33 -0300, Flavio Leitner a =C3=A9crit =
:
> RFC 1122 says the following:
> ...
>   Keep-alive packets MUST only be sent when no data or
>   acknowledgement packets have been received for the
>   connection within an interval.
> ...
>=20
> The acknowledgement packet is reseting the keepalive
> timer but the data packet isn't. This patch fixes it by
> checking the timestamp of the last received data packet
> too when the keepalive timer expires.
>=20
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> ---

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

>  include/net/tcp.h    |    8 ++++++++
>  net/ipv4/tcp.c       |    2 +-
>  net/ipv4/tcp_timer.c |    4 ++--
>  3 files changed, 11 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 75be5a2..305810e 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1032,6 +1032,14 @@ static inline int keepalive_probes(const struc=
t tcp_sock *tp)
>  	return tp->keepalive_probes ? : sysctl_tcp_keepalive_probes;
>  }
> =20
> +static inline u32 keepalive_time_elapsed(const struct tcp_sock *tp)
> +{
> +	const struct inet_connection_sock *icsk =3D &tp->inet_conn;
> +
> +	return min_t(u32, tcp_time_stamp - icsk->icsk_ack.lrcvtime,
> +			  tcp_time_stamp - tp->rcv_tstamp);
> +}
> +
>  static inline int tcp_fin_time(const struct sock *sk)
>  {
>  	int fin_timeout =3D tcp_sk(sk)->linger2 ? : sysctl_tcp_fin_timeout;
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 0f8caf6..48a6f33 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2298,7 +2298,7 @@ static int do_tcp_setsockopt(struct sock *sk, i=
nt level,
>  			if (sock_flag(sk, SOCK_KEEPOPEN) &&
>  			    !((1 << sk->sk_state) &
>  			      (TCPF_CLOSE | TCPF_LISTEN))) {
> -				__u32 elapsed =3D tcp_time_stamp - tp->rcv_tstamp;
> +				u32 elapsed =3D keepalive_time_elapsed(tp);
>  				if (tp->keepalive_time > elapsed)
>  					elapsed =3D tp->keepalive_time - elapsed;
>  				else
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index 8a0ab29..a9155f9 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -517,7 +517,7 @@ static void tcp_keepalive_timer (unsigned long da=
ta)
>  	struct sock *sk =3D (struct sock *) data;
>  	struct inet_connection_sock *icsk =3D inet_csk(sk);
>  	struct tcp_sock *tp =3D tcp_sk(sk);
> -	__u32 elapsed;
> +	u32 elapsed;
> =20
>  	/* Only process if socket is not in use. */
>  	bh_lock_sock(sk);
> @@ -554,7 +554,7 @@ static void tcp_keepalive_timer (unsigned long da=
ta)
>  	if (tp->packets_out || tcp_send_head(sk))
>  		goto resched;
> =20
> -	elapsed =3D tcp_time_stamp - tp->rcv_tstamp;
> +	elapsed =3D keepalive_time_elapsed(tp);
> =20
>  	if (elapsed >=3D keepalive_time_when(tp)) {
>  		if (icsk->icsk_probes_out >=3D keepalive_probes(tp)) {


