From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 1/7] ixgbevf: make use of the dev pointer in the ixgbevf_ring struct
Date: Fri, 17 Jan 2014 18:29:59 -0800
Message-ID: <1390012205-21995-2-git-send-email-aaron.f.brown@intel.com>
References: <1390012205-21995-1-git-send-email-aaron.f.brown@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24162 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752962AbaARCaL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 21:30:11 -0500
In-Reply-To: <1390012205-21995-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch cleans up the code by removing the adapter structure as
parameter from multiple functions. The adapter structure was previously
being used to access the dev pointer, but this can also be done via the
ixgbevf_ring structure. This way we can drop the adapter as parameter from
these functions.

This patch also includes small cleanups in some error code paths.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      | 46 ++++++------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  8 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 91 +++++++++--------------
 3 files changed, 61 insertions(+), 84 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index 515ba4e..f4e0574 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -305,18 +305,18 @@ static int ixgbevf_set_ringparam(struct net_device *netdev,
 			/* clone ring and setup updated count */
 			tx_ring[i] = *adapter->tx_ring[i];
 			tx_ring[i].count = new_tx_count;
-			err = ixgbevf_setup_tx_resources(adapter, &tx_ring[i]);
-			if (!err)
-				continue;
-			while (i) {
-				i--;
-				ixgbevf_free_tx_resources(adapter, &tx_ring[i]);
-			}
+			err = ixgbevf_setup_tx_resources(&tx_ring[i]);
+			if (err) {
+				while (i) {
+					i--;
+					ixgbevf_free_tx_resources(&tx_ring[i]);
+				}
 
-			vfree(tx_ring);
-			tx_ring = NULL;
+				vfree(tx_ring);
+				tx_ring = NULL;
 
-			goto clear_reset;
+				goto clear_reset;
+			}
 		}
 	}
 
@@ -331,18 +331,18 @@ static int ixgbevf_set_ringparam(struct net_device *netdev,
 			/* clone ring and setup updated count */
 			rx_ring[i] = *adapter->rx_ring[i];
 			rx_ring[i].count = new_rx_count;
-			err = ixgbevf_setup_rx_resources(adapter, &rx_ring[i]);
-			if (!err)
-				continue;
-			while (i) {
-				i--;
-				ixgbevf_free_rx_resources(adapter, &rx_ring[i]);
-			}
+			err = ixgbevf_setup_rx_resources(&rx_ring[i]);
+			if (err) {
+				while (i) {
+					i--;
+					ixgbevf_free_rx_resources(&rx_ring[i]);
+				}
 
-			vfree(rx_ring);
-			rx_ring = NULL;
+				vfree(rx_ring);
+				rx_ring = NULL;
 
-			goto clear_reset;
+				goto clear_reset;
+			}
 		}
 	}
 
@@ -352,7 +352,7 @@ static int ixgbevf_set_ringparam(struct net_device *netdev,
 	/* Tx */
 	if (tx_ring) {
 		for (i = 0; i < adapter->num_tx_queues; i++) {
-			ixgbevf_free_tx_resources(adapter, adapter->tx_ring[i]);
+			ixgbevf_free_tx_resources(adapter->tx_ring[i]);
 			*adapter->tx_ring[i] = tx_ring[i];
 		}
 		adapter->tx_ring_count = new_tx_count;
@@ -364,7 +364,7 @@ static int ixgbevf_set_ringparam(struct net_device *netdev,
 	/* Rx */
 	if (rx_ring) {
 		for (i = 0; i < adapter->num_rx_queues; i++) {
-			ixgbevf_free_rx_resources(adapter, adapter->rx_ring[i]);
+			ixgbevf_free_rx_resources(adapter->rx_ring[i]);
 			*adapter->rx_ring[i] = rx_ring[i];
 		}
 		adapter->rx_ring_count = new_rx_count;
@@ -380,7 +380,7 @@ clear_reset:
 	/* free Tx resources if Rx error is encountered */
 	if (tx_ring) {
 		for (i = 0; i < adapter->num_tx_queues; i++)
-			ixgbevf_free_tx_resources(adapter, &tx_ring[i]);
+			ixgbevf_free_tx_resources(&tx_ring[i]);
 		vfree(tx_ring);
 	}
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 0547e40..59a7574 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -420,10 +420,10 @@ void ixgbevf_down(struct ixgbevf_adapter *adapter);
 void ixgbevf_reinit_locked(struct ixgbevf_adapter *adapter);
 void ixgbevf_reset(struct ixgbevf_adapter *adapter);
 void ixgbevf_set_ethtool_ops(struct net_device *netdev);
-int ixgbevf_setup_rx_resources(struct ixgbevf_adapter *, struct ixgbevf_ring *);
-int ixgbevf_setup_tx_resources(struct ixgbevf_adapter *, struct ixgbevf_ring *);
-void ixgbevf_free_rx_resources(struct ixgbevf_adapter *, struct ixgbevf_ring *);
-void ixgbevf_free_tx_resources(struct ixgbevf_adapter *, struct ixgbevf_ring *);
+int ixgbevf_setup_rx_resources(struct ixgbevf_ring *);
+int ixgbevf_setup_tx_resources(struct ixgbevf_ring *);
+void ixgbevf_free_rx_resources(struct ixgbevf_ring *);
+void ixgbevf_free_tx_resources(struct ixgbevf_ring *);
 void ixgbevf_update_stats(struct ixgbevf_adapter *adapter);
 int ethtool_ioctl(struct ifreq *ifr);
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 6cf4120..ec60db0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -368,34 +368,31 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
 				     struct ixgbevf_ring *rx_ring,
 				     int cleaned_count)
 {
-	struct pci_dev *pdev = adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbevf_rx_buffer *bi;
 	unsigned int i = rx_ring->next_to_use;
 
-	bi = &rx_ring->rx_buffer_info[i];
-
 	while (cleaned_count--) {
 		rx_desc = IXGBEVF_RX_DESC(rx_ring, i);
+		bi = &rx_ring->rx_buffer_info[i];
 
 		if (!bi->skb) {
 			struct sk_buff *skb;
 
 			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
 							rx_ring->rx_buf_len);
-			if (!skb) {
-				adapter->alloc_rx_buff_failed++;
+			if (!skb)
 				goto no_buffers;
-			}
+
 			bi->skb = skb;
 
-			bi->dma = dma_map_single(&pdev->dev, skb->data,
+			bi->dma = dma_map_single(rx_ring->dev, skb->data,
 						 rx_ring->rx_buf_len,
 						 DMA_FROM_DEVICE);
-			if (dma_mapping_error(&pdev->dev, bi->dma)) {
+			if (dma_mapping_error(rx_ring->dev, bi->dma)) {
 				dev_kfree_skb(skb);
 				bi->skb = NULL;
-				dev_err(&pdev->dev, "RX DMA map failed\n");
+				dev_err(rx_ring->dev, "Rx DMA map failed\n");
 				break;
 			}
 		}
@@ -404,10 +401,10 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
 		i++;
 		if (i == rx_ring->count)
 			i = 0;
-		bi = &rx_ring->rx_buffer_info[i];
 	}
 
 no_buffers:
+	adapter->alloc_rx_buff_failed++;
 	if (rx_ring->next_to_use != i)
 		ixgbevf_release_rx_desc(rx_ring, i);
 }
@@ -425,7 +422,6 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 				int budget)
 {
 	struct ixgbevf_adapter *adapter = q_vector->adapter;
-	struct pci_dev *pdev = adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
 	struct ixgbevf_rx_buffer *rx_buffer_info, *next_buffer;
 	struct sk_buff *skb;
@@ -451,7 +447,7 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		rx_buffer_info->skb = NULL;
 
 		if (rx_buffer_info->dma) {
-			dma_unmap_single(&pdev->dev, rx_buffer_info->dma,
+			dma_unmap_single(rx_ring->dev, rx_buffer_info->dma,
 					 rx_ring->rx_buf_len,
 					 DMA_FROM_DEVICE);
 			rx_buffer_info->dma = 0;
@@ -1633,13 +1629,10 @@ void ixgbevf_up(struct ixgbevf_adapter *adapter)
 
 /**
  * ixgbevf_clean_rx_ring - Free Rx Buffers per Queue
- * @adapter: board private structure
  * @rx_ring: ring to free buffers from
  **/
-static void ixgbevf_clean_rx_ring(struct ixgbevf_adapter *adapter,
-				  struct ixgbevf_ring *rx_ring)
+static void ixgbevf_clean_rx_ring(struct ixgbevf_ring *rx_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
 	unsigned long size;
 	unsigned int i;
 
@@ -1652,7 +1645,7 @@ static void ixgbevf_clean_rx_ring(struct ixgbevf_adapter *adapter,
 
 		rx_buffer_info = &rx_ring->rx_buffer_info[i];
 		if (rx_buffer_info->dma) {
-			dma_unmap_single(&pdev->dev, rx_buffer_info->dma,
+			dma_unmap_single(rx_ring->dev, rx_buffer_info->dma,
 					 rx_ring->rx_buf_len,
 					 DMA_FROM_DEVICE);
 			rx_buffer_info->dma = 0;
@@ -1677,11 +1670,9 @@ static void ixgbevf_clean_rx_ring(struct ixgbevf_adapter *adapter,
 
 /**
  * ixgbevf_clean_tx_ring - Free Tx Buffers
- * @adapter: board private structure
  * @tx_ring: ring to be cleaned
  **/
-static void ixgbevf_clean_tx_ring(struct ixgbevf_adapter *adapter,
-				  struct ixgbevf_ring *tx_ring)
+static void ixgbevf_clean_tx_ring(struct ixgbevf_ring *tx_ring)
 {
 	struct ixgbevf_tx_buffer *tx_buffer_info;
 	unsigned long size;
@@ -1711,7 +1702,7 @@ static void ixgbevf_clean_all_rx_rings(struct ixgbevf_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		ixgbevf_clean_rx_ring(adapter, adapter->rx_ring[i]);
+		ixgbevf_clean_rx_ring(adapter->rx_ring[i]);
 }
 
 /**
@@ -1723,7 +1714,7 @@ static void ixgbevf_clean_all_tx_rings(struct ixgbevf_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		ixgbevf_clean_tx_ring(adapter, adapter->tx_ring[i]);
+		ixgbevf_clean_tx_ring(adapter->tx_ring[i]);
 }
 
 void ixgbevf_down(struct ixgbevf_adapter *adapter)
@@ -2426,17 +2417,13 @@ pf_has_reset:
 
 /**
  * ixgbevf_free_tx_resources - Free Tx Resources per Queue
- * @adapter: board private structure
  * @tx_ring: Tx descriptor ring for a specific queue
  *
  * Free all transmit software resources
  **/
-void ixgbevf_free_tx_resources(struct ixgbevf_adapter *adapter,
-			       struct ixgbevf_ring *tx_ring)
+void ixgbevf_free_tx_resources(struct ixgbevf_ring *tx_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
-
-	ixgbevf_clean_tx_ring(adapter, tx_ring);
+	ixgbevf_clean_tx_ring(tx_ring);
 
 	vfree(tx_ring->tx_buffer_info);
 	tx_ring->tx_buffer_info = NULL;
@@ -2445,7 +2432,7 @@ void ixgbevf_free_tx_resources(struct ixgbevf_adapter *adapter,
 	if (!tx_ring->desc)
 		return;
 
-	dma_free_coherent(&pdev->dev, tx_ring->size, tx_ring->desc,
+	dma_free_coherent(tx_ring->dev, tx_ring->size, tx_ring->desc,
 			  tx_ring->dma);
 
 	tx_ring->desc = NULL;
@@ -2463,20 +2450,17 @@ static void ixgbevf_free_all_tx_resources(struct ixgbevf_adapter *adapter)
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		if (adapter->tx_ring[i]->desc)
-			ixgbevf_free_tx_resources(adapter, adapter->tx_ring[i]);
+			ixgbevf_free_tx_resources(adapter->tx_ring[i]);
 }
 
 /**
  * ixgbevf_setup_tx_resources - allocate Tx resources (Descriptors)
- * @adapter: board private structure
  * @tx_ring:    tx descriptor ring (for a specific queue) to setup
  *
  * Return 0 on success, negative on failure
  **/
-int ixgbevf_setup_tx_resources(struct ixgbevf_adapter *adapter,
-			       struct ixgbevf_ring *tx_ring)
+int ixgbevf_setup_tx_resources(struct ixgbevf_ring *tx_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
 	int size;
 
 	size = sizeof(struct ixgbevf_tx_buffer) * tx_ring->count;
@@ -2488,7 +2472,7 @@ int ixgbevf_setup_tx_resources(struct ixgbevf_adapter *adapter,
 	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
 
-	tx_ring->desc = dma_alloc_coherent(&pdev->dev, tx_ring->size,
+	tx_ring->desc = dma_alloc_coherent(tx_ring->dev, tx_ring->size,
 					   &tx_ring->dma, GFP_KERNEL);
 	if (!tx_ring->desc)
 		goto err;
@@ -2518,7 +2502,7 @@ static int ixgbevf_setup_all_tx_resources(struct ixgbevf_adapter *adapter)
 	int i, err = 0;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		err = ixgbevf_setup_tx_resources(adapter, adapter->tx_ring[i]);
+		err = ixgbevf_setup_tx_resources(adapter->tx_ring[i]);
 		if (!err)
 			continue;
 		hw_dbg(&adapter->hw,
@@ -2531,37 +2515,34 @@ static int ixgbevf_setup_all_tx_resources(struct ixgbevf_adapter *adapter)
 
 /**
  * ixgbevf_setup_rx_resources - allocate Rx resources (Descriptors)
- * @adapter: board private structure
  * @rx_ring:    rx descriptor ring (for a specific queue) to setup
  *
  * Returns 0 on success, negative on failure
  **/
-int ixgbevf_setup_rx_resources(struct ixgbevf_adapter *adapter,
-			       struct ixgbevf_ring *rx_ring)
+int ixgbevf_setup_rx_resources(struct ixgbevf_ring *rx_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
 	int size;
 
 	size = sizeof(struct ixgbevf_rx_buffer) * rx_ring->count;
 	rx_ring->rx_buffer_info = vzalloc(size);
 	if (!rx_ring->rx_buffer_info)
-		goto alloc_failed;
+		goto err;
 
 	/* Round up to nearest 4K */
 	rx_ring->size = rx_ring->count * sizeof(union ixgbe_adv_rx_desc);
 	rx_ring->size = ALIGN(rx_ring->size, 4096);
 
-	rx_ring->desc = dma_alloc_coherent(&pdev->dev, rx_ring->size,
+	rx_ring->desc = dma_alloc_coherent(rx_ring->dev, rx_ring->size,
 					   &rx_ring->dma, GFP_KERNEL);
 
-	if (!rx_ring->desc) {
-		vfree(rx_ring->rx_buffer_info);
-		rx_ring->rx_buffer_info = NULL;
-		goto alloc_failed;
-	}
+	if (!rx_ring->desc)
+		goto err;
 
 	return 0;
-alloc_failed:
+err:
+	vfree(rx_ring->rx_buffer_info);
+	rx_ring->rx_buffer_info = NULL;
+	dev_err(rx_ring->dev, "Unable to allocate memory for the Rx descriptor ring\n");
 	return -ENOMEM;
 }
 
@@ -2580,7 +2561,7 @@ static int ixgbevf_setup_all_rx_resources(struct ixgbevf_adapter *adapter)
 	int i, err = 0;
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		err = ixgbevf_setup_rx_resources(adapter, adapter->rx_ring[i]);
+		err = ixgbevf_setup_rx_resources(adapter->rx_ring[i]);
 		if (!err)
 			continue;
 		hw_dbg(&adapter->hw,
@@ -2592,22 +2573,18 @@ static int ixgbevf_setup_all_rx_resources(struct ixgbevf_adapter *adapter)
 
 /**
  * ixgbevf_free_rx_resources - Free Rx Resources
- * @adapter: board private structure
  * @rx_ring: ring to clean the resources from
  *
  * Free all receive software resources
  **/
-void ixgbevf_free_rx_resources(struct ixgbevf_adapter *adapter,
-			       struct ixgbevf_ring *rx_ring)
+void ixgbevf_free_rx_resources(struct ixgbevf_ring *rx_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
-
-	ixgbevf_clean_rx_ring(adapter, rx_ring);
+	ixgbevf_clean_rx_ring(rx_ring);
 
 	vfree(rx_ring->rx_buffer_info);
 	rx_ring->rx_buffer_info = NULL;
 
-	dma_free_coherent(&pdev->dev, rx_ring->size, rx_ring->desc,
+	dma_free_coherent(rx_ring->dev, rx_ring->size, rx_ring->desc,
 			  rx_ring->dma);
 
 	rx_ring->desc = NULL;
@@ -2625,7 +2602,7 @@ static void ixgbevf_free_all_rx_resources(struct ixgbevf_adapter *adapter)
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		if (adapter->rx_ring[i]->desc)
-			ixgbevf_free_rx_resources(adapter, adapter->rx_ring[i]);
+			ixgbevf_free_rx_resources(adapter->rx_ring[i]);
 }
 
 /**
-- 
1.8.5.GIT
