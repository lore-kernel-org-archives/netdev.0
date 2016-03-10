From: Karol Herbst <git@karolherbst.de>
Subject: [PATCH 2/2] net/forcedeth: add wol p support
Date: Thu, 10 Mar 2016 15:58:04 +0100
Message-ID: <1457621884-2479-3-git-send-email-git@karolherbst.de>
References: <1457621884-2479-1-git-send-email-git@karolherbst.de>
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Karol Herbst <nouveau@karolherbst.de>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.udag.de ([62.146.106.18]:43619 "EHLO smtp02.udag.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752208AbcCJPDn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 10:03:43 -0500
In-Reply-To: <1457621884-2479-1-git-send-email-git@karolherbst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

REd on my mac mini. No idea if that also works on other ethernet cards
supported by forcedeth, but I doubt anybody cares at all, otherwise somebody
else would have REd it already.

Signed-off-by: Karol Herbst <nouveau@karolherbst.de>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index bdce33b..8e4e894 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -291,6 +291,7 @@ enum {
 #define NVREG_WAKEUPFLAGS_ACCEPT_WAKEUPPAT	0x02
 #define NVREG_WAKEUPFLAGS_ACCEPT_LINKCHANGE	0x04
 #define NVREG_WAKEUPFLAGS_ENABLE_G	0x01111
+#define NVREG_WAKEUPFLAGS_ENABLE_P	0x12000
 
 	NvRegMgmtUnitGetVersion = 0x204,
 #define NVREG_MGMTUNITGETVERSION	0x01
@@ -4216,12 +4217,14 @@ static void nv_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 static void nv_get_wol(struct net_device *dev, struct ethtool_wolinfo *wolinfo)
 {
 	struct fe_priv *np = netdev_priv(dev);
-	wolinfo->supported = WAKE_MAGIC;
+	wolinfo->supported = WAKE_MAGIC | WAKE_PHY;
 
 	spin_lock_irq(&np->lock);
 	wolinfo->wolopts = 0;
 	if (np->wolenabled & WAKE_MAGIC)
 		wolinfo->wolopts |= WAKE_MAGIC;
+	if (np->wolenabled & WAKE_PHY)
+		wolinfo->wolopts |= WAKE_PHY;
 	spin_unlock_irq(&np->lock);
 }
 
@@ -4236,6 +4239,10 @@ static int nv_set_wol(struct net_device *dev, struct ethtool_wolinfo *wolinfo)
 		np->wolenabled |= WAKE_MAGIC;
 		np->wol_flags |= NVREG_WAKEUPFLAGS_ENABLE_G;
 	}
+	if (wolinfo->wolopts & WAKE_PHY) {
+		np->wolenabled |= WAKE_PHY;
+		np->wol_flags |= NVREG_WAKEUPFLAGS_ENABLE_P;
+	}
 	if (netif_running(dev)) {
 		spin_lock_irq(&np->lock);
 		writel(np->wol_flags, base + NvRegWakeUpFlags);
-- 
2.7.2
