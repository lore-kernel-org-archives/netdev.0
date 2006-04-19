From: akpm@osdl.org
Subject: [patch 09/10] bcm43xx: fix pctl slowclock limit calculation
Date: Tue, 18 Apr 2006 21:04:34 -0700
Message-ID: <200604190405.k3J45G9R008015@shell0.pdx.osdl.net>
Cc: linville@tuxdriver.com, netdev@vger.kernel.org, akpm@osdl.org,
	mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16332 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750774AbWDSEGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 00:06:08 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Michael Buesch <mb@bu3sch.de>

This fixes coverity bug:
http://marc.theaimsgroup.com/?l=linux-netdev&m=114417628413880&w=2

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/wireless/bcm43xx/bcm43xx_power.c |  115 ++++++++++-------
 drivers/net/wireless/bcm43xx/bcm43xx_power.h |    9 +
 2 files changed, 77 insertions(+), 47 deletions(-)

diff -puN drivers/net/wireless/bcm43xx/bcm43xx_power.c~bcm43xx-fix-pctl-slowclock-limit-calculation drivers/net/wireless/bcm43xx/bcm43xx_power.c
--- devel/drivers/net/wireless/bcm43xx/bcm43xx_power.c~bcm43xx-fix-pctl-slowclock-limit-calculation	2006-04-12 18:12:22.000000000 -0700
+++ devel-akpm/drivers/net/wireless/bcm43xx/bcm43xx_power.c	2006-04-12 18:12:22.000000000 -0700
@@ -35,77 +35,101 @@
 #include "bcm43xx_main.h"
 
 
+/* Get the Slow Clock Source */
+static int bcm43xx_pctl_get_slowclksrc(struct bcm43xx_private *bcm)
+{
+	u32 tmp;
+	int err;
+
+	assert(bcm->current_core == &bcm->core_chipcommon);
+	if (bcm->current_core->rev < 6) {
+		if (bcm->bustype == BCM43xx_BUSTYPE_PCMCIA ||
+		    bcm->bustype == BCM43xx_BUSTYPE_SB)
+			return BCM43xx_PCTL_CLKSRC_XTALOS;
+		if (bcm->bustype == BCM43xx_BUSTYPE_PCI) {
+			err = bcm43xx_pci_read_config32(bcm, BCM43xx_PCTL_OUT, &tmp);
+			assert(!err);
+			if (tmp & 0x10)
+				return BCM43xx_PCTL_CLKSRC_PCI;
+			return BCM43xx_PCTL_CLKSRC_XTALOS;
+		}
+	}
+	if (bcm->current_core->rev < 10) {
+		tmp = bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SLOWCLKCTL);
+		tmp &= 0x7;
+		if (tmp == 0)
+			return BCM43xx_PCTL_CLKSRC_LOPWROS;
+		if (tmp == 1)
+			return BCM43xx_PCTL_CLKSRC_XTALOS;
+		if (tmp == 2)
+			return BCM43xx_PCTL_CLKSRC_PCI;
+	}
+
+	return BCM43xx_PCTL_CLKSRC_XTALOS;
+}
+
 /* Get max/min slowclock frequency
  * as described in http://bcm-specs.sipsolutions.net/PowerControl
  */
 static int bcm43xx_pctl_clockfreqlimit(struct bcm43xx_private *bcm,
 				       int get_max)
 {
-	int limit = 0;
+	int limit;
+	int clocksrc;
 	int divisor;
-	int selection;
-	int err;
 	u32 tmp;
-	struct bcm43xx_coreinfo *old_core;
 
-	if (!(bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL))
-		goto out;
-	old_core = bcm->current_core;
-	err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
-	if (err)
-		goto out;
+	assert(bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL);
+	assert(bcm->current_core == &bcm->core_chipcommon);
 
+	clocksrc = bcm43xx_pctl_get_slowclksrc(bcm);
 	if (bcm->current_core->rev < 6) {
-		if ((bcm->bustype == BCM43xx_BUSTYPE_PCMCIA) ||
-			(bcm->bustype == BCM43xx_BUSTYPE_SB)) {
-			selection = 1;
+		switch (clocksrc) {
+		case BCM43xx_PCTL_CLKSRC_PCI:
+			divisor = 64;
+			break;
+		case BCM43xx_PCTL_CLKSRC_XTALOS:
 			divisor = 32;
-		} else {
-			err = bcm43xx_pci_read_config32(bcm, BCM43xx_PCTL_OUT, &tmp);
-			if (err) {
-				printk(KERN_ERR PFX "clockfreqlimit pcicfg read failure\n");
-				goto out_switchback;
-			}
-			if (tmp & 0x10) {
-				/* PCI */
-				selection = 2;
-				divisor = 64;
-			} else {
-				/* XTAL */
-				selection = 1;
-				divisor = 32;
-			}
+			break;
+		default:
+			assert(0);
+			divisor = 1;
 		}
 	} else if (bcm->current_core->rev < 10) {
-		selection = (tmp & 0x07);
-		if (selection) {
+		switch (clocksrc) {
+		case BCM43xx_PCTL_CLKSRC_LOPWROS:
+			divisor = 1;
+			break;
+		case BCM43xx_PCTL_CLKSRC_XTALOS:
+		case BCM43xx_PCTL_CLKSRC_PCI:
 			tmp = bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SLOWCLKCTL);
-			divisor = 4 * (1 + ((tmp & 0xFFFF0000) >> 16));
-		} else
+			divisor = ((tmp & 0xFFFF0000) >> 16) + 1;
+			divisor *= 4;
+			break;
+		default:
+			assert(0);
 			divisor = 1;
+		}
 	} else {
 		tmp = bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SYSCLKCTL);
-		divisor = 4 * (1 + ((tmp & 0xFFFF0000) >> 16));
-		selection = 1;
+		divisor = ((tmp & 0xFFFF0000) >> 16) + 1;
+		divisor *= 4;
 	}
-	
-	switch (selection) {
-	case 0:
-		/* LPO */
+
+	switch (clocksrc) {
+	case BCM43xx_PCTL_CLKSRC_LOPWROS:
 		if (get_max)
 			limit = 43000;
 		else
 			limit = 25000;
 		break;
-	case 1:
-		/* XTAL */
+	case BCM43xx_PCTL_CLKSRC_XTALOS:
 		if (get_max)
 			limit = 20200000;
 		else
 			limit = 19800000;
 		break;
-	case 2:
-		/* PCI */
+	case BCM43xx_PCTL_CLKSRC_PCI:
 		if (get_max)
 			limit = 34000000;
 		else
@@ -113,17 +137,14 @@ static int bcm43xx_pctl_clockfreqlimit(s
 		break;
 	default:
 		assert(0);
+		limit = 0;
 	}
 	limit /= divisor;
 
-out_switchback:
-	err = bcm43xx_switch_core(bcm, old_core);
-	assert(err == 0);
-
-out:
 	return limit;
 }
 
+
 /* init power control
  * as described in http://bcm-specs.sipsolutions.net/PowerControl
  */
diff -puN drivers/net/wireless/bcm43xx/bcm43xx_power.h~bcm43xx-fix-pctl-slowclock-limit-calculation drivers/net/wireless/bcm43xx/bcm43xx_power.h
--- devel/drivers/net/wireless/bcm43xx/bcm43xx_power.h~bcm43xx-fix-pctl-slowclock-limit-calculation	2006-04-12 18:12:22.000000000 -0700
+++ devel-akpm/drivers/net/wireless/bcm43xx/bcm43xx_power.h	2006-04-12 18:12:22.000000000 -0700
@@ -33,6 +33,15 @@
 
 #include <linux/types.h>
 
+/* Clock sources */
+enum {
+	/* PCI clock */
+	BCM43xx_PCTL_CLKSRC_PCI,
+	/* Crystal slow clock oscillator */
+	BCM43xx_PCTL_CLKSRC_XTALOS,
+	/* Low power oscillator */
+	BCM43xx_PCTL_CLKSRC_LOPWROS,
+};
 
 struct bcm43xx_private;
 
_
