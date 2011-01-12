From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: rndis gadget: Inconsistent locking
Date: Wed, 12 Jan 2011 14:07:12 +0100
Message-ID: <1294837632.3981.18.camel@edumazet-laptop>
References: <20110112122811.GA9513@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>,
	=?UTF-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Neil Jones <neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110112122811.GA9513-8HppEYmqbBCE+EvaaNYduQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le mercredi 12 janvier 2011 =C3=A0 12:28 +0000, Jarek Poplawski a =C3=A9=
crit :
> On 2011-01-10 13:14, David Brownell wrote:
> >=20
> >=20
> >> I have just retested Michals patch but I have found another
> >> lockdep failure.
> >>
> >> It looks like rndis_msg_parser() can call dev_get_stats> too:
> >=20
> > Can someone provide a fully working patch then?
> > Or maybe just revert the one that caused all the
> > breakage??
> >=20
> > Rememeber that this driver was working fine for
> > years before netdev changes added multiple bugs
> > because (at least) they didn't update all callers.
>=20
> Maybe I miss something, but if it's like Michal described something
> like this should be enough (not tested nor compiled).
>=20
> Jarek P.
> ---
>=20
>  drivers/usb/gadget/f_phonet.c |    6 ++++++
>  drivers/usb/gadget/u_ether.c  |    6 ++++++
>  2 files changed, 12 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_pho=
net.c
> index 3c6e1a0..bef4622 100644
> --- a/drivers/usb/gadget/f_phonet.c
> +++ b/drivers/usb/gadget/f_phonet.c
> @@ -207,6 +207,11 @@ static int pn_net_close(struct net_device *dev)
>  	return 0;
>  }
> =20
> +static struct net_device_stats *pn_net_stats(struct net_device *dev)
> +{
> +	return &dev->stats;
> +}
> +
>  static void pn_tx_complete(struct usb_ep *ep, struct usb_request *re=
q)
>  {
>  	struct f_phonet *fp =3D ep->driver_data;
> @@ -279,6 +284,7 @@ static int pn_net_mtu(struct net_device *dev, int=
 new_mtu)
>  static const struct net_device_ops pn_netdev_ops =3D {
>  	.ndo_open	=3D pn_net_open,
>  	.ndo_stop	=3D pn_net_close,
> +	.ndo_get_stats	=3D pn_net_stats,
>  	.ndo_start_xmit	=3D pn_net_xmit,
>  	.ndo_change_mtu	=3D pn_net_mtu,
>  };
> diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ethe=
r.c
> index 1eda968..f21520f 100644
> --- a/drivers/usb/gadget/u_ether.c
> +++ b/drivers/usb/gadget/u_ether.c
> @@ -702,6 +702,11 @@ static int eth_stop(struct net_device *net)
>  	return 0;
>  }
> =20
> +static struct net_device_stats *eth_get_stats(struct net_device *net=
)
> +{
> +	return &net->stats;
> +}
> +
>  /*------------------------------------------------------------------=
-------*/
> =20
>  /* initial value, changed by "ifconfig usb0 hw ether xx:xx:xx:xx:xx:=
xx" */
> @@ -740,6 +745,7 @@ static struct eth_dev *the_dev;
>  static const struct net_device_ops eth_netdev_ops =3D {
>  	.ndo_open		=3D eth_open,
>  	.ndo_stop		=3D eth_stop,
> +	.ndo_get_stats		=3D eth_get_stats,
>  	.ndo_start_xmit		=3D eth_start_xmit,
>  	.ndo_change_mtu		=3D ueth_change_mtu,
>  	.ndo_set_mac_address 	=3D eth_mac_addr,
> --

Hmm...=20

So all net devices in gen_ndis_query_resp() should have a
ndo_get_stats() or ndo_get_stats64() method, not allowed to use
spin_lock_bh() / spin_unlock_bh()

If yes, we should add big fat comments to pn_net_stats()/eth_get_stats(=
) so that nobody
tries to revert your patch ;)



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
