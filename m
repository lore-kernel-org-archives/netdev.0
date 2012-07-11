From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/5] ixgbe: Add feature offset value to ring features
Date: Wed, 11 Jul 2012 02:09:27 -0700
Message-ID: <1341997769-22034-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1341997769-22034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47130 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753957Ab2GKJJi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 05:09:38 -0400
In-Reply-To: <1341997769-22034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The mask value for ring features was overloaded for FCoE which can lead to
some confusion.  In order to avoid any confusion I am splitting the mask
value and adding an offset value.  This can be used for the start of the
FCoE rings, and in the future I hope to use it to store the start of the
registers for SR-IOV.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |    6 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |   23 ++++++++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 4 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index ae3da83..2ffdc8f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -280,7 +280,8 @@ enum ixgbe_ring_f_enum {
 struct ixgbe_ring_feature {
 	u16 limit;	/* upper limit on feature indices */
 	u16 indices;	/* current value of indices */
-	int mask;
+	u16 mask;	/* Mask used for feature to ring mapping */
+	u16 offset;	/* offset to start of feature */
 } ____cacheline_internodealigned_in_smp;
 
 /*
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index b4da760..0922ece 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -674,7 +674,7 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 	if (adapter->ring_feature[RING_F_FCOE].indices) {
 		/* Use multiple rx queues for FCoE by redirection table */
 		for (i = 0; i < IXGBE_FCRETA_SIZE; i++) {
-			fcoe_i = f->mask + i % f->indices;
+			fcoe_i = f->offset + i % f->indices;
 			fcoe_i &= IXGBE_FCRETA_ENTRY_MASK;
 			fcoe_q = adapter->rx_ring[fcoe_i]->reg_idx;
 			IXGBE_WRITE_REG(hw, IXGBE_FCRETA(i), fcoe_q);
@@ -683,7 +683,7 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FCOE), 0);
 	} else  {
 		/* Use single rx queue for FCoE */
-		fcoe_i = f->mask;
+		fcoe_i = f->offset;
 		fcoe_q = adapter->rx_ring[fcoe_i]->reg_idx;
 		IXGBE_WRITE_REG(hw, IXGBE_FCRECTL, 0);
 		IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FCOE),
@@ -691,7 +691,7 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 				(fcoe_q << IXGBE_ETQS_RX_QUEUE_SHIFT));
 	}
 	/* send FIP frames to the first FCoE queue */
-	fcoe_i = f->mask;
+	fcoe_i = f->offset;
 	fcoe_q = adapter->rx_ring[fcoe_i]->reg_idx;
 	IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FIP),
 			IXGBE_ETQS_QUEUE_EN |
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index b64588a..47e54e8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -185,12 +185,12 @@ static inline bool ixgbe_cache_ring_fcoe(struct ixgbe_adapter *adapter)
 		else
 			ixgbe_cache_ring_rss(adapter);
 
-		fcoe_rx_i = f->mask;
-		fcoe_tx_i = f->mask;
+		fcoe_rx_i = f->offset;
+		fcoe_tx_i = f->offset;
 	}
 	for (i = 0; i < f->indices; i++, fcoe_rx_i++, fcoe_tx_i++) {
-		adapter->rx_ring[f->mask + i]->reg_idx = fcoe_rx_i;
-		adapter->tx_ring[f->mask + i]->reg_idx = fcoe_tx_i;
+		adapter->rx_ring[f->offset + i]->reg_idx = fcoe_rx_i;
+		adapter->tx_ring[f->offset + i]->reg_idx = fcoe_tx_i;
 	}
 	return true;
 }
@@ -327,10 +327,7 @@ static inline bool ixgbe_set_fdir_queues(struct ixgbe_adapter *adapter)
  * @adapter: board private structure to initialize
  *
  * FCoE RX FCRETA can use up to 8 rx queues for up to 8 different exchanges.
- * The ring feature mask is not used as a mask for FCoE, as it can take any 8
- * rx queues out of the max number of rx queues, instead, it is used as the
- * index of the first rx queue used by FCoE.
- *
+ * Offset is used as the index of the first rx queue used by FCoE.
  **/
 static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
 {
@@ -353,7 +350,7 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
 	}
 
 	/* adding FCoE rx rings to the end */
-	f->mask = adapter->num_rx_queues;
+	f->offset = adapter->num_rx_queues;
 	adapter->num_rx_queues += f->indices;
 	adapter->num_tx_queues += f->indices;
 
@@ -388,7 +385,7 @@ static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 
 #ifdef IXGBE_FCOE
 	/* FCoE enabled queues require special configuration indexed
-	 * by feature specific indices and mask. Here we map FCoE
+	 * by feature specific indices and offset. Here we map FCoE
 	 * indices onto the DCB queue pairs allowing FCoE to own
 	 * configuration later.
 	 */
@@ -401,7 +398,7 @@ static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 		ixgbe_dcb_unpack_map(&adapter->dcb_cfg, DCB_TX_CONFIG, prio_tc);
 		tc = prio_tc[adapter->fcoe.up];
 		f->indices = dev->tc_to_txq[tc].count;
-		f->mask = dev->tc_to_txq[tc].offset;
+		f->offset = dev->tc_to_txq[tc].offset;
 	}
 #endif
 
@@ -632,8 +629,8 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 		if (adapter->netdev->features & NETIF_F_FCOE_MTU) {
 			struct ixgbe_ring_feature *f;
 			f = &adapter->ring_feature[RING_F_FCOE];
-			if ((rxr_idx >= f->mask) &&
-			    (rxr_idx < f->mask + f->indices))
+			if ((rxr_idx >= f->offset) &&
+			    (rxr_idx < f->offset + f->indices))
 				set_bit(__IXGBE_RX_FCOE, &ring->state);
 		}
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 8e83f15..3a807ff 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6211,7 +6211,7 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 
 		while (txq >= f->indices)
 			txq -= f->indices;
-		txq += adapter->ring_feature[RING_F_FCOE].mask;
+		txq += adapter->ring_feature[RING_F_FCOE].offset;
 
 		return txq;
 	}
-- 
1.7.10.4
