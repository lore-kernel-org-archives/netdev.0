From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH 3/4] bcm43xx: Port suspend-mac-in-long-pwork from d80211
Date: Tue, 13 Jun 2006 21:18:40 +0200
Message-ID: <200606132118.41175.mb@bu3sch.de>
References: <20060613191206.122150000@ppc1>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:40389
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751102AbWFMTUU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 15:20:20 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Port the Suspend MAC In Long Periodic Work patch from bcm43xx-softmac to bcm43xx-d80211.

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-06-13 21:11:08.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-06-13 21:11:37.000000000 +0200
@@ -743,6 +743,8 @@
 	u32 irq_savedstate;
 	/* Link Quality calculation context. */
 	struct bcm43xx_noise_calculation noisecalc;
+	/* if > 0 MAC is suspended. if == 0 MAC is enabled. */
+	int mac_suspended;
 
 	/* Interrupt Service Routine tasklet (bottom-half) */
 	struct tasklet_struct isr_tasklet;
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-06-13 21:11:24.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-06-13 21:11:37.000000000 +0200
@@ -2169,13 +2169,17 @@
 /* http://bcm-specs.sipsolutions.net/EnableMac */
 void bcm43xx_mac_enable(struct bcm43xx_private *bcm)
 {
-	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
-	                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
-			| BCM43xx_SBF_MAC_ENABLED);
-	bcm43xx_write32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON, BCM43xx_IRQ_READY);
-	bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD); /* dummy read */
-	bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
-	bcm43xx_power_saving_ctl_bits(bcm, -1, -1);
+	bcm->mac_suspended--;
+	assert(bcm->mac_suspended >= 0);
+	if (bcm->mac_suspended == 0) {
+		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
+		                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
+				| BCM43xx_SBF_MAC_ENABLED);
+		bcm43xx_write32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON, BCM43xx_IRQ_READY);
+		bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD); /* dummy read */
+		bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
+		bcm43xx_power_saving_ctl_bits(bcm, -1, -1);
+	}
 }
 
 /* http://bcm-specs.sipsolutions.net/SuspendMAC */
@@ -2184,18 +2188,23 @@
 	int i;
 	u32 tmp;
 
-	bcm43xx_power_saving_ctl_bits(bcm, -1, 1);
-	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
-	                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
-			& ~BCM43xx_SBF_MAC_ENABLED);
-	bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
-	for (i = 100000; i; i--) {
-		tmp = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
-		if (tmp & BCM43xx_IRQ_READY)
-			return;
-		udelay(10);
+	assert(bcm->mac_suspended >= 0);
+	if (bcm->mac_suspended == 0) {
+		bcm43xx_power_saving_ctl_bits(bcm, -1, 1);
+		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
+		                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
+				& ~BCM43xx_SBF_MAC_ENABLED);
+		bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
+		for (i = 100000; i; i--) {
+			tmp = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
+			if (tmp & BCM43xx_IRQ_READY)
+				goto out;
+			udelay(10);
+		}
+		printkl(KERN_ERR PFX "MAC suspend failed\n");
 	}
-	printkl(KERN_ERR PFX "MAC suspend failed\n");
+out:
+	bcm->mac_suspended++;
 }
 
 static void bcm43xx_select_opmode(struct bcm43xx_private *bcm)
@@ -3013,8 +3022,10 @@
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
 		 */
-		bcm43xx_lock_irqonly(bcm, flags);
 		netif_stop_queue(bcm->net_dev);
+		synchronize_net();
+		bcm43xx_lock_irqonly(bcm, flags);
+		bcm43xx_mac_suspend(bcm);
 		if (bcm43xx_using_pio(bcm))
 			bcm43xx_pio_freeze_txqueues(bcm);
 		savedirqs = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
@@ -3037,6 +3048,7 @@
 			bcm43xx_interrupt_enable(bcm, savedirqs);
 			if (bcm43xx_using_pio(bcm))
 				bcm43xx_pio_thaw_txqueues(bcm);
+			bcm43xx_mac_enable(bcm);
 		}
 		netif_wake_queue(bcm->net_dev);
 		mmiowb();
@@ -4371,6 +4383,7 @@
 
 	bcm->ieee = ieee;
 	bcm->irq_savedstate = BCM43xx_IRQ_INITIAL;
+	bcm->mac_suspended = 1;
 	bcm->pci_dev = pci_dev;
 	bcm->net_dev = net_dev;
 	bcm->bad_frames_preempt = modparam_bad_frames_preempt;

--

