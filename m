From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 2/8] ethtool: Name the 'no change' value for
 setting RSS hash key but not indir table
Date: Tue, 03 Jun 2014 02:50:43 +0100
Message-ID: <1401760243.14007.181.camel@deadeye.wl.decadent.org.uk>
References: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-s1NTU6x3pOdRjcwIxsYJ"
Cc: netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49638 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752622AbaFCBuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 21:50:50 -0400
In-Reply-To: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-s1NTU6x3pOdRjcwIxsYJ
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
If more than one person is responsible for a bug, no one is at fault.

--=-s1NTU6x3pOdRjcwIxsYJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU40p8+e/yOyVhhEJAQpO7BAAgnNAHAxTcC0+psDW1H5lN3G33Jvfk+WB
rY/TwX42lLQ7Wmy7oDCjNaldsOigMIk6H06KbXKBVhkAfnnVjCuUVcAT73y2aKt2
O0AEU/pK8cLHfLa3FTCjdi4tNCVT+6B+j/LyiNxlWqC03vH3or7rt6YmOVSDKi8X
Km+VnSrfNvzE+5g7gh/TFiL1hHgKgkHypSqjznA3rjzUXyqsP1eHKS/KQWZQSDFg
ENC9y/QqerGo2uL5O/Lx18B+TsNNnDBKOoV/0fFlYiQrFtHKLW66+aIGgzj2FB88
c+F+1rJvKCw1ctTLDd3YM4BuoMRx0febVhnbCgCiMihE8KluG81gH0qRtgJi4DGX
8hLZPCfc+vogKEG+wLtSrhqUsUcBHoXd5LeOfl/KSnXa8lMO/dcnWb5hrFVkqh8M
kzMm50cZ+smzCnLcYab3I0P/l9gXyhzLF9xqaNxB/Sfctwf6Zbisxnpxd3Zyq3RG
FKSgfySnia1Gox/RToix7/tE8hENBayQy0wZbnLqBpuAKVpB4vw6ilLBOqcfhNqt
gQDTFxSRk9xX06PGoNykof4iEJLWs9A9fyqIaVyAUiMmdWbV0i2Dl2EbSoI8xCq4
5EshvuH8T6ymSh8CIm8lg6b97+mXFplIKIOT73qmXORQItWeWvmP20HRGgHO9QgA
NRwLhSPf8/s=
=muKz
-----END PGP SIGNATURE-----

--=-s1NTU6x3pOdRjcwIxsYJ--
