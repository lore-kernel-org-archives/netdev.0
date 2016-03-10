From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH 3/3] dm9601: add support ethtool style utility
Date: Thu, 10 Mar 2016 11:49:20 +0000
Message-ID: <1457610560.3001.34.camel@decadent.org.uk>
References: <1457609067-3674-1-git-send-email-josright123@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2OpfbE4cjclE1dzc+n1W"
Cc: Joseph Chang <joseph_chang-Ubu6M+hUeUGoECsaD+WFmw@public.gmane.org>
To: Joseph CHANG <josright123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1457609067-3674-1-git-send-email-josright123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-2OpfbE4cjclE1dzc+n1W
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The subject line on this is very vague; it should say which ethtool
operation you're implementing.

On Thu, 2016-03-10 at 19:24 +0800, Joseph CHANG wrote:

> Add function dm9601_set_eeprom which tested good with ethtool
> utility, include the eeprom words dump and the eeprom byte write.
>=20
> Signed-off-by: Joseph CHANG <josright123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> =C2=A0drivers/net/usb/dm9601.c | 39 +++++++++++++++++++++++++++++++++++++=
++
> =C2=A01 file changed, 39 insertions(+)
>=20
> diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
> index 50095df..a6904f4 100644
> --- a/drivers/net/usb/dm9601.c
> +++ b/drivers/net/usb/dm9601.c
> @@ -61,6 +61,7 @@
> =C2=A0#define DM_RX_OVERHEAD	7	/* 3 byte header + 4 byte crc tail */
> =C2=A0#define DM_TIMEOUT	1000
> =C2=A0#define	DM_EP3I_VAL	0x07
> +#define	MD96XX_EEPROM_MAGIC	0x9620

The get_eeprom operation needs to be changed, to set eeprom->magic to
this value.

> =C2=A0static int dm_read(struct usbnet *dev, u8 reg, u16 length, void *da=
ta)
> =C2=A0{
> @@ -289,6 +290,43 @@ static int dm9601_get_eeprom(struct net_device *net,
> =C2=A0	return 0;
> =C2=A0}
> =C2=A0
> +static int dm9601_set_eeprom(struct net_device *net,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct ethtool_eeprom *eeprom, u8 *data=
)
> +{
> +	struct usbnet *dev =3D netdev_priv(net);
> +	int offset =3D eeprom->offset;
> +	int len =3D eeprom->len;
> +	int done;
> +
> +	if (eeprom->magic !=3D MD96XX_EEPROM_MAGIC) {
> +		netdev_dbg(dev->net, "EEPROM: magic value mismatch, magic =3D 0x%x",
> +			=C2=A0=C2=A0=C2=A0eeprom->magic);
> +		return -EINVAL;
> +	}
> +
> +	while (len > 0) {
> +		if (len & 1 || offset & 1) {

Given that the get_eeprom operation only handles word-aligned reads, is
it really important to support misaligned writes in set_eeprom?

Also, this test should be 'if (len =3D=3D 1 || offset & 1)'. =C2=A0Consider=
 a
write with offset =3D 2, len =3D 3. =C2=A0You want to write a word on the f=
irst
iteration, then a byte on the second iteration.

> +			int which =3D offset & 1;
> +			u8 tmp[2];
> +
> +			dm_read_eeprom_word(dev, offset / 2, tmp);
> +			tmp[which] =3D *data;
> +			dm_write_eeprom_word(dev, offset / 2,
> +					=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0tmp[0] | tmp[1] << 8);
> +			mdelay(10);

Why is a delay required here, but not in the other case?

> +			done =3D 1;
> +		} else {
> +			dm_write_eeprom_word(dev, offset / 2,
> +					=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0data[0] | data[1] << 8);
> +			done =3D 2;
> +		}
> +		data +=3D done;
> +		offset +=3D done;
> +		len -=3D done;
> +	}
> +	return 0;
> +}
[...]

Ben.

--=20
Ben Hutchings
To err is human; to really foul things up requires a computer.
--=-2OpfbE4cjclE1dzc+n1W
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW4V9AAAoJEOe/yOyVhhEJRPUP/2RPs4OFFhevQUCau3V7Orp6
2hBEj/pKUlr9AXWhBrhbwnBPNNnukYXnG3cdo6tT7VYCumtEnjjOmkM7VAq12rqC
iA7c33rVf2YGpLfFOR9Tnd+NbllOX4o+wX67Aox0A511nkDudtlgiXoHZ/YQbH55
Ns+RapXh/JkkOhDPkpM3+eApE1wvN5y6i11XdvnRncdQ0sR7xi+ZLkvZvd7BQRxG
FXEFo9ytfp8d3JmhtBnczLrGVpu++nkqB6R7ouYHkwPZz3g/t5rQHXBQIao5qGn3
sPVUkgZLyJH2dDssXrUBSA571Rap/+zHIwrYqDAEtvL3Gv0sEqOYnJfHjD0/qDYd
jTVCWV+jyiZthnzbmED/Fa0jy1tOlXJCk4bSxBIGVtg0OWyB7/kxb+Sfw6hxVWbJ
OJnEfuTnRlXkPxtkJEwEK1msuKUFSnTKFlwACyn4jbHSCq80Dx4Y3At1otyLl6+N
reZeM7MhRHqtpMee3xyHQDXfOQB1vA9Pcbzv4HL3cg5LGuNRNJztCBrvrq05g6bc
jd0E8E9WsQcXD44P5pyXCkVQ+0P6qOWrWU1rQM5A6/teeqFWu+/JFxQyoeqRVOLT
ltOWDUFEgOyV+KJYfsDgo/ZVG1Co4ee5ZqeY/8V1BWLPkrukL//QKj8HP/KIYpxU
Sq5j0M3yemYXb1ngAP/8
=eCS5
-----END PGP SIGNATURE-----

--=-2OpfbE4cjclE1dzc+n1W--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
