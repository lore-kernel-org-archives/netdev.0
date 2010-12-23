From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: cleanup of cwnd initialization in
 tcp_init_metrics()
Date: Thu, 23 Dec 2010 09:24:31 +0100
Message-ID: <1293092671.2679.44.camel@edumazet-laptop>
References: <alpine.LNX.2.00.1012221938030.16569@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vojtech Pavlik <vojtech@suse.cz>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35631 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924Ab0LWIYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 03:24:37 -0500
In-Reply-To: <alpine.LNX.2.00.1012221938030.16569@pobox.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 19:39 +0100, Jiri Kosina a =C3=
=A9crit :
> Commit 86bcebafc5e7f5 ("tcp: fix >2 iw selection") fixed a case when=20
> congestion window initialization has been mistakenly omitted by=20
> introducing cwnd label and putting backwards jump from the end of the=
=20
> function.
>=20
> This makes the code unnecessarily tricky to read and understand on a =
first=20
> sight.
>=20
> Shuffle the code around a little bit to make it more obvious.

Well in fine you have

	if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->rx_opt.saw_tstam=
p)
		goto reset;
	goto out;
reset:

Is that really more obvious ? ;)

>=20
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---
>  net/ipv4/tcp_input.c |   10 ++++------
>  1 files changed, 4 insertions(+), 6 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 6d8ab1c..dddff6d 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -915,11 +915,7 @@ static void tcp_init_metrics(struct sock *sk)
>  	if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->rx_opt.saw_ts=
tamp)
>  		goto reset;
> =20
> -cwnd:
> -	tp->snd_cwnd =3D tcp_init_cwnd(tp, dst);
> -	tp->snd_cwnd_stamp =3D tcp_time_stamp;
> -	return;
> -
> +	goto out;
>  reset:
>  	/* Play conservative. If timestamps are not
>  	 * supported, TCP will fail to recalculate correct
> @@ -930,7 +926,9 @@ reset:
>  		tp->mdev =3D tp->mdev_max =3D tp->rttvar =3D TCP_TIMEOUT_INIT;
>  		inet_csk(sk)->icsk_rto =3D TCP_TIMEOUT_INIT;
>  	}
> -	goto cwnd;
> +out:
> +	tp->snd_cwnd =3D tcp_init_cwnd(tp, dst);
> +	tp->snd_cwnd_stamp =3D tcp_time_stamp;
>  }
> =20
>  static void tcp_update_reordering(struct sock *sk, const int metric,




