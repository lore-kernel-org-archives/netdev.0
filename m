From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 5/6] ibm_newemac: PowerPC 440GX EMAC PHY clock workaround
Date: Tue, 22 Apr 2008 10:46:46 +1000
Message-ID: <20080422004803.7F497DE2C5@ozlabs.org>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:43527 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761120AbYDVAsG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 20:48:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valentine Barshak <vbarshak@ru.mvista.com>

The PowerPC 440GX Taishan board fails to reset EMAC3 (reset timeout error)
if there's no link. Because of that it fails to find PHY chip. The older ibm_emac
driver had a workaround for that: the EMAC_CLK_INTERNAL/EMAC_CLK_EXTERNAL macros,
which toggle the Ethernet Clock Select bit in the SDR0_MFR register. This patch
does the same for "ibm,emac-440gx" compatible chips. The workaround forces
clock on -all- EMACs, so we select clock under global emac_phy_map_lock.

BenH: Made that #ifdef CONFIG_PPC_DCR_NATIVE for now as dcri_* stuff doesn't
exist for MMIO type DCRs like Cell. Some future rework & improvements of the
DCR infrastructure will make that cleaner but for now, this makes it work.

Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

---
 drivers/net/ibm_newemac/core.c |   18 +++++++++++++++++-
 drivers/net/ibm_newemac/core.h |    8 ++++++--
 2 files changed, 23 insertions(+), 3 deletions(-)

--- linux-work.orig/drivers/net/ibm_newemac/core.c	2008-04-22 10:11:59.000000000 +1000
+++ linux-work/drivers/net/ibm_newemac/core.c	2008-04-22 10:31:18.000000000 +1000
@@ -43,6 +43,8 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/uaccess.h>
+#include <asm/dcr.h>
+#include <asm/dcr-regs.h>
 
 #include "core.h"
 
@@ -2333,6 +2335,11 @@ static int __devinit emac_init_phy(struc
 	dev->phy.mdio_read = emac_mdio_read;
 	dev->phy.mdio_write = emac_mdio_write;
 
+	/* Enable internal clock source */
+#ifdef CONFIG_PPC_DCR_NATIVE
+	if (emac_has_feature(dev, EMAC_FTR_440GX_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_MFR, 0, SDR0_MFR_ECS);
+#endif
 	/* Configure EMAC with defaults so we can at least use MDIO
 	 * This is needed mostly for 440GX
 	 */
@@ -2365,6 +2372,12 @@ static int __devinit emac_init_phy(struc
 			if (!emac_mii_phy_probe(&dev->phy, i))
 				break;
 		}
+
+	/* Enable external clock source */
+#ifdef CONFIG_PPC_DCR_NATIVE
+	if (emac_has_feature(dev, EMAC_FTR_440GX_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_MFR, SDR0_MFR_ECS, 0);
+#endif
 	mutex_unlock(&emac_phy_map_lock);
 	if (i == 0x20) {
 		printk(KERN_WARNING "%s: can't find PHY!\n", np->full_name);
@@ -2490,8 +2503,11 @@ static int __devinit emac_init_config(st
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
Index: linux-work/drivers/net/ibm_newemac/core.h
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/core.h	2008-04-22 10:06:31.000000000 +1000
+++ linux-work/drivers/net/ibm_newemac/core.h	2008-04-22 10:30:03.000000000 +1000
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
