From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH v2 3/3] ixgbe: add multiple txqs per tc
Date: Wed, 01 Dec 2010 10:23:03 -0800
Message-ID: <20101201182303.2748.27253.stgit@jf-dev1-dcblab>
References: <20101201182252.2748.15208.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	tgraf@infradead.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62523 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756112Ab0LASZX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 13:25:23 -0500
In-Reply-To: <20101201182252.2748.15208.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is sample code to illustrate the usage model for hardware
QOS offloading. It needs some polishing, but should be good
enough to illustrate how the API can be used.

Currently, DCB only enables a single queue per tc. Due to
complications with how to map tc filter rules to traffic classes
when multiple queues are enabled. And previously there was no
mechanism to map flows to multiple queues by priority.

Using the QOS offloading API we allocate multiple queues per
tc and configure the stack to hash across these queues. The
hardware then offloads the DCB extended transmission selection
algorithm. Sockets can set the priority using the SO_PRIORITY
socket option and expect ETS to work.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 drivers/net/ixgbe/ixgbe.h        |    2 
 drivers/net/ixgbe/ixgbe_dcb_nl.c |    3 
 drivers/net/ixgbe/ixgbe_main.c   |  264 +++++++++++++++++++-------------------
 3 files changed, 134 insertions(+), 135 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 3ae30b8..860b1fa 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -243,7 +243,7 @@ enum ixgbe_ring_f_enum {
 	RING_F_ARRAY_SIZE      /* must be last in enum set */
 };
 
-#define IXGBE_MAX_DCB_INDICES   8
+#define IXGBE_MAX_DCB_INDICES  64
 #define IXGBE_MAX_RSS_INDICES  16
 #define IXGBE_MAX_VMDQ_INDICES 64
 #define IXGBE_MAX_FDIR_INDICES 64
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index bf566e8..8e203ae 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -155,6 +155,7 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			if (netif_running(netdev))
 				netdev->netdev_ops->ndo_stop(netdev);
 			ixgbe_clear_interrupt_scheme(adapter);
+			netdev_set_num_tc(adapter->netdev, 0);
 
 			adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
 			adapter->temp_dcb_cfg.pfc_mode_enable = false;
@@ -359,7 +360,7 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		return DCB_NO_HW_CHG;
 
 	ret = ixgbe_copy_dcb_cfg(&adapter->temp_dcb_cfg, &adapter->dcb_cfg,
-				 adapter->ring_feature[RING_F_DCB].indices);
+				 netdev->num_tcs);
 
 	if (ret)
 		return DCB_NO_HW_CHG;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 494cb57..1517e5c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -634,6 +634,18 @@ void ixgbe_unmap_and_free_tx_resource(struct ixgbe_ring *tx_ring,
 	/* tx_buffer_info must be completely set up in the transmit path */
 }
 
+int ixgbe_set_num_tc(struct net_device *dev, u8 tcs)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	int err = 0;
+
+	/* Do not allow change while DCB controlled */
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
+		return -EINVAL;
+
+	return netdev_set_num_tc(dev, tcs);
+}
+
 /**
  * ixgbe_dcb_txq_to_tc - convert a reg index to a traffic class
  * @adapter: driver private struct
@@ -647,7 +659,7 @@ void ixgbe_unmap_and_free_tx_resource(struct ixgbe_ring *tx_ring,
 u8 ixgbe_dcb_txq_to_tc(struct ixgbe_adapter *adapter, u8 reg_idx)
 {
 	int tc = -1;
-	int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
+	u8 num_tcs = netdev_get_num_tc(adapter->netdev);
 
 	/* if DCB is not enabled the queues have no TC */
 	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
@@ -662,13 +674,13 @@ u8 ixgbe_dcb_txq_to_tc(struct ixgbe_adapter *adapter, u8 reg_idx)
 		tc = reg_idx >> 2;
 		break;
 	default:
-		if (dcb_i != 4 && dcb_i != 8)
+		if (num_tcs != 4 && num_tcs != 8)
 			break;
 
 		/* if VMDq is enabled the lowest order bits determine TC */
 		if (adapter->flags & (IXGBE_FLAG_SRIOV_ENABLED |
 				      IXGBE_FLAG_VMDQ_ENABLED)) {
-			tc = reg_idx & (dcb_i - 1);
+			tc = reg_idx & (num_tcs - 1);
 			break;
 		}
 
@@ -681,9 +693,9 @@ u8 ixgbe_dcb_txq_to_tc(struct ixgbe_adapter *adapter, u8 reg_idx)
 		 * will only ever be 8 or 4 and that reg_idx will never
 		 * be greater then 128. The code without the power of 2
 		 * optimizations would be:
-		 * (((reg_idx % 32) + 32) * dcb_i) >> (9 - reg_idx / 32)
+		 * (((reg_idx % 32) + 32) * num_tcs) >> (9 - reg_idx / 32)
 		 */
-		tc = ((reg_idx & 0X1F) + 0x20) * dcb_i;
+		tc = ((reg_idx & 0X1F) + 0x20) * num_tcs;
 		tc >>= 9 - (reg_idx >> 5);
 	}
 
@@ -4190,14 +4202,29 @@ static void ixgbe_reset_task(struct work_struct *work)
 }
 
 #ifdef CONFIG_IXGBE_DCB
+#define MAX_Q_PER_TC 8
+
 static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 {
 	bool ret = false;
 	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_DCB];
+	int num_tcs;
+	int i, q;
 
 	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
 		return ret;
 
+	num_tcs = 8;
+	netdev_set_num_tc(adapter->netdev, num_tcs);
+
+	f->indices = 0;
+	for (i = 0; i < num_tcs; i++) {
+		q = min((int)num_online_cpus(), MAX_Q_PER_TC);
+		netdev_set_prio_tc_map(adapter->netdev, i, i);
+		netdev_set_tc_queue(adapter->netdev, i, q, f->indices);
+		f->indices += q;
+	}
+
 	f->mask = 0x7 << 3;
 	adapter->num_rx_queues = f->indices;
 	adapter->num_tx_queues = f->indices;
@@ -4284,12 +4311,7 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
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
@@ -4345,16 +4367,15 @@ static int ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 	if (ixgbe_set_sriov_queues(adapter))
 		goto done;
 
-#ifdef IXGBE_FCOE
-	if (ixgbe_set_fcoe_queues(adapter))
-		goto done;
-
-#endif /* IXGBE_FCOE */
 #ifdef CONFIG_IXGBE_DCB
 	if (ixgbe_set_dcb_queues(adapter))
 		goto done;
-
 #endif
+
+#ifdef IXGBE_FCOE
+	if (ixgbe_set_fcoe_queues(adapter))
+		goto done;
+#endif /* IXGBE_FCOE */
 	if (ixgbe_set_fdir_queues(adapter))
 		goto done;
 
@@ -4446,6 +4467,63 @@ static inline bool ixgbe_cache_ring_rss(struct ixgbe_adapter *adapter)
 }
 
 #ifdef CONFIG_IXGBE_DCB
+
+ /* ixgbe_get_first_reg_idx - Return first register index associated
+ *  with this traffic class
+ */
+void ixgbe_get_first_reg_idx(struct ixgbe_adapter *adapter, u8 tc,
+				     unsigned int *tx, unsigned int *rx)
+{
+	struct net_device *dev = adapter->netdev;
+	struct ixgbe_hw *hw = &adapter->hw;
+	u8 num_tcs = netdev_get_num_tc(dev);
+
+	*tx = 0;
+	*rx = 0;
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
+		*tx = tc << 3;
+		*rx = tc << 2;
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		if (num_tcs == 8) {
+			if (tc < 3) {
+				*tx = tc << 5;
+				*rx = tc << 4;
+			} else if (tc <  5) {
+				*tx = ((tc + 2) << 4);
+				*rx = tc << 4;
+			} else if (tc < num_tcs) {
+				*tx = ((tc + 8) << 3);
+				*rx = tc << 4;
+			}
+		} else if (num_tcs == 4) {
+				*rx =  tc << 5;
+				switch (tc) {
+				case 0:
+					*tx =  0;
+					break;
+				case 1:
+					*tx = 64;
+					break;
+				case 2:
+					*tx = 96;
+					break;
+				case 3:
+					*tx = 112;
+					break;
+				default:
+					break;
+				}
+		}
+		break;
+	default:
+		break;
+	}
+}
+
 /**
  * ixgbe_cache_ring_dcb - Descriptor ring to register mapping for DCB
  * @adapter: board private structure to initialize
@@ -4455,72 +4533,26 @@ static inline bool ixgbe_cache_ring_rss(struct ixgbe_adapter *adapter)
  **/
 static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 {
-	int i;
-	bool ret = false;
-	int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
+	struct net_device *dev = adapter->netdev;
+	int i, j, k;
+	u8 num_tcs = netdev_get_num_tc(dev);
+	unsigned int tx_s, rx_s;
 
 	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
 		return false;
 
 	/* the number of queues is assumed to be symmetric */
-	switch (adapter->hw.mac.type) {
-	case ixgbe_mac_82598EB:
-		for (i = 0; i < dcb_i; i++) {
-			adapter->rx_ring[i]->reg_idx = i << 3;
-			adapter->tx_ring[i]->reg_idx = i << 2;
+	for (i = 0, k = 0; i < num_tcs; i++) {
+		struct netdev_tc_txq *tcp = netdev_get_tc_queue(dev, i);
+		u16 qcount = tcp->count;
+		ixgbe_get_first_reg_idx(adapter, i, &tx_s, &rx_s);
+		for (j = 0; j < qcount; j++, k++) {
+			adapter->tx_ring[k]->reg_idx = tx_s + j;
+			adapter->rx_ring[k]->reg_idx = rx_s + j;
 		}
-		ret = true;
-		break;
-	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
-		if (dcb_i == 8) {
-			/*
-			 * Tx TC0 starts at: descriptor queue 0
-			 * Tx TC1 starts at: descriptor queue 32
-			 * Tx TC2 starts at: descriptor queue 64
-			 * Tx TC3 starts at: descriptor queue 80
-			 * Tx TC4 starts at: descriptor queue 96
-			 * Tx TC5 starts at: descriptor queue 104
-			 * Tx TC6 starts at: descriptor queue 112
-			 * Tx TC7 starts at: descriptor queue 120
-			 *
-			 * Rx TC0-TC7 are offset by 16 queues each
-			 */
-			for (i = 0; i < 3; i++) {
-				adapter->tx_ring[i]->reg_idx = i << 5;
-				adapter->rx_ring[i]->reg_idx = i << 4;
-			}
-			for ( ; i < 5; i++) {
-				adapter->tx_ring[i]->reg_idx = ((i + 2) << 4);
-				adapter->rx_ring[i]->reg_idx = i << 4;
-			}
-			for ( ; i < dcb_i; i++) {
-				adapter->tx_ring[i]->reg_idx = ((i + 8) << 3);
-				adapter->rx_ring[i]->reg_idx = i << 4;
-			}
-			ret = true;
-		} else if (dcb_i == 4) {
-			/*
-			 * Tx TC0 starts at: descriptor queue 0
-			 * Tx TC1 starts at: descriptor queue 64
-			 * Tx TC2 starts at: descriptor queue 96
-			 * Tx TC3 starts at: descriptor queue 112
-			 *
-			 * Rx TC0-TC3 are offset by 32 queues each
-			 */
-			adapter->tx_ring[0]->reg_idx = 0;
-			adapter->tx_ring[1]->reg_idx = 64;
-			adapter->tx_ring[2]->reg_idx = 96;
-			adapter->tx_ring[3]->reg_idx = 112;
-			for (i = 0 ; i < dcb_i; i++)
-				adapter->rx_ring[i]->reg_idx = i << 5;
-			ret = true;
-		}
-		break;
-	default:
-		break;
 	}
-	return ret;
+
+	return true;
 }
 #endif
 
@@ -4648,17 +4680,15 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 
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
 
@@ -5122,7 +5152,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->dcb_cfg.round_robin_enable = false;
 	adapter->dcb_set_bitmap = 0x00;
 	ixgbe_copy_dcb_cfg(&adapter->dcb_cfg, &adapter->temp_dcb_cfg,
-			   adapter->ring_feature[RING_F_DCB].indices);
+			   dev->max_tcs);
 
 #endif
 
@@ -5975,7 +6005,7 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 		if (link_up) {
 #ifdef CONFIG_DCB
 			if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-				for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
+				for (i = 0; i < netdev->max_tcs; i++)
 					hw->mac.ops.fc_enable(hw, i);
 			} else {
 				hw->mac.ops.fc_enable(hw, 0);
@@ -6500,25 +6530,6 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
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
@@ -6526,14 +6537,20 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
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
@@ -6556,33 +6573,12 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 
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
@@ -6856,6 +6852,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_tx_rate	= ixgbe_ndo_set_vf_bw,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
+	.ndo_set_num_tc		= ixgbe_set_num_tc,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbe_netpoll,
 #endif
@@ -6994,9 +6991,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
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
@@ -7157,6 +7154,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 #ifdef CONFIG_IXGBE_DCB
 	netdev->dcbnl_ops = &dcbnl_ops;
+	netdev_alloc_max_tcs(netdev, MAX_TRAFFIC_CLASS);
 #endif
 
 #ifdef IXGBE_FCOE

