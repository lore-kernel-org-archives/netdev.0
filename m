From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH] bcm43xx: fix pctl slowclock limit calculation
Date: Thu, 13 Apr 2006 02:30:26 +0200
Message-ID: <200604130230.27509.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
   "Bunk, Adrian" <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>
Content-Disposition: inline
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

This fixes coverity bug:
http://marc.theaimsgroup.com/?l=linux-netdev&m=114417628413880&w=2

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_power.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_power.c	2006-04-11 06:00:00.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_power.c	2006-04-13 02:10:17.000000000 +0200
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
@@ -113,17 +137,14 @@
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
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_power.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_power.h	2006-04-11 06:00:00.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_power.h	2006-04-13 01:28:05.000000000 +0200
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
 

-- 
Greetings Michael.
