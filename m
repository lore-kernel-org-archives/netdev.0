From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 02/12] net: Introduce new feature setting ops
Date: Thu, 16 Dec 2010 23:13:06 +0000
Message-ID: <1292541186.18294.16.camel@bwh-desktop>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
	 <822f5776f99cab9889cd72d658d5fe50c56bb247.1292451559.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:36075 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342Ab0LPXNJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 18:13:09 -0500
In-Reply-To: <822f5776f99cab9889cd72d658d5fe50c56bb247.1292451559.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-15 at 23:24 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> This introduces a new framework to handle device features setting.
> It consists of:
>   - new fields in struct net_device:
> 	+ hw_features - features that hw/driver supports toggling
> 	+ wanted_features - features that user wants enabled, when possible
>   - new netdev_ops:
> 	+ feat =3D ndo_fix_features(dev, feat) - API checking constraints fo=
r
> 		enabling features or their combinations
> 	+ ndo_set_features(dev) - API updating hardware state to match
> 		changed dev->features
>   - new ethtool commands:
> 	+ ETHTOOL_GFEATURES/ETHTOOL_SFEATURES: get/set dev->wanted_features
> 		and trigger device reconfiguration if resulting dev->features
> 		changed
> 	[TODO: this might be extended to support device-specific flags, and
> 	keep NETIF_F flags from becoming part of ABI by using GET_STRINGS
> 	for describing the bits]

We already have ETHTOOL_{G,S}PFLAGS for that, though.

> 	[Note: ETHTOOL_GFEATURES and ETHTOOL_SFEATURES' data is supposed to
> 	be 'compatible', so that you can R/M/W without additional copying]

But if you expect userland to do that, what is the point of the 'valid'
mask?  Shouldn't userland do something like:

	struct ethtool_features feat =3D { ETHTOOL_SFEATURES };
	...
	if (off_tso_wanted >=3D 0)
		feat.features[0].valid |=3D NETIF_F_TSO;
	if (off_tso_wanted > 0)
		feat.features[0].requested |=3D NETIF_F_TSO;
	...

[...]
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -523,6 +523,31 @@ struct ethtool_flash {
>         char    data[ETHTOOL_FLASH_MAX_FILENAME];
>  };
> =20
> +/* for returning feature sets */
> +#define ETHTOOL_DEV_FEATURE_WORDS      1
> +
> +struct ethtool_get_features_block {
> +       __u32   available;      /* features togglable */
> +       __u32   requested;      /* features requested to be enabled *=
/
> +       __u32   active;         /* features currently enabled */
> +       __u32   __pad[1];
> +};
> +
> +struct ethtool_set_features_block {
> +       __u32   valid;          /* bits valid in .requested */
> +       __u32   requested;      /* features requested */
> +       __u32   __pad[2];
> +};
> +
> +struct ethtool_features {
> +       __u32   cmd;
> +       __u32   count;          /* blocks */
> +       union {
> +               struct ethtool_get_features_block get;
> +               struct ethtool_set_features_block set;
> +       } features[0];
> +};

I want kernel-doc comments with a proper description of semantics.

> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
[...]
> @@ -934,6 +949,14 @@ struct net_device {
>  				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
>  				 NETIF_F_FRAGLIST)
> =20
> +	/* toggable features with no driver requirements */
> +#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
> +
> +	/* ethtool-toggable features */

The verb is 'toggle' so this adjective should be either 'togglable' or
'toggleable'.  Or you could choose a different adjective.

> +	unsigned long		hw_features;
> +	/* ethtool-requested features */
> +	unsigned long		wanted_features;
> +

While you're at it, you could change all these 'features' fields and
parameters to u32, since we presumably won't be defining features that
can only be enabled on 64-bit architectures.

[...]
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 1774178..f08e7f1 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -171,6 +171,55 @@ EXPORT_SYMBOL(ethtool_ntuple_flush);
> =20
>  /* Handlers for each ethtool command */
> =20
> +static int ethtool_get_features(struct net_device *dev, void __user =
*useraddr)
> +{
> +	struct ethtool_features cmd =3D {
> +		.cmd =3D ETHTOOL_GFEATURES,
> +		.count =3D ETHTOOL_DEV_FEATURE_WORDS,
> +	};
> +	struct ethtool_get_features_block features[ETHTOOL_DEV_FEATURE_WORD=
S] =3D {
> +		{
> +			.available =3D dev->hw_features,
> +			.requested =3D dev->wanted_features,
> +			.active =3D dev->features,
> +		},
> +	};
> +
> +	if (copy_to_user(useraddr, &cmd, sizeof(cmd)))
> +		return -EFAULT;
> +	useraddr +=3D sizeof(cmd);
> +	if (copy_to_user(useraddr, features, sizeof(features)))
> +		return -EFAULT;

If ETHTOOL_DEV_FEATURE_WORDS increases, how do you know the user buffer
will be big enough?

> +	return 0;
> +}
> +
> +static int ethtool_set_features(struct net_device *dev, void __user =
*useraddr)
> +{
> +	struct ethtool_features cmd;
> +	struct ethtool_set_features_block features[ETHTOOL_DEV_FEATURE_WORD=
S];
> +
> +	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
> +		return -EFAULT;
> +	useraddr +=3D sizeof(cmd);
> +
> +	if (cmd.count > ETHTOOL_DEV_FEATURE_WORDS)
> +		cmd.count =3D ETHTOOL_DEV_FEATURE_WORDS;

So additional feature words will be silently ignored...

> +	if (copy_from_user(features, useraddr, sizeof(*features) * cmd.coun=
t))
> +		return -EFAULT;
> +	memset(features + cmd.count, 0,
> +		sizeof(features) - sizeof(*features) * cmd.count);
> +
> +	features[0].valid &=3D dev->hw_features | NETIF_F_SOFT_FEATURES;
[...]

=2E..as will any other unsupported features.  This is not a good idea.
(However, remembering which features are wanted does seem like a good
idea.)

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

