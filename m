From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 07/10] ixgbe: Enable Flow Director hashing in 82599
Date: Thu, 04 Jun 2009 19:01:43 -0700
Message-ID: <20090605020143.8468.86760.stgit@localhost.localdomain>
References: <20090605015948.8468.25862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:59348 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752204AbZFECCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 22:02:00 -0400
In-Reply-To: <20090605015948.8468.25862.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

This patch enables Flow Director's ATR functionality to the main base
driver for 82599.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |   12 ++
 drivers/net/ixgbe/ixgbe_ethtool.c |    2 
 drivers/net/ixgbe/ixgbe_main.c    |  215 +++++++++++++++++++++++++++++++++++++
 3 files changed, 228 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 7adf959..f2206e2 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -126,6 +126,8 @@ struct ixgbe_ring {
 	unsigned int count;		/* amount of descriptors */
 	unsigned int next_to_use;
 	unsigned int next_to_clean;
+	u8 atr_sample_rate;
+	u8 atr_count;
 
 	int queue_index; /* needed for multiqueue queue management */
 	union {
@@ -148,6 +150,7 @@ struct ixgbe_ring {
 	int cpu;
 #endif
 	struct ixgbe_queue_stats stats;
+	unsigned long reinit_state;
 
 	u16 work_limit;                /* max work per interrupt */
 	u16 rx_buf_len;
@@ -159,6 +162,7 @@ enum ixgbe_ring_f_enum {
 	RING_F_DCB,
 	RING_F_VMDQ,
 	RING_F_RSS,
+	RING_F_FDIR,
 #ifdef IXGBE_FCOE
 	RING_F_FCOE,
 #endif /* IXGBE_FCOE */
@@ -169,6 +173,7 @@ enum ixgbe_ring_f_enum {
 #define IXGBE_MAX_DCB_INDICES   8
 #define IXGBE_MAX_RSS_INDICES  16
 #define IXGBE_MAX_VMDQ_INDICES 16
+#define IXGBE_MAX_FDIR_INDICES 64
 #ifdef IXGBE_FCOE
 #define IXGBE_MAX_FCOE_INDICES  8
 #endif /* IXGBE_FCOE */
@@ -317,6 +322,8 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_IN_WATCHDOG_TASK             (u32)(1 << 23)
 #define IXGBE_FLAG_IN_SFP_LINK_TASK             (u32)(1 << 24)
 #define IXGBE_FLAG_IN_SFP_MOD_TASK              (u32)(1 << 25)
+#define IXGBE_FLAG_FDIR_HASH_CAPABLE            (u32)(1 << 26)
+#define IXGBE_FLAG_FDIR_PERFECT_CAPABLE         (u32)(1 << 27)
 #define IXGBE_FLAG_FCOE_ENABLED                 (u32)(1 << 29)
 
 	u32 flags2;
@@ -356,6 +363,10 @@ struct ixgbe_adapter {
 	struct timer_list sfp_timer;
 	struct work_struct multispeed_fiber_task;
 	struct work_struct sfp_config_module_task;
+	u32 fdir_pballoc;
+	u32 atr_sample_rate;
+	spinlock_t fdir_perfect_lock;
+	struct work_struct fdir_reinit_task;
 #ifdef IXGBE_FCOE
 	struct ixgbe_fcoe fcoe;
 #endif /* IXGBE_FCOE */
@@ -368,6 +379,7 @@ enum ixbge_state_t {
 	__IXGBE_TESTING,
 	__IXGBE_RESETTING,
 	__IXGBE_DOWN,
+	__IXGBE_FDIR_INIT_DONE,
 	__IXGBE_SFP_MODULE_NOT_FOUND
 };
 
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index ce9cf7e..86f4f3e 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -68,6 +68,8 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"rx_crc_errors", IXGBE_STAT(net_stats.rx_crc_errors)},
 	{"rx_frame_errors", IXGBE_STAT(net_stats.rx_frame_errors)},
 	{"hw_rsc_count", IXGBE_STAT(rsc_count)},
+	{"fdir_match", IXGBE_STAT(stats.fdirmatch)},
+	{"fdir_miss", IXGBE_STAT(stats.fdirmiss)},
 	{"rx_fifo_errors", IXGBE_STAT(net_stats.rx_fifo_errors)},
 	{"rx_missed_errors", IXGBE_STAT(net_stats.rx_missed_errors)},
 	{"tx_aborted_errors", IXGBE_STAT(net_stats.tx_aborted_errors)},
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2553173..ca7c5d5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1123,8 +1123,24 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		ixgbe_check_fan_failure(adapter, eicr);
 
-	if (hw->mac.type == ixgbe_mac_82599EB)
+	if (hw->mac.type == ixgbe_mac_82599EB) {
 		ixgbe_check_sfp_event(adapter, eicr);
+
+		/* Handle Flow Director Full threshold interrupt */
+		if (eicr & IXGBE_EICR_FLOW_DIR) {
+			int i;
+			IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_FLOW_DIR);
+			/* Disable transmits before FDIR Re-initialization */
+			netif_tx_stop_all_queues(netdev);
+			for (i = 0; i < adapter->num_tx_queues; i++) {
+				struct ixgbe_ring *tx_ring =
+				                           &adapter->tx_ring[i];
+				if (test_and_clear_bit(__IXGBE_FDIR_INIT_DONE,
+				                       &tx_ring->reinit_state))
+					schedule_work(&adapter->fdir_reinit_task);
+			}
+		}
+	}
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
 		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMS_OTHER);
 
@@ -1623,6 +1639,9 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
 		mask |= IXGBE_EIMS_GPI_SDP1;
 		mask |= IXGBE_EIMS_GPI_SDP2;
 	}
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
+	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
+		mask |= IXGBE_EIMS_FLOW_DIR;
 
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
 	ixgbe_irq_enable_queues(adapter, ~0);
@@ -2376,6 +2395,7 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 static void ixgbe_configure(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
+	struct ixgbe_hw *hw = &adapter->hw;
 	int i;
 
 	ixgbe_set_rx_mode(netdev);
@@ -2397,6 +2417,15 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 		ixgbe_configure_fcoe(adapter);
 
 #endif /* IXGBE_FCOE */
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			adapter->tx_ring[i].atr_sample_rate =
+			                               adapter->atr_sample_rate;
+		ixgbe_init_fdir_signature_82599(hw, adapter->fdir_pballoc);
+	} else if (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE) {
+		ixgbe_init_fdir_perfect_82599(hw, adapter->fdir_pballoc);
+	}
+
 	ixgbe_configure_tx(adapter);
 	ixgbe_configure_rx(adapter);
 	for (i = 0; i < adapter->num_rx_queues; i++)
@@ -2653,6 +2682,10 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 			DPRINTK(PROBE, ERR, "link_config FAILED %d\n", err);
 	}
 
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		set_bit(__IXGBE_FDIR_INIT_DONE,
+		        &(adapter->tx_ring[i].reinit_state));
+
 	/* enable transmits */
 	netif_tx_start_all_queues(netdev);
 
@@ -2848,6 +2881,10 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	del_timer_sync(&adapter->watchdog_timer);
 	cancel_work_sync(&adapter->watchdog_task);
 
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
+	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
+		cancel_work_sync(&adapter->fdir_reinit_task);
+
 	/* disable transmits in the hardware now that interrupts are off */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		j = adapter->tx_ring[i].reg_idx;
@@ -2982,6 +3019,38 @@ static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 	return ret;
 }
 
+/**
+ * ixgbe_set_fdir_queues: Allocate queues for Flow Director
+ * @adapter: board private structure to initialize
+ *
+ * Flow Director is an advanced Rx filter, attempting to get Rx flows back
+ * to the original CPU that initiated the Tx session.  This runs in addition
+ * to RSS, so if a packet doesn't match an FDIR filter, we can still spread the
+ * Rx load across CPUs using RSS.
+ *
+ **/
+static bool inline ixgbe_set_fdir_queues(struct ixgbe_adapter *adapter)
+{
+	bool ret = false;
+	struct ixgbe_ring_feature *f_fdir = &adapter->ring_feature[RING_F_FDIR];
+
+	f_fdir->indices = min((int)num_online_cpus(), f_fdir->indices);
+	f_fdir->mask = 0;
+
+	/* Flow Director must have RSS enabled */
+	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED &&
+	    ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
+	     (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)))) {
+		adapter->num_tx_queues = f_fdir->indices;
+		adapter->num_rx_queues = f_fdir->indices;
+		ret = true;
+	} else {
+		adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+		adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+	}
+	return ret;
+}
+
 #ifdef IXGBE_FCOE
 /**
  * ixgbe_set_fcoe_queues: Allocate queues for Fiber Channel over Ethernet (FCoE)
@@ -3046,6 +3115,9 @@ static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 		goto done;
 
 #endif
+	if (ixgbe_set_fdir_queues(adapter))
+		goto done;
+
 	if (ixgbe_set_rss_queues(adapter))
 		goto done;
 
@@ -3216,6 +3288,31 @@ static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 }
 #endif
 
+/**
+ * ixgbe_cache_ring_fdir - Descriptor ring to register mapping for Flow Director
+ * @adapter: board private structure to initialize
+ *
+ * Cache the descriptor ring offsets for Flow Director to the assigned rings.
+ *
+ **/
+static bool inline ixgbe_cache_ring_fdir(struct ixgbe_adapter *adapter)
+{
+	int i;
+	bool ret = false;
+
+	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED &&
+	    ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
+	     (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))) {
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			adapter->rx_ring[i].reg_idx = i;
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			adapter->tx_ring[i].reg_idx = i;
+		ret = true;
+	}
+
+	return ret;
+}
+
 #ifdef IXGBE_FCOE
 /**
  * ixgbe_cache_ring_fcoe - Descriptor ring to register mapping for the FCoE
@@ -3276,6 +3373,9 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 		return;
 
 #endif
+	if (ixgbe_cache_ring_fdir(adapter))
+		return;
+
 	if (ixgbe_cache_ring_rss(adapter))
 		return;
 }
@@ -3369,6 +3469,9 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 
 	adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
 	adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
+	adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+	adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+	adapter->atr_sample_rate = 0;
 	ixgbe_set_num_queues(adapter);
 
 	err = pci_enable_msi(adapter->pdev);
@@ -3634,6 +3737,11 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82599;
 		adapter->flags |= IXGBE_FLAG2_RSC_CAPABLE;
 		adapter->flags |= IXGBE_FLAG2_RSC_ENABLED;
+		adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
+		adapter->ring_feature[RING_F_FDIR].indices =
+		                                         IXGBE_MAX_FDIR_INDICES;
+		adapter->atr_sample_rate = 20;
+		adapter->fdir_pballoc = 0;
 #ifdef IXGBE_FCOE
 		adapter->flags |= IXGBE_FLAG_FCOE_ENABLED;
 		adapter->ring_feature[RING_F_FCOE].indices = IXGBE_FCRETA_SIZE;
@@ -4223,6 +4331,8 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		IXGBE_READ_REG(hw, IXGBE_TORH); /* to clear */
 		adapter->stats.lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXCNT);
 		adapter->stats.lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXCNT);
+		adapter->stats.fdirmatch += IXGBE_READ_REG(hw, IXGBE_FDIRMATCH);
+		adapter->stats.fdirmiss += IXGBE_READ_REG(hw, IXGBE_FDIRMISS);
 #ifdef IXGBE_FCOE
 		adapter->stats.fccrc += IXGBE_READ_REG(hw, IXGBE_FCCRC);
 		adapter->stats.fcoerpdc += IXGBE_READ_REG(hw, IXGBE_FCOERPDC);
@@ -4388,6 +4498,30 @@ static void ixgbe_sfp_config_module_task(struct work_struct *work)
 }
 
 /**
+ * ixgbe_fdir_reinit_task - worker thread to reinit FDIR filter table
+ * @work: pointer to work_struct containing our data
+ **/
+static void ixgbe_fdir_reinit_task(struct work_struct *work)
+{
+	struct ixgbe_adapter *adapter = container_of(work,
+	                                             struct ixgbe_adapter,
+	                                             fdir_reinit_task);
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i;
+
+	if (ixgbe_reinit_fdir_tables_82599(hw) == 0) {
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			set_bit(__IXGBE_FDIR_INIT_DONE,
+			        &(adapter->tx_ring[i].reinit_state));
+	} else {
+		DPRINTK(PROBE, ERR, "failed to finish FDIR re-initialization, "
+		        "ignored adding FDIR ATR filters \n");
+	}
+	/* Done FDIR Re-initialization, enable transmits */
+	netif_tx_start_all_queues(adapter->netdev);
+}
+
+/**
  * ixgbe_watchdog_task - worker thread to bring link up
  * @work: pointer to work_struct containing our data
  **/
@@ -4814,6 +4948,58 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 	writel(i, adapter->hw.hw_addr + tx_ring->tail);
 }
 
+static void ixgbe_atr(struct ixgbe_adapter *adapter, struct sk_buff *skb,
+	              int queue, u32 tx_flags)
+{
+	/* Right now, we support IPv4 only */
+	struct ixgbe_atr_input atr_input;
+	struct tcphdr *th;
+	struct udphdr *uh;
+	struct iphdr *iph = ip_hdr(skb);
+	struct ethhdr *eth = (struct ethhdr *)skb->data;
+	u16 vlan_id, src_port, dst_port, flex_bytes;
+	u32 src_ipv4_addr, dst_ipv4_addr;
+	u8 l4type = 0;
+
+	/* check if we're UDP or TCP */
+	if (iph->protocol == IPPROTO_TCP) {
+		th = tcp_hdr(skb);
+		src_port = th->source;
+		dst_port = th->dest;
+		l4type |= IXGBE_ATR_L4TYPE_TCP;
+		/* l4type IPv4 type is 0, no need to assign */
+	} else if(iph->protocol == IPPROTO_UDP) {
+		uh = udp_hdr(skb);
+		src_port = uh->source;
+		dst_port = uh->dest;
+		l4type |= IXGBE_ATR_L4TYPE_UDP;
+		/* l4type IPv4 type is 0, no need to assign */
+	} else {
+		/* Unsupported L4 header, just bail here */
+		return;
+	}
+
+	memset(&atr_input, 0, sizeof(struct ixgbe_atr_input));
+
+	vlan_id = (tx_flags & IXGBE_TX_FLAGS_VLAN_MASK) >>
+	           IXGBE_TX_FLAGS_VLAN_SHIFT;
+	src_ipv4_addr = iph->saddr;
+	dst_ipv4_addr = iph->daddr;
+	flex_bytes = eth->h_proto;
+
+	ixgbe_atr_set_vlan_id_82599(&atr_input, vlan_id);
+	ixgbe_atr_set_src_port_82599(&atr_input, dst_port);
+	ixgbe_atr_set_dst_port_82599(&atr_input, src_port);
+	ixgbe_atr_set_flex_byte_82599(&atr_input, flex_bytes);
+	ixgbe_atr_set_l4type_82599(&atr_input, l4type);
+	/* src and dst are inverted, think how the receiver sees them */
+	ixgbe_atr_set_src_ipv4_82599(&atr_input, dst_ipv4_addr);
+	ixgbe_atr_set_dst_ipv4_82599(&atr_input, src_ipv4_addr);
+
+	/* This assumes the Rx queue and Tx queue are bound to the same CPU */
+	ixgbe_fdir_add_signature_filter_82599(&adapter->hw, &atr_input, queue);
+}
+
 static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
                                  struct ixgbe_ring *tx_ring, int size)
 {
@@ -4848,6 +5034,9 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
+		return smp_processor_id();
+
 	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
 		return 0;  /* All traffic should default to class 0 */
 
@@ -4932,6 +5121,17 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	count = ixgbe_tx_map(adapter, tx_ring, skb, tx_flags, first);
 	if (count) {
+		/* add the ATR filter if ATR is on */
+		if (tx_ring->atr_sample_rate) {
+			++tx_ring->atr_count;
+			if ((tx_ring->atr_count >= tx_ring->atr_sample_rate) &&
+		             test_bit(__IXGBE_FDIR_INIT_DONE,
+                                      &tx_ring->reinit_state)) {
+				ixgbe_atr(adapter, skb, tx_ring->queue_index,
+				          tx_flags);
+				tx_ring->atr_count = 0;
+			}
+		}
 		ixgbe_tx_queue(adapter, tx_ring, tx_flags, count, skb->len,
 		               hdr_len);
 		ixgbe_maybe_stop_tx(netdev, tx_ring, DESC_NEEDED);
@@ -5314,6 +5514,12 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 				netdev->features |= NETIF_F_FCOE_CRC;
 				netdev->features |= NETIF_F_FSO;
 				netdev->fcoe_ddp_xid = IXGBE_FCOE_DDP_MAX - 1;
+				DPRINTK(DRV, INFO, "FCoE enabled, "
+					"disabling Flow Director\n");
+				adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+				adapter->flags &=
+				        ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+				adapter->atr_sample_rate = 0;
 			} else {
 				adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
 			}
@@ -5412,6 +5618,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	/* carrier off reporting is important to ethtool even BEFORE open */
 	netif_carrier_off(netdev);
 
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
+	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
+		INIT_WORK(&adapter->fdir_reinit_task, ixgbe_fdir_reinit_task);
+
 #ifdef CONFIG_IXGBE_DCA
 	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
@@ -5474,6 +5684,9 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	cancel_work_sync(&adapter->sfp_task);
 	cancel_work_sync(&adapter->multispeed_fiber_task);
 	cancel_work_sync(&adapter->sfp_config_module_task);
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
+	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
+		cancel_work_sync(&adapter->fdir_reinit_task);
 	flush_scheduled_work();
 
 #ifdef CONFIG_IXGBE_DCA

