From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/11] forcedeth: Add function init_realtek_8211b
Date: Mon, 29 Nov 2010 09:41:58 -0800
Message-ID: <c66fcbd5111052cc1051ce5212f728aa47010c68.1291051316.git.joe@perches.com>
References: <cover.1291051316.git.joe@perches.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Szymon Janc <szymon@janc.net.pl>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirqus@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1959 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755410Ab0K2RmM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 12:42:12 -0500
In-Reply-To: <cover.1291051316.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Deduplicate the code use for the init/reset of this device.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/forcedeth.c |  105 ++++++++++++++--------------------------------
 1 files changed, 32 insertions(+), 73 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index c3a9783..300748c 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1181,6 +1181,33 @@ static int phy_reset(struct net_device *dev, u32 bmcr_setup)
 	return 0;
 }
 
+static int init_realtek_8211b(struct net_device *dev, struct fe_priv *np)
+{
+	static const struct {
+		int reg;
+		int init;
+	} ri[] = {
+		{ PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1 },
+		{ PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT2 },
+		{ PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3 },
+		{ PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT4 },
+		{ PHY_REALTEK_INIT_REG4, PHY_REALTEK_INIT5 },
+		{ PHY_REALTEK_INIT_REG5, PHY_REALTEK_INIT6 },
+		{ PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1 },
+	};
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(ri); i++) {
+		if (mii_rw(dev, np->phyaddr, ri[i].reg, ri[i].init)) {
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+	}
+
+	return 0;
+}
+
 static int phy_init(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
@@ -1200,44 +1227,10 @@ static int phy_init(struct net_device *dev)
 	if (np->phy_oui == PHY_OUI_REALTEK) {
 		if (np->phy_model == PHY_MODEL_REALTEK_8211 &&
 		    np->phy_rev == PHY_REV_REALTEK_8211B) {
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-				netdev_info(dev, "%s: phy init failed\n",
-					    pci_name(np->pci_dev));
-				return PHY_ERROR;
-			}
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT2)) {
-				netdev_info(dev, "%s: phy init failed\n",
-					    pci_name(np->pci_dev));
-				return PHY_ERROR;
-			}
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
-				netdev_info(dev, "%s: phy init failed\n",
-					    pci_name(np->pci_dev));
-				return PHY_ERROR;
-			}
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT4)) {
-				netdev_info(dev, "%s: phy init failed\n",
-					    pci_name(np->pci_dev));
-				return PHY_ERROR;
-			}
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG4, PHY_REALTEK_INIT5)) {
-				netdev_info(dev, "%s: phy init failed\n",
-					    pci_name(np->pci_dev));
-				return PHY_ERROR;
-			}
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG5, PHY_REALTEK_INIT6)) {
-				netdev_info(dev, "%s: phy init failed\n",
-					    pci_name(np->pci_dev));
-				return PHY_ERROR;
-			}
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-				netdev_info(dev, "%s: phy init failed\n",
-					    pci_name(np->pci_dev));
+			if (init_realtek_8211b(dev, np))
 				return PHY_ERROR;
-			}
-		}
-		if (np->phy_model == PHY_MODEL_REALTEK_8211 &&
-		    np->phy_rev == PHY_REV_REALTEK_8211C) {
+		} else if (np->phy_model == PHY_MODEL_REALTEK_8211 &&
+			   np->phy_rev == PHY_REV_REALTEK_8211C) {
 			u32 powerstate = readl(base + NvRegPowerState2);
 
 			/* need to perform hw phy reset */
@@ -1459,43 +1452,9 @@ static int phy_init(struct net_device *dev)
 		if (np->phy_model == PHY_MODEL_REALTEK_8211 &&
 		    np->phy_rev == PHY_REV_REALTEK_8211B) {
 			/* reset could have cleared these out, set them back */
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-				netdev_info(dev, "%s: phy init failed\n",
-					    pci_name(np->pci_dev));
+			if (init_realtek_8211b(dev, np))
 				return PHY_ERROR;
-			}
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT2)) {
-				netdev_info(dev, "%s: phy init failed\n",
-					    pci_name(np->pci_dev));
-				return PHY_ERROR;
-			}
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
-				netdev_info(dev, "%s: phy init failed\n",
-					    pci_name(np->pci_dev));
-				return PHY_ERROR;
-			}
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT4)) {
-				netdev_info(dev, "%s: phy init failed\n",
-					    pci_name(np->pci_dev));
-				return PHY_ERROR;
-			}
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG4, PHY_REALTEK_INIT5)) {
-				netdev_info(dev, "%s: phy init failed\n",
-					    pci_name(np->pci_dev));
-				return PHY_ERROR;
-			}
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG5, PHY_REALTEK_INIT6)) {
-				netdev_info(dev, "%s: phy init failed\n",
-					    pci_name(np->pci_dev));
-				return PHY_ERROR;
-			}
-			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-				netdev_info(dev, "%s: phy init failed\n",
-					    pci_name(np->pci_dev));
-				return PHY_ERROR;
-			}
-		}
-		if (np->phy_model == PHY_MODEL_REALTEK_8201) {
+		} else if (np->phy_model == PHY_MODEL_REALTEK_8201) {
 			if (np->driver_data & DEV_NEED_PHY_INIT_FIX) {
 				phy_reserved = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, MII_READ);
 				phy_reserved |= PHY_REALTEK_INIT7;
-- 
1.7.3.2.245.g03276.dirty

