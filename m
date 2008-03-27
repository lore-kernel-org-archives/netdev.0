From: Valentine Barshak <vbarshak@ru.mvista.com>
Subject: [PATCH 1/2] ibm_newemac: PowerPC 440GX EMAC PHY clock workaround
Date: Thu, 27 Mar 2008 17:40:44 +0300
Message-ID: <20080327144044.GA8831@ru.mvista.com>
References: <20080327085353.6ac04886@zod.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benh@kernel.crashing.org, jwboyer@linux.vnet.ibm.com,
	jeff@garzik.org, netdev@vger.kernel.org
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [212.176.242.38] ([212.176.242.38]:56391 "EHLO
	vaxon.spb.rtsoft.ru" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752775AbYC0PIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 11:08:18 -0400
Content-Disposition: inline
In-Reply-To: <20080327085353.6ac04886@zod.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PowerPC 440GX Taishan board fails to reset EMAC3 (reset timeout error)
if there's no link. Because of that it fails to find PHY chip. The older ibm_emac
driver had a workaround for that: the EMAC_CLK_INTERNAL/EMAC_CLK_EXTERNAL macros,
which toggle the Ethernet Clock Select bit in the SDR0_MFR register. This patch
does the same for "ibm,emac-440gx" compatible chips. The workaround forces
clock on -all- EMACs, so we select clock under global emac_phy_map_lock.

Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
---
 drivers/net/ibm_newemac/core.c |   16 +++++++++++++++-
 drivers/net/ibm_newemac/core.h |    8 ++++++--
 2 files changed, 21 insertions(+), 3 deletions(-)

diff -pruN linux-2.6.orig/drivers/net/ibm_newemac/core.c linux-2.6/drivers/net/ibm_newemac/core.c
--- linux-2.6.orig/drivers/net/ibm_newemac/core.c	2008-02-22 19:56:26.000000000 +0300
+++ linux-2.6/drivers/net/ibm_newemac/core.c	2008-02-22 20:38:47.000000000 +0300
@@ -43,6 +43,8 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/uaccess.h>
+#include <asm/dcr.h>
+#include <asm/dcr-regs.h>
 
 #include "core.h"
 
@@ -2323,6 +2325,10 @@ static int __devinit emac_init_phy(struc
 	dev->phy.mdio_read = emac_mdio_read;
 	dev->phy.mdio_write = emac_mdio_write;
 
+	/* Enable internal clock source */
+	if (emac_has_feature(dev, EMAC_FTR_440GX_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_MFR, 0, SDR0_MFR_ECS);
+
 	/* Configure EMAC with defaults so we can at least use MDIO
 	 * This is needed mostly for 440GX
 	 */
@@ -2355,6 +2361,11 @@ static int __devinit emac_init_phy(struc
 			if (!emac_mii_phy_probe(&dev->phy, i))
 				break;
 		}
+
+	/* Enable external clock source */
+	if (emac_has_feature(dev, EMAC_FTR_440GX_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_MFR, SDR0_MFR_ECS, 0);
+
 	mutex_unlock(&emac_phy_map_lock);
 	if (i == 0x20) {
 		printk(KERN_WARNING "%s: can't find PHY!\n", np->full_name);
@@ -2480,8 +2491,11 @@ static int __devinit emac_init_config(st
 	}
 
 	/* Check EMAC version */
-	if (of_device_is_compatible(np, "ibm,emac4"))
+	if (of_device_is_compatible(np, "ibm,emac4")) {
 		dev->features |= EMAC_FTR_EMAC4;
+		if (of_device_is_compatible(np, "ibm,emac-440gx"))
+			dev->features |= EMAC_FTR_440GX_PHY_CLK_FIX;
+	}
 
 	/* Fixup some feature bits based on the device tree */
 	if (of_get_property(np, "has-inverted-stacr-oc", NULL))
diff -pruN linux-2.6.orig/drivers/net/ibm_newemac/core.h linux-2.6/drivers/net/ibm_newemac/core.h
--- linux-2.6.orig/drivers/net/ibm_newemac/core.h	2008-02-21 16:45:36.000000000 +0300
+++ linux-2.6/drivers/net/ibm_newemac/core.h	2008-02-22 19:57:44.000000000 +0300
@@ -301,6 +301,10 @@ struct emac_instance {
  * Set if we have new type STACR with STAOPC
  */
 #define EMAC_FTR_HAS_NEW_STACR		0x00000040
+/*
+ * Set if we need phy clock workaround for 440gx
+ */
+#define EMAC_FTR_440GX_PHY_CLK_FIX	0x00000080
 
 
 /* Right now, we don't quite handle the always/possible masks on the
@@ -312,8 +316,8 @@ enum {
 
 	EMAC_FTRS_POSSIBLE	=
 #ifdef CONFIG_IBM_NEW_EMAC_EMAC4
-	    EMAC_FTR_EMAC4	| EMAC_FTR_HAS_NEW_STACR	|
-	    EMAC_FTR_STACR_OC_INVERT	|
+	    EMAC_FTR_EMAC4 | EMAC_FTR_HAS_NEW_STACR |
+	    EMAC_FTR_STACR_OC_INVERT | EMAC_FTR_440GX_PHY_CLK_FIX |
 #endif
 #ifdef CONFIG_IBM_NEW_EMAC_TAH
 	    EMAC_FTR_HAS_TAH	|

