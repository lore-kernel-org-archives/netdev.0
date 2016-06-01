From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] net/ethoc: fix null dereference on error exit path
Date: Wed,  1 Jun 2016 14:16:50 +0100
Message-ID: <1464787010-3089-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Tobias Klauser <tklauser@distanz.ch>,
	Max Filippov <jcmvbkbc@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

priv is assigned to NULL however some of the early error exit paths to
label 'free' dereference priv, causing a null pointer dereference.

Move the label 'free' to just the free_netdev statement, and add a new
exit path 'free2' for the error cases were clk_disable_unprepare needs
calling before the final free.

Fixes issue found by CoverityScan, CID#113260

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/ethoc.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 41b0106..4edb98c 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1195,7 +1195,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	priv->mdio = mdiobus_alloc();
 	if (!priv->mdio) {
 		ret = -ENOMEM;
-		goto free;
+		goto free2;
 	}
 
 	priv->mdio->name = "ethoc-mdio";
@@ -1208,7 +1208,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	ret = mdiobus_register(priv->mdio);
 	if (ret) {
 		dev_err(&netdev->dev, "failed to register MDIO bus\n");
-		goto free;
+		goto free2;
 	}
 
 	ret = ethoc_mdio_probe(netdev);
@@ -1241,9 +1241,10 @@ error2:
 error:
 	mdiobus_unregister(priv->mdio);
 	mdiobus_free(priv->mdio);
-free:
+free2:
 	if (priv->clk)
 		clk_disable_unprepare(priv->clk);
+free:
 	free_netdev(netdev);
 out:
 	return ret;
-- 
2.8.1
