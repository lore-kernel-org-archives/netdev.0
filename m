From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next PATCH v2 1/1] bring netlink interface to par with
 brctl show macs
Date: Mon, 26 May 2014 03:35:47 +0100
Message-ID: <1401071747.17377.111.camel@deadeye.wl.decadent.org.uk>
References: <1401023755-8174-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-y6YmvRB+Plb8h/Why2wq"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	stephen@networkplumber.org, vyasevic@redhat.com,
	john.r.fastabend@intel.com, sfeldma@cumulusnetworks.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52284 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751178AbaEZCf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2014 22:35:58 -0400
In-Reply-To: <1401023755-8174-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-y6YmvRB+Plb8h/Why2wq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-05-25 at 09:15 -0400, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>=20
> This patch allows something equivalent to
> "brctl showmacs <bridge device>" with iproute2
> syntax "bridge fdb show br <bridge device>"
> Filtering by bridge is done in the kernel.
> The current setup doesnt scale when you have many bridges each
> with large fdbs (preliminary fix with the kernel patch).
>=20
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  net/core/rtnetlink.c |   49 ++++++++++++++++++++++++++++++++++----------=
-----
>  1 file changed, 34 insertions(+), 15 deletions(-)
>=20
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index f31268d..1ad4828 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2509,26 +2509,45 @@ static int rtnl_fdb_dump(struct sk_buff *skb, str=
uct netlink_callback *cb)
>  {
>  	int idx =3D 0;
>  	struct net *net =3D sock_net(skb->sk);
> +	const struct net_device_ops *ops;
>  	struct net_device *dev;
> +	struct ndmsg *ndm;
> =20
> -	rcu_read_lock();
> -	for_each_netdev_rcu(net, dev) {
> -		if (dev->priv_flags & IFF_BRIDGE_PORT) {
> -			struct net_device *br_dev;
> -			const struct net_device_ops *ops;
> -
> -			br_dev =3D netdev_master_upper_dev_get(dev);
> -			ops =3D br_dev->netdev_ops;
> -			if (ops->ndo_fdb_dump)
> -				idx =3D ops->ndo_fdb_dump(skb, cb, dev, idx);
> +	ndm =3D nlmsg_data(cb->nlh);
> +	if (ndm->ndm_ifindex) {
> +		dev =3D __dev_get_by_index(net, ndm->ndm_ifindex);
> +		if (dev =3D=3D NULL) {
> +			pr_info("PF_BRIDGE: RTM_GETNEIGH with unknown ifindex\n");

You left another debug message here.

> +			return -ENODEV;
>  		}
> =20
> -		if (dev->netdev_ops->ndo_fdb_dump)
> -			idx =3D dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, idx);
> -		else
> -			idx =3D ndo_dflt_fdb_dump(skb, cb, dev, idx);
> +		ops =3D dev->netdev_ops;
> +		if (ops->ndo_fdb_dump) {
> +			idx =3D ops->ndo_fdb_dump(skb, cb, dev, idx);
> +		} else {
> +			pr_info("PF_BRIDGE: RTM_GETNEIGH %s no dumper\n",
> +				dev->name);

And here.

> +			return -EINVAL;
> +		}
[...]

Why does this only call the device's own ndo_fdb_dump and not a
bridge-port's bridge's ndo_fdb_dump or ndo_dflt_fdb_dump?

Ben.

--=20
Ben Hutchings
Humans are not rational beings; they are rationalising beings.

--=-y6YmvRB+Plb8h/Why2wq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU4KoiOe/yOyVhhEJAQqUvQ/+MmzVrDuwWlEJq13K0U8x0MWCB1rWHlhM
jerQpoeA1bK1LkZYtn89wwQzoDJ9QObzZ1YoqWaKW0RJSXqHuR6wbupkiYSBqrrt
/xg/D1SmF1fzIZazsDNPyF1msHLejHq2uswrqc6w5ifrUwpCVfpxvIBmhUmbhsxc
Pla8/5OS2J/JCczfA/r995NQFxeon87m3oe4Hzf8gOsdXverfrfswPU9i2/Xsryg
tXoy5atHQoS4GZOUhcclFLbA9pXxK31BuX4u5D36f4hzwy8scSLOkcvbnl/qTu6v
XjE8uNn2WW1POEe2OML58EFozZuVxHyCJJiwUEbFXAAsspEzOtO0nYbygSAu2tU5
Fto4W7zDjNw2W+2vX1pZwYU+vedg3LHUJvrT69eDH+tS4KD1LER5Ydrgg6cyejms
0bhkyJdrR8knrB15JYSSE/pTMZfuMzbbVxmbIdseaWhiqWOWSGyoIxRnT9zPt4ma
+aj+k/ZmjPvtZYyT1RAoVaQBYpuoMSLzM1D4KIO20o5RHnBUBZZbxZz9rukLx0F4
Vy/jcifMvEaEBW8iO5GmTtvH47hebIUwtzi/txNnnzawshipw15GJbmA41EzvxYd
L4VAX403oyDcTbTHTcE+gWyv6lJg2GfV4oy1irrjDbFxlfNM/8A3lJ2VSfbdYzN3
e3+oatVipDg=
=mAmD
-----END PGP SIGNATURE-----

--=-y6YmvRB+Plb8h/Why2wq--
