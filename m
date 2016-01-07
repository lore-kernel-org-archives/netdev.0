From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH v2] stmmac: Don't exit mdio registration when mdio subnode is not found in the DTS
Date: Thu,  7 Jan 2016 21:13:28 +0100
Message-ID: <1452197608-29060-1-git-send-email-romain.perier@gmail.com>
Cc: netdev@vger.kernel.org, linux-rockchip@lists.infradead.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:33533 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356AbcAGUNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 15:13:33 -0500
Received: by mail-wm0-f48.google.com with SMTP id f206so111944884wmf.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 12:13:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Originally, most of the platforms using this driver did not define an mdio subnode
in the devicetree. Commit e34d65 ("stmmac: create of compatible mdio bus for stmmac driver")
introduced a backward compatibily issue by using of_mdiobus_register explicitly
with an mdio subnode. This patch fixes the issue by calling the function
mdiobus_register, when mdio subnode is not found. The driver is now compatible
with both modes.

Fixes: e34d65696d2e ("stmmac: create of compatible mdio bus for stmmac driver")
Signed-off-by: Romain Perier <romain.perier@gmail.com>
---

Changes in v2:
	- Removed IS_ENABLED macro from the if statement before calling
	  of_mdiobus_register.
	- Added Fixes tag in commit message

 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 16c85cc..648488d 100644
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
+	if (mdio_node)
+		err = of_mdiobus_register(new_bus, mdio_node);
+	else
+		err = mdiobus_register(new_bus);
 	if (err != 0) {
 		pr_err("%s: Cannot register as MDIO bus\n", new_bus->name);
 		goto bus_register_fail;
-- 
2.5.0
