From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/5] ixgbe: make q_vectors dynamic to reduce
	netdev size
Date: Wed, 06 May 2009 13:43:28 -0700
Message-ID: <20090506204317.18071.96421.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:56858
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761676AbZEFUnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:43:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Currently the q_vectors are being allocated statically inside of the
adapter struct.  This increases the overall size of the adapter struct when
we can easily allocate the vectors dynamically.  This patch changes that
behavior so that the q_vectors are allocated dynamically and the napi
structures are automatically allocated inside of the q_vectors as needed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    5 -
 drivers/net/ixgbe/ixgbe_dcb_nl.c  |   16 --
 drivers/net/ixgbe/ixgbe_ethtool.c |    2 
 drivers/net/ixgbe/ixgbe_main.c    |  268 +++++++++++++++++++++----------------
 4 files changed, 158 insertions(+), 133 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 4b44a8e..61cb415 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -187,6 +187,7 @@ struct ixgbe_q_vector {
 	u8 tx_itr;
 	u8 rx_itr;
 	u32 eitr;
+	u32 v_idx;        /* vector index in list */
 };
 
 /* Helper macros to switch between ints/sec and what the register uses.
@@ -230,7 +231,7 @@ struct ixgbe_adapter {
 	struct vlan_group *vlgrp;
 	u16 bd_number;
 	struct work_struct reset_task;
-	struct ixgbe_q_vector q_vector[MAX_MSIX_Q_VECTORS];
+	struct ixgbe_q_vector *q_vector[MAX_MSIX_Q_VECTORS];
 	char name[MAX_MSIX_COUNT][IFNAMSIZ + 9];
 	struct ixgbe_dcb_config dcb_cfg;
 	struct ixgbe_dcb_config temp_dcb_cfg;
@@ -367,8 +368,8 @@ extern int ixgbe_setup_tx_resources(struct ixgbe_adapter *, struct ixgbe_ring *)
 extern void ixgbe_free_rx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
 extern void ixgbe_free_tx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
 extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
-extern void ixgbe_reset_interrupt_capability(struct ixgbe_adapter *adapter);
 extern int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
+extern void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter);
 void ixgbe_napi_add_all(struct ixgbe_adapter *adapter);
 void ixgbe_napi_del_all(struct ixgbe_adapter *adapter);
 extern void ixgbe_write_eitr(struct ixgbe_adapter *, int, u32);
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index bd0a0c2..99e0c10 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -124,13 +124,7 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 
 		if (netif_running(netdev))
 			netdev->netdev_ops->ndo_stop(netdev);
-		ixgbe_reset_interrupt_capability(adapter);
-		ixgbe_napi_del_all(adapter);
-		INIT_LIST_HEAD(&netdev->napi_list);
-		kfree(adapter->tx_ring);
-		kfree(adapter->rx_ring);
-		adapter->tx_ring = NULL;
-		adapter->rx_ring = NULL;
+		ixgbe_clear_interrupt_scheme(adapter);
 
 		adapter->hw.fc.requested_mode = ixgbe_fc_pfc;
 		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
@@ -144,13 +138,7 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			adapter->hw.fc.requested_mode = ixgbe_fc_default;
 			if (netif_running(netdev))
 				netdev->netdev_ops->ndo_stop(netdev);
-			ixgbe_reset_interrupt_capability(adapter);
-			ixgbe_napi_del_all(adapter);
-			INIT_LIST_HEAD(&netdev->napi_list);
-			kfree(adapter->tx_ring);
-			kfree(adapter->rx_ring);
-			adapter->tx_ring = NULL;
-			adapter->rx_ring = NULL;
+			ixgbe_clear_interrupt_scheme(adapter);
 
 			adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
 			adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index d822c92..c0167d6 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1114,7 +1114,7 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	}
 
 	for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++) {
-		struct ixgbe_q_vector *q_vector = &adapter->q_vector[i];
+		struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
 		if (q_vector->txr_count && !q_vector->rxr_count)
 			/* tx vector gets half the rate */
 			q_vector->eitr = (adapter->eitr_param >> 1);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index be5eabc..165bfa6 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -468,7 +468,7 @@ static void ixgbe_receive_skb(struct ixgbe_q_vector *q_vector,
 	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
 	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
-	skb_record_rx_queue(skb, q_vector - &adapter->q_vector[0]);
+	skb_record_rx_queue(skb, q_vector->v_idx);
 	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
 		if (adapter->vlgrp && is_vlan && (tag != 0))
 			vlan_gro_receive(napi, adapter->vlgrp, tag, skb);
@@ -835,7 +835,7 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 	 * corresponding register.
 	 */
 	for (v_idx = 0; v_idx < q_vectors; v_idx++) {
-		q_vector = &adapter->q_vector[v_idx];
+		q_vector = adapter->q_vector[v_idx];
 		/* XXX for_each_bit(...) */
 		r_idx = find_first_bit(q_vector->rxr_idx,
 		                       adapter->num_rx_queues);
@@ -984,8 +984,7 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	u32 new_itr;
 	u8 current_itr, ret_itr;
-	int i, r_idx, v_idx = ((void *)q_vector - (void *)(adapter->q_vector)) /
-	                       sizeof(struct ixgbe_q_vector);
+	int i, r_idx, v_idx = q_vector->v_idx;
 	struct ixgbe_ring *rx_ring, *tx_ring;
 
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
@@ -1303,19 +1302,21 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
                                      int r_idx)
 {
-	a->q_vector[v_idx].adapter = a;
-	set_bit(r_idx, a->q_vector[v_idx].rxr_idx);
-	a->q_vector[v_idx].rxr_count++;
+	struct ixgbe_q_vector *q_vector = a->q_vector[v_idx];
+
+	set_bit(r_idx, q_vector->rxr_idx);
+	q_vector->rxr_count++;
 	a->rx_ring[r_idx].v_idx = 1 << v_idx;
 }
 
 static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
-                                     int r_idx)
+                                     int t_idx)
 {
-	a->q_vector[v_idx].adapter = a;
-	set_bit(r_idx, a->q_vector[v_idx].txr_idx);
-	a->q_vector[v_idx].txr_count++;
-	a->tx_ring[r_idx].v_idx = 1 << v_idx;
+	struct ixgbe_q_vector *q_vector = a->q_vector[v_idx];
+
+	set_bit(t_idx, q_vector->txr_idx);
+	q_vector->txr_count++;
+	a->tx_ring[t_idx].v_idx = 1 << v_idx;
 }
 
 /**
@@ -1411,7 +1412,7 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
                          (!(_v)->txr_count) ? &ixgbe_msix_clean_rx : \
                          &ixgbe_msix_clean_many)
 	for (vector = 0; vector < q_vectors; vector++) {
-		handler = SET_HANDLER(&adapter->q_vector[vector]);
+		handler = SET_HANDLER(adapter->q_vector[vector]);
 
 		if(handler == &ixgbe_msix_clean_rx) {
 			sprintf(adapter->name[vector], "%s-%s-%d",
@@ -1427,7 +1428,7 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 
 		err = request_irq(adapter->msix_entries[vector].vector,
 		                  handler, 0, adapter->name[vector],
-		                  &(adapter->q_vector[vector]));
+		                  adapter->q_vector[vector]);
 		if (err) {
 			DPRINTK(PROBE, ERR,
 			        "request_irq failed for MSIX interrupt "
@@ -1450,7 +1451,7 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 free_queue_irqs:
 	for (i = vector - 1; i >= 0; i--)
 		free_irq(adapter->msix_entries[--vector].vector,
-		         &(adapter->q_vector[i]));
+		         adapter->q_vector[i]);
 	adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
 	pci_disable_msix(adapter->pdev);
 	kfree(adapter->msix_entries);
@@ -1461,7 +1462,7 @@ out:
 
 static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 {
-	struct ixgbe_q_vector *q_vector = adapter->q_vector;
+	struct ixgbe_q_vector *q_vector = adapter->q_vector[0];
 	u8 current_itr;
 	u32 new_itr = q_vector->eitr;
 	struct ixgbe_ring *rx_ring = &adapter->rx_ring[0];
@@ -1539,6 +1540,7 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	struct net_device *netdev = data;
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_q_vector *q_vector = adapter->q_vector[0];
 	u32 eicr;
 
 	/*
@@ -1566,13 +1568,13 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 
 	ixgbe_check_fan_failure(adapter, eicr);
 
-	if (napi_schedule_prep(&adapter->q_vector[0].napi)) {
+	if (napi_schedule_prep(&(q_vector->napi))) {
 		adapter->tx_ring[0].total_packets = 0;
 		adapter->tx_ring[0].total_bytes = 0;
 		adapter->rx_ring[0].total_packets = 0;
 		adapter->rx_ring[0].total_bytes = 0;
 		/* would disable interrupts here but EIAM disabled it */
-		__napi_schedule(&adapter->q_vector[0].napi);
+		__napi_schedule(&(q_vector->napi));
 	}
 
 	return IRQ_HANDLED;
@@ -1583,7 +1585,7 @@ static inline void ixgbe_reset_q_vectors(struct ixgbe_adapter *adapter)
 	int i, q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 
 	for (i = 0; i < q_vectors; i++) {
-		struct ixgbe_q_vector *q_vector = &adapter->q_vector[i];
+		struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
 		bitmap_zero(q_vector->rxr_idx, MAX_RX_QUEUES);
 		bitmap_zero(q_vector->txr_idx, MAX_TX_QUEUES);
 		q_vector->rxr_count = 0;
@@ -1634,7 +1636,7 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 		i--;
 		for (; i >= 0; i--) {
 			free_irq(adapter->msix_entries[i].vector,
-			         &(adapter->q_vector[i]));
+			         adapter->q_vector[i]);
 		}
 
 		ixgbe_reset_q_vectors(adapter);
@@ -2135,7 +2137,7 @@ static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
 
 	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
 		struct napi_struct *napi;
-		q_vector = &adapter->q_vector[q_idx];
+		q_vector = adapter->q_vector[q_idx];
 		if (!q_vector->rxr_count)
 			continue;
 		napi = &q_vector->napi;
@@ -2158,7 +2160,7 @@ static void ixgbe_napi_disable_all(struct ixgbe_adapter *adapter)
 		q_vectors = 1;
 
 	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
-		q_vector = &adapter->q_vector[q_idx];
+		q_vector = adapter->q_vector[q_idx];
 		if (!q_vector->rxr_count)
 			continue;
 		napi_disable(&q_vector->napi);
@@ -2498,8 +2500,6 @@ int ixgbe_up(struct ixgbe_adapter *adapter)
 	/* hardware has been reset, we need to reload some things */
 	ixgbe_configure(adapter);
 
-	ixgbe_napi_add_all(adapter);
-
 	return ixgbe_up_complete(adapter);
 }
 
@@ -2877,9 +2877,6 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 		adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
 		kfree(adapter->msix_entries);
 		adapter->msix_entries = NULL;
-		adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
-		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
-		ixgbe_set_num_queues(adapter);
 	} else {
 		adapter->flags |= IXGBE_FLAG_MSIX_ENABLED; /* Woot! */
 		/*
@@ -3103,31 +3100,20 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	 * mean we disable MSI-X capabilities of the adapter. */
 	adapter->msix_entries = kcalloc(v_budget,
 	                                sizeof(struct msix_entry), GFP_KERNEL);
-	if (!adapter->msix_entries) {
-		adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
-		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
-		ixgbe_set_num_queues(adapter);
-		kfree(adapter->tx_ring);
-		kfree(adapter->rx_ring);
-		err = ixgbe_alloc_queues(adapter);
-		if (err) {
-			DPRINTK(PROBE, ERR, "Unable to allocate memory "
-			        "for queues\n");
-			goto out;
-		}
-
-		goto try_msi;
-	}
+	if (adapter->msix_entries) {
+		for (vector = 0; vector < v_budget; vector++)
+			adapter->msix_entries[vector].entry = vector;
 
-	for (vector = 0; vector < v_budget; vector++)
-		adapter->msix_entries[vector].entry = vector;
+		ixgbe_acquire_msix_vectors(adapter, v_budget);
 
-	ixgbe_acquire_msix_vectors(adapter, v_budget);
+		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
+			goto out;
+	}
 
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
-		goto out;
+	adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
+	adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
+	ixgbe_set_num_queues(adapter);
 
-try_msi:
 	err = pci_enable_msi(adapter->pdev);
 	if (!err) {
 		adapter->flags |= IXGBE_FLAG_MSI_ENABLED;
@@ -3142,6 +3128,87 @@ out:
 	return err;
 }
 
+/**
+ * ixgbe_alloc_q_vectors - Allocate memory for interrupt vectors
+ * @adapter: board private structure to initialize
+ *
+ * We allocate one q_vector per queue interrupt.  If allocation fails we
+ * return -ENOMEM.
+ **/
+static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
+{
+	int q_idx, num_q_vectors;
+	struct ixgbe_q_vector *q_vector;
+	int napi_vectors;
+	int (*poll)(struct napi_struct *, int);
+
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+		num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+		napi_vectors = adapter->num_rx_queues;
+		poll = &ixgbe_clean_rxonly;
+	} else {
+		num_q_vectors = 1;
+		napi_vectors = 1;
+		poll = &ixgbe_poll;
+	}
+
+	for (q_idx = 0; q_idx < num_q_vectors; q_idx++) {
+		q_vector = kzalloc(sizeof(struct ixgbe_q_vector), GFP_KERNEL);
+		if (!q_vector)
+			goto err_out;
+		q_vector->adapter = adapter;
+		q_vector->v_idx = q_idx;
+		q_vector->eitr = adapter->eitr_param;
+		if (q_idx < napi_vectors)
+			netif_napi_add(adapter->netdev, &q_vector->napi,
+			               (*poll), 64);
+		adapter->q_vector[q_idx] = q_vector;
+	}
+
+	return 0;
+
+err_out:
+	while (q_idx) {
+		q_idx--;
+		q_vector = adapter->q_vector[q_idx];
+		netif_napi_del(&q_vector->napi);
+		kfree(q_vector);
+		adapter->q_vector[q_idx] = NULL;
+	}
+	return -ENOMEM;
+}
+
+/**
+ * ixgbe_free_q_vectors - Free memory allocated for interrupt vectors
+ * @adapter: board private structure to initialize
+ *
+ * This function frees the memory allocated to the q_vectors.  In addition if
+ * NAPI is enabled it will delete any references to the NAPI struct prior
+ * to freeing the q_vector.
+ **/
+static void ixgbe_free_q_vectors(struct ixgbe_adapter *adapter)
+{
+	int q_idx, num_q_vectors;
+	int napi_vectors;
+
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+		num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+		napi_vectors = adapter->num_rx_queues;
+	} else {
+		num_q_vectors = 1;
+		napi_vectors = 1;
+	}
+
+	for (q_idx = 0; q_idx < num_q_vectors; q_idx++) {
+		struct ixgbe_q_vector *q_vector = adapter->q_vector[q_idx];
+
+		adapter->q_vector[q_idx] = NULL;
+		if (q_idx < napi_vectors)
+			netif_napi_del(&q_vector->napi);
+		kfree(q_vector);
+	}
+}
+
 void ixgbe_reset_interrupt_capability(struct ixgbe_adapter *adapter)
 {
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
@@ -3173,18 +3240,25 @@ int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
 	/* Number of supported queues */
 	ixgbe_set_num_queues(adapter);
 
-	err = ixgbe_alloc_queues(adapter);
-	if (err) {
-		DPRINTK(PROBE, ERR, "Unable to allocate memory for queues\n");
-		goto err_alloc_queues;
-	}
-
 	err = ixgbe_set_interrupt_capability(adapter);
 	if (err) {
 		DPRINTK(PROBE, ERR, "Unable to setup interrupt capabilities\n");
 		goto err_set_interrupt;
 	}
 
+	err = ixgbe_alloc_q_vectors(adapter);
+	if (err) {
+		DPRINTK(PROBE, ERR, "Unable to allocate memory for queue "
+		        "vectors\n");
+		goto err_alloc_q_vectors;
+	}
+
+	err = ixgbe_alloc_queues(adapter);
+	if (err) {
+		DPRINTK(PROBE, ERR, "Unable to allocate memory for queues\n");
+		goto err_alloc_queues;
+	}
+
 	DPRINTK(DRV, INFO, "Multiqueue %s: Rx Queue count = %u, "
 	        "Tx Queue count = %u\n",
 	        (adapter->num_rx_queues > 1) ? "Enabled" :
@@ -3194,11 +3268,30 @@ int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
 
 	return 0;
 
+err_alloc_queues:
+	ixgbe_free_q_vectors(adapter);
+err_alloc_q_vectors:
+	ixgbe_reset_interrupt_capability(adapter);
 err_set_interrupt:
+	return err;
+}
+
+/**
+ * ixgbe_clear_interrupt_scheme - Clear the current interrupt scheme settings
+ * @adapter: board private structure to clear interrupt scheme on
+ *
+ * We go through and clear interrupt specific resources and reset the structure
+ * to pre-load conditions
+ **/
+void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter)
+{
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
-err_alloc_queues:
-	return err;
+	adapter->tx_ring = NULL;
+	adapter->rx_ring = NULL;
+
+	ixgbe_free_q_vectors(adapter);
+	ixgbe_reset_interrupt_capability(adapter);
 }
 
 /**
@@ -3619,8 +3712,6 @@ static int ixgbe_open(struct net_device *netdev)
 
 	ixgbe_configure(adapter);
 
-	ixgbe_napi_add_all(adapter);
-
 	err = ixgbe_request_irq(adapter);
 	if (err)
 		goto err_req_irq;
@@ -3672,55 +3763,6 @@ static int ixgbe_close(struct net_device *netdev)
 	return 0;
 }
 
-/**
- * ixgbe_napi_add_all - prep napi structs for use
- * @adapter: private struct
- *
- * helper function to napi_add each possible q_vector->napi
- */
-void ixgbe_napi_add_all(struct ixgbe_adapter *adapter)
-{
-	int q_idx, q_vectors;
-	struct net_device *netdev = adapter->netdev;
-	int (*poll)(struct napi_struct *, int);
-
-	/* check if we already have our netdev->napi_list populated */
-	if (&netdev->napi_list != netdev->napi_list.next)
-		return;
-
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-		poll = &ixgbe_clean_rxonly;
-		/* Only enable as many vectors as we have rx queues. */
-		q_vectors = adapter->num_rx_queues;
-	} else {
-		poll = &ixgbe_poll;
-		/* only one q_vector for legacy modes */
-		q_vectors = 1;
-	}
-
-	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
-		struct ixgbe_q_vector *q_vector = &adapter->q_vector[q_idx];
-		netif_napi_add(adapter->netdev, &q_vector->napi, (*poll), 64);
-	}
-}
-
-void ixgbe_napi_del_all(struct ixgbe_adapter *adapter)
-{
-	int q_idx;
-	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-
-	/* legacy and MSI only use one vector */
-	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED))
-		q_vectors = 1;
-
-	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
-		struct ixgbe_q_vector *q_vector = &adapter->q_vector[q_idx];
-		if (!q_vector->rxr_count)
-			continue;
-		netif_napi_del(&q_vector->napi);
-	}
-}
-
 #ifdef CONFIG_PM
 static int ixgbe_resume(struct pci_dev *pdev)
 {
@@ -3782,11 +3824,7 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 		ixgbe_free_all_tx_resources(adapter);
 		ixgbe_free_all_rx_resources(adapter);
 	}
-	ixgbe_reset_interrupt_capability(adapter);
-	ixgbe_napi_del_all(adapter);
-	INIT_LIST_HEAD(&netdev->napi_list);
-	kfree(adapter->tx_ring);
-	kfree(adapter->rx_ring);
+	ixgbe_clear_interrupt_scheme(adapter);
 
 #ifdef CONFIG_PM
 	retval = pci_save_state(pdev);
@@ -5012,8 +5050,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 err_register:
 	ixgbe_release_hw_control(adapter);
 err_hw_init:
+	ixgbe_clear_interrupt_scheme(adapter);
 err_sw_init:
-	ixgbe_reset_interrupt_capability(adapter);
 err_eeprom:
 	clear_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
 	del_timer_sync(&adapter->sfp_timer);
@@ -5071,7 +5109,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	if (netdev->reg_state == NETREG_REGISTERED)
 		unregister_netdev(netdev);
 
-	ixgbe_reset_interrupt_capability(adapter);
+	ixgbe_clear_interrupt_scheme(adapter);
 
 	ixgbe_release_hw_control(adapter);
 
@@ -5079,8 +5117,6 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	pci_release_regions(pdev);
 
 	DPRINTK(PROBE, INFO, "complete\n");
-	kfree(adapter->tx_ring);
-	kfree(adapter->rx_ring);
 
 	free_netdev(netdev);
 

