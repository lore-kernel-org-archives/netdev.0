From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 10/21] ixgbe: DCB, use multiple Tx rings per traffic class
Date: Sat, 12 Mar 2011 04:20:17 -0800
Message-ID: <1299932428-3114-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58767 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753915Ab1CLMUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:20:55 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

This enables multiple {Tx|Rx} rings per traffic class while in DCB
mode. In order to get this working as expected the tc_to_tx net
device mapping is configured as well as the prio_tc_map.

skb priorities are mapped across a range of queue pairs to get
a distribution per traffic class. The maximum number of
queue pairs used while in DCB mode is capped at 64. The hardware
max is actually 128 queues but 64 is sufficient for now and
allocating more seemed a bit excessive. It is easy enough to
increase the cap later if need be.

To get the 802.1Q priority tags inserted correctly ixgbe was
previously using the skb queue_mapping field to directly set
the 802.1Q priority. This no longer works because we have removed
the 1:1 mapping between queues and traffic class. Each ring
is aligned with an 802.1Qaz traffic class so here we add an
extra field to the ring struct to identify the 802.1Q traffic
class. This uses an extra byte of the ixgbe_ring struct
fortunately there was a 2byte hole,

struct ixgbe_ring {
        void *                     desc;                 /*     0     8 */
        struct device *            dev;                  /*     8     8 */
        struct net_device *        netdev;               /*    16     8 */
        union {
                struct ixgbe_tx_buffer * tx_buffer_info; /*           8 */
                struct ixgbe_rx_buffer * rx_buffer_info; /*           8 */
        };                                               /*    24     8 */
        long unsigned int          state;                /*    32     8 */
        u8                         atr_sample_rate;      /*    40     1 */
        u8                         atr_count;            /*    41     1 */
        u16                        count;                /*    42     2 */
        u16                        rx_buf_len;           /*    44     2 */
        u16                        next_to_use;          /*    46     2 */
        u16                        next_to_clean;        /*    48     2 */
        u8                         queue_index;          /*    50     1 */
        u8                         reg_idx;              /*    51     1 */
        u16                        work_limit;           /*    52     2 */

        /* XXX 2 bytes hole, try to pack */

        u8 *                       tail;                 /*    56     8 */
        /* --- cacheline 1 boundary (64 bytes) --- */

Now we can set the VLAN priority directly and it will be
correct. User space can indicate the 802.1Qaz priority
using the SO_PRIORITY setsocket() option and QOS layer will
steer the skb to the correct rings. Additionally using
the multiq qdisc with a queue_mapping action works as
well.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h        |    4 +-
 drivers/net/ixgbe/ixgbe_dcb_nl.c |    7 +-
 drivers/net/ixgbe/ixgbe_main.c   |  339 +++++++++++++++++++-------------------
 3 files changed, 182 insertions(+), 168 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 815edfd..b7e62d5 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -209,6 +209,7 @@ struct ixgbe_ring {
 					 * associated with this ring, which is
 					 * different for DCB and RSS modes
 					 */
+	u8 dcb_tc;
 
 	u16 work_limit;			/* max work per interrupt */
 
@@ -243,7 +244,7 @@ enum ixgbe_ring_f_enum {
 	RING_F_ARRAY_SIZE      /* must be last in enum set */
 };
 
-#define IXGBE_MAX_DCB_INDICES   8
+#define IXGBE_MAX_DCB_INDICES  64
 #define IXGBE_MAX_RSS_INDICES  16
 #define IXGBE_MAX_VMDQ_INDICES 64
 #define IXGBE_MAX_FDIR_INDICES 64
@@ -542,6 +543,7 @@ extern void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter,
 extern void ixgbe_clear_rscctl(struct ixgbe_adapter *adapter,
                                struct ixgbe_ring *ring);
 extern void ixgbe_set_rx_mode(struct net_device *netdev);
+extern int ixgbe_setup_tc(struct net_device *dev, u8 tc);
 #ifdef IXGBE_FCOE
 extern void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter);
 extern int ixgbe_fso(struct ixgbe_adapter *adapter,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index d4b2914..b7b6db3 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -145,6 +145,9 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 		}
 
 		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
+		if (!netdev_get_num_tc(netdev))
+			ixgbe_setup_tc(netdev, MAX_TRAFFIC_CLASS);
+
 		ixgbe_init_interrupt_scheme(adapter);
 		if (netif_running(netdev))
 			netdev->netdev_ops->ndo_open(netdev);
@@ -169,6 +172,8 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 				break;
 			}
 
+			ixgbe_setup_tc(netdev, 0);
+
 			ixgbe_init_interrupt_scheme(adapter);
 			if (netif_running(netdev))
 				netdev->netdev_ops->ndo_open(netdev);
@@ -351,7 +356,7 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		return DCB_NO_HW_CHG;
 
 	ret = ixgbe_copy_dcb_cfg(&adapter->temp_dcb_cfg, &adapter->dcb_cfg,
-				 adapter->ring_feature[RING_F_DCB].indices);
+				 MAX_TRAFFIC_CLASS);
 
 	if (ret)
 		return DCB_NO_HW_CHG;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 4aeade8..3694226 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -652,7 +652,7 @@ void ixgbe_unmap_and_free_tx_resource(struct ixgbe_ring *tx_ring,
 static u8 ixgbe_dcb_txq_to_tc(struct ixgbe_adapter *adapter, u8 reg_idx)
 {
 	int tc = -1;
-	int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
+	int dcb_i = netdev_get_num_tc(adapter->netdev);
 
 	/* if DCB is not enabled the queues have no TC */
 	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
@@ -4258,24 +4258,6 @@ static void ixgbe_reset_task(struct work_struct *work)
 	ixgbe_reinit_locked(adapter);
 }
 
-#ifdef CONFIG_IXGBE_DCB
-static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
-{
-	bool ret = false;
-	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_DCB];
-
-	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
-		return ret;
-
-	f->mask = 0x7 << 3;
-	adapter->num_rx_queues = f->indices;
-	adapter->num_tx_queues = f->indices;
-	ret = true;
-
-	return ret;
-}
-#endif
-
 /**
  * ixgbe_set_rss_queues: Allocate queues for RSS
  * @adapter: board private structure to initialize
@@ -4346,19 +4328,26 @@ static inline bool ixgbe_set_fdir_queues(struct ixgbe_adapter *adapter)
  **/
 static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
 {
-	bool ret = false;
 	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_FCOE];
 
-	f->indices = min((int)num_online_cpus(), f->indices);
-	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
-		adapter->num_rx_queues = 1;
-		adapter->num_tx_queues = 1;
+	if (!(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))
+		return false;
+
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 #ifdef CONFIG_IXGBE_DCB
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			e_info(probe, "FCoE enabled with DCB\n");
-			ixgbe_set_dcb_queues(adapter);
-		}
+		int tc;
+		struct net_device *dev = adapter->netdev;
+
+		tc = netdev_get_prio_tc_map(dev, adapter->fcoe.up);
+		f->indices = dev->tc_to_txq[tc].count;
+		f->mask = dev->tc_to_txq[tc].offset;
 #endif
+	} else {
+		f->indices = min((int)num_online_cpus(), f->indices);
+
+		adapter->num_rx_queues = 1;
+		adapter->num_tx_queues = 1;
+
 		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 			e_info(probe, "FCoE enabled with RSS\n");
 			if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
@@ -4371,14 +4360,45 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
 		f->mask = adapter->num_rx_queues;
 		adapter->num_rx_queues += f->indices;
 		adapter->num_tx_queues += f->indices;
+	}
 
-		ret = true;
+	return true;
+}
+#endif /* IXGBE_FCOE */
+
+#ifdef CONFIG_IXGBE_DCB
+static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
+{
+	bool ret = false;
+	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_DCB];
+	int i, q;
+
+	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
+		return ret;
+
+	f->indices = 0;
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		q = min((int)num_online_cpus(), MAX_TRAFFIC_CLASS);
+		f->indices += q;
 	}
 
+	f->mask = 0x7 << 3;
+	adapter->num_rx_queues = f->indices;
+	adapter->num_tx_queues = f->indices;
+	ret = true;
+
+#ifdef IXGBE_FCOE
+	/* FCoE enabled queues require special configuration done through
+	 * configure_fcoe() and others. Here we map FCoE indices onto the
+	 * DCB queue pairs allowing FCoE to own configuration later.
+	 */
+	ixgbe_set_fcoe_queues(adapter);
+#endif
+
 	return ret;
 }
+#endif
 
-#endif /* IXGBE_FCOE */
 /**
  * ixgbe_set_sriov_queues: Allocate queues for IOV use
  * @adapter: board private structure to initialize
@@ -4414,16 +4434,16 @@ static int ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
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
 
 #endif
+#ifdef IXGBE_FCOE
+	if (ixgbe_set_fcoe_queues(adapter))
+		goto done;
+
+#endif /* IXGBE_FCOE */
 	if (ixgbe_set_fdir_queues(adapter))
 		goto done;
 
@@ -4515,6 +4535,91 @@ static inline bool ixgbe_cache_ring_rss(struct ixgbe_adapter *adapter)
 }
 
 #ifdef CONFIG_IXGBE_DCB
+
+/* ixgbe_get_first_reg_idx - Return first register index associated with ring */
+void ixgbe_get_first_reg_idx(struct ixgbe_adapter *adapter, u8 tc,
+			     unsigned int *tx, unsigned int *rx)
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
+			*rx =  tc << 5;
+			switch (tc) {
+			case 0:
+				*tx =  0;
+				break;
+			case 1:
+				*tx = 64;
+				break;
+			case 2:
+				*tx = 96;
+				break;
+			case 3:
+				*tx = 112;
+				break;
+			default:
+				break;
+			}
+		}
+		break;
+	default:
+		break;
+	}
+}
+
+#define IXGBE_MAX_Q_PER_TC	(IXGBE_MAX_DCB_INDICES / MAX_TRAFFIC_CLASS)
+
+/* ixgbe_setup_tc - routine to configure net_device for multiple traffic
+ * classes.
+ *
+ * @netdev: net device to configure
+ * @tc: number of traffic classes to enable
+ */
+int ixgbe_setup_tc(struct net_device *dev, u8 tc)
+{
+	int i;
+	unsigned int q, offset = 0;
+
+	if (!tc) {
+		netdev_reset_tc(dev);
+	} else {
+		if (netdev_set_num_tc(dev, tc))
+			return -EINVAL;
+
+		/* Partition Tx queues evenly amongst traffic classes */
+		for (i = 0; i < tc; i++) {
+			q = min((int)num_online_cpus(), IXGBE_MAX_Q_PER_TC);
+			netdev_set_prio_tc_map(dev, i, i);
+			netdev_set_tc_queue(dev, i, q, offset);
+			offset += q;
+		}
+	}
+	return 0;
+}
+
 /**
  * ixgbe_cache_ring_dcb - Descriptor ring to register mapping for DCB
  * @adapter: board private structure to initialize
@@ -4524,72 +4629,27 @@ static inline bool ixgbe_cache_ring_rss(struct ixgbe_adapter *adapter)
  **/
 static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 {
-	int i;
-	bool ret = false;
-	int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
+	struct net_device *dev = adapter->netdev;
+	int i, j, k;
+	u8 num_tcs = netdev_get_num_tc(dev);
 
 	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
 		return false;
 
-	/* the number of queues is assumed to be symmetric */
-	switch (adapter->hw.mac.type) {
-	case ixgbe_mac_82598EB:
-		for (i = 0; i < dcb_i; i++) {
-			adapter->rx_ring[i]->reg_idx = i << 3;
-			adapter->tx_ring[i]->reg_idx = i << 2;
-		}
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
+	for (i = 0, k = 0; i < num_tcs; i++) {
+		unsigned int tx_s, rx_s;
+		u16 count = dev->tc_to_txq[i].count;
+
+		ixgbe_get_first_reg_idx(adapter, i, &tx_s, &rx_s);
+		for (j = 0; j < count; j++, k++) {
+			adapter->tx_ring[k]->reg_idx = tx_s + j;
+			adapter->rx_ring[k]->reg_idx = rx_s + j;
+			adapter->tx_ring[k]->dcb_tc = i;
+			adapter->rx_ring[k]->dcb_tc = i;
 		}
-		break;
-	default:
-		break;
 	}
-	return ret;
+
+	return true;
 }
 #endif
 
@@ -4635,33 +4695,6 @@ static inline bool ixgbe_cache_ring_fcoe(struct ixgbe_adapter *adapter)
 	if (!(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))
 		return false;
 
-#ifdef CONFIG_IXGBE_DCB
-	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-		struct ixgbe_fcoe *fcoe = &adapter->fcoe;
-
-		ixgbe_cache_ring_dcb(adapter);
-		/* find out queues in TC for FCoE */
-		fcoe_rx_i = adapter->rx_ring[fcoe->tc]->reg_idx + 1;
-		fcoe_tx_i = adapter->tx_ring[fcoe->tc]->reg_idx + 1;
-		/*
-		 * In 82599, the number of Tx queues for each traffic
-		 * class for both 8-TC and 4-TC modes are:
-		 * TCs  : TC0 TC1 TC2 TC3 TC4 TC5 TC6 TC7
-		 * 8 TCs:  32  32  16  16   8   8   8   8
-		 * 4 TCs:  64  64  32  32
-		 * We have max 8 queues for FCoE, where 8 the is
-		 * FCoE redirection table size. If TC for FCoE is
-		 * less than or equal to TC3, we have enough queues
-		 * to add max of 8 queues for FCoE, so we start FCoE
-		 * Tx queue from the next one, i.e., reg_idx + 1.
-		 * If TC for FCoE is above TC3, implying 8 TC mode,
-		 * and we need 8 for FCoE, we have to take all queues
-		 * in that traffic class for FCoE.
-		 */
-		if ((f->indices == IXGBE_FCRETA_SIZE) && (fcoe->tc > 3))
-			fcoe_tx_i--;
-	}
-#endif /* CONFIG_IXGBE_DCB */
 	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 		if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
 		    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
@@ -4718,16 +4751,16 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 	if (ixgbe_cache_ring_sriov(adapter))
 		return;
 
+#ifdef CONFIG_IXGBE_DCB
+	if (ixgbe_cache_ring_dcb(adapter))
+		return;
+#endif
+
 #ifdef IXGBE_FCOE
 	if (ixgbe_cache_ring_fcoe(adapter))
 		return;
-
 #endif /* IXGBE_FCOE */
-#ifdef CONFIG_IXGBE_DCB
-	if (ixgbe_cache_ring_dcb(adapter))
-		return;
 
-#endif
 	if (ixgbe_cache_ring_fdir(adapter))
 		return;
 
@@ -5192,7 +5225,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->dcb_set_bitmap = 0x00;
 	adapter->dcbx_cap = DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_CEE;
 	ixgbe_copy_dcb_cfg(&adapter->dcb_cfg, &adapter->temp_dcb_cfg,
-			   adapter->ring_feature[RING_F_DCB].indices);
+			   MAX_TRAFFIC_CLASS);
 
 #endif
 
@@ -6664,18 +6697,12 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 
 	protocol = vlan_get_protocol(skb);
 
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
+	if (((protocol == htons(ETH_P_FCOE)) ||
+	    (protocol == htons(ETH_P_FIP))) &&
+	    (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)) {
+		txq &= (adapter->ring_feature[RING_F_FCOE].indices - 1);
+		txq += adapter->ring_feature[RING_F_FCOE].mask;
+		return txq;
 	}
 #endif
 
@@ -6685,15 +6712,6 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 		return txq;
 	}
 
-	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-		if (skb->priority == TC_PRIO_CONTROL)
-			txq = adapter->ring_feature[RING_F_DCB].indices-1;
-		else
-			txq = (skb->vlan_tci & IXGBE_TX_FLAGS_VLAN_PRIO_MASK)
-			       >> 13;
-		return txq;
-	}
-
 	return skb_tx_hash(dev, skb);
 }
 
@@ -6715,13 +6733,13 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 		tx_flags |= vlan_tx_tag_get(skb);
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 			tx_flags &= ~IXGBE_TX_FLAGS_VLAN_PRIO_MASK;
-			tx_flags |= ((skb->queue_mapping & 0x7) << 13);
+			tx_flags |= tx_ring->dcb_tc << 13;
 		}
 		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 	} else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED &&
 		   skb->priority != TC_PRIO_CONTROL) {
-		tx_flags |= ((skb->queue_mapping & 0x7) << 13);
+		tx_flags |= tx_ring->dcb_tc << 13;
 		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 	}
@@ -6730,20 +6748,8 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 	/* for FCoE with DCB, we force the priority to what
 	 * was specified by the switch */
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED &&
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
-		/* flag for FCoE offloads */
-		if (protocol == htons(ETH_P_FCOE))
-			tx_flags |= IXGBE_TX_FLAGS_FCOE;
-	}
+	    (protocol == htons(ETH_P_FCOE)))
+		tx_flags |= IXGBE_TX_FLAGS_FCOE;
 #endif
 
 	/* four things can cause us to need a context descriptor */
@@ -7157,8 +7163,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	else
 		indices = min_t(unsigned int, indices, IXGBE_MAX_FDIR_INDICES);
 
+#if defined(CONFIG_DCB)
 	indices = max_t(unsigned int, indices, IXGBE_MAX_DCB_INDICES);
-#ifdef IXGBE_FCOE
+#elif defined(IXGBE_FCOE)
 	indices += min_t(unsigned int, num_possible_cpus(),
 			 IXGBE_MAX_FCOE_INDICES);
 #endif
-- 
1.7.4

