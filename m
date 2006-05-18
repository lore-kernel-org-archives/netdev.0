From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [patch 09/10] [RFT] bcm43xx: backplane setup for PCI-E devices and devices with PCI core ID > 10
Date: Fri, 19 May 2006 00:00:09 +0200
Message-ID: <20060519155751.186032000@polimi.it>
References: <20060519154451.042749000@polimi.it>
Cc: Edgar Hucek <hostmaster@ed-soft.at>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Louis E Garcia II <louisg00@bellsouth.net>,
	Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213-156-52-114.fastres.net ([213.156.52.114]:55430 "EHLO
	213-156-52-114.fastres.net") by vger.kernel.org with ESMTP
	id S932386AbWESP5x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 11:57:53 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=bcm43xx-pcie_backplane.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Backplane setup for PCI-E devices and PCI devices with PCI Core ID > 10. 
Use chipcommon if possible while broadcasting PCI settings.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -154,6 +154,7 @@
 /* SBTOPCI2 values. */
 #define BCM43xx_SBTOPCI2_PREFETCH	0x4
 #define BCM43xx_SBTOPCI2_BURST		0x8
+#define BCM43xx_SBTOPCI2_MEMREAD_MULTI	0x20
 
 /* PCI-E core registers. */
 #define BCM43xx_PCIECORE_REG_ADDR	0x0130
@@ -173,6 +174,14 @@
 #define BCM43xx_PCIE_MDIO_TA	0x00020000
 #define BCM43xx_PCIE_MDIO_TC	0x0100
 
+/* MDIO devices. */
+#define BCM43xx_MDIO_SERDES_RX	0x1F
+
+/* SERDES RX registers. */
+#define BCM43xx_SERDES_RXTIMER	0x2
+#define BCM43xx_SERDES_CDR	0x6
+#define BCM43xx_SERDES_CDR_BW	0x7
+
 /* Chipcommon capabilities. */
 #define BCM43xx_CAPABILITIES_PCTL		0x00040000
 #define BCM43xx_CAPABILITIES_PLLMASK		0x00030000
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2952,18 +2952,26 @@ static void bcm43xx_pcicore_broadcast_va
 
 static int bcm43xx_pcicore_commit_settings(struct bcm43xx_private *bcm)
 {
-	int err;
-	struct bcm43xx_coreinfo *old_core;
+	int err = 0;
 
-	old_core = bcm->current_core;
-	err = bcm43xx_switch_core(bcm, &bcm->core_pci);
-	if (err)
-		goto out;
+	bcm->irq_savedstate = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 
-	bcm43xx_pcicore_broadcast_value(bcm, 0xfd8, 0x00000000);
+	if (bcm->core_chipcommon.available) {
+		err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
+		if (err)
+			goto out;
+
+		bcm43xx_pcicore_broadcast_value(bcm, 0xfd8, 0x00000000);
+
+		/* this function is always called when a PCI core is mapped */
+		err = bcm43xx_switch_core(bcm, &bcm->core_pci);
+		if (err)
+			goto out;
+	} else
+		bcm43xx_pcicore_broadcast_value(bcm, 0xfd8, 0x00000000);
+
+	bcm43xx_interrupt_enable(bcm, bcm->irq_savedstate);
 
-	bcm43xx_switch_core(bcm, old_core);
-	assert(err == 0);
 out:
 	return err;
 }
@@ -3026,7 +3034,8 @@ static int bcm43xx_setup_backplane_pci_c
 	if (err)
 		goto out;
 
-	if (bcm->core_pci.rev < 6) {
+	if (bcm->current_core->rev < 6 ||
+	    bcm->current_core->id == BCM43xx_COREID_PCI) {
 		value = bcm43xx_read32(bcm, BCM43xx_CIR_SBINTVEC);
 		value |= (1 << backplane_flag_nr);
 		bcm43xx_write32(bcm, BCM43xx_CIR_SBINTVEC, value);
@@ -3044,21 +3053,46 @@ static int bcm43xx_setup_backplane_pci_c
 		}
 	}
 
-	value = bcm43xx_read32(bcm, BCM43xx_PCICORE_SBTOPCI2);
-	value |= BCM43xx_SBTOPCI2_PREFETCH | BCM43xx_SBTOPCI2_BURST;
-	bcm43xx_write32(bcm, BCM43xx_PCICORE_SBTOPCI2, value);
-
-	if (bcm->core_pci.rev < 5) {
-		value = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
-		value |= (2 << BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_SHIFT)
-			 & BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
-		value |= (3 << BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_SHIFT)
-			 & BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, value);
-		err = bcm43xx_pcicore_commit_settings(bcm);
-		assert(err == 0);
+	if (bcm->current_core->id == BCM43xx_COREID_PCI) {
+		value = bcm43xx_read32(bcm, BCM43xx_PCICORE_SBTOPCI2);
+		value |= BCM43xx_SBTOPCI2_PREFETCH | BCM43xx_SBTOPCI2_BURST;
+		bcm43xx_write32(bcm, BCM43xx_PCICORE_SBTOPCI2, value);
+
+		if (bcm->current_core->rev < 5) {
+			value = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
+			value |= (2 << BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_SHIFT)
+				 & BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
+			value |= (3 << BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_SHIFT)
+				 & BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
+			bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, value);
+			err = bcm43xx_pcicore_commit_settings(bcm);
+			assert(err == 0);
+		} else if (bcm->current_core->rev >= 11) {
+			value = bcm43xx_read32(bcm, BCM43xx_PCICORE_SBTOPCI2);
+			value |= BCM43xx_SBTOPCI2_MEMREAD_MULTI;
+			bcm43xx_write32(bcm, BCM43xx_PCICORE_SBTOPCI2, value);
+		}
+	} else {
+		if (bcm->current_core->rev == 0 || bcm->current_core->rev == 1) {
+			value = bcm43xx_pcie_reg_read(bcm, BCM43xx_PCIE_TLP_WORKAROUND);
+			value |= 0x8;
+			bcm43xx_pcie_reg_write(bcm, BCM43xx_PCIE_TLP_WORKAROUND,
+					       value);
+		}
+		if (bcm->current_core->rev == 0) {
+			bcm43xx_pcie_mdio_write(bcm, BCM43xx_MDIO_SERDES_RX,
+						BCM43xx_SERDES_RXTIMER, 0x8128);
+			bcm43xx_pcie_mdio_write(bcm, BCM43xx_MDIO_SERDES_RX,
+						BCM43xx_SERDES_CDR, 0x0100);
+			bcm43xx_pcie_mdio_write(bcm, BCM43xx_MDIO_SERDES_RX,
+						BCM43xx_SERDES_CDR_BW, 0x1466);
+		} else if (bcm->current_core->rev == 1) {
+			value = bcm43xx_pcie_reg_read(bcm, BCM43xx_PCIE_DLLP_LINKCTL);
+			value |= 0x40;
+			bcm43xx_pcie_reg_write(bcm, BCM43xx_PCIE_DLLP_LINKCTL,
+					       value);
+		}
 	}
-
 out_switch_back:
 	err = bcm43xx_switch_core(bcm, old_core);
 out:

--
Ciao
Stefano
