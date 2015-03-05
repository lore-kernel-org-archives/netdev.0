From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v1] bonding: implement bond_poll_controller()
Date: Thu, 05 Mar 2015 12:10:25 +0000
Message-ID: <1425557425.3164.55.camel@decadent.org.uk>
References: <1425522400-3671-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-NqKvvJEGJshS8ieAbH2j"
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43945 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751868AbbCEMKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 07:10:39 -0500
In-Reply-To: <1425522400-3671-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-NqKvvJEGJshS8ieAbH2j
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-03-04 at 18:26 -0800, Mahesh Bandewar wrote:
> This patches implements the poll_controller support for all
> bonding driver. If the slaves have poll_controller net_op defined,
> this implementation calls them. This is mode agnostic implementation
> and iterates through all slaves (based on mode) and calls respective
> handler.
>=20
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_main.c | 33 +++++++++++++++++++++++++++++++++
>  1 file changed, 33 insertions(+)
>=20
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_m=
ain.c
> index af5908a2190c..cbf77d388f53 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -928,6 +928,39 @@ static inline void slave_disable_netpoll(struct slav=
e *slave)
> =20
>  static void bond_poll_controller(struct net_device *bond_dev)
>  {
> +	struct bonding *bond =3D netdev_priv(bond_dev);
> +	struct slave *slave =3D NULL;
> +	struct list_head *iter;
> +	struct ad_info ad_info;
> +	struct netpoll_info *ni;
> +	const struct net_device_ops *ops;
> +
> +	if (BOND_MODE(bond) =3D=3D BOND_MODE_8023AD)
> +		if (bond_3ad_get_active_agg_info(bond, &ad_info))
> +			return;

I don't think you need all that information...

> +	rcu_read_lock();
> +	bond_for_each_slave_rcu(bond, slave, iter) {
> +		ops =3D slave->dev->netdev_ops;
> +		if (!bond_slave_is_up(slave) || !ops->ndo_poll_controller)
> +			continue;
> +
> +		if (BOND_MODE(bond) =3D=3D BOND_MODE_8023AD) {
> +			struct aggregator *agg =3D
> +			    SLAVE_AD_INFO(slave)->port.aggregator;
> +
> +			if (agg &&
> +			    agg->aggregator_identifier !=3D ad_info.aggregator_id)
> +				continue;

I think this could be:

			if (!(agg && agg->is_active))
				continue;

Ben.

> +		}
> +
> +		ni =3D rcu_dereference_bh(slave->dev->npinfo);
> +		if (down_trylock(&ni->dev_lock))
> +			continue;
> +		ops->ndo_poll_controller(slave->dev);
> +		up(&ni->dev_lock);
> +	}
> +	rcu_read_unlock();
>  }
> =20
>  static void bond_netpoll_cleanup(struct net_device *bond_dev)

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-NqKvvJEGJshS8ieAbH2j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVPhHsee/yOyVhhEJAQr3dxAAoPZXXFF/5hhoQ8hO35b7t3IiWgCPCnKk
gVwuGZ6EwL6Jlynv90J6kMmkTG7abnELK5PYPyD7JKTQkMA9KgV8lv4/3aZE8CxB
3Vb2dhkJDLXTF13xgmxtYYKqxs0iE3NRcTNG6ftMjhk141DqVGE5B9Jg7a7dF038
bFniFT67v2vofbvtSl1RnS1AfVKliqyzE4keuEr3PQ5g71zuP+pKv4MyHZY/sPO6
ilK+3/bLpmrWX1DDwOB0izskYt/WXA4rafbLMklDYYtH1Nso7Alq3XBQ9aQKCYYZ
+lLMjyOS7ILUVq6VCODbb/UdZUWaaucKYfLQ01bUCdsYd1vXVFuoRAPqpeJy73pz
j2f7SgS9BkFUGZDqha6tq4rrWn4ifau1+Y7ESrJZd5b2mgLOXA9J2fqSxCuCsWZu
79PZIG5Fb4sxaoIow961K9p+d+u0RdzJJdzLo3U21S4oSbA0MSbK1JD7t+bDfA0S
tfHduOdno4kr0qrB6pZ+6SUDS45ZJ7Q18fK3jm2PzuRVh9H2k16rzyeG9EEdFhEY
xzX3WfF2FNlwPv5D0uClw7LhqvC26eouPy1TGB/2tJQ8dH66bhOEDCgtHzTj33YF
tB4wYjNIAsXNEvyRWiNC7V2fZfAgoZp2P2dum7Nsd9YLW+j5nBUPEaryTYZbMobz
OqR4NydE8Bk=
=YnhK
-----END PGP SIGNATURE-----

--=-NqKvvJEGJshS8ieAbH2j--
