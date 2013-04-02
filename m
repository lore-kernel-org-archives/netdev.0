From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 2/5] net/cadence/at91_ether: Simplify OF dependencies
Date: Tue,  2 Apr 2013 12:35:08 -0700
Message-ID: <1364931311-30603-3-git-send-email-linux@roeck-us.net>
References: <1364931311-30603-1-git-send-email-linux@roeck-us.net>
Cc: Rob Herring <rob.herring@calxeda.com>,
	David Daney <david.daney@cavium.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Guenter Roeck <linux@roeck-us.net>
To: "David S. Miller" <davem@davemloft.net>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364931311-30603-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With of_get_mac_address() and of_get_phy_mode() now defined as dummy
functions if OF_NET is not configured, it is no longer necessary to
provide OF dependent functions as front-end. Also, the two functions
depend on OF_NET, not on OF, so the conditional code was not correct
anyway.

Drop the front-end functions and call of_get_mac_address() and
of_get_phy_mode() directly instead.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/ethernet/cadence/at91_ether.c |   44 ++++-------------------------
 1 file changed, 6 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 3becdb2..50565cb 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -303,42 +303,7 @@ static const struct of_device_id at91ether_dt_ids[] = {
 	{ .compatible = "cdns,emac" },
 	{ /* sentinel */ }
 };
-
 MODULE_DEVICE_TABLE(of, at91ether_dt_ids);
-
-static int at91ether_get_phy_mode_dt(struct platform_device *pdev)
-{
-	struct device_node *np = pdev->dev.of_node;
-
-	if (np)
-		return of_get_phy_mode(np);
-
-	return -ENODEV;
-}
-
-static int at91ether_get_hwaddr_dt(struct macb *bp)
-{
-	struct device_node *np = bp->pdev->dev.of_node;
-
-	if (np) {
-		const char *mac = of_get_mac_address(np);
-		if (mac) {
-			memcpy(bp->dev->dev_addr, mac, ETH_ALEN);
-			return 0;
-		}
-	}
-
-	return -ENODEV;
-}
-#else
-static int at91ether_get_phy_mode_dt(struct platform_device *pdev)
-{
-	return -ENODEV;
-}
-static int at91ether_get_hwaddr_dt(struct macb *bp)
-{
-	return -ENODEV;
-}
 #endif
 
 /* Detect MAC & PHY and perform ethernet interface initialization */
@@ -352,6 +317,7 @@ static int __init at91ether_probe(struct platform_device *pdev)
 	struct macb *lp;
 	int res;
 	u32 reg;
+	const char *mac;
 
 	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!regs)
@@ -403,11 +369,13 @@ static int __init at91ether_probe(struct platform_device *pdev)
 	platform_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	res = at91ether_get_hwaddr_dt(lp);
-	if (res < 0)
+	mac = of_get_mac_address(pdev->dev.of_node);
+	if (mac)
+		memcpy(lp->dev->dev_addr, mac, ETH_ALEN);
+	else
 		macb_get_hwaddr(lp);
 
-	res = at91ether_get_phy_mode_dt(pdev);
+	res = of_get_phy_mode(pdev->dev.of_node);
 	if (res < 0) {
 		if (board_data && board_data->is_rmii)
 			lp->phy_interface = PHY_INTERFACE_MODE_RMII;
-- 
1.7.9.7
