From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/4] forcedeth: add vitesse phy
Date: Mon, 21 May 2007 20:22:45 -0400
Message-ID: <465237D5.4050809@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070402090800060803060900"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:15608 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757901AbXEVDIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 23:08:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070402090800060803060900
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds errata support for the vitesse phy.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------070402090800060803060900
Content-Type: text/plain;
 name="patch-forcedeth-vitesse"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-vitesse"

--- old/drivers/net/forcedeth.c	2007-05-01 15:30:53.000000000 -0400
+++ new/drivers/net/forcedeth.c	2007-05-01 15:30:57.000000000 -0400
@@ -550,6 +550,7 @@
 /* PHY defines */
 #define PHY_OUI_MARVELL	0x5043
 #define PHY_OUI_CICADA	0x03f1
+#define PHY_OUI_VITESSE	0x01c1
 #define PHYID1_OUI_MASK	0x03ff
 #define PHYID1_OUI_SHFT	6
 #define PHYID2_OUI_MASK	0xfc00
@@ -557,12 +558,29 @@
 #define PHYID2_MODEL_MASK		0x03f0
 #define PHY_MODEL_MARVELL_E3016		0x220
 #define PHY_MARVELL_E3016_INITMASK	0x0300
-#define PHY_INIT1	0x0f000
-#define PHY_INIT2	0x0e00
-#define PHY_INIT3	0x01000
-#define PHY_INIT4	0x0200
-#define PHY_INIT5	0x0004
-#define PHY_INIT6	0x02000
+#define PHY_CICADA_INIT1	0x0f000
+#define PHY_CICADA_INIT2	0x0e00
+#define PHY_CICADA_INIT3	0x01000
+#define PHY_CICADA_INIT4	0x0200
+#define PHY_CICADA_INIT5	0x0004
+#define PHY_CICADA_INIT6	0x02000
+#define PHY_VITESSE_INIT_REG1	0x1f
+#define PHY_VITESSE_INIT_REG2	0x10
+#define PHY_VITESSE_INIT_REG3	0x11
+#define PHY_VITESSE_INIT_REG4	0x12
+#define PHY_VITESSE_INIT_MSK1	0xc
+#define PHY_VITESSE_INIT_MSK2	0x0180
+#define PHY_VITESSE_INIT1	0x52b5
+#define PHY_VITESSE_INIT2	0xaf8a
+#define PHY_VITESSE_INIT3	0x8
+#define PHY_VITESSE_INIT4	0x8f8a
+#define PHY_VITESSE_INIT5	0xaf86
+#define PHY_VITESSE_INIT6	0x8f86
+#define PHY_VITESSE_INIT7	0xaf82
+#define PHY_VITESSE_INIT8	0x0100
+#define PHY_VITESSE_INIT9	0x8f82
+#define PHY_VITESSE_INIT10	0x0
+
 #define PHY_GIGABIT	0x0100
 
 #define PHY_TIMEOUT	0x1
@@ -1141,14 +1159,14 @@
 	/* phy vendor specific configuration */
 	if ((np->phy_oui == PHY_OUI_CICADA) && (phyinterface & PHY_RGMII) ) {
 		phy_reserved = mii_rw(dev, np->phyaddr, MII_RESV1, MII_READ);
-		phy_reserved &= ~(PHY_INIT1 | PHY_INIT2);
-		phy_reserved |= (PHY_INIT3 | PHY_INIT4);
+		phy_reserved &= ~(PHY_CICADA_INIT1 | PHY_CICADA_INIT2);
+		phy_reserved |= (PHY_CICADA_INIT3 | PHY_CICADA_INIT4);
 		if (mii_rw(dev, np->phyaddr, MII_RESV1, phy_reserved)) {
 			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, MII_NCONFIG, MII_READ);
-		phy_reserved |= PHY_INIT5;
+		phy_reserved |= PHY_CICADA_INIT5;
 		if (mii_rw(dev, np->phyaddr, MII_NCONFIG, phy_reserved)) {
 			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
@@ -1156,12 +1174,82 @@
 	}
 	if (np->phy_oui == PHY_OUI_CICADA) {
 		phy_reserved = mii_rw(dev, np->phyaddr, MII_SREVISION, MII_READ);
-		phy_reserved |= PHY_INIT6;
+		phy_reserved |= PHY_CICADA_INIT6;
 		if (mii_rw(dev, np->phyaddr, MII_SREVISION, phy_reserved)) {
 			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	}
+	if (np->phy_oui == PHY_OUI_VITESSE) {
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG1, PHY_VITESSE_INIT1)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT2)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, MII_READ);
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, MII_READ);
+		phy_reserved &= ~PHY_VITESSE_INIT_MSK1;
+		phy_reserved |= PHY_VITESSE_INIT3;
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT4)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT5)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, MII_READ);
+		phy_reserved &= ~PHY_VITESSE_INIT_MSK1;
+		phy_reserved |= PHY_VITESSE_INIT3;
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, MII_READ);
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT6)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT7)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, MII_READ);
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, MII_READ);
+		phy_reserved &= ~PHY_VITESSE_INIT_MSK2;
+		phy_reserved |= PHY_VITESSE_INIT8;
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT9)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG1, PHY_VITESSE_INIT10)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+	}
 	/* some phys clear out pause advertisment on reset, set it back */
 	mii_rw(dev, np->phyaddr, MII_ADVERTISE, reg);
 

--------------070402090800060803060900--
