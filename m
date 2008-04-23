From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth: realtek phy crossover detection
Date: Wed, 23 Apr 2008 14:37:30 -0400
Message-ID: <480F81EA.1050005@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080300050401040603000807"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:14841 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812AbYDWViY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 17:38:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080300050401040603000807
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes an issue seen with the realtek 8201 phy. This phy has a 
problem with crossover detection and it needs to be disabled. The 
problem only arises on certain switches. Therefore, a module parameter 
has been added to allow enabling crossover detection if needed. The 
default will be set to disabled.


Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------080300050401040603000807
Content-Type: text/plain;
 name="patch-forcedeth-realtek"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-realtek"

--- old/drivers/net/forcedeth.c	2008-04-09 19:33:19.000000000 -0400
+++ new/drivers/net/forcedeth.c	2008-04-23 14:34:09.000000000 -0400
@@ -572,16 +572,22 @@
 #define DESC_VER_3	3
 
 /* PHY defines */
-#define PHY_OUI_MARVELL	0x5043
-#define PHY_OUI_CICADA	0x03f1
-#define PHY_OUI_VITESSE	0x01c1
-#define PHY_OUI_REALTEK	0x0732
+#define PHY_OUI_MARVELL		0x5043
+#define PHY_OUI_CICADA		0x03f1
+#define PHY_OUI_VITESSE		0x01c1
+#define PHY_OUI_REALTEK		0x0732
+#define PHY_OUI_REALTEK2	0x0020
 #define PHYID1_OUI_MASK	0x03ff
 #define PHYID1_OUI_SHFT	6
 #define PHYID2_OUI_MASK	0xfc00
 #define PHYID2_OUI_SHFT	10
 #define PHYID2_MODEL_MASK		0x03f0
-#define PHY_MODEL_MARVELL_E3016		0x220
+#define PHY_MODEL_REALTEK_8211		0x0110
+#define PHY_REV_MASK			0x0001
+#define PHY_REV_REALTEK_8211B		0x0000
+#define PHY_REV_REALTEK_8211C		0x0001
+#define PHY_MODEL_REALTEK_8201		0x0200
+#define PHY_MODEL_MARVELL_E3016		0x0220
 #define PHY_MARVELL_E3016_INITMASK	0x0300
 #define PHY_CICADA_INIT1	0x0f000
 #define PHY_CICADA_INIT2	0x0e00
@@ -608,10 +614,18 @@
 #define PHY_REALTEK_INIT_REG1	0x1f
 #define PHY_REALTEK_INIT_REG2	0x19
 #define PHY_REALTEK_INIT_REG3	0x13
+#define PHY_REALTEK_INIT_REG4	0x14
+#define PHY_REALTEK_INIT_REG5	0x18
+#define PHY_REALTEK_INIT_REG6	0x11
 #define PHY_REALTEK_INIT1	0x0000
 #define PHY_REALTEK_INIT2	0x8e00
 #define PHY_REALTEK_INIT3	0x0001
 #define PHY_REALTEK_INIT4	0xad17
+#define PHY_REALTEK_INIT5	0xfb54
+#define PHY_REALTEK_INIT6	0xf5c7
+#define PHY_REALTEK_INIT7	0x1000
+#define PHY_REALTEK_INIT8	0x0003
+#define PHY_REALTEK_INIT_MSK1	0x0003
 
 #define PHY_GIGABIT	0x0100
 
@@ -790,6 +804,7 @@
 	int wolenabled;
 	unsigned int phy_oui;
 	unsigned int phy_model;
+	unsigned int phy_rev;
 	u16 gigabit;
 	int intr_test;
 	int recover_error;
@@ -803,6 +818,7 @@
 	u32 txrxctl_bits;
 	u32 vlanctl_bits;
 	u32 driver_data;
+	u32 device_id;
 	u32 register_size;
 	int rx_csum;
 	u32 mac_in_use;
@@ -913,6 +929,16 @@
 };
 static int dma_64bit = NV_DMA_64BIT_ENABLED;
 
+/*
+ * Crossover Detection
+ * Realtek 8201 phy + some OEM boards do not work properly.
+ */
+enum {
+	NV_CROSSOVER_DETECTION_DISABLED,
+	NV_CROSSOVER_DETECTION_ENABLED
+};
+static int phy_cross = NV_CROSSOVER_DETECTION_DISABLED;
+
 static inline struct fe_priv *get_nvpriv(struct net_device *dev)
 {
 	return netdev_priv(dev);
@@ -1170,25 +1196,53 @@
 		}
 	}
 	if (np->phy_oui == PHY_OUI_REALTEK) {
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT2)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT4)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
+		if (np->phy_model == PHY_MODEL_REALTEK_8211 &&
+		    np->phy_rev == PHY_REV_REALTEK_8211B) {
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT2)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT4)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG4, PHY_REALTEK_INIT5)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG5, PHY_REALTEK_INIT6)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
 		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
+		if (np->phy_model == PHY_MODEL_REALTEK_8201) {
+			if (np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_32 ||
+			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_33 ||
+			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_34 ||
+			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_35 ||
+			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_36 ||
+			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_37 ||
+			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_38 ||
+			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_39) {
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, MII_READ);
+				phy_reserved |= PHY_REALTEK_INIT7;
+				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+			}
 		}
 	}
 
@@ -1328,26 +1382,71 @@
 		}
 	}
 	if (np->phy_oui == PHY_OUI_REALTEK) {
-		/* reset could have cleared these out, set them back */
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT2)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT4)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
+		if (np->phy_model == PHY_MODEL_REALTEK_8211 &&
+		    np->phy_rev == PHY_REV_REALTEK_8211B) {
+			/* reset could have cleared these out, set them back */
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT2)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT4)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG4, PHY_REALTEK_INIT5)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG5, PHY_REALTEK_INIT6)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
 		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
+		if (np->phy_model == PHY_MODEL_REALTEK_8201) {
+			if (np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_32 ||
+			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_33 ||
+			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_34 ||
+			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_35 ||
+			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_36 ||
+			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_37 ||
+			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_38 ||
+			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_39) {
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, MII_READ);
+				phy_reserved |= PHY_REALTEK_INIT7;
+				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+			}
+			if (phy_cross == NV_CROSSOVER_DETECTION_DISABLED) {
+				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, MII_READ);
+				phy_reserved &= ~PHY_REALTEK_INIT_MSK1;
+				phy_reserved |= PHY_REALTEK_INIT3;
+				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+			}
 		}
 	}
 
@@ -5339,6 +5438,8 @@
 
 	/* copy of driver data */
 	np->driver_data = id->driver_data;
+	/* copy of device id */
+	np->device_id = id->device;
 
 	/* handle different descriptor versions */
 	if (id->driver_data & DEV_HAS_HIGH_DMA) {
@@ -5612,6 +5713,14 @@
 			pci_name(pci_dev), id1, id2, phyaddr);
 		np->phyaddr = phyaddr;
 		np->phy_oui = id1 | id2;
+
+		/* Realtek hardcoded phy id1 to all zero's on certain phys */
+		if (np->phy_oui == PHY_OUI_REALTEK2)
+			np->phy_oui = PHY_OUI_REALTEK;
+		/* Setup phy revision for Realtek */
+		if (np->phy_oui == PHY_OUI_REALTEK && np->phy_model == PHY_MODEL_REALTEK_8211)
+			np->phy_rev = mii_rw(dev, phyaddr, MII_RESV1, MII_READ) & PHY_REV_MASK;
+
 		break;
 	}
 	if (i == 33) {
@@ -5690,6 +5799,28 @@
 	return err;
 }
 
+static void nv_restore_phy(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	u16 phy_reserved, mii_control;
+
+	if (np->phy_oui == PHY_OUI_REALTEK &&
+	    np->phy_model == PHY_MODEL_REALTEK_8201 &&
+	    phy_cross == NV_CROSSOVER_DETECTION_DISABLED) {
+		mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3);
+		phy_reserved = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, MII_READ);
+		phy_reserved &= ~PHY_REALTEK_INIT_MSK1;
+		phy_reserved |= PHY_REALTEK_INIT8;
+		mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, phy_reserved);
+		mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1);
+
+		/* restart auto negotiation */
+		mii_control = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
+		mii_control |= (BMCR_ANRESTART | BMCR_ANENABLE);
+		mii_rw(dev, np->phyaddr, MII_BMCR, mii_control);
+	}
+}
+
 static void __devexit nv_remove(struct pci_dev *pci_dev)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
@@ -5706,6 +5837,9 @@
 	writel(readl(base + NvRegTransmitPoll) & ~NVREG_TRANSMITPOLL_MAC_ADDR_REV,
 	       base + NvRegTransmitPoll);
 
+	/* restore any phy related changes */
+	nv_restore_phy(dev);
+
 	/* free all structures */
 	free_rings(dev);
 	iounmap(get_hwbase(dev));
@@ -5950,6 +6084,8 @@
 MODULE_PARM_DESC(msix, "MSIX interrupts are enabled by setting to 1 and disabled by setting to 0.");
 module_param(dma_64bit, int, 0);
 MODULE_PARM_DESC(dma_64bit, "High DMA is enabled by setting to 1 and disabled by setting to 0.");
+module_param(phy_cross, int, 0);
+MODULE_PARM_DESC(phy_cross, "Phy crossover detection for Realtek 8201 phy is enabled by setting to 1 and disabled by setting to 0.");
 
 MODULE_AUTHOR("Manfred Spraul <manfred@colorfullife.com>");
 MODULE_DESCRIPTION("Reverse Engineered nForce ethernet driver");

--------------080300050401040603000807--
