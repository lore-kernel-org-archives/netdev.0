From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 6/9] net: bcmgenet: rework bcmgenet_netif_start and bcmgenet_netif_stop
Date: Wed, 25 Oct 2017 15:04:16 -0700
Message-ID: <20171025220419.24951-7-opendmb@gmail.com>
References: <20171025220419.24951-1-opendmb@gmail.com>
Cc: Doug Berger <opendmb@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:53182 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932141AbdJYWFN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 18:05:13 -0400
In-Reply-To: <20171025220419.24951-1-opendmb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit consolidates more common functionality from
bcmgenet_close and bcmgenet_suspend into bcmgenet_netif_stop and
modifies the start and stop sequences to better suit the design
of the GENET hardware.

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 49 +++++++++-----------------
 1 file changed, 17 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 88aacf3bf44f..747224714394 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2763,11 +2763,11 @@ static void bcmgenet_netif_start(struct net_device *dev)
 
 	/* Start the network engine */
 	bcmgenet_enable_rx_napi(priv);
-	bcmgenet_enable_tx_napi(priv);
 
 	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, true);
 
 	netif_tx_start_all_queues(dev);
+	bcmgenet_enable_tx_napi(priv);
 
 	/* Monitor link interrupts now */
 	bcmgenet_link_intr_enable(priv);
@@ -2868,10 +2868,19 @@ static void bcmgenet_netif_stop(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 
+	bcmgenet_disable_tx_napi(priv);
 	netif_tx_stop_all_queues(dev);
+
+	/* Disable MAC receive */
+	umac_enable_set(priv, CMD_RX_EN, false);
+
+	bcmgenet_dma_teardown(priv);
+
+	/* Disable MAC transmit. TX DMA disabled must be done before this */
+	umac_enable_set(priv, CMD_TX_EN, false);
+
 	phy_stop(priv->phydev);
 	bcmgenet_disable_rx_napi(priv);
-	bcmgenet_disable_tx_napi(priv);
 	bcmgenet_intr_disable(priv);
 
 	/* Wait for pending work items to complete. Since interrupts are
@@ -2883,12 +2892,16 @@ static void bcmgenet_netif_stop(struct net_device *dev)
 	priv->old_speed = -1;
 	priv->old_duplex = -1;
 	priv->old_pause = -1;
+
+	/* tx reclaim */
+	bcmgenet_tx_reclaim_all(dev);
+	bcmgenet_fini_dma(priv);
 }
 
 static int bcmgenet_close(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
-	int ret;
+	int ret = 0;
 
 	netif_dbg(priv, ifdown, dev, "bcmgenet_close\n");
 
@@ -2897,20 +2910,6 @@ static int bcmgenet_close(struct net_device *dev)
 	/* Really kill the PHY state machine and disconnect from it */
 	phy_disconnect(priv->phydev);
 
-	/* Disable MAC receive */
-	umac_enable_set(priv, CMD_RX_EN, false);
-
-	ret = bcmgenet_dma_teardown(priv);
-	if (ret)
-		return ret;
-
-	/* Disable MAC transmit. TX DMA disabled must be done before this */
-	umac_enable_set(priv, CMD_TX_EN, false);
-
-	/* tx reclaim */
-	bcmgenet_tx_reclaim_all(dev);
-	bcmgenet_fini_dma(priv);
-
 	free_irq(priv->irq0, priv);
 	free_irq(priv->irq1, priv);
 
@@ -3522,7 +3521,7 @@ static int bcmgenet_suspend(struct device *d)
 {
 	struct net_device *dev = dev_get_drvdata(d);
 	struct bcmgenet_priv *priv = netdev_priv(dev);
-	int ret;
+	int ret = 0;
 
 	if (!netif_running(dev))
 		return 0;
@@ -3534,20 +3533,6 @@ static int bcmgenet_suspend(struct device *d)
 
 	netif_device_detach(dev);
 
-	/* Disable MAC receive */
-	umac_enable_set(priv, CMD_RX_EN, false);
-
-	ret = bcmgenet_dma_teardown(priv);
-	if (ret)
-		return ret;
-
-	/* Disable MAC transmit. TX DMA disabled must be done before this */
-	umac_enable_set(priv, CMD_TX_EN, false);
-
-	/* tx reclaim */
-	bcmgenet_tx_reclaim_all(dev);
-	bcmgenet_fini_dma(priv);
-
 	/* Prepare the device for Wake-on-LAN and switch to the slow clock */
 	if (device_may_wakeup(d) && priv->wolopts) {
 		ret = bcmgenet_power_down(priv, GENET_POWER_WOL_MAGIC);
-- 
2.14.1
