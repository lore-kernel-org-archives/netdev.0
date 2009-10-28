From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 01/23] igb: add support for seperate tx-usecs
	setting in ethtool
Date: Wed, 28 Oct 2009 02:45:42 -0700
Message-ID: <20091028094540.13156.2637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:39866 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751635AbZJ1Jt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:49:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for a seperate tx-usecs interrupt moderation setting
in ethtool which is supported when tx and rx interrupt vectors are sperated.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h         |    5 +++-
 drivers/net/igb/igb_ethtool.c |   49 +++++++++++++++++++++++++++++++----------
 drivers/net/igb/igb_main.c    |   22 ++++++++++++------
 3 files changed, 54 insertions(+), 22 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 6c35c90..bef8cdc 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -249,8 +249,8 @@ struct igb_adapter {
 	unsigned int total_rx_bytes;
 	unsigned int total_rx_packets;
 	/* Interrupt Throttle Rate */
-	u32 itr;
-	u32 itr_setting;
+	u32 rx_itr_setting;
+	u32 tx_itr_setting;
 	u16 tx_itr;
 	u16 rx_itr;
 
@@ -321,6 +321,7 @@ struct igb_adapter {
 #define IGB_FLAG_HAS_MSI           (1 << 0)
 #define IGB_FLAG_DCA_ENABLED       (1 << 1)
 #define IGB_FLAG_QUAD_PORT_A       (1 << 2)
+#define IGB_FLAG_QUEUE_PAIRS       (1 << 3)
 
 enum e1000_state_t {
 	__IGB_TESTING,
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 048a615..84fe25a 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1827,18 +1827,37 @@ static int igb_set_coalesce(struct net_device *netdev,
 	    (ec->rx_coalesce_usecs == 2))
 		return -EINVAL;
 
+	if ((ec->tx_coalesce_usecs > IGB_MAX_ITR_USECS) ||
+	    ((ec->tx_coalesce_usecs > 3) &&
+	     (ec->tx_coalesce_usecs < IGB_MIN_ITR_USECS)) ||
+	    (ec->tx_coalesce_usecs == 2))
+		return -EINVAL;
+
+	if ((adapter->flags & IGB_FLAG_QUEUE_PAIRS) && ec->tx_coalesce_usecs)
+		return -EINVAL;
+
 	/* convert to rate of irq's per second */
-	if (ec->rx_coalesce_usecs && ec->rx_coalesce_usecs <= 3) {
-		adapter->itr_setting = ec->rx_coalesce_usecs;
-		adapter->itr = IGB_START_ITR;
-	} else {
-		adapter->itr_setting = ec->rx_coalesce_usecs << 2;
-		adapter->itr = adapter->itr_setting;
-	}
+	if (ec->rx_coalesce_usecs && ec->rx_coalesce_usecs <= 3)
+		adapter->rx_itr_setting = ec->rx_coalesce_usecs;
+	else
+		adapter->rx_itr_setting = ec->rx_coalesce_usecs << 2;
+
+	/* convert to rate of irq's per second */
+	if (adapter->flags & IGB_FLAG_QUEUE_PAIRS)
+		adapter->tx_itr_setting = adapter->rx_itr_setting;
+	else if (ec->tx_coalesce_usecs && ec->tx_coalesce_usecs <= 3)
+		adapter->tx_itr_setting = ec->tx_coalesce_usecs;
+	else
+		adapter->tx_itr_setting = ec->tx_coalesce_usecs << 2;
 
 	for (i = 0; i < adapter->num_q_vectors; i++) {
 		struct igb_q_vector *q_vector = adapter->q_vector[i];
-		q_vector->itr_val = adapter->itr;
+		if (q_vector->rx_ring)
+			q_vector->itr_val = adapter->rx_itr_setting;
+		else
+			q_vector->itr_val = adapter->tx_itr_setting;
+		if (q_vector->itr_val && q_vector->itr_val <= 3)
+			q_vector->itr_val = IGB_START_ITR;
 		q_vector->set_itr = 1;
 	}
 
@@ -1850,15 +1869,21 @@ static int igb_get_coalesce(struct net_device *netdev,
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
-	if (adapter->itr_setting <= 3)
-		ec->rx_coalesce_usecs = adapter->itr_setting;
+	if (adapter->rx_itr_setting <= 3)
+		ec->rx_coalesce_usecs = adapter->rx_itr_setting;
 	else
-		ec->rx_coalesce_usecs = adapter->itr_setting >> 2;
+		ec->rx_coalesce_usecs = adapter->rx_itr_setting >> 2;
+
+	if (!(adapter->flags & IGB_FLAG_QUEUE_PAIRS)) {
+		if (adapter->tx_itr_setting <= 3)
+			ec->tx_coalesce_usecs = adapter->tx_itr_setting;
+		else
+			ec->tx_coalesce_usecs = adapter->tx_itr_setting >> 2;
+	}
 
 	return 0;
 }
 
-
 static int igb_nway_reset(struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index c9fda11..5724ac8 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -734,6 +734,8 @@ msi_only:
 		dev_info(&adapter->pdev->dev, "IOV Disabled\n");
 	}
 #endif
+	adapter->vfs_allocated_count = 0;
+	adapter->flags |= IGB_FLAG_QUEUE_PAIRS;
 	adapter->num_rx_queues = 1;
 	adapter->num_tx_queues = 1;
 	adapter->num_q_vectors = 1;
@@ -791,7 +793,9 @@ static void igb_map_rx_ring_to_vector(struct igb_adapter *adapter,
 	q_vector = adapter->q_vector[v_idx];
 	q_vector->rx_ring = &adapter->rx_ring[ring_idx];
 	q_vector->rx_ring->q_vector = q_vector;
-	q_vector->itr_val = adapter->itr;
+	q_vector->itr_val = adapter->rx_itr_setting;
+	if (q_vector->itr_val && q_vector->itr_val <= 3)
+		q_vector->itr_val = IGB_START_ITR;
 }
 
 static void igb_map_tx_ring_to_vector(struct igb_adapter *adapter,
@@ -802,7 +806,9 @@ static void igb_map_tx_ring_to_vector(struct igb_adapter *adapter,
 	q_vector = adapter->q_vector[v_idx];
 	q_vector->tx_ring = &adapter->tx_ring[ring_idx];
 	q_vector->tx_ring->q_vector = q_vector;
-	q_vector->itr_val = adapter->itr;
+	q_vector->itr_val = adapter->tx_itr_setting;
+	if (q_vector->itr_val && q_vector->itr_val <= 3)
+		q_vector->itr_val = IGB_START_ITR;
 }
 
 /**
@@ -1597,9 +1603,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	hw->fc.requested_mode = e1000_fc_default;
 	hw->fc.current_mode = e1000_fc_default;
 
-	adapter->itr_setting = IGB_DEFAULT_ITR;
-	adapter->itr = IGB_START_ITR;
-
 	igb_validate_mdi_setting(hw);
 
 	/* Initial Wake on LAN setting If APM wake is enabled in the EEPROM,
@@ -1854,6 +1857,9 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 
 	adapter->tx_ring_count = IGB_DEFAULT_TXD;
 	adapter->rx_ring_count = IGB_DEFAULT_RXD;
+	adapter->rx_itr_setting = IGB_DEFAULT_ITR;
+	adapter->tx_itr_setting = IGB_DEFAULT_ITR;
+
 	adapter->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
@@ -3052,7 +3058,6 @@ enum latency_range {
 	latency_invalid = 255
 };
 
-
 /**
  * igb_update_ring_itr - update the dynamic ITR value based on packet size
  *
@@ -3216,7 +3221,7 @@ static void igb_set_itr(struct igb_adapter *adapter)
 	current_itr = max(adapter->rx_itr, adapter->tx_itr);
 
 	/* conservative mode (itr 3) eliminates the lowest_latency setting */
-	if (adapter->itr_setting == 3 && current_itr == lowest_latency)
+	if (adapter->rx_itr_setting == 3 && current_itr == lowest_latency)
 		current_itr = low_latency;
 
 	switch (current_itr) {
@@ -4577,7 +4582,8 @@ static inline void igb_ring_irq_enable(struct igb_q_vector *q_vector)
 	struct igb_adapter *adapter = q_vector->adapter;
 	struct e1000_hw *hw = &adapter->hw;
 
-	if (adapter->itr_setting & 3) {
+	if ((q_vector->rx_ring && (adapter->rx_itr_setting & 3)) ||
+	    (!q_vector->rx_ring && (adapter->tx_itr_setting & 3))) {
 		if (!adapter->msix_entries)
 			igb_set_itr(adapter);
 		else

