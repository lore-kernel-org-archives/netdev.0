From: Tom Parkin <tparkin@katalix.com>
Subject: Re: [PATCH net] l2tp: fix l2tp_eth module loading
Date: Thu, 28 Sep 2017 15:17:28 +0100
Message-ID: <20170928141728.GA3107@jackdaw>
References: <a7d351fd5948fc69ef17da3c170cd7c152f899c4.1506606179.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Cc: netdev@vger.kernel.org, James Chapman <jchapman@katalix.com>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.katalix.com ([82.103.140.233]:51781 "EHLO mail.katalix.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751925AbdI1ORd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 10:17:33 -0400
Content-Disposition: inline
In-Reply-To: <a7d351fd5948fc69ef17da3c170cd7c152f899c4.1506606179.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 28, 2017 at 03:44:38PM +0200, Guillaume Nault wrote:
> The l2tp_eth module crashes if its netlink callbacks are run when the
> pernet data aren't initialised.
>=20
> We should normally register_pernet_device() before the genl callbacks.
> However, the pernet data only maintain a list of l2tpeth interfaces,
> and this list is never used. So let's just drop pernet handling
> instead.
>=20
> Fixes: d9e31d17ceba ("l2tp: Add L2TP ethernet pseudowire support")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Whoops.  I think this was intended to clear up the devices in the net
namespace, but since l2tp_core.c already deletes tunnels on namespace
exit I don't think it's necessary for l2tp_eth.c to do anything more.

> ---
>  net/l2tp/l2tp_eth.c | 51 ++---------------------------------------------=
----
>  1 file changed, 2 insertions(+), 49 deletions(-)
>=20
> diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
> index 87da9ef61860..014a7bc2a872 100644
> --- a/net/l2tp/l2tp_eth.c
> +++ b/net/l2tp/l2tp_eth.c
> @@ -44,7 +44,6 @@ struct l2tp_eth {
>  	struct net_device	*dev;
>  	struct sock		*tunnel_sock;
>  	struct l2tp_session	*session;
> -	struct list_head	list;
>  	atomic_long_t		tx_bytes;
>  	atomic_long_t		tx_packets;
>  	atomic_long_t		tx_dropped;
> @@ -58,17 +57,6 @@ struct l2tp_eth_sess {
>  	struct net_device	*dev;
>  };
> =20
> -/* per-net private data for this module */
> -static unsigned int l2tp_eth_net_id;
> -struct l2tp_eth_net {
> -	struct list_head l2tp_eth_dev_list;
> -	spinlock_t l2tp_eth_lock;
> -};
> -
> -static inline struct l2tp_eth_net *l2tp_eth_pernet(struct net *net)
> -{
> -	return net_generic(net, l2tp_eth_net_id);
> -}
> =20
>  static int l2tp_eth_dev_init(struct net_device *dev)
>  {
> @@ -84,12 +72,6 @@ static int l2tp_eth_dev_init(struct net_device *dev)
> =20
>  static void l2tp_eth_dev_uninit(struct net_device *dev)
>  {
> -	struct l2tp_eth *priv =3D netdev_priv(dev);
> -	struct l2tp_eth_net *pn =3D l2tp_eth_pernet(dev_net(dev));
> -
> -	spin_lock(&pn->l2tp_eth_lock);
> -	list_del_init(&priv->list);
> -	spin_unlock(&pn->l2tp_eth_lock);
>  	dev_put(dev);
>  }
> =20
> @@ -273,7 +255,6 @@ static int l2tp_eth_create(struct net *net, struct l2=
tp_tunnel *tunnel,
>  	struct l2tp_eth *priv;
>  	struct l2tp_eth_sess *spriv;
>  	int rc;
> -	struct l2tp_eth_net *pn;
> =20
>  	if (cfg->ifname) {
>  		strlcpy(name, cfg->ifname, IFNAMSIZ);
> @@ -305,7 +286,6 @@ static int l2tp_eth_create(struct net *net, struct l2=
tp_tunnel *tunnel,
>  	priv =3D netdev_priv(dev);
>  	priv->dev =3D dev;
>  	priv->session =3D session;
> -	INIT_LIST_HEAD(&priv->list);
> =20
>  	priv->tunnel_sock =3D tunnel->sock;
>  	session->recv_skb =3D l2tp_eth_dev_recv;
> @@ -326,10 +306,6 @@ static int l2tp_eth_create(struct net *net, struct l=
2tp_tunnel *tunnel,
>  	strlcpy(session->ifname, dev->name, IFNAMSIZ);
> =20
>  	dev_hold(dev);
> -	pn =3D l2tp_eth_pernet(dev_net(dev));
> -	spin_lock(&pn->l2tp_eth_lock);
> -	list_add(&priv->list, &pn->l2tp_eth_dev_list);
> -	spin_unlock(&pn->l2tp_eth_lock);
> =20
>  	return 0;
> =20
> @@ -342,22 +318,6 @@ static int l2tp_eth_create(struct net *net, struct l=
2tp_tunnel *tunnel,
>  	return rc;
>  }
> =20
> -static __net_init int l2tp_eth_init_net(struct net *net)
> -{
> -	struct l2tp_eth_net *pn =3D net_generic(net, l2tp_eth_net_id);
> -
> -	INIT_LIST_HEAD(&pn->l2tp_eth_dev_list);
> -	spin_lock_init(&pn->l2tp_eth_lock);
> -
> -	return 0;
> -}
> -
> -static struct pernet_operations l2tp_eth_net_ops =3D {
> -	.init =3D l2tp_eth_init_net,
> -	.id   =3D &l2tp_eth_net_id,
> -	.size =3D sizeof(struct l2tp_eth_net),
> -};
> -
> =20
>  static const struct l2tp_nl_cmd_ops l2tp_eth_nl_cmd_ops =3D {
>  	.session_create	=3D l2tp_eth_create,
> @@ -371,25 +331,18 @@ static int __init l2tp_eth_init(void)
> =20
>  	err =3D l2tp_nl_register_ops(L2TP_PWTYPE_ETH, &l2tp_eth_nl_cmd_ops);
>  	if (err)
> -		goto out;
> -
> -	err =3D register_pernet_device(&l2tp_eth_net_ops);
> -	if (err)
> -		goto out_unreg;
> +		goto err;
> =20
>  	pr_info("L2TP ethernet pseudowire support (L2TPv3)\n");
> =20
>  	return 0;
> =20
> -out_unreg:
> -	l2tp_nl_unregister_ops(L2TP_PWTYPE_ETH);
> -out:
> +err:
>  	return err;
>  }
> =20
>  static void __exit l2tp_eth_exit(void)
>  {
> -	unregister_pernet_device(&l2tp_eth_net_ops);
>  	l2tp_nl_unregister_ops(L2TP_PWTYPE_ETH);
>  }
> =20
> --=20
> 2.14.2
>=20

--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJZzQR4AAoJEJSMBmUKuovQaYMH+gI5cL9GCB0iRYoUBtmgOvp3
MBQDxEs+hqdIAIOCpupcQxIf9V6Aop0nhBpTgF8Pk6p2iipxbJyJw/uB4e0OiWIs
VxKxihXrh+h4dC/0EC0CEEAYl5jgx9stFRuJpMuB5v+iz4eVmhkrmsonTO9k7bji
sZSQ01/W6Pho+cjyBIC1KohmkECmHnK2GHkxgcfdv8cLAziVi3sXzG8Zl6b3aG9a
9T7xBwn7vbl2X76VXjsFbnhtE0RGfq8sdsHlOsYygGLbuOBkmomLkLT3EIk7DGb3
iHHH06xpS0gzQyq+sxKVm+sc48BXCLFTr0kz1spxqZ2dgvVKGeAebQ4nTHPuwxc=
=Dtdv
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--
