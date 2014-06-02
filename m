From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 8/8] ethtool: Check that reserved fields of struct
 ethtool_rxfh are 0
Date: Mon, 02 Jun 2014 02:04:26 +0100
Message-ID: <1401671066.14007.102.camel@deadeye.wl.decadent.org.uk>
References: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+O1/bC4mtD7oF0iBkGiY"
Cc: netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46353 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752518AbaFBBEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 21:04:33 -0400
In-Reply-To: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+O1/bC4mtD7oF0iBkGiY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

We should fail rather than silently ignoring use of these extensions.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/core/ethtool.c | 89 ++++++++++++++++++++++----------------------------=
----
 1 file changed, 36 insertions(+), 53 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 8ae452a..17cb912 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -681,11 +681,11 @@ static noinline_for_stack int ethtool_get_rxfh(struct=
 net_device *dev,
 {
 	int ret;
 	const struct ethtool_ops *ops =3D dev->ethtool_ops;
-	u32 user_indir_size =3D 0, user_key_size =3D 0;
+	u32 user_indir_size, user_key_size;
 	u32 dev_indir_size =3D 0, dev_key_size =3D 0;
+	struct ethtool_rxfh rxfh;
 	u32 total_size;
-	u32 indir_offset, indir_bytes;
-	u32 key_offset;
+	u32 indir_bytes;
 	u32 *indir =3D NULL;
 	u8 *hkey =3D NULL;
 	u8 *rss_config;
@@ -697,33 +697,24 @@ static noinline_for_stack int ethtool_get_rxfh(struct=
 net_device *dev,
=20
 	if (ops->get_rxfh_indir_size)
 		dev_indir_size =3D ops->get_rxfh_indir_size(dev);
-
-	indir_offset =3D offsetof(struct ethtool_rxfh, indir_size);
-
-	if (copy_from_user(&user_indir_size,
-			   useraddr + indir_offset,
-			   sizeof(user_indir_size)))
-		return -EFAULT;
-
-	if (copy_to_user(useraddr + indir_offset,
-			 &dev_indir_size, sizeof(dev_indir_size)))
-		return -EFAULT;
-
 	if (ops->get_rxfh_key_size)
 		dev_key_size =3D ops->get_rxfh_key_size(dev);
=20
 	if ((dev_key_size + dev_indir_size) =3D=3D 0)
 		return -EOPNOTSUPP;
=20
-	key_offset =3D offsetof(struct ethtool_rxfh, key_size);
-
-	if (copy_from_user(&user_key_size,
-			   useraddr + key_offset,
-			   sizeof(user_key_size)))
+	if (copy_from_user(&rxfh, useraddr, sizeof(rxfh)))
 		return -EFAULT;
+	user_indir_size =3D rxfh.indir_size;
+	user_key_size =3D rxfh.key_size;
=20
-	if (copy_to_user(useraddr + key_offset,
-			 &dev_key_size, sizeof(dev_key_size)))
+	/* Check that reserved fields are 0 for now */
+	if (rxfh.rss_context || rxfh.rsvd[0] || rxfh.rsvd[1])
+		return -EINVAL;
+
+	rxfh.indir_size =3D dev_indir_size;
+	rxfh.key_size =3D dev_key_size;
+	if (copy_to_user(useraddr, &rxfh, sizeof(rxfh)))
 		return -EFAULT;
=20
 	/* If the user buffer size is 0, this is just a query for the
@@ -768,12 +759,11 @@ static noinline_for_stack int ethtool_set_rxfh(struct=
 net_device *dev,
 	int ret;
 	const struct ethtool_ops *ops =3D dev->ethtool_ops;
 	struct ethtool_rxnfc rx_rings;
-	u32 user_indir_size =3D 0, dev_indir_size =3D 0, i;
-	u32 user_key_size =3D 0, dev_key_size =3D 0;
+	struct ethtool_rxfh rxfh;
+	u32 dev_indir_size =3D 0, dev_key_size =3D 0, i;
 	u32 *indir =3D NULL, indir_bytes =3D 0;
 	u8 *hkey =3D NULL;
 	u8 *rss_config;
-	u32 indir_offset, key_offset;
 	u32 rss_cfg_offset =3D offsetof(struct ethtool_rxfh, rss_config[0]);
=20
 	if (!(ops->get_rxfh_indir_size || ops->get_rxfh_key_size) ||
@@ -782,40 +772,33 @@ static noinline_for_stack int ethtool_set_rxfh(struct=
 net_device *dev,
=20
 	if (ops->get_rxfh_indir_size)
 		dev_indir_size =3D ops->get_rxfh_indir_size(dev);
-
-	indir_offset =3D offsetof(struct ethtool_rxfh, indir_size);
-	if (copy_from_user(&user_indir_size,
-			   useraddr + indir_offset,
-			   sizeof(user_indir_size)))
-		return -EFAULT;
-
 	if (ops->get_rxfh_key_size)
 		dev_key_size =3D dev->ethtool_ops->get_rxfh_key_size(dev);
-
 	if ((dev_key_size + dev_indir_size) =3D=3D 0)
 		return -EOPNOTSUPP;
=20
-	key_offset =3D offsetof(struct ethtool_rxfh, key_size);
-	if (copy_from_user(&user_key_size,
-			   useraddr + key_offset,
-			   sizeof(user_key_size)))
+	if (copy_from_user(&rxfh, useraddr, sizeof(rxfh)))
 		return -EFAULT;
=20
+	/* Check that reserved fields are 0 for now */
+	if (rxfh.rss_context || rxfh.rsvd[0] || rxfh.rsvd[1])
+		return -EINVAL;
+
 	/* If either indir or hash key is valid, proceed further.
 	 * It is not valid to request that both be unchanged.
 	 */
-	if ((user_indir_size &&
-	     user_indir_size !=3D ETH_RXFH_INDIR_NO_CHANGE &&
-	     user_indir_size !=3D dev_indir_size) ||
-	    (user_key_size && (user_key_size !=3D dev_key_size)) ||
-	    (user_indir_size =3D=3D ETH_RXFH_INDIR_NO_CHANGE &&
-	     user_key_size =3D=3D 0))
+	if ((rxfh.indir_size &&
+	     rxfh.indir_size !=3D ETH_RXFH_INDIR_NO_CHANGE &&
+	     rxfh.indir_size !=3D dev_indir_size) ||
+	    (rxfh.key_size && (rxfh.key_size !=3D dev_key_size)) ||
+	    (rxfh.indir_size =3D=3D ETH_RXFH_INDIR_NO_CHANGE &&
+	     rxfh.key_size =3D=3D 0))
 		return -EINVAL;
=20
-	if (user_indir_size !=3D ETH_RXFH_INDIR_NO_CHANGE)
+	if (rxfh.indir_size !=3D ETH_RXFH_INDIR_NO_CHANGE)
 		indir_bytes =3D dev_indir_size * sizeof(indir[0]);
=20
-	rss_config =3D kzalloc(indir_bytes + user_key_size, GFP_USER);
+	rss_config =3D kzalloc(indir_bytes + rxfh.key_size, GFP_USER);
 	if (!rss_config)
 		return -ENOMEM;
=20
@@ -824,29 +807,29 @@ static noinline_for_stack int ethtool_set_rxfh(struct=
 net_device *dev,
 	if (ret)
 		goto out;
=20
-	/* user_indir_size =3D=3D 0 means reset the indir table to default.
-	 * user_indir_size =3D=3D ETH_RXFH_INDIR_NO_CHANGE means leave it unchang=
ed.
+	/* rxfh.indir_size =3D=3D 0 means reset the indir table to default.
+	 * rxfh.indir_size =3D=3D ETH_RXFH_INDIR_NO_CHANGE means leave it unchang=
ed.
 	 */
-	if (user_indir_size &&
-	    user_indir_size !=3D ETH_RXFH_INDIR_NO_CHANGE) {
+	if (rxfh.indir_size &&
+	    rxfh.indir_size !=3D ETH_RXFH_INDIR_NO_CHANGE) {
 		indir =3D (u32 *)rss_config;
 		ret =3D ethtool_copy_validate_indir(indir,
 						  useraddr + rss_cfg_offset,
 						  &rx_rings,
-						  user_indir_size);
+						  rxfh.indir_size);
 		if (ret)
 			goto out;
-	} else if (user_indir_size =3D=3D 0) {
+	} else if (rxfh.indir_size =3D=3D 0) {
 		indir =3D (u32 *)rss_config;
 		for (i =3D 0; i < dev_indir_size; i++)
 			indir[i] =3D ethtool_rxfh_indir_default(i, rx_rings.data);
 	}
=20
-	if (user_key_size) {
+	if (rxfh.key_size) {
 		hkey =3D rss_config + indir_bytes;
 		if (copy_from_user(hkey,
 				   useraddr + rss_cfg_offset + indir_bytes,
-				   user_key_size)) {
+				   rxfh.key_size)) {
 			ret =3D -EFAULT;
 			goto out;
 		}

--=20
Ben Hutchings
Any smoothly functioning technology is indistinguishable from a rigged demo=
.

--=-+O1/bC4mtD7oF0iBkGiY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU4vNmue/yOyVhhEJAQq3MBAAsSanpUkBJM4aHnqycI/xP83xvKrGEoLk
wJCczcWvfVOgxZs7ee9v1KlKE4i4qCqXRsr4DPcl7V1R7OQWnBdLJV4frVxEkNxE
Qohqx0Xd4J39AvwTBL9A5yjx+5mGDRxmhTO6f+26D+DBF/GptbXYC+db3iINfRtJ
Gmd2GAAWqpfFgQg4QAmwZhMreJcDmUvW4krYNc/kBpkPu4a9+8Vl9zRYZEK+7z94
SjznQxRP5R/ZbVMk/d5StQaLxVQZD8KOcBvcji2bTXUhA0/ySAPECHpjqak0cO//
v1xhDgsS3TLoLSPNwWRaVJUwvW8I7bbxIwI9hxn3EC5qkz9V9qwob21/woWhe7C+
tuuHiYYCB0NEKh2c2cjSVkfm40OtDHlYRe5tyCrN/q8fC1M46366vYqe7u3J2DBw
bB3bNHUodhSFqSRxfCJgZsbi+pe8vKY1t3CpMV4q+F5m0zOulmaDDi0QuOmyYHFI
uSFI+nUVCnDc1nHx7opIJ0eQfQZvU3vr1itKPl8afGQcxbKlxRiPaFzXiv9WUrtN
9lT4O0GwCGo1euHU2bXMK6im9JMiJr19yS8b35agmY9c2z22tVP3EIlXEWbcunST
a5Non0+0+Uv8gkxrrkfIpabS5AFFQzL/Ec79EzOweF0tiU55CLMVkKJfaEq6eiHS
YHCY4Pegayc=
=zQxQ
-----END PGP SIGNATURE-----

--=-+O1/bC4mtD7oF0iBkGiY--
