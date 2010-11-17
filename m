From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH v1 2/2] ixgbe: add multiple txqs per tc
Date: Tue, 16 Nov 2010 21:15:50 -0800
Message-ID: <20101117051550.19800.64236.stgit@jf-dev1-dcblab>
References: <20101117051544.19800.97654.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, nhorman@tuxdriver.com,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59372 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766Ab0KQFSg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Nov 2010 00:18:36 -0500
In-Reply-To: <20101117051544.19800.97654.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is sample code to illustrate the usage model for hardware
QOS offloading. It needs some polishing, but should be good
enough to illustrate how the API can be used.

Currently, DCB only enables a single queue per tc. Due to
complications with how to map tc filter rules to traffic classes
when multiple queues are enabled. And previously there was no
mechanism to map flows to multiple queues by priority.

Using the above mentioned API we allocate multiple queues per
tc and configure the stack to hash across these queues. The
hardware then offloads the DCB extended transmission selection
algorithm. Sockets can set the priority using the SO_PRIORITY
socket option.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 drivers/net/ixgbe/ixgbe.h        |    5 -
 drivers/net/ixgbe/ixgbe_dcb_nl.c |    3 
 drivers/net/ixgbe/ixgbe_main.c   |  254 +++++++++++++++-----------------------
 3 files changed, 105 insertions(+), 157 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index ed8703c..2ac7bf7 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -207,11 +207,12 @@ enum ixgbe_ring_f_enum {
 	RING_F_ARRAY_SIZE      /* must be last in enum set */
 };
 
-#define IXGBE_MAX_DCB_INDICES   8
+#define IXGBE_MAX_DCB_INDICES  64
 #define IXGBE_MAX_RSS_INDICES  16
 #define IXGBE_MAX_VMDQ_INDICES 64
 #define IXGBE_MAX_FDIR_INDICES 64
-#ifdef IXGBE_FCOE
+
+#if defined(IXGBE_FCOE)
 #define IXGBE_MAX_FCOE_INDICES  8
 #define MAX_RX_QUEUES (IXGBE_MAX_FDIR_INDICES + IXGBE_MAX_FCOE_INDICES)
 #define MAX_TX_QUEUES (IXGBE_MAX_FDIR_INDICES + IXGBE_MAX_FCOE_INDICES)
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index b53b465..7c85f3c 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -140,6 +140,7 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
 		}
 		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
+
 		ixgbe_init_interrupt_scheme(adapter);
 		if (netif_running(netdev))
 			netdev->netdev_ops->ndo_open(netdev);
@@ -342,7 +343,7 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		return DCB_NO_HW_CHG;
 
 	ret = ixgbe_copy_dcb_cfg(&adapter->temp_dcb_cfg, &adapter->dcb_cfg,
-				 adapter->ring_feature[RING_F_DCB].indices);
+				 netdev->num_tcs);
 
 	if (ret)
 		return DCB_NO_HW_CHG;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fbad4d8..2c0cfb8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -644,7 +644,7 @@ static inline bool ixgbe_tx_xon_state(struct ixgbe_adapter *adapter,
 	if (adapter->dcb_cfg.pfc_mode_enable) {
 		int tc;
 		int reg_idx = tx_ring->reg_idx;
-		int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
+		int dcb_i = MAX_TRAFFIC_CLASS;
 
 		switch (adapter->hw.mac.type) {
 		case ixgbe_mac_82598EB:
@@ -3978,14 +3978,64 @@ static void ixgbe_reset_task(struct work_struct *work)
 }
 
 #ifdef CONFIG_IXGBE_DCB
+/*
+ * Queue to TC Mapping Layout 82599:
+ *
+ * Tx TC0 starts at: descriptor queue 0
+ * Tx TC1 starts at: descriptor queue 32
+ * Tx TC2 starts at: descriptor queue 64
+ * Tx TC3 starts at: descriptor queue 80
+ * Tx TC4 starts at: descriptor queue 96
+ * Tx TC5 starts at: descriptor queue 104
+ * Tx TC6 starts at: descriptor queue 112
+ * Tx TC7 starts at: descriptor queue 120
+ *
+ * Rx TC0-TC7 are offset by 16 queues each
+ *
+ * Queue to TC Mapping Layout 82598:
+ *
+ * TX TC0-TC7 are offset by 4 queues each
+ * RX TC0-TC7 are offset by 4 queues each
+ */
+static unsigned int Q_TC8_82599[] = {0, 32, 64, 80, 96, 104, 112, 120, 128};
+static unsigned int Q_TC4_82599[] = {0, 64, 96, 104, 128};
+static unsigned int Q_TC8_82598[] = {0, 4, 8, 12, 16, 20, 24, 28, 32};
+
+#define MAX_Q_PER_TC 4
+
 static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 {
 	bool ret = false;
 	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_DCB];
+	int num_tcs;
+	unsigned int *__tc;
+	int i, q;
 
 	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
 		return ret;
 
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+		num_tcs = 4;
+		__tc = Q_TC8_82598;
+	} else {
+		num_tcs = 8;
+		if (num_tcs == 8)
+			__tc = Q_TC8_82599;
+		else
+			__tc = Q_TC4_82599;
+	}
+
+	netdev_set_num_tc(adapter->netdev, num_tcs);
+
+	f->indices = 0;
+	for (i = 0; i < num_tcs; i++) {
+		q = min((unsigned int)num_online_cpus(), __tc[i+1] - __tc[i]);
+		q = min(q, MAX_Q_PER_TC);
+		netdev_set_prio_tc_map(adapter->netdev, i, i);
+		netdev_set_tc_queue(adapter->netdev, i, q, f->indices);
+		f->indices += q;
+	}
+
 	f->mask = 0x7 << 3;
 	adapter->num_rx_queues = f->indices;
 	adapter->num_tx_queues = f->indices;
@@ -4072,12 +4122,7 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
 		adapter->num_rx_queues = 1;
 		adapter->num_tx_queues = 1;
-#ifdef CONFIG_IXGBE_DCB
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			e_info(probe, "FCoE enabled with DCB\n");
-			ixgbe_set_dcb_queues(adapter);
-		}
-#endif
+
 		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 			e_info(probe, "FCoE enabled with RSS\n");
 			if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
@@ -4133,16 +4178,16 @@ static int ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 	if (ixgbe_set_sriov_queues(adapter))
 		goto done;
 
+#ifdef CONFIG_IXGBE_DCB
+	if (ixgbe_set_dcb_queues(adapter))
+		goto done;
+#endif
+
 #ifdef IXGBE_FCOE
 	if (ixgbe_set_fcoe_queues(adapter))
 		goto done;
 
 #endif /* IXGBE_FCOE */
-#ifdef CONFIG_IXGBE_DCB
-	if (ixgbe_set_dcb_queues(adapter))
-		goto done;
-
-#endif
 	if (ixgbe_set_fdir_queues(adapter))
 		goto done;
 
@@ -4246,73 +4291,35 @@ static inline bool ixgbe_cache_ring_rss(struct ixgbe_adapter *adapter)
  **/
 static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 {
-	int i;
+	struct net_device *dev = adapter->netdev;
+	int i, j, rx_off, qcount, index;
 	bool ret = false;
-	int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
+	u8 num_tcs = netdev_get_num_tc(dev);
+	unsigned int *__tc;
 
 	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
-			/* the number of queues is assumed to be symmetric */
-			for (i = 0; i < dcb_i; i++) {
-				adapter->rx_ring[i]->reg_idx = i << 3;
-				adapter->tx_ring[i]->reg_idx = i << 2;
+			rx_off = 2;
+			__tc = Q_TC8_82598;
+		} else {
+			if (num_tcs == 8) {
+				rx_off = 4;
+				__tc = Q_TC8_82599;
+			} else if (num_tcs == 4) {
+				rx_off = 5;
+				__tc = Q_TC4_82599;
 			}
-			ret = true;
-		} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
-			if (dcb_i == 8) {
-				/*
-				 * Tx TC0 starts at: descriptor queue 0
-				 * Tx TC1 starts at: descriptor queue 32
-				 * Tx TC2 starts at: descriptor queue 64
-				 * Tx TC3 starts at: descriptor queue 80
-				 * Tx TC4 starts at: descriptor queue 96
-				 * Tx TC5 starts at: descriptor queue 104
-				 * Tx TC6 starts at: descriptor queue 112
-				 * Tx TC7 starts at: descriptor queue 120
-				 *
-				 * Rx TC0-TC7 are offset by 16 queues each
-				 */
-				for (i = 0; i < 3; i++) {
-					adapter->tx_ring[i]->reg_idx = i << 5;
-					adapter->rx_ring[i]->reg_idx = i << 4;
-				}
-				for ( ; i < 5; i++) {
-					adapter->tx_ring[i]->reg_idx =
-								 ((i + 2) << 4);
-					adapter->rx_ring[i]->reg_idx = i << 4;
-				}
-				for ( ; i < dcb_i; i++) {
-					adapter->tx_ring[i]->reg_idx =
-								 ((i + 8) << 3);
-					adapter->rx_ring[i]->reg_idx = i << 4;
-				}
+		}
 
-				ret = true;
-			} else if (dcb_i == 4) {
-				/*
-				 * Tx TC0 starts at: descriptor queue 0
-				 * Tx TC1 starts at: descriptor queue 64
-				 * Tx TC2 starts at: descriptor queue 96
-				 * Tx TC3 starts at: descriptor queue 112
-				 *
-				 * Rx TC0-TC3 are offset by 32 queues each
-				 */
-				adapter->tx_ring[0]->reg_idx = 0;
-				adapter->tx_ring[1]->reg_idx = 64;
-				adapter->tx_ring[2]->reg_idx = 96;
-				adapter->tx_ring[3]->reg_idx = 112;
-				for (i = 0 ; i < dcb_i; i++)
-					adapter->rx_ring[i]->reg_idx = i << 5;
-
-				ret = true;
-			} else {
-				ret = false;
+		for (i = 0, index = 0; i < num_tcs; i++) {
+			qcount = dev->_tc_txqcount[i];
+			for (j = 0; j < qcount; j++, index++) {
+				adapter->tx_ring[index]->reg_idx = __tc[i] + j;
+				adapter->rx_ring[index]->reg_idx =
+					(i << (rx_off + (num_tcs == 4))) + j;
 			}
-		} else {
-			ret = false;
 		}
-	} else {
-		ret = false;
+		ret = true;
 	}
 
 	return ret;
@@ -4359,33 +4366,6 @@ static inline bool ixgbe_cache_ring_fcoe(struct ixgbe_adapter *adapter)
 	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_FCOE];
 
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
-#ifdef CONFIG_IXGBE_DCB
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			struct ixgbe_fcoe *fcoe = &adapter->fcoe;
-
-			ixgbe_cache_ring_dcb(adapter);
-			/* find out queues in TC for FCoE */
-			fcoe_rx_i = adapter->rx_ring[fcoe->tc]->reg_idx + 1;
-			fcoe_tx_i = adapter->tx_ring[fcoe->tc]->reg_idx + 1;
-			/*
-			 * In 82599, the number of Tx queues for each traffic
-			 * class for both 8-TC and 4-TC modes are:
-			 * TCs  : TC0 TC1 TC2 TC3 TC4 TC5 TC6 TC7
-			 * 8 TCs:  32  32  16  16   8   8   8   8
-			 * 4 TCs:  64  64  32  32
-			 * We have max 8 queues for FCoE, where 8 the is
-			 * FCoE redirection table size. If TC for FCoE is
-			 * less than or equal to TC3, we have enough queues
-			 * to add max of 8 queues for FCoE, so we start FCoE
-			 * tx descriptor from the next one, i.e., reg_idx + 1.
-			 * If TC for FCoE is above TC3, implying 8 TC mode,
-			 * and we need 8 for FCoE, we have to take all queues
-			 * in that traffic class for FCoE.
-			 */
-			if ((f->indices == IXGBE_FCRETA_SIZE) && (fcoe->tc > 3))
-				fcoe_tx_i--;
-		}
-#endif /* CONFIG_IXGBE_DCB */
 		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 			if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
 			    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
@@ -4443,17 +4423,15 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 
 	if (ixgbe_cache_ring_sriov(adapter))
 		return;
-
+#ifdef CONFIG_IXGBE_DCB
+	if (ixgbe_cache_ring_dcb(adapter))
+		return;
+#endif /* IXGBE_DCB */
 #ifdef IXGBE_FCOE
 	if (ixgbe_cache_ring_fcoe(adapter))
 		return;
 
 #endif /* IXGBE_FCOE */
-#ifdef CONFIG_IXGBE_DCB
-	if (ixgbe_cache_ring_dcb(adapter))
-		return;
-
-#endif
 	if (ixgbe_cache_ring_fdir(adapter))
 		return;
 
@@ -4910,7 +4888,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->dcb_cfg.round_robin_enable = false;
 	adapter->dcb_set_bitmap = 0x00;
 	ixgbe_copy_dcb_cfg(&adapter->dcb_cfg, &adapter->temp_dcb_cfg,
-			   adapter->ring_feature[RING_F_DCB].indices);
+			   MAX_TRAFFIC_CLASS);
 
 #endif
 
@@ -6253,25 +6231,6 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	int txq = smp_processor_id();
-#ifdef IXGBE_FCOE
-	__be16 protocol;
-
-	protocol = vlan_get_protocol(skb);
-
-	if ((protocol == htons(ETH_P_FCOE)) ||
-	    (protocol == htons(ETH_P_FIP))) {
-		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
-			txq &= (adapter->ring_feature[RING_F_FCOE].indices - 1);
-			txq += adapter->ring_feature[RING_F_FCOE].mask;
-			return txq;
-#ifdef CONFIG_IXGBE_DCB
-		} else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			txq = adapter->fcoe.up;
-			return txq;
-#endif
-		}
-	}
-#endif
 
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
 		while (unlikely(txq >= dev->real_num_tx_queues))
@@ -6279,14 +6238,20 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 		return txq;
 	}
 
-	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-		if (skb->priority == TC_PRIO_CONTROL)
-			txq = adapter->ring_feature[RING_F_DCB].indices-1;
-		else
-			txq = (skb->vlan_tci & IXGBE_TX_FLAGS_VLAN_PRIO_MASK)
-			       >> 13;
+#ifdef IXGBE_FCOE
+	/*
+	 * If DCB is not enabled to assign FCoE a priority mapping
+	 * we need to steer the skb to FCoE enabled tx rings.
+	 */
+	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
+	    !(adapter->flags & IXGBE_FLAG_DCB_ENABLED) &&
+	    ((skb->protocol == htons(ETH_P_FCOE)) ||
+	     (skb->protocol == htons(ETH_P_FIP)))) {
+		txq &= (adapter->ring_feature[RING_F_FCOE].indices - 1);
+		txq += adapter->ring_feature[RING_F_FCOE].mask;
 		return txq;
 	}
+#endif
 
 	return skb_tx_hash(dev, skb);
 }
@@ -6308,33 +6273,12 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev
 
 	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= vlan_tx_tag_get(skb);
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			tx_flags &= ~IXGBE_TX_FLAGS_VLAN_PRIO_MASK;
-			tx_flags |= ((skb->queue_mapping & 0x7) << 13);
-		}
-		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
-		tx_flags |= IXGBE_TX_FLAGS_VLAN;
-	} else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED &&
-		   skb->priority != TC_PRIO_CONTROL) {
-		tx_flags |= ((skb->queue_mapping & 0x7) << 13);
 		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 	}
 
 #ifdef IXGBE_FCOE
-	/* for FCoE with DCB, we force the priority to what
-	 * was specified by the switch */
-	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED &&
-	    (protocol == htons(ETH_P_FCOE) ||
-	     protocol == htons(ETH_P_FIP))) {
-#ifdef CONFIG_IXGBE_DCB
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			tx_flags &= ~(IXGBE_TX_FLAGS_VLAN_PRIO_MASK
-				      << IXGBE_TX_FLAGS_VLAN_SHIFT);
-			tx_flags |= ((adapter->fcoe.up << 13)
-				      << IXGBE_TX_FLAGS_VLAN_SHIFT);
-		}
-#endif
+	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
 		/* flag for FCoE offloads */
 		if (protocol == htons(ETH_P_FCOE))
 			tx_flags |= IXGBE_TX_FLAGS_FCOE;
@@ -6744,9 +6688,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		indices = min_t(unsigned int, indices, IXGBE_MAX_RSS_INDICES);
 	else
 		indices = min_t(unsigned int, indices, IXGBE_MAX_FDIR_INDICES);
-
+#if defined(CONFIG_IXGBE_DCB)
 	indices = max_t(unsigned int, indices, IXGBE_MAX_DCB_INDICES);
-#ifdef IXGBE_FCOE
+#elif defined(IXGBE_FCOE)
 	indices += min_t(unsigned int, num_possible_cpus(),
 			 IXGBE_MAX_FCOE_INDICES);
 #endif
@@ -6901,6 +6845,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 #ifdef CONFIG_IXGBE_DCB
 	netdev->dcbnl_ops = &dcbnl_ops;
+	netdev_alloc_max_tcs(netdev, MAX_TRAFFIC_CLASS);
 #endif
 
 #ifdef IXGBE_FCOE
@@ -7043,6 +6988,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	/* add san mac addr to netdev */
 	ixgbe_add_sanmac_netdev(netdev);
 
+
 	e_dev_info("Intel(R) 10 Gigabit Network Connection\n");
 	cards_found++;
 	return 0;

