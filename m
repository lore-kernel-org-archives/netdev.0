From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] TCP: avoid to send keepalive probes if it is
 receiving data
Date: Sun, 18 Apr 2010 19:15:19 +0200
Message-ID: <1271610919.16881.5564.camel@edumazet-laptop>
References: <1271581560.16881.4769.camel@edumazet-laptop>
	 <1271602519-6805-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:61189 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754796Ab0DRRP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 13:15:29 -0400
Received: by bwz25 with SMTP id 25so4673372bwz.28
        for <netdev@vger.kernel.org>; Sun, 18 Apr 2010 10:15:27 -0700 (PDT)
In-Reply-To: <1271602519-6805-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 18 avril 2010 =C3=A0 11:55 -0300, Flavio Leitner a =C3=A9cr=
it :
> RFC 1122 says the following:
> ...
>   Keep-alive packets MUST only be sent when no data or
>   acknowledgement packets have been received for the
>   connection within an interval.
> ...
>=20
> Fix this by storing the timestamp of last received data
> packet and checking for it when the keepalive timer expires.
>=20
> -v2 fix do_tcp_setsockopt() as pointed by Eric Dumazet <eric.dumazet@=
gmail.com>
>=20
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>


I find this patch very welcome, and we could easily use this new
lrcvtime information available in diagnostic tools (ss command)

But are you sure you update it for all valid packets ?

If we receive a pure ACK, it seems you do not ...



> ---
>  include/linux/tcp.h  |    1 +
>  net/ipv4/tcp.c       |    5 ++++-
>  net/ipv4/tcp_input.c |    3 +++
>  net/ipv4/tcp_timer.c |    8 ++++++++
>  4 files changed, 16 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index a778ee0..405678f 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -314,6 +314,7 @@ struct tcp_sock {
>   	u32	snd_sml;	/* Last byte of the most recently transmitted small p=
acket */
>  	u32	rcv_tstamp;	/* timestamp of last received ACK (for keepalives) =
*/
>  	u32	lsndtime;	/* timestamp of last sent data packet (for restart wi=
ndow) */
> +	u32	lrcvtime;	/* timestamp of last received data packet (for keepal=
ives) */
> =20
>  	/* Data for direct copy to user */
>  	struct {
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 0f8caf6..a4048d7 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2298,7 +2298,10 @@ static int do_tcp_setsockopt(struct sock *sk, =
int level,
>  			if (sock_flag(sk, SOCK_KEEPOPEN) &&
>  			    !((1 << sk->sk_state) &
>  			      (TCPF_CLOSE | TCPF_LISTEN))) {
> -				__u32 elapsed =3D tcp_time_stamp - tp->rcv_tstamp;
> +				u32 elapsed =3D min_t(u32,
> +						      tcp_time_stamp - tp->rcv_tstamp,
> +						      tcp_time_stamp - tp->lrcvtime);
> +
>  				if (tp->keepalive_time > elapsed)
>  					elapsed =3D tp->keepalive_time - elapsed;
>  				else
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index f240f57..60d2980 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -5391,6 +5391,8 @@ no_ack:
>  				__kfree_skb(skb);
>  			else
>  				sk->sk_data_ready(sk, 0);
> +
> +			tp->lrcvtime =3D tcp_time_stamp;
>  			return 0;
>  		}
>  	}
> @@ -5421,6 +5423,7 @@ step5:
> =20
>  	tcp_data_snd_check(sk);
>  	tcp_ack_snd_check(sk);
> +	tp->lrcvtime =3D tcp_time_stamp;
>  	return 0;
> =20
>  csum_error:
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index 8a0ab29..74dd804 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -554,6 +554,14 @@ static void tcp_keepalive_timer (unsigned long d=
ata)
>  	if (tp->packets_out || tcp_send_head(sk))
>  		goto resched;
> =20
> +	elapsed =3D tcp_time_stamp - tp->lrcvtime;
> +=09
> +	/* receiving data means alive */
> +	if (elapsed < keepalive_time_when(tp)) {
> +		elapsed =3D keepalive_time_when(tp) - elapsed;
> +		goto resched;
> +	}
> +
>  	elapsed =3D tcp_time_stamp - tp->rcv_tstamp;
> =20
>  	if (elapsed >=3D keepalive_time_when(tp)) {


