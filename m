From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 19/29] fm10k: Add support for multiple queues
Date: Tue, 23 Sep 2014 04:16:47 -0700
Message-ID: <1411471017-28213-20-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:14536 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755556AbaIWLRU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 07:17:20 -0400
In-Reply-To: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch takes the driver from supporting a single queue to supporting
multiple queues.  The upper queue limit for the PF is 128 queues and the
upper limit for the VF is (128 / num_vfs) rounded down to nearest power of 2.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h         |   1 +
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c |  57 +++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 148 +++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |  41 +++++++
 4 files changed, 247 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index d8b0d34..4b6f406 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -422,6 +422,7 @@ void fm10k_unmap_and_free_tx_resource(struct fm10k_ring *,
 				      struct fm10k_tx_buffer *);
 void fm10k_restore_rx_state(struct fm10k_intfc *);
 void fm10k_reset_rx_state(struct fm10k_intfc *);
+int fm10k_setup_tc(struct net_device *dev, u8 tc);
 int fm10k_open(struct net_device *netdev);
 int fm10k_close(struct net_device *netdev);
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index a88c75c..54e8ebd 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -838,6 +838,61 @@ static int fm10k_set_rssh(struct net_device *netdev, const u32 *indir,
 	return 0;
 }
 
+static unsigned int fm10k_max_channels(struct net_device *dev)
+{
+	struct fm10k_intfc *interface = netdev_priv(dev);
+	unsigned int max_combined = interface->hw.mac.max_queues;
+	u8 tcs = netdev_get_num_tc(dev);
+
+	/* For QoS report channels per traffic class */
+	if (tcs > 1)
+		max_combined = 1 << (fls(max_combined / tcs) - 1);
+
+	return max_combined;
+}
+
+static void fm10k_get_channels(struct net_device *dev,
+			       struct ethtool_channels *ch)
+{
+	struct fm10k_intfc *interface = netdev_priv(dev);
+	struct fm10k_hw *hw = &interface->hw;
+
+	/* report maximum channels */
+	ch->max_combined = fm10k_max_channels(dev);
+
+	/* report info for other vector */
+	ch->max_other = NON_Q_VECTORS(hw);
+	ch->other_count = ch->max_other;
+
+	/* record RSS queues */
+	ch->combined_count = interface->ring_feature[RING_F_RSS].indices;
+}
+
+static int fm10k_set_channels(struct net_device *dev,
+			      struct ethtool_channels *ch)
+{
+	struct fm10k_intfc *interface = netdev_priv(dev);
+	unsigned int count = ch->combined_count;
+	struct fm10k_hw *hw = &interface->hw;
+
+	/* verify they are not requesting separate vectors */
+	if (!count || ch->rx_count || ch->tx_count)
+		return -EINVAL;
+
+	/* verify other_count has not changed */
+	if (ch->other_count != NON_Q_VECTORS(hw))
+		return -EINVAL;
+
+	/* verify the number of channels does not exceed hardware limits */
+	if (count > fm10k_max_channels(dev))
+		return -EINVAL;
+
+	interface->ring_feature[RING_F_RSS].limit = count;
+
+	/* use setup TC to update any traffic class queue mapping */
+	return fm10k_setup_tc(dev, netdev_get_num_tc(dev));
+}
+
 static const struct ethtool_ops fm10k_ethtool_ops = {
 	.get_strings		= fm10k_get_strings,
 	.get_sset_count		= fm10k_get_sset_count,
@@ -860,6 +915,8 @@ static const struct ethtool_ops fm10k_ethtool_ops = {
 	.get_rxfh_key_size	= fm10k_get_rssrk_size,
 	.get_rxfh		= fm10k_get_rssh,
 	.set_rxfh		= fm10k_set_rssh,
+	.get_channels		= fm10k_get_channels,
+	.set_channels		= fm10k_set_channels,
 };
 
 void fm10k_set_ethtool_ops(struct net_device *dev)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index f7220d8..dae82d2 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1086,6 +1086,81 @@ static int fm10k_poll(struct napi_struct *napi, int budget)
 }
 
 /**
+ * fm10k_set_qos_queues: Allocate queues for a QOS-enabled device
+ * @interface: board private structure to initialize
+ *
+ * When QoS (Quality of Service) is enabled, allocate queues for
+ * each traffic class.  If multiqueue isn't available,then abort QoS
+ * initialization.
+ *
+ * This function handles all combinations of Qos and RSS.
+ *
+ **/
+static bool fm10k_set_qos_queues(struct fm10k_intfc *interface)
+{
+	struct net_device *dev = interface->netdev;
+	struct fm10k_ring_feature *f;
+	int rss_i, i;
+	int pcs;
+
+	/* Map queue offset and counts onto allocated tx queues */
+	pcs = netdev_get_num_tc(dev);
+
+	if (pcs <= 1)
+		return false;
+
+	/* set QoS mask and indices */
+	f = &interface->ring_feature[RING_F_QOS];
+	f->indices = pcs;
+	f->mask = (1 << fls(pcs - 1)) - 1;
+
+	/* determine the upper limit for our current DCB mode */
+	rss_i = interface->hw.mac.max_queues / pcs;
+	rss_i = 1 << (fls(rss_i) - 1);
+
+	/* set RSS mask and indices */
+	f = &interface->ring_feature[RING_F_RSS];
+	rss_i = min_t(u16, rss_i, f->limit);
+	f->indices = rss_i;
+	f->mask = (1 << fls(rss_i - 1)) - 1;
+
+	/* configure pause class to queue mapping */
+	for (i = 0; i < pcs; i++)
+		netdev_set_tc_queue(dev, i, rss_i, rss_i * i);
+
+	interface->num_rx_queues = rss_i * pcs;
+	interface->num_tx_queues = rss_i * pcs;
+
+	return true;
+}
+
+/**
+ * fm10k_set_rss_queues: Allocate queues for RSS
+ * @interface: board private structure to initialize
+ *
+ * This is our "base" multiqueue mode.  RSS (Receive Side Scaling) will try
+ * to allocate one Rx queue per CPU, and if available, one Tx queue per CPU.
+ *
+ **/
+static bool fm10k_set_rss_queues(struct fm10k_intfc *interface)
+{
+	struct fm10k_ring_feature *f;
+	u16 rss_i;
+
+	f = &interface->ring_feature[RING_F_RSS];
+	rss_i = min_t(u16, interface->hw.mac.max_queues, f->limit);
+
+	/* record indices and power of 2 mask for RSS */
+	f->indices = rss_i;
+	f->mask = (1 << fls(rss_i - 1)) - 1;
+
+	interface->num_rx_queues = rss_i;
+	interface->num_tx_queues = rss_i;
+
+	return true;
+}
+
+/**
  * fm10k_set_num_queues: Allocate queues for device, feature dependent
  * @interface: board private structure to initialize
  *
@@ -1101,6 +1176,11 @@ static void fm10k_set_num_queues(struct fm10k_intfc *interface)
 	/* Start with base case */
 	interface->num_rx_queues = 1;
 	interface->num_tx_queues = 1;
+
+	if (fm10k_set_qos_queues(interface))
+		return;
+
+	fm10k_set_rss_queues(interface);
 }
 
 /**
@@ -1381,6 +1461,71 @@ static int fm10k_init_msix_capability(struct fm10k_intfc *interface)
 	return 0;
 }
 
+/**
+ * fm10k_cache_ring_qos - Descriptor ring to register mapping for QoS
+ * @interface: Interface structure continaining rings and devices
+ *
+ * Cache the descriptor ring offsets for Qos
+ **/
+static bool fm10k_cache_ring_qos(struct fm10k_intfc *interface)
+{
+	struct net_device *dev = interface->netdev;
+	int pc, offset, rss_i, i, q_idx;
+	u16 pc_stride = interface->ring_feature[RING_F_QOS].mask + 1;
+	u8 num_pcs = netdev_get_num_tc(dev);
+
+	if (num_pcs <= 1)
+		return false;
+
+	rss_i = interface->ring_feature[RING_F_RSS].indices;
+
+	for (pc = 0, offset = 0; pc < num_pcs; pc++, offset += rss_i) {
+		q_idx = pc;
+		for (i = 0; i < rss_i; i++) {
+			interface->tx_ring[offset + i]->reg_idx = q_idx;
+			interface->tx_ring[offset + i]->qos_pc = pc;
+			interface->rx_ring[offset + i]->reg_idx = q_idx;
+			interface->rx_ring[offset + i]->qos_pc = pc;
+			q_idx += pc_stride;
+		}
+	}
+
+	return true;
+}
+
+/**
+ * fm10k_cache_ring_rss - Descriptor ring to register mapping for RSS
+ * @interface: Interface structure continaining rings and devices
+ *
+ * Cache the descriptor ring offsets for RSS
+ **/
+static void fm10k_cache_ring_rss(struct fm10k_intfc *interface)
+{
+	int i;
+
+	for (i = 0; i < interface->num_rx_queues; i++)
+		interface->rx_ring[i]->reg_idx = i;
+
+	for (i = 0; i < interface->num_tx_queues; i++)
+		interface->tx_ring[i]->reg_idx = i;
+}
+
+/**
+ * fm10k_assign_rings - Map rings to network devices
+ * @interface: Interface structure containing rings and devices
+ *
+ * This function is meant to go though and configure both the network
+ * devices so that they contain rings, and configure the rings so that
+ * they function with their network devices.
+ **/
+static void fm10k_assign_rings(struct fm10k_intfc *interface)
+{
+	if (fm10k_cache_ring_qos(interface))
+		return;
+
+	fm10k_cache_ring_rss(interface);
+}
+
 static void fm10k_init_reta(struct fm10k_intfc *interface)
 {
 	u16 i, rss_i = interface->ring_feature[RING_F_RSS].indices;
@@ -1448,6 +1593,9 @@ int fm10k_init_queueing_scheme(struct fm10k_intfc *interface)
 	if (err)
 		return err;
 
+	/* Map rings to devices, and map devices to physical queues */
+	fm10k_assign_rings(interface);
+
 	/* Initialize RSS redirection table */
 	fm10k_init_reta(interface);
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index b9b1459..2cda9f9 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -973,6 +973,46 @@ static struct rtnl_link_stats64 *fm10k_get_stats64(struct net_device *netdev,
 	return stats;
 }
 
+int fm10k_setup_tc(struct net_device *dev, u8 tc)
+{
+	struct fm10k_intfc *interface = netdev_priv(dev);
+
+	/* Currently only the PF supports priority classes */
+	if (tc && (interface->hw.mac.type != fm10k_mac_pf))
+		return -EINVAL;
+
+	/* Hardware supports up to 8 traffic classes */
+	if (tc > 8)
+		return -EINVAL;
+
+	/* Hardware has to reinitialize queues to match packet
+	 * buffer alignment. Unfortunately, the hardware is not
+	 * flexible enough to do this dynamically.
+	 */
+	if (netif_running(dev))
+		fm10k_close(dev);
+
+	fm10k_mbx_free_irq(interface);
+
+	fm10k_clear_queueing_scheme(interface);
+
+	/* we expect the prio_tc map to be repopulated later */
+	netdev_reset_tc(dev);
+	netdev_set_num_tc(dev, tc);
+
+	fm10k_init_queueing_scheme(interface);
+
+	fm10k_mbx_request_irq(interface);
+
+	if (netif_running(dev))
+		fm10k_open(dev);
+
+	/* flag to indicate SWPRI has yet to be updated */
+	interface->flags |= FM10K_FLAG_SWPRI_CONFIG;
+
+	return 0;
+}
+
 static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_open		= fm10k_open,
 	.ndo_stop		= fm10k_close,
@@ -985,6 +1025,7 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_vlan_rx_kill_vid	= fm10k_vlan_rx_kill_vid,
 	.ndo_set_rx_mode	= fm10k_set_rx_mode,
 	.ndo_get_stats64	= fm10k_get_stats64,
+	.ndo_setup_tc		= fm10k_setup_tc,
 };
 
 #define DEFAULT_DEBUG_LEVEL_SHIFT 3
-- 
1.9.3
