From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 1/2] net: provide a default dev->ethtool_ops
Date: Sat, 15 Sep 2012 14:40:47 +0100
Message-ID: <1347716447.13258.101.camel@deadeye.wl.decadent.org.uk>
References: <1347607441.8555.265.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31972 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751165Ab2IONkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 09:40:52 -0400
In-Reply-To: <1347607441.8555.265.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-14 at 09:24 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> Instead of forcing device drivers to provide empty ethtool_ops or twe=
ak
> net/core/ethtool.c again, we could provide a generic ethtool_ops.
>=20
> This occurred to me when I wanted to add GSO support to GRE tunnels.
> ethtool -k support should be generic for all drivers.
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>

Yes, I should have done this ages ago.  Just some nit-picking below:

[...]
> diff --git a/net/core/dev.c b/net/core/dev.c
> index b1e6d63..ff8dcfc 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6045,6 +6045,11 @@ struct net_device *alloc_netdev_mqs(int sizeof=
_priv, const char *name,
> =20
>  	strcpy(dev->name, name);
>  	dev->group =3D INIT_NETDEV_GROUP;
> +	if (!dev->ethtool_ops) {
> +		static const struct ethtool_ops default_ethtool_ops;
> +
> +		dev->ethtool_ops =3D &default_ethtool_ops;
> +	}

This block has a blank line in it, so I think it needs a blank line
either side to make the visual grouping of code right.  Alternately you
could pull the variable out of the block.

[...]=20
> @@ -1410,8 +1409,9 @@ static int ethtool_get_module_eeprom(struct net=
_device *dev,
>  				      modinfo.eeprom_len);
>  }
> =20
> -/* The main entry point in this file.  Called from net/core/dev.c */
> -
> +/* The main entry point in this file.  Called from net/core/dev.c
> + * with RTNL held.
> + */

Good point but an unrelated change.

>  int dev_ethtool(struct net *net, struct ifreq *ifr)
>  {
>  	struct net_device *dev =3D __dev_get_by_name(net, ifr->ifr_name);
> @@ -1419,25 +1419,15 @@ int dev_ethtool(struct net *net, struct ifreq=
 *ifr)
>  	u32 ethcmd;
>  	int rc;
>  	u32 old_features;
> +	const struct ethtool_ops *ops;
> =20
>  	if (!dev || !netif_device_present(dev))
>  		return -ENODEV;
> =20
> +	ops =3D dev->ethtool_ops;
[...]

Introducing this local variable is a useful cleanup but again should be
a separate change.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
