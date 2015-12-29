From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH] stmmac: Don't exit mdio registration when mdio subnode is not found in the DTS
Date: Tue, 29 Dec 2015 15:05:35 +0100
Message-ID: <1451397935-23643-1-git-send-email-romain.perier@gmail.com>
Cc: netdev@vger.kernel.org, linux-rockchip@lists.infradead.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37662 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817AbbL2OFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 09:05:38 -0500
Received: by mail-wm0-f44.google.com with SMTP id f206so43226533wmf.0
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2015 06:05:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Originally, most of the platforms using this driver did not define an mdio subnode
in the devicetree. Commit e34d65 ("stmmac: create of compatible mdio bus for stmmac driver")
introduced a backward compatibily issue by using of_mdiobus_register explicitly
with an mdio subnode. This patch fixes the issue by calling the function
mdiobus_register, when mdio subnode is not found. The driver is now compatible
with both modes.

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 16c85cc..0034de44 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -218,8 +218,7 @@ int stmmac_mdio_register(struct net_device *ndev)
 		if (mdio_node) {
 			netdev_dbg(ndev, "FOUND MDIO subnode\n");
 		} else {
-			netdev_err(ndev, "NO MDIO subnode\n");
-			return 0;
+			netdev_warn(ndev, "No MDIO subnode found\n");
 		}
 	}
 
@@ -251,7 +250,10 @@ int stmmac_mdio_register(struct net_device *ndev)
 	new_bus->phy_mask = mdio_bus_data->phy_mask;
 	new_bus->parent = priv->device;
 
-	err = of_mdiobus_register(new_bus, mdio_node);
+	if (IS_ENABLED(CONFIG_OF) && mdio_node)
+		err = of_mdiobus_register(new_bus, mdio_node);
+	else
+		err = mdiobus_register(new_bus);
 	if (err != 0) {
 		pr_err("%s: Cannot register as MDIO bus\n", new_bus->name);
 		goto bus_register_fail;
-- 
2.5.0
