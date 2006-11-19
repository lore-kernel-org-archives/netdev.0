From: Martin Michlmayr <tbm@cyrius.com>
Subject: TULIP_MWI fix for Cobalt
Date: Sun, 19 Nov 2006 15:04:23 +0000
Message-ID: <20061119150423.GA7655@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: romieu@fr.zoreil.com, pdh@colonel-panic.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:34315 "EHLO
	sorrow.cyrius.com") by vger.kernel.org with ESMTP id S1756706AbWKSPFv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 10:05:51 -0500
To: val_henson@linux.intel.com, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please consider the patch below.  The original consensus was that
since this is documented in the errata it should be done by default
rather than as a config option.  I think the original author of the
patch doesn't have time to submit a revised version but now that
there's a new maintainer of the Tulip code maybe there's hope to get
this in some way.

This patch is being used in the Debian MIPS kernels and fixes a real
bug.


From: Peter Horton <pdh@colonel-panic.org>

This patch works around the MWI bug on the DC21143 rev 65 Tulip by ensuring
that the receive buffers don't end on a cache line boundary (as documented
in the errata).

This patch is required for the MIPs based Cobalt Qube/RaQ as supporting the
extra PCI commands seems to reduce the chance of a hard lockup between the
Tulip and the PCI bridge.

--- linux.git.orig/drivers/net/tulip/tulip_core.c	2006-01-29 21:43:40.000000000 +0000
+++ linux.git/drivers/net/tulip/tulip_core.c	2006-01-29 21:56:50.000000000 +0000
@@ -294,6 +294,8 @@
 	if (tp->mii_cnt  ||  (tp->mtable  &&  tp->mtable->has_mii))
 		iowrite32(0x00040000, ioaddr + CSR6);
 
+	printk(KERN_DEBUG "%s: CSR0 %08x\n", dev->name, tp->csr0);
+
 	/* Reset the chip, holding bit 0 set at least 50 PCI cycles. */
 	iowrite32(0x00000001, ioaddr + CSR0);
 	udelay(100);
@@ -1155,8 +1157,10 @@
 	/* if we have any cache line size at all, we can do MRM */
 	csr0 |= MRM;
 
+#ifndef CONFIG_TULIP_MWI_DC21143
 	/* ...and barring hardware bugs, MWI */
 	if (!(tp->chip_id == DC21143 && tp->revision == 65))
+#endif
 		csr0 |= MWI;
 
 	/* set or disable MWI in the standard PCI command bit.
@@ -1182,7 +1186,7 @@
 	 */
 	switch (cache) {
 	case 8:
-		csr0 |= MRL | (1 << CALShift) | (16 << BurstLenShift);
+		csr0 |= MRL | (1 << CALShift) | (8 << BurstLenShift);
 		break;
 	case 16:
 		csr0 |= MRL | (2 << CALShift) | (16 << BurstLenShift);
Index: linux.git/drivers/net/tulip/tulip.h
===================================================================
--- linux.git.orig/drivers/net/tulip/tulip.h	2006-01-29 21:43:40.000000000 +0000
+++ linux.git/drivers/net/tulip/tulip.h	2006-01-29 21:52:01.000000000 +0000
@@ -262,7 +262,15 @@
 #define RX_RING_SIZE	128 
 #define MEDIA_MASK     31
 
-#define PKT_BUF_SZ		1536	/* Size of each temporary Rx buffer. */
+/* MWI can fail on 21143 rev 65 if the receive buffer ends
+   on a cache line boundary. Ensure it doesn't ...
+*/
+
+#ifdef CONFIG_TULIP_MWI_DC21143
+#define PKT_BUF_SZ		(1536 + 4)	/* Size of each temporary Rx buffer. */
+#else
+#define PKT_BUF_SZ		1536		/* Size of each temporary Rx buffer. */
+#endif
 
 #define TULIP_MIN_CACHE_LINE	8	/* in units of 32-bit words */
 
Index: linux.git/drivers/net/tulip/Kconfig
===================================================================
--- linux.git.orig/drivers/net/tulip/Kconfig	2006-01-29 21:48:09.000000000 +0000
+++ linux.git/drivers/net/tulip/Kconfig	2006-01-29 21:50:28.000000000 +0000
@@ -57,6 +57,16 @@
 
 	  If unsure, say N.
 
+config TULIP_MWI_DC21143
+	bool "Enable MWI workaround on dc21143 controllers"
+	depends on TULIP_MWI
+	help
+	  This enables a workaround for MWI ("New bus configuration") on DC21143
+	  controllers.  Normally MWI is disabled on these chips because of
+	  hardware errata.
+
+	  If unsure, say N.
+
 config TULIP_MMIO
 	bool "Use PCI shared mem for NIC registers"
 	depends on TULIP


-- 
Martin Michlmayr
http://www.cyrius.com/
