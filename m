From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next] amd-xgbe: Use system workqueue for device restart
Date: Wed, 14 Oct 2015 12:37:32 -0500
Message-ID: <20151014173732.11432.15970.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0096.outbound.protection.outlook.com ([207.46.100.96]:55665
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753389AbbJNRhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 13:37:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A previous patch switched from using the system workqueue to the device
workqueue for various operations. During a device restart the device
workqueue is flushed so the restart cannot use this workqueue or else
a deadlock results.  Move the device restart back to using the system
workqueue.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 14bad8c..49f796a 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -365,7 +365,7 @@ static irqreturn_t xgbe_isr(int irq, void *data)
 
 		/* Restart the device on a Fatal Bus Error */
 		if (XGMAC_GET_BITS(dma_ch_isr, DMA_CH_SR, FBE))
-			queue_work(pdata->dev_workqueue, &pdata->restart_work);
+			schedule_work(&pdata->restart_work);
 
 		/* Clear all interrupt signals */
 		XGMAC_DMA_IOWRITE(channel, DMA_CH_SR, dma_ch_isr);
@@ -1537,7 +1537,7 @@ static void xgbe_tx_timeout(struct net_device *netdev)
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
 
 	netdev_warn(netdev, "tx timeout, device restarting\n");
-	queue_work(pdata->dev_workqueue, &pdata->restart_work);
+	schedule_work(&pdata->restart_work);
 }
 
 static struct rtnl_link_stats64 *xgbe_get_stats64(struct net_device *netdev,
