From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 02/18] igb: Remove adapter struct
	from these function	call parameters
Date: Fri, 27 Jun 2008 10:59:48 -0700
Message-ID: <20080627175941.22428.13019.stgit@localhost.localdomain>
References: <20080627175921.22428.52767.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080627175921.22428.52767.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Mitch Williams <mitch.a.williams@intel.com>

Simplify a bunch of calls to these functions by moving the adapter
struct out of the function arguments since that is not needed.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/igb/igb_main.c |   88 ++++++++++++++++++++------------------------
 1 files changed, 40 insertions(+), 48 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 7b6b780..9034339 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -71,8 +71,8 @@ static int igb_setup_all_tx_resources(struct igb_adapter *);
 static int igb_setup_all_rx_resources(struct igb_adapter *);
 static void igb_free_all_tx_resources(struct igb_adapter *);
 static void igb_free_all_rx_resources(struct igb_adapter *);
-static void igb_free_tx_resources(struct igb_adapter *, struct igb_ring *);
-static void igb_free_rx_resources(struct igb_adapter *, struct igb_ring *);
+static void igb_free_tx_resources(struct igb_ring *);
+static void igb_free_rx_resources(struct igb_ring *);
 void igb_update_stats(struct igb_adapter *);
 static int igb_probe(struct pci_dev *, const struct pci_device_id *);
 static void __devexit igb_remove(struct pci_dev *pdev);
@@ -84,8 +84,8 @@ static void igb_configure_rx(struct igb_adapter *);
 static void igb_setup_rctl(struct igb_adapter *);
 static void igb_clean_all_tx_rings(struct igb_adapter *);
 static void igb_clean_all_rx_rings(struct igb_adapter *);
-static void igb_clean_tx_ring(struct igb_adapter *, struct igb_ring *);
-static void igb_clean_rx_ring(struct igb_adapter *, struct igb_ring *);
+static void igb_clean_tx_ring(struct igb_ring *);
+static void igb_clean_rx_ring(struct igb_ring *);
 static void igb_set_multi(struct net_device *);
 static void igb_update_phy_info(unsigned long);
 static void igb_watchdog(unsigned long);
@@ -102,12 +102,10 @@ static irqreturn_t igb_msix_other(int irq, void *);
 static irqreturn_t igb_msix_rx(int irq, void *);
 static irqreturn_t igb_msix_tx(int irq, void *);
 static int igb_clean_rx_ring_msix(struct napi_struct *, int);
-static bool igb_clean_tx_irq(struct igb_adapter *, struct igb_ring *);
+static bool igb_clean_tx_irq(struct igb_ring *);
 static int igb_clean(struct napi_struct *, int);
-static bool igb_clean_rx_irq_adv(struct igb_adapter *,
-				 struct igb_ring *, int *, int);
-static void igb_alloc_rx_buffers_adv(struct igb_adapter *,
-				     struct igb_ring *, int);
+static bool igb_clean_rx_irq_adv(struct igb_ring *, int *, int);
+static void igb_alloc_rx_buffers_adv(struct igb_ring *, int);
 static int igb_ioctl(struct net_device *, struct ifreq *, int cmd);
 static void igb_tx_timeout(struct net_device *);
 static void igb_reset_task(struct work_struct *);
@@ -637,7 +635,7 @@ static void igb_configure(struct igb_adapter *adapter)
 	 * next_to_use != next_to_clean */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct igb_ring *ring = &adapter->rx_ring[i];
-		igb_alloc_rx_buffers_adv(adapter, ring, IGB_DESC_UNUSED(ring));
+		igb_alloc_rx_buffers_adv(ring, IGB_DESC_UNUSED(ring));
 	}
 
 
@@ -1396,8 +1394,7 @@ static int igb_setup_all_tx_resources(struct igb_adapter *adapter)
 			dev_err(&adapter->pdev->dev,
 				"Allocation for Tx Queue %u failed\n", i);
 			for (i--; i >= 0; i--)
-				igb_free_tx_resources(adapter,
-							&adapter->tx_ring[i]);
+				igb_free_tx_resources(&adapter->tx_ring[i]);
 			break;
 		}
 	}
@@ -1540,8 +1537,7 @@ static int igb_setup_all_rx_resources(struct igb_adapter *adapter)
 			dev_err(&adapter->pdev->dev,
 				"Allocation for Rx Queue %u failed\n", i);
 			for (i--; i >= 0; i--)
-				igb_free_rx_resources(adapter,
-							&adapter->rx_ring[i]);
+				igb_free_rx_resources(&adapter->rx_ring[i]);
 			break;
 		}
 	}
@@ -1769,12 +1765,11 @@ static void igb_configure_rx(struct igb_adapter *adapter)
  *
  * Free all transmit software resources
  **/
-static void igb_free_tx_resources(struct igb_adapter *adapter,
-				  struct igb_ring *tx_ring)
+static void igb_free_tx_resources(struct igb_ring *tx_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
+	struct pci_dev *pdev = tx_ring->adapter->pdev;
 
-	igb_clean_tx_ring(adapter, tx_ring);
+	igb_clean_tx_ring(tx_ring);
 
 	vfree(tx_ring->buffer_info);
 	tx_ring->buffer_info = NULL;
@@ -1795,7 +1790,7 @@ static void igb_free_all_tx_resources(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		igb_free_tx_resources(adapter, &adapter->tx_ring[i]);
+		igb_free_tx_resources(&adapter->tx_ring[i]);
 }
 
 static void igb_unmap_and_free_tx_resource(struct igb_adapter *adapter,
@@ -1821,9 +1816,9 @@ static void igb_unmap_and_free_tx_resource(struct igb_adapter *adapter,
  * @adapter: board private structure
  * @tx_ring: ring to be cleaned
  **/
-static void igb_clean_tx_ring(struct igb_adapter *adapter,
-			      struct igb_ring *tx_ring)
+static void igb_clean_tx_ring(struct igb_ring *tx_ring)
 {
+	struct igb_adapter *adapter = tx_ring->adapter;
 	struct igb_buffer *buffer_info;
 	unsigned long size;
 	unsigned int i;
@@ -1860,7 +1855,7 @@ static void igb_clean_all_tx_rings(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		igb_clean_tx_ring(adapter, &adapter->tx_ring[i]);
+		igb_clean_tx_ring(&adapter->tx_ring[i]);
 }
 
 /**
@@ -1870,12 +1865,11 @@ static void igb_clean_all_tx_rings(struct igb_adapter *adapter)
  *
  * Free all receive software resources
  **/
-static void igb_free_rx_resources(struct igb_adapter *adapter,
-				  struct igb_ring *rx_ring)
+static void igb_free_rx_resources(struct igb_ring *rx_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
+	struct pci_dev *pdev = rx_ring->adapter->pdev;
 
-	igb_clean_rx_ring(adapter, rx_ring);
+	igb_clean_rx_ring(rx_ring);
 
 	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
@@ -1896,7 +1890,7 @@ static void igb_free_all_rx_resources(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_free_rx_resources(adapter, &adapter->rx_ring[i]);
+		igb_free_rx_resources(&adapter->rx_ring[i]);
 }
 
 /**
@@ -1904,9 +1898,9 @@ static void igb_free_all_rx_resources(struct igb_adapter *adapter)
  * @adapter: board private structure
  * @rx_ring: ring to free buffers from
  **/
-static void igb_clean_rx_ring(struct igb_adapter *adapter,
-			      struct igb_ring *rx_ring)
+static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 {
+	struct igb_adapter *adapter = rx_ring->adapter;
 	struct igb_buffer *buffer_info;
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned long size;
@@ -1970,7 +1964,7 @@ static void igb_clean_all_rx_rings(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_clean_rx_ring(adapter, &adapter->rx_ring[i]);
+		igb_clean_rx_ring(&adapter->rx_ring[i]);
 }
 
 /**
@@ -3049,7 +3043,7 @@ static irqreturn_t igb_msix_tx(int irq, void *data)
 
 	tx_ring->total_bytes = 0;
 	tx_ring->total_packets = 0;
-	if (!igb_clean_tx_irq(adapter, tx_ring))
+	if (!igb_clean_tx_irq(tx_ring))
 		/* Ring was not completely cleaned, so fire another interrupt */
 		wr32(E1000_EICS, tx_ring->eims_value);
 
@@ -3200,14 +3194,13 @@ static int igb_clean(struct napi_struct *napi, int budget)
 	 * the lock means tx_ring[i] is currently being cleaned anyway. */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		if (spin_trylock(&adapter->tx_ring[i].tx_clean_lock)) {
-			tx_clean_complete &= igb_clean_tx_irq(adapter,
-							&adapter->tx_ring[i]);
+			tx_clean_complete &= igb_clean_tx_irq(&adapter->tx_ring[i]);
 			spin_unlock(&adapter->tx_ring[i].tx_clean_lock);
 		}
 	}
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_clean_rx_irq_adv(adapter, &adapter->rx_ring[i], &work_done,
+		igb_clean_rx_irq_adv(&adapter->rx_ring[i], &work_done,
 				     adapter->rx_ring[i].napi.weight);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
@@ -3237,7 +3230,7 @@ static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
 	if (!netif_carrier_ok(netdev))
 		goto quit_polling;
 
-	igb_clean_rx_irq_adv(adapter, rx_ring, &work_done, budget);
+	igb_clean_rx_irq_adv(rx_ring, &work_done, budget);
 
 
 	/* If not enough Rx work done, exit the polling mode */
@@ -3272,11 +3265,11 @@ static inline u32 get_head(struct igb_ring *tx_ring)
  * @adapter: board private structure
  * returns true if ring is completely cleaned
  **/
-static bool igb_clean_tx_irq(struct igb_adapter *adapter,
-				  struct igb_ring *tx_ring)
+static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
 {
-	struct net_device *netdev = adapter->netdev;
+	struct igb_adapter *adapter = tx_ring->adapter;
 	struct e1000_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_desc *tx_desc;
 	struct igb_buffer *buffer_info;
 	struct sk_buff *skb;
@@ -3431,10 +3424,10 @@ static inline void igb_rx_checksum_adv(struct igb_adapter *adapter,
 	adapter->hw_csum_good++;
 }
 
-static bool igb_clean_rx_irq_adv(struct igb_adapter *adapter,
-				      struct igb_ring *rx_ring,
-				      int *work_done, int budget)
+static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
+				 int *work_done, int budget)
 {
+	struct igb_adapter *adapter = rx_ring->adapter;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	union e1000_adv_rx_desc *rx_desc , *next_rxd;
@@ -3557,8 +3550,7 @@ next_desc:
 
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= IGB_RX_BUFFER_WRITE) {
-			igb_alloc_rx_buffers_adv(adapter, rx_ring,
-						 cleaned_count);
+			igb_alloc_rx_buffers_adv(rx_ring, cleaned_count);
 			cleaned_count = 0;
 		}
 
@@ -3573,7 +3565,7 @@ out:
 	cleaned_count = IGB_DESC_UNUSED(rx_ring);
 
 	if (cleaned_count)
-		igb_alloc_rx_buffers_adv(adapter, rx_ring, cleaned_count);
+		igb_alloc_rx_buffers_adv(rx_ring, cleaned_count);
 
 	rx_ring->total_packets += total_packets;
 	rx_ring->total_bytes += total_bytes;
@@ -3589,10 +3581,10 @@ out:
  * igb_alloc_rx_buffers_adv - Replace used receive buffers; packet split
  * @adapter: address of board private structure
  **/
-static void igb_alloc_rx_buffers_adv(struct igb_adapter *adapter,
-				     struct igb_ring *rx_ring,
+static void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring,
 				     int cleaned_count)
 {
+	struct igb_adapter *adapter = rx_ring->adapter;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	union e1000_adv_rx_desc *rx_desc;
@@ -4031,10 +4023,10 @@ static void igb_netpoll(struct net_device *netdev)
 
 	igb_irq_disable(adapter);
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		igb_clean_tx_irq(adapter, &adapter->tx_ring[i]);
+		igb_clean_tx_irq(&adapter->tx_ring[i]);
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_clean_rx_irq_adv(adapter, &adapter->rx_ring[i],
+		igb_clean_rx_irq_adv(&adapter->rx_ring[i],
 				     &work_done,
 				     adapter->rx_ring[i].napi.weight);
 


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
