From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 05/10] amd-xgbe: Use the new DMA memory barriers
 where appropriate
Date: Thu, 19 Mar 2015 12:12:55 -0500
Message-ID: <20150319171255.26446.19340.stgit@tlendack-t1.amdoffice.net>
References: <20150319171225.26446.36048.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0102.outbound.protection.outlook.com ([207.46.100.102]:26814
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753586AbbCSRpk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 13:45:40 -0400
In-Reply-To: <20150319171225.26446.36048.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new lighter weight memory barriers when working with the device
descriptors.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |   15 +++++++++------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    5 ++++-
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 29137c9..e165d06 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1068,7 +1068,7 @@ static void xgbe_tx_desc_reset(struct xgbe_ring_data *rdata)
 	rdesc->desc3 = 0;
 
 	/* Make sure ownership is written to the descriptor */
-	wmb();
+	dma_wmb();
 }
 
 static void xgbe_tx_desc_init(struct xgbe_channel *channel)
@@ -1124,12 +1124,12 @@ static void xgbe_rx_desc_reset(struct xgbe_ring_data *rdata)
 	 * is written to the descriptor(s) before setting the OWN bit
 	 * for the descriptor
 	 */
-	wmb();
+	dma_wmb();
 
 	XGMAC_SET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, OWN, 1);
 
 	/* Make sure ownership is written to the descriptor */
-	wmb();
+	dma_wmb();
 }
 
 static void xgbe_rx_desc_init(struct xgbe_channel *channel)
@@ -1358,6 +1358,9 @@ static void xgbe_tx_start_xmit(struct xgbe_channel *channel,
 	struct xgbe_prv_data *pdata = channel->pdata;
 	struct xgbe_ring_data *rdata;
 
+	/* Make sure everything is written before the register write */
+	wmb();
+
 	/* Issue a poll command to Tx DMA by writing address
 	 * of next immediate free descriptor */
 	rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
@@ -1565,7 +1568,7 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 	 * is written to the descriptor(s) before setting the OWN bit
 	 * for the first descriptor
 	 */
-	wmb();
+	dma_wmb();
 
 	/* Set OWN bit for the first descriptor */
 	rdata = XGBE_GET_DESC_DATA(ring, start_index);
@@ -1577,7 +1580,7 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 #endif
 
 	/* Make sure ownership is written to the descriptor */
-	wmb();
+	dma_wmb();
 
 	ring->cur = cur_index + 1;
 	if (!packet->skb->xmit_more ||
@@ -1613,7 +1616,7 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 		return 1;
 
 	/* Make sure descriptor fields are read after reading the OWN bit */
-	rmb();
+	dma_rmb();
 
 #ifdef XGMAC_ENABLE_RX_DESC_DUMP
 	xgbe_dump_rx_desc(ring, rdesc, ring->cur);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 885b02b..8635c94 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1800,6 +1800,9 @@ static void xgbe_rx_refresh(struct xgbe_channel *channel)
 		ring->dirty++;
 	}
 
+	/* Make sure everything is written before the register write */
+	wmb();
+
 	/* Update the Rx Tail Pointer Register with address of
 	 * the last cleaned entry */
 	rdata = XGBE_GET_DESC_DATA(ring, ring->dirty - 1);
@@ -1863,7 +1866,7 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 
 		/* Make sure descriptor fields are read after reading the OWN
 		 * bit */
-		rmb();
+		dma_rmb();
 
 #ifdef XGMAC_ENABLE_TX_DESC_DUMP
 		xgbe_dump_tx_desc(ring, ring->dirty, 1, 0);
