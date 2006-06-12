From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx: suspend MAC while executing long pwork
Date: Mon, 12 Jun 2006 17:02:22 +0200
Message-ID: <200606121702.22661.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:26550
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1752021AbWFLPCi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 11:02:38 -0400
To: "John Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,
Please queue this for 2.6.18.

--

Suspend MAC (and make MAC-suspend refcounting) when doing
long periodic work.
On long periodic work, we disable IRQs on the device, so
we don't want the MAC to stay operating and probably miss
packets due do non-delivery of interrupts.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx.h	2006-06-05 18:19:59.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h	2006-06-12 16:20:28.000000000 +0200
@@ -723,6 +723,8 @@
 	u32 irq_savedstate;
 	/* Link Quality calculation context. */
 	struct bcm43xx_noise_calculation noisecalc;
+	/* if > 0 MAC is suspended. if == 0 MAC is enabled. */
+	int mac_suspended;
 
 	/* Threshold values. */
 	//TODO: The RTS thr has to be _used_. Currently, it is only set via WX.
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-06-05 20:17:36.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-06-12 16:41:41.000000000 +0200
@@ -2284,13 +2284,17 @@
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
@@ -2299,18 +2303,23 @@
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
 
 void bcm43xx_set_iwmode(struct bcm43xx_private *bcm,
@@ -3168,8 +3177,10 @@
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
@@ -3192,6 +3203,7 @@
 			bcm43xx_interrupt_enable(bcm, savedirqs);
 			if (bcm43xx_using_pio(bcm))
 				bcm43xx_pio_thaw_txqueues(bcm);
+			bcm43xx_mac_enable(bcm);
 		}
 		netif_wake_queue(bcm->net_dev);
 		mmiowb();
@@ -3774,6 +3786,7 @@
 	bcm->softmac->set_channel = bcm43xx_ieee80211_set_chan;
 
 	bcm->irq_savedstate = BCM43xx_IRQ_INITIAL;
+	bcm->mac_suspended = 1;
 	bcm->pci_dev = pci_dev;
 	bcm->net_dev = net_dev;
 	bcm->bad_frames_preempt = modparam_bad_frames_preempt;


-- 
Greetings Michael.
