From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Sat, 17 Oct 2009 14:07:22 +0200
Message-ID: <4AD9B37A.3090606@gmail.com>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli> <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net> <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli> <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli> <20091016050310.GA5574@1wt.eu> <Pine.LNX.4.58.0910161137490.3886@u.domain.uli> <4AD84D8B.5020103@gmail.com> <Pine.LNX.4.58.0910171417260.7818@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42823 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbZJQMIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2009 08:08:01 -0400
In-Reply-To: <Pine.LNX.4.58.0910171417260.7818@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov a =E9crit :
>=20
> 	I tested both patches. It seems the current algorithm to
> convert seconds to retransmissions does not match well the TCP
> SYN-ACK timer and sometimes can convert the seconds to
> retransmissions which are 1 above the expected. For example,
> you set 9 seconds (expecting 2 retrans) but you get 3 retrans,
> visible with TCP_SYNCNT=3D1.
>=20
> 	Also, it is limited to period of 32 retransmissions.
>=20
> 	The following patch changes the TCP_DEFER_ACCEPT
> period calculation to match TCP SYN-ACK retransmissions and to
> help those folks who select the seconds with TCP SYN-ACK
> timing in mind. It also allows the retransmission threshold
> to be up to 255.
>=20
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
>=20
> diff -urp v2.6.31/linux/net/ipv4/tcp.c linux/net/ipv4/tcp.c
> --- v2.6.31/linux/net/ipv4/tcp.c	2009-09-11 10:27:17.000000000 +0300
> +++ linux/net/ipv4/tcp.c	2009-10-17 12:34:38.000000000 +0300
> @@ -2165,13 +2165,20 @@ static int do_tcp_setsockopt(struct sock
>  	case TCP_DEFER_ACCEPT:
>  		icsk->icsk_accept_queue.rskq_defer_accept =3D 0;
>  		if (val > 0) {
> +			int timeout =3D TCP_TIMEOUT_INIT / HZ;
> +			int period =3D timeout;
> +
>  			/* Translate value in seconds to number of
>  			 * retransmits */
> -			while (icsk->icsk_accept_queue.rskq_defer_accept < 32 &&
> -			       val > ((TCP_TIMEOUT_INIT / HZ) <<
> -				       icsk->icsk_accept_queue.rskq_defer_accept))
> +			icsk->icsk_accept_queue.rskq_defer_accept =3D 1;
> +			while (icsk->icsk_accept_queue.rskq_defer_accept < 255 &&
> +			       val > period) {
>  				icsk->icsk_accept_queue.rskq_defer_accept++;
> -			icsk->icsk_accept_queue.rskq_defer_accept++;
> +				timeout <<=3D 1;
> +				if (timeout > TCP_RTO_MAX / HZ)
> +					timeout =3D TCP_RTO_MAX / HZ;
> +				period +=3D timeout;
> +			}
>  		}
>  		break;
> =20
>=20
> 	FYI, the old algorithm selects the following retransmissions
> for the configured seconds:
>=20
> defer_accept=3D1 retrans for 1-3 secs
> defer_accept=3D2 retrans for 4-6 secs
> defer_accept=3D3 retrans for 7-12 secs
> defer_accept=3D4 retrans for 13-24 secs
> defer_accept=3D5 retrans for 25-48 secs
> defer_accept=3D6 retrans for 49-96 secs
> defer_accept=3D7 retrans for 97-192 secs
> defer_accept=3D8 retrans for 193-384 secs
>=20
> 	While the new algorithm is as follows:
>=20
> defer_accept=3D1 retrans for 1-3 secs
> defer_accept=3D2 retrans for 4-9 secs
> defer_accept=3D3 retrans for 10-21 secs
> defer_accept=3D4 retrans for 22-45 secs
> defer_accept=3D5 retrans for 46-93 secs
> defer_accept=3D6 retrans for 94-189 secs
> defer_accept=3D7 retrans for 190-309 secs
> defer_accept=3D8 retrans for 310-429 secs
>=20
> 	Comments? Next step is to post the 3 patches separately
> for final review and applying.
>=20

I really like this, but please define helper functions out of do_tcp_se=
tsockopt()

/* Translate value in seconds to number of SYN-ACK retransmits */
static u8 secs_to_retrans(int seconds)
{
	u8 res =3D 0;

	if (seconds > 0) {
		int timeout =3D TCP_TIMEOUT_INIT / HZ;
		int period =3D timeout;

		res =3D 1;
		while (res < 255 && seconds > period) {
			res++;
			timeout <<=3D 1;
			if (timeout > TCP_RTO_MAX / HZ)
				timeout =3D TCP_RTO_MAX / HZ;
			period +=3D timeout;
		}
	}
	return res;
}

You also need the reverse function for getsockopt()...
