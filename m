From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFC PATCH 02/12] net: Introduce new feature setting ops
Date: Sun, 19 Dec 2010 01:49:59 +0100
Message-ID: <20101219004959.GA12005@rere.qmqm.pl>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl> <822f5776f99cab9889cd72d658d5fe50c56bb247.1292451559.git.mirq-linux@rere.qmqm.pl> <1292541186.18294.16.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:56396 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752290Ab0LSAuB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Dec 2010 19:50:01 -0500
Content-Disposition: inline
In-Reply-To: <1292541186.18294.16.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 11:13:06PM +0000, Ben Hutchings wrote:
> On Wed, 2010-12-15 at 23:24 +0100, Micha=B3 Miros=B3aw wrote:
> > This introduces a new framework to handle device features setting.
> > It consists of:
> >   - new fields in struct net_device:
> > 	+ hw_features - features that hw/driver supports toggling
> > 	+ wanted_features - features that user wants enabled, when possibl=
e
> >   - new netdev_ops:
> > 	+ feat =3D ndo_fix_features(dev, feat) - API checking constraints =
for
> > 		enabling features or their combinations
> > 	+ ndo_set_features(dev) - API updating hardware state to match
> > 		changed dev->features
> >   - new ethtool commands:
> > 	+ ETHTOOL_GFEATURES/ETHTOOL_SFEATURES: get/set dev->wanted_feature=
s
> > 		and trigger device reconfiguration if resulting dev->features
> > 		changed
> > 	[TODO: this might be extended to support device-specific flags, an=
d
> > 	keep NETIF_F flags from becoming part of ABI by using GET_STRINGS
> > 	for describing the bits]
> We already have ETHTOOL_{G,S}PFLAGS for that, though.

Since we're almost out of bits in features, I thought that I might as w=
ell
just take care of that in one go. I'll implement the GET_STRINGS part t=
o
show what I mean about bits not becoming an ABI.

> > 	[Note: ETHTOOL_GFEATURES and ETHTOOL_SFEATURES' data is supposed t=
o
> > 	be 'compatible', so that you can R/M/W without additional copying]
> But if you expect userland to do that, what is the point of the 'vali=
d'
> mask?  Shouldn't userland do something like:
>=20
> 	struct ethtool_features feat =3D { ETHTOOL_SFEATURES };
> 	...
> 	if (off_tso_wanted >=3D 0)
> 		feat.features[0].valid |=3D NETIF_F_TSO;
> 	if (off_tso_wanted > 0)
> 		feat.features[0].requested |=3D NETIF_F_TSO;
> 	...

That looks even better than what I thought originally. So this means I =
can
just get rid of the combined ethtool cmd struct.

> [...]
> > --- a/include/linux/ethtool.h
> > +++ b/include/linux/ethtool.h
> > @@ -523,6 +523,31 @@ struct ethtool_flash {
> >         char    data[ETHTOOL_FLASH_MAX_FILENAME];
> >  };
> > =20
> > +/* for returning feature sets */
> > +#define ETHTOOL_DEV_FEATURE_WORDS      1
> > +
> > +struct ethtool_get_features_block {
> > +       __u32   available;      /* features togglable */
> > +       __u32   requested;      /* features requested to be enabled=
 */
> > +       __u32   active;         /* features currently enabled */
> > +       __u32   __pad[1];
> > +};
> > +
> > +struct ethtool_set_features_block {
> > +       __u32   valid;          /* bits valid in .requested */
> > +       __u32   requested;      /* features requested */
> > +       __u32   __pad[2];
> > +};
> > +
> > +struct ethtool_features {
> > +       __u32   cmd;
> > +       __u32   count;          /* blocks */
> > +       union {
> > +               struct ethtool_get_features_block get;
> > +               struct ethtool_set_features_block set;
> > +       } features[0];
> > +};
> I want kernel-doc comments with a proper description of semantics.

Will do.

> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> [...]
> > @@ -934,6 +949,14 @@ struct net_device {
> >  				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
> >  				 NETIF_F_FRAGLIST)
> > =20
> > +	/* toggable features with no driver requirements */
> > +#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
> > +
> > +	/* ethtool-toggable features */
>=20
> The verb is 'toggle' so this adjective should be either 'togglable' o=
r
> 'toggleable'.  Or you could choose a different adjective.

'changed'. Or fixed. ;-)

> > +	unsigned long		hw_features;
> > +	/* ethtool-requested features */
> > +	unsigned long		wanted_features;
> > +
> While you're at it, you could change all these 'features' fields and
> parameters to u32, since we presumably won't be defining features tha=
t
> can only be enabled on 64-bit architectures.

Done. I also went through functions that pass features along and fixed
their types. Patch will be in the next version of this series.

> [...]
> > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > index 1774178..f08e7f1 100644
> > --- a/net/core/ethtool.c
> > +++ b/net/core/ethtool.c
> > @@ -171,6 +171,55 @@ EXPORT_SYMBOL(ethtool_ntuple_flush);
> > =20
> >  /* Handlers for each ethtool command */
> > =20
> > +static int ethtool_get_features(struct net_device *dev, void __use=
r *useraddr)
> > +{
> > +	struct ethtool_features cmd =3D {
> > +		.cmd =3D ETHTOOL_GFEATURES,
> > +		.count =3D ETHTOOL_DEV_FEATURE_WORDS,
> > +	};
> > +	struct ethtool_get_features_block features[ETHTOOL_DEV_FEATURE_WO=
RDS] =3D {
> > +		{
> > +			.available =3D dev->hw_features,
> > +			.requested =3D dev->wanted_features,
> > +			.active =3D dev->features,
> > +		},
> > +	};
> > +
> > +	if (copy_to_user(useraddr, &cmd, sizeof(cmd)))
> > +		return -EFAULT;
> > +	useraddr +=3D sizeof(cmd);
> > +	if (copy_to_user(useraddr, features, sizeof(features)))
> > +		return -EFAULT;
> If ETHTOOL_DEV_FEATURE_WORDS increases, how do you know the user buff=
er
> will be big enough?

I'll change that to use count from GET_STRINGS.

> > +	return 0;
> > +}
> > +
> > +static int ethtool_set_features(struct net_device *dev, void __use=
r *useraddr)
> > +{
> > +	struct ethtool_features cmd;
> > +	struct ethtool_set_features_block features[ETHTOOL_DEV_FEATURE_WO=
RDS];
> > +
> > +	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
> > +		return -EFAULT;
> > +	useraddr +=3D sizeof(cmd);
> > +
> > +	if (cmd.count > ETHTOOL_DEV_FEATURE_WORDS)
> > +		cmd.count =3D ETHTOOL_DEV_FEATURE_WORDS;
> So additional feature words will be silently ignored...
> > +	if (copy_from_user(features, useraddr, sizeof(*features) * cmd.co=
unt))
> > +		return -EFAULT;
> > +	memset(features + cmd.count, 0,
> > +		sizeof(features) - sizeof(*features) * cmd.count);
> > +
> > +	features[0].valid &=3D dev->hw_features | NETIF_F_SOFT_FEATURES;
> [...]
>=20
> ...as will any other unsupported features.  This is not a good idea.
> (However, remembering which features are wanted does seem like a good
> idea.)

That's intentional. Unsupported features can't be enabled anyway.
hw_features is supposed to contain all features that the device can sup=
port
and is able to enable/disable. This set should be constant and anything=
 that
is in the wanted_features set but is not supported because of other con=
ditions
will be stripped by ndo_fix_features() call.

Other way would be to return EINVAL when bits not changeable are presen=
t in
the valid mask. I don't want to do that, since then your example of cha=
nging
a feature without GFEATURES first will not work.

Best Regards,
Micha=B3 Miros=B3aw
=20
