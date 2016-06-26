From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v1 2/2] ethtool:QSFP Plus/QSFP28 Diagnostics
 Information Support
Date: Sun, 26 Jun 2016 11:33:09 +0200
Message-ID: <1466933589.2504.42.camel@decadent.org.uk>
References: <1465860426-30387-3-git-send-email-vidya@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7qGHyfoVUdBzSbYxJ/Qh"
Cc: bkenward@solarflare.com, daniel@iogearbox.net, galp@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	dustin@cumulusnetworks.com
To: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	netdev@vger.kernel.org, bwh@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55378 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751753AbcFZJdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 05:33:21 -0400
In-Reply-To: <1465860426-30387-3-git-send-email-vidya@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7qGHyfoVUdBzSbYxJ/Qh
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-06-13 at 16:27 -0700, Vidya Sagar Ravipati wrote:
> From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
>=20
> This patch series provides following support
> a) Reorganized fields based out of SFF-8024 fields i.e. Identifier/
> =C2=A0=C2=A0=C2=A0Encoding/Connector types which are common across SFP/SF=
P+ (SFF-8472)
> =C2=A0=C2=A0=C2=A0and QSFP+/QSFP28 (SFF-8436/SFF-8636) modules into sff-c=
ommon files.
> a) Support for diagnostics information for QSFP Plus/QSFP28 modules
> =C2=A0=C2=A0=C2=A0based on SFF-8436/SFF-8636

Those two changes should be separate patches.

> Standards for QSFP+/QSFP28
> a) QSFP+/QSFP28 - SFF 8636 Rev 2.7 dated January 26,2016
> b) SFF-8024 Rev 4.0 dated May 31, 2016
>=20
> Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
> Acked-by: Bert Kenward <bkenward@solarflare.com>
> ---
> =C2=A0Makefile.am=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A02 +-
> =C2=A0ethtool.c=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A05 +
> =C2=A0internal.h=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A03 +
> =C2=A0qsfp.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 876 +++++++++++++=
++++++++++++++++++++++++++++++++++++++++++++++
> =C2=A0qsfp.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 599 +++++++++++++=
+++++++++++++++++++++++++++
> =C2=A0sff-common.c | 255 +++++++++++++++++
> =C2=A0sff-common.h | 156 +++++++++++
> =C2=A0sfpid.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 103 +------
> =C2=A08 files changed, 1899 insertions(+), 100 deletions(-)
> =C2=A0create mode 100644 qsfp.c
> =C2=A0create mode 100644 qsfp.h
> =C2=A0create mode 100644 sff-common.c
> =C2=A0create mode 100644 sff-common.h
>=20
> diff --git a/Makefile.am b/Makefile.am
> index 6814bc9..1f3d767 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -13,7 +13,7 @@ ethtool_SOURCES +=3D \
> =C2=A0		=C2=A0=C2=A0fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
> =C2=A0		=C2=A0=C2=A0pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
> =C2=A0		=C2=A0=C2=A0smsc911x.c at76c50x-usb.c sfc.c stmmac.c	\
> -		=C2=A0=C2=A0sfpid.c sfpdiag.c ixgbevf.c tse.c vmxnet3.c
> +		=C2=A0=C2=A0sff-common.c sfpid.c sfpdiag.c ixgbevf.c tse.c vmxnet3.c q=
sfp.c
> =C2=A0endif
> =C2=A0
> =C2=A0TESTS =3D test-cmdline test-features
> diff --git a/ethtool.c b/ethtool.c
> index 0cd0d4f..a0d48d1 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -3963,6 +3963,11 @@ static int do_getmodule(struct cmd_context *ctx)
> =C2=A0				sff8079_show_all(eeprom->data);
> =C2=A0				sff8472_show_all(eeprom->data);
> =C2=A0				break;
> +			case ETH_MODULE_SFF_8436:
> +			case ETH_MODULE_SFF_8636:
> +				sff8636_show_all(eeprom->data,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0modinfo.eeprom_len);

The last line here is wrongly indented, as are many other continuation
lines. =C2=A0ethtool code should be formatted just the same way David likes
kernel networking code.

[...]
> --- /dev/null
> +++ b/qsfp.c
[...]
> +/* Channel Monitoring Fields */
> +struct sff8636_channel_diags {
> +
> +	__u16 bias_cur;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/* Measured bias cur=
rent in 2uA units */
> +	__u16 rx_power;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/* Measured RX Power=
 */
> +	__u16 tx_power;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/* Measured TX Power=
 */
> +
> +};

There's no need for blank lines in this structure definition.

> +/* Module Monitoring Fields */
> +struct sff8636_diags {
> +
> +#define MAX_CHANNEL_NUM 4
> +#define LWARN 0
> +#define HWARN 1
> +#define LALRM 2
> +#define HALRM 3
> +
> +	=C2=A0/* Supports DOM */
> +	__u8 supports_dom;
> +	/* Supports alarm/warning thold */
> +	__u8 supports_alarms;
> +	/* RX Power: 0 =3D OMA, 1 =3D Average power */
> +	__u8=C2=A0=C2=A0rx_power_type;
> +	/* TX Power: 0 =3D Not supported, 1 =3D Average power */
> +	__u8=C2=A0=C2=A0tx_power_type;
> +	/* SFP voltage in 0.1mV units */
> +	__u16 sfp_voltage;
> +	/* SFP Temp in 16-bit signed 1/256 Celcius */
> +	__s16 sfp_temp;
> +	/* [4] tables are low/high warn, low/high alarm */
> +	/* SFP voltage in 0.1mV units */
> +	__u16 thresh_sfp_voltage[4];
> +	/* SFP Temp in 16-bit signed 1/256 Celcius */
> +	__s16 thresh_sfp_temp[4];
> +	/* Measured bias current in 2uA units */
> +	__u16 thresh_bias_cur[4];
> +	/* Measured TX Power */
> +	__u16 thresh_tx_power[4];
> +	/* Measured RX Power */
> +	__u16 thresh_rx_power[4];

This looks very similar to sff8472_diags, only with the actual values
separated from the arrays of thresholds.

Can the structure and code be combined with sfpdiag.c, with the
additional per-channel diagnostics being optional?

> +	struct sff8636_channel_diags scd[MAX_CHANNEL_NUM];
> +};
[...]
> --- /dev/null
> +++ b/sff-common.c
[...]
> +double convert_mw_to_dbm(double mw)
> +{
> +	return (10. * log10(mw / 1000.)) + 30.;
> +}
[...]

This is copied from sfpdiag.c, so you should make that file use it
rather than a duplicate definition.

Ben.

--=20

Ben Hutchings
compatible: Gracefully accepts erroneous data from any source

--=-7qGHyfoVUdBzSbYxJ/Qh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXb6FWAAoJEOe/yOyVhhEJV7AQAMt7+ositKjZPG4e+sjYq7G8
Q17ozOKMmgdxTbK9qQEwlaRIxSY/jlXnplLlDJGHB+loSwpmCCtTnqEGERCvOEpE
d6uqKv0pYITjJXCoZjIRdydyTd7+JgvtCzk+rKIeUgkR50hN3DBI6bXSwuJiFz25
K31bJkt9Iegvms707L2VykJSfjEM77YOaVhZkgui956Gx6v5LT2b8NHhH4U2m/kg
q4Ueh3fw06qVLe8Jc0uLV4OnBBRHEejypj/LUuwKvIjS5K84k0kVJiIzA1Kyu9k9
Vn0EA5T0GfYUuURsKQsdhEC7XGRKcV0UYN1Ra4MPWb24WabczYlJZ/SXIolPZYPI
4zZYc3N64nIL7ZZGHDtXQsbczDFYw+xuqyMiLf4mo0X3dS3koBJc6ijP8PgvOJLl
1yX2PMOIanmjwH+sCUHt9bN1VpgOxueVWriRUz6jiP9ocdKNCabgc5gI5LnZzQeb
qi3GHr/Ay5SnqL2f3WmVF3kMmAwaFLyglYKLFi2aL7Fzxps9rp1W4tK8fcXTqVqG
R+R2uPep+eQSPEPCcTjjB87wv/OxKZbo4NkmFGA2CkJFh9Tq/gnFqeebRkjGWak1
CTl6jQ7KwtcVbfjz/QuF7h0H3dRlVYjCHVAzqx/Fei2voOR5glvFn1U744CQgGcR
8QdGY4pp294Uks5x59cs
=t6P4
-----END PGP SIGNATURE-----

--=-7qGHyfoVUdBzSbYxJ/Qh--
