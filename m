From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 2/3] ethoc: Clean up PHY probing
Date: Tue, 18 May 2010 07:39:25 +0200
Message-ID: <1274161166-18521-3-git-send-email-jonas@southpole.se>
References: <1274161166-18521-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:35398 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756622Ab0ERF6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:58:32 -0400
In-Reply-To: <1274161166-18521-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- No need to iterate over all possible addresses on bus
- Use helper function phy_find_first
- Use phy_connect_direct as we already have the relevant structure
---
 drivers/net/ethoc.c |   24 ++++++++----------------
 1 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 41bded6..4bccae2 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -620,21 +620,13 @@ static int ethoc_mdio_probe(struct net_device *dev)
 {
 	struct ethoc *priv = netdev_priv(dev);
 	struct phy_device *phy;
+	int err;
 	int i;
 
-	for (i = 0; i < PHY_MAX_ADDR; i++) {
-		phy = priv->mdio->phy_map[i];
-		if (phy) {
-			if (priv->phy_id != -1) {
-				/* attach to specified PHY */
-				if (priv->phy_id == phy->addr)
-					break;
-			} else {
-				/* autoselect PHY if none was specified */
-				if (phy->addr != 0)
-					break;
-			}
-		}
+	if (priv->phy_id != -1) {
+		phy = priv->mdio->phy_map[priv->phy_id];
+	} else {
+		phy = phy_find_first(priv->mdio);
 	}
 
 	if (!phy) {
@@ -642,11 +634,11 @@ static int ethoc_mdio_probe(struct net_device *dev)
 		return -ENXIO;
 	}
 
-	phy = phy_connect(dev, dev_name(&phy->dev), ethoc_mdio_poll, 0,
+	err = phy_connect_direct(dev, phy, ethoc_mdio_poll, 0,
 			PHY_INTERFACE_MODE_GMII);
-	if (IS_ERR(phy)) {
+	if (err) {
 		dev_err(&dev->dev, "could not attach to PHY\n");
-		return PTR_ERR(phy);
+		return err;
 	}
 
 	priv->phy = phy;
-- 
1.7.0.4

