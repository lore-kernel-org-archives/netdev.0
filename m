From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Reduce number of pointer dereferences in IPv6
 netfilter LOG module function dump_packet()
Date: Mon, 15 Nov 2010 01:50:15 +0100
Message-ID: <1289782215.2743.167.camel@edumazet-laptop>
References: <alpine.LNX.2.00.1011142241260.1253@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Core Team <coreteam@netfilter.org>,
	Jan Rekorajski <baggins@pld.org.pl>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1011142241260.1253@swampdragon.chaosbits.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 14 novembre 2010 =C3=A0 22:47 +0100, Jesper Juhl a =C3=A9cr=
it :
> By adding two pointer variables to=20
> net/ipv6/netfilter/ip6t_LOG.c::dump_packet() we can save 19 bytes of =
=2Etext=20
> and many pointer dereferences.
>=20
> before:
>    text    data     bss     dec     hex filename
>    6258     600    3088    9946    26da net/ipv6/netfilter/ip6t_LOG.o
>=20
> after:
>    text    data     bss     dec     hex filename
>    6239     600    3088    9927    26c7 net/ipv6/netfilter/ip6t_LOG.o
>=20
>=20
> Please Cc me on replies.
>=20
>=20
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  ip6t_LOG.c |   16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)
>=20
> diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_=
LOG.c
> index 09c8889..51d10a5 100644
> --- a/net/ipv6/netfilter/ip6t_LOG.c
> +++ b/net/ipv6/netfilter/ip6t_LOG.c
> @@ -46,6 +46,8 @@ static void dump_packet(struct sbuff *m,
>  	unsigned int ptr;
>  	unsigned int hdrlen =3D 0;
>  	unsigned int logflags;
> +	struct sock *sk;
> +	struct socket *sk_socket;
> =20
>  	if (info->type =3D=3D NF_LOG_TYPE_LOG)
>  		logflags =3D info->u.log.logflags;
> @@ -358,13 +360,15 @@ static void dump_packet(struct sbuff *m,
>  	}
> =20
>  	/* Max length: 15 "UID=3D4294967295 " */
> -	if ((logflags & IP6T_LOG_UID) && recurse && skb->sk) {
> -		read_lock_bh(&skb->sk->sk_callback_lock);
> -		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
> +	sk =3D skb->sk;
> +	sk_socket =3D sk->sk_socket;
> +	if ((logflags & IP6T_LOG_UID) && recurse && sk) {
> +		read_lock_bh(&sk->sk_callback_lock);
> +		if (sk_socket && sk_socket->file)
>  			sb_add(m, "UID=3D%u GID=3D%u ",
> -				skb->sk->sk_socket->file->f_cred->fsuid,
> -				skb->sk->sk_socket->file->f_cred->fsgid);
> -		read_unlock_bh(&skb->sk->sk_callback_lock);
> +				sk_socket->file->f_cred->fsuid,
> +				sk_socket->file->f_cred->fsgid);
> +		read_unlock_bh(&sk->sk_callback_lock);
>  	}
> =20
>  	/* Max length: 16 "MARK=3D0xFFFFFFFF " */
>=20
>=20
>=20

Same comment than previous patch, you add a NULL dereference.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
