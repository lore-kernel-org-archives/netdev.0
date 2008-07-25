From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth bug fix: realtek phy 8211c errata
Date: Fri, 25 Jul 2008 15:31:29 -0400
Message-ID: <488A2A11.4080000@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090503000708000303030600"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:11958 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbYGYWrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 18:47:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090503000708000303030600
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds support for the realtek 8211c phy. The driver must 
perform a hardware reset of the phy due to an errata where the phy could 
not detect the link.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------090503000708000303030600
Content-Type: text/plain;
 name="patch-forcedeth-realtek-phy-reset"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-realtek-phy-reset"

--- old/drivers/net/forcedeth.c	2008-07-25 15:00:46.000000000 -0400
+++ new/drivers/net/forcedeth.c	2008-07-25 15:00:48.000000000 -0400
@@ -337,6 +337,7 @@
 	NvRegPowerState2 = 0x600,
 #define NVREG_POWERSTATE2_POWERUP_MASK		0x0F11
 #define NVREG_POWERSTATE2_POWERUP_REV_A3	0x0001
+#define NVREG_POWERSTATE2_PHY_RESET		0x0004
 };
 
 /* Big endian: should work, but is untested */
@@ -533,6 +534,7 @@
 #define PHY_REALTEK_INIT_REG4	0x14
 #define PHY_REALTEK_INIT_REG5	0x18
 #define PHY_REALTEK_INIT_REG6	0x11
+#define PHY_REALTEK_INIT_REG7	0x01
 #define PHY_REALTEK_INIT1	0x0000
 #define PHY_REALTEK_INIT2	0x8e00
 #define PHY_REALTEK_INIT3	0x0001
@@ -541,6 +543,9 @@
 #define PHY_REALTEK_INIT6	0xf5c7
 #define PHY_REALTEK_INIT7	0x1000
 #define PHY_REALTEK_INIT8	0x0003
+#define PHY_REALTEK_INIT9	0x0008
+#define PHY_REALTEK_INIT10	0x0005
+#define PHY_REALTEK_INIT11	0x0200
 #define PHY_REALTEK_INIT_MSK1	0x0003
 
 #define PHY_GIGABIT	0x0100
@@ -1153,6 +1158,42 @@
 				return PHY_ERROR;
 			}
 		}
+		if (np->phy_model == PHY_MODEL_REALTEK_8211 &&
+		    np->phy_rev == PHY_REV_REALTEK_8211C) {
+			u32 powerstate = readl(base + NvRegPowerState2);
+
+			/* need to perform hw phy reset */
+			powerstate |= NVREG_POWERSTATE2_PHY_RESET;
+			writel(powerstate, base + NvRegPowerState2);
+			msleep(25);
+
+			powerstate &= ~NVREG_POWERSTATE2_PHY_RESET;
+			writel(powerstate, base + NvRegPowerState2);
+			msleep(25);
+
+			reg = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, MII_READ);
+			reg |= PHY_REALTEK_INIT9;
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, reg)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT10)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			reg = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG7, MII_READ);
+			if (!(reg & PHY_REALTEK_INIT11)) {
+				reg |= PHY_REALTEK_INIT11;
+				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG7, reg)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+		}
 		if (np->phy_model == PHY_MODEL_REALTEK_8201) {
 			if (np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_32 ||
 			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_33 ||
@@ -1205,12 +1246,23 @@
 	mii_control = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
 	mii_control |= BMCR_ANENABLE;
 
-	/* reset the phy
-	 * (certain phys need bmcr to be setup with reset)
-	 */
-	if (phy_reset(dev, mii_control)) {
-		printk(KERN_INFO "%s: phy reset failed\n", pci_name(np->pci_dev));
-		return PHY_ERROR;
+	if (np->phy_oui == PHY_OUI_REALTEK &&
+	    np->phy_model == PHY_MODEL_REALTEK_8211 &&
+	    np->phy_rev == PHY_REV_REALTEK_8211C) {
+		/* start autoneg since we already performed hw reset above */
+		mii_control |= BMCR_ANRESTART;
+		if (mii_rw(dev, np->phyaddr, MII_BMCR, mii_control)) {
+			printk(KERN_INFO "%s: phy init failed\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+	} else {
+		/* reset the phy
+		 * (certain phys need bmcr to be setup with reset)
+		 */
+		if (phy_reset(dev, mii_control)) {
+			printk(KERN_INFO "%s: phy reset failed\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
 	}
 
 	/* phy vendor specific configuration */

--------------090503000708000303030600--
