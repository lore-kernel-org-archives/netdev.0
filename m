From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH 4/4] ixgbe: add multiple txqs per tc
Date: Thu, 09 Dec 2010 12:00:13 -0800
Message-ID: <20101209200013.3554.50143.stgit@jf-dev1-dcblab>
References: <20101209195956.3554.49511.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, shemminger@vyatta.com,
	tgraf@infradead.org, eric.dumazet@gmail.com,
	john.r.fastabend@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2196 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757037Ab0LIUCR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 15:02:17 -0500
In-Reply-To: <20101209195956.3554.49511.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This illustrates the usage model for hardware QOS offloading.

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
 drivers/net/ixgbe/ixgbe_dcb_nl.c |    4 -
 drivers/net/ixgbe/ixgbe_main.c   |  256 ++++++++++++++++++++++----------------
 3 files changed, 149 insertions(+), 113 deletions(-)

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
index bf566e8..d49b8ce 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -354,12 +354,12 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	int ret;
+	int tc = max(netdev->num_tc, MAX_TRAFFIC_CLASS);
 
 	if (!adapter->dcb_set_bitmap)
 		return DCB_NO_HW_CHG;
 
-	ret = ixgbe_copy_dcb_cfg(&adapter->temp_dcb_cfg, &adapter->dcb_cfg,
-				 adapter->ring_feature[RING_F_DCB].indices);
+	ret = ixgbe_copy_dcb_cfg(&adapter->temp_dcb_cfg, &adapter->dcb_cfg, tc);
 
 	if (ret)
 		return DCB_NO_HW_CHG;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a12e86f..46b700d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -638,6 +638,43 @@ void ixgbe_unmap_and_free_tx_resource(struct ixgbe_ring *tx_ring,
 	/* tx_buffer_info must be completely set up in the transmit path */
 }
 
+#define IXGBE_MAX_Q_PER_TC	(IXGBE_MAX_DCB_INDICES / MAX_TRAFFIC_CLASS)
+
+/* ixgbe setup routine for many traffic classes hardware only supports
+ * 4 or 8 traffic classes.
+ *
+ * JF: Todo, software should be able to map arbitrary TCs to 4 or 8 HW
+ * tcs. For illustration purposes require 4 or 8 tcs for now.
+ */
+int ixgbe_setup_tc(struct net_device *dev, u8 tcs)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	int i, err = 0;
+	unsigned int q, offset = 0;
+
+	if (!tcs) {
+		err = netdev_set_num_tc(dev, tcs);
+	} else if (tcs != 4 || tcs != 8) {
+		if (!dev->max_tc && netdev_alloc_max_tc(dev, tcs))
+			return -ENOMEM;
+
+		if (netdev_set_num_tc(dev, tcs))
+			return -EINVAL;
+
+		/* Partition TX queues evenly amongst traffic classes */
+		for (i = 0; i < tcs; i++) {
+			q = min((int)num_online_cpus(), IXGBE_MAX_Q_PER_TC);
+			netdev_set_prio_tc_map(adapter->netdev, i, i);
+			netdev_set_tc_queue(adapter->netdev, i, q, offset);
+			offset += q;
+		}
+	} else {
+		err = -EINVAL;
+	}
+
+	return err;
+}
+
 /**
  * ixgbe_dcb_txq_to_tc - convert a reg index to a traffic class
  * @adapter: driver private struct
@@ -651,7 +688,7 @@ void ixgbe_unmap_and_free_tx_resource(struct ixgbe_ring *tx_ring,
 u8 ixgbe_dcb_txq_to_tc(struct ixgbe_adapter *adapter, u8 reg_idx)
 {
 	int tc = -1;
-	int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
+	u8 num_tcs = netdev_get_num_tc(adapter->netdev);
 
 	/* if DCB is not enabled the queues have no TC */
 	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
@@ -666,13 +703,13 @@ u8 ixgbe_dcb_txq_to_tc(struct ixgbe_adapter *adapter, u8 reg_idx)
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
 
@@ -685,9 +722,9 @@ u8 ixgbe_dcb_txq_to_tc(struct ixgbe_adapter *adapter, u8 reg_idx)
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
 
@@ -4205,10 +4242,17 @@ static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 {
 	bool ret = false;
 	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_DCB];
+	int i, q;
 
 	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
 		return ret;
 
+	f->indices = 0;
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		q = min((int)num_online_cpus(), MAX_TRAFFIC_CLASS);
+		f->indices += q;
+	}
+
 	f->mask = 0x7 << 3;
 	adapter->num_rx_queues = f->indices;
 	adapter->num_tx_queues = f->indices;
@@ -4295,12 +4339,7 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
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
@@ -4356,16 +4395,15 @@ static int ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
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
 
@@ -4457,6 +4495,63 @@ static inline bool ixgbe_cache_ring_rss(struct ixgbe_adapter *adapter)
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
@@ -4466,72 +4561,26 @@ static inline bool ixgbe_cache_ring_rss(struct ixgbe_adapter *adapter)
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
 
@@ -4659,17 +4708,15 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 
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
 
@@ -5133,7 +5180,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->dcb_cfg.round_robin_enable = false;
 	adapter->dcb_set_bitmap = 0x00;
 	ixgbe_copy_dcb_cfg(&adapter->dcb_cfg, &adapter->temp_dcb_cfg,
-			   adapter->ring_feature[RING_F_DCB].indices);
+			   MAX_TRAFFIC_CLASS);
 
 #endif
 
@@ -5986,7 +6033,7 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 		if (link_up) {
 #ifdef CONFIG_DCB
 			if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-				for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
+				for (i = 0; i < netdev->max_tc; i++)
 					hw->mac.ops.fc_enable(hw, i);
 			} else {
 				hw->mac.ops.fc_enable(hw, 0);
@@ -6511,25 +6558,6 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
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
@@ -6537,14 +6565,20 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
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
@@ -6867,6 +6901,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_tx_rate	= ixgbe_ndo_set_vf_bw,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
+	.ndo_setup_tc		= ixgbe_setup_tc,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbe_netpoll,
 #endif
@@ -7007,8 +7042,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	else
 		indices = min_t(unsigned int, indices, IXGBE_MAX_FDIR_INDICES);
 
+#if defined(CONFIG_IXGBE_DCB)
 	indices = max_t(unsigned int, indices, IXGBE_MAX_DCB_INDICES);
-#ifdef IXGBE_FCOE
+#elif defined(IXGBE_FCOE)
 	indices += min_t(unsigned int, num_possible_cpus(),
 			 IXGBE_MAX_FCOE_INDICES);
 #endif

