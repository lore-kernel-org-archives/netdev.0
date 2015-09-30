From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 7/8] amd-xgbe: Use device workqueue instead of
 system workqueue
Date: Wed, 30 Sep 2015 08:53:16 -0500
Message-ID: <20150930135316.12605.46198.stgit@tlendack-t1.amdoffice.net>
References: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0073.outbound.protection.outlook.com ([157.56.110.73]:28421
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752671AbbI3OI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 10:08:29 -0400
In-Reply-To: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver creates, flushes and destroys a device workqueue but queues
work to the system workqueue. Switch from using the system workqueue to
the device workqueue.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 24212d2..14bad8c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -365,7 +365,7 @@ static irqreturn_t xgbe_isr(int irq, void *data)
 
 		/* Restart the device on a Fatal Bus Error */
 		if (XGMAC_GET_BITS(dma_ch_isr, DMA_CH_SR, FBE))
-			schedule_work(&pdata->restart_work);
+			queue_work(pdata->dev_workqueue, &pdata->restart_work);
 
 		/* Clear all interrupt signals */
 		XGMAC_DMA_IOWRITE(channel, DMA_CH_SR, dma_ch_isr);
@@ -387,7 +387,8 @@ static irqreturn_t xgbe_isr(int irq, void *data)
 				/* Read Tx Timestamp to clear interrupt */
 				pdata->tx_tstamp =
 					hw_if->get_tx_tstamp(pdata);
-				schedule_work(&pdata->tx_tstamp_work);
+				queue_work(pdata->dev_workqueue,
+					   &pdata->tx_tstamp_work);
 			}
 		}
 	}
@@ -453,7 +454,7 @@ static void xgbe_service_timer(unsigned long data)
 {
 	struct xgbe_prv_data *pdata = (struct xgbe_prv_data *)data;
 
-	schedule_work(&pdata->service_work);
+	queue_work(pdata->dev_workqueue, &pdata->service_work);
 
 	mod_timer(&pdata->service_timer, jiffies + HZ);
 }
@@ -894,7 +895,7 @@ static int xgbe_start(struct xgbe_prv_data *pdata)
 	netif_tx_start_all_queues(netdev);
 
 	xgbe_start_timers(pdata);
-	schedule_work(&pdata->service_work);
+	queue_work(pdata->dev_workqueue, &pdata->service_work);
 
 	DBGPR("<--xgbe_start\n");
 
@@ -1536,7 +1537,7 @@ static void xgbe_tx_timeout(struct net_device *netdev)
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
 
 	netdev_warn(netdev, "tx timeout, device restarting\n");
-	schedule_work(&pdata->restart_work);
+	queue_work(pdata->dev_workqueue, &pdata->restart_work);
 }
 
 static struct rtnl_link_stats64 *xgbe_get_stats64(struct net_device *netdev,
