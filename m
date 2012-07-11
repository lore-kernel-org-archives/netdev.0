From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/5] ixgbe: count q_vectors instead of MSI-X vectors
Date: Wed, 11 Jul 2012 02:09:25 -0700
Message-ID: <1341997769-22034-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1341997769-22034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65340 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753356Ab2GKJJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 05:09:32 -0400
In-Reply-To: <1341997769-22034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

It makes much more sense for us to count q_vectors instead of MSI-X
vectors.  We were using num_msix_vectors to find the number of q_vectors in
multiple places.  This was wasteful since we only had one place that
actually needs the number of MSI-X vectors and that is in slow path.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   14 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |   27 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   99 ++++++++--------------
 4 files changed, 59 insertions(+), 89 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index d1acf24..24cd510 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -315,7 +315,7 @@ struct ixgbe_ring_container {
                               ? 8 : 1)
 #define MAX_TX_PACKET_BUFFERS MAX_RX_PACKET_BUFFERS
 
-/* MAX_MSIX_Q_VECTORS of these are allocated,
+/* MAX_Q_VECTORS of these are allocated,
  * but we only use one per queue-specific vector.
  */
 struct ixgbe_q_vector {
@@ -401,11 +401,11 @@ static inline u16 ixgbe_desc_unused(struct ixgbe_ring *ring)
 #define NON_Q_VECTORS (OTHER_VECTOR)
 
 #define MAX_MSIX_VECTORS_82599 64
-#define MAX_MSIX_Q_VECTORS_82599 64
+#define MAX_Q_VECTORS_82599 64
 #define MAX_MSIX_VECTORS_82598 18
-#define MAX_MSIX_Q_VECTORS_82598 16
+#define MAX_Q_VECTORS_82598 16
 
-#define MAX_MSIX_Q_VECTORS MAX_MSIX_Q_VECTORS_82599
+#define MAX_Q_VECTORS MAX_Q_VECTORS_82599
 #define MAX_MSIX_COUNT MAX_MSIX_VECTORS_82599
 
 #define MIN_MSIX_Q_VECTORS 1
@@ -496,7 +496,7 @@ struct ixgbe_adapter {
 	u32 alloc_rx_page_failed;
 	u32 alloc_rx_buff_failed;
 
-	struct ixgbe_q_vector *q_vector[MAX_MSIX_Q_VECTORS];
+	struct ixgbe_q_vector *q_vector[MAX_Q_VECTORS];
 
 	/* DCB parameters */
 	struct ieee_pfc *ixgbe_ieee_pfc;
@@ -507,8 +507,8 @@ struct ixgbe_adapter {
 	u8 dcbx_cap;
 	enum ixgbe_fc_mode last_lfc_mode;
 
-	int num_msix_vectors;
-	int max_msix_q_vectors;         /* true count of q_vectors for device */
+	int num_q_vectors;	/* current number of q_vectors for device */
+	int max_q_vectors;	/* true count of q_vectors for device */
 	struct ixgbe_ring_feature ring_feature[RING_F_ARRAY_SIZE];
 	struct msix_entry *msix_entries;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index bbc7da5..8e1be50 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2090,7 +2090,6 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_q_vector *q_vector;
 	int i;
-	int num_vectors;
 	u16 tx_itr_param, rx_itr_param;
 	bool need_reset = false;
 
@@ -2126,12 +2125,7 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	/* check the old value and enable RSC if necessary */
 	need_reset = ixgbe_update_rsc(adapter);
 
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
-		num_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-	else
-		num_vectors = 1;
-
-	for (i = 0; i < num_vectors; i++) {
+	for (i = 0; i < adapter->num_q_vectors; i++) {
 		q_vector = adapter->q_vector[i];
 		if (q_vector->tx.count && !q_vector->rx.count)
 			/* tx only */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index f36c3c3..39a80d2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -507,8 +507,8 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 		 * of max_msix_q_vectors + NON_Q_VECTORS, or the number of
 		 * vectors we were allocated.
 		 */
-		adapter->num_msix_vectors = min(vectors,
-				   adapter->max_msix_q_vectors + NON_Q_VECTORS);
+		vectors -= NON_Q_VECTORS;
+		adapter->num_q_vectors = min(vectors, adapter->max_q_vectors);
 	}
 }
 
@@ -695,7 +695,7 @@ static void ixgbe_free_q_vector(struct ixgbe_adapter *adapter, int v_idx)
  **/
 static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 {
-	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+	int q_vectors = adapter->num_q_vectors;
 	int rxr_remaining = adapter->num_rx_queues;
 	int txr_remaining = adapter->num_tx_queues;
 	int rxr_idx = 0, txr_idx = 0, v_idx = 0;
@@ -739,10 +739,12 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 	return 0;
 
 err_out:
-	while (v_idx) {
-		v_idx--;
+	adapter->num_tx_queues = 0;
+	adapter->num_rx_queues = 0;
+	adapter->num_q_vectors = 0;
+
+	while (v_idx--)
 		ixgbe_free_q_vector(adapter, v_idx);
-	}
 
 	return -ENOMEM;
 }
@@ -757,14 +759,13 @@ err_out:
  **/
 static void ixgbe_free_q_vectors(struct ixgbe_adapter *adapter)
 {
-	int v_idx, q_vectors;
+	int v_idx = adapter->num_q_vectors;
 
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
-		q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-	else
-		q_vectors = 1;
+	adapter->num_tx_queues = 0;
+	adapter->num_rx_queues = 0;
+	adapter->num_q_vectors = 0;
 
-	for (v_idx = 0; v_idx < q_vectors; v_idx++)
+	while (v_idx--)
 		ixgbe_free_q_vector(adapter, v_idx);
 }
 
@@ -844,6 +845,8 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	if (err)
 		return err;
 
+	adapter->num_q_vectors = 1;
+
 	err = pci_enable_msi(adapter->pdev);
 	if (!err) {
 		adapter->flags |= IXGBE_FLAG_MSI_ENABLED;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 59a3f14..903d165 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -993,7 +993,6 @@ out_no_update:
 
 static void ixgbe_setup_dca(struct ixgbe_adapter *adapter)
 {
-	int num_q_vectors;
 	int i;
 
 	if (!(adapter->flags & IXGBE_FLAG_DCA_ENABLED))
@@ -1002,12 +1001,7 @@ static void ixgbe_setup_dca(struct ixgbe_adapter *adapter)
 	/* always use CB2 mode, difference is masked in the CB driver */
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 2);
 
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
-		num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-	else
-		num_q_vectors = 1;
-
-	for (i = 0; i < num_q_vectors; i++) {
+	for (i = 0; i < adapter->num_q_vectors; i++) {
 		adapter->q_vector[i]->cpu = -1;
 		ixgbe_update_dca(adapter->q_vector[i]);
 	}
@@ -1831,11 +1825,9 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_q_vector *q_vector;
-	int q_vectors, v_idx;
+	int v_idx;
 	u32 mask;
 
-	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-
 	/* Populate MSIX to EITR Select */
 	if (adapter->num_vfs > 32) {
 		u32 eitrsel = (1 << (adapter->num_vfs - 32)) - 1;
@@ -1846,7 +1838,7 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 	 * Populate the IVAR table and set the ITR values to the
 	 * corresponding register.
 	 */
-	for (v_idx = 0; v_idx < q_vectors; v_idx++) {
+	for (v_idx = 0; v_idx < adapter->num_q_vectors; v_idx++) {
 		struct ixgbe_ring *ring;
 		q_vector = adapter->q_vector[v_idx];
 
@@ -2410,11 +2402,10 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 	int vector, err;
 	int ri = 0, ti = 0;
 
-	for (vector = 0; vector < q_vectors; vector++) {
+	for (vector = 0; vector < adapter->num_q_vectors; vector++) {
 		struct ixgbe_q_vector *q_vector = adapter->q_vector[vector];
 		struct msix_entry *entry = &adapter->msix_entries[vector];
 
@@ -2569,30 +2560,28 @@ static int ixgbe_request_irq(struct ixgbe_adapter *adapter)
 
 static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 {
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-		int i, q_vectors;
+	int vector;
 
-		q_vectors = adapter->num_msix_vectors;
-		i = q_vectors - 1;
-		free_irq(adapter->msix_entries[i].vector, adapter);
-		i--;
+	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED)) {
+		free_irq(adapter->pdev->irq, adapter);
+		return;
+	}
 
-		for (; i >= 0; i--) {
-			/* free only the irqs that were actually requested */
-			if (!adapter->q_vector[i]->rx.ring &&
-			    !adapter->q_vector[i]->tx.ring)
-				continue;
+	for (vector = 0; vector < adapter->num_q_vectors; vector++) {
+		struct ixgbe_q_vector *q_vector = adapter->q_vector[vector];
+		struct msix_entry *entry = &adapter->msix_entries[vector];
 
-			/* clear the affinity_mask in the IRQ descriptor */
-			irq_set_affinity_hint(adapter->msix_entries[i].vector,
-					      NULL);
+		/* free only the irqs that were actually requested */
+		if (!q_vector->rx.ring && !q_vector->tx.ring)
+			continue;
 
-			free_irq(adapter->msix_entries[i].vector,
-				 adapter->q_vector[i]);
-		}
-	} else {
-		free_irq(adapter->pdev->irq, adapter);
+		/* clear the affinity_mask in the IRQ descriptor */
+		irq_set_affinity_hint(entry->vector, NULL);
+
+		free_irq(entry->vector, q_vector);
 	}
+
+	free_irq(adapter->msix_entries[vector++].vector, adapter);
 }
 
 /**
@@ -2616,9 +2605,12 @@ static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
 	}
 	IXGBE_WRITE_FLUSH(&adapter->hw);
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-		int i;
-		for (i = 0; i < adapter->num_msix_vectors; i++)
-			synchronize_irq(adapter->msix_entries[i].vector);
+		int vector;
+
+		for (vector = 0; vector < adapter->num_q_vectors; vector++)
+			synchronize_irq(adapter->msix_entries[vector].vector);
+
+		synchronize_irq(adapter->msix_entries[vector++].vector);
 	} else {
 		synchronize_irq(adapter->pdev->irq);
 	}
@@ -3561,33 +3553,17 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
 {
 	int q_idx;
-	struct ixgbe_q_vector *q_vector;
-	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-
-	/* legacy and MSI only use one vector */
-	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED))
-		q_vectors = 1;
 
-	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
-		q_vector = adapter->q_vector[q_idx];
-		napi_enable(&q_vector->napi);
-	}
+	for (q_idx = 0; q_idx < adapter->num_q_vectors; q_idx++)
+		napi_enable(&adapter->q_vector[q_idx]->napi);
 }
 
 static void ixgbe_napi_disable_all(struct ixgbe_adapter *adapter)
 {
 	int q_idx;
-	struct ixgbe_q_vector *q_vector;
-	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 
-	/* legacy and MSI only use one vector */
-	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED))
-		q_vectors = 1;
-
-	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
-		q_vector = adapter->q_vector[q_idx];
-		napi_disable(&q_vector->napi);
-	}
+	for (q_idx = 0; q_idx < adapter->num_q_vectors; q_idx++)
+		napi_disable(&adapter->q_vector[q_idx]->napi);
 }
 
 #ifdef CONFIG_IXGBE_DCB
@@ -4416,12 +4392,12 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	case ixgbe_mac_82598EB:
 		if (hw->device_id == IXGBE_DEV_ID_82598AT)
 			adapter->flags |= IXGBE_FLAG_FAN_FAIL_CAPABLE;
-		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82598;
+		adapter->max_q_vectors = MAX_Q_VECTORS_82598;
 		break;
 	case ixgbe_mac_X540:
 		adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_CAPABLE;
 	case ixgbe_mac_82599EB:
-		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82599;
+		adapter->max_q_vectors = MAX_Q_VECTORS_82599;
 		adapter->flags2 |= IXGBE_FLAG2_RSC_CAPABLE;
 		adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
 		if (hw->device_id == IXGBE_DEV_ID_82599_T3_LOM)
@@ -5313,7 +5289,7 @@ static void ixgbe_check_hang_subtask(struct ixgbe_adapter *adapter)
 			(IXGBE_EICS_TCP_TIMER | IXGBE_EICS_OTHER));
 	} else {
 		/* get one bit for every active tx/rx interrupt vector */
-		for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++) {
+		for (i = 0; i < adapter->num_q_vectors; i++) {
 			struct ixgbe_q_vector *qv = adapter->q_vector[i];
 			if (qv->rx.ring || qv->tx.ring)
 				eics |= ((u64)1 << i);
@@ -6525,11 +6501,8 @@ static void ixgbe_netpoll(struct net_device *netdev)
 
 	adapter->flags |= IXGBE_FLAG_IN_NETPOLL;
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-		int num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-		for (i = 0; i < num_q_vectors; i++) {
-			struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
-			ixgbe_msix_clean_rings(0, q_vector);
-		}
+		for (i = 0; i < adapter->num_q_vectors; i++)
+			ixgbe_msix_clean_rings(0, adapter->q_vector[i]);
 	} else {
 		ixgbe_intr(adapter->pdev->irq, netdev);
 	}
-- 
1.7.10.4
