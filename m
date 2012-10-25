From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH] pch_gbe: don't come up if we can't allocate buffers
Date: Thu, 25 Oct 2012 09:10:05 +0200
Message-ID: <1351149005-13698-1-git-send-email-vfalico@redhat.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	tshimizu818@gmail.com, andy.cress@us.kontron.com,
	erwan.velu@zodiacaerospace.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7062 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756770Ab2JYH3B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 03:29:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, even if pch_gbe_alloc_tx/rx_buffers (even partially) fail, we
bring the interface up. It mihgt confuse the user (if he requested specific
amount of buffers) and can lead to different bugs.

Add error handling to these functions and clean after them in case of
failure. It also resolves a possible NULL pointer dereference in
pch_gbe_alloc_tx_buffers(), in case of netdev_alloc_skb() failure. It's ok
to (paritally) fail for pch_gbe_alloc_rx_buffers() in some situation, so
don't clean inside and rather handle skb freeing outside of the function.

This patch also adds tx_alloc_buff_failed ethtool counter.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |    1 +
 .../ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c    |    1 +
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   75 ++++++++++++++-----
 3 files changed, 57 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
index b07311e..da4284f 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -572,6 +572,7 @@ struct pch_gbe_hw_stats {
 	u32 tx_carrier_errors;
 	u32 tx_timeout_count;
 	u32 tx_restart_count;
+	u32 tx_alloc_buff_failed;
 	u32 intr_rx_dsc_empty_count;
 	u32 intr_rx_frame_err_count;
 	u32 intr_rx_fifo_err_count;
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
index 24b787b..f7e793d 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
@@ -58,6 +58,7 @@ static const struct pch_gbe_stats pch_gbe_gstrings_stats[] = {
 	PCH_GBE_STAT(tx_carrier_errors),
 	PCH_GBE_STAT(tx_timeout_count),
 	PCH_GBE_STAT(tx_restart_count),
+	PCH_GBE_STAT(tx_alloc_buff_failed),
 	PCH_GBE_STAT(intr_rx_dsc_empty_count),
 	PCH_GBE_STAT(intr_rx_frame_err_count),
 	PCH_GBE_STAT(intr_rx_fifo_err_count),
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 4c4fe5b..3fa9c86 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -965,6 +965,16 @@ static void pch_gbe_unmap_and_free_rx_resource(
 	}
 }
 
+static void pch_gbe_clean_rx_buffers_pool(struct pch_gbe_adapter *adapter,
+					 struct pch_gbe_rx_ring *rx_ring)
+{
+	pci_free_consistent(adapter->pdev, rx_ring->rx_buff_pool_size,
+			    rx_ring->rx_buff_pool, rx_ring->rx_buff_pool_logic);
+	rx_ring->rx_buff_pool_logic = 0;
+	rx_ring->rx_buff_pool_size = 0;
+	rx_ring->rx_buff_pool = NULL;
+}
+
 /**
  * pch_gbe_clean_tx_ring - Free Tx Buffers
  * @adapter:  Board private structure
@@ -1401,7 +1411,7 @@ static irqreturn_t pch_gbe_intr(int irq, void *data)
  * @rx_ring:       Rx descriptor ring
  * @cleaned_count: Cleaned count
  */
-static void
+static int
 pch_gbe_alloc_rx_buffers(struct pch_gbe_adapter *adapter,
 			 struct pch_gbe_rx_ring *rx_ring, int cleaned_count)
 {
@@ -1413,6 +1423,7 @@ pch_gbe_alloc_rx_buffers(struct pch_gbe_adapter *adapter,
 	struct sk_buff *skb;
 	unsigned int i;
 	unsigned int bufsz;
+	int err = 0;
 
 	bufsz = adapter->rx_buffer_len + NET_IP_ALIGN;
 	i = rx_ring->next_to_use;
@@ -1423,6 +1434,8 @@ pch_gbe_alloc_rx_buffers(struct pch_gbe_adapter *adapter,
 		if (unlikely(!skb)) {
 			/* Better luck next round */
 			adapter->stats.rx_alloc_buff_failed++;
+			err = -ENOMEM;
+			pr_err("alloc_rx_buffers skb alloc failed\n");
 			break;
 		}
 		/* align */
@@ -1438,6 +1451,8 @@ pch_gbe_alloc_rx_buffers(struct pch_gbe_adapter *adapter,
 			buffer_info->skb = NULL;
 			buffer_info->dma = 0;
 			adapter->stats.rx_alloc_buff_failed++;
+			err = -EIO;
+			pr_err("alloc_rx_buffers dma map failed\n");
 			break; /* while !buffer_info->skb */
 		}
 		buffer_info->mapped = true;
@@ -1460,7 +1475,7 @@ pch_gbe_alloc_rx_buffers(struct pch_gbe_adapter *adapter,
 			  (int)sizeof(struct pch_gbe_rx_desc) * i,
 			  &hw->reg->RX_DSC_SW_P);
 	}
-	return;
+	return err;
 }
 
 static int
@@ -1498,7 +1513,7 @@ pch_gbe_alloc_rx_buffers_pool(struct pch_gbe_adapter *adapter,
  * @adapter:   Board private structure
  * @tx_ring:   Tx descriptor ring
  */
-static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
+static int pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
 					struct pch_gbe_tx_ring *tx_ring)
 {
 	struct pch_gbe_buffer *buffer_info;
@@ -1506,6 +1521,7 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
 	unsigned int i;
 	unsigned int bufsz;
 	struct pch_gbe_tx_desc *tx_desc;
+	int err;
 
 	bufsz =
 	    adapter->hw.mac.max_frame_size + PCH_GBE_DMA_ALIGN + NET_IP_ALIGN;
@@ -1513,12 +1529,26 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
 	for (i = 0; i < tx_ring->count; i++) {
 		buffer_info = &tx_ring->buffer_info[i];
 		skb = netdev_alloc_skb(adapter->netdev, bufsz);
+		if (unlikely(!skb)) {
+			adapter->stats.tx_alloc_buff_failed++;
+			err = -ENOMEM;
+			goto freeall;
+		}
 		skb_reserve(skb, PCH_GBE_DMA_ALIGN);
 		buffer_info->skb = skb;
 		tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
 		tx_desc->gbec_status = (DSC_INIT16);
 	}
-	return;
+	return 0;
+
+freeall:
+	for (i--; i >= 0; i--) {
+		dev_kfree_skb_any(buffer_info->skb);
+		buffer_info->skb = NULL;
+		tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
+		tx_desc->gbec_status = 0;
+	}
+	return err;
 }
 
 /**
@@ -1947,17 +1977,17 @@ int pch_gbe_up(struct pch_gbe_adapter *adapter)
 	pch_gbe_configure_rx(adapter);
 
 	err = pch_gbe_request_irq(adapter);
-	if (err) {
-		pr_err("Error: can't bring device up - irq request failed\n");
+	if (err)
 		goto out;
-	}
 	err = pch_gbe_alloc_rx_buffers_pool(adapter, rx_ring, rx_ring->count);
-	if (err) {
-		pr_err("Error: can't bring device up - alloc rx buffers pool failed\n");
-		goto freeirq;
-	}
-	pch_gbe_alloc_tx_buffers(adapter, tx_ring);
-	pch_gbe_alloc_rx_buffers(adapter, rx_ring, rx_ring->count);
+	if (err)
+		goto free_irq;
+	err = pch_gbe_alloc_tx_buffers(adapter, tx_ring);
+	if (err)
+		goto free_rx_pool;
+	err = pch_gbe_alloc_rx_buffers(adapter, rx_ring, rx_ring->count);
+	if (err)
+		goto free_tx;
 	adapter->tx_queue_len = netdev->tx_queue_len;
 	pch_gbe_enable_dma_rx(&adapter->hw);
 	pch_gbe_enable_mac_rx(&adapter->hw);
@@ -1969,10 +1999,20 @@ int pch_gbe_up(struct pch_gbe_adapter *adapter)
 	netif_start_queue(adapter->netdev);
 
 	return 0;
+free_tx:
+	/* pch_gbe_alloc_rx_buffers() is special - it doesn't clean after
+	 * it (partially) failed - so we need to do it by hand
+	 */
+	pch_gbe_clean_rx_ring(adapter, adapter->rx_ring);
 
-freeirq:
+	pch_gbe_clean_tx_ring(adapter, adapter->tx_ring);
+
+free_rx_pool:
+	pch_gbe_clean_rx_buffers_pool(adapter, adapter->rx_ring);
+free_irq:
 	pch_gbe_free_irq(adapter);
 out:
+	pr_err("Error: can't bring device up\n");
 	return err;
 }
 
@@ -1984,7 +2024,6 @@ void pch_gbe_down(struct pch_gbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
-	struct pch_gbe_rx_ring *rx_ring = adapter->rx_ring;
 
 	/* signal that we're down so the interrupt handler does not
 	 * reschedule our watchdog timer */
@@ -2005,11 +2044,7 @@ void pch_gbe_down(struct pch_gbe_adapter *adapter)
 	pch_gbe_clean_tx_ring(adapter, adapter->tx_ring);
 	pch_gbe_clean_rx_ring(adapter, adapter->rx_ring);
 
-	pci_free_consistent(adapter->pdev, rx_ring->rx_buff_pool_size,
-			    rx_ring->rx_buff_pool, rx_ring->rx_buff_pool_logic);
-	rx_ring->rx_buff_pool_logic = 0;
-	rx_ring->rx_buff_pool_size = 0;
-	rx_ring->rx_buff_pool = NULL;
+	pch_gbe_clean_rx_buffers_pool(adapter, adapter->rx_ring);
 }
 
 /**
-- 
1.7.1
