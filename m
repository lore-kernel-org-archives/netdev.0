From: "Steven J. Hill" <sjhill@realitydiluted.com>
Subject: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [8/8]
Date: Thu, 19 Jul 2007 00:02:04 -0500
Message-ID: <469EF04C.1020505@realitydiluted.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7EDE666DCDA103D7BF6134DE"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from real.realitydiluted.com ([66.43.201.61]:45536 "EHLO
	real.realitydiluted.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbXGSFCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 01:02:07 -0400
Received: from atlas.inter.net ([10.0.0.3])
	by real.realitydiluted.com with esmtp (Exim 4.67)
	(envelope-from <sjhill@realitydiluted.com>)
	id 1IBOBV-00067p-Ut
	for netdev@vger.kernel.org; Thu, 19 Jul 2007 00:04:19 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7EDE666DCDA103D7BF6134DE
Content-Type: multipart/mixed;
 boundary="------------030003070809090708010606"

This is a multi-part message in MIME format.
--------------030003070809090708010606
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Fix long standing panic with regards to descriptors and locking.

Signed-off-by: Steven J. Hill <sjhill1@rockwellcollins.com>
---

--------------030003070809090708010606
Content-Type: text/x-patch;
 name="08-mv643xx-panic-lock-fix.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="08-mv643xx-panic-lock-fix.patch"

diff -ur linux-2.6.22.1/drivers/net/mv643xx_eth.c linux-2.6.22.1-rci/driv=
ers/net/mv643xx_eth.c
--- linux-2.6.22.1/drivers/net/mv643xx_eth.c	2007-07-18 22:55:11.00000000=
0 -0500
+++ linux-2.6.22.1-rci/drivers/net/mv643xx_eth.c	2007-07-18 22:39:37.0000=
00000 -0500
@@ -350,13 +350,6 @@
=20
 	while (mp->tx_desc_count > 0) {
 		spin_lock_irqsave(&mp->lock, flags);
-
-		/* tx_desc_count might have changed before acquiring the lock */
-		if (mp->tx_desc_count <=3D 0) {
-			spin_unlock_irqrestore(&mp->lock, flags);
-			return released;
-		}
-
 		tx_index =3D mp->tx_used_desc_q;
 		desc =3D &mp->p_tx_desc_area[tx_index];
 #ifdef CONFIG_GT64260
@@ -367,7 +360,7 @@
=20
 		if (!force && (cmd_sts & ETH_BUFFER_OWNED_BY_DMA)) {
 			spin_unlock_irqrestore(&mp->lock, flags);
-			return released;
+			continue;
 		}
=20
 		mp->tx_used_desc_q =3D (tx_index + 1) % mp->tx_ring_size;
@@ -1488,7 +1481,19 @@
 	BUG_ON(netif_queue_stopped(dev));
 	BUG_ON(skb =3D=3D NULL);
=20
-	if (mp->tx_ring_size - mp->tx_desc_count < MAX_DESCS_PER_SKB) {
+	if (mp->tx_ring_size - mp->tx_desc_count <=3D MAX_DESCS_PER_SKB) {
+		/*
+		 * We are completely out of TX descriptors, however,
+		 * if 'tx_used_desc_q' is zero, most likely the port
+		 * has been configured and is up, but there is no link.
+		 * We attempt to free a single descriptor to keep the
+		 * 'sendto' call and rest of the stack happy. If this
+		 * check is taken out, expect an error and kernel panic
+		 * from 'kernel/softirq.c:141' inside 'local_bh_enable'.
+		 */
+		if (mp->tx_used_desc_q =3D=3D 0)
+			mv643xx_eth_free_all_tx_descs(dev);
+
 		printk(KERN_ERR "%s: transmit with queue full\n", dev->name);
 		netif_stop_queue(dev);
 		return 1;

--------------030003070809090708010606--

--------------enig7EDE666DCDA103D7BF6134DE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGnvBMgyK5H2Ic36cRAojBAJ9siZh2s8c9/4t9K0EIfboBD09CkwCfXjhi
ySfZ02Vo0g5Id0T5tnwiO50=
=gntH
-----END PGP SIGNATURE-----

--------------enig7EDE666DCDA103D7BF6134DE--
