From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net-ethtool: Allow ethtool to set interface
 in loopback mode.
Date: Tue, 29 Mar 2011 00:48:43 +0100
Message-ID: <1301356123.27727.41.camel@bwh-desktop>
References: <1301351066-24916-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:45487 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586Ab1C1Xsr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 19:48:47 -0400
In-Reply-To: <1301351066-24916-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm sorry that things keep changing under your feet.  Unfortunately I'm
going to have to ask for more changes; see below.

I'm cc'ing Micha=C5=82 Miros=C5=82aw so he can comment on how he thinks=
 the
generic feature handling should be extended.

On Mon, 2011-03-28 at 15:24 -0700, Mahesh Bandewar wrote:
> Add second word for feature (currently it's single word). Also use th=
e first
> bit of the second word to set the loopback mode. By configuring the i=
nterface
> in loopback mode in conjunction with a policy route / rule, a user-la=
nd
> application can stress the egress / ingress path exposing the flows o=
f the
> change in progress and potentially help developer(s) understand the i=
mpact of
> those changes without even sending a packet out on the network.
>=20
> Following set of commands illustrates one such example -
>     a) ip -4 addr add 192.168.1.1/24 dev eth1
>     b) ip -4 rule add from all iif eth1 lookup 250
>     c) ip -4 route add local 0/0 dev lo proto kernel scope host table=
 250
>     d) arp -Ds 192.168.1.100 eth1
>     e) arp -Ds 192.168.1.200 eth1
>     f) sysctl -w net.ipv4.ip_nonlocal_bind=3D1
>     g) sysctl -w net.ipv4.conf.all.accept_local=3D1
>     # Assuming that the machine has 8 cores
>     h) taskset 000f netserver -L 192.168.1.200
>     i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.168.1.=
200 -l 30
>=20
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  include/linux/ethtool.h |   14 ++++++++++++
>  net/core/ethtool.c      |   54 +++++++++++++++++++++++++++++++++++++=
++++++---
>  2 files changed, 64 insertions(+), 4 deletions(-)
>=20
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index aac3e2e..a42f60c 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -526,6 +526,8 @@ struct ethtool_flash {
> =20
>  /* for returning and changing feature sets */
> =20
> +#define ETHTOOL_DEV_FEATURE_WORDS	2

If this needs to be exposed in ethtool.h, it should be #ifdef
__KERNEL__.  User-space should find out the number of features at
run-time.

>  /**
>   * struct ethtool_get_features_block - block with state of 32 featur=
es
>   * @available: mask of changeable features
> @@ -594,6 +596,8 @@ struct ethtool_sfeatures {
>   *   %ETHTOOL_F_COMPAT - some or all changes requested were made by =
calling
>   *      compatibility functions. Requested offload state cannot be p=
roperly
>   *      managed by kernel.
> + *   %ETHTOOL_F_2NDWORD - some or all changes requested in the secon=
d word of
> + *      the features failed.

Why do you think it is necessary to distinguish between the words?

>   *
>   * Meaning of bits in the masks are obtained by %ETHTOOL_GSSET_INFO =
(number of
>   * bits in the arrays - always multiple of 32) and %ETHTOOL_GSTRINGS=
 commands
> @@ -604,11 +608,13 @@ enum ethtool_sfeatures_retval_bits {
>  	ETHTOOL_F_UNSUPPORTED__BIT,
>  	ETHTOOL_F_WISH__BIT,
>  	ETHTOOL_F_COMPAT__BIT,
> +	ETHTOOL_F_2NDWORD__BIT,
>  };
> =20
>  #define ETHTOOL_F_UNSUPPORTED   (1 << ETHTOOL_F_UNSUPPORTED__BIT)
>  #define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
>  #define ETHTOOL_F_COMPAT        (1 << ETHTOOL_F_COMPAT__BIT)
> +#define ETHTOOL_F_2NDWORD       (1 << ETHTOOL_F_2NDWORD__BIT)
> =20
>  #ifdef __KERNEL__
> =20
> @@ -764,6 +770,8 @@ struct ethtool_ops {
>  				  struct ethtool_rxfh_indir *);
>  	int	(*set_rxfh_indir)(struct net_device *,
>  				  const struct ethtool_rxfh_indir *);
> +	int (*get_loopback)(struct net_device *);
> +	int (*set_loopback)(struct net_device *, u32);

Part of the idea of the 'features' interface is to treat feature flags
uniformly in ethtool.  I think there should be just two driver
operations to get/set all features outside the first word.

[...]
> +static int ethtool_set_secondword_features(struct net_device *dev,
> +		struct ethtool_set_features_block *features)
> +{
> +	int ret =3D 0;
> +
> +	if (features[1].valid & ETHTOOL_LOOPBACK) {
> +		features[1].valid &=3D ~ETHTOOL_LOOPBACK;
> +		if (dev->ethtool_ops->set_loopback) {=09
> +			ret |=3D dev->ethtool_ops->set_loopback(dev,
> +				!!(features[1].requested & ETHTOOL_LOOPBACK));
> +		}
> +	}
> +
> +	return(ret);
> +}

This fails silently if the device doesn't implement set_loopback.

Minor style point: don't use parentheses around the return value.

> +
>  static int ethtool_get_features(struct net_device *dev, void __user =
*useraddr)
>  {
>  	struct ethtool_gfeatures cmd =3D {
> @@ -251,12 +281,19 @@ static int ethtool_get_features(struct net_devi=
ce *dev, void __user *useraddr)
>  			.active =3D dev->features,
>  			.never_changed =3D NETIF_F_NEVER_CHANGE,
>  		},
> +		{
> +			.available =3D ETHTOOL_VALID_2NDWORD_FEATURES,

Should be 0 by default.

> +			.active =3D 0,
> +		},
>  	};
>  	u32 __user *sizeaddr;
>  	u32 copy_size;
> =20
>  	ethtool_get_features_compat(dev, features);
> =20
> +	/* Get 2nd-word features */
> +	ethtool_get_secondword_features(dev, features);
> +

If you define a get_ext_features operation, this could be:

	if (dev->ethtool_ops && dev->ethtool_ops->get_ext_features)
		dev->ethtool_ops->get_ext_features(dev, features);

>  	sizeaddr =3D useraddr + offsetof(struct ethtool_gfeatures, size);
>  	if (get_user(copy_size, sizeaddr))
>  		return -EFAULT;
> @@ -289,14 +326,20 @@ static int ethtool_set_features(struct net_devi=
ce *dev, void __user *useraddr)
>  	if (copy_from_user(features, useraddr, sizeof(features)))
>  		return -EFAULT;
> =20
> -	if (features[0].valid & ~NETIF_F_ETHTOOL_BITS)
> +	if (features[0].valid & ~NETIF_F_ETHTOOL_BITS ||
> +	    features[1].valid & ~ETHTOOL_VALID_2NDWORD_FEATURES)
>  		return -EINVAL;
> =20
>  	if (ethtool_set_features_compat(dev, features))
>  		ret |=3D ETHTOOL_F_COMPAT;
> =20
> -	if (features[0].valid & ~dev->hw_features) {
> +	if (ethtool_set_secondword_features(dev, features))
> +		ret |=3D ETHTOOL_F_2NDWORD;
> +
> +	if ((features[0].valid & ~dev->hw_features) ||
> +	    (features[1].valid & ~ETHTOOL_VALID_2NDWORD_FEATURES)) {

We've already checked features[1].valid against this mask, so it is
pointless to do it again.  What we want to do here is to check against
what the hardware and driver support.  And beyond the first word of
features, we don't know the answer to that.  Maybe dev->hw_features
should be turned into an array?

If you define a set_ext_features operation,
ethtool_set_secondword_features() could be replaced with:

	if (features[1].valid) {
		if (!dev->ethtool_ops || !dev->ethtool_ops->set_ext_features) {
			ret |=3D ETHTOOL_F_UNSUPPORTED;
		} else {
			int ext_ret =3D
				dev->ethtool_ops->set_ext_features(dev, features);
			if (ext_ret < 0)
				return ext_ret;
			ret |=3D ext_ret;
		}
	}

Ben.

>  		features[0].valid &=3D dev->hw_features;
> +		features[1].valid &=3D ETHTOOL_VALID_2NDWORD_FEATURES;
>  		ret |=3D ETHTOOL_F_UNSUPPORTED;
>  	}
> =20
> @@ -346,6 +389,9 @@ static const char netdev_features_strings[ETHTOOL=
_DEV_FEATURE_WORDS * 32][ETH_GS
>  	/* NETIF_F_RXCSUM */          "rx-checksum",
>  	"",
>  	"",
> +
> +	/* 2nd word of features */
> +	/* ETHTOOL_LOOPBACK */        "loopback",
>  };
> =20
>  static int __ethtool_get_sset_count(struct net_device *dev, int sset=
)

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

