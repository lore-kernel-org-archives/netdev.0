From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFC PATCH 03/12] net: ethtool: use ndo_fix_features for
	offload setting
Date: Sun, 19 Dec 2010 01:54:04 +0100
Message-ID: <20101219005404.GB12005@rere.qmqm.pl>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl> <b4f8764846cebb2ebaad8c5c3fb86457e11cc8a4.1292451559.git.mirq-linux@rere.qmqm.pl> <1292541829.18294.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:47626 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752543Ab0LSAyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Dec 2010 19:54:05 -0500
Content-Disposition: inline
In-Reply-To: <1292541829.18294.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 11:23:49PM +0000, Ben Hutchings wrote:
> On Wed, 2010-12-15 at 23:24 +0100, Micha=B3 Miros=B3aw wrote:
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > ---
> >  include/linux/netdevice.h |    2 +
> >  net/core/dev.c            |    8 ++
> >  net/core/ethtool.c        |  252 +++++++++++++++++++--------------=
-----------
> >  3 files changed, 119 insertions(+), 143 deletions(-)
> >=20
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 4b20944..7634cab 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -941,6 +941,8 @@ struct net_device {
> >  #define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
> >  #define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
> > =20
> > +#define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO=
_ECN)
> > +
> >  	/*
> >  	 * If one device supports one of these features, then enable them
> >  	 * for all in netdev_increment_features.
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 1e616bb..95d0a49 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -5054,6 +5054,14 @@ unsigned long netdev_fix_features(unsigned l=
ong features, const char *name)
> >  		features &=3D ~NETIF_F_TSO;
> >  	}
> > =20
> > +	/* Software GSO depends on SG. */
> > +	if ((features & NETIF_F_GSO) && !(features & NETIF_F_SG)) {
> > +		if (name)
> > +			printk(KERN_NOTICE "%s: Dropping NETIF_F_GSO since no "
> > +			       "SG feature.\n", name);
> > +		features &=3D ~NETIF_F_GSO;
> > +	}
> > +
> >  	if (features & NETIF_F_UFO) {
> >  		/* maybe split UFO into V4 and V6? */
> >  		if (!((features & NETIF_F_GEN_CSUM) ||
> The severity of these messages will need to be reduced if ethtool rel=
ies
> on this function to propagate feature changes.  (And I wonder why som=
e
> of them are ERR and some NOTICE.)

Patch is ready (all converted to netdev_info).

> > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > index f08e7f1..b068738 100644
> > --- a/net/core/ethtool.c
> > +++ b/net/core/ethtool.c
> > @@ -55,6 +55,7 @@ int ethtool_op_set_tx_csum(struct net_device *dev=
, u32 data)
> > =20
> >  	return 0;
> >  }
> > +EXPORT_SYMBOL(ethtool_op_set_tx_csum);
> > =20
> >  int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data)
> >  {
> > @@ -220,6 +221,85 @@ static int ethtool_set_features(struct net_dev=
ice *dev, void __user *useraddr)
> >  	return 0;
> >  }
> > =20
> > +static unsigned long ethtool_get_feature_mask(u32 eth_cmd)
> > +{
> > +	switch (eth_cmd) {
> > +	case ETHTOOL_GTXCSUM:
> > +	case ETHTOOL_STXCSUM:
> > +		return NETIF_F_ALL_CSUM|NETIF_F_SCTP_CSUM;
> I wonder whether this should cover NETIF_F_FCOE_CRC as well (ixgbe
> currently doesn't seem to allow toggling it).

This mask is only for 'legacy' set_tx_csum ethtool commands. Other
checksumming options - or whatever bits are included in hw_features - c=
an be
toggled by ETHTOOL_SFEATURES.

> There should be spaces around the '|' operator.

=46ixed.

> > +static int __ethtool_set_tx_csum(struct net_device *dev, u32 data)=
;
> > +static int __ethtool_set_sg(struct net_device *dev, u32 data);
> > +static int __ethtool_set_tso(struct net_device *dev, u32 data);
> > +static int __ethtool_set_ufo(struct net_device *dev, u32 data);
> > +
> > +static int ethtool_set_one_feature(struct net_device *dev,
> > +	void __user *useraddr, u32 ethcmd)
> > +{
> > +	struct ethtool_value edata;
> > +	unsigned long mask;
> > +
> > +	if (copy_from_user(&edata, useraddr, sizeof(edata)))
> > +		return -EFAULT;
> > +
> > +	mask =3D ethtool_get_feature_mask(ethcmd);
> > +	mask &=3D dev->hw_features | NETIF_F_SOFT_FEATURES;
> > +	if (mask) {
> > +		if (edata.data)
> > +			dev->wanted_features |=3D mask;
> > +		else
> > +			dev->wanted_features &=3D ~mask;
> > +
> > +		netdev_update_features(dev);
> > +		return 0;
> > +	}
> > +
> > +	switch (ethcmd) {
> > +	case ETHTOOL_STXCSUM:
> > +		return __ethtool_set_tx_csum(dev, edata.data);
> > +	case ETHTOOL_SSG:
> > +		return __ethtool_set_sg(dev, edata.data);
> > +	case ETHTOOL_STSO:
> > +		return __ethtool_set_tso(dev, edata.data);
> > +	case ETHTOOL_SUFO:
> > +		return __ethtool_set_ufo(dev, edata.data);
> > +	default:
> > +		return -EOPNOTSUPP;
> > +	}
> > +}
> [...]
>=20
> This deserves some comments.

Sure.

This is compatibility layer for current ethtool tools, and drivers
not converted to ndo_fix_features() and friends.

Best Regards,
Micha=B3 Miros=B3aw
