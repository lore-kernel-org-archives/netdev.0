From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH RFC ethtool]  QSFP Diagnostics Information Support
Date: Sat, 04 Apr 2015 14:46:41 +0100
Message-ID: <1428155201.11260.56.camel@decadent.org.uk>
References: <1420846916-39510-1-git-send-email-vidya@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-PueleOD4XjzYGQr7XzTJ"
Cc: netdev@vger.kernel.org, bwh@kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com, bkenward@solarflare.com,
	dave.lee@finisar.com
To: vidya@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57716 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751635AbbDDNq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 09:46:58 -0400
In-Reply-To: <1420846916-39510-1-git-send-email-vidya@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PueleOD4XjzYGQr7XzTJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Sorry for the very late review.

On Fri, 2015-01-09 at 15:41 -0800, vidya@cumulusnetworks.com wrote:
> From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
>=20
> This patch provides support for diagnostics information
> for QSFP Plus modules which based on SFF 8436 specification
> This implementation is loosely based on current SFP DOM parser
> and SFF-8436 specs (ftp://ftp.seagate.com/pub/sff/SFF-8436.PDF)
> by SFF Committee.
[...]
> --- a/ethtool-copy.h
> +++ b/ethtool-copy.h
> @@ -1314,6 +1314,8 @@ enum ethtool_sfeatures_retval_bits {
>  #define ETH_MODULE_SFF_8079_LEN		256
>  #define ETH_MODULE_SFF_8472		0x2
>  #define ETH_MODULE_SFF_8472_LEN		512
> +#define ETH_MODULE_SFF_8436     0x3
> +#define ETH_MODULE_SFF_8436_LEN     640

ethtool-copy.h should always be generated from the kernel tree
(specifically from include/uapi/linux/ethtool.h, via 'make
headers_install' which writes usr/include/linux/ethtool.h).  You need to
update that header first.  But these new macros have already been
defined differently there:

#define ETH_MODULE_SFF_8436		0x4
#define ETH_MODULE_SFF_8436_LEN		256

and it looks like mlx4_en is already using these.

I didn't look at the spec, but based on your comment in qsfp.c about the
extra sub-pages being optional, perhaps you should add a comment and
another definition, thus:

#define ETH_MODULE_SFF_8436_LEN		256	/* min, without optional pages */
#define ETH_MODULE_SFF_8436_MAX_LEN	640	/* with all optional pages */

The code in qsfp.c will need to check what length it actually gets back
and avoid accessing missing pages.

[...]
> --- /dev/null
> +++ b/qsfp.c
> @@ -0,0 +1,827 @@
> +/*
> + * qsfp.c: Implements SFF-8436 based QSFP+ Diagnostics Memory map.
> + *
> + * Copyright (C) 2014 Cumulus networks Inc.

A lot of this is based on sfpid.c and sfdiag.c so I think you need to
list their copyright holders here as well.

[...]
> +static void sff8436_show_identifier(const __u8 *id)
> +{
> +	printf("\t%-41s : 0x%02x", "Identifier", id[SFF8436_ID_OFFSET]);
> +	switch (id[SFF8436_ID_OFFSET]) {
> +	case SFF8436_ID_UNKNOWN:
> +		printf(" (no module present, unknown, or unspecified)\n");
> +		break;
> +	case SFF8436_ID_GBIC:
> +		printf(" (GBIC)\n");
> +		break;
> +	case SFF8436_ID_SOLDERED_MODULE:
> +		printf(" (module soldered to motherboard)\n");
> +		break;
> +	case SFF8436_ID_SFP:
> +		printf(" (SFP)\n");
> +		break;

These seem to match up numerically with SFF8079.  If they're using the
same ID assignments then everything except the byte offset can be shared
with sff8079_show_identifier().

[...]
> +static void sff8436_show_connector(const __u8 *id)
> +{
> +	printf("\t%-41s : 0x%02x", "Connector", id[SFF8436_CTOR_OFFSET]);
> +	switch (id[SFF8436_CTOR_OFFSET]) {
> +	case SFF8436_CTOR_UNKNOWN:
> +		printf(" (unknown or unspecified)\n");
> +		break;
> +	case SFF8436_CTOR_SC:
> +		printf(" (SC)\n");
> +		break;

Similarly with this and sff8079_show_connector().

[...]
> +static void sff8436_show_value_with_unit(const __u8 *id, unsigned int re=
g,
> +					 const char *name, unsigned int mult,
> +					 const char *unit)
> +{
> +	unsigned int val =3D id[reg];
> +
> +	printf("\t%-41s : %u%s\n", name, val * mult, unit);
> +}
> +
> +static void sff8436_show_ascii(const __u8 *id, unsigned int first_reg,
> +			       unsigned int last_reg, const char *name)
> +{
> +	unsigned int reg, val;
> +
> +	printf("\t%-41s : ", name);
> +	for (reg =3D first_reg; reg <=3D last_reg; reg++) {
> +		val =3D id[reg];
> +		putchar(((val >=3D 32) && (val <=3D 126)) ? val : '_');
> +	}
> +	printf("\n");
> +}

These are identical to functions in sfpid.c with the prefix changed.
Don't copy them, share them.

> +static double convert_mw_to_dbm(double mw)
> +{
> +	return (10. * log10(mw / 1000.)) + 30.;
> +}

This is identical to a function in sfpdiag.c.

> +/* Most common case: 16-bit unsigned integer in a certain unit */
> +#define OFFSET_TO_U16(offset) \
> +	(id[offset] << 8 | id[offset + 1])

For macro safety, there should be parentheses around 'offset' in
'offset + 1'.

[...]
> +static void sff8436_show_dom(const __u8 *id)
> +{
> +	struct sff8436_diags sd;
> +	char *rx_power_string =3D NULL;
> +	char power_string[MAX_DESC_SIZE];
> +	int i;
> +
> +	/*
> +	 * There is no clear identifier to signify the existance of
> +	 * optical diagnostics similar to SFF-8472. So checking existance
> +	 * of page 3, will provide the gurantee for existance of alarms
> +	 * and thresholds
> +	 */
> +	sd.supports_alarms =3D id[SFF8436_STATUS_2_OFFSET] &
> +						SFF8436_STATUS_PAGE_3_PRESENT;
> +	sd.rx_power_type =3D id[SFF8436_DIAG_TYPE_OFFSET] &
> +						SFF8436_RX_PWR_TYPE_MASK;
> +
> +	sff8436_dom_parse(id, &sd);
> +
> +# define PRINT_xX_PWR(string, var)                             \
> +	printf("\t%-41s : %.4f mW / %.2f dBm\n", (string),           \
> +	       (double)((var) / 10000.),                             \
> +	       convert_mw_to_dbm((double)((var) / 10000.)))
> +
> +#define PRINT_BIAS(string, bias_cur)                            \
> +	printf("\t%-41s : %.3f mA\n", (string),                       \
> +	       (double)(bias_cur / 500.))
> +
> +#define PRINT_TEMP(string, temp)                                    \
> +	printf("\t%-41s : %.2f degrees C / %.2f degrees F\n", (string),   \
> +	       (double)(temp / 256.), (double)(temp / 256. * 1.8 + 32.))
> +
> +
> +#define PRINT_VCC(string, sfp_voltage)                               \
> +	printf("\t%-41s : %.4f V\n", (string),                             \
> +	       (double)(sfp_voltage / 10000.))

The macros above, which don't depend on the local structure definitions,
should be shared with sff8472_show_dom().  (Obviously you would need to
change that function too.)

[...]
> +	printf("\t%-41s : %s\n", "Alarm/warning flags implemented",
> +	       (!sd.supports_alarms ? "Yes" : "No"));
> +	if (!sd.supports_alarms) {

Why is the flag inverted here?

[...]
> +}
> +void sff8436_show_all(const __u8 *id)
> +{
[...]

Leave a blank line between functions.

Ben.

--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g

--=-PueleOD4XjzYGQr7XzTJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVR/rR+e/yOyVhhEJAQoWZhAAnbZwo8cDFNQPhhhIWpIQ64HHF9XzF8t0
8hx4IJqvsmBQQ/lfc+Z/jNdcbRBjHHAcvK7aoPfzjDIiDn68TCw9sZPh5JDMR1Dv
lfOHP/p2Sb2bwEiWKtntLOXtfbLl5fj/v5c7rdHDI80WjUSzE0UBQNc3kWpIBktq
TzehOcZV6OdG683OuYupf9RudjacZdM5yFJ6q/XUwRqv9oa7SWadv5JrkGCbZSYD
b9BqrsIo3a6g1Xpsd16zSrcvf9/97heNkaLayH4yByKHD3yKB5t+jUWXvC2MNxvf
UXmJhezeJEke/DnVErkEqgi5nU4nvm7MSBF8SUNhh/dYHOaSycSCAw3c6r2pglSy
W88FcaldQgqGedfQYuFZmulVgazZc8lHa60yvDmSV1ughHXeCNYA0cviIhlszyBK
56t6ej0/47pEZOrPUqWFVr52DjAKILh1u++fTvDuO+qMJjMwht0xv9ArY/Y+PBTF
cZPJ/MO/V5BD56DoeB04dDx/ZhtSE0VCLHBqv5PmX0xFh16QqQdT1wjB8yIoqy0J
HNEMSfflXtG8pMmdCCMRv3OdLeTclZ4Q3NS85SOqxVOIla9qP3bk1avE8MRJLbNC
Q2DoDGhn132U8Jb74nS4ehxLFxznQKMO/0QxH7q1Gf1MSg2oeuqMmAL/H0Gvxgz5
SgKhUB0e3f0=
=qo+P
-----END PGP SIGNATURE-----

--=-PueleOD4XjzYGQr7XzTJ--
