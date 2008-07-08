From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 20/20] igb: Improve multiqueue AIM support
Date: Tue, 08 Jul 2008 15:14:44 -0700
Message-ID: <20080708221410.1518.8236.stgit@localhost.localdomain>
References: <20080708220046.1518.88457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36588 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755316AbYGHWOp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:14:45 -0400
In-Reply-To: <20080708220046.1518.88457.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Improve multiqueue performance
Change itr_val to reflect ITR timer value instead of ints/sec
Cleaned up AIM algorithms in general

Based on work by Mitch Williams

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h         |    8 +-
 drivers/net/igb/igb_ethtool.c |   17 +++-
 drivers/net/igb/igb_main.c    |  169 ++++++++++++++++++++++++-----------------
 3 files changed, 113 insertions(+), 81 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index c25ca17..56de7ec 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -47,7 +47,9 @@ struct igb_adapter;
 
 #define IGB_MIN_DYN_ITR 3000
 #define IGB_MAX_DYN_ITR 96000
-#define IGB_START_ITR 6000
+
+/* ((1000000000ns / (6000ints/s * 1024ns)) << 2 = 648 */
+#define IGB_START_ITR 648
 
 #define IGB_DYN_ITR_PACKET_THRESHOLD 2
 #define IGB_DYN_ITR_LENGTH_LOW 200
@@ -170,9 +172,10 @@ struct igb_ring {
 		};
 		/* RX */
 		struct {
-			int no_itr_adjust;
 			struct igb_queue_stats rx_stats;
 			struct napi_struct napi;
+			int set_itr;
+			struct igb_ring *buddy;
 #ifdef CONFIG_IGB_LRO
 			struct net_lro_mgr lro_mgr;
 			bool lro_used;
@@ -219,7 +222,6 @@ struct igb_adapter {
 	u32 itr_setting;
 	u16 tx_itr;
 	u16 rx_itr;
-	int set_itr;
 
 	struct work_struct reset_task;
 	struct work_struct watchdog_task;
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 7db1830..11aee13 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1861,6 +1861,8 @@ static int igb_set_coalesce(struct net_device *netdev,
 			    struct ethtool_coalesce *ec)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	int i;
 
 	if ((ec->rx_coalesce_usecs > IGB_MAX_ITR_USECS) ||
 	    ((ec->rx_coalesce_usecs > 3) &&
@@ -1869,13 +1871,16 @@ static int igb_set_coalesce(struct net_device *netdev,
 		return -EINVAL;
 
 	/* convert to rate of irq's per second */
-	if (ec->rx_coalesce_usecs <= 3)
+	if (ec->rx_coalesce_usecs && ec->rx_coalesce_usecs <= 3) {
 		adapter->itr_setting = ec->rx_coalesce_usecs;
-	else
-		adapter->itr_setting = (1000000 / ec->rx_coalesce_usecs);
+		adapter->itr = IGB_START_ITR;
+	} else {
+		adapter->itr_setting = ec->rx_coalesce_usecs << 2;
+		adapter->itr = adapter->itr_setting;
+	}
 
-	if (netif_running(netdev))
-		igb_reinit_locked(adapter);
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		wr32(adapter->rx_ring[i].itr_register, adapter->itr);
 
 	return 0;
 }
@@ -1888,7 +1893,7 @@ static int igb_get_coalesce(struct net_device *netdev,
 	if (adapter->itr_setting <= 3)
 		ec->rx_coalesce_usecs = adapter->itr_setting;
 	else
-		ec->rx_coalesce_usecs = 1000000 / adapter->itr_setting;
+		ec->rx_coalesce_usecs = adapter->itr_setting >> 2;
 
 	return 0;
 }
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 2a5303c..aaed129 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -255,6 +255,8 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 		return -ENOMEM;
 	}
 
+	adapter->rx_ring->buddy = adapter->tx_ring;
+
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		struct igb_ring *ring = &(adapter->tx_ring[i]);
 		ring->adapter = adapter;
@@ -375,7 +377,7 @@ static void igb_configure_msix(struct igb_adapter *adapter)
 		igb_assign_vector(adapter, IGB_N0_QUEUE, i, vector++);
 		adapter->eims_enable_mask |= tx_ring->eims_value;
 		if (tx_ring->itr_val)
-			writel(1000000000 / (tx_ring->itr_val * 256),
+			writel(tx_ring->itr_val,
 			       hw->hw_addr + tx_ring->itr_register);
 		else
 			writel(1, hw->hw_addr + tx_ring->itr_register);
@@ -383,10 +385,11 @@ static void igb_configure_msix(struct igb_adapter *adapter)
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct igb_ring *rx_ring = &adapter->rx_ring[i];
+		rx_ring->buddy = 0;
 		igb_assign_vector(adapter, i, IGB_N0_QUEUE, vector++);
 		adapter->eims_enable_mask |= rx_ring->eims_value;
 		if (rx_ring->itr_val)
-			writel(1000000000 / (rx_ring->itr_val * 256),
+			writel(rx_ring->itr_val,
 			       hw->hw_addr + rx_ring->itr_register);
 		else
 			writel(1, hw->hw_addr + rx_ring->itr_register);
@@ -449,7 +452,7 @@ static int igb_request_msix(struct igb_adapter *adapter)
 		if (err)
 			goto out;
 		ring->itr_register = E1000_EITR(0) + (vector << 2);
-		ring->itr_val = adapter->itr;
+		ring->itr_val = 976; /* ~4000 ints/sec */
 		vector++;
 	}
 	for (i = 0; i < adapter->num_rx_queues; i++) {
@@ -1898,8 +1901,7 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 	mdelay(10);
 
 	if (adapter->itr_setting > 3)
-		wr32(E1000_ITR,
-				1000000000 / (adapter->itr * 256));
+		wr32(E1000_ITR, adapter->itr);
 
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring */
@@ -2463,38 +2465,60 @@ enum latency_range {
 };
 
 
-static void igb_lower_rx_eitr(struct igb_adapter *adapter,
-			      struct igb_ring *rx_ring)
+/**
+ * igb_update_ring_itr - update the dynamic ITR value based on packet size
+ *
+ *      Stores a new ITR value based on strictly on packet size.  This
+ *      algorithm is less sophisticated than that used in igb_update_itr,
+ *      due to the difficulty of synchronizing statistics across multiple
+ *      receive rings.  The divisors and thresholds used by this fuction
+ *      were determined based on theoretical maximum wire speed and testing
+ *      data, in order to minimize response time while increasing bulk
+ *      throughput.
+ *      This functionality is controlled by the InterruptThrottleRate module
+ *      parameter (see igb_param.c)
+ *      NOTE:  This function is called only when operating in a multiqueue
+ *             receive environment.
+ * @rx_ring: pointer to ring
+ **/
+static void igb_update_ring_itr(struct igb_ring *rx_ring)
 {
-	struct e1000_hw *hw = &adapter->hw;
-	int new_val;
+	int new_val = rx_ring->itr_val;
+	int avg_wire_size = 0;
+	struct igb_adapter *adapter = rx_ring->adapter;
 
-	new_val = rx_ring->itr_val / 2;
-	if (new_val < IGB_MIN_DYN_ITR)
-		new_val = IGB_MIN_DYN_ITR;
+	if (!rx_ring->total_packets)
+		goto clear_counts; /* no packets, so don't do anything */
 
-	if (new_val != rx_ring->itr_val) {
-		rx_ring->itr_val = new_val;
-		wr32(rx_ring->itr_register,
-				1000000000 / (new_val * 256));
+	/* For non-gigabit speeds, just fix the interrupt rate at 4000
+	 * ints/sec - ITR timer value of 120 ticks.
+	 */
+	if (adapter->link_speed != SPEED_1000) {
+		new_val = 120;
+		goto set_itr_val;
 	}
-}
+	avg_wire_size = rx_ring->total_bytes / rx_ring->total_packets;
 
-static void igb_raise_rx_eitr(struct igb_adapter *adapter,
-			      struct igb_ring *rx_ring)
-{
-	struct e1000_hw *hw = &adapter->hw;
-	int new_val;
+	/* Add 24 bytes to size to account for CRC, preamble, and gap */
+	avg_wire_size += 24;
+
+	/* Don't starve jumbo frames */
+	avg_wire_size = min(avg_wire_size, 3000);
 
-	new_val = rx_ring->itr_val * 2;
-	if (new_val > IGB_MAX_DYN_ITR)
-		new_val = IGB_MAX_DYN_ITR;
+	/* Give a little boost to mid-size frames */
+	if ((avg_wire_size > 300) && (avg_wire_size < 1200))
+		new_val = avg_wire_size / 3;
+	else
+		new_val = avg_wire_size / 2;
 
+set_itr_val:
 	if (new_val != rx_ring->itr_val) {
 		rx_ring->itr_val = new_val;
-		wr32(rx_ring->itr_register,
-				1000000000 / (new_val * 256));
+		rx_ring->set_itr = 1;
 	}
+clear_counts:
+	rx_ring->total_bytes = 0;
+	rx_ring->total_packets = 0;
 }
 
 /**
@@ -2561,8 +2585,7 @@ update_itr_done:
 	return retval;
 }
 
-static void igb_set_itr(struct igb_adapter *adapter, u16 itr_register,
-			int rx_only)
+static void igb_set_itr(struct igb_adapter *adapter)
 {
 	u16 current_itr;
 	u32 new_itr = adapter->itr;
@@ -2578,26 +2601,23 @@ static void igb_set_itr(struct igb_adapter *adapter, u16 itr_register,
 				    adapter->rx_itr,
 				    adapter->rx_ring->total_packets,
 				    adapter->rx_ring->total_bytes);
-	/* conservative mode (itr 3) eliminates the lowest_latency setting */
-	if (adapter->itr_setting == 3 && adapter->rx_itr == lowest_latency)
-		adapter->rx_itr = low_latency;
 
-	if (!rx_only) {
+	if (adapter->rx_ring->buddy) {
 		adapter->tx_itr = igb_update_itr(adapter,
 					    adapter->tx_itr,
 					    adapter->tx_ring->total_packets,
 					    adapter->tx_ring->total_bytes);
-		/* conservative mode (itr 3) eliminates the
-		 * lowest_latency setting */
-		if (adapter->itr_setting == 3 &&
-		    adapter->tx_itr == lowest_latency)
-			adapter->tx_itr = low_latency;
 
 		current_itr = max(adapter->rx_itr, adapter->tx_itr);
 	} else {
 		current_itr = adapter->rx_itr;
 	}
 
+	/* conservative mode (itr 3) eliminates the lowest_latency setting */
+	if (adapter->itr_setting == 3 &&
+	    current_itr == lowest_latency)
+		current_itr = low_latency;
+
 	switch (current_itr) {
 	/* counts and packets in update_itr are dependent on these numbers */
 	case lowest_latency:
@@ -2614,6 +2634,13 @@ static void igb_set_itr(struct igb_adapter *adapter, u16 itr_register,
 	}
 
 set_itr_now:
+	adapter->rx_ring->total_bytes = 0;
+	adapter->rx_ring->total_packets = 0;
+	if (adapter->rx_ring->buddy) {
+		adapter->rx_ring->buddy->total_bytes = 0;
+		adapter->rx_ring->buddy->total_packets = 0;
+	}
+
 	if (new_itr != adapter->itr) {
 		/* this attempts to bias the interrupt rate towards Bulk
 		 * by adding intermediate steps when interrupt rate is
@@ -2628,7 +2655,8 @@ set_itr_now:
 		 * ends up being correct.
 		 */
 		adapter->itr = new_itr;
-		adapter->set_itr = 1;
+		adapter->rx_ring->itr_val = 1000000000 / (new_itr * 256);
+		adapter->rx_ring->set_itr = 1;
 	}
 
 	return;
@@ -2979,6 +3007,7 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 		/* this is a hard error */
 		return NETDEV_TX_BUSY;
 	}
+	skb_orphan(skb);
 
 	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		tx_flags |= IGB_TX_FLAGS_VLAN;
@@ -3312,8 +3341,6 @@ static irqreturn_t igb_msix_tx(int irq, void *data)
 	struct igb_adapter *adapter = tx_ring->adapter;
 	struct e1000_hw *hw = &adapter->hw;
 
-	if (!tx_ring->itr_val)
-		wr32(E1000_EIMC, tx_ring->eims_value);
 #ifdef CONFIG_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_tx_dca(tx_ring);
@@ -3332,21 +3359,36 @@ static irqreturn_t igb_msix_tx(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+static void igb_write_itr(struct igb_ring *ring)
+{
+	struct e1000_hw *hw = &ring->adapter->hw;
+	if ((ring->adapter->itr_setting & 3) && ring->set_itr) {
+		switch (hw->mac.type) {
+		case e1000_82576:
+			wr32(ring->itr_register,
+			     ring->itr_val |
+			     0x80000000);
+			break;
+		default:
+			wr32(ring->itr_register,
+			     ring->itr_val |
+			     (ring->itr_val << 16));
+			break;
+		}
+		ring->set_itr = 0;
+	}
+}
+
 static irqreturn_t igb_msix_rx(int irq, void *data)
 {
 	struct igb_ring *rx_ring = data;
 	struct igb_adapter *adapter = rx_ring->adapter;
-	struct e1000_hw *hw = &adapter->hw;
 
 	/* Write the ITR value calculated at the end of the
 	 * previous interrupt.
 	 */
 
-	if (adapter->set_itr) {
-		wr32(rx_ring->itr_register,
-		     1000000000 / (rx_ring->itr_val * 256));
-		adapter->set_itr = 0;
-	}
+	igb_write_itr(rx_ring);
 
 	if (netif_rx_schedule_prep(adapter->netdev, &rx_ring->napi))
 		__netif_rx_schedule(adapter->netdev, &rx_ring->napi);
@@ -3493,13 +3535,7 @@ static irqreturn_t igb_intr_msi(int irq, void *data)
 	/* read ICR disables interrupts using IAM */
 	u32 icr = rd32(E1000_ICR);
 
-	/* Write the ITR value calculated at the end of the
-	 * previous interrupt.
-	 */
-	if (adapter->set_itr) {
-		wr32(E1000_ITR, 1000000000 / (adapter->itr * 256));
-		adapter->set_itr = 0;
-	}
+	igb_write_itr(adapter->rx_ring);
 
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->mac.get_link_status = 1;
@@ -3529,13 +3565,7 @@ static irqreturn_t igb_intr(int irq, void *data)
 	if (!icr)
 		return IRQ_NONE;  /* Not our interrupt */
 
-	/* Write the ITR value calculated at the end of the
-	 * previous interrupt.
-	 */
-	if (adapter->set_itr) {
-		wr32(E1000_ITR, 1000000000 / (adapter->itr * 256));
-		adapter->set_itr = 0;
-	}
+	igb_write_itr(adapter->rx_ring);
 
 	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is
 	 * not set, then the adapter didn't send an interrupt */
@@ -3585,7 +3615,7 @@ static int igb_poll(struct napi_struct *napi, int budget)
 	if ((tx_clean_complete && (work_done < budget)) ||
 	    !netif_running(netdev)) {
 		if (adapter->itr_setting & 3)
-			igb_set_itr(adapter, E1000_ITR, false);
+			igb_set_itr(adapter);
 		netif_rx_complete(netdev, napi);
 		if (!test_bit(__IGB_DOWN, &adapter->state))
 			igb_irq_enable(adapter);
@@ -3619,15 +3649,11 @@ static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
 quit_polling:
 		netif_rx_complete(netdev, napi);
 
-		wr32(E1000_EIMS, rx_ring->eims_value);
-		if ((adapter->itr_setting & 3) && !rx_ring->no_itr_adjust &&
-		    (rx_ring->total_packets > IGB_DYN_ITR_PACKET_THRESHOLD)) {
-			int mean_size = rx_ring->total_bytes /
-					rx_ring->total_packets;
-			if (mean_size < IGB_DYN_ITR_LENGTH_LOW)
-				igb_raise_rx_eitr(adapter, rx_ring);
-			else if (mean_size > IGB_DYN_ITR_LENGTH_HIGH)
-				igb_lower_rx_eitr(adapter, rx_ring);
+		if (adapter->itr_setting & 3) {
+			if (adapter->num_rx_queues == 1)
+				igb_set_itr(adapter);
+			else
+				igb_update_ring_itr(rx_ring);
 		}
 
 		if (!test_bit(__IGB_DOWN, &adapter->state))
@@ -3972,7 +3998,6 @@ send_up:
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
 		}
-		rx_ring->no_itr_adjust |= (staterr & E1000_RXD_STAT_DYNINT);
 
 		total_bytes += skb->len;
 		total_packets++;

