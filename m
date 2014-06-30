From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 11/11] tlan: Isolate external PHY when using internal PHY
Date: Mon, 30 Jun 2014 18:38:37 +0200
Message-ID: <1404146317-3094-12-git-send-email-linux@rainbow-software.org>
References: <1404146317-3094-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404146317-3094-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using internal 10 Mbps PHY, isolate the external PHY from MII bus.
External PHY must be kept powered up because it passes TX from tlan chip to
network.

This fixes weird link-loss problems under load with OC-2326 card at 10 Mbps.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/ti/tlan.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index dbded9f..a13c25a 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -2529,9 +2529,10 @@ static void tlan_phy_power_down(struct net_device *dev)
 	value = MII_GC_PDOWN | MII_GC_LOOPBK | MII_GC_ISOLATE;
 	tlan_mii_sync(dev->base_addr);
 	tlan_mii_write_reg(dev, priv->phy[priv->phy_num], MII_GEN_CTL, value);
-	if ((priv->phy_num == 0) &&
-	    (priv->phy[1] != TLAN_PHY_NONE) &&
-	    (!(priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10))) {
+	if ((priv->phy_num == 0) && (priv->phy[1] != TLAN_PHY_NONE)) {
+		/* if using internal PHY, the external PHY must be powered on */
+		if (priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10)
+			value = MII_GC_ISOLATE; /* just isolate it from MII */
 		tlan_mii_sync(dev->base_addr);
 		tlan_mii_write_reg(dev, priv->phy[1], MII_GEN_CTL, value);
 	}
-- 
Ondrej Zary
