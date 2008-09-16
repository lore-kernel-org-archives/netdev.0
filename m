From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 09/14] Phonet: allocate and initialize new sockets
Date: Tue, 16 Sep 2008 13:53:05 -0300
Message-ID: <20080916165305.GL8702@ghostprotocols.net>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-9-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48490 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753358AbYIPRB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 13:01:57 -0400
Content-Disposition: inline
In-Reply-To: <1221577694-4513-9-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Sep 16, 2008 at 06:08:09PM +0300, R=E9mi Denis-Courmont escreve=
u:
> Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
> ---
>  include/net/phonet/phonet.h |    1 +
>  net/phonet/af_phonet.c      |   20 ++++++++++++++++++--
>  2 files changed, 19 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.=
h
> index 8e7e42d..1131833 100644
> --- a/include/net/phonet/phonet.h
> +++ b/include/net/phonet/phonet.h
> @@ -81,6 +81,7 @@ void pn_skb_get_dst_sockaddr(struct sk_buff *skb, s=
truct sockaddr_pn *sa)
> =20
>  /* Protocols in Phonet protocol family. */
>  struct phonet_protocol {
> +	const struct proto_ops	*ops;
>  	struct proto		*prot;
>  	int			sock_type;
>  };
> diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> index 317f30c..1628e7c 100644
> --- a/net/phonet/af_phonet.c
> +++ b/net/phonet/af_phonet.c
> @@ -41,6 +41,8 @@ static inline void phonet_proto_put(struct phonet_p=
rotocol *pp);
> =20
>  static int pn_socket_create(struct net *net, struct socket *sock, in=
t protocol)
>  {
> +	struct sock *sk;
> +	struct pn_sock *pn;
>  	struct phonet_protocol *pnp;
>  	int err;
> =20
> @@ -71,8 +73,22 @@ static int pn_socket_create(struct net *net, struc=
t socket *sock, int protocol)
>  		goto out;
>  	}
> =20
> -	/* TODO: create and init the struct sock */
> -	err =3D -EPROTONOSUPPORT;
> +	sk =3D sk_alloc(net, PF_PHONET, GFP_KERNEL, pnp->prot);
> +	if (sk =3D=3D NULL) {
> +		err =3D -ENOMEM;
> +		goto out;
> +	}
> +
> +	sock_init_data(sock, sk);
> +	sock->state =3D SS_UNCONNECTED;
> +	sock->ops =3D pnp->ops;
> +	sk->sk_backlog_rcv =3D sk->sk_prot->backlog_rcv;

Scrap the comment I made in a previous patch, I guess

> +	sk->sk_protocol =3D protocol;
> +	pn =3D pn_sk(sk);
> +	pn->sobject =3D 0;
> +	pn->resource =3D 0;
> +	sk->sk_prot->init(sk);
> +	err =3D 0;
> =20
>  out:
>  	phonet_proto_put(pnp);
> --=20
> 1.5.4.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
