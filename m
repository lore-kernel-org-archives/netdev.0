From: Greg Ungerer <gerg@uclinux.org>
Subject: [PATCH] net: fec: don't access RACC register when not available
Date: Fri, 26 Jun 2015 15:10:35 +1000
Message-ID: <201506260510.t5Q5AZ90010455@goober.accelecon.com>
Cc: <gerg@uclinux.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nschwqsrv02p.mx.bigpond.com ([61.9.189.234]:35916 "EHLO
	nschwqsrv02p.mx.bigpond.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751774AbbFZFTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 01:19:36 -0400
Received: from nschwcmgw08p ([61.9.190.168]) by nschwmtas02p.mx.bigpond.com
          with ESMTP
          id <20150626050921.YEAI26469.nschwmtas02p.mx.bigpond.com@nschwcmgw08p>
          for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 05:09:21 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 8969de63989b8814a6db9d00b9d1ceabe40e8b11 Mon Sep 17 00:00:00 2001
From: Greg Ungerer <gerg@uclinux.org>
Date: Sat, 20 Jun 2015 15:51:57 +1000
Subject: [PATCH] net: fec: don't access RACC register when not available

Not all silicon implementations of the Freescale FEC hardware module
have the RACC (Receive Accelerator Function) register, so we should not
be trying to access it on those that don't. Currently none of the ColdFire
based parts with a FEC have it.

Support for RACC was introduced by commit 4c09eed9 ("net: fec: Enable imx6
enet checksum acceleration"). A fix was introduced in commit d1391930
("net: fec: Fix build for MCF5272") that disables its use on the ColdFire
M5272 part, but it doesn't fix the general case of other ColdFire parts.

To fix we create a quirk flag, FEC_QUIRK_HAS_RACC, and check it before
working with the RACC register.

Signed-off-by: Greg Ungerer <gerg@uclinux.org>
---
 drivers/net/ethernet/freescale/fec.h      |  2 ++
 drivers/net/ethernet/freescale/fec_main.c | 30 +++++++++++++++++-------------
 2 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index a86af8a..1eee73c 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -428,6 +428,8 @@ struct bufdesc_ex {
 #define FEC_QUIRK_BUG_CAPTURE		(1 << 10)
 /* Controller has only one MDIO bus */
 #define FEC_QUIRK_SINGLE_MDIO		(1 << 11)
+/* Controller supports RACC register */
+#define FEC_QUIRK_HAS_RACC		(1 << 12)
 
 struct fec_enet_priv_tx_q {
 	int index;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 66d47e4..63658d5 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -85,28 +85,30 @@ static struct platform_device_id fec_devtype[] = {
 		.driver_data = 0,
 	}, {
 		.name = "imx25-fec",
-		.driver_data = FEC_QUIRK_USE_GASKET,
+		.driver_data = FEC_QUIRK_USE_GASKET | FEC_QUIRK_HAS_RACC,
 	}, {
 		.name = "imx27-fec",
-		.driver_data = 0,
+		.driver_data = FEC_QUIRK_HAS_RACC,
 	}, {
 		.name = "imx28-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_SWAP_FRAME |
-				FEC_QUIRK_SINGLE_MDIO,
+				FEC_QUIRK_SINGLE_MDIO | FEC_QUIRK_HAS_RACC,
 	}, {
 		.name = "imx6q-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
 				FEC_QUIRK_HAS_BUFDESC_EX | FEC_QUIRK_HAS_CSUM |
-				FEC_QUIRK_HAS_VLAN | FEC_QUIRK_ERR006358,
+				FEC_QUIRK_HAS_VLAN | FEC_QUIRK_ERR006358 |
+				FEC_QUIRK_HAS_RACC,
 	}, {
 		.name = "mvf600-fec",
-		.driver_data = FEC_QUIRK_ENET_MAC,
+		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_RACC,
 	}, {
 		.name = "imx6sx-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
 				FEC_QUIRK_HAS_BUFDESC_EX | FEC_QUIRK_HAS_CSUM |
 				FEC_QUIRK_HAS_VLAN | FEC_QUIRK_HAS_AVB |
-				FEC_QUIRK_ERR007885 | FEC_QUIRK_BUG_CAPTURE,
+				FEC_QUIRK_ERR007885 | FEC_QUIRK_BUG_CAPTURE |
+				FEC_QUIRK_HAS_RACC,
 	}, {
 		/* sentinel */
 	}
@@ -970,13 +972,15 @@ fec_restart(struct net_device *ndev)
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 
 #if !defined(CONFIG_M5272)
-	/* set RX checksum */
-	val = readl(fep->hwp + FEC_RACC);
-	if (fep->csum_flags & FLAG_RX_CSUM_ENABLED)
-		val |= FEC_RACC_OPTIONS;
-	else
-		val &= ~FEC_RACC_OPTIONS;
-	writel(val, fep->hwp + FEC_RACC);
+	if (fep->quirks & FEC_QUIRK_HAS_RACC) {
+		/* set RX checksum */
+		val = readl(fep->hwp + FEC_RACC);
+		if (fep->csum_flags & FLAG_RX_CSUM_ENABLED)
+			val |= FEC_RACC_OPTIONS;
+		else
+			val &= ~FEC_RACC_OPTIONS;
+		writel(val, fep->hwp + FEC_RACC);
+	}
 #endif
 
 	/*
-- 
1.9.1
