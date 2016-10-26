From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: [PATCH] net: mv643xx_eth: Fetch the phy connection type from DT
Date: Wed, 26 Oct 2016 11:47:02 -0600
Message-ID: <20161026174702.GB24717@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:60704 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932334AbcJZRrF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Oct 2016 13:47:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MAC is capable of RGMII mode and that is probably a more typical
connection type than GMII today (eg it is used by Marvell Reference
designs for several SOCs). Let DT users specify the standard

   phy-connection-type = "rgmii-id";

On a phy node.

Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
---
 .../devicetree/bindings/net/marvell-orion-net.txt  |  1 +
 drivers/net/ethernet/marvell/mv643xx_eth.c         | 23 ++++++++++++++++++----
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-orion-net.txt b/Documentation/devicetree/bindings/net/marvell-orion-net.txt
index bce52b2ec55e..6fd988c84c4f 100644
--- a/Documentation/devicetree/bindings/net/marvell-orion-net.txt
+++ b/Documentation/devicetree/bindings/net/marvell-orion-net.txt
@@ -49,6 +49,7 @@ Optional port properties:
 and
 
  - phy-handle: See ethernet.txt file in the same directory.
+ - phy-mode: See ethernet.txt file in the same directory.
 
 or
 
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 55831188bc32..bf5cc55ba24c 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2968,6 +2968,22 @@ static void set_params(struct mv643xx_eth_private *mp,
 	mp->txq_count = pd->tx_queue_count ? : 1;
 }
 
+static int get_phy_mode(struct mv643xx_eth_private *mp)
+{
+	struct device *dev = mp->dev->dev.parent;
+	int iface = -1;
+
+	if (dev->of_node)
+		iface = of_get_phy_mode(dev->of_node);
+
+	/* Historical default if unspecified. We could also read/write
+	 * the interface state in the PSC1
+	 */
+	if (iface < 0)
+		iface = PHY_INTERFACE_MODE_GMII;
+	return iface;
+}
+
 static struct phy_device *phy_scan(struct mv643xx_eth_private *mp,
 				   int phy_addr)
 {
@@ -2994,7 +3010,7 @@ static struct phy_device *phy_scan(struct mv643xx_eth_private *mp,
 				"orion-mdio-mii", addr);
 
 		phydev = phy_connect(mp->dev, phy_id, mv643xx_eth_adjust_link,
-				PHY_INTERFACE_MODE_GMII);
+				     get_phy_mode(mp));
 		if (!IS_ERR(phydev)) {
 			phy_addr_set(mp, addr);
 			break;
@@ -3090,6 +3106,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	if (!dev)
 		return -ENOMEM;
 
+	SET_NETDEV_DEV(dev, &pdev->dev);
 	mp = netdev_priv(dev);
 	platform_set_drvdata(pdev, mp);
 
@@ -3129,7 +3146,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	if (pd->phy_node) {
 		mp->phy = of_phy_connect(mp->dev, pd->phy_node,
 					 mv643xx_eth_adjust_link, 0,
-					 PHY_INTERFACE_MODE_GMII);
+					 get_phy_mode(mp));
 		if (!mp->phy)
 			err = -ENODEV;
 		else
@@ -3187,8 +3204,6 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	dev->priv_flags |= IFF_UNICAST_FLT;
 	dev->gso_max_segs = MV643XX_MAX_TSO_SEGS;
 
-	SET_NETDEV_DEV(dev, &pdev->dev);
-
 	if (mp->shared->win_protect)
 		wrl(mp, WINDOW_PROTECT(mp->port_num), mp->shared->win_protect);
 
-- 
2.1.4
