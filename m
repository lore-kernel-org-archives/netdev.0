From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] [TCP]: Fixes IW > 2 cases when TCP is application
 limited
Date: Thu, 3 Aug 2006 18:45:34 -0700
Message-ID: <20060803184534.1ecb8546@localhost.localdomain>
References: <11546407561210-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18363 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030280AbWHDBpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 21:45:47 -0400
To: Ilpo =?UTF-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
In-Reply-To: <11546407561210-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 04 Aug 2006 00:32:36 +0300
Ilpo  J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi> wrote:

> Whenever a transfer is application limited, we are allowed at least
> initial window worth of data per window unless cwnd is previously
> less than that.
>=20
> Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  net/ipv4/tcp_input.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 738dad9..104af5d 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3541,7 +3541,8 @@ void tcp_cwnd_application_limited(struct
>  	if (inet_csk(sk)->icsk_ca_state =3D=3D TCP_CA_Open &&
>  	    sk->sk_socket && !test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)=
) {
>  		/* Limited by application or receiver window. */
> -		u32 win_used =3D max(tp->snd_cwnd_used, 2U);
> +		u32 init_win =3D tcp_init_cwnd(tp, __sk_dst_get(sk));
> +		u32 win_used =3D max(tp->snd_cwnd_used, init_win);
>  		if (win_used < tp->snd_cwnd) {
>  			tp->snd_ssthresh =3D tcp_current_ssthresh(sk);
>  			tp->snd_cwnd =3D (tp->snd_cwnd + win_used) >> 1;

This looks correct.

Some code reorganization would help. This function is only called on th=
e
output side and could be moved over to tcp_output.c and made static.
This would allow for a greater possibility of compiler inlining (if it =
wants).
