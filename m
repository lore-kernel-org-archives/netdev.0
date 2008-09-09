From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 15/24] ixgbe: fix ring reallocation in ethtool
Date: Mon, 08 Sep 2008 21:48:12 -0700
Message-ID: <20080909044812.18904.7889.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:14460 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590AbYIIEsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:48:14 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1350319waf.23
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 21:48:13 -0700 (PDT)
In-Reply-To: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

changing ring sizes in ethtool needs to be robust.  If an allocation fails the
driver must continue operation, with the previous settings.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    4 ++
 drivers/net/ixgbe/ixgbe_ethtool.c |   95 ++++++++++++++++++-------------------
 drivers/net/ixgbe/ixgbe_main.c    |   10 ++--
 3 files changed, 56 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 71ddac6..27db64f 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -336,5 +336,9 @@ extern int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 				    struct ixgbe_ring *rxdr);
 extern int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
 				    struct ixgbe_ring *txdr);
+extern void ixgbe_free_rx_resources(struct ixgbe_adapter *adapter,
+                                    struct ixgbe_ring *rxdr);
+extern void ixgbe_free_tx_resources(struct ixgbe_adapter *adapter,
+                                    struct ixgbe_ring *txdr);
 
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index f18e3da..928b97c 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -654,12 +654,9 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 			       struct ethtool_ringparam *ring)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_tx_buffer *old_buf;
-	struct ixgbe_rx_buffer *old_rx_buf;
-	void *old_desc;
+	struct ixgbe_ring *temp_ring;
 	int i, err;
-	u32 new_rx_count, new_tx_count, old_size;
-	dma_addr_t old_dma;
+	u32 new_rx_count, new_tx_count;
 
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
@@ -678,6 +675,15 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 		return 0;
 	}
 
+	if (adapter->num_tx_queues > adapter->num_rx_queues)
+		temp_ring = vmalloc(adapter->num_tx_queues *
+		                    sizeof(struct ixgbe_ring));
+	else
+		temp_ring = vmalloc(adapter->num_rx_queues *
+		                    sizeof(struct ixgbe_ring));
+	if (!temp_ring)
+		return -ENOMEM;
+
 	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
 		msleep(1);
 
@@ -690,66 +696,59 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 	 * to the tx and rx ring structs.
 	 */
 	if (new_tx_count != adapter->tx_ring->count) {
+		memcpy(temp_ring, adapter->tx_ring,
+		       adapter->num_tx_queues * sizeof(struct ixgbe_ring));
+
 		for (i = 0; i < adapter->num_tx_queues; i++) {
-			/* Save existing descriptor ring */
-			old_buf = adapter->tx_ring[i].tx_buffer_info;
-			old_desc = adapter->tx_ring[i].desc;
-			old_size = adapter->tx_ring[i].size;
-			old_dma = adapter->tx_ring[i].dma;
-			/* Try to allocate a new one */
-			adapter->tx_ring[i].tx_buffer_info = NULL;
-			adapter->tx_ring[i].desc = NULL;
-			adapter->tx_ring[i].count = new_tx_count;
-			err = ixgbe_setup_tx_resources(adapter,
-						       &adapter->tx_ring[i]);
+			temp_ring[i].count = new_tx_count;
+			err = ixgbe_setup_tx_resources(adapter, &temp_ring[i]);
 			if (err) {
-				/* Restore the old one so at least
-				   the adapter still works, even if
-				   we failed the request */
-				adapter->tx_ring[i].tx_buffer_info = old_buf;
-				adapter->tx_ring[i].desc = old_desc;
-				adapter->tx_ring[i].size = old_size;
-				adapter->tx_ring[i].dma = old_dma;
+				while (i) {
+					i--;
+					ixgbe_free_tx_resources(adapter, &temp_ring[i]);
+				}
 				goto err_setup;
 			}
-			/* Free the old buffer manually */
-			vfree(old_buf);
-			pci_free_consistent(adapter->pdev, old_size,
-					    old_desc, old_dma);
 		}
+
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			ixgbe_free_tx_resources(adapter, &adapter->tx_ring[i]);
+
+		memcpy(adapter->tx_ring, temp_ring,
+		       adapter->num_tx_queues * sizeof(struct ixgbe_ring));
+
+		adapter->tx_ring_count = new_tx_count;
 	}
 
 	if (new_rx_count != adapter->rx_ring->count) {
-		for (i = 0; i < adapter->num_rx_queues; i++) {
+		memcpy(temp_ring, adapter->rx_ring,
+		       adapter->num_rx_queues * sizeof(struct ixgbe_ring));
 
-			old_rx_buf = adapter->rx_ring[i].rx_buffer_info;
-			old_desc = adapter->rx_ring[i].desc;
-			old_size = adapter->rx_ring[i].size;
-			old_dma = adapter->rx_ring[i].dma;
-
-			adapter->rx_ring[i].rx_buffer_info = NULL;
-			adapter->rx_ring[i].desc = NULL;
-			adapter->rx_ring[i].dma = 0;
-			adapter->rx_ring[i].count = new_rx_count;
-			err = ixgbe_setup_rx_resources(adapter,
-						       &adapter->rx_ring[i]);
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			temp_ring[i].count = new_rx_count;
+			err = ixgbe_setup_rx_resources(adapter, &temp_ring[i]);
 			if (err) {
-				adapter->rx_ring[i].rx_buffer_info = old_rx_buf;
-				adapter->rx_ring[i].desc = old_desc;
-				adapter->rx_ring[i].size = old_size;
-				adapter->rx_ring[i].dma = old_dma;
+				while (i) {
+					i--;
+					ixgbe_free_rx_resources(adapter, &temp_ring[i]);
+				}
 				goto err_setup;
 			}
-
-			vfree(old_rx_buf);
-			pci_free_consistent(adapter->pdev, old_size, old_desc,
-					    old_dma);
 		}
+
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			ixgbe_free_rx_resources(adapter, &adapter->rx_ring[i]);
+
+		memcpy(adapter->rx_ring, temp_ring,
+		       adapter->num_rx_queues * sizeof(struct ixgbe_ring));
+
+		adapter->rx_ring_count = new_rx_count;
 	}
 
+	/* success! */
 	err = 0;
 err_setup:
-	if (netif_running(adapter->netdev))
+	if (netif_running(netdev))
 		ixgbe_up(adapter);
 
 	clear_bit(__IXGBE_RESETTING, &adapter->state);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 8b0f1b6..27d69e4 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2737,8 +2737,8 @@ alloc_failed:
  *
  * Free all transmit software resources
  **/
-static void ixgbe_free_tx_resources(struct ixgbe_adapter *adapter,
-                                    struct ixgbe_ring *tx_ring)
+void ixgbe_free_tx_resources(struct ixgbe_adapter *adapter,
+                             struct ixgbe_ring *tx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 
@@ -2767,14 +2767,14 @@ static void ixgbe_free_all_tx_resources(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_free_rx_resources - Free Rx Resources
+ * ixgbe_ree_rx_resources - Free Rx Resources
  * @adapter: board private structure
  * @rx_ring: ring to clean the resources from
  *
  * Free all receive software resources
  **/
-static void ixgbe_free_rx_resources(struct ixgbe_adapter *adapter,
-				    struct ixgbe_ring *rx_ring)
+void ixgbe_free_rx_resources(struct ixgbe_adapter *adapter,
+                             struct ixgbe_ring *rx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 

