From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx: voluntary preemtion in the calibration loops
Date: Wed, 28 Jun 2006 20:17:57 +0200
Message-ID: <200606282017.57295.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:15252
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750793AbWF1SSV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 14:18:21 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds voluntary preemption points into the
PHY calibration loops to allow non-CONFIG_PREEMPT machines
to not suffer from huge delays.
CONFIG_PREEMPT machines are already fine, because all this
code is run in non-atomic process context.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_phy.c	2006-06-24 22:13:44.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_phy.c	2006-06-28 18:24:59.000000000 +0200
@@ -81,6 +81,16 @@
 static void bcm43xx_phy_initg(struct bcm43xx_private *bcm);
 
 
+static inline
+void bcm43xx_voluntary_preempt(void)
+{
+	assert(!in_atomic() && !in_irq() &&
+	       !in_interrupt() && !irqs_disabled());
+#ifndef CONFIG_PREEMPT
+	cond_resched();
+#endif /* CONFIG_PREEMPT */
+}
+
 void bcm43xx_raw_phy_lock(struct bcm43xx_private *bcm)
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
@@ -133,22 +143,14 @@
 void bcm43xx_phy_calibrate(struct bcm43xx_private *bcm)
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
-	unsigned long flags;
 
 	bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD); /* Dummy read. */
 	if (phy->calibrated)
 		return;
 	if (phy->type == BCM43xx_PHYTYPE_G && phy->rev == 1) {
-		/* We do not want to be preempted while calibrating
-		 * the hardware.
-		 */
-		local_irq_save(flags);
-
 		bcm43xx_wireless_core_reset(bcm, 0);
 		bcm43xx_phy_initg(bcm);
 		bcm43xx_wireless_core_reset(bcm, 1);
-
-		local_irq_restore(flags);
 	}
 	phy->calibrated = 1;
 }
@@ -1299,7 +1301,9 @@
 {
 	int i;
 	u16 ret = 0;
+	unsigned long flags;
 
+	local_irq_save(flags);
 	for (i = 0; i < 10; i++){
 		bcm43xx_phy_write(bcm, 0x0015, 0xAFA0);
 		udelay(1);
@@ -1309,6 +1313,8 @@
 		udelay(40);
 		ret += bcm43xx_phy_read(bcm, 0x002C);
 	}
+	local_irq_restore(flags);
+	bcm43xx_voluntary_preempt();
 
 	return ret;
 }
@@ -1435,6 +1441,7 @@
 	}
 	ret = bcm43xx_phy_read(bcm, 0x002D);
 	local_irq_restore(flags);
+	bcm43xx_voluntary_preempt();
 
 	return ret;
 }
@@ -1760,6 +1767,7 @@
 			bcm43xx_radio_write16(bcm, 0x43, i);
 			bcm43xx_radio_write16(bcm, 0x52, radio->txctl2);
 			udelay(10);
+			bcm43xx_voluntary_preempt();
 
 			bcm43xx_phy_set_baseband_attenuation(bcm, j * 2);
 
@@ -1803,6 +1811,7 @@
 					      radio->txctl2
 					      | (3/*txctl1*/ << 4));//FIXME: shouldn't txctl1 be zero here and 3 in the loop above?
 			udelay(10);
+			bcm43xx_voluntary_preempt();
 
 			bcm43xx_phy_set_baseband_attenuation(bcm, j * 2);
 
@@ -1824,6 +1833,7 @@
 		bcm43xx_phy_write(bcm, 0x0812, (r27 << 8) | 0xA2);
 		udelay(2);
 		bcm43xx_phy_write(bcm, 0x0812, (r27 << 8) | 0xA3);
+		bcm43xx_voluntary_preempt();
 	} else
 		bcm43xx_phy_write(bcm, 0x0015, r27 | 0xEFA0);
 	bcm43xx_phy_lo_adjust(bcm, is_initializing);
@@ -2188,12 +2198,6 @@
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	int err = -ENODEV;
-	unsigned long flags;
-
-	/* We do not want to be preempted while calibrating
-	 * the hardware.
-	 */
-	local_irq_save(flags);
 
 	switch (phy->type) {
 	case BCM43xx_PHYTYPE_A:
@@ -2227,7 +2231,6 @@
 		err = 0;
 		break;
 	}
-	local_irq_restore(flags);
 	if (err)
 		printk(KERN_WARNING PFX "Unknown PHYTYPE found!\n");
 


-- 
Greetings Michael.
