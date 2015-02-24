From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe: Do not schedule napi until ready
Date: Tue, 24 Feb 2015 10:48:01 -0600
Message-ID: <20150224164801.26035.17252.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0117.outbound.protection.outlook.com ([65.55.169.117]:18018
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753217AbbBXQsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 11:48:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible that the ethernet device could not have been properly
shutdown when Linux begins executing, through firmware use for example.
Until the amd-xgbe module is loaded, interrupts associated with the
the device could be pending. Once the module is loaded and interrupts
are requested, the interrupt could fire right away. If napi support
has not been initialized then the poll function will be null and result
in a kernel panic when napi attempts to invoke the poll function. Add
a check to the interrupt routine to be sure napi has been initialized
before trying to schedule it.

Also, move the napi enablement support to be a bit earlier during
startup and a bit later during shutdown to be certain napi support is
enabled while the device can perform DMA.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |   22 ++++++++++++++++------
 drivers/net/ethernet/amd/xgbe/xgbe.h     |    1 +
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index b93d440..be0cede 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -349,7 +349,8 @@ static irqreturn_t xgbe_isr(int irq, void *data)
 		if (!pdata->per_channel_irq &&
 		    (XGMAC_GET_BITS(dma_ch_isr, DMA_CH_SR, TI) ||
 		     XGMAC_GET_BITS(dma_ch_isr, DMA_CH_SR, RI))) {
-			if (napi_schedule_prep(&pdata->napi)) {
+			if (pdata->napi_ready &&
+			    napi_schedule_prep(&pdata->napi)) {
 				/* Disable Tx and Rx interrupts */
 				xgbe_disable_rx_tx_ints(pdata);
 
@@ -396,11 +397,12 @@ isr_done:
 static irqreturn_t xgbe_dma_isr(int irq, void *data)
 {
 	struct xgbe_channel *channel = data;
+	struct xgbe_prv_data *pdata = channel->pdata;
 
 	/* Per channel DMA interrupts are enabled, so we use the per
 	 * channel napi structure and not the private data napi structure
 	 */
-	if (napi_schedule_prep(&channel->napi)) {
+	if (pdata->napi_ready && napi_schedule_prep(&channel->napi)) {
 		/* Disable Tx and Rx interrupts */
 		disable_irq_nosync(channel->dma_irq);
 
@@ -586,6 +588,8 @@ static void xgbe_napi_enable(struct xgbe_prv_data *pdata, unsigned int add)
 
 		napi_enable(&pdata->napi);
 	}
+
+	pdata->napi_ready = 1;
 }
 
 static void xgbe_napi_disable(struct xgbe_prv_data *pdata, unsigned int del)
@@ -593,6 +597,8 @@ static void xgbe_napi_disable(struct xgbe_prv_data *pdata, unsigned int del)
 	struct xgbe_channel *channel;
 	unsigned int i;
 
+	pdata->napi_ready = 0;
+
 	if (pdata->per_channel_irq) {
 		channel = pdata->channel;
 		for (i = 0; i < pdata->channel_count; i++, channel++) {
@@ -818,12 +824,13 @@ int xgbe_powerdown(struct net_device *netdev, unsigned int caller)
 		netif_device_detach(netdev);
 
 	netif_tx_stop_all_queues(netdev);
-	xgbe_napi_disable(pdata, 0);
 
 	/* Powerdown Tx/Rx */
 	hw_if->powerdown_tx(pdata);
 	hw_if->powerdown_rx(pdata);
 
+	xgbe_napi_disable(pdata, 0);
+
 	pdata->power_down = 1;
 
 	spin_unlock_irqrestore(&pdata->lock, flags);
@@ -855,13 +862,14 @@ int xgbe_powerup(struct net_device *netdev, unsigned int caller)
 	phy_start(pdata->phydev);
 
 	/* Enable Tx/Rx */
+	xgbe_napi_enable(pdata, 0);
+
 	hw_if->powerup_tx(pdata);
 	hw_if->powerup_rx(pdata);
 
 	if (caller == XGMAC_DRIVER_CONTEXT)
 		netif_device_attach(netdev);
 
-	xgbe_napi_enable(pdata, 0);
 	netif_tx_start_all_queues(netdev);
 
 	spin_unlock_irqrestore(&pdata->lock, flags);
@@ -884,12 +892,13 @@ static int xgbe_start(struct xgbe_prv_data *pdata)
 
 	phy_start(pdata->phydev);
 
+	xgbe_napi_enable(pdata, 1);
+
 	hw_if->enable_tx(pdata);
 	hw_if->enable_rx(pdata);
 
 	xgbe_init_tx_timers(pdata);
 
-	xgbe_napi_enable(pdata, 1);
 	netif_tx_start_all_queues(netdev);
 
 	DBGPR("<--xgbe_start\n");
@@ -910,13 +919,14 @@ static void xgbe_stop(struct xgbe_prv_data *pdata)
 	phy_stop(pdata->phydev);
 
 	netif_tx_stop_all_queues(netdev);
-	xgbe_napi_disable(pdata, 1);
 
 	xgbe_stop_tx_timers(pdata);
 
 	hw_if->disable_tx(pdata);
 	hw_if->disable_rx(pdata);
 
+	xgbe_napi_disable(pdata, 1);
+
 	channel = pdata->channel;
 	for (i = 0; i < pdata->channel_count; i++, channel++) {
 		if (!channel->tx_ring)
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 13e8f95..1507193 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -750,6 +750,7 @@ struct xgbe_prv_data {
 	unsigned char mac_addr[ETH_ALEN];
 	netdev_features_t netdev_features;
 	struct napi_struct napi;
+	unsigned int napi_ready;
 	struct xgbe_mmc_stats mmc_stats;
 
 	/* Filtering support */
