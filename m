From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [patch 02/10] [RFT] bcm43xx: functions for access to PCI-E registers and PCI-E MDIO
Date: Fri, 19 May 2006 00:00:02 +0200
Message-ID: <20060519155630.586019000@polimi.it>
References: <20060519154451.042749000@polimi.it>
Cc: Edgar Hucek <hostmaster@ed-soft.at>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Louis E Garcia II <louisg00@bellsouth.net>,
	Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213-156-52-114.fastres.net ([213.156.52.114]:22898 "EHLO
	213-156-52-114.fastres.net") by vger.kernel.org with ESMTP
	id S932367AbWESP4c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 11:56:32 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=bcm43xx-pcie_core_rw.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add read and write functions for PCI-E registers
Add write function for MDIO slaves.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2973,6 +2973,45 @@ out:
 	return err;
 }
 
+static u32 bcm43xx_pcie_reg_read(struct bcm43xx_private *bcm, u32 address)
+{
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_REG_ADDR, address);
+	return bcm43xx_read32(bcm, BCM43xx_PCIECORE_REG_DATA);
+}
+
+static void bcm43xx_pcie_reg_write(struct bcm43xx_private *bcm, u32 address,
+				   u32 data)
+{
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_REG_ADDR, address);
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_REG_DATA, data);
+}
+
+static int bcm43xx_pcie_mdio_write(struct bcm43xx_private *bcm, u8 dev, u8 reg,
+				   u16 data)
+{
+	int i;
+
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_MDIO_CTL, 0x0082);
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_MDIO_DATA, BCM43xx_PCIE_MDIO_ST |
+			BCM43xx_PCIE_MDIO_WT | (dev << BCM43xx_PCIE_MDIO_DEV) |
+			(reg << BCM43xx_PCIE_MDIO_REG) | BCM43xx_PCIE_MDIO_TA |
+			data);
+	udelay(10);
+
+	for (i = 0; i < 10; i++) {
+		if (bcm43xx_read32(bcm, BCM43xx_PCIECORE_MDIO_CTL) &
+		    BCM43xx_PCIE_MDIO_TC)
+			return 0;
+		udelay(1000);
+	}
+	if (bcm43xx_read32(bcm, BCM43xx_PCIECORE_MDIO_CTL) &
+	    BCM43xx_PCIE_MDIO_TC)
+		return 0;
+
+	printk(KERN_ERR PFX "Error: MDIO transaction failed\n");
+	return -EIO;
+}
+
 /* Make an I/O Core usable. "core_mask" is the bitmask of the cores to enable.
  * To enable core 0, pass a core_mask of 1<<0
  */
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -154,6 +154,24 @@
 #define BCM43xx_SBTOPCI2_PREFETCH	0x4
 #define BCM43xx_SBTOPCI2_BURST		0x8
 
+/* PCI-E core registers. */
+#define BCM43xx_PCIECORE_REG_ADDR	0x0130
+#define BCM43xx_PCIECORE_REG_DATA	0x0134
+#define BCM43xx_PCIECORE_MDIO_CTL	0x0128
+#define BCM43xx_PCIECORE_MDIO_DATA	0x012C
+
+/* PCI-E registers. */
+#define BCM43xx_PCIE_TLP_WORKAROUND	0x0004
+#define BCM43xx_PCIE_DLLP_LINKCTL	0x0100
+
+/* PCI-E MDIO bits. */
+#define BCM43xx_PCIE_MDIO_ST	0x40000000
+#define BCM43xx_PCIE_MDIO_WT	0x10000000
+#define BCM43xx_PCIE_MDIO_DEV	22
+#define BCM43xx_PCIE_MDIO_REG	18
+#define BCM43xx_PCIE_MDIO_TA	0x00020000
+#define BCM43xx_PCIE_MDIO_TC	0x0100
+
 /* Chipcommon capabilities. */
 #define BCM43xx_CAPABILITIES_PCTL		0x00040000
 #define BCM43xx_CAPABILITIES_PLLMASK		0x00030000

--
Ciao
Stefano
