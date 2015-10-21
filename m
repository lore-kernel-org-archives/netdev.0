From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe: Use wmb before updating current descriptor
 count
Date: Wed, 21 Oct 2015 15:37:05 -0500
Message-ID: <20151021203705.29412.11836.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Christoffer Dall <christoffer.dall@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0067.outbound.protection.outlook.com ([207.46.100.67]:11202
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750767AbbJUUhL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 16:37:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code currently uses the lightweight dma_wmb barrier before updating
the current descriptor count. Under heavy load, the Tx cleanup routine
was seeing the updated current descriptor count before the updated
descriptor information. As a result, the Tx descriptor was being cleaned
up before it was used because it was not "owned" by the hardware yet,
resulting in a Tx queue hang.

Using the wmb barrier insures that the descriptor is updated before the
descriptor counter preventing the Tx queue hang. For extra insurance,
the Tx cleanup routine is changed to grab the current decriptor count on
entry and uses that initial value in the processing loop rather than
trying to chase the current value.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
Tested-by: Christoffer Dall <christoffer.dall@linaro.org>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index a4473d8..e9ab8b9 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1595,7 +1595,7 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 				  packet->rdesc_count, 1);
 
 	/* Make sure ownership is written to the descriptor */
-	dma_wmb();
+	wmb();
 
 	ring->cur = cur_index + 1;
 	if (!packet->skb->xmit_more ||
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index aae9d5e..d2b77d9 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1807,6 +1807,7 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 	struct netdev_queue *txq;
 	int processed = 0;
 	unsigned int tx_packets = 0, tx_bytes = 0;
+	unsigned int cur;
 
 	DBGPR("-->xgbe_tx_poll\n");
 
@@ -1814,10 +1815,11 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 	if (!ring)
 		return 0;
 
+	cur = ring->cur;
 	txq = netdev_get_tx_queue(netdev, channel->queue_index);
 
 	while ((processed < XGBE_TX_DESC_MAX_PROC) &&
-	       (ring->dirty != ring->cur)) {
+	       (ring->dirty != cur)) {
 		rdata = XGBE_GET_DESC_DATA(ring, ring->dirty);
 		rdesc = rdata->rdesc;
 
