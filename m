From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 08/11] tlan: Add PHY reset timeout
Date: Sat, 21 Jun 2014 16:47:53 +0200
Message-ID: <1403362076-7777-9-git-send-email-linux@rainbow-software.org>
References: <1403362076-7777-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403362076-7777-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a timeout to prevent infinite loop waiting for PHY to reset.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/ti/tlan.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index b4e9dcf..f5af196 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -2569,6 +2569,7 @@ static void tlan_phy_reset(struct net_device *dev)
 	struct tlan_priv	*priv = netdev_priv(dev);
 	u16		phy;
 	u16		value;
+	unsigned long timeout = jiffies + HZ;
 
 	phy = priv->phy[priv->phy_num];
 
@@ -2576,9 +2577,13 @@ static void tlan_phy_reset(struct net_device *dev)
 	tlan_mii_sync(dev->base_addr);
 	value = MII_GC_LOOPBK | MII_GC_RESET;
 	tlan_mii_write_reg(dev, phy, MII_GEN_CTL, value);
-	tlan_mii_read_reg(dev, phy, MII_GEN_CTL, &value);
-	while (value & MII_GC_RESET)
+	do {
 		tlan_mii_read_reg(dev, phy, MII_GEN_CTL, &value);
+		if (time_after(jiffies, timeout)) {
+			netdev_err(dev, "PHY reset timeout\n");
+			return;
+		}
+	} while (value & MII_GC_RESET);
 
 	/* Wait for 500 ms and initialize.
 	 * I don't remember why I wait this long.
-- 
Ondrej Zary
