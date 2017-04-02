From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 07/13] ftgmac100: Move napi_add/del to open/close
Date: Sun,  2 Apr 2017 13:35:17 +1000
Message-ID: <20170402033523.9482-8-benh@kernel.crashing.org>
References: <20170402033523.9482-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48970 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751165AbdDBDgF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 1 Apr 2017 23:36:05 -0400
In-Reply-To: <20170402033523.9482-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than probe/remove

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 8792c7c..ac22f71 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1160,6 +1160,9 @@ static int ftgmac100_open(struct net_device *netdev)
 	if (err)
 		goto err_hw;
 
+	/* Initialize NAPI */
+	netif_napi_add(netdev, &priv->napi, ftgmac100_poll, 64);
+
 	ftgmac100_init_hw(priv);
 	ftgmac100_start_hw(priv);
 
@@ -1190,6 +1193,7 @@ static int ftgmac100_open(struct net_device *netdev)
 err_ncsi:
 	napi_disable(&priv->napi);
 	netif_stop_queue(netdev);
+	netif_napi_del(&priv->napi);
 	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
 err_hw:
 	free_irq(netdev->irq, netdev);
@@ -1209,6 +1213,7 @@ static int ftgmac100_stop(struct net_device *netdev)
 
 	netif_stop_queue(netdev);
 	napi_disable(&priv->napi);
+	netif_napi_del(&priv->napi);
 	if (netdev->phydev)
 		phy_stop(netdev->phydev);
 	else if (priv->use_ncsi)
@@ -1381,9 +1386,6 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 	spin_lock_init(&priv->tx_lock);
 
-	/* initialize NAPI */
-	netif_napi_add(netdev, &priv->napi, ftgmac100_poll, 64);
-
 	/* map io memory */
 	priv->res = request_mem_region(res->start, resource_size(res),
 				       dev_name(&pdev->dev));
-- 
2.9.3
