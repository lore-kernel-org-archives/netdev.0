From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 01/12] amd-xgbe: Move ring allocation to device
 open
Date: Tue, 4 Nov 2014 16:06:26 -0600
Message-ID: <20141104220626.24738.72937.stgit@tlendack-t1.amdoffice.net>
References: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0148.outbound.protection.outlook.com ([157.56.111.148]:3681
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751129AbaKDWGc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 17:06:32 -0500
In-Reply-To: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the channel and ring tracking structures allocation to device
open.  This will allow for future support to vary the number of Tx/Rx
queues without unloading the module.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |   93 +++++++++++++++++++++++++-
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |    8 +-
 drivers/net/ethernet/amd/xgbe/xgbe-main.c    |   62 -----------------
 3 files changed, 93 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 2349ea9..07b00bd 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -129,6 +129,80 @@
 static int xgbe_poll(struct napi_struct *, int);
 static void xgbe_set_rx_mode(struct net_device *);
 
+static int xgbe_alloc_channels(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel_mem, *channel;
+	struct xgbe_ring *tx_ring, *rx_ring;
+	unsigned int count, i;
+
+	count = max_t(unsigned int, pdata->tx_ring_count, pdata->rx_ring_count);
+
+	channel_mem = kcalloc(count, sizeof(struct xgbe_channel), GFP_KERNEL);
+	if (!channel_mem)
+		goto err_channel;
+
+	tx_ring = kcalloc(pdata->tx_ring_count, sizeof(struct xgbe_ring),
+			  GFP_KERNEL);
+	if (!tx_ring)
+		goto err_tx_ring;
+
+	rx_ring = kcalloc(pdata->rx_ring_count, sizeof(struct xgbe_ring),
+			  GFP_KERNEL);
+	if (!rx_ring)
+		goto err_rx_ring;
+
+	for (i = 0, channel = channel_mem; i < count; i++, channel++) {
+		snprintf(channel->name, sizeof(channel->name), "channel-%d", i);
+		channel->pdata = pdata;
+		channel->queue_index = i;
+		channel->dma_regs = pdata->xgmac_regs + DMA_CH_BASE +
+				    (DMA_CH_INC * i);
+
+		if (i < pdata->tx_ring_count) {
+			spin_lock_init(&tx_ring->lock);
+			channel->tx_ring = tx_ring++;
+		}
+
+		if (i < pdata->rx_ring_count) {
+			spin_lock_init(&rx_ring->lock);
+			channel->rx_ring = rx_ring++;
+		}
+
+		DBGPR("  %s - queue_index=%u, dma_regs=%p, tx=%p, rx=%p\n",
+		      channel->name, channel->queue_index, channel->dma_regs,
+		      channel->tx_ring, channel->rx_ring);
+	}
+
+	pdata->channel = channel_mem;
+	pdata->channel_count = count;
+
+	return 0;
+
+err_rx_ring:
+	kfree(tx_ring);
+
+err_tx_ring:
+	kfree(channel_mem);
+
+err_channel:
+	netdev_err(pdata->netdev, "channel allocation failed\n");
+
+	return -ENOMEM;
+}
+
+static void xgbe_free_channels(struct xgbe_prv_data *pdata)
+{
+	if (!pdata->channel)
+		return;
+
+	kfree(pdata->channel->rx_ring);
+	kfree(pdata->channel->tx_ring);
+	kfree(pdata->channel);
+
+	pdata->channel = NULL;
+	pdata->channel_count = 0;
+}
+
 static inline unsigned int xgbe_tx_avail_desc(struct xgbe_ring *ring)
 {
 	return (ring->rdesc_count - (ring->cur - ring->dirty));
@@ -1119,10 +1193,15 @@ static int xgbe_open(struct net_device *netdev)
 		goto err_ptpclk;
 	pdata->rx_buf_size = ret;
 
+	/* Allocate the channel and ring structures */
+	ret = xgbe_alloc_channels(pdata);
+	if (ret)
+		goto err_ptpclk;
+
 	/* Allocate the ring descriptors and buffers */
 	ret = desc_if->alloc_ring_resources(pdata);
 	if (ret)
-		goto err_ptpclk;
+		goto err_channels;
 
 	/* Initialize the device restart and Tx timestamp work struct */
 	INIT_WORK(&pdata->restart_work, xgbe_restart);
@@ -1134,7 +1213,7 @@ static int xgbe_open(struct net_device *netdev)
 	if (ret) {
 		netdev_alert(netdev, "error requesting irq %d\n",
 			     pdata->irq_number);
-		goto err_irq;
+		goto err_rings;
 	}
 	pdata->irq_number = netdev->irq;
 
@@ -1152,9 +1231,12 @@ err_start:
 	devm_free_irq(pdata->dev, pdata->irq_number, pdata);
 	pdata->irq_number = 0;
 
-err_irq:
+err_rings:
 	desc_if->free_ring_resources(pdata);
 
+err_channels:
+	xgbe_free_channels(pdata);
+
 err_ptpclk:
 	clk_disable_unprepare(pdata->ptpclk);
 
@@ -1181,9 +1263,12 @@ static int xgbe_close(struct net_device *netdev)
 	/* Issue software reset to device */
 	hw_if->exit(pdata);
 
-	/* Free all the ring data */
+	/* Free the ring descriptors and buffers */
 	desc_if->free_ring_resources(pdata);
 
+	/* Free the channel and ring structures */
+	xgbe_free_channels(pdata);
+
 	/* Release the interrupt */
 	if (pdata->irq_number != 0) {
 		devm_free_irq(pdata->dev, pdata->irq_number, pdata);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index 49508ec..47022fb 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -452,9 +452,9 @@ static int xgbe_set_coalesce(struct net_device *netdev,
 			     rx_usecs);
 		return -EINVAL;
 	}
-	if (rx_frames > pdata->channel->rx_ring->rdesc_count) {
+	if (rx_frames > pdata->rx_desc_count) {
 		netdev_alert(netdev, "rx-frames is limited to %d frames\n",
-			     pdata->channel->rx_ring->rdesc_count);
+			     pdata->rx_desc_count);
 		return -EINVAL;
 	}
 
@@ -462,9 +462,9 @@ static int xgbe_set_coalesce(struct net_device *netdev,
 	tx_frames = ec->tx_max_coalesced_frames;
 
 	/* Check the bounds of values for Tx */
-	if (tx_frames > pdata->channel->tx_ring->rdesc_count) {
+	if (tx_frames > pdata->tx_desc_count) {
 		netdev_alert(netdev, "tx-frames is limited to %d frames\n",
-			     pdata->channel->tx_ring->rdesc_count);
+			     pdata->tx_desc_count);
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index f5a8fa0..e5077fd 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -133,60 +133,6 @@ MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION(XGBE_DRV_VERSION);
 MODULE_DESCRIPTION(XGBE_DRV_DESC);
 
-static struct xgbe_channel *xgbe_alloc_rings(struct xgbe_prv_data *pdata)
-{
-	struct xgbe_channel *channel_mem, *channel;
-	struct xgbe_ring *tx_ring, *rx_ring;
-	unsigned int count, i;
-
-	DBGPR("-->xgbe_alloc_rings\n");
-
-	count = max_t(unsigned int, pdata->tx_ring_count, pdata->rx_ring_count);
-
-	channel_mem = devm_kcalloc(pdata->dev, count,
-				   sizeof(struct xgbe_channel), GFP_KERNEL);
-	if (!channel_mem)
-		return NULL;
-
-	tx_ring = devm_kcalloc(pdata->dev, pdata->tx_ring_count,
-			       sizeof(struct xgbe_ring), GFP_KERNEL);
-	if (!tx_ring)
-		return NULL;
-
-	rx_ring = devm_kcalloc(pdata->dev, pdata->rx_ring_count,
-			       sizeof(struct xgbe_ring), GFP_KERNEL);
-	if (!rx_ring)
-		return NULL;
-
-	for (i = 0, channel = channel_mem; i < count; i++, channel++) {
-		snprintf(channel->name, sizeof(channel->name), "channel-%d", i);
-		channel->pdata = pdata;
-		channel->queue_index = i;
-		channel->dma_regs = pdata->xgmac_regs + DMA_CH_BASE +
-				    (DMA_CH_INC * i);
-
-		if (i < pdata->tx_ring_count) {
-			spin_lock_init(&tx_ring->lock);
-			channel->tx_ring = tx_ring++;
-		}
-
-		if (i < pdata->rx_ring_count) {
-			spin_lock_init(&rx_ring->lock);
-			channel->rx_ring = rx_ring++;
-		}
-
-		DBGPR("  %s - queue_index=%u, dma_regs=%p, tx=%p, rx=%p\n",
-		      channel->name, channel->queue_index, channel->dma_regs,
-		      channel->tx_ring, channel->rx_ring);
-	}
-
-	pdata->channel_count = count;
-
-	DBGPR("<--xgbe_alloc_rings\n");
-
-	return channel_mem;
-}
-
 static void xgbe_default_config(struct xgbe_prv_data *pdata)
 {
 	DBGPR("-->xgbe_default_config\n");
@@ -383,14 +329,6 @@ static int xgbe_probe(struct platform_device *pdev)
 		goto err_io;
 	}
 
-	/* Allocate the rings for the DMA channels */
-	pdata->channel = xgbe_alloc_rings(pdata);
-	if (!pdata->channel) {
-		dev_err(dev, "ring allocation failed\n");
-		ret = -ENOMEM;
-		goto err_io;
-	}
-
 	/* Prepare to regsiter with MDIO */
 	pdata->mii_bus_id = kasprintf(GFP_KERNEL, "%s", pdev->name);
 	if (!pdata->mii_bus_id) {
