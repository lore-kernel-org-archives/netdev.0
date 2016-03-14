From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v4 10/11] ethtool.c: add support for
 ETHTOOL_xLINKSETTINGS ioctls
Date: Mon, 14 Mar 2016 01:32:36 +0000
Message-ID: <1457919156.3331.90.camel@decadent.org.uk>
References: <1457719104-39188-1-git-send-email-ddecotig@gmail.com>
	 <1457719104-39188-11-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ie5zhgkiSNapF8fj+VjD"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42580 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750701AbcCNBcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 21:32:46 -0400
In-Reply-To: <1457719104-39188-11-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Ie5zhgkiSNapF8fj+VjD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-11 at 09:58 -0800, David Decotigny wrote:
[...]
> +static int parse_hex_u32_bitmap(const char *s,
> +				unsigned int nbits, u32 *result)
> +{
> +	const unsigned nwords =3D __KERNEL_DIV_ROUND_UP(nbits, 32);
> +	size_t slen =3D strlen(s);
> +	size_t i;
> +
> +	/* ignore optional '0x' prefix */
> +	if ((slen > 2) && (
> +		=C2=A0=C2=A0=C2=A0=C2=A0(0 =3D=3D memcmp(s, "0x", 2)
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|| (0 =3D=3D memcmp(s, "0X", 2))))) {

memcmp() is a really poor tool for comparing strings. =C2=A0You should use
strncasecmp() here.

> +		slen -=3D 2;
> +		s +=3D 2;
> +	}
> +
> +	if (slen > 8*nwords)=C2=A0=C2=A0/* up to 2 digits per byte */

The '*' operator should have spaces around it. =C2=A0Please run
checkpatch.pl over your ethtool patches to catch style errors like this
(there are many others in this one).

[...]
> +static void dump_link_caps(const char *prefix, const char *an_prefix,
> +			=C2=A0=C2=A0=C2=A0const u32 *mask, int link_mode_only)
> =C2=A0{
> =C2=A0	static const struct {
> =C2=A0		int same_line; /* print on same line as previous */
> -		u32 value;
> +		unsigned bit_indice;

bit_index

[...]
> @@ -558,51 +655,57 @@ dump_link_caps(const char *prefix, const char *an_p=
refix, u32 mask,
> =C2=A0		}
> =C2=A0	}
> =C2=A0	if (did1 =3D=3D 0)
> -		=C2=A0fprintf(stdout, "Not reported");
> +		fprintf(stdout, "Not reported");

Good catch, but whitespace fixes belong in another patch.

[...]

> @@ -2248,10 +2360,219 @@ static int do_sfeatures(struct cmd_context *ctx)
> =C2=A0	return 0;
> =C2=A0}
> =C2=A0
> -static int do_gset(struct cmd_context *ctx)
> +static struct ethtool_link_usettings *
> +__do_ioctl_glinksettings(struct cmd_context * ctx)
> +{
> +	int err;
> +	struct {
> +		struct ethtool_link_settings req;
> +		__u32 link_mode_data[3*__ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NU32];
> +	} ecmd;
> +	struct ethtool_link_usettings *link_usettings;
> +	unsigned u32_offs;
> +
> +	/* handshake with kernel to determine number of words for link
> +	=C2=A0* mode bitmaps */
> +	memset(&ecmd, 0, sizeof(ecmd));
> +	ecmd.req.cmd =3D ETHTOOL_GLINKSETTINGS;
> +	err =3D send_ioctl(ctx, &ecmd);
> +	if (err < 0)
> +		return NULL;
> +
> +	if (ecmd.req.link_mode_masks_nwords >=3D 0 || ecmd.req.cmd)
> +		return NULL;

Oops, I missed the kernel side of this. =C2=A0Clearing the cmd field is a
very strange thing to do and inconsistent with every other ethtool
command, so I've just sent a patch to change the kernel side of that.
You'll need to change this to match.

(I also think the negative size is a bit weird, but don't feel so
strongly about it.)

[...]
> +	link_usettings =3D malloc(sizeof(*link_usettings));
> +	if (NULL =3D=3D link_usettings)

Comparison is the wrong way round.

> +		return NULL;
> +
> +	memset(link_usettings, 0, sizeof(*link_usettings));

Could use calloc() instead of malloc() + memset().

> +	/* keep transceiver 0 */
> +	memcpy(&link_usettings->base, &ecmd.req, sizeof(link_usettings->base));
> +	/* remember that ETHTOOL_GLINKSETTINGS was used */
> +	link_usettings->base.cmd =3D ETHTOOL_GLINKSETTINGS;

This is redundant as we know that ecmd.req.cmd =3D=3D
ETHTOOL_GLINKSETTINGS.

[...]
> +static struct ethtool_link_usettings *
> +__do_ioctl_gset(struct cmd_context * ctx)
> =C2=A0{
[...]
> +	link_usettings->base.link_mode_masks_nwords =3D 1;
> +	link_usettings->link_modes.supported[0] =3D ecmd.supported;
> +	link_usettings->link_modes.advertising[0] =3D ecmd.advertising;
> +	link_usettings->link_modes.lp_advertising[0] =3D ecmd.lp_advertising;
> +	link_usettings->base.speed =3D ethtool_cmd_speed(&ecmd);
> +	link_usettings->base.duplex =3D ecmd.duplex;
> +	link_usettings->base.port =3D ecmd.port;
> +	link_usettings->base.phy_address =3D ecmd.phy_address;
> +	link_usettings->deprecated.transceiver =3D ecmd.transceiver;
> +	link_usettings->base.autoneg =3D ecmd.autoneg;
> +	link_usettings->base.mdio_support =3D ecmd.mdio_support;
> +	/* ignored (fully deprecated): maxrxpkt, maxtxpkt */
> +	link_usettings->base.eth_tp_mdix =3D ecmd.eth_tp_mdix;
> +	link_usettings->base.eth_tp_mdix_ctrl =3D ecmd.eth_tp_mdix_ctrl;
> +	link_usettings->deprecated.transceiver =3D ecmd.transceiver;

Duplicate assignment.

> +	return link_usettings;
> +}
> +
> +static bool ethtool_link_mode_is_backward_compatible(
> +	const u32 *mask)

Don't wrap function parameter lists or statements that are already
under 80 characters.

[...]
> +static void
> +__free_link_usettings(struct ethtool_link_usettings *link_usettings) {
> +	free(link_usettings);
> +}

Is this function ever likely to do more than just free()? =C2=A0If not,
don't bother abstracting that.

[...]
> @@ -2469,75 +2799,88 @@ static int do_sset(struct cmd_context *ctx)
> =C2=A0		}
> =C2=A0	}
> =C2=A0
> -	if (full_advertising_wanted < 0) {
> +	if (NULL =3D=3D full_advertising_wanted) {
> =C2=A0		/* User didn't supply a full advertisement bitfield:
> =C2=A0		=C2=A0* construct one from the specified speed and duplex.
> =C2=A0		=C2=A0*/
> +		int adv_bit =3D -1;
> +
> =C2=A0		if (speed_wanted =3D=3D SPEED_10 && duplex_wanted =3D=3D DUPLEX_H=
ALF)
> -			advertising_wanted =3D ADVERTISED_10baseT_Half;
> +			adv_bit =3D ETHTOOL_LINK_MODE_10baseT_Half_BIT;
> =C2=A0		else if (speed_wanted =3D=3D SPEED_10 &&
> =C2=A0			=C2=A0duplex_wanted =3D=3D DUPLEX_FULL)
> -			advertising_wanted =3D ADVERTISED_10baseT_Full;
> +			adv_bit =3D ETHTOOL_LINK_MODE_10baseT_Full_BIT;
> =C2=A0		else if (speed_wanted =3D=3D SPEED_100 &&
> =C2=A0			=C2=A0duplex_wanted =3D=3D DUPLEX_HALF)
> -			advertising_wanted =3D ADVERTISED_100baseT_Half;
> +			adv_bit =3D ETHTOOL_LINK_MODE_100baseT_Half_BIT;
> =C2=A0		else if (speed_wanted =3D=3D SPEED_100 &&
> =C2=A0			=C2=A0duplex_wanted =3D=3D DUPLEX_FULL)
> -			advertising_wanted =3D ADVERTISED_100baseT_Full;
> +			adv_bit =3D ETHTOOL_LINK_MODE_100baseT_Full_BIT;
> =C2=A0		else if (speed_wanted =3D=3D SPEED_1000 &&
> =C2=A0			=C2=A0duplex_wanted =3D=3D DUPLEX_HALF)
> -			advertising_wanted =3D ADVERTISED_1000baseT_Half;
> +			adv_bit =3D ETHTOOL_LINK_MODE_1000baseT_Half_BIT;
> =C2=A0		else if (speed_wanted =3D=3D SPEED_1000 &&
> =C2=A0			=C2=A0duplex_wanted =3D=3D DUPLEX_FULL)
> -			advertising_wanted =3D ADVERTISED_1000baseT_Full;
> +			adv_bit =3D ETHTOOL_LINK_MODE_1000baseT_Full_BIT;
> =C2=A0		else if (speed_wanted =3D=3D SPEED_2500 &&
> =C2=A0			=C2=A0duplex_wanted =3D=3D DUPLEX_FULL)
> -			advertising_wanted =3D ADVERTISED_2500baseX_Full;
> +			adv_bit =3D ETHTOOL_LINK_MODE_2500baseX_Full_BIT;
> =C2=A0		else if (speed_wanted =3D=3D SPEED_10000 &&
> =C2=A0			=C2=A0duplex_wanted =3D=3D DUPLEX_FULL)
> -			advertising_wanted =3D ADVERTISED_10000baseT_Full;
> -		else
> -			/* auto negotiate without forcing,
> -			=C2=A0* all supported speed will be assigned below
> -			=C2=A0*/
> -			advertising_wanted =3D 0;
> +			adv_bit =3D ETHTOOL_LINK_MODE_10000baseT_Full_BIT;
> +
> +		if (adv_bit >=3D 0) {
> +			advertising_wanted =3D _mask_advertising_wanted;

If I'm not mistaken, _mask_advertising_wanted is uninitialised at this
point so you need to clear it before setting the one bit.

> +			ethtool_link_mode_set_bit(
> +				adv_bit, advertising_wanted);
[...]
> @@ -2549,37 +2892,56 @@ static int do_sset(struct cmd_context *ctx)
> =C2=A0				fprintf(stderr,	"\n");
> =C2=A0			}
> =C2=A0			if (autoneg_wanted =3D=3D AUTONEG_ENABLE &&
> -			=C2=A0=C2=A0=C2=A0=C2=A0advertising_wanted =3D=3D 0) {
> +			=C2=A0=C2=A0=C2=A0=C2=A0NULL =3D=3D advertising_wanted) {
> +				unsigned int i;
> +
> =C2=A0				/* Auto negotiation enabled, but with
> =C2=A0				=C2=A0* unspecified speed and duplex: enable all
> =C2=A0				=C2=A0* supported speeds and duplexes.
> =C2=A0				=C2=A0*/
> -				ecmd.advertising =3D
> -					(ecmd.advertising &
> -					=C2=A0~ALL_ADVERTISED_MODES) |
> -					(ALL_ADVERTISED_MODES & ecmd.supported);
> +				ethtool_link_mode_for_each_u32(i)
> +				{

Brace belongs on the previous line (everywhere you use
ethtool_link_mode_for_each_u32()).

[...]
> -			} else if (advertising_wanted > 0) {
> +			} else if (NULL !=3D advertising_wanted) {
> +				unsigned int i;
> +
> =C2=A0				/* Enable all requested modes */
> -				ecmd.advertising =3D
> -					(ecmd.advertising &
> -					=C2=A0~ALL_ADVERTISED_MODES) |
> -					advertising_wanted;
> -			} else if (full_advertising_wanted > 0) {
> -				ecmd.advertising =3D full_advertising_wanted;
> +				ethtool_link_mode_for_each_u32(i)
> +				{
> +					u32 *adv =3D link_usettings->link_modes.advertising + i;
> +					*adv =3D ((*adv & all_advertised_modes[i])
[...]

Should be ~all_advertised_modes[i] rather than=C2=A0all_advertised_modes[i]=
.

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.
--=-Ie5zhgkiSNapF8fj+VjD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW5hS1AAoJEOe/yOyVhhEJ/MYQAJnLNpRqYpL+ve/6hFWTD1JT
MwTxMsj5QdXmppeFoiNPMsay0mFVmqmPne3NMEiZz45km3SvB0NZWnyaO4gzabQy
+miAOGQe8jwQQe+igafBRTysfJD9CahXGFccSXnMaJcBa/YsDgTwkrrfcRRsyC9v
v2Refh3kNEPf7jcrKrUuF4ekAKHJnZbv4eI81AujTqxNK29W/PRtoVsH+IASMNeM
mZmc+dEFSMZl2wPagTl+l0/N5ZS7t4kfEJ7wnAVv/05qH1Lsx/OMZWBRSqtRc2kX
z/5OPDKQvGL7kgf90CqXRwZiH0j0uup0r0LsAlm8WIZQ/7M5e18zm1U54K+Xm52S
rhiMvl2nPNe2+UPOjfYkkiLUE7IX2GC3iR5PZRZ/e0me9i07IlZUmymWgC7vb7Z1
uX1huTOtQ+2pedsBBFMuI6KYTPpwpX9t2mbnUiLqnoNyKGSBI097Su1ZdAvbMPON
j3BTRCbyQCo2/kW1bI+l9okNR26/hn2+jKgrJNRZkd0lTWXYTDiVIWcwDfrXQMoz
3ldMiR+J2MkFGGqXaDYqWv/IXPRMhduSSnKXD11lppuCtiYxo0/oln+boZb5qEYd
zqe74TInAswUyNGcAJcFFvQJHmW3mJBQslez/eTKPrKo2yo0oMAKuXJqOmiNNfmg
BWzKk/NqoQbSjc3eLJQ5
=7uB3
-----END PGP SIGNATURE-----

--=-Ie5zhgkiSNapF8fj+VjD--
