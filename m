From: Joe Perches <joe@perches.com>
Subject: [PATCH] gianfar: Fix possible overrun and simplify interrupt name field creation
Date: Sat, 17 Mar 2012 12:05:38 -0700
Message-ID: <17d93e9eb16cbad75b20cdbcaf38f268260d6fd5.1332010469.git.joe@perches.com>
Cc: Sandeep Gopalpet <sandeep.kumar@freescale.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Space allocated for int_name_<foo> is unsufficient for
maximal device name, expand it.

Code to create int_name_<foo> is obscure, simplify it
by using sprintf.

Found by looking for unnecessary \ line continuations.
Uncompiled, untested.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/freescale/gianfar.c |   39 +++++------------------------
 drivers/net/ethernet/freescale/gianfar.h |    2 +-
 2 files changed, 8 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index adb0ae4..770b8cf 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -971,7 +971,6 @@ static int gfar_probe(struct platform_device *ofdev)
 	struct gfar_private *priv = NULL;
 	struct gfar __iomem *regs = NULL;
 	int err = 0, i, grp_idx = 0;
-	int len_devname;
 	u32 rstat = 0, tstat = 0, rqueue = 0, tqueue = 0;
 	u32 isrg = 0;
 	u32 __iomem *baddr;
@@ -1172,40 +1171,16 @@ static int gfar_probe(struct platform_device *ofdev)
 		priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
 
 	/* fill out IRQ number and name fields */
-	len_devname = strlen(dev->name);
 	for (i = 0; i < priv->num_grps; i++) {
-		strncpy(&priv->gfargrp[i].int_name_tx[0], dev->name,
-				len_devname);
 		if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
-			strncpy(&priv->gfargrp[i].int_name_tx[len_devname],
-				"_g", sizeof("_g"));
-			priv->gfargrp[i].int_name_tx[
-				strlen(priv->gfargrp[i].int_name_tx)] = i+48;
-			strncpy(&priv->gfargrp[i].int_name_tx[strlen(
-				priv->gfargrp[i].int_name_tx)],
-				"_tx", sizeof("_tx") + 1);
-
-			strncpy(&priv->gfargrp[i].int_name_rx[0], dev->name,
-					len_devname);
-			strncpy(&priv->gfargrp[i].int_name_rx[len_devname],
-					"_g", sizeof("_g"));
-			priv->gfargrp[i].int_name_rx[
-				strlen(priv->gfargrp[i].int_name_rx)] = i+48;
-			strncpy(&priv->gfargrp[i].int_name_rx[strlen(
-				priv->gfargrp[i].int_name_rx)],
-				"_rx", sizeof("_rx") + 1);
-
-			strncpy(&priv->gfargrp[i].int_name_er[0], dev->name,
-					len_devname);
-			strncpy(&priv->gfargrp[i].int_name_er[len_devname],
-				"_g", sizeof("_g"));
-			priv->gfargrp[i].int_name_er[strlen(
-					priv->gfargrp[i].int_name_er)] = i+48;
-			strncpy(&priv->gfargrp[i].int_name_er[strlen(\
-				priv->gfargrp[i].int_name_er)],
-				"_er", sizeof("_er") + 1);
+			sprintf(priv->gfargrp[i].int_name_tx, "%s%s%c%s",
+				dev->name, "_g", '0' + i, "_tx");
+			sprintf(priv->gfargrp[i].int_name_rx, "%s%s%c%s",
+				dev->name, "_g", '0' + i, "_rx");
+			sprintf(priv->gfargrp[i].int_name_er, "%s%s%c%s",
+				dev->name, "_g", '0' + i, "_er");
 		} else
-			priv->gfargrp[i].int_name_tx[len_devname] = '\0';
+			strcpy(priv->gfargrp[i].int_name_tx, dev->name);
 	}
 
 	/* Initialize the filer table */
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 4fe0f34..e537d81 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -520,7 +520,7 @@ extern const char gfar_driver_version[];
 #define RXFCB_PERR_MASK		0x000c
 #define RXFCB_PERR_BADL3	0x0008
 
-#define GFAR_INT_NAME_MAX	IFNAMSIZ + 4
+#define GFAR_INT_NAME_MAX	(IFNAMSIZ + 6)	/* '_g#_xx' */
 
 struct txbd8
 {
-- 
1.7.8.111.gad25c.dirty
