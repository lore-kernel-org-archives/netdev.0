From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 4/5] amd-xgbe: Performance enhancements
Date: Wed, 2 Jul 2014 13:04:46 -0500
Message-ID: <20140702180446.14996.59990.stgit@tlendack-t1.amdoffice.net>
References: <20140702180422.14996.88116.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0244.outbound.protection.outlook.com ([207.46.163.244]:57645
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751540AbaGBSE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 14:04:56 -0400
In-Reply-To: <20140702180422.14996.88116.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides some general performance enhancements for the
driver:
  - Modify the default coalescing settings (reduce usec, increase frames)
  - Change the AXI burst length to 256 bytes (default was 16 bytes which
    was smaller than a cache line)
  - Change the AXI cache settings to write-back/write-allocate which
    allocate cache entries for received packets during the DMA since the
    packet will be processed soon afterwards
  - Combine ioread/iowrite when disabling both the Tx and Rx interrupts
  - Change to processing the Tx/Rx channels in pairs
  - Only recycle the Rx descriptors when a threshold of dirty descriptors
    is reached

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-common.h |    2 +
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c    |   73 ++++++++++------------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c    |   91 +++++++++++++++++----------
 drivers/net/ethernet/amd/xgbe/xgbe.h        |   12 ++--
 4 files changed, 100 insertions(+), 78 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index ccbceba..7ec80ac 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -170,6 +170,8 @@
 #define DMA_MR_SWR_WIDTH		1
 #define DMA_SBMR_EAME_INDEX		11
 #define DMA_SBMR_EAME_WIDTH		1
+#define DMA_SBMR_BLEN_256_INDEX		7
+#define DMA_SBMR_BLEN_256_WIDTH		1
 #define DMA_SBMR_UNDEF_INDEX		0
 #define DMA_SBMR_UNDEF_WIDTH		1
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index e9fed23b..d6a45ce 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1306,56 +1306,48 @@ static int xgbe_is_last_desc(struct xgbe_ring_desc *rdesc)
 	return XGMAC_GET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, LD);
 }
 
-static void xgbe_save_interrupt_status(struct xgbe_channel *channel,
-				       enum xgbe_int_state int_state)
+static int xgbe_enable_int(struct xgbe_channel *channel,
+			   enum xgbe_int int_id)
 {
 	unsigned int dma_ch_ier;
 
-	if (int_state == XGMAC_INT_STATE_SAVE) {
-		channel->saved_ier = XGMAC_DMA_IOREAD(channel, DMA_CH_IER);
-		channel->saved_ier &= XGBE_DMA_INTERRUPT_MASK;
-	} else {
-		dma_ch_ier = XGMAC_DMA_IOREAD(channel, DMA_CH_IER);
-		dma_ch_ier |= channel->saved_ier;
-		XGMAC_DMA_IOWRITE(channel, DMA_CH_IER, dma_ch_ier);
-	}
-}
+	dma_ch_ier = XGMAC_DMA_IOREAD(channel, DMA_CH_IER);
 
-static int xgbe_enable_int(struct xgbe_channel *channel,
-			   enum xgbe_int int_id)
-{
 	switch (int_id) {
-	case XGMAC_INT_DMA_ISR_DC0IS:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TIE, 1);
-		break;
 	case XGMAC_INT_DMA_CH_SR_TI:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TIE, 1);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, TIE, 1);
 		break;
 	case XGMAC_INT_DMA_CH_SR_TPS:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TXSE, 1);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, TXSE, 1);
 		break;
 	case XGMAC_INT_DMA_CH_SR_TBU:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TBUE, 1);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, TBUE, 1);
 		break;
 	case XGMAC_INT_DMA_CH_SR_RI:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, RIE, 1);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, RIE, 1);
 		break;
 	case XGMAC_INT_DMA_CH_SR_RBU:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, RBUE, 1);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, RBUE, 1);
 		break;
 	case XGMAC_INT_DMA_CH_SR_RPS:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, RSE, 1);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, RSE, 1);
+		break;
+	case XGMAC_INT_DMA_CH_SR_TI_RI:
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, TIE, 1);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, RIE, 1);
 		break;
 	case XGMAC_INT_DMA_CH_SR_FBE:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, FBEE, 1);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, FBEE, 1);
 		break;
 	case XGMAC_INT_DMA_ALL:
-		xgbe_save_interrupt_status(channel, XGMAC_INT_STATE_RESTORE);
+		dma_ch_ier |= channel->saved_ier;
 		break;
 	default:
 		return -1;
 	}
 
+	XGMAC_DMA_IOWRITE(channel, DMA_CH_IER, dma_ch_ier);
+
 	return 0;
 }
 
@@ -1364,42 +1356,44 @@ static int xgbe_disable_int(struct xgbe_channel *channel,
 {
 	unsigned int dma_ch_ier;
 
+	dma_ch_ier = XGMAC_DMA_IOREAD(channel, DMA_CH_IER);
+
 	switch (int_id) {
-	case XGMAC_INT_DMA_ISR_DC0IS:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TIE, 0);
-		break;
 	case XGMAC_INT_DMA_CH_SR_TI:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TIE, 0);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, TIE, 0);
 		break;
 	case XGMAC_INT_DMA_CH_SR_TPS:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TXSE, 0);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, TXSE, 0);
 		break;
 	case XGMAC_INT_DMA_CH_SR_TBU:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TBUE, 0);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, TBUE, 0);
 		break;
 	case XGMAC_INT_DMA_CH_SR_RI:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, RIE, 0);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, RIE, 0);
 		break;
 	case XGMAC_INT_DMA_CH_SR_RBU:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, RBUE, 0);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, RBUE, 0);
 		break;
 	case XGMAC_INT_DMA_CH_SR_RPS:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, RSE, 0);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, RSE, 0);
+		break;
+	case XGMAC_INT_DMA_CH_SR_TI_RI:
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, TIE, 0);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, RIE, 0);
 		break;
 	case XGMAC_INT_DMA_CH_SR_FBE:
-		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, FBEE, 0);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, FBEE, 0);
 		break;
 	case XGMAC_INT_DMA_ALL:
-		xgbe_save_interrupt_status(channel, XGMAC_INT_STATE_SAVE);
-
-		dma_ch_ier = XGMAC_DMA_IOREAD(channel, DMA_CH_IER);
+		channel->saved_ier = dma_ch_ier & XGBE_DMA_INTERRUPT_MASK;
 		dma_ch_ier &= ~XGBE_DMA_INTERRUPT_MASK;
-		XGMAC_DMA_IOWRITE(channel, DMA_CH_IER, dma_ch_ier);
 		break;
 	default:
 		return -1;
 	}
 
+	XGMAC_DMA_IOWRITE(channel, DMA_CH_IER, dma_ch_ier);
+
 	return 0;
 }
 
@@ -1453,6 +1447,7 @@ static void xgbe_config_dma_bus(struct xgbe_prv_data *pdata)
 
 	/* Set the System Bus mode */
 	XGMAC_IOWRITE_BITS(pdata, DMA_SBMR, UNDEF, 1);
+	XGMAC_IOWRITE_BITS(pdata, DMA_SBMR, BLEN_256, 1);
 }
 
 static void xgbe_config_dma_cache(struct xgbe_prv_data *pdata)
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index b5fdf66..344e6b1 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -156,16 +156,21 @@ static void xgbe_enable_rx_tx_ints(struct xgbe_prv_data *pdata)
 {
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
 	struct xgbe_channel *channel;
+	enum xgbe_int int_id;
 	unsigned int i;
 
 	channel = pdata->channel;
 	for (i = 0; i < pdata->channel_count; i++, channel++) {
-		if (channel->tx_ring)
-			hw_if->enable_int(channel,
-					  XGMAC_INT_DMA_CH_SR_TI);
-		if (channel->rx_ring)
-			hw_if->enable_int(channel,
-					  XGMAC_INT_DMA_CH_SR_RI);
+		if (channel->tx_ring && channel->rx_ring)
+			int_id = XGMAC_INT_DMA_CH_SR_TI_RI;
+		else if (channel->tx_ring)
+			int_id = XGMAC_INT_DMA_CH_SR_TI;
+		else if (channel->rx_ring)
+			int_id = XGMAC_INT_DMA_CH_SR_RI;
+		else
+			continue;
+
+		hw_if->enable_int(channel, int_id);
 	}
 }
 
@@ -173,16 +178,21 @@ static void xgbe_disable_rx_tx_ints(struct xgbe_prv_data *pdata)
 {
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
 	struct xgbe_channel *channel;
+	enum xgbe_int int_id;
 	unsigned int i;
 
 	channel = pdata->channel;
 	for (i = 0; i < pdata->channel_count; i++, channel++) {
-		if (channel->tx_ring)
-			hw_if->disable_int(channel,
-					   XGMAC_INT_DMA_CH_SR_TI);
-		if (channel->rx_ring)
-			hw_if->disable_int(channel,
-					   XGMAC_INT_DMA_CH_SR_RI);
+		if (channel->tx_ring && channel->rx_ring)
+			int_id = XGMAC_INT_DMA_CH_SR_TI_RI;
+		else if (channel->tx_ring)
+			int_id = XGMAC_INT_DMA_CH_SR_TI;
+		else if (channel->rx_ring)
+			int_id = XGMAC_INT_DMA_CH_SR_RI;
+		else
+			continue;
+
+		hw_if->disable_int(channel, int_id);
 	}
 }
 
@@ -1114,6 +1124,22 @@ struct net_device_ops *xgbe_get_netdev_ops(void)
 	return (struct net_device_ops *)&xgbe_netdev_ops;
 }
 
+static void xgbe_rx_refresh(struct xgbe_channel *channel)
+{
+	struct xgbe_prv_data *pdata = channel->pdata;
+	struct xgbe_desc_if *desc_if = &pdata->desc_if;
+	struct xgbe_ring *ring = channel->rx_ring;
+	struct xgbe_ring_data *rdata;
+
+	desc_if->realloc_skb(channel);
+
+	/* Update the Rx Tail Pointer Register with address of
+	 * the last cleaned entry */
+	rdata = XGBE_GET_DESC_DATA(ring, ring->rx.realloc_index - 1);
+	XGMAC_DMA_IOWRITE(channel, DMA_CH_RDTR_LO,
+			  lower_32_bits(rdata->rdesc_dma));
+}
+
 static int xgbe_tx_poll(struct xgbe_channel *channel)
 {
 	struct xgbe_prv_data *pdata = channel->pdata;
@@ -1171,7 +1197,6 @@ static int xgbe_rx_poll(struct xgbe_channel *channel, int budget)
 {
 	struct xgbe_prv_data *pdata = channel->pdata;
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
-	struct xgbe_desc_if *desc_if = &pdata->desc_if;
 	struct xgbe_ring *ring = channel->rx_ring;
 	struct xgbe_ring_data *rdata;
 	struct xgbe_packet_data *packet;
@@ -1198,6 +1223,9 @@ static int xgbe_rx_poll(struct xgbe_channel *channel, int budget)
 		cur_len = 0;
 
 read_again:
+		if (ring->dirty > (XGBE_RX_DESC_CNT >> 3))
+			xgbe_rx_refresh(channel);
+
 		rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
 
 		if (hw_if->dev_read(channel))
@@ -1285,16 +1313,6 @@ read_again:
 		napi_gro_receive(&pdata->napi, skb);
 	}
 
-	if (received) {
-		desc_if->realloc_skb(channel);
-
-		/* Update the Rx Tail Pointer Register with address of
-		 * the last cleaned entry */
-		rdata = XGBE_GET_DESC_DATA(ring, ring->rx.realloc_index - 1);
-		XGMAC_DMA_IOWRITE(channel, DMA_CH_RDTR_LO,
-				  lower_32_bits(rdata->rdesc_dma));
-	}
-
 	DBGPR("<--xgbe_rx_poll: received = %d\n", received);
 
 	return received;
@@ -1305,21 +1323,28 @@ static int xgbe_poll(struct napi_struct *napi, int budget)
 	struct xgbe_prv_data *pdata = container_of(napi, struct xgbe_prv_data,
 						   napi);
 	struct xgbe_channel *channel;
-	int processed;
+	int ring_budget;
+	int processed, last_processed;
 	unsigned int i;
 
 	DBGPR("-->xgbe_poll: budget=%d\n", budget);
 
-	/* Cleanup Tx ring first */
-	channel = pdata->channel;
-	for (i = 0; i < pdata->channel_count; i++, channel++)
-		xgbe_tx_poll(channel);
-
-	/* Process Rx ring next */
 	processed = 0;
-	channel = pdata->channel;
-	for (i = 0; i < pdata->channel_count; i++, channel++)
-		processed += xgbe_rx_poll(channel, budget - processed);
+	ring_budget = budget / pdata->rx_ring_count;
+	do {
+		last_processed = processed;
+
+		channel = pdata->channel;
+		for (i = 0; i < pdata->channel_count; i++, channel++) {
+			/* Cleanup Tx ring first */
+			xgbe_tx_poll(channel);
+
+			/* Process Rx ring next */
+			if (ring_budget > (budget - processed))
+				ring_budget = budget - processed;
+			processed += xgbe_rx_poll(channel, ring_budget);
+		}
+	} while ((processed < budget) && (processed != last_processed));
 
 	/* If we processed everything, we are done */
 	if (processed < budget) {
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index a2d5f5f..eef8ea1 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -146,7 +146,7 @@
 #define XGBE_DMA_ARDOMAIN	0x2
 #define XGBE_DMA_ARCACHE	0xb
 #define XGBE_DMA_AWDOMAIN	0x2
-#define XGBE_DMA_AWCACHE	0x7
+#define XGBE_DMA_AWCACHE	0xf
 
 #define XGBE_DMA_INTERRUPT_MASK	0x31c7
 
@@ -181,12 +181,12 @@
 
 
 /* Default coalescing parameters */
-#define XGMAC_INIT_DMA_TX_USECS		100
-#define XGMAC_INIT_DMA_TX_FRAMES	16
+#define XGMAC_INIT_DMA_TX_USECS		50
+#define XGMAC_INIT_DMA_TX_FRAMES	25
 
 #define XGMAC_MAX_DMA_RIWT		0xff
-#define XGMAC_INIT_DMA_RX_USECS		100
-#define XGMAC_INIT_DMA_RX_FRAMES	16
+#define XGMAC_INIT_DMA_RX_USECS		30
+#define XGMAC_INIT_DMA_RX_FRAMES	25
 
 /* Flow control queue count */
 #define XGMAC_MAX_FLOW_CONTROL_QUEUES	8
@@ -307,13 +307,13 @@ struct xgbe_channel {
 } ____cacheline_aligned;
 
 enum xgbe_int {
-	XGMAC_INT_DMA_ISR_DC0IS,
 	XGMAC_INT_DMA_CH_SR_TI,
 	XGMAC_INT_DMA_CH_SR_TPS,
 	XGMAC_INT_DMA_CH_SR_TBU,
 	XGMAC_INT_DMA_CH_SR_RI,
 	XGMAC_INT_DMA_CH_SR_RBU,
 	XGMAC_INT_DMA_CH_SR_RPS,
+	XGMAC_INT_DMA_CH_SR_TI_RI,
 	XGMAC_INT_DMA_CH_SR_FBE,
 	XGMAC_INT_DMA_ALL,
 };
