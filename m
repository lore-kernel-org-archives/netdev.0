From: Kostya Belezko <bkostya@hotmail.com>
Subject: [PATCH v2][Nios2-dev] Altera TSE: Add missing phydev
Date: Tue, 30 Dec 2014 12:27:09 -0500
Message-ID: <BLU437-SMTP8237F72A0A7CCFCAF201F6B65E0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Kostya Belezko <bkostya@hotmail.com>
To: Nios2-dev <nios2-dev@lists.rocketboards.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blu004-omc1s6.hotmail.com ([65.55.116.17]:60557 "EHLO
	BLU004-OMC1S6.hotmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbaL3RdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 12:33:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Altera network device doesn't come up after
 
ifconfig eth0 down
ifconfig eth0 up
 
The reason behind is clearing priv->phydev during tse_shutdown().
The phydev is not restored back at tse_open().

Resubmiting as to follow Tobias Klauser suggestion.
phy_start/phy_stop are called on each ifup/ifdown and
phy_disconnect is called once during the module removal. 

Signed-off-by: Kostya Belezko <bkostya@hotmail.com>

---
 drivers/net/ethernet/altera/altera_tse_main.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 4efc435..720db5f 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -1170,10 +1170,6 @@ tx_request_irq_error:
 init_error:
 	free_skbufs(dev);
 alloc_skbuf_error:
-	if (priv->phydev) {
-		phy_disconnect(priv->phydev);
-		priv->phydev = NULL;
-	}
 phy_error:
 	return ret;
 }
@@ -1186,12 +1182,9 @@ static int tse_shutdown(struct net_device *dev)
 	int ret;
 	unsigned long int flags;
 
-	/* Stop and disconnect the PHY */
-	if (priv->phydev) {
+	/* Stop the PHY */
+	if (priv->phydev)
 		phy_stop(priv->phydev);
-		phy_disconnect(priv->phydev);
-		priv->phydev = NULL;
-	}
 
 	netif_stop_queue(dev);
 	napi_disable(&priv->napi);
@@ -1525,6 +1518,10 @@ err_free_netdev:
 static int altera_tse_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct altera_tse_private *priv = netdev_priv(ndev);
+
+	if (priv->phydev)
+		phy_disconnect(priv->phydev);
 
 	platform_set_drvdata(pdev, NULL);
 	altera_tse_mdio_destroy(ndev);
-- 
2.1.0
