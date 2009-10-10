From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH 1/3] drivers/net/forcedeth.c: Update erratas for Marvell PHYs
Date: Sat, 10 Oct 2009 17:58:12 +0200
Message-ID: <1255190294-4121-2-git-send-email-manfred@colorfullife.com>
References: <1255190294-4121-1-git-send-email-manfred@colorfullife.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Manfred Spraul <manfred@colorfullife.com>
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:64723 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761890AbZJJP6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 11:58:33 -0400
Received: by bwz6 with SMTP id 6so2235076bwz.37
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2009 08:57:55 -0700 (PDT)
In-Reply-To: <1255190294-4121-1-git-send-email-manfred@colorfullife.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates/adds erratas for the Marvell 88E3016, 88E1111 and 88E1116
PHYs.
The changes were originally written by Ayaz Abdulla, I merely added
meaningful names for the registers, based on the documentation
for Marvell 88E3016 (publicly available on datasheetdir) and existing linux
drivers.

Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
---
 drivers/net/forcedeth.c |   74 +++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 68 insertions(+), 6 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 0a1c2bb..0e48e25 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -506,6 +506,7 @@ union ring_type {
 #define PHY_OUI_VITESSE		0x01c1
 #define PHY_OUI_REALTEK		0x0732
 #define PHY_OUI_REALTEK2	0x0020
+#define PHY_OUI_BROADCOM	0x50ef
 #define PHYID1_OUI_MASK	0x03ff
 #define PHYID1_OUI_SHFT	6
 #define PHYID2_OUI_MASK	0xfc00
@@ -517,7 +518,12 @@ union ring_type {
 #define PHY_REV_REALTEK_8211C		0x0001
 #define PHY_MODEL_REALTEK_8201		0x0200
 #define PHY_MODEL_MARVELL_E3016		0x0220
-#define PHY_MARVELL_E3016_INITMASK	0x0300
+#define PHY_MODEL_MARVELL_E1116		0x0210
+#define PHY_MODEL_MARVELL_E1111		0x00c0
+#define PHY_MODEL_MARVELL_E1011		0x00b0
+#define PHY_MODEL_BROADCOM_9507		0x00a0
+#define PHY_MODEL_BROADCOM_AC131	0x0070
+#define PHY_MODEL_BROADCOM_50610	0x0160
 #define PHY_CICADA_INIT1	0x0f000
 #define PHY_CICADA_INIT2	0x0e00
 #define PHY_CICADA_INIT3	0x01000
@@ -560,6 +566,26 @@ union ring_type {
 #define PHY_REALTEK_INIT11	0x0200
 #define PHY_REALTEK_INIT_MSK1	0x0003
 
+
+/* Marvell 88E3016. Based on the datasheet MV-S103164-00. */
+#define PHY_MV_E3016_REG_PHY_CTRL	0x0010
+#define PHY_MV_E3016_REG_PHY_CTRL2	0x001c
+
+/* Disable Normal Linkpulse Check. Necessary to fix an errata. */
+#define PHY_MV_E3016_REG_PHY_CTRL_DIS_NLP	0x4000
+/* These bits are reserved and must be zero. */
+#define PHY_MV_E3016_REG_PHY_CTRL2_CLEAR	0x0300
+
+/* Marvell 88E1111. Based on mv88e1xxx.h (sklin driver) */
+#define PHY_MV_E1XXX_REG_PHY_CTRL	0x0010
+#define PHY_MV_E1XXX_REG_RES		0x0016
+
+/* Clear low byte of RES register */
+#define PHY_MV_E1XXX_REG_RES_MASK	0x00ff
+
+/* set 2 bits (function unknown) */
+#define PHY_MV_E1XXX_REG_PHY_CTRL_SET	0x0300
+
 #define PHY_GIGABIT	0x0100
 
 #define PHY_TIMEOUT	0x1
@@ -1198,11 +1224,11 @@ static int phy_init(struct net_device *dev)
 	u8 __iomem *base = get_hwbase(dev);
 	u32 phyinterface, phy_reserved, mii_status, mii_control, mii_control_1000,reg;
 
-	/* phy errata for E3016 phy */
-	if (np->phy_model == PHY_MODEL_MARVELL_E3016) {
-		reg = mii_rw(dev, np->phyaddr, MII_NCONFIG, MII_READ);
-		reg &= ~PHY_MARVELL_E3016_INITMASK;
-		if (mii_rw(dev, np->phyaddr, MII_NCONFIG, reg)) {
+	if (np->phy_oui == PHY_OUI_MARVELL && np->phy_model == PHY_MODEL_MARVELL_E3016) {
+		/* phy errata for E3016 phy */
+		reg = mii_rw(dev, np->phyaddr, PHY_MV_E3016_REG_PHY_CTRL2, MII_READ);
+		reg &= ~PHY_MV_E3016_REG_PHY_CTRL2_CLEAR;
+		if (mii_rw(dev, np->phyaddr, PHY_MV_E3016_REG_PHY_CTRL2, reg)) {
 			printk(KERN_INFO "%s: phy write to errata reg failed.\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
@@ -1340,6 +1366,42 @@ static int phy_init(struct net_device *dev)
 	}
 
 	/* phy vendor specific configuration */
+	if (np->phy_oui == PHY_OUI_MARVELL) {
+		if (np->driver_data & DEV_NEED_PHY_INIT_FIX) {
+			if (np->phy_model == PHY_MODEL_MARVELL_E1116) {
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_MV_E1XXX_REG_RES, MII_READ);
+				phy_reserved &= ~PHY_MV_E1XXX_REG_RES_MASK;
+				if (mii_rw(dev, np->phyaddr, PHY_MV_E1XXX_REG_RES,phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_MV_E1XXX_REG_PHY_CTRL, MII_READ);
+				phy_reserved |= PHY_MV_E1XXX_REG_PHY_CTRL_SET;
+				if (mii_rw(dev, np->phyaddr, PHY_MV_E1XXX_REG_PHY_CTRL,phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+			}
+			if (np->phy_model == PHY_MODEL_MARVELL_E1111) {
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_MV_E1XXX_REG_PHY_CTRL, MII_READ);
+				phy_reserved |= PHY_MV_E1XXX_REG_PHY_CTRL_SET;
+				if (mii_rw(dev, np->phyaddr, PHY_MV_E1XXX_REG_PHY_CTRL,phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+			}
+			if (np->phy_model == PHY_MODEL_MARVELL_E3016) {
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_MV_E3016_REG_PHY_CTRL, MII_READ);
+				phy_reserved |= PHY_MV_E3016_REG_PHY_CTRL_DIS_NLP;
+				if (mii_rw(dev, np->phyaddr, PHY_MV_E3016_REG_PHY_CTRL,phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+			}
+		}
+	}
+
 	if ((np->phy_oui == PHY_OUI_CICADA) && (phyinterface & PHY_RGMII) ) {
 		phy_reserved = mii_rw(dev, np->phyaddr, MII_RESV1, MII_READ);
 		phy_reserved &= ~(PHY_CICADA_INIT1 | PHY_CICADA_INIT2);
-- 
1.6.2.5

