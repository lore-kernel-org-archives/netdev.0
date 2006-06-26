From: Michael Buesch <mb@bu3sch.de>
Subject: Re: bcm43xx: "transmit timed out" and apparent hang with "preemptible periodic work" patches
Date: Mon, 26 Jun 2006 17:27:23 +0200
Message-ID: <200606261727.24266.mb@bu3sch.de>
References: <87ac80ps5o.fsf@briny.internal.ondioline.org> <200606261443.47341.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:11978
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751230AbWFZP2r
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 11:28:47 -0400
To: Paul Collins <paul@briny.ondioline.org>
In-Reply-To: <200606261443.47341.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 26 June 2006 14:43, Michael Buesch wrote:
> On Monday 26 June 2006 04:28, Paul Collins wrote:
> > With the bcm43xx periodic work patches that recently made it into
> > Linus's tree, my PowerBook does not survive running overnight.
> > 
> > Yesterday I reverted
> > 
> > 91769e7dd9cef7988dc4280f74ed168351beb5b8 [PATCH] bcm43xx: preemptible periodic work
> > 78ff56a06edc3407996173daf63e48f6b90c7062 [PATCH] bcm43xx: redesign locking
> > 
> > and it was still alive this morning.
> > 
> > The following is logged, but that may not be all since the screen was
> > turned off and kern.log was marked for no-fsync.
> > 
> > Jun 24 06:53:41 briny kernel: NETDEV WATCHDOG: eth1: transmit timed out
> > Jun 24 06:53:41 briny kernel: bcm43xx: Controller RESET (TX timeout) ...
> > Jun 24 06:53:41 briny kernel: bcm43xx: Chip ID 0x4306, rev 0x3
> > Jun 24 06:53:41 briny kernel: bcm43xx: Number of cores: 5
> > Jun 24 06:53:41 briny kernel: bcm43xx: Core 0: ID 0x800, rev 0x4, vendor 0x4243, enabled
> > Jun 24 06:53:41 briny kernel: bcm43xx: Core 1: ID 0x812, rev 0x5, vendor 0x4243, disabled
> > Jun 24 06:53:41 briny kernel: bcm43xx: Core 2: ID 0x80d, rev 0x2, vendor 0x4243, enabled
> > Jun 24 06:53:41 briny kernel: bcm43xx: Core 3: ID 0x807, rev 0x2, vendor 0x4243, disabled
> > Jun 24 06:53:41 briny kernel: bcm43xx: Core 4: ID 0x804, rev 0x9, vendor 0x4243, enabled
> > Jun 24 06:53:41 briny kernel: bcm43xx: PHY connected
> > Jun 24 06:53:41 briny kernel: bcm43xx: Detected PHY: Version: 2, Type 2, Revision 2
> > Jun 24 06:53:41 briny kernel: bcm43xx: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
> > Jun 24 06:53:41 briny kernel: bcm43xx: Radio turned off
> > Jun 24 06:53:41 briny kernel: bcm43xx: Radio turned off
> > Jun 24 06:53:41 briny kernel: bcm43xx: Controller restarted
> 
> Try to get more logs.
> I suggest to do a netconsole for logging.
> 

Also note that current softmac trees have a patch missing.
It seems it got lost somewhere after my merge request.
I already contacted John in private for this, but no reply, yet.
The patch is attached. Maybe it fixes your issue.


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
