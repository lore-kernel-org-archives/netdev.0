From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/8] [TCP]: Uninline tcp_set_state
Date: Sat, 12 Jan 2008 13:03:55 -0800
Message-ID: <20080112130355.74c39ae7@deepthought>
References: <12001308173969-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12001308171262-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:59755 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756023AbYALVGp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 16:06:45 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JDnYr-00084m-KC
	for netdev@vger.kernel.org; Sat, 12 Jan 2008 21:06:37 +0000
Received: from 069-064-229-129.pdx.net ([69.64.229.129])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2008 21:06:37 +0000
Received: from shemminger by 069-064-229-129.pdx.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2008 21:06:37 +0000
In-Reply-To: <12001308171262-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Jan 2008 11:40:10 +0200
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> net/ipv4/tcp.c:
>   tcp_close_state | -226
>   tcp_done        | -145
>   tcp_close       | -564
>   tcp_disconnect  | -141
>  4 functions changed, 1076 bytes removed, diff: -1076
>=20
> net/ipv4/tcp_input.c:
>   tcp_fin               |  -86
>   tcp_rcv_state_process | -164
>  2 functions changed, 250 bytes removed, diff: -250
>=20
> net/ipv4/tcp_ipv4.c:
>   tcp_v4_connect | -209
>  1 function changed, 209 bytes removed, diff: -209
>=20
> net/ipv4/arp.c:
>   arp_ignore |   +5
>  1 function changed, 5 bytes added, diff: +5
>=20
> net/ipv6/tcp_ipv6.c:
>   tcp_v6_connect | -158
>  1 function changed, 158 bytes removed, diff: -158
>=20
> net/sunrpc/xprtsock.c:
>   xs_sendpages |   -2
>  1 function changed, 2 bytes removed, diff: -2
>=20
> net/dccp/ccids/ccid3.c:
>   ccid3_update_send_interval |   +7
>  1 function changed, 7 bytes added, diff: +7
>=20
> net/ipv4/tcp.c:
>   tcp_set_state | +238
>  1 function changed, 238 bytes added, diff: +238
>=20
> built-in.o:
>  12 functions changed, 250 bytes added, 1695 bytes removed, diff: -14=
45
>=20
> I've no explanation why some unrelated changes seem to occur
> consistently as well (arp_ignore, ccid3_update_send_interval;
> I checked the arp_ignore asm and it seems to be due to some
> reordered of operation order causing some extra opcodes to be
> generated). Still, the benefits are pretty obvious from the
> codiff's results.
>=20
> Signed-off-by: Ilpo J=C3=83=C2=A4rvinen <ilpo.jarvinen@helsinki.fi>
> Cc: Andi Kleen <andi@firstfloor.org>
> ---
>  include/net/tcp.h |   35 +----------------------------------
>  net/ipv4/tcp.c    |   35 +++++++++++++++++++++++++++++++++++
>  2 files changed, 36 insertions(+), 34 deletions(-)
>=20
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 48081ad..306580c 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -926,40 +926,7 @@ static const char *statename[]=3D{
>  	"Close Wait","Last ACK","Listen","Closing"
>  };
>  #endif
> -
> -static inline void tcp_set_state(struct sock *sk, int state)
> -{
> -	int oldstate =3D sk->sk_state;
> -
> -	switch (state) {
> -	case TCP_ESTABLISHED:
> -		if (oldstate !=3D TCP_ESTABLISHED)
> -			TCP_INC_STATS(TCP_MIB_CURRESTAB);
> -		break;
> -
> -	case TCP_CLOSE:
> -		if (oldstate =3D=3D TCP_CLOSE_WAIT || oldstate =3D=3D TCP_ESTABLIS=
HED)
> -			TCP_INC_STATS(TCP_MIB_ESTABRESETS);
> -
> -		sk->sk_prot->unhash(sk);
> -		if (inet_csk(sk)->icsk_bind_hash &&
> -		    !(sk->sk_userlocks & SOCK_BINDPORT_LOCK))
> -			inet_put_port(&tcp_hashinfo, sk);
> -		/* fall through */
> -	default:
> -		if (oldstate=3D=3DTCP_ESTABLISHED)
> -			TCP_DEC_STATS(TCP_MIB_CURRESTAB);
> -	}
> -
> -	/* Change state AFTER socket is unhashed to avoid closed
> -	 * socket sitting in hash tables.
> -	 */
> -	sk->sk_state =3D state;
> -
> -#ifdef STATE_TRACE
> -	SOCK_DEBUG(sk, "TCP sk=3D%p, State %s -> %s\n",sk, statename[oldsta=
te],statename[state]);
> -#endif=09
> -}
>


Since the function is called with a constant state, I guess the assumpt=
ion
was that gcc would be smart enough to only include the code needed, it =
looks like
either code was bigger or the compiler was dumber than expected

--=20
Stephen Hemminger <stephen.hemminger@vyatta.com>

