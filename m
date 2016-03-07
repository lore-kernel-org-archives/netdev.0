From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v3 04/12] ethtool.c: do_seeprom checks for
 params & stdin sanity
Date: Mon, 07 Mar 2016 16:05:39 +0000
Message-ID: <1457366739.15205.21.camel@decadent.org.uk>
References: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
	 <1457138533-2417-5-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gwOWaC0lKi3v0aVofzB1"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43668 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752803AbcCGQFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 11:05:46 -0500
In-Reply-To: <1457138533-2417-5-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gwOWaC0lKi3v0aVofzB1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-04 at 16:42 -0800, David Decotigny wrote:
> From: David Decotigny <decot@googlers.com>
>=20
> Tested:
> =C2=A0 On qemu e1000:
> =C2=A0 $ dd if=3D/dev/zero bs=3D2 count=3D5 | /mnt/ethtool -E eth0 length=
 9
> =C2=A0 too much data from stdin
> =C2=A0 $ dd if=3D/dev/zero bs=3D2 count=3D5 | /mnt/ethtool -E eth0 length=
 11
> =C2=A0 not enough data from stdin
> =C2=A0 $ dd if=3D/dev/zero bs=3D2 count=3D5 | /mnt/ethtool -E eth0 length=
 10
> =C2=A0 Cannot set EEPROM data: Bad address
>=20
>=20
> Signed-off-by: David Decotigny <decot@googlers.com>
> ---
> =C2=A0ethtool.c | 24 ++++++++++++++++++++----
> =C2=A01 file changed, 20 insertions(+), 4 deletions(-)
>=20
> diff --git a/ethtool.c b/ethtool.c
> index c64b962..19f479c 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -2828,8 +2828,14 @@ static int do_seeprom(struct cmd_context *ctx)
> =C2=A0	if (seeprom_length =3D=3D -1)
> =C2=A0		seeprom_length =3D drvinfo.eedump_len;
> =C2=A0
> -	if (drvinfo.eedump_len < seeprom_offset + seeprom_length)
> -		seeprom_length =3D drvinfo.eedump_len - seeprom_offset;
> +	if (drvinfo.eedump_len < seeprom_offset + seeprom_length) {
> +		if (drvinfo.eedump_len > seeprom_offset)
> +			seeprom_length =3D drvinfo.eedump_len - seeprom_offset;

Don't silently truncate - treat this as an error too.

> +		else {
> +			fprintf(stderr, "offset & length out of bounds\n");
> +			return 75;

Use the default error code of 1 rather than making 75 even less
meaningful.

> +		}
> +	}
> =C2=A0
> =C2=A0	eeprom =3D calloc(1, sizeof(*eeprom)+seeprom_length);
> =C2=A0	if (!eeprom) {
> @@ -2844,8 +2850,18 @@ static int do_seeprom(struct cmd_context *ctx)
> =C2=A0	eeprom->data[0] =3D seeprom_value;
> =C2=A0
> =C2=A0	/* Multi-byte write: read input from stdin */
> -	if (!seeprom_value_seen)
> -		eeprom->len =3D fread(eeprom->data, 1, eeprom->len, stdin);
> +	if (!seeprom_value_seen) {
> +		if (1 !=3D fread(eeprom->data, eeprom->len, 1, stdin)) {
> +			fprintf(stderr, "not enough data from stdin\n");
> +			free(eeprom);
> +			return 75;
> +		}
> +		if ((EOF !=3D fgetc(stdin)) || !feof(stdin)) {

Comparisons are the wrong way round.

Ben.

> +			fprintf(stderr, "too much data from stdin\n");
> +			free(eeprom);
> +			return 75;
> +		}
> +	}
> =C2=A0
> =C2=A0	err =3D send_ioctl(ctx, eeprom);
> =C2=A0	if (err < 0) {
--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g
--=-gwOWaC0lKi3v0aVofzB1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW3abTAAoJEOe/yOyVhhEJrVoP/j9EPLSxD9vLXcvw5T1E1CqY
CCMY1IZlSepDDNIL4ZXb23vVylPx0Pul7LCgYJ228Mb+X6zmyYzhZ+ok0bjHx30H
ZaskhWxalh9zDyX9oTtqbdMucgpeuzENzOSHwoTfpBiFUF4Q1EbgJABj64i+2MGj
mSoOAuQTxKWgIR10Hx9QzjJrKSnL++5/YFR4gBXnHdvO8N/3jG565M5+i4VBHp32
ykir4z8Nb+LaAvo4yC8InvmPPsoNZpCh+OtzxlFKaVu1s6ctMz+BdtB0ZscHckSh
iSvXntPhnSOBbYcMiw3ZsYsr7nd7u8iE2CKmtWt2XpfNe8NbK3b2N0pzHKGpvNKC
S/BrbjqlGUXSmR5QKPWRznca1e1z0nzW/JPmc41yTxEA1siBrxyZlAPlJjRayCUA
0vkti2PcCrjUfisGKza8AjBx2r9eMtuV2Kh/RGlZ4jRcNV3XC1jCSO6VJ77maVpi
xiQBBVEZSaGweI2adUuHn6ABgCRrZCYM0ksq76IkCOZSx/j0Za4sxRXEN/p0d205
otAS2AETSqTRMR2bnBojWfk4lsDRV3aYmCkt4rl+tQgCkP42QbXtKajidKdurxKS
mJKlkIEseiEUSi2wz/TXcGBo7YSUV40PNi/4yQeWXEIxzsYKdVbr+IAlBpuh0MdZ
z3PSMGFrm5tTJEDvjGsC
=m2+P
-----END PGP SIGNATURE-----

--=-gwOWaC0lKi3v0aVofzB1--
