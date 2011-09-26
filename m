From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Subject: [PATCH 2/2] pch_gbe: Fixed the issue on which a network freezes
Date: Mon, 26 Sep 2011 16:27:43 +0900
Message-ID: <1317022063-12143-2-git-send-email-toshiharu-linux@dsn.okisemi.com>
References: <1317022063-12143-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, tomoya-linux@dsn.okisemi.com,
	Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317022063-12143-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The pch_gbe driver has an issue which a network stops,
when receiving traffic is high.
In the case, The link down and up are necessary to return a network.

This patch fixed this issue.

Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
---
 drivers/net/pch_gbe/pch_gbe_main.c |   56 +++++++++++++++++------------------
 1 files changed, 27 insertions(+), 29 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 5474189..b8b4ba2 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -1199,6 +1199,8 @@ static irqreturn_t pch_gbe_intr(int irq, void *data)
 			iowrite32((int_en & ~PCH_GBE_INT_RX_FIFO_ERR),
 				  &hw->reg->INT_EN);
 			pch_gbe_stop_receive(adapter);
+			int_st |= ioread32(&hw->reg->INT_ST);
+			int_st = int_st & ioread32(&hw->reg->INT_EN);
 		}
 	if (int_st & PCH_GBE_INT_RX_DMA_ERR)
 		adapter->stats.intr_rx_dma_err_count++;
@@ -1218,14 +1220,11 @@ static irqreturn_t pch_gbe_intr(int irq, void *data)
 			/* Set Pause packet */
 			pch_gbe_mac_set_pause_packet(hw);
 		}
-		if ((int_en & (PCH_GBE_INT_RX_DMA_CMPLT | PCH_GBE_INT_TX_CMPLT))
-		    == 0) {
-			return IRQ_HANDLED;
-		}
 	}
 
 	/* When request status is Receive interruption */
-	if ((int_st & (PCH_GBE_INT_RX_DMA_CMPLT | PCH_GBE_INT_TX_CMPLT))) {
+	if ((int_st & (PCH_GBE_INT_RX_DMA_CMPLT | PCH_GBE_INT_TX_CMPLT)) ||
+	    (adapter->rx_stop_flag == true)) {
 		if (likely(napi_schedule_prep(&adapter->napi))) {
 			/* Enable only Rx Descriptor empty */
 			atomic_inc(&adapter->irq_sem);
@@ -1385,7 +1384,7 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 	struct sk_buff *skb;
 	unsigned int i;
 	unsigned int cleaned_count = 0;
-	bool cleaned = false;
+	bool cleaned = true;
 
 	pr_debug("next_to_clean : %d\n", tx_ring->next_to_clean);
 
@@ -1396,7 +1395,6 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 
 	while ((tx_desc->gbec_status & DSC_INIT16) == 0x0000) {
 		pr_debug("gbec_status:0x%04x\n", tx_desc->gbec_status);
-		cleaned = true;
 		buffer_info = &tx_ring->buffer_info[i];
 		skb = buffer_info->skb;
 
@@ -1439,8 +1437,10 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 		tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
 
 		/* weight of a sort for tx, to avoid endless transmit cleanup */
-		if (cleaned_count++ == PCH_GBE_TX_WEIGHT)
+		if (cleaned_count++ == PCH_GBE_TX_WEIGHT) {
+			cleaned = false;
 			break;
+		}
 	}
 	pr_debug("called pch_gbe_unmap_and_free_tx_resource() %d count\n",
 		 cleaned_count);
@@ -2168,7 +2168,6 @@ static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
 {
 	struct pch_gbe_adapter *adapter =
 	    container_of(napi, struct pch_gbe_adapter, napi);
-	struct net_device *netdev = adapter->netdev;
 	int work_done = 0;
 	bool poll_end_flag = false;
 	bool cleaned = false;
@@ -2176,33 +2175,32 @@ static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
 
 	pr_debug("budget : %d\n", budget);
 
-	/* Keep link state information with original netdev */
-	if (!netif_carrier_ok(netdev)) {
+	pch_gbe_clean_rx(adapter, adapter->rx_ring, &work_done, budget);
+	cleaned = pch_gbe_clean_tx(adapter, adapter->tx_ring);
+
+	if (!cleaned)
+		work_done = budget;
+	/* If no Tx and not enough Rx work done,
+	 * exit the polling mode
+	 */
+	if (work_done < budget)
 		poll_end_flag = true;
-	} else {
-		pch_gbe_clean_rx(adapter, adapter->rx_ring, &work_done, budget);
+
+	if (poll_end_flag) {
+		napi_complete(napi);
+		if (adapter->rx_stop_flag) {
+			adapter->rx_stop_flag = false;
+			pch_gbe_start_receive(&adapter->hw);
+		}
+		pch_gbe_irq_enable(adapter);
+	} else
 		if (adapter->rx_stop_flag) {
 			adapter->rx_stop_flag = false;
 			pch_gbe_start_receive(&adapter->hw);
 			int_en = ioread32(&adapter->hw.reg->INT_EN);
 			iowrite32((int_en | PCH_GBE_INT_RX_FIFO_ERR),
-					&adapter->hw.reg->INT_EN);
+				&adapter->hw.reg->INT_EN);
 		}
-		cleaned = pch_gbe_clean_tx(adapter, adapter->tx_ring);
-
-		if (cleaned)
-			work_done = budget;
-		/* If no Tx and not enough Rx work done,
-		 * exit the polling mode
-		 */
-		if (work_done < budget)
-			poll_end_flag = true;
-	}
-
-	if (poll_end_flag) {
-		napi_complete(napi);
-		pch_gbe_irq_enable(adapter);
-	}
 
 	pr_debug("poll_end_flag : %d  work_done : %d  budget : %d\n",
 		 poll_end_flag, work_done, budget);
-- 
1.7.4.4
