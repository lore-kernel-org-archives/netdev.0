From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: PHY driver loading for clause 45 PHY
Date: Tue, 22 Apr 2014 17:44:07 +0100
Message-ID: <1398185047.7767.30.camel@deadeye.wl.decadent.org.uk>
References: <986457BC66A4884EBFFDEFEBEB20F84C15F28CB2@satlexdag03.amd.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tow0DyvXhDA7KiTWhYsM"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: "Lendacky, Thomas" <Thomas.Lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53719 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932250AbaDVQoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 12:44:17 -0400
In-Reply-To: <986457BC66A4884EBFFDEFEBEB20F84C15F28CB2@satlexdag03.amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tow0DyvXhDA7KiTWhYsM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-04-11 at 13:47 +0000, Lendacky, Thomas wrote:
> Adding PHY library maintainer, Florian, directly...
>=20
> I've encountered an issue trying to get a phy driver to load when the
> phy supports clause 45.  I  call get_phy_device passing in an mii_bus
> structure, an MMD address and true for is_c45.  The get_phy_device
> function calls the get_phy_id function which calls the appropriate c45
> routines to obtain the device ids for each available MMD device.
> However, phy_id is set to zero upon return (by get_phy_c45_ids).  This
> zero phy_id is used by phy_device_create to build a module name in an
> attempt to load a phy driver that is associated with the phy_id. Since
> the module name used doesn't match any of the ids associated with my
> phy driver, my phy driver does not load.
>=20
> I've worked around this for now by patching phy_device_create just
> before calling request_module:
>=20
> diff -rup linux-3.14/drivers/net/phy/phy_device.c linux-3.14-build/driver=
s/net/phy/phy_device.c
> --- linux-3.14/drivers/net/phy/phy_device.c	2014-03-30 22:40:15.000000000=
 -0500
> +++ linux-3.14-build/drivers/net/phy/phy_device.c	2014-04-08 15:51:24.000=
000000 -0500
> @@ -195,6 +195,9 @@ struct phy_device *phy_device_create(str
>  	 * driver will get bored and give up as soon as it finds that
>  	 * there's no driver _already_ loaded.
>  	 */
> +	if (is_c45 && (addr < ARRAY_SIZE(c45_ids->device_ids)))
> +		phy_id =3D c45_ids->device_ids[addr];

addr is the address of the PHY (PRTAD) but c45_ids->device_ids is
indexed by MMD number (DEVAD).

>  	request_module(MDIO_MODULE_PREFIX MDIO_ID_FMT, MDIO_ID_ARGS(phy_id));
> =20
>  	device_initialize(&dev->dev);
>=20
> This builds the proper module name, but I'm not sure this is the proper
> thing to do.  Should the code loop through all the device_ids and issue
> a request_module for each non-zero id?

That's not going to help in itself.  The logic for loading a driver
module by device ID should match the logic for binding the driver in
that module by device ID - in that case that's in mdio_bus_match().

Something that bothered me about MDIO clause 45 is that the separation
between MMDs seems to imply that NIC vendors could potentially mix and
match chips implementing different MMDs, and in general you might need
to load multiple drivers for a single PHY.  But I don't think phylib is
anywhere near ready to support such composite PHYs, if they exist.

> Or is there a better way to get a phy driver that supports clause 45
> loaded?

I think that as long as we can only have one driver for each PHY, a
sensible approach would be to take the ID of the first present MMD in
the c45_ids array as the overall PHY ID.  Something like this
(untested):

--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -212,9 +212,10 @@ EXPORT_SYMBOL(phy_device_create);
  * @c45_ids: where to store the c45 ID information.
  *
  *   If the PHY devices-in-package appears to be valid, it and the
- *   corresponding identifiers are stored in @c45_ids, zero is stored
- *   in @phy_id.  Otherwise 0xffffffff is stored in @phy_id.  Returns
- *   zero on success.
+ *   corresponding identifiers are stored in @c45_ids, and the
+ *   identifier of the lowest-numbered MMD is stored in @phy_id.
+ *   Otherwise 0xffffffff is stored in @phy_id.  Returns zero on
+ *   success.
  *
  */
 static int get_phy_c45_ids(struct mii_bus *bus, int addr, u32 *phy_id,
@@ -240,14 +241,15 @@ static int get_phy_c45_ids(struct mii_bus *bus, int a=
ddr, u32 *phy_id,
 		if (phy_reg < 0)
 			return -EIO;
 		c45_ids->devices_in_package |=3D (phy_reg & 0xffff);
+	}
=20
-		/* If mostly Fs, there is no device there,
-		 * let's get out of here.
-		 */
-		if ((c45_ids->devices_in_package & 0x1fffffff) =3D=3D 0x1fffffff) {
-			*phy_id =3D 0xffffffff;
-			return 0;
-		}
+	/* If all zeroes or mostly Fs, there is no device there, let's get
+	 * out of here.
+	 */
+	if (c45_ids->devices_in_package =3D=3D 0 ||
+	    (c45_ids->devices_in_package & 0x1fffffff) =3D=3D 0x1fffffff) {
+		*phy_id =3D 0xffffffff;
+		return 0;
 	}
=20
 	/* Now probe Device Identifiers for each device present. */
@@ -267,7 +269,7 @@ static int get_phy_c45_ids(struct mii_bus *bus, int add=
r, u32 *phy_id,
 			return -EIO;
 		c45_ids->device_ids[i] |=3D (phy_reg & 0xffff);
 	}
-	*phy_id =3D 0;
+	*phy_id =3D c45_ids->device_ids[__ffs(c45_ids->devices_in_package)];
 	return 0;
 }
=20


Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-tow0DyvXhDA7KiTWhYsM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1acV+e/yOyVhhEJAQqnwRAAplbAx1vWwzCxbZiImDulGMfE8JQkPY0t
qDYx13ahbuKcwyghSzJx7tBXPeFTO4VvgKWr+yqHdxEX3FH74CMejPzS2JRaI+tM
Bjuj3TEq+chGImDPdUmJ3ZROgXIGhMRIj8TYfSxeMBjRyOCe37tgIq0CisUTRBoZ
Lj4YVgU9IT+TMvGVGvwIGEIats9NwOPFurkinWmaipgGmJYylQaZBzS3u5MWs4Ui
gS26J91dI5r5GlhE0eAuPl/Wa+d+/xp6QcJRRx6Uvwy0kS9bkSS3gp3/y1P0fD2T
R+NEBVkwEJMXPXHLn5AUzEAGssZfsL+0RkAe+t/u3Ne8Tf2/OpdMMUDlNBc+suwJ
FVMpLkXFJyAF9gum9L7FsEUrfQj4afTD4bunAsnUcXQ1mb8DfBnYJYka+f1cyqbu
8EW1FX7y0kV8m6zVw+6RxbGM6J2FAxSB3ERx9WXcNMw8Wnbw11QN0wrkanrn7J3X
iFFSKq9WwW3uZTbvZe24ANkgpvyZmJQsmSmKIpOU3VZHzbMyKnf4MRQnBUo6DBo1
SzON/sfnG0Zb1sRAMKqIDjs+/JY2RHZjusVzMb2zlWkNXrS6v1U/cKkcM1Gx3pw3
8mDzZh2FBZyzyZnEWv+WEao7dSDpbKtPQAwmOkefjLuSFA4KhnVzBIjoyyjD9JkT
2QWxOdK61+0=
=k5Uf
-----END PGP SIGNATURE-----

--=-tow0DyvXhDA7KiTWhYsM--
