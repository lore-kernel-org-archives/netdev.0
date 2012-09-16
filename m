From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: provide a default dev->ethtool_ops
Date: Sun, 16 Sep 2012 21:17:26 +0200
Message-ID: <1347823046.26523.44.camel@edumazet-glaptop>
References: <1347607441.8555.265.camel@edumazet-glaptop>
	 <1347716447.13258.101.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63468 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055Ab2IPTRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2012 15:17:36 -0400
Received: by bkwj10 with SMTP id j10so2133700bkw.19
        for <netdev@vger.kernel.org>; Sun, 16 Sep 2012 12:17:35 -0700 (PDT)
In-Reply-To: <1347716447.13258.101.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

On Sat, 2012-09-15 at 14:40 +0100, Ben Hutchings wrote:

> >  	strcpy(dev->name, name);
> >  	dev->group =3D INIT_NETDEV_GROUP;
> > +	if (!dev->ethtool_ops) {
> > +		static const struct ethtool_ops default_ethtool_ops;
> > +
> > +		dev->ethtool_ops =3D &default_ethtool_ops;
> > +	}
>=20
> This block has a blank line in it, so I think it needs a blank line
> either side to make the visual grouping of code right.  Alternately y=
ou
> could pull the variable out of the block.
>=20

Blank line is preferred after a variable declaration in a function.

I dont feel the need to make this variable visible outside of this
function yet. But if you feel it, no problem.



> [...]=20
> > @@ -1410,8 +1409,9 @@ static int ethtool_get_module_eeprom(struct n=
et_device *dev,
> >  				      modinfo.eeprom_len);
> >  }
> > =20
> > -/* The main entry point in this file.  Called from net/core/dev.c =
*/
> > -
> > +/* The main entry point in this file.  Called from net/core/dev.c
> > + * with RTNL held.
> > + */
>=20
> Good point but an unrelated change.

Its related, because I wanted to make clear (at least for me)
why assuming dev->ethtool_ops was not NULL at this point was valid.

>=20
> >  int dev_ethtool(struct net *net, struct ifreq *ifr)
> >  {
> >  	struct net_device *dev =3D __dev_get_by_name(net, ifr->ifr_name);
> > @@ -1419,25 +1419,15 @@ int dev_ethtool(struct net *net, struct ifr=
eq *ifr)
> >  	u32 ethcmd;
> >  	int rc;
> >  	u32 old_features;
> > +	const struct ethtool_ops *ops;
> > =20
> >  	if (!dev || !netif_device_present(dev))
> >  		return -ENODEV;
> > =20
> > +	ops =3D dev->ethtool_ops;
> [...]
>=20
> Introducing this local variable is a useful cleanup but again should =
be
> a separate change.

Its a patch meant for net-next, and a cleanup. I could understand your
point if we had to backport this to stable trees, buts its not the
case ?

I really dont care, so if you really prefer I dont cleanup ethtool.c, s=
o
be it.

Some functions test dev->ethtool_ops is NULL, others lack this test.
This just makes no sense to me, maybe there is something I missed.

Thanks

[PATCH v2 net-next] net: provide a default dev->ethtool_ops

Instead of forcing device drivers to provide empty ethtool_ops or tweak
net/core/ethtool.c again, we could provide a generic ethtool_ops.

This occurred to me when I wanted to add GSO support to GRE tunnels.
ethtool -k support should be generic for all drivers.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/core/dev.c     |    4 ++++
 net/core/ethtool.c |   12 ------------
 2 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index dcc673d..2bcb02c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5959,6 +5959,8 @@ struct netdev_queue *dev_ingress_queue_create(str=
uct net_device *dev)
 	return queue;
 }
=20
+static const struct ethtool_ops default_ethtool_ops;
+
 /**
  *	alloc_netdev_mqs - allocate network device
  *	@sizeof_priv:	size of private data to allocate space for
@@ -6046,6 +6048,8 @@ struct net_device *alloc_netdev_mqs(int sizeof_pr=
iv, const char *name,
=20
 	strcpy(dev->name, name);
 	dev->group =3D INIT_NETDEV_GROUP;
+	if (!dev->ethtool_ops)
+		dev->ethtool_ops =3D &default_ethtool_ops;
 	return dev;
=20
 free_all:
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index cbf033d..4d64cc2 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1426,18 +1426,6 @@ int dev_ethtool(struct net *net, struct ifreq *i=
fr)
 	if (copy_from_user(&ethcmd, useraddr, sizeof(ethcmd)))
 		return -EFAULT;
=20
-	if (!dev->ethtool_ops) {
-		/* A few commands do not require any driver support,
-		 * are unprivileged, and do not change anything, so we
-		 * can take a shortcut to them. */
-		if (ethcmd =3D=3D ETHTOOL_GDRVINFO)
-			return ethtool_get_drvinfo(dev, useraddr);
-		else if (ethcmd =3D=3D ETHTOOL_GET_TS_INFO)
-			return ethtool_get_ts_info(dev, useraddr);
-		else
-			return -EOPNOTSUPP;
-	}
-
 	/* Allow some commands to be done by anyone */
 	switch (ethcmd) {
 	case ETHTOOL_GSET:
