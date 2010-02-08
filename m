From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] macb: straighten out macb_mii_probe function
Date: Mon, 8 Feb 2010 16:12:08 +0100
Message-ID: <20100208151207.GE2601@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hskinnemoen@atmel.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752499Ab0BHPNT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 10:13:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use "phy_find_first" instead of manual lookup. Also use "phy_connect_direct"
instead of "phy_connect" since we already have phy_device pointer here.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/macb.c |   29 +++++++++--------------------
 1 files changed, 9 insertions(+), 20 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 1d0d4d9..2b92c90 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -189,18 +189,11 @@ static void macb_handle_link_change(struct net_device *dev)
 static int macb_mii_probe(struct net_device *dev)
 {
 	struct macb *bp = netdev_priv(dev);
-	struct phy_device *phydev = NULL;
+	struct phy_device *phydev;
 	struct eth_platform_data *pdata;
-	int phy_addr;
-
-	/* find the first phy */
-	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
-		if (bp->mii_bus->phy_map[phy_addr]) {
-			phydev = bp->mii_bus->phy_map[phy_addr];
-			break;
-		}
-	}
+	int ret;
 
+	phydev = phy_find_first(bp->mii_bus);
 	if (!phydev) {
 		printk (KERN_ERR "%s: no PHY found\n", dev->name);
 		return -1;
@@ -210,17 +203,13 @@ static int macb_mii_probe(struct net_device *dev)
 	/* TODO : add pin_irq */
 
 	/* attach the mac to the phy */
-	if (pdata && pdata->is_rmii) {
-		phydev = phy_connect(dev, dev_name(&phydev->dev),
-			&macb_handle_link_change, 0, PHY_INTERFACE_MODE_RMII);
-	} else {
-		phydev = phy_connect(dev, dev_name(&phydev->dev),
-			&macb_handle_link_change, 0, PHY_INTERFACE_MODE_MII);
-	}
-
-	if (IS_ERR(phydev)) {
+	ret = phy_connect_direct(dev, phydev, &macb_handle_link_change, 0,
+				 pdata && pdata->is_rmii ?
+				 PHY_INTERFACE_MODE_RMII :
+				 PHY_INTERFACE_MODE_MII);
+	if (ret) {
 		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
-		return PTR_ERR(phydev);
+		return ret;
 	}
 
 	/* mask with MAC supported features */
-- 
1.6.6

