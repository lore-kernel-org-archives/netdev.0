From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v3 net-next 1/2] ethtool: Support for configurable RSS
 hash key
Date: Wed, 05 Mar 2014 23:59:39 +0000
Message-ID: <1394063979.2861.25.camel@deadeye.wl.decadent.org.uk>
References: <1393589141-10597-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
	 <0e1d7b54-dcbd-446d-b1c9-644086da138f@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-RB/FSP8FLJaaI+c2omij"
Cc: netdev@vger.kernel.org
To: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39270 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752444AbaCEX7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 18:59:46 -0500
In-Reply-To: <0e1d7b54-dcbd-446d-b1c9-644086da138f@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RB/FSP8FLJaaI+c2omij
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-02-28 at 17:35 +0530, Venkat Duvvuru wrote:
> This ethtool patch primarily copies the ioctl command data structures
> from/to the User space and invokes the driver hook.

Missing Signed-off-by - unless this was meant to be an RFC.

> ---
>  include/linux/ethtool.h      |   13 +++
>  include/uapi/linux/ethtool.h |   30 +++++++
>  net/core/ethtool.c           |  195 ++++++++++++++++++++++++++++++++++++=
++++++
>  3 files changed, 238 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 0a114d0..f7f5576 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -154,13 +154,23 @@ static inline u32 ethtool_rxfh_indir_default(u32 in=
dex, u32 n_rx_rings)
>   * @reset: Reset (part of) the device, as specified by a bitmask of
>   *	flags from &enum ethtool_reset_flags.  Returns a negative
>   *	error code or zero.
> + * @get_rxfh_key_size: Get the size of the RX flow hash key.
> + *	Returns zero if not supported for this specific device.
>   * @get_rxfh_indir_size: Get the size of the RX flow hash indirection ta=
ble.
>   *	Returns zero if not supported for this specific device.
>   * @get_rxfh_indir: Get the contents of the RX flow hash indirection tab=
le.
>   *	Will not be called if @get_rxfh_indir_size returns zero.
> + * @get_rxfh: Get the contents of the RX flow hash indirection table and=
 hash
> + *	key.
> + *	Will not be called if @get_rxfh_indir_size and @get_rxfh_key_size
> + *	returns zero.

Shouldn't that 'and' be an 'or'?  I.e. this is only called if the driver
exposes both the key and the indirection table.

>   *	Returns a negative error code or zero.
>   * @set_rxfh_indir: Set the contents of the RX flow hash indirection tab=
le.
>   *	Will not be called if @get_rxfh_indir_size returns zero.
> + * @set_rxfh: Set the contents of the RX flow hash indirection table and
> + *	hash key.
> + *	Will not be called if @get_rxfh_indir_size and @get_rxfh_key_size
> + *	returns zero.
>   *	Returns a negative error code or zero.

Similarly here.

>   * @get_channels: Get number of channels.
>   * @set_channels: Set number of channels.  Returns a negative error code=
 or
> @@ -232,7 +242,10 @@ struct ethtool_ops {
>  	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
>  	int	(*flash_device)(struct net_device *, struct ethtool_flash *);
>  	int	(*reset)(struct net_device *, u32 *);
> +	u32	(*get_rxfh_key_size)(struct net_device *);
>  	u32	(*get_rxfh_indir_size)(struct net_device *);
> +	int	(*get_rxfh)(struct net_device *, struct ethtool_rxfh *);
> +	int	(*set_rxfh)(struct net_device *, struct ethtool_rxfh *);
>  	int	(*get_rxfh_indir)(struct net_device *, u32 *);
>  	int	(*set_rxfh_indir)(struct net_device *, const u32 *);
>  	void	(*get_channels)(struct net_device *, struct ethtool_channels *);
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index fd161e9..675d2fe 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -847,6 +847,33 @@ struct ethtool_rxfh_indir {
>  };
> =20
>  /**
> + * struct ethtool_rxfh - command to get or set RX flow hash indirection =
or/and
> + * hash key.

The summary has to be a single physical line - this is a limitation of
the kernel-doc format.

> + * @cmd: Specific command number - %ETHTOOL_GRSSH or %ETHTOOL_SRSSH
> + * @indir_size: On entry, the array size of the user buffer, which may b=
e zero.
> + *		On return from %ETHTOOL_GRSSH, the array size of the hardware
> + *		indirection table.
> + * @key_size:	On entry, the array size of the user buffer in bytes,
> + *		which may be zero.
> + *		On return from %ETHTOOL_GRSSH, the size of the RSS hash key.
> + * @rsvd:	Reserved for future extensions.
> + * @rss_config: RX ring/queue index for each hash value or/and hash key
> + *		respectively.
> + *
> + * For %ETHTOOL_GRSSH, a @indir_size and key_size of zero means that onl=
y the
> + * size should be returned.  For %ETHTOOL_SRSSH, a @indir_size of zero m=
eans
> + * the indir table should be reset to default values.  This last feature
> + * is not supported by the original implementations.

You need to explain how the indirection table and key are arranged in
memory, both for userland and for drivers that implement the related
operations (if they are passed this structure, which I think they
shouldn't be - see below).

> + */
> +struct ethtool_rxfh {
> +	__u32   cmd;
> +	__u32   indir_size;
> +	__u32   key_size;
> +	__u32	rsvd[3];
> +	__u32   rss_config[0];
> +};
> +
> +/**
>   * struct ethtool_rx_ntuple_flow_spec - specification for RX flow filter
>   * @flow_type: Type of match to perform, e.g. %TCP_V4_FLOW
>   * @h_u: Flow field values to match (dependent on @flow_type)
> @@ -1118,6 +1145,9 @@ enum ethtool_sfeatures_retval_bits {
>  #define ETHTOOL_GEEE		0x00000044 /* Get EEE settings */
>  #define ETHTOOL_SEEE		0x00000045 /* Set EEE settings */
> =20
> +#define ETHTOOL_GRSSH		0x00000046 /* Get RX flow hash configuration */
> +#define ETHTOOL_SRSSH		0x00000047 /* Set RX flow hash configuration */
> +
>  /* compatibility with older code */
>  #define SPARC_ETH_GSET		ETHTOOL_GSET
>  #define SPARC_ETH_SSET		ETHTOOL_SSET
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 30071de..06d3213 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -667,6 +667,194 @@ out:
>  	return ret;
>  }
> =20
> +static noinline_for_stack int ethtool_get_rxfh(struct net_device *dev,
> +					       void __user *useraddr)
> +{
> +	int ret;
> +	struct ethtool_rxfh *rss_info;
> +	const struct ethtool_ops *ops =3D dev->ethtool_ops;
> +	u32 user_indir_size =3D 0, user_key_size =3D 0;
> +	u32 dev_indir_size =3D 0, dev_key_size =3D 0;
> +	u32 total_size;
> +	u32 indir_offset, indir_bytes;
> +	u32 key_offset;
> +
> +	if (!(dev->ethtool_ops->get_rxfh_indir_size ||
> +	      dev->ethtool_ops->get_rxfh_key_size ||
> +	      dev->ethtool_ops->get_rxfh))
> +		return -EOPNOTSUPP;

This condition is not quite right - it should be:

	if (!(dev->ethtool_ops->get_rxfh_indir_size ||
	      dev->ethtool_ops->get_rxfh_key_size) ||
	    !dev->ethtool_ops->get_rxfh)

> +	if (ops->get_rxfh_indir_size)
> +		dev_indir_size =3D ops->get_rxfh_indir_size(dev);
> +
> +	if (dev_indir_size) {

Why is this conditional?  If the device doesn't support an indirection
table then we should still write back a size of 0.

> +		indir_offset =3D offsetof(struct ethtool_rxfh, indir_size);
> +
> +		if (copy_from_user(&user_indir_size,
> +				   useraddr + indir_offset,
> +				   sizeof(user_indir_size)))
> +			return -EFAULT;
> +
> +		if (copy_to_user(useraddr + indir_offset,
> +				 &dev_indir_size, sizeof(dev_indir_size)))
> +			return -EFAULT;=20
> +	}
> +
> +	if (ops->get_rxfh_key_size)
> +		dev_key_size =3D ops->get_rxfh_key_size(dev);
> +
> +	if ((dev_key_size + dev_indir_size) =3D=3D 0)
> +		return -EOPNOTSUPP;
> +
> +	if (dev_key_size) {

Similarly here, if the device doesn't allow changing the key.

[...]
> +	indir_bytes =3D user_indir_size * sizeof(rss_info->rss_config[0]);
> +	total_size =3D indir_bytes + user_key_size;
> +	rss_info =3D kzalloc(total_size, GFP_USER);
> +	if (!rss_info)
> +		return -ENOMEM;

This doesn't make sense.  You allocate a buffer big enough to hold just
the indirection table and key, but then treat the pointer as pointing to
a full command structure.

> +	rss_info->indir_size =3D user_indir_size;
> +	rss_info->key_size =3D user_key_size;
> +	ret =3D dev->ethtool_ops->get_rxfh(dev, rss_info);

I think it would be better to pass the driver two separate pointers into
the buffer, one for the indirection table and one for the key.

[...]
> +static noinline_for_stack int ethtool_set_rxfh(struct net_device *dev,
> +					       void __user *useraddr)
> +{
> +	int ret;
> +	const struct ethtool_ops *ops =3D dev->ethtool_ops;
> +	struct ethtool_rxnfc rx_rings;
> +	struct ethtool_rxfh *rss_info;
> +	u32 user_indir_size =3D 0, dev_indir_size =3D 0, i;
> +	u32 user_key_size =3D 0, dev_key_size =3D 0;
> +	u32 *indir, indir_bytes =3D 0;
> +	u32 indir_offset, key_offset;
> +	u32 rss_cfg_offset =3D offsetof(struct ethtool_rxfh, rss_config[0]);
> +
> +	if (!(ops->get_rxfh_indir_size || ops->set_rxfh ||
> +	      ops->get_rxnfc || ops->get_rxfh_key_size))
> +		return -EOPNOTSUPP;

I think this should be:

	if (!(ops->get_rxfh_indir_size || ops->get_rxfh_key_size) ||
	    !ops->set_rxfh || !ops->get_rxnfc)

> +	if (ops->get_rxfh_indir_size)
> +		dev_indir_size =3D ops->get_rxfh_indir_size(dev);
> +
> +	if (dev_indir_size) {
> +		indir_offset =3D offsetof(struct ethtool_rxfh, indir_size);
> +		if (copy_from_user(&user_indir_size,
> +				   useraddr + indir_offset,
> +				   sizeof(user_indir_size)))
> +			return -EFAULT;
> +	}

You should copy and check the specified size anyway, otherwise an
attempt to set unsupported RSS parameters may be silently ignored.

> +	if (ops->get_rxfh_key_size)
> +		dev_key_size =3D dev->ethtool_ops->get_rxfh_key_size(dev);
> +
> +	if ((dev_key_size + dev_indir_size) =3D=3D 0)
> +		return -EOPNOTSUPP;
> +
> +	if (dev_key_size) {
> +		key_offset =3D offsetof(struct ethtool_rxfh, key_size);
> +		if (copy_from_user(&user_key_size,
> +				   useraddr + key_offset,
> +				   sizeof(user_key_size)))
> +			return -EFAULT;
> +	}

Similarly here.

> +	if (!user_indir_size && !user_key_size)
> +		return -EINVAL;

Isn't that a valid way to reset the RSS configuration to default?

> +	if ((user_indir_size && ((user_indir_size !=3D 0xDEADBEEF) &&
> +				 user_indir_size !=3D dev_indir_size)) ||
> +	    (user_key_size && (user_key_size !=3D dev_key_size)))
> +		return -EINVAL;
> +
> +	if (user_indir_size && user_indir_size !=3D 0xDEADBEEF)
> +		indir_bytes =3D user_indir_size * sizeof(rss_info->rss_config[0]);

Why is 0xDEADBEEF special?

> +	rss_info =3D kzalloc(indir_bytes + user_key_size, GFP_USER);
> +	if (!rss_info)
> +		return -ENOMEM;

This buffer is too small.

> +	rx_rings.cmd =3D ETHTOOL_GRXRINGS;
> +	ret =3D ops->get_rxnfc(dev, &rx_rings, NULL);
> +	if (ret)
> +		goto out;
> +
> +	rss_info->indir_size =3D user_indir_size;
> +	rss_info->key_size =3D user_key_size;
> +
> +	indir =3D rss_info->rss_config;
> +	if (user_indir_size && user_indir_size !=3D 0xDEADBEEF) {
> +		if (copy_from_user(indir,
> +				   useraddr + rss_cfg_offset,
> +				   user_indir_size * sizeof(indir[0]))) {
> +			ret =3D -EFAULT;
> +			goto out;
> +		}
> +
> +		/* Validate ring indices */
> +		for (i =3D 0; i < user_indir_size; i++) {
> +			if (indir[i] >=3D rx_rings.data) {
> +				ret =3D -EINVAL;
> +				goto out;
> +			}
> +		}
> +	} else if (user_indir_size =3D=3D 0) {
> +		for (i =3D 0; i < dev_indir_size; i++)
> +			indir[i] =3D ethtool_rxfh_indir_default(i, rx_rings.data);
> +	} else {
> +		rss_info->indir_size =3D 0;
> +	}
[...]

This is largely duplicated from ethtool_set_rxfh_indir(), so please put
it in a common function.

Ben.

--=20
Ben Hutchings
For every complex problem
there is a solution that is simple, neat, and wrong.

--=-RB/FSP8FLJaaI+c2omij
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxe6a+e/yOyVhhEJAQrl7g/6AlxI8MQ5AIKbMbq6wm9EInShHbKJDYy1
AvRRjYbK4KzA4BNJDUWg+DoINvkmhIwOPyxhCZ7rvBO/adkkKPqRuPtCRP2w0Y/v
BYQob5bH1J3wo/zNYb5GR2kkwzILx/geUiI5g3MXU+4mh5tePKgmAplud6byEVp9
JnbvpwHubwrMhvZ88rVZ37OpUXRfQ9/2E4w4pcPOedNav7n/bzOwyyEWDeDz9NpS
luxc1DgamUmCx0Xay+3/dONGXbszZdlkB1yUrIg0BNYLi+dqiAQgwtqKxl9r3Sjz
Q7LZI7cLrtjHMvB0GDm+y4tNesFN7/xCLcqO5J1nOUYJhY0hWStze1MkQmQ9C5Qi
a5AxReG8FRSOlp1ALSjDudDXDp1zd4gtR2YFEYSeU/XgxtgNCdv2HU2FSTuIlt6e
EfdljdjP4015jNF2jiNIri8RHtBjcjvlMvLn8dvX8miOX0Rx0CtOUnm1Nc8VNR3b
yOHid8d/QaWis+lxvRAwlUIU9bekUFGtIGodFeNXdHYz7ZHHOPwczDk9fu0G2mY5
GTdK0wR0Sm4Icvd9boyOKnqZ5pVgxv2coxMa24r51rw/qo/n1BBBS67ElB44rDFs
b7pcl+6pQHbQQ9uYbcEUT5oghbhPRXWpKxUFPqxe9KHgHmOul9npQt3/Egx4Pj7P
SgBVGJDiFLc=
=mJ7M
-----END PGP SIGNATURE-----

--=-RB/FSP8FLJaaI+c2omij--
