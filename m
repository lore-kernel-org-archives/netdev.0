From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH] sh_eth: call of_mdiobus_register() to register phys
Date: Mon, 17 Feb 2014 15:28:15 +0000
Message-ID: <1392650895-1422-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: horms+renesas@verge.net.au, sergei.shtylyov@cogentembedded.com,
	linux-sh@vger.kernel.org, magnus@opensource.se,
	linux-kernel@lists.codethink.co.uk,
	Ben Dooks <ben.dooks@codethink.co.uk>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the sh_eth device is registered using OF, then the driver
should call of_mdiobus_register() to register any PHYs connected
to the system.

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 06970ac..165f0c4 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -40,6 +40,7 @@
 #include <linux/if_vlan.h>
 #include <linux/clk.h>
 #include <linux/sh_eth.h>
+#include <linux/of_mdio.h>
 
 #include "sh_eth.h"
 
@@ -2629,6 +2630,18 @@ static int sh_mdio_init(struct net_device *ndev, int id,
 	snprintf(mdp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
 		 mdp->pdev->name, id);
 
+	if (ndev->dev.parent->of_node) {
+		dev_set_drvdata(&ndev->dev, mdp->mii_bus);
+		ret = of_mdiobus_register(mdp->mii_bus,
+					  ndev->dev.parent->of_node);
+		if (ret != 0) {
+			dev_err(&ndev->dev, "of_mdiobus_register() failed\n");
+			goto out_free_bus;
+		}
+
+		return 0;
+	}
+
 	/* PHY IRQ */
 	mdp->mii_bus->irq = devm_kzalloc(&ndev->dev,
 					 sizeof(int) * PHY_MAX_ADDR,
-- 
1.8.5.3

