From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v3 03/17] net: ethtool: add new
 ETHTOOL_GSETTINGS/SSETTINGS API
Date: Tue, 01 Dec 2015 01:52:31 +0000
Message-ID: <1448934751.30642.32.camel@decadent.org.uk>
References: <1448921155-24764-1-git-send-email-ddecotig@gmail.com>
	 <1448921155-24764-4-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-87ZacLqBaiVYRAGcabym"
Cc: Eric Dumazet <edumazet@google.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ed Swierk <eswierk@skyportsystems.com>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-api@vger.kernel.org,
	linux-mips@linux-mips.org, fcoe-devel@open-fcoe.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448921155-24764-4-git-send-email-ddecotig@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-87ZacLqBaiVYRAGcabym
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-11-30 at 14:05 -0800, David Decotigny wrote:
> From: David Decotigny <decot@googlers.com>
>=20
> This patch defines a new ETHTOOL_GSETTINGS/SSETTINGS API, handled by
> the new get_ksettings/set_ksettings callbacks. This API provides
> support for most legacy ethtool_cmd fields, adds support for larger
> link mode masks (up to 4064 bits, variable length), and removes
> ethtool_cmd deprecated fields (transceiver/maxrxpkt/maxtxpkt).

As you have to introduce new commands and a new structure, please
include the word 'link' in their names.

[...]
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 653dc9c..6de122d 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -12,6 +12,7 @@
> =C2=A0#ifndef _LINUX_ETHTOOL_H
> =C2=A0#define _LINUX_ETHTOOL_H
> =C2=A0
> +#include=20
> =C2=A0#include=20
> =C2=A0#include=20
> =C2=A0
> @@ -40,9 +41,6 @@ struct compat_ethtool_rxnfc {
> =C2=A0
> =C2=A0#include=20
> =C2=A0
> -extern int __ethtool_get_settings(struct net_device *dev,
> -				=C2=A0=C2=A0struct ethtool_cmd *cmd);
> -
> =C2=A0/**
> =C2=A0 * enum ethtool_phys_id_state - indicator state for physical identi=
fication
> =C2=A0 * @ETHTOOL_ID_INACTIVE: Physical ID indicator should be deactivate=
d
> @@ -97,13 +95,85 @@ static inline u32 ethtool_rxfh_indir_default(u32 inde=
x, u32 n_rx_rings)
> =C2=A0	return index % n_rx_rings;
> =C2=A0}
> =C2=A0
> +#define __ETHTOOL_LINK_MODE_IS_VALID_BIT(indice)	\
> +	((indice) >=3D 0 && (indice) <=3D __ETHTOOL_LINK_MODE_LAST)

'indice'? =C2=A0Shoudn't this be 'index' or 'mode'?

>=20
> +/* number of link mode bits handled internally by kernel */
> +#define __ETHTOOL_LINK_MODE_MASK_NBITS (__ETHTOOL_LINK_MODE_LAST+1)

Spaces around the + sign.

>=20
> +typedef struct {
> +	unsigned long mask[BITS_TO_LONGS(__ETHTOOL_LINK_MODE_MASK_NBITS)];
> +} ethtool_link_mode_mask_t;

checkpatch claims you shouldn't introduce such typedefs.

[...]
>=20
> +/**
> + * struct ethtool_settings - link control and status
> + * This structure deprecates struct %ethtool_cmd.

We do the deprecating; the structures are purely passive.

[...]
>=20
> + * Deprecated fields should be ignored by both users and drivers.

Delete this last paragraph.

[...]
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -352,6 +352,388 @@ static int __ethtool_set_flags(struct net_device *d=
ev, u32 data)
> =C2=A0	return 0;
> =C2=A0}
> =C2=A0
> +/* TODO: remove when %ETHTOOL_GSET/%ETHTOOL_SSET disappear */

Please delete this TODO and all the similar ones; we don't remove
userland APIs just because they're deprecated.

[...]
>=20
> +/* number of 32-bit words to store the user's link mode bitmaps */
> +#define __ETHTOOL_LINK_MODE_MASK_NU32			\
> +	((__ETHTOOL_LINK_MODE_MASK_NBITS + 31) / 32)

Should use DIV_ROUND_UP().

>=20
> +/* layout of the struct passed from/to userland */
> +struct ethtool_usettings {
> +	struct ethtool_settings parent;
> +	struct {
> +		__u32 supported[__ETHTOOL_LINK_MODE_MASK_NU32] __aligned(4);
> +		__u32 advertising[__ETHTOOL_LINK_MODE_MASK_NU32] __aligned(4);
> +		__u32 lp_advertising[
> +			__ETHTOOL_LINK_MODE_MASK_NU32] __aligned(4);

Why __aligned(4)? =C2=A0Do you have any reason to think that some padding
might be added otherwise?

[...]
> +#if BITS_PER_LONG =3D=3D 64
> +static unsigned long _shl32(__u32 v)
> +{
> +	return ((unsigned long)v) << 32;
> +}
> +#endif
> +
> +/* convert a user's __u32[] bitmap in user space to a kernel internal
> + * bitmap. return 0 on success, errno on error. this assumes that
> + * link_mode_masks_nwords was already verified
> + */
> +static int load_ksettings_from_user(struct ethtool_ksettings *to,
> +				=C2=A0=C2=A0=C2=A0=C2=A0const void __user *from)
> +{
> +	struct ethtool_usettings usettings;
> +#if BITS_PER_LONG !=3D 32
> +	unsigned i;
> +#endif
> +
> +	if (copy_from_user(&usettings, from, sizeof(usettings)))
> +		return -EFAULT;
> +
> +	/* make sure we didn't receive garbage between last allowed bit
> +	=C2=A0* and end of last u32 word
> +	=C2=A0*/
> +	if (__ETHTOOL_LINK_MODE_MASK_NBITS % 32) {
> +		const u32 allowed =3D (
> +			1U << (__ETHTOOL_LINK_MODE_MASK_NBITS % 32)) - 1;
> +		if (usettings.link_modes.supported[
> +			=C2=A0=C2=A0=C2=A0=C2=A0__ETHTOOL_LINK_MODE_MASK_NU32 - 1] & ~allowed=
)
> +			return -EINVAL;
> +		if (usettings.link_modes.advertising[
> +			=C2=A0=C2=A0=C2=A0=C2=A0__ETHTOOL_LINK_MODE_MASK_NU32 - 1] & ~allowed=
)
> +			return -EINVAL;
> +		if (usettings.link_modes.lp_advertising[
> +			=C2=A0=C2=A0=C2=A0=C2=A0__ETHTOOL_LINK_MODE_MASK_NU32 - 1] & ~allowed=
)
> +			return -EINVAL;
> +	}
> +
> +#if BITS_PER_LONG =3D=3D 32
> +	compiletime_assert(sizeof(*to) =3D=3D sizeof(usettings),
> +			=C2=A0=C2=A0=C2=A0"sizeof(ulong) !=3D 32");
> +	memcpy(to, &usettings, sizeof(*to));
> +#elif BITS_PER_LONG =3D=3D 64
> +	memset(to, 0, sizeof(*to));

This memset() looks redundant.

> +	memcpy(&to->parent, &usettings.parent, sizeof(to->parent));
> +	for (i =3D 0 ; i < __ETHTOOL_LINK_MODE_MASK_NU32 ; ++i) {
> +		if (0 =3D=3D (i & 1)) {
> +			to->link_modes.supported.mask[i >> 1]
> +				=3D usettings.link_modes.supported[i];
> +			to->link_modes.advertising.mask[i >> 1]
> +				=3D usettings.link_modes.advertising[i];
> +			to->link_modes.lp_advertising.mask[i >> 1]
> +				=3D usettings.link_modes.lp_advertising[i];
> +		} else {
> +			to->link_modes.supported.mask[i >> 1] |=3D _shl32(
> +				usettings.link_modes.supported[i]);
> +			to->link_modes.advertising.mask[i >> 1] |=3D _shl32(
> +				usettings.link_modes.advertising[i]);
> +			to->link_modes.lp_advertising.mask[i >> 1] |=3D _shl32(
> +				usettings.link_modes.lp_advertising[i]);
> +		}
> +	}
> +#else
> +# error "unsupported ulong width"
> +#endif
> +	return 0;
> +}

I think the array conversion ought to be a separate function that you
can call 3 times here, rather than repeating it here. =C2=A0In fact that
could be a general function in lib/bitmap.c.

Similarly for the opposite conversion below.

[...]
> =C2=A0static int ethtool_get_settings(struct net_device *dev, void __user=
 *useraddr)
> =C2=A0{
> -	int err;
> =C2=A0	struct ethtool_cmd cmd;
> =C2=A0
> -	err =3D __ethtool_get_settings(dev, &cmd);
> -	if (err < 0)
> -		return err;
> +	ASSERT_RTNL();
> +
> +	if (dev->ethtool_ops->get_ksettings) {
> +		/* First, use ksettings API if it is supported */
> +		int err;
> +		struct ethtool_ksettings ksettings;
> +
> +		memset(&ksettings, 0, sizeof(ksettings));
> +		err =3D dev->ethtool_ops->get_ksettings(dev, &ksettings);
> +		if (err < 0)
> +			return err;
> +		if (!convert_ksettings_to_legacy_settings(&cmd, &ksettings)) {
> +			static int __warned;
> +
> +			/* not all bitmaps could be translated
> +			=C2=A0* acurately to legacy API: print warning with
> +			=C2=A0* netdev name, but does still succeed
> +			=C2=A0*/
> +			if (!__warned)
> +				netdev_warn(dev, "please upgrade ethtool\n");

ethtool isn't the only program that uses this API, not by a long way.=C2=A0
And since it's the program at fault, not the device, it doesn't make a
lot of sense to use netdev_warn().

So I suggest a message more like that in warn_legacy_capability_use()
in kernel/capability.c.

[...]
> =C2=A0static int ethtool_set_settings(struct net_device *dev, void __user=
 *useraddr)
> =C2=A0{
> =C2=A0	struct ethtool_cmd cmd;
> =C2=A0
> -	if (!dev->ethtool_ops->set_settings)
> -		return -EOPNOTSUPP;
> +	ASSERT_RTNL();
> =C2=A0
> =C2=A0	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
> =C2=A0		return -EFAULT;
> =C2=A0
> +	/* first, try new %ethtool_ksettings API. */
> +	if (dev->ethtool_ops->set_ksettings) {
> +		struct ethtool_ksettings ksettings;
> +
> +		if (!convert_legacy_settings_to_ksettings(&ksettings, &cmd)) {
> +			static int __warned;
> +
> +			/* rejecting setting deprecated fields
> +			=C2=A0* transceiver/maxtxpkt/maxrxpkt
> +			=C2=A0*/
> +			if (!__warned)
> +				netdev_warn(dev, "please upgrade ethtool");

I don't think this makes sense - it's not as if ethtool will
automatically try to set these without it being explicitly requested by
the user. =C2=A0Just return -EINVAL without logging anything.

> +			__warned =3D 1;
> +			return -EINVAL;
> +		}
[...]

Ben.

--=20
Ben Hutchings
Theory and practice are closer in theory than in practice.
                                - John Levine, moderator of comp.compilers
--=-87ZacLqBaiVYRAGcabym
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVlz9YOe/yOyVhhEJAQpmJA//V0APSTTq9TEVF5Jp+C3IZ+YMACpBAPtM
xor/3hJHlvDRNMyUpDwFHRsbwVgdU6oBO+QVuFeMLCSavGKiqxOI53vkKFloJATE
vfc3eZvP45Rr8KcJfBzWvmB+YpldCIsPFtdfkdtUpu6LOmqBdyGxNJUCh6R+4OTb
suAveOpEBXihjgXbecmPWGt6L5V1SVP68boZe4YxQNV/oFsGUbjxA7yGgj1sXFC2
/GPQdyJf82lKH/2HQB4dIO3owmoZYvJKLCtMCVJt/gvPURgWOkVJnAicxmYdY18K
czEoiNiQ/bjVvmuyiepxE7B7XTMKITvdFqjBP0EXU/2ckcH5OBg9bab1E1NdVkwy
vCgWFcrzWugGh+mIfqkHQueB6+vfPMqp48J/hOzwkIsB1gIglRziV4MWasnOoHVx
xcMyUxk5DPt/XNXYze0RNh+kBQCxXKFHi51Eub7qECUGBnygdrS1lyPEbu4Hl5zy
t1L0fXG33odlICJgoxR5miXvsb6ZJzvkqWQsIsswzgSfvN2HJQpSXCp6S7+O5v+z
RB8XUwkD5E16r5MbCj3zSJRm7FDYXbuPVtHzSWztSiU2KATJadwEj9xMfhOhZ8ed
6W3os54czpqceC7eZIcLRCxt+nUxLJ0SmZwIFP34ARdHv5T96+wLnEDx68MqpPPg
OK5m5Qp3ICA=
=lAwL
-----END PGP SIGNATURE-----

--=-87ZacLqBaiVYRAGcabym--
