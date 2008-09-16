From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 08/14] Phonet: receive path socket lookup
Date: Tue, 16 Sep 2008 13:52:05 -0300
Message-ID: <20080916165205.GK8702@ghostprotocols.net>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-8-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48467 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753239AbYIPRA5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 13:00:57 -0400
Content-Disposition: inline
In-Reply-To: <1221577694-4513-8-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Sep 16, 2008 at 06:08:08PM +0300, R=E9mi Denis-Courmont escreve=
u:
> This delivers received packet to the right socket, if any.
>=20
> Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
> ---
>  include/net/phonet/phonet.h |    1 +
>  net/phonet/af_phonet.c      |   13 ++++++++++++-
>  2 files changed, 13 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.=
h
> index e0fa080..8e7e42d 100644
> --- a/include/net/phonet/phonet.h
> +++ b/include/net/phonet/phonet.h
> @@ -35,6 +35,7 @@
>   */
>  struct pn_sock {
>  	struct sock	sk;
> +	int		(*handler)(struct sock *, struct sk_buff *);
>  	u16		sobject;
>  	u8		resource;
>  };
> diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> index 12c72e1..317f30c 100644
> --- a/net/phonet/af_phonet.c
> +++ b/net/phonet/af_phonet.c
> @@ -96,7 +96,9 @@ static int phonet_rcv(struct sk_buff *skb, struct n=
et_device *dev,
>  			struct net_device *orig_dev)
>  {
>  	struct phonethdr *ph;
> +	struct sock *sk;
>  	struct sockaddr_pn sa;
> +	int err;
>  	u16 len;
> =20
>  	if (dev_net(dev) !=3D &init_net)
> @@ -120,7 +122,15 @@ static int phonet_rcv(struct sk_buff *skb, struc=
t net_device *dev,
>  	if (pn_sockaddr_get_addr(&sa) =3D=3D 0)
>  		goto out; /* currently, we cannot be device 0 */
> =20
> -	/* TODO: put packets to sockets backlog */
> +	sk =3D pn_find_sock_by_sa(&sa);
> +	if (sk =3D=3D NULL)
> +		goto out;
> +
> +	/* Push data to the socket (or other sockets connected to it). */
> +	err =3D pn_sk(sk)->handler(sk, skb);

wouldn't be nice to use sk_backlog_rcv() and sk_receive_skb()?

> +	sock_put(sk);
> +
> +	return err ? NET_RX_DROP : NET_RX_SUCCESS;
> =20
>  out:
>  	kfree_skb(skb);
> @@ -196,6 +206,7 @@ static int __init phonet_init(void)
>  {
>  	int err;
> =20
> +	phonet_socket_init();
>  	err =3D sock_register(&phonet_proto_family);
>  	if (err) {
>  		printk(KERN_ALERT
> --=20
> 1.5.4.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
