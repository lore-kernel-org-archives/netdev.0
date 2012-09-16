From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 1/2] net: provide a default dev->ethtool_ops
Date: Sun, 16 Sep 2012 23:35:53 +0100
Message-ID: <1347834953.4836.11.camel@deadeye.wl.decadent.org.uk>
References: <1347607441.8555.265.camel@edumazet-glaptop>
	 <1347716447.13258.101.camel@deadeye.wl.decadent.org.uk>
	 <1347823046.26523.44.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:39330 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751961Ab2IPWgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2012 18:36:02 -0400
In-Reply-To: <1347823046.26523.44.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-09-16 at 21:17 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> On Sat, 2012-09-15 at 14:40 +0100, Ben Hutchings wrote:
>=20
> > >  	strcpy(dev->name, name);
> > >  	dev->group =3D INIT_NETDEV_GROUP;
> > > +	if (!dev->ethtool_ops) {
> > > +		static const struct ethtool_ops default_ethtool_ops;
> > > +
> > > +		dev->ethtool_ops =3D &default_ethtool_ops;
> > > +	}
> >=20
> > This block has a blank line in it, so I think it needs a blank line
> > either side to make the visual grouping of code right.  Alternately=
 you
> > could pull the variable out of the block.
> >=20
>=20
> Blank line is preferred after a variable declaration in a function.

Yes but:

	when the previous statement is right next to;
	the start of the block {
		the variable declaration is visually grouped with that;

		rather than with the statement that uses it;
	}

> I dont feel the need to make this variable visible outside of this
> function yet. But if you feel it, no problem.
>
> > [...]=20
> > > @@ -1410,8 +1409,9 @@ static int ethtool_get_module_eeprom(struct=
 net_device *dev,
> > >  				      modinfo.eeprom_len);
> > >  }
> > > =20
> > > -/* The main entry point in this file.  Called from net/core/dev.=
c */
> > > -
> > > +/* The main entry point in this file.  Called from net/core/dev.=
c
> > > + * with RTNL held.
> > > + */
> >=20
> > Good point but an unrelated change.
>=20
> Its related, because I wanted to make clear (at least for me)
> why assuming dev->ethtool_ops was not NULL at this point was valid.

So we know it won't change under us?  But that is also true of
dev->netdev_ops, which is often used with a finer-grained lock.

> > >  int dev_ethtool(struct net *net, struct ifreq *ifr)
> > >  {
> > >  	struct net_device *dev =3D __dev_get_by_name(net, ifr->ifr_name=
);
> > > @@ -1419,25 +1419,15 @@ int dev_ethtool(struct net *net, struct i=
freq *ifr)
> > >  	u32 ethcmd;
> > >  	int rc;
> > >  	u32 old_features;
> > > +	const struct ethtool_ops *ops;
> > > =20
> > >  	if (!dev || !netif_device_present(dev))
> > >  		return -ENODEV;
> > > =20
> > > +	ops =3D dev->ethtool_ops;
> > [...]
> >=20
> > Introducing this local variable is a useful cleanup but again shoul=
d be
> > a separate change.
>=20
> Its a patch meant for net-next, and a cleanup. I could understand you=
r
> point if we had to backport this to stable trees, buts its not the
> case ?
>=20
> I really dont care, so if you really prefer I dont cleanup ethtool.c,=
 so
> be it.
>
> Some functions test dev->ethtool_ops is NULL, others lack this test.
> This just makes no sense to me, maybe there is something I missed.

Most of those checks are probably redundant, and I see no problem with
your removing them.  It was just that you were also changing various
other references to dev->ethtool_ops to use local variables.

> Thanks
>=20
> [PATCH v2 net-next] net: provide a default dev->ethtool_ops
>=20
> Instead of forcing device drivers to provide empty ethtool_ops or twe=
ak
> net/core/ethtool.c again, we could provide a generic ethtool_ops.
>=20
> This occurred to me when I wanted to add GSO support to GRE tunnels.
> ethtool -k support should be generic for all drivers.
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
>  net/core/dev.c     |    4 ++++
>  net/core/ethtool.c |   12 ------------
>  2 files changed, 4 insertions(+), 12 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index dcc673d..2bcb02c 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5959,6 +5959,8 @@ struct netdev_queue *dev_ingress_queue_create(s=
truct net_device *dev)
>  	return queue;
>  }
> =20
> +static const struct ethtool_ops default_ethtool_ops;
> +
>  /**
>   *	alloc_netdev_mqs - allocate network device
>   *	@sizeof_priv:	size of private data to allocate space for
> @@ -6046,6 +6048,8 @@ struct net_device *alloc_netdev_mqs(int sizeof_=
priv, const char *name,
> =20
>  	strcpy(dev->name, name);
>  	dev->group =3D INIT_NETDEV_GROUP;
> +	if (!dev->ethtool_ops)
> +		dev->ethtool_ops =3D &default_ethtool_ops;
>  	return dev;
> =20
>  free_all:
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index cbf033d..4d64cc2 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1426,18 +1426,6 @@ int dev_ethtool(struct net *net, struct ifreq =
*ifr)
>  	if (copy_from_user(&ethcmd, useraddr, sizeof(ethcmd)))
>  		return -EFAULT;
> =20
> -	if (!dev->ethtool_ops) {
> -		/* A few commands do not require any driver support,
> -		 * are unprivileged, and do not change anything, so we
> -		 * can take a shortcut to them. */
> -		if (ethcmd =3D=3D ETHTOOL_GDRVINFO)
> -			return ethtool_get_drvinfo(dev, useraddr);
> -		else if (ethcmd =3D=3D ETHTOOL_GET_TS_INFO)
> -			return ethtool_get_ts_info(dev, useraddr);
> -		else
> -			return -EOPNOTSUPP;
> -	}
> -
>  	/* Allow some commands to be done by anyone */
>  	switch (ethcmd) {
>  	case ETHTOOL_GSET:
>=20
>=20

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
