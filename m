From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 2/8] ethtool: Name the 'no change' value for
 setting RSS hash key but not indir table
Date: Mon, 02 Jun 2014 02:01:36 +0100
Message-ID: <1401670896.14007.96.camel@deadeye.wl.decadent.org.uk>
References: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ot+/+SvASWzGjJQdi8pA"
Cc: netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46326 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752656AbaFBBBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 21:01:43 -0400
In-Reply-To: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ot+/+SvASWzGjJQdi8pA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

We usually allocate special values of u32 fields starting from the top
down, so also change the value to 0xffffffff.  As these operations
haven't been included in a stable release yet, it's not too late to
change.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/uapi/linux/ethtool.h | 12 +++++++-----
 net/core/ethtool.c           | 12 +++++++-----
 2 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index d47d31d..cba18e3 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -850,7 +850,8 @@ struct ethtool_rxfh_indir {
  * struct ethtool_rxfh - command to get/set RX flow hash indir or/and hash=
 key.
  * @cmd: Specific command number - %ETHTOOL_GRSSH or %ETHTOOL_SRSSH
  * @rss_context: RSS context identifier.
- * @indir_size: On entry, the array size of the user buffer, which may be =
zero.
+ * @indir_size: On entry, the array size of the user buffer, which may be =
zero,
+ *		or (for %ETHTOOL_SRSSH), %ETH_RXFH_INDIR_NO_CHANGE.
  *		On return from %ETHTOOL_GRSSH, the array size of the hardware
  *		indirection table.
  * @key_size:	On entry, the array size of the user buffer in bytes,
@@ -861,10 +862,10 @@ struct ethtool_rxfh_indir {
  *		of size @indir_size followed by hash key of size @key_size.
  *
  * For %ETHTOOL_GRSSH, a @indir_size and key_size of zero means that only =
the
- * size should be returned.  For %ETHTOOL_SRSSH, a @indir_size of 0xDEADBE=
EF
- * means that indir table setting is not requested and a @indir_size of ze=
ro
- * means the indir table should be reset to default values.  This last fea=
ture
- * is not supported by the original implementations.
+ * size should be returned.  For %ETHTOOL_SRSSH, an @indir_size of
+ * %ETH_RXFH_INDIR_NO_CHANGE means that indir table setting is not request=
ed
+ * and a @indir_size of zero means the indir table should be reset to defa=
ult
+ * values.
  */
 struct ethtool_rxfh {
 	__u32   cmd;
@@ -874,6 +875,7 @@ struct ethtool_rxfh {
 	__u32	rsvd[2];
 	__u32   rss_config[0];
 };
+#define ETH_RXFH_INDIR_NO_CHANGE	0xffffffff
=20
 /**
  * struct ethtool_rx_ntuple_flow_spec - specification for RX flow filter
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c834cb2..7156fe5 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -803,12 +803,13 @@ static noinline_for_stack int ethtool_set_rxfh(struct=
 net_device *dev,
=20
 	/* If either indir or hash key is valid, proceed further.
 	 */
-	if ((user_indir_size && ((user_indir_size !=3D 0xDEADBEEF) &&
-				 user_indir_size !=3D dev_indir_size)) ||
+	if ((user_indir_size &&
+	     user_indir_size !=3D ETH_RXFH_INDIR_NO_CHANGE &&
+	     user_indir_size !=3D dev_indir_size) ||
 	    (user_key_size && (user_key_size !=3D dev_key_size)))
 		return -EINVAL;
=20
-	if (user_indir_size !=3D 0xDEADBEEF)
+	if (user_indir_size !=3D ETH_RXFH_INDIR_NO_CHANGE)
 		indir_bytes =3D dev_indir_size * sizeof(indir[0]);
=20
 	rss_config =3D kzalloc(indir_bytes + user_key_size, GFP_USER);
@@ -821,9 +822,10 @@ static noinline_for_stack int ethtool_set_rxfh(struct =
net_device *dev,
 		goto out;
=20
 	/* user_indir_size =3D=3D 0 means reset the indir table to default.
-	 * user_indir_size =3D=3D 0xDEADBEEF means indir setting is not requested=
.
+	 * user_indir_size =3D=3D ETH_RXFH_INDIR_NO_CHANGE means leave it unchang=
ed.
 	 */
-	if (user_indir_size && user_indir_size !=3D 0xDEADBEEF) {
+	if (user_indir_size &&
+	    user_indir_size !=3D ETH_RXFH_INDIR_NO_CHANGE) {
 		indir =3D (u32 *)rss_config;
 		ret =3D ethtool_copy_validate_indir(indir,
 						  useraddr + rss_cfg_offset,


--=20
Ben Hutchings
Any smoothly functioning technology is indistinguishable from a rigged demo=
.

--=-ot+/+SvASWzGjJQdi8pA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU4vM8Oe/yOyVhhEJAQoUrBAAry1s6yjQDC142bptHx5GFwi1hBVyPr+C
PnkrkplQl01qqf1m/R26td9gMGVPEpQUU8RyjnLMf4hI0eY+WPk723z6QP8AN7YR
yb9VayBSp1RJuCnaDgIt9Cv5jzVZ6mHaAuOhTBzN7ZosWHkL6ryyosyxKXoR5SQC
bfAQ2d2fGj2213GLRXkXlaDHTGQjhQhd6stKrCQyyh6GQbgNWkuTBXBQIQksNkMj
rAMROefFlRepVDfJ855dfF9uUwImcuNX6HNxr0ozX7tH4cH3mXK63ftHG6lqJtkk
78bze7wAO+JE6XhXhnbPr1ZZkg9658E9H8VYKkMB+efXa5kh9lKbCkEFPcFdqajS
DexJ19ptCtBRzgihavVR7EuiwpqNbFzb49xu5hV1/m7OgdyREIILEu/rqeFBX8Fe
UQd9no5dWCu08b1XqyAq8oT+b22d01J0QTh0Snixt36GXYaFIh/AyJMscJQ9mrHa
OXiNqfvGsTjTbHStUkC5wleG+LAixfSN+vE/jLXec5XoU4CE7807C626JMIq8KZZ
E9euAVIaa7Hl8n36V468bf52FG348ur4aCLLqxs6/J/6zLLwmFIvK13VjD1J7Vtd
MZRG8a3WnnspwZxPkryyj7d7q7md7hUP91Dyxc3GWS2Snk5WSZihqn4tHHeTsxU/
dCVi1jtAznE=
=P6pm
-----END PGP SIGNATURE-----

--=-ot+/+SvASWzGjJQdi8pA--
