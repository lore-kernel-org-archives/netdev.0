From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 1/5] net: Introduce new feature setting ops
Date: Sun, 30 Jan 2011 08:24:24 +1000
Message-ID: <1296339864.3477.52.camel@localhost>
References: <cover.1296325509.git.mirq-linux@rere.qmqm.pl>
	 <0d740ad53dd1e096b2b5d27662ca393ce12c7cf7.1296325509.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:16624 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690Ab1A2W1i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jan 2011 17:27:38 -0500
In-Reply-To: <0d740ad53dd1e096b2b5d27662ca393ce12c7cf7.1296325509.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-01-29 at 19:39 +0100, Micha=C5=82 Miros=C5=82aw wrote:
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
> 	+ ETHTOOL_GSTRINGS(ETH_SS_FEATURES): get feature bits names (meaning=
)
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>  include/linux/ethtool.h   |   86 +++++++++++++++++++++++++
>  include/linux/netdevice.h |   44 ++++++++++++-
>  net/core/dev.c            |   47 ++++++++++++--
>  net/core/ethtool.c        |  154 +++++++++++++++++++++++++++++++++++=
++++++----
>  4 files changed, 312 insertions(+), 19 deletions(-)
>=20
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 1908929..b832083 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -251,6 +251,7 @@ enum ethtool_stringset {
>  	ETH_SS_STATS,
>  	ETH_SS_PRIV_FLAGS,
>  	ETH_SS_NTUPLE_FILTERS,
> +	ETH_SS_FEATURES,
>  };
> =20
>  /* for passing string sets for data tagging */
> @@ -523,6 +524,88 @@ struct ethtool_flash {
>  	char	data[ETHTOOL_FLASH_MAX_FILENAME];
>  };
> =20
> +/* for returning and changing feature sets */
> +
> +/**
> + * struct ethtool_get_features_block - block with state of 32 featur=
es
> + * @avaliable: mask of changeable features

Typo, should be @available.

> + * @requested: mask of features requested to be enabled if possible
> + * @active: mask of currently enabled features
> + * @never_changed: mask of never-changeable features

I don't think the description of never_changed is clear enough.  It
should be described as something like:

    Mask of feature flags that are not changeable for any device.

> + */
> +struct ethtool_get_features_block {
> +	__u32	available;	/* features togglable */
> +	__u32	requested;	/* features requested to be enabled */
> +	__u32	active;		/* features currently enabled */
> +	__u32	never_changed;	/* never-changeable features */

Don't comment the fields inline as well as in the kernel-doc.

> +};
> +
> +/**
> + * struct ethtool_gfeatures - command to get state of device's featu=
res
> + * @cmd: command number =3D %ETHTOOL_GFEATURES
> + * @size: in: array size of the features[] array
> + *       out: count of features[] elements filled

The value on output should be the size required to read all features, s=
o
that the caller can discover it easily.

The two lines describing 'size' will be wrapped together when converted
to another format (manual page, HTML...).  You need to use at least a
full stop (period) to separate them.

[...]
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index c7d7074..6490860 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -783,6 +783,16 @@ struct netdev_tc_txq {
>   *	Set hardware filter for RFS.  rxq_index is the target queue index=
;
>   *	flow_id is a flow ID to be passed to rps_may_expire_flow() later.
>   *	Return the filter ID on success, or a negative error code.
> + *
> + * u32 (*ndo_fix_features)(struct net_device *dev, u32 features);
> + *	Modifies features supported by device depending on device-specifi=
c
> + *	constraints. Should not modify hardware state.

I don't think this wording is clear enough.  How about:

    Adjusts the requested feature flags according to device-specific
    constraints, and returns the resulting flags.  Must not modify
    the device state.

[...]
> @@ -954,6 +974,12 @@ struct net_device {
>  #define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
>  #define NETIF_F_FSO		(SKB_GSO_FCOE << NETIF_F_GSO_SHIFT)
> =20
> +	/* Features valid for ethtool to change */
> +	/* =3D all defined minus driver/device-class-related */
> +#define NETIF_F_NEVER_CHANGE	(NETIF_F_VLAN_CHALLENGED | \
> +				  NETIF_F_LLTX | NETIF_F_NETNS_LOCAL)

Shouldn't NETIF_F_NO_CSUM and NETIF_F_HIGHDMA be included in this?  (An=
d
excluded from NETIF_F_ALL_TX_OFFLOADS.)

> +#define NETIF_F_ETHTOOL_BITS	(0x1f3fffff & ~NETIF_F_NEVER_CHANGE)
> +
>  	/* List of features with software fallbacks. */
>  #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
>  				 NETIF_F_TSO6 | NETIF_F_UFO)
> @@ -964,6 +990,12 @@ struct net_device {
>  #define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
>  #define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
> =20
> +#define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_E=
CN)
> +
> +#define NETIF_F_ALL_TX_OFFLOADS	(NETIF_F_ALL_CSUM | NETIF_F_SG | \
> +				 NETIF_F_FRAGLIST | NETIF_F_ALL_TSO | \
> +				 NETIF_F_SCTP_CSUM | NETIF_F_FCOE_CRC)
> +
>  	/*
>  	 * If one device supports one of these features, then enable them
>  	 * for all in netdev_increment_features.
[...]
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ddd5df2..0ccbee6 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
[...]
> @@ -5267,6 +5273,35 @@ u32 netdev_fix_features(struct net_device *dev=
, u32 features)
>  }
>  EXPORT_SYMBOL(netdev_fix_features);
> =20
> +void netdev_update_features(struct net_device *dev)
> +{
> +	u32 features;
> +	int err =3D 0;
> +
> +	features =3D netdev_get_wanted_features(dev);
> +
> +	if (dev->netdev_ops->ndo_fix_features)
> +		features =3D dev->netdev_ops->ndo_fix_features(dev, features);
> +
> +	/* driver might be less strict about feature dependencies */
> +	features =3D netdev_fix_features(dev, features);
> +
> +	if (dev->features =3D=3D features)
> +		return;
> +
> +	netdev_info(dev, "Features changed: 0x%08x -> 0x%08x\n",
> +		dev->features, features);
> +
> +	if (dev->netdev_ops->ndo_set_features)
> +		err =3D dev->netdev_ops->ndo_set_features(dev, features);
> +
> +	if (!err)
> +		dev->features =3D features;
> +	else if (err < 0)
> +		netdev_err(dev, "set_features() failed (%d)\n", err);

The error message should include the feature flags passed, since the
previous informational message may be filtered out.

> +}
> +EXPORT_SYMBOL(netdev_update_features);
> +
>  /**
>   *	netif_stacked_transfer_operstate -	transfer operstate
>   *	@rootdev: the root or lower level device to transfer state from
[...]
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 5984ee0..1420edd 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -55,6 +55,7 @@ int ethtool_op_set_tx_csum(struct net_device *dev, =
u32 data)
> =20
>  	return 0;
>  }
> +EXPORT_SYMBOL(ethtool_op_set_tx_csum);
> =20
>  int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data)
>  {
> @@ -171,6 +172,136 @@ EXPORT_SYMBOL(ethtool_ntuple_flush);
> =20
>  /* Handlers for each ethtool command */
> =20
> +#define ETHTOOL_DEV_FEATURE_WORDS	1
> +
> +static int ethtool_get_features(struct net_device *dev, void __user =
*useraddr)
> +{
> +	struct ethtool_gfeatures cmd =3D {
> +		.cmd =3D ETHTOOL_GFEATURES,
> +		.size =3D ETHTOOL_DEV_FEATURE_WORDS,
> +	};
> +	struct ethtool_get_features_block features[ETHTOOL_DEV_FEATURE_WORD=
S] =3D {
> +		{
> +			.available =3D dev->hw_features,
> +			.requested =3D dev->wanted_features,
> +			.active =3D dev->features,
> +			.never_changed =3D NETIF_F_NEVER_CHANGE,
> +		},
> +	};
> +	u32 __user *sizeaddr;
> +	u32 in_size;
> +
> +	sizeaddr =3D useraddr + offsetof(struct ethtool_gfeatures, size);
> +	if (get_user(in_size, sizeaddr))
> +		return -EFAULT;
> +
> +	if (in_size < ETHTOOL_DEV_FEATURE_WORDS)
> +		return -EINVAL;

I don't think this should be considered invalid.  Instead:

	u32 copy_size;
	...
	copy_size =3D min_t(u32, in_size, ETHTOOL_DEV_FEATURE_WORDS);

> +	if (copy_to_user(useraddr, &cmd, sizeof(cmd)))
> +		return -EFAULT;
> +	useraddr +=3D sizeof(cmd);
> +	if (copy_to_user(useraddr, features, sizeof(features)))

and:

	if (copy_to_user(useraddr, features, copy_size * sizeof(features[0]))

[...]
> +static const char netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS =
* 32][ETH_GSTRING_LEN] =3D {
> +	/* NETIF_F_SG */              "scatter-gather",

SG really means TX DMA gather only, as the driver is responsible for
allocating its own RX buffers.

> +	/* NETIF_F_IP_CSUM */         "tx-checksum-hw-ipv4",
> +	/* NETIF_F_NO_CSUM */         "tx-checksum-local",
> +	/* NETIF_F_HW_CSUM */         "tx-checksum-hw-ip-generic",
> +	/* NETIF_F_IPV6_CSUM */       "tx_checksum-hw-ipv6",
> +	/* NETIF_F_HIGHDMA */         "highdma",
> +	/* NETIF_F_FRAGLIST */        "scatter-gather-fraglist",
> +	/* NETIF_F_HW_VLAN_TX */      "tx-vlan-hw",
> +
> +	/* NETIF_F_HW_VLAN_RX */      "rx-vlan-hw",
> +	/* NETIF_F_HW_VLAN_FILTER */  "rx-vlan-filter",
> +	/* NETIF_F_VLAN_CHALLENGED */ "*vlan-challenged",

Don't mark the unchangeable features specially here; that can be done b=
y
userland.  Actually, I wonder whether they really need descriptions at
all.

> +	/* NETIF_F_GSO */             "generic-segmentation-offload",
> +	/* NETIF_F_LLTX */            "*lockless-tx",
> +	/* NETIF_F_NETNS_LOCAL */     "*netns-local",
> +	/* NETIF_F_GRO */             "generic-receive-offload",
> +	/* NETIF_F_LRO */             "large-receive-offload",
> +
> +	/* NETIF_F_TSO */             "tcp-segmentation-offload",
> +	/* NETIF_F_UFO */             "udp-fragmentation-offload",
> +	/* NETIF_F_GSO_ROBUST */      "gso-robust",
> +	/* NETIF_F_TSO_ECN */         "tcp-ecn-segmentation-offload",
> +	/* NETIF_F_TSO6 */            "ipv6-tcp-segmentation-offload",
> +	/* NETIF_F_FSO */             "fcoe-segmentation-offload",
> +	"",
> +	"",
> +
> +	/* NETIF_F_FCOE_CRC */        "tx-checksum-fcoe-crc",
> +	/* NETIF_F_SCTP_CSUM */       "tx-checksum-sctp",
> +	/* NETIF_F_FCOE_MTU */        "fcoe-mtu",
> +	/* NETIF_F_NTUPLE */          "ntuple-filter",
[...]

I think this should be named 'rx-ntuple-filter'.  TX filtering may be
controlled for related devices (VFs) and is completely separate from
this.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

