From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 8/9] tlan: Add PHY reset timeout
Date: Tue, 27 May 2014 23:38:46 +0200
Message-ID: <1401226727-5508-9-git-send-email-linux@rainbow-software.org>
References: <1401226727-5508-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.gsystem.sk ([62.176.172.50]:58373 "EHLO ns.gsystem.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752508AbaE0VjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 17:39:04 -0400
In-Reply-To: <1401226727-5508-1-git-send-email-linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a timeout to prevent infinite loop waiting for PHY to reset.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/ti/tlan.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 007c2fe..0612c1a 100644
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
