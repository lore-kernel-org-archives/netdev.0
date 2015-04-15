From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFC PATCH] bgmac: Fix build error seen if BCM47XX is not configured
Date: Wed, 15 Apr 2015 13:05:38 -0700
Message-ID: <1429128338-28549-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:37710 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753780AbbDOUFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 16:05:44 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YiTZA-001Xck-0J
	for netdev@vger.kernel.org; Wed, 15 Apr 2015 20:05:44 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

arm:allmodconfig fails to build as follows since ARCH_BCM_5301X
is configured but not BCM47XX.

drivers/net/ethernet/broadcom/bgmac.c: In function 'bgmac_probe':
drivers/net/ethernet/broadcom/bgmac.c:1643:2: error:
		implicit declaration of function 'bcm47xx_nvram_getenv'

=46ixes: fc300dc3733f ("bgmac: allow enabling on ARCH_BCM_5301X")
Cc: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
Seen in today's upstream kernel.

I don't like this fix too much (I think it is quite kludgy),
so I marked it RFC (and please don't beat the messenger ;-).

 drivers/net/ethernet/broadcom/bgmac.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 5cb93d1f50a4..dcf27a7c1836 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -17,8 +17,21 @@
 #include <linux/phy_fixed.h>
 #include <linux/interrupt.h>
 #include <linux/dma-mapping.h>
+
+#ifdef CONFIG_BCM47XX
 #include <bcm47xx_nvram.h>
=20
+static int __bcm47xx_nvram_getenv(const char *name, char *val, size_t =
len)
+{
+	return bcm47xx_nvram_getenv(name, val, len);
+}
+#else
+static int __bcm47xx_nvram_getenv(const char *name, char *val, size_t =
len)
+{
+	return -ENOENT;
+}
+#endif
+
 static const struct bcma_device_id bgmac_bcma_tbl[] =3D {
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_4706_MAC_GBIT, BCMA_ANY_REV, BCMA=
_ANY_CLASS),
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_MAC_GBIT, BCMA_ANY_REV, BCMA_ANY_=
CLASS),
@@ -1070,7 +1083,7 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 			     BGMAC_CHIPCTL_1_IF_TYPE_MII;
 		char buf[4];
=20
-		if (bcm47xx_nvram_getenv("et_swtype", buf, sizeof(buf)) > 0) {
+		if (__bcm47xx_nvram_getenv("et_swtype", buf, sizeof(buf)) > 0) {
 			if (kstrtou8(buf, 0, &et_swtype))
 				bgmac_err(bgmac, "Failed to parse et_swtype (%s)\n",
 					  buf);
@@ -1635,7 +1648,7 @@ static int bgmac_probe(struct bcma_device *core)
 	}
=20
 	bgmac->int_mask =3D BGMAC_IS_ERRMASK | BGMAC_IS_RX | BGMAC_IS_TX_MASK=
;
-	if (bcm47xx_nvram_getenv("et0_no_txint", NULL, 0) =3D=3D 0)
+	if (__bcm47xx_nvram_getenv("et0_no_txint", NULL, 0) =3D=3D 0)
 		bgmac->int_mask &=3D ~BGMAC_IS_TX_MASK;
=20
 	/* TODO: reset the external phy. Specs are needed */
--=20
2.1.0
