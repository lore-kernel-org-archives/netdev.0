From: Karol Herbst <git@karolherbst.de>
Subject: [PATCH 1/2] net/forcedeth: refactor wol support to make it easier to add more wol modes
Date: Thu, 10 Mar 2016 15:58:03 +0100
Message-ID: <1457621884-2479-2-git-send-email-git@karolherbst.de>
References: <1457621884-2479-1-git-send-email-git@karolherbst.de>
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.udag.de ([62.146.106.18]:43596 "EHLO smtp02.udag.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752044AbcCJPDn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 10:03:43 -0500
In-Reply-To: <1457621884-2479-1-git-send-email-git@karolherbst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Karol Herbst <git@karolherbst.de>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 75e88f4..bdce33b 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -290,7 +290,7 @@ enum {
 #define NVREG_WAKEUPFLAGS_ACCEPT_MAGPAT		0x01
 #define NVREG_WAKEUPFLAGS_ACCEPT_WAKEUPPAT	0x02
 #define NVREG_WAKEUPFLAGS_ACCEPT_LINKCHANGE	0x04
-#define NVREG_WAKEUPFLAGS_ENABLE	0x1111
+#define NVREG_WAKEUPFLAGS_ENABLE_G	0x01111
 
 	NvRegMgmtUnitGetVersion = 0x204,
 #define NVREG_MGMTUNITGETVERSION	0x01
@@ -764,6 +764,7 @@ struct fe_priv {
 	int fixed_mode;
 	int phyaddr;
 	int wolenabled;
+	u32 wol_flags;
 	unsigned int phy_oui;
 	unsigned int phy_model;
 	unsigned int phy_rev;
@@ -4218,8 +4219,9 @@ static void nv_get_wol(struct net_device *dev, struct ethtool_wolinfo *wolinfo)
 	wolinfo->supported = WAKE_MAGIC;
 
 	spin_lock_irq(&np->lock);
-	if (np->wolenabled)
-		wolinfo->wolopts = WAKE_MAGIC;
+	wolinfo->wolopts = 0;
+	if (np->wolenabled & WAKE_MAGIC)
+		wolinfo->wolopts |= WAKE_MAGIC;
 	spin_unlock_irq(&np->lock);
 }
 
@@ -4227,20 +4229,19 @@ static int nv_set_wol(struct net_device *dev, struct ethtool_wolinfo *wolinfo)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-	u32 flags = 0;
 
-	if (wolinfo->wolopts == 0) {
-		np->wolenabled = 0;
-	} else if (wolinfo->wolopts & WAKE_MAGIC) {
-		np->wolenabled = 1;
-		flags = NVREG_WAKEUPFLAGS_ENABLE;
+	np->wolenabled = 0;
+	np->wol_flags = 0;
+	if (wolinfo->wolopts & WAKE_MAGIC) {
+		np->wolenabled |= WAKE_MAGIC;
+		np->wol_flags |= NVREG_WAKEUPFLAGS_ENABLE_G;
 	}
 	if (netif_running(dev)) {
 		spin_lock_irq(&np->lock);
-		writel(flags, base + NvRegWakeUpFlags);
+		writel(np->wol_flags, base + NvRegWakeUpFlags);
 		spin_unlock_irq(&np->lock);
 	}
-	device_set_wakeup_enable(&np->pci_dev->dev, np->wolenabled);
+	device_set_wakeup_enable(&np->pci_dev->dev, np->wolenabled != 0);
 	return 0;
 }
 
@@ -5445,7 +5446,7 @@ static int nv_open(struct net_device *dev)
 	writel(NVREG_MIISPEED_BIT8|NVREG_MIIDELAY, base + NvRegMIISpeed);
 	writel(NVREG_MII_LINKCHANGE, base + NvRegMIIMask);
 	if (np->wolenabled)
-		writel(NVREG_WAKEUPFLAGS_ENABLE , base + NvRegWakeUpFlags);
+		writel(np->wol_flags, base + NvRegWakeUpFlags);
 
 	i = readl(base + NvRegPowerState);
 	if ((i & NVREG_POWERSTATE_POWEREDUP) == 0)
@@ -5833,6 +5834,7 @@ static int nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 	/* disable WOL */
 	writel(0, base + NvRegWakeUpFlags);
 	np->wolenabled = 0;
+	np->wol_flags = 0;
 	device_set_wakeup_enable(&pci_dev->dev, false);
 
 	if (id->driver_data & DEV_HAS_POWER_CNTRL) {
@@ -6175,7 +6177,7 @@ static void nv_shutdown(struct pci_dev *pdev)
 	 * only put the device into D3 if we really go for poweroff.
 	 */
 	if (system_state == SYSTEM_POWER_OFF) {
-		pci_wake_from_d3(pdev, np->wolenabled);
+		pci_wake_from_d3(pdev, np->wolenabled != 0);
 		pci_set_power_state(pdev, PCI_D3hot);
 	}
 }
-- 
2.7.2
