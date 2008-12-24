From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 2/2] igb: re-order queues to support cleaner use of
	ivar on 82576
Date: Wed, 24 Dec 2008 14:32:01 -0800
Message-ID: <20081224223201.12176.17314.stgit@lost.foo-projects.org>
References: <20081224223142.12176.9916.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:60782 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751289AbYLXWcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 17:32:18 -0500
In-Reply-To: <20081224223142.12176.9916.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The 82576 adapter orders the queues in pairs when virtualization is in use.
The queue ordering previously conflicted with the ordering when sr-iov was
enabled.  This new ordering allows a PF to allocate 2 queues without using
any VF resources.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    3 +
 drivers/net/igb/igb_main.c |  115 +++++++++++++++++++++++++++++---------------
 2 files changed, 79 insertions(+), 39 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index c906325..5a27825 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -159,7 +159,8 @@ struct igb_ring {
 	u16 itr_register;
 	u16 cpu;
 
-	int queue_index;
+	u16 queue_index;
+	u16 reg_idx;
 	unsigned int total_bytes;
 	unsigned int total_packets;
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 4962cdf..9331e52 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -231,6 +231,40 @@ static void __exit igb_exit_module(void)
 
 module_exit(igb_exit_module);
 
+#define Q_IDX_82576(i) (((i & 0x1) << 3) + (i >> 1))
+/**
+ * igb_cache_ring_register - Descriptor ring to register mapping
+ * @adapter: board private structure to initialize
+ *
+ * Once we know the feature-set enabled for the device, we'll cache
+ * the register offset the descriptor ring is assigned to.
+ **/
+static void igb_cache_ring_register(struct igb_adapter *adapter)
+{
+	int i;
+
+	switch (adapter->hw.mac.type) {
+	case e1000_82576:
+		/* The queues are allocated for virtualization such that VF 0
+		 * is allocated queues 0 and 8, VF 1 queues 1 and 9, etc.
+		 * In order to avoid collision we start at the first free queue
+		 * and continue consuming queues in the same sequence
+		 */
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			adapter->rx_ring[i].reg_idx = Q_IDX_82576(i);
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			adapter->tx_ring[i].reg_idx = Q_IDX_82576(i);
+		break;
+	case e1000_82575:
+	default:
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			adapter->rx_ring[i].reg_idx = i;
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			adapter->tx_ring[i].reg_idx = i;
+		break;
+	}
+}
+
 /**
  * igb_alloc_queues - Allocate memory for all rings
  * @adapter: board private structure to initialize
@@ -272,6 +306,8 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 		/* set a default napi handler for each rx_ring */
 		netif_napi_add(adapter->netdev, &ring->napi, igb_poll, 64);
 	}
+
+	igb_cache_ring_register(adapter);
 	return 0;
 }
 
@@ -312,36 +348,36 @@ static void igb_assign_vector(struct igb_adapter *adapter, int rx_queue,
 		array_wr32(E1000_MSIXBM(0), msix_vector, msixbm);
 		break;
 	case e1000_82576:
-		/* The 82576 uses a table-based method for assigning vectors.
+		/* 82576 uses a table-based method for assigning vectors.
 		   Each queue has a single entry in the table to which we write
 		   a vector number along with a "valid" bit.  Sadly, the layout
 		   of the table is somewhat counterintuitive. */
 		if (rx_queue > IGB_N0_QUEUE) {
-			index = (rx_queue & 0x7);
+			index = (rx_queue >> 1);
 			ivar = array_rd32(E1000_IVAR0, index);
-			if (rx_queue < 8) {
-				/* vector goes into low byte of register */
-				ivar = ivar & 0xFFFFFF00;
-				ivar |= msix_vector | E1000_IVAR_VALID;
-			} else {
+			if (rx_queue & 0x1) {
 				/* vector goes into third byte of register */
 				ivar = ivar & 0xFF00FFFF;
 				ivar |= (msix_vector | E1000_IVAR_VALID) << 16;
+			} else {
+				/* vector goes into low byte of register */
+				ivar = ivar & 0xFFFFFF00;
+				ivar |= msix_vector | E1000_IVAR_VALID;
 			}
 			adapter->rx_ring[rx_queue].eims_value= 1 << msix_vector;
 			array_wr32(E1000_IVAR0, index, ivar);
 		}
 		if (tx_queue > IGB_N0_QUEUE) {
-			index = (tx_queue & 0x7);
+			index = (tx_queue >> 1);
 			ivar = array_rd32(E1000_IVAR0, index);
-			if (tx_queue < 8) {
-				/* vector goes into second byte of register */
-				ivar = ivar & 0xFFFF00FF;
-				ivar |= (msix_vector | E1000_IVAR_VALID) << 8;
-			} else {
+			if (tx_queue & 0x1) {
 				/* vector goes into high byte of register */
 				ivar = ivar & 0x00FFFFFF;
 				ivar |= (msix_vector | E1000_IVAR_VALID) << 24;
+			} else {
+				/* vector goes into second byte of register */
+				ivar = ivar & 0xFFFF00FF;
+				ivar |= (msix_vector | E1000_IVAR_VALID) << 8;
 			}
 			adapter->tx_ring[tx_queue].eims_value= 1 << msix_vector;
 			array_wr32(E1000_IVAR0, index, ivar);
@@ -1638,33 +1674,33 @@ static void igb_configure_tx(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 tctl;
 	u32 txdctl, txctrl;
-	int i;
+	int i, j;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		struct igb_ring *ring = &(adapter->tx_ring[i]);
-
-		wr32(E1000_TDLEN(i),
+		j = ring->reg_idx;
+		wr32(E1000_TDLEN(j),
 				ring->count * sizeof(struct e1000_tx_desc));
 		tdba = ring->dma;
-		wr32(E1000_TDBAL(i),
+		wr32(E1000_TDBAL(j),
 				tdba & 0x00000000ffffffffULL);
-		wr32(E1000_TDBAH(i), tdba >> 32);
+		wr32(E1000_TDBAH(j), tdba >> 32);
 
-		ring->head = E1000_TDH(i);
-		ring->tail = E1000_TDT(i);
+		ring->head = E1000_TDH(j);
+		ring->tail = E1000_TDT(j);
 		writel(0, hw->hw_addr + ring->tail);
 		writel(0, hw->hw_addr + ring->head);
-		txdctl = rd32(E1000_TXDCTL(i));
+		txdctl = rd32(E1000_TXDCTL(j));
 		txdctl |= E1000_TXDCTL_QUEUE_ENABLE;
-		wr32(E1000_TXDCTL(i), txdctl);
+		wr32(E1000_TXDCTL(j), txdctl);
 
 		/* Turn off Relaxed Ordering on head write-backs.  The
 		 * writebacks MUST be delivered in order or it will
 		 * completely screw up our bookeeping.
 		 */
-		txctrl = rd32(E1000_DCA_TXCTRL(i));
+		txctrl = rd32(E1000_DCA_TXCTRL(j));
 		txctrl &= ~E1000_DCA_TXCTRL_TX_WB_RO_EN;
-		wr32(E1000_DCA_TXCTRL(i), txctrl);
+		wr32(E1000_DCA_TXCTRL(j), txctrl);
 	}
 
 
@@ -1781,7 +1817,7 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl;
 	u32 srrctl = 0;
-	int i;
+	int i, j;
 
 	rctl = rd32(E1000_RCTL);
 
@@ -1839,8 +1875,10 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 		srrctl |= E1000_SRRCTL_DESCTYPE_ADV_ONEBUF;
 	}
 
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		wr32(E1000_SRRCTL(i), srrctl);
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		j = adapter->rx_ring[i].reg_idx;
+		wr32(E1000_SRRCTL(j), srrctl);
+	}
 
 	wr32(E1000_RCTL, rctl);
 }
@@ -1857,7 +1895,7 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl, rxcsum;
 	u32 rxdctl;
-	int i;
+	int i, j;
 
 	/* disable receives while setting up the descriptors */
 	rctl = rd32(E1000_RCTL);
@@ -1872,25 +1910,26 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 	 * the Base and Length of the Rx Descriptor Ring */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct igb_ring *ring = &(adapter->rx_ring[i]);
+		j = ring->reg_idx;
 		rdba = ring->dma;
-		wr32(E1000_RDBAL(i),
+		wr32(E1000_RDBAL(j),
 				rdba & 0x00000000ffffffffULL);
-		wr32(E1000_RDBAH(i), rdba >> 32);
-		wr32(E1000_RDLEN(i),
+		wr32(E1000_RDBAH(j), rdba >> 32);
+		wr32(E1000_RDLEN(j),
 			       ring->count * sizeof(union e1000_adv_rx_desc));
 
-		ring->head = E1000_RDH(i);
-		ring->tail = E1000_RDT(i);
+		ring->head = E1000_RDH(j);
+		ring->tail = E1000_RDT(j);
 		writel(0, hw->hw_addr + ring->tail);
 		writel(0, hw->hw_addr + ring->head);
 
-		rxdctl = rd32(E1000_RXDCTL(i));
+		rxdctl = rd32(E1000_RXDCTL(j));
 		rxdctl |= E1000_RXDCTL_QUEUE_ENABLE;
 		rxdctl &= 0xFFF00000;
 		rxdctl |= IGB_RX_PTHRESH;
 		rxdctl |= IGB_RX_HTHRESH << 8;
 		rxdctl |= IGB_RX_WTHRESH << 16;
-		wr32(E1000_RXDCTL(i), rxdctl);
+		wr32(E1000_RXDCTL(j), rxdctl);
 #ifdef CONFIG_IGB_LRO
 		/* Intitial LRO Settings */
 		ring->lro_mgr.max_aggr = MAX_LRO_AGGR;
@@ -1920,7 +1959,7 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 			shift = 6;
 		for (j = 0; j < (32 * 4); j++) {
 			reta.bytes[j & 3] =
-				(j % adapter->num_rx_queues) << shift;
+				adapter->rx_ring[(j % adapter->num_rx_queues)].reg_idx << shift;
 			if ((j & 3) == 3)
 				writel(reta.dword,
 				       hw->hw_addr + E1000_RETA(0) + (j & ~3));
@@ -3365,7 +3404,7 @@ static void igb_update_rx_dca(struct igb_ring *rx_ring)
 	struct igb_adapter *adapter = rx_ring->adapter;
 	struct e1000_hw *hw = &adapter->hw;
 	int cpu = get_cpu();
-	int q = rx_ring - adapter->rx_ring;
+	int q = rx_ring->reg_idx;
 
 	if (rx_ring->cpu != cpu) {
 		dca_rxctrl = rd32(E1000_DCA_RXCTRL(q));
@@ -3392,7 +3431,7 @@ static void igb_update_tx_dca(struct igb_ring *tx_ring)
 	struct igb_adapter *adapter = tx_ring->adapter;
 	struct e1000_hw *hw = &adapter->hw;
 	int cpu = get_cpu();
-	int q = tx_ring - adapter->tx_ring;
+	int q = tx_ring->reg_idx;
 
 	if (tx_ring->cpu != cpu) {
 		dca_txctrl = rd32(E1000_DCA_TXCTRL(q));

