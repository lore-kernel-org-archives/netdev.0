From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe: Request IRQs only after driver is fully setup
Date: Wed, 25 Feb 2015 13:50:12 -0600
Message-ID: <20150225195012.17171.35178.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0137.outbound.protection.outlook.com ([65.55.169.137]:28393
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753099AbbBYTuT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 14:50:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible that the hardware may not have been properly shutdown
before this driver gets control, through use by firmware, for example.
Until the driver is loaded, interrupts associated with the hardware
could go pending. When the IRQs are requested napi support has not
been initialized yet, but the ISR will get control and schedule napi
processing resulting in a kernel panic because the poll routine has not
been set.

Adjust the code so that the driver is fully ready to handle and process
interrupts as soon as the IRQs are requested. This involves requesting
and freeing IRQs during start and stop processing and ordering the napi
add and delete calls appropriately.

Also adjust the powerup and powerdown routines to match the start and
stop routines in regards to the ordering of tasks, including napi
related calls.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |  175 ++++++++++++++++--------------
 1 file changed, 93 insertions(+), 82 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index b93d440..885b02b 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -609,6 +609,68 @@ static void xgbe_napi_disable(struct xgbe_prv_data *pdata, unsigned int del)
 	}
 }
 
+static int xgbe_request_irqs(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	struct net_device *netdev = pdata->netdev;
+	unsigned int i;
+	int ret;
+
+	ret = devm_request_irq(pdata->dev, pdata->dev_irq, xgbe_isr, 0,
+			       netdev->name, pdata);
+	if (ret) {
+		netdev_alert(netdev, "error requesting irq %d\n",
+			     pdata->dev_irq);
+		return ret;
+	}
+
+	if (!pdata->per_channel_irq)
+		return 0;
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		snprintf(channel->dma_irq_name,
+			 sizeof(channel->dma_irq_name) - 1,
+			 "%s-TxRx-%u", netdev_name(netdev),
+			 channel->queue_index);
+
+		ret = devm_request_irq(pdata->dev, channel->dma_irq,
+				       xgbe_dma_isr, 0,
+				       channel->dma_irq_name, channel);
+		if (ret) {
+			netdev_alert(netdev, "error requesting irq %d\n",
+				     channel->dma_irq);
+			goto err_irq;
+		}
+	}
+
+	return 0;
+
+err_irq:
+	/* Using an unsigned int, 'i' will go to UINT_MAX and exit */
+	for (i--, channel--; i < pdata->channel_count; i--, channel--)
+		devm_free_irq(pdata->dev, channel->dma_irq, channel);
+
+	devm_free_irq(pdata->dev, pdata->dev_irq, pdata);
+
+	return ret;
+}
+
+static void xgbe_free_irqs(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	devm_free_irq(pdata->dev, pdata->dev_irq, pdata);
+
+	if (!pdata->per_channel_irq)
+		return;
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++)
+		devm_free_irq(pdata->dev, channel->dma_irq, channel);
+}
+
 void xgbe_init_tx_coalesce(struct xgbe_prv_data *pdata)
 {
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
@@ -810,20 +872,20 @@ int xgbe_powerdown(struct net_device *netdev, unsigned int caller)
 		return -EINVAL;
 	}
 
-	phy_stop(pdata->phydev);
-
 	spin_lock_irqsave(&pdata->lock, flags);
 
 	if (caller == XGMAC_DRIVER_CONTEXT)
 		netif_device_detach(netdev);
 
 	netif_tx_stop_all_queues(netdev);
-	xgbe_napi_disable(pdata, 0);
 
-	/* Powerdown Tx/Rx */
 	hw_if->powerdown_tx(pdata);
 	hw_if->powerdown_rx(pdata);
 
+	xgbe_napi_disable(pdata, 0);
+
+	phy_stop(pdata->phydev);
+
 	pdata->power_down = 1;
 
 	spin_unlock_irqrestore(&pdata->lock, flags);
@@ -854,14 +916,14 @@ int xgbe_powerup(struct net_device *netdev, unsigned int caller)
 
 	phy_start(pdata->phydev);
 
-	/* Enable Tx/Rx */
+	xgbe_napi_enable(pdata, 0);
+
 	hw_if->powerup_tx(pdata);
 	hw_if->powerup_rx(pdata);
 
 	if (caller == XGMAC_DRIVER_CONTEXT)
 		netif_device_attach(netdev);
 
-	xgbe_napi_enable(pdata, 0);
 	netif_tx_start_all_queues(netdev);
 
 	spin_unlock_irqrestore(&pdata->lock, flags);
@@ -875,6 +937,7 @@ static int xgbe_start(struct xgbe_prv_data *pdata)
 {
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
 	struct net_device *netdev = pdata->netdev;
+	int ret;
 
 	DBGPR("-->xgbe_start\n");
 
@@ -884,17 +947,31 @@ static int xgbe_start(struct xgbe_prv_data *pdata)
 
 	phy_start(pdata->phydev);
 
+	xgbe_napi_enable(pdata, 1);
+
+	ret = xgbe_request_irqs(pdata);
+	if (ret)
+		goto err_napi;
+
 	hw_if->enable_tx(pdata);
 	hw_if->enable_rx(pdata);
 
 	xgbe_init_tx_timers(pdata);
 
-	xgbe_napi_enable(pdata, 1);
 	netif_tx_start_all_queues(netdev);
 
 	DBGPR("<--xgbe_start\n");
 
 	return 0;
+
+err_napi:
+	xgbe_napi_disable(pdata, 1);
+
+	phy_stop(pdata->phydev);
+
+	hw_if->exit(pdata);
+
+	return ret;
 }
 
 static void xgbe_stop(struct xgbe_prv_data *pdata)
@@ -907,16 +984,21 @@ static void xgbe_stop(struct xgbe_prv_data *pdata)
 
 	DBGPR("-->xgbe_stop\n");
 
-	phy_stop(pdata->phydev);
-
 	netif_tx_stop_all_queues(netdev);
-	xgbe_napi_disable(pdata, 1);
 
 	xgbe_stop_tx_timers(pdata);
 
 	hw_if->disable_tx(pdata);
 	hw_if->disable_rx(pdata);
 
+	xgbe_free_irqs(pdata);
+
+	xgbe_napi_disable(pdata, 1);
+
+	phy_stop(pdata->phydev);
+
+	hw_if->exit(pdata);
+
 	channel = pdata->channel;
 	for (i = 0; i < pdata->channel_count; i++, channel++) {
 		if (!channel->tx_ring)
@@ -931,10 +1013,6 @@ static void xgbe_stop(struct xgbe_prv_data *pdata)
 
 static void xgbe_restart_dev(struct xgbe_prv_data *pdata)
 {
-	struct xgbe_channel *channel;
-	struct xgbe_hw_if *hw_if = &pdata->hw_if;
-	unsigned int i;
-
 	DBGPR("-->xgbe_restart_dev\n");
 
 	/* If not running, "restart" will happen on open */
@@ -942,19 +1020,10 @@ static void xgbe_restart_dev(struct xgbe_prv_data *pdata)
 		return;
 
 	xgbe_stop(pdata);
-	synchronize_irq(pdata->dev_irq);
-	if (pdata->per_channel_irq) {
-		channel = pdata->channel;
-		for (i = 0; i < pdata->channel_count; i++, channel++)
-			synchronize_irq(channel->dma_irq);
-	}
 
 	xgbe_free_tx_data(pdata);
 	xgbe_free_rx_data(pdata);
 
-	/* Issue software reset to device */
-	hw_if->exit(pdata);
-
 	xgbe_start(pdata);
 
 	DBGPR("<--xgbe_restart_dev\n");
@@ -1283,10 +1352,7 @@ static void xgbe_packet_info(struct xgbe_prv_data *pdata,
 static int xgbe_open(struct net_device *netdev)
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
-	struct xgbe_hw_if *hw_if = &pdata->hw_if;
 	struct xgbe_desc_if *desc_if = &pdata->desc_if;
-	struct xgbe_channel *channel = NULL;
-	unsigned int i = 0;
 	int ret;
 
 	DBGPR("-->xgbe_open\n");
@@ -1329,55 +1395,14 @@ static int xgbe_open(struct net_device *netdev)
 	INIT_WORK(&pdata->restart_work, xgbe_restart);
 	INIT_WORK(&pdata->tx_tstamp_work, xgbe_tx_tstamp);
 
-	/* Request interrupts */
-	ret = devm_request_irq(pdata->dev, pdata->dev_irq, xgbe_isr, 0,
-			       netdev->name, pdata);
-	if (ret) {
-		netdev_alert(netdev, "error requesting irq %d\n",
-			     pdata->dev_irq);
-		goto err_rings;
-	}
-
-	if (pdata->per_channel_irq) {
-		channel = pdata->channel;
-		for (i = 0; i < pdata->channel_count; i++, channel++) {
-			snprintf(channel->dma_irq_name,
-				 sizeof(channel->dma_irq_name) - 1,
-				 "%s-TxRx-%u", netdev_name(netdev),
-				 channel->queue_index);
-
-			ret = devm_request_irq(pdata->dev, channel->dma_irq,
-					       xgbe_dma_isr, 0,
-					       channel->dma_irq_name, channel);
-			if (ret) {
-				netdev_alert(netdev,
-					     "error requesting irq %d\n",
-					     channel->dma_irq);
-				goto err_irq;
-			}
-		}
-	}
-
 	ret = xgbe_start(pdata);
 	if (ret)
-		goto err_start;
+		goto err_rings;
 
 	DBGPR("<--xgbe_open\n");
 
 	return 0;
 
-err_start:
-	hw_if->exit(pdata);
-
-err_irq:
-	if (pdata->per_channel_irq) {
-		/* Using an unsigned int, 'i' will go to UINT_MAX and exit */
-		for (i--, channel--; i < pdata->channel_count; i--, channel--)
-			devm_free_irq(pdata->dev, channel->dma_irq, channel);
-	}
-
-	devm_free_irq(pdata->dev, pdata->dev_irq, pdata);
-
 err_rings:
 	desc_if->free_ring_resources(pdata);
 
@@ -1399,30 +1424,16 @@ err_phy_init:
 static int xgbe_close(struct net_device *netdev)
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
-	struct xgbe_hw_if *hw_if = &pdata->hw_if;
 	struct xgbe_desc_if *desc_if = &pdata->desc_if;
-	struct xgbe_channel *channel;
-	unsigned int i;
 
 	DBGPR("-->xgbe_close\n");
 
 	/* Stop the device */
 	xgbe_stop(pdata);
 
-	/* Issue software reset to device */
-	hw_if->exit(pdata);
-
 	/* Free the ring descriptors and buffers */
 	desc_if->free_ring_resources(pdata);
 
-	/* Release the interrupts */
-	devm_free_irq(pdata->dev, pdata->dev_irq, pdata);
-	if (pdata->per_channel_irq) {
-		channel = pdata->channel;
-		for (i = 0; i < pdata->channel_count; i++, channel++)
-			devm_free_irq(pdata->dev, channel->dma_irq, channel);
-	}
-
 	/* Free the channel and ring structures */
 	xgbe_free_channels(pdata);
 
