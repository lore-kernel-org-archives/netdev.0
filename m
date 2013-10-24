From: James Chapman <jchapman@katalix.com>
Subject: Re: [RFC PATCH net-next] ppp: Allow ppp device connected to an l2tp
 session to change of namespace
Date: Thu, 24 Oct 2013 11:55:45 +0100
Message-ID: <5268FCB1.7020903@katalix.com>
References: <5268F6CD.9070600@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: =?ISO-8859-1?Q?Fran=E7ois_Cachereul?= <f.cachereul@alphalink.fr>,
	Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:43210 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754052Ab3JXKzu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Oct 2013 06:55:50 -0400
In-Reply-To: <5268F6CD.9070600@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/10/13 11:30, Fran=E7ois Cachereul wrote:
> Remove NETIF_F_NETNS_LOCAL flag from ppp device in ppp_connect_channe=
l()
> if the device is connected to a l2tp session socket.
> Restore the flag in ppp_disconnect_channel().

What about pppd's network namespace? Also, L2TP's tunnel socket (UDP or
L2TP/IP) will be in a different namespace if the ppp interface is moved=
=2E

>=20
> Signed-off-by: Fran=E7ois CACHEREUL <f.cachereul@alphalink.fr>
> ---
> I'm trying to get rid of this flag for ppp device connected to l2tp
> session, it's seem to be safe to do it for as l2tp_ppp module hasn't =
any
> reference to the ppp device except to the device name. We can probabl=
y
> do it for others modules but pppoe and pptp will require more work.
>=20
> I remove the flag for l2tp in ppp_generic.c because I couldn't find a
> place like a callback to do it in l2tp_ppp.c. The best will be to=20
> remove the flag for all ppp devices.
>=20
> Fran=E7ois
>=20
>  drivers/net/ppp/ppp_generic.c |   11 +++++++++++
>  1 file changed, 11 insertions(+)
>=20
> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_gene=
ric.c
> index 72ff14b..7ccf2ae 100644
> --- a/drivers/net/ppp/ppp_generic.c
> +++ b/drivers/net/ppp/ppp_generic.c
> @@ -54,6 +54,8 @@
>  #include <net/net_namespace.h>
>  #include <net/netns/generic.h>
> =20
> +#include <linux/if_pppox.h>
> +
>  #define PPP_VERSION	"2.4.2"
> =20
>  /*
> @@ -2861,6 +2863,7 @@ ppp_connect_channel(struct channel *pch, int un=
it)
>  	struct ppp_net *pn;
>  	int ret =3D -ENXIO;
>  	int hdrlen;
> +	struct sock *sk;
> =20
>  	pn =3D ppp_pernet(pch->chan_net);
> =20
> @@ -2883,6 +2886,13 @@ ppp_connect_channel(struct channel *pch, int u=
nit)
>  	++ppp->n_channels;
>  	pch->ppp =3D ppp;
>  	atomic_inc(&ppp->file.refcnt);
> +
> +	/* allow ppp net device to be moved in another network namespace
> +	 * if it's connected to an l2tp session */
> +	sk =3D (struct sock *)pch->chan->private;
> +	if (sk && sk->sk_protocol =3D=3D PX_PROTO_OL2TP)
> +		ppp->dev->features &=3D ~NETIF_F_NETNS_LOCAL;
> +
>  	ppp_unlock(ppp);
>  	ret =3D 0;
> =20
> @@ -2912,6 +2922,7 @@ ppp_disconnect_channel(struct channel *pch)
>  		list_del(&pch->clist);
>  		if (--ppp->n_channels =3D=3D 0)
>  			wake_up_interruptible(&ppp->file.rwait);
> +		ppp->dev->features |=3D NETIF_F_NETNS_LOCAL;
>  		ppp_unlock(ppp);
>  		if (atomic_dec_and_test(&ppp->file.refcnt))
>  			ppp_destroy_interface(ppp);
>=20



--=20
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
