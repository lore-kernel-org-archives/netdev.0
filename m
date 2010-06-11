From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 4/7] ethoc: Clean up PHY probing
Date: Fri, 11 Jun 2010 14:47:37 +0200
Message-ID: <1276260460-14531-4-git-send-email-jonas@southpole.se>
References: <1276260460-14531-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:49427 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760008Ab0FKMrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 08:47:51 -0400
In-Reply-To: <1276260460-14531-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- No need to iterate over all possible addresses on bus
- Use helper function phy_find_first
- Use phy_connect_direct as we already have the relevant structure

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |   24 ++++++++----------------
 1 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index afeb993..1ee9947 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -635,21 +635,13 @@ static int ethoc_mdio_probe(struct net_device *dev)
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
@@ -657,11 +649,11 @@ static int ethoc_mdio_probe(struct net_device *dev)
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

