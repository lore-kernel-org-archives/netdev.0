From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Reduce number of pointer dereferences in IPv4
 netfilter LOG module function dump_packet()
Date: Mon, 15 Nov 2010 01:49:40 +0100
Message-ID: <1289782180.2743.166.camel@edumazet-laptop>
References: <alpine.LNX.2.00.1011142212310.1253@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Core Team <coreteam@netfilter.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1011142212310.1253@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 14 novembre 2010 =C3=A0 22:35 +0100, Jesper Juhl a =C3=A9cr=
it :
> By adding two pointer variables to=20
> net/ipv4/netfilter/ipt_LOG.c::dump_packet() we can save 16 bytes of .=
text=20
> and 9 pointer dereferences.
>=20
> before this patch we did 20 pointer dereferences and had this object =
file=20
> size:
>    text    data     bss     dec     hex filename
>    6233     600    3080    9913    26b9 net/ipv4/netfilter/ipt_LOG.o
>=20
> after this patch we do just 11 pointer dereferences and have this obj=
ect=20
> file size:
>    text    data     bss     dec     hex filename
>    6217     600    3080    9897    26a9 net/ipv4/netfilter/ipt_LOG.o
>=20
>=20
> Please Cc me on replies.
>=20
>=20
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  ipt_LOG.c |   16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)
>=20
> diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LO=
G.c
> index 72ffc8f..02a92de 100644
> --- a/net/ipv4/netfilter/ipt_LOG.c
> +++ b/net/ipv4/netfilter/ipt_LOG.c
> @@ -39,6 +39,8 @@ static void dump_packet(struct sbuff *m,
>  	struct iphdr _iph;
>  	const struct iphdr *ih;
>  	unsigned int logflags;
> +	struct sock *sk;
> +	struct socket *sk_socket;
> =20
>  	if (info->type =3D=3D NF_LOG_TYPE_LOG)
>  		logflags =3D info->u.log.logflags;
> @@ -335,13 +337,15 @@ static void dump_packet(struct sbuff *m,
>  	}
> =20
>  	/* Max length: 15 "UID=3D4294967295 " */
> -	if ((logflags & IPT_LOG_UID) && !iphoff && skb->sk) {
> -		read_lock_bh(&skb->sk->sk_callback_lock);
> -		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
> +	sk =3D skb->sk;
> +	sk_socket =3D sk->sk_socket;

Really ? sk can be NULL, so you add a NULL dereference.

> +	if ((logflags & IPT_LOG_UID) && !iphoff && sk) {
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

Most of these "dereferences" are compiler optimized.

You added a bug in your patch, and make ipt_LOG slower if rule is not
asking for IPT_LOG_UID
