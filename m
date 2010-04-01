From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/2] phylib: Support phy module autoloading
Date: Thu, 01 Apr 2010 05:34:01 +0100
Message-ID: <1270096441.12516.18.camel@localhost>
References: <1269998334.18090.278.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-dZDfLY+owzD4ya+V0Ouq"
Cc: davem@davemloft.net, netdev@vger.kernel.org, 553024@bugs.debian.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60728 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751090Ab0DAEeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 00:34:14 -0400
In-Reply-To: <1269998334.18090.278.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dZDfLY+owzD4ya+V0Ouq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2010-03-31 at 02:18 +0100, David Woodhouse wrote:
> We don't use the normal hotplug mechanism because it doesn't work. It wil=
l
> load the module some time after the device appears, but that's not good
> enough for us -- we need the driver loaded _immediately_ because otherwis=
e
> the NIC driver may just abort and then the phy 'device' goes away.
>=20
> Instead, we just issue a request_module() directly in phy_device_create()=
.
[...]

Thanks for doing this, David.  I had a stab at it earlier when this
problem was reported in Debian <http://bugs.debian.org/553024>.  I
didn't complete this because (a) I didn't understand all the details of
adding new device table type, and (b) I tried to avoid duplicating
information, which turns out to be rather difficult in modules with
multiple drivers.

Since you've dealt with (a), and (b) is not really as important, I would
just like to suggest some minor changes to your patch 1 (see below).
Feel free to fold them in.  Your patch 2 would then need the
substitutions s/phy_device_id/mdio_device_id/; s/TABLE(phy/TABLE(mdio/.

Ben.

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 1 Apr 2010 05:03:02 +0100
Subject: [PATCH] phylib: Minor cleanup of phylib autoloading

Refer to MDIO, consistent with other module aliases using bus names.
Change type names to __u32, consistent with the rest of the file.
Add kernel-doc comment to struct mdio_device_id.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/phy/phy_device.c    |    2 +-
 include/linux/mod_devicetable.h |   22 ++++++++++++++--------
 scripts/mod/file2alias.c        |    8 ++++----
 3 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index b35ec7e..b0e54b4 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -188,7 +188,7 @@ struct phy_device* phy_device_create(struct mii_bus *bu=
s, int addr, int phy_id)
 	   around for long enough for the driver to get loaded. With
 	   MDIO, the NIC driver will get bored and give up as soon
 	   as it finds that there's no driver _already_ loaded. */
-	sprintf(modid, "phy:" PHYID_FMT, PHYID_ARGS(phy_id));
+	sprintf(modid, MDIO_MODULE_PREFIX MDIO_ID_FMT, MDIO_ID_ARGS(phy_id));
 	request_module(modid);
 #endif
=20
diff --git a/include/linux/mod_devicetable.h b/include/linux/mod_devicetabl=
e.h
index 0c3e300..55f1f9c 100644
--- a/include/linux/mod_devicetable.h
+++ b/include/linux/mod_devicetable.h
@@ -474,10 +474,10 @@ struct platform_device_id {
 			__attribute__((aligned(sizeof(kernel_ulong_t))));
 };
=20
-#define PHY_MODULE_PREFIX	"phy:"
+#define MDIO_MODULE_PREFIX	"mdio:"
=20
-#define PHYID_FMT "%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%=
d%d%d%d%d"
-#define PHYID_ARGS(_id) \
+#define MDIO_ID_FMT "%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%=
d%d%d%d%d%d"
+#define MDIO_ID_ARGS(_id) \
 	(_id)>>31, ((_id)>>30) & 1, ((_id)>>29) & 1, ((_id)>>28) & 1,	\
 	((_id)>>27) & 1, ((_id)>>26) & 1, ((_id)>>25) & 1, ((_id)>>24) & 1, \
 	((_id)>>23) & 1, ((_id)>>22) & 1, ((_id)>>21) & 1, ((_id)>>20) & 1, \
@@ -487,11 +487,17 @@ struct platform_device_id {
 	((_id)>>7) & 1, ((_id)>>6) & 1, ((_id)>>5) & 1, ((_id)>>4) & 1, \
 	((_id)>>3) & 1, ((_id)>>2) & 1, ((_id)>>1) & 1, (_id) & 1
=20
-
-
-struct phy_device_id {
-	uint32_t phy_id;
-	uint32_t phy_id_mask;
+/**
+ * struct mdio_device_id - identifies PHY devices on an MDIO/MII bus
+ * @phy_id: The result of
+ *     (mdio_read(&MII_PHYSID1) << 16 | mdio_read(&PHYSID2)) & @phy_id_mas=
k
+ *     for this PHY type
+ * @phy_id_mask: Defines the significant bits of @phy_id.  A value of 0
+ *     is used to terminate an array of struct mdio_device_id.
+ */
+struct mdio_device_id {
+	__u32 phy_id;
+	__u32 phy_id_mask;
 };
=20
 #endif /* LINUX_MOD_DEVICETABLE_H */
diff --git a/scripts/mod/file2alias.c b/scripts/mod/file2alias.c
index b412185..0e08b8b 100644
--- a/scripts/mod/file2alias.c
+++ b/scripts/mod/file2alias.c
@@ -797,7 +797,7 @@ static int do_platform_entry(const char *filename,
 }
=20
 static int do_phy_entry(const char *filename,
-			struct phy_device_id *id, char *alias)
+			struct mdio_device_id *id, char *alias)
 {
 	char str[33];
 	int i;
@@ -813,7 +813,7 @@ static int do_phy_entry(const char *filename,
 			str[i] =3D '0';
 	}
=20
-	sprintf(alias, PHY_MODULE_PREFIX "%s", str);
+	sprintf(alias, MDIO_MODULE_PREFIX "%s", str);
 	return 1;
 }
=20
@@ -964,9 +964,9 @@ void handle_moddevtable(struct module *mod, struct elf_=
info *info,
 		do_table(symval, sym->st_size,
 			 sizeof(struct platform_device_id), "platform",
 			 do_platform_entry, mod);
-	else if (sym_is(symname, "__mod_phy_device_table"))
+	else if (sym_is(symname, "__mod_mdio_device_table"))
 		do_table(symval, sym->st_size,
-			 sizeof(struct phy_device_id), "phy",
+			 sizeof(struct mdio_device_id), "phy",
 			 do_phy_entry, mod);
 	free(zeros);
 }
--=20
1.7.0.3


--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-dZDfLY+owzD4ya+V0Ouq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS7QiM+e/yOyVhhEJAQLMzQ/+Pb9Q7Wx5eVBaGeytNj2mXZHnbxtU6Rda
zDvhgh1YSfx6uQYzeoCZF18aY8cMN2BquEFkcElI5k1RQqZDCBrLb21VJC4Vdg1d
tjj7PhbAIsXSIrk+5FJ6k+ySbrlIQj71a3s3xodsfD2Ql5fY41qxzMp1PeYF1Luo
dOW3ZZ0cFNFmkyluZzPZXLKJvJe+2Fup2AsR4Y4lfRQM3vZQ1WPfXy8VOfZlhwc+
ZRW5hwXNmRaGeEWhTbHG7IqApnppIlDqDdRAAM8wSjdODUUHclIGp1xmqSf3tVha
w5IyKNeo6YLdKq3hrLS8tlNl7p/x5iV5vMsWhvLwri1zy+9hEaC3yc7cqVt2KyAT
AP3AkzFcxYt5/0s+7FskdZ7aQO/9/3KZBh8CnPjQNBzADE4xcfX1u89oFQVsfR8D
VLh74Sg79SdHPcBL/r7YYsbHnaJ6pNkb8ecuhET0BofPt4YWdunvqTYIMcvtzH7x
66KqwOlg4KcrFeer2zR0E7G+J/fphHdDhT9o5cL9tl9IBjXuZQC8BJlHd3q58T6v
T3zy7ucBOS1p280MBkjrEbUYZJ6mj0z1ng/dUtbcYEXPOiqy5KMuj7pXI2y5rXDN
5A0NuL86iDbFonJEdXGKjBm8AvjgixLQFtmEikCb+qX1upRmeD6A0jwJaEzPDTho
5iBXa9DEHPI=
=rDuO
-----END PGP SIGNATURE-----

--=-dZDfLY+owzD4ya+V0Ouq--
