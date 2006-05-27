From: Sergey Vlasov <vsu@altlinux.ru>
Subject: Re: CRC16 in rt2x00
Date: Sat, 27 May 2006 17:55:16 +0400
Message-ID: <20060527175516.600f450c.vsu@altlinux.ru>
References: <200605271327.18879.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sat__27_May_2006_17_55_16_+0400_r2tBa4=2iQ4ZEzks"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from master.altlinux.org ([62.118.250.235]:53777 "EHLO
	master.altlinux.org") by vger.kernel.org with ESMTP
	id S1751527AbWE0Nzt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 09:55:49 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200605271327.18879.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Sat__27_May_2006_17_55_16_+0400_r2tBa4=2iQ4ZEzks
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, 27 May 2006 13:27:15 +0200 Ivo van Doorn wrote:

> I have a small question about the CRC16 usage in rt2x00
> and what the netdev preferred method is for this.
>=20
> At the moment the rt2x00 drivers in wireless-dev use
> its own CRC16 table and calculation inside the driver.
> There already is a CRC16 library in the kernel
> which uses the 0x8005 table, while rt2x00 uses the
> 0x1021 polynomial table.
>=20
> Is keeping this version of CRC16 inside rt2x00 the most
> sensible thing to do? Or should it be moved to the lib
> folder of the kernel so other drivers could make use of it as well?
> (So far I have not found a driver which makes use
> of the same CRC16 table)

However, fs/udf/crc.c has exactly the same CRC table as rt2x00:

static uint16_t crc_table[256] =3D {
        0x0000U, 0x1021U, 0x2042U, 0x3063U, 0x4084U, 0x50a5U, 0x60c6U, 0x70=
e7U,
...
        0x6e17U, 0x7e36U, 0x4e55U, 0x5e74U, 0x2e93U, 0x3eb2U, 0x0ed1U, 0x1e=
f0U
};

/*     =20
 * udf_crc
 *     =20
 * PURPOSE
 *      Calculate a 16-bit CRC checksum using ITU-T V.41 polynomial.
 *     =20
 * DESCRIPTION
 *      The OSTA-UDF(tm) 1.50 standard states that using CRCs is mandatory.
 *      The polynomial used is: x^16 + x^12 + x^15 + 1
 *
 * PRE-CONDITIONS
 *      data            Pointer to the data block.
 *      size            Size of the data block.
 *
 * POST-CONDITIONS
 *      <return>        CRC of the data block.
 *
 * HISTORY
 *      July 21, 1997 - Andrew E. Mileski
 *      Adapted from OSTA-UDF(tm) 1.50 standard.
 */

This is a bit-reversed form of CRC-CCITT supported by lib/crc-ccitt.c.
Unfortunately, this does not help much, because converting one form to
the other is too expensive (you would need to reverse bits in all data
bytes, and then reverse bits in the 16-bit result).

BTW, there is more CRC code duplication in drivers/bluetooth/hci_bcsp.c
(bcsp_crc_update() seems to give the same result as crc_ccitt_byte()).

In drivers/media/dvb/frontends/nxt200x.c, nxt200x_crc() seems to give
the same result as rt2x00crc_byte() (but without using a table).

drivers/net/wan/cycx_drv.c:checksum() is also some mutated version of
CRC-CCITT (adding two additional zero bytes at the end of data makes it
return the same result as rt2x00crc()).

--Signature=_Sat__27_May_2006_17_55_16_+0400_r2tBa4=2iQ4ZEzks
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.9.17 (GNU/Linux)

iD8DBQFEeFpIW82GfkQfsqIRAjV/AJ43kS4wxKOEVb1vyry5c0ZW+HvcDgCfcZ2Z
jqHWN+TtB8wItIElCW8SL7Y=
=PJ6/
-----END PGP SIGNATURE-----

--Signature=_Sat__27_May_2006_17_55_16_+0400_r2tBa4=2iQ4ZEzks--
