From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 6/11] ibm_newemac: Cleanup/fix support for STACR register variants
Date: Fri, 30 Nov 2007 16:40:29 +1100
Message-ID: <20071130054132.94859DDE21@ozlabs.org>
References: <1196401223.5661.297518056501.qpush@grosgo>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48397 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994AbXK3Fld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 00:41:33 -0500
In-Reply-To: <1196401223.5661.297518056501.qpush@grosgo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a few variants of the STACR register that affect more than
just the "AXON" version of EMAC. Replace the current test of various
chip models with tests for generic properties in the device-tree.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Acked-by: Stefan Roese <sr@denx.de>
---

 arch/powerpc/boot/dts/sequoia.dts |    4 ++++
 drivers/net/ibm_newemac/core.c    |   23 +++++++++++++----------
 drivers/net/ibm_newemac/core.h    |    6 +++---
 3 files changed, 20 insertions(+), 13 deletions(-)

Index: linux-work/arch/powerpc/boot/dts/sequoia.dts
===================================================================
--- linux-work.orig/arch/powerpc/boot/dts/sequoia.dts	2007-11-20 14:47:01.000000000 +1100
+++ linux-work/arch/powerpc/boot/dts/sequoia.dts	2007-11-20 14:47:02.000000000 +1100
@@ -274,6 +274,8 @@
 				zmii-channel = <0>;
 				rgmii-device = <&RGMII0>;
 				rgmii-channel = <0>;
+				has-inverted-stacr-oc;
+				has-new-stacr-staopc;
 			};
 
 			EMAC1: ethernet@ef600f00 {
@@ -302,6 +304,8 @@
 				zmii-channel = <1>;
 				rgmii-device = <&RGMII0>;
 				rgmii-channel = <1>;
+				has-inverted-stacr-oc;
+				has-new-stacr-staopc;
 			};
 		};
 	};
Index: linux-work/drivers/net/ibm_newemac/core.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/core.c	2007-11-20 14:46:58.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/core.c	2007-11-20 14:47:02.000000000 +1100
@@ -711,7 +711,7 @@ static int __emac_mdio_read(struct emac_
 		r = EMAC_STACR_BASE(dev->opb_bus_freq);
 	if (emac_has_feature(dev, EMAC_FTR_STACR_OC_INVERT))
 		r |= EMAC_STACR_OC;
-	if (emac_has_feature(dev, EMAC_FTR_HAS_AXON_STACR))
+	if (emac_has_feature(dev, EMAC_FTR_HAS_NEW_STACR))
 		r |= EMACX_STACR_STAC_READ;
 	else
 		r |= EMAC_STACR_STAC_READ;
@@ -783,7 +783,7 @@ static void __emac_mdio_write(struct ema
 		r = EMAC_STACR_BASE(dev->opb_bus_freq);
 	if (emac_has_feature(dev, EMAC_FTR_STACR_OC_INVERT))
 		r |= EMAC_STACR_OC;
-	if (emac_has_feature(dev, EMAC_FTR_HAS_AXON_STACR))
+	if (emac_has_feature(dev, EMAC_FTR_HAS_NEW_STACR))
 		r |= EMACX_STACR_STAC_WRITE;
 	else
 		r |= EMAC_STACR_STAC_WRITE;
@@ -2480,16 +2480,19 @@ static int __devinit emac_init_config(st
 	/* Check EMAC version */
 	if (of_device_is_compatible(np, "ibm,emac4"))
 		dev->features |= EMAC_FTR_EMAC4;
-	if (of_device_is_compatible(np, "ibm,emac-axon")
-	    || of_device_is_compatible(np, "ibm,emac-440epx"))
-		dev->features |= EMAC_FTR_HAS_AXON_STACR
-			| EMAC_FTR_STACR_OC_INVERT;
-	if (of_device_is_compatible(np, "ibm,emac-440spe"))
+
+	/* Fixup some feature bits based on the device tree */
+	if (of_get_property(np, "has-inverted-stacr-oc", NULL))
 		dev->features |= EMAC_FTR_STACR_OC_INVERT;
+	if (of_get_property(np, "has-new-stacr-staopc", NULL))
+		dev->features |= EMAC_FTR_HAS_NEW_STACR;
 
-	/* Fixup some feature bits based on the device tree and verify
-	 * we have support for them compiled in
-	 */
+	/* CAB lacks the appropriate properties */
+	if (of_device_is_compatible(np, "ibm,emac-axon"))
+		dev->features |= EMAC_FTR_HAS_NEW_STACR |
+			EMAC_FTR_STACR_OC_INVERT;
+
+	/* Enable TAH/ZMII/RGMII features as found */
 	if (dev->tah_ph != 0) {
 #ifdef CONFIG_IBM_NEW_EMAC_TAH
 		dev->features |= EMAC_FTR_HAS_TAH;
Index: linux-work/drivers/net/ibm_newemac/core.h
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/core.h	2007-11-20 14:46:51.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/core.h	2007-11-20 14:47:02.000000000 +1100
@@ -293,9 +293,9 @@ struct emac_instance {
  */
 #define EMAC_FTR_HAS_RGMII		0x00000020
 /*
- * Set if we have axon-type STACR
+ * Set if we have new type STACR with STAOPC
  */
-#define EMAC_FTR_HAS_AXON_STACR		0x00000040
+#define EMAC_FTR_HAS_NEW_STACR		0x00000040
 
 
 /* Right now, we don't quite handle the always/possible masks on the
@@ -307,7 +307,7 @@ enum {
 
 	EMAC_FTRS_POSSIBLE	=
 #ifdef CONFIG_IBM_NEW_EMAC_EMAC4
-	    EMAC_FTR_EMAC4	| EMAC_FTR_HAS_AXON_STACR	|
+	    EMAC_FTR_EMAC4	| EMAC_FTR_HAS_NEW_STACR	|
 	    EMAC_FTR_STACR_OC_INVERT	|
 #endif
 #ifdef CONFIG_IBM_NEW_EMAC_TAH
