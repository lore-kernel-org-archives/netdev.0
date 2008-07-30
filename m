From: akpm@linux-foundation.org
Subject: [patch for 2.6.27? 1/2] forcedeth bug fix: realtek phy 8211c errata
Date: Wed, 30 Jul 2008 12:50:11 -0700
Message-ID: <200807301950.m6UJoC3N013253@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	aabdulla@nvidia.com, jgarzik@pobox.com, manfred@colorfullife.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52555 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754710AbYG3TwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:52:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>

This patch adds support for the realtek 8211c phy.  The driver must
perform a hardware reset of the phy due to an errata where the phy could
not detect the link.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Cc: Manfred Spraul <manfred@colorfullife.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |   64 ++++++++++++++++++++++++++++++++++----
 1 file changed, 58 insertions(+), 6 deletions(-)

diff -puN drivers/net/forcedeth.c~forcedeth-bug-fix-realtek-phy-8211c-errata drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-bug-fix-realtek-phy-8211c-errata
+++ a/drivers/net/forcedeth.c
@@ -333,6 +333,7 @@ enum {
 	NvRegPowerState2 = 0x600,
 #define NVREG_POWERSTATE2_POWERUP_MASK		0x0F11
 #define NVREG_POWERSTATE2_POWERUP_REV_A3	0x0001
+#define NVREG_POWERSTATE2_PHY_RESET		0x0004
 };
 
 /* Big endian: should work, but is untested */
@@ -529,6 +530,7 @@ union ring_type {
 #define PHY_REALTEK_INIT_REG4	0x14
 #define PHY_REALTEK_INIT_REG5	0x18
 #define PHY_REALTEK_INIT_REG6	0x11
+#define PHY_REALTEK_INIT_REG7	0x01
 #define PHY_REALTEK_INIT1	0x0000
 #define PHY_REALTEK_INIT2	0x8e00
 #define PHY_REALTEK_INIT3	0x0001
@@ -537,6 +539,9 @@ union ring_type {
 #define PHY_REALTEK_INIT6	0xf5c7
 #define PHY_REALTEK_INIT7	0x1000
 #define PHY_REALTEK_INIT8	0x0003
+#define PHY_REALTEK_INIT9	0x0008
+#define PHY_REALTEK_INIT10	0x0005
+#define PHY_REALTEK_INIT11	0x0200
 #define PHY_REALTEK_INIT_MSK1	0x0003
 
 #define PHY_GIGABIT	0x0100
@@ -1149,6 +1154,42 @@ static int phy_init(struct net_device *d
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
@@ -1201,12 +1242,23 @@ static int phy_init(struct net_device *d
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
_
