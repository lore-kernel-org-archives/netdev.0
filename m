From: Lars Persson <lars.persson@axis.com>
Subject: [PATCH net 5/5] dwc_eth_qos: do phy_start before resetting hardware
Date: Mon, 29 Feb 2016 16:22:34 +0100
Message-ID: <13e93030fac6f6323664fc7023d0a2090b5127bf.1456756740.git.larper@axis.com>
References: <cover.1456756740.git.larper@axis.com>
Cc: linux-kernel@vger.kernel.org, Lars Persson <larper@axis.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1456756740.git.larper@axis.com>
In-Reply-To: <cover.1456756740.git.larper@axis.com>
References: <cover.1456756740.git.larper@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts the changed init order from commit 3647bc35bd42
("dwc_eth_qos: Reset hardware before PHY start") and makes another fix
for the race.

It turned out that the reset state machine of the dwceqos hardware
requires PHY clocks to be present in order to complete the reset
cycle.

To plug the race with the phy state machine we defer link speed
setting until the hardware init has finished.

Signed-off-by: Lars Persson <larper@axis.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 6897c1d..af11ed1 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -650,6 +650,11 @@ struct net_local {
 	u32 mmc_tx_counters_mask;
 
 	struct dwceqos_flowcontrol flowcontrol;
+
+	/* Tracks the intermediate state of phy started but hardware
+	 * init not finished yet.
+	 */
+	bool phy_defer;
 };
 
 static void dwceqos_read_mmc_counters(struct net_local *lp, u32 rx_mask,
@@ -901,6 +906,9 @@ static void dwceqos_adjust_link(struct net_device *ndev)
 	struct phy_device *phydev = lp->phy_dev;
 	int status_change = 0;
 
+	if (lp->phy_defer)
+		return;
+
 	if (phydev->link) {
 		if ((lp->speed != phydev->speed) ||
 		    (lp->duplex != phydev->duplex)) {
@@ -1635,6 +1643,12 @@ static void dwceqos_init_hw(struct net_local *lp)
 	regval = dwceqos_read(lp, REG_DWCEQOS_MAC_CFG);
 	dwceqos_write(lp, REG_DWCEQOS_MAC_CFG,
 		      regval | DWCEQOS_MAC_CFG_TE | DWCEQOS_MAC_CFG_RE);
+
+	lp->phy_defer = false;
+	mutex_lock(&lp->phy_dev->lock);
+	phy_read_status(lp->phy_dev);
+	dwceqos_adjust_link(lp->ndev);
+	mutex_unlock(&lp->phy_dev->lock);
 }
 
 static void dwceqos_tx_reclaim(unsigned long data)
@@ -1880,9 +1894,13 @@ static int dwceqos_open(struct net_device *ndev)
 	}
 	netdev_reset_queue(ndev);
 
+	/* The dwceqos reset state machine requires all phy clocks to complete,
+	 * hence the unusual init order with phy_start first.
+	 */
+	lp->phy_defer = true;
+	phy_start(lp->phy_dev);
 	dwceqos_init_hw(lp);
 	napi_enable(&lp->napi);
-	phy_start(lp->phy_dev);
 
 	netif_start_queue(ndev);
 	tasklet_enable(&lp->tx_bdreclaim_tasklet);
@@ -1915,8 +1933,6 @@ static int dwceqos_stop(struct net_device *ndev)
 {
 	struct net_local *lp = netdev_priv(ndev);
 
-	phy_stop(lp->phy_dev);
-
 	tasklet_disable(&lp->tx_bdreclaim_tasklet);
 	napi_disable(&lp->napi);
 
@@ -1927,6 +1943,7 @@ static int dwceqos_stop(struct net_device *ndev)
 
 	dwceqos_drain_dma(lp);
 	dwceqos_reset_hw(lp);
+	phy_stop(lp->phy_dev);
 
 	dwceqos_descriptor_free(lp);
 
-- 
2.1.4
