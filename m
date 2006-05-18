From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [patch 08/10] [RFT] bcm43xx: powercontrol support for PCI-E devices
Date: Fri, 19 May 2006 00:00:08 +0200
Message-ID: <20060519155739.833990000@polimi.it>
References: <20060519154451.042749000@polimi.it>
Cc: Edgar Hucek <hostmaster@ed-soft.at>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Louis E Garcia II <louisg00@bellsouth.net>,
	Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213-156-52-114.fastres.net ([213.156.52.114]:388 "EHLO
	213-156-52-114.fastres.net") by vger.kernel.org with ESMTP
	id S932395AbWESP5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 11:57:42 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=bcm43xx-pcie_powercontrol.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add powercontrol support for PCI-E devices.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -140,6 +140,7 @@
 
 /* Chipcommon registers. */
 #define BCM43xx_CHIPCOMMON_CAPABILITIES 	0x04
+#define BCM43xx_CHIPCOMMON_CTL			0x28
 #define BCM43xx_CHIPCOMMON_PLLONDELAY		0xB0
 #define BCM43xx_CHIPCOMMON_FREFSELDELAY		0xB4
 #define BCM43xx_CHIPCOMMON_SLOWCLKCTL		0xB8
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_power.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_power.c
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_power.c
@@ -153,8 +153,6 @@ int bcm43xx_pctl_init(struct bcm43xx_pri
 	int err, maxfreq;
 	struct bcm43xx_coreinfo *old_core;
 
-	if (!(bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL))
-		return 0;
 	old_core = bcm->current_core;
 	err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
 	if (err == -ENODEV)
@@ -162,6 +160,21 @@ int bcm43xx_pctl_init(struct bcm43xx_pri
 	if (err)
 		goto out;
 
+	if (bcm->chip_id == 0x4321) {
+		if (bcm->chip_rev == 1)
+			bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_CTL, 0x00A4);
+		if (bcm->chip_rev == 0)
+			bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_CTL, 0x03A4);
+	}
+
+	if (!(bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL))
+		return 0;
+
+	if (bcm->current_core->rev >= 10)
+		bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_SYSCLKCTL,
+			(bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SYSCLKCTL)
+			& 0x0000FFFF) | 0x40000);
+
 	maxfreq = bcm43xx_pctl_clockfreqlimit(bcm, 1);
 	bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_PLLONDELAY,
 			(maxfreq * 150 + 999999) / 1000000);

--
Ciao
Stefano
