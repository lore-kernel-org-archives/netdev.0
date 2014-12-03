From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next] amd-xgbe: IRQ names require allocated memory
Date: Tue, 2 Dec 2014 18:07:18 -0600
Message-ID: <20141203000718.17370.31628.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0134.outbound.protection.outlook.com ([157.56.110.134]:1664
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932722AbaLCAHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2014 19:07:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When requesting an irq, the name passed in must be (part of) allocated
memory. The irq name was a local variable and resulted in random
characters when listing /proc/interrupts. Add a character field to the
xgbe_channel structure to hold the irq name and use that.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    8 ++++----
 drivers/net/ethernet/amd/xgbe/xgbe.h     |    1 +
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 02c104d..bedfdb1 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1285,7 +1285,6 @@ static int xgbe_open(struct net_device *netdev)
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
 	struct xgbe_desc_if *desc_if = &pdata->desc_if;
 	struct xgbe_channel *channel = NULL;
-	char dma_irq_name[IFNAMSIZ + 32];
 	unsigned int i = 0;
 	int ret;
 
@@ -1341,13 +1340,14 @@ static int xgbe_open(struct net_device *netdev)
 	if (pdata->per_channel_irq) {
 		channel = pdata->channel;
 		for (i = 0; i < pdata->channel_count; i++, channel++) {
-			snprintf(dma_irq_name, sizeof(dma_irq_name) - 1,
+			snprintf(channel->dma_irq_name,
+				 sizeof(channel->dma_irq_name) - 1,
 				 "%s-TxRx-%u", netdev_name(netdev),
 				 channel->queue_index);
 
 			ret = devm_request_irq(pdata->dev, channel->dma_irq,
-					       xgbe_dma_isr, 0, dma_irq_name,
-					       channel);
+					       xgbe_dma_isr, 0,
+					       channel->dma_irq_name, channel);
 			if (ret) {
 				netdev_alert(netdev,
 					     "error requesting irq %d\n",
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index eb33873..f9ec762 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -400,6 +400,7 @@ struct xgbe_channel {
 
 	/* Per channel interrupt irq number */
 	int dma_irq;
+	char dma_irq_name[IFNAMSIZ + 32];
 
 	/* Netdev related settings */
 	struct napi_struct napi;
