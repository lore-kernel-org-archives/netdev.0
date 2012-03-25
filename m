From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH v2] gianfar: Fix possible overrun and simplify interrupt name field creation
Date: Sun, 25 Mar 2012 13:10:07 -0400
Message-ID: <1332695407-21167-1-git-send-email-paul.gortmaker@windriver.com>
References: <CAP=VYLrPbYv2C7hYaQ-aUJLFCfYh5zkJzFXJt8GFV2OTZ7h=og@mail.gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	afleming@freescale.com, Joe Perches <joe@perches.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLrPbYv2C7hYaQ-aUJLFCfYh5zkJzFXJt8GFV2OTZ7h=og@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>

Space allocated for int_name_<foo> is insufficient for
maximal device name, expand it.

Code to create int_name_<foo> is obscure, simplify it
by using sprintf.

Found by looking for unnecessary \ line continuations.

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[v2: delete "uncompiled/untested" and fix typo in commit log]

The IRQ names appear unchanged after applying this patch:

root@SBC8641D:/root> for i in `seq 3` ; do ifconfig eth$i 192.168.0.$i ; done
root@SBC8641D:/root> cat /proc/interrupts
           CPU0       CPU1
 16:          0          0   MPIC      Level     phy_interrupt, phy_interrupt, phy_interrupt, phy_interrupt
 29:       6884          0   MPIC      Level     eth0_g0_tx
 30:          0      11578   MPIC      Level     eth0_g0_rx
 31:          0          0   MPIC      Level     eth2_g0_tx
 32:          0          0   MPIC      Level     eth2_g0_rx
 33:          0          0   MPIC      Level     eth2_g0_er
 34:          0          0   MPIC      Level     eth0_g0_er
 35:          0          0   MPIC      Level     eth1_g0_tx
 36:          0          0   MPIC      Level     eth1_g0_rx
 37:          0          0   MPIC      Level     eth3_g0_tx
 38:          0          0   MPIC      Level     eth3_g0_rx
 39:          0          0   MPIC      Level     eth3_g0_er
 40:          0          0   MPIC      Level     eth1_g0_er

Having them all in group "g0" may seem odd, but it is definitely
the same as it was before the commit.  Tested on mar23 linux-next.


diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index d9428f0..e7bed53 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -968,7 +968,6 @@ static int gfar_probe(struct platform_device *ofdev)
 	struct gfar_private *priv = NULL;
 	struct gfar __iomem *regs = NULL;
 	int err = 0, i, grp_idx = 0;
-	int len_devname;
 	u32 rstat = 0, tstat = 0, rqueue = 0, tqueue = 0;
 	u32 isrg = 0;
 	u32 __iomem *baddr;
@@ -1169,40 +1168,16 @@ static int gfar_probe(struct platform_device *ofdev)
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
index fc2488a..4c9f8d4 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -517,7 +517,7 @@ extern const char gfar_driver_version[];
 #define RXFCB_PERR_MASK		0x000c
 #define RXFCB_PERR_BADL3	0x0008
 
-#define GFAR_INT_NAME_MAX	IFNAMSIZ + 4
+#define GFAR_INT_NAME_MAX	(IFNAMSIZ + 6)	/* '_g#_xx' */
 
 struct txbd8
 {
-- 
1.7.9.1
