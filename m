From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/17] fm10k: add support for extra debug statistics
Date: Tue, 22 Sep 2015 16:54:26 -0700
Message-ID: <1442966076-14359-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:63267 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935024AbbIVXyn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 19:54:43 -0400
In-Reply-To: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Add a private ethtool flag to enable display of these statistics, which
are generally less useful. However, sometimes it can be useful for
debugging purposes. The most useful portion is the ability to see what
the PF thinks the VF mailboxes look like.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h         |  19 ++
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 216 +++++++++++++++++++----
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c     |   5 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    |  15 ++
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     |  18 ++
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    |   6 +
 6 files changed, 243 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index c8c8c5b..1444020 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -101,12 +101,19 @@ struct fm10k_tx_queue_stats {
 	u64 csum_err;
 	u64 tx_busy;
 	u64 tx_done_old;
+	u64 csum_good;
 };
 
 struct fm10k_rx_queue_stats {
 	u64 alloc_failed;
 	u64 csum_err;
 	u64 errors;
+	u64 csum_good;
+	u64 switch_errors;
+	u64 drops;
+	u64 pp_errors;
+	u64 link_errors;
+	u64 length_errors;
 };
 
 struct fm10k_ring {
@@ -251,6 +258,7 @@ struct fm10k_intfc {
 #define FM10K_FLAG_RSS_FIELD_IPV6_UDP		(u32)(1 << 2)
 #define FM10K_FLAG_RX_TS_ENABLED		(u32)(1 << 3)
 #define FM10K_FLAG_SWPRI_CONFIG			(u32)(1 << 4)
+#define FM10K_FLAG_DEBUG_STATS			(u32)(1 << 5)
 	int xcast_mode;
 
 	/* Tx fast path data */
@@ -277,6 +285,17 @@ struct fm10k_intfc {
 	u64 rx_drops_nic;
 	u64 rx_overrun_pf;
 	u64 rx_overrun_vf;
+
+	/* Debug Statistics */
+	u64 hw_sm_mbx_full;
+	u64 hw_csum_tx_good;
+	u64 hw_csum_rx_good;
+	u64 rx_switch_errors;
+	u64 rx_drops;
+	u64 rx_pp_errors;
+	u64 rx_link_errors;
+	u64 rx_length_errors;
+
 	u32 tx_timeout_count;
 
 	/* RX */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index c6dc968..4ef2fbd 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -76,19 +76,22 @@ static const struct fm10k_stats fm10k_gstrings_global_stats[] = {
 	FM10K_STAT("mac_rules_used", hw.swapi.mac.used),
 	FM10K_STAT("mac_rules_avail", hw.swapi.mac.avail),
 
-	FM10K_STAT("mbx_tx_busy", hw.mbx.tx_busy),
-	FM10K_STAT("mbx_tx_oversized", hw.mbx.tx_dropped),
-	FM10K_STAT("mbx_tx_messages", hw.mbx.tx_messages),
-	FM10K_STAT("mbx_tx_dwords", hw.mbx.tx_dwords),
-	FM10K_STAT("mbx_rx_messages", hw.mbx.rx_messages),
-	FM10K_STAT("mbx_rx_dwords", hw.mbx.rx_dwords),
-	FM10K_STAT("mbx_rx_parse_err", hw.mbx.rx_parse_err),
-
 	FM10K_STAT("tx_hang_count", tx_timeout_count),
 
 	FM10K_STAT("tx_hwtstamp_timeouts", tx_hwtstamp_timeouts),
 };
 
+static const struct fm10k_stats fm10k_gstrings_debug_stats[] = {
+	FM10K_STAT("hw_sm_mbx_full", hw_sm_mbx_full),
+	FM10K_STAT("hw_csum_tx_good", hw_csum_tx_good),
+	FM10K_STAT("hw_csum_rx_good", hw_csum_rx_good),
+	FM10K_STAT("rx_switch_errors", rx_switch_errors),
+	FM10K_STAT("rx_drops", rx_drops),
+	FM10K_STAT("rx_pp_errors", rx_pp_errors),
+	FM10K_STAT("rx_link_errors", rx_link_errors),
+	FM10K_STAT("rx_length_errors", rx_length_errors),
+};
+
 static const struct fm10k_stats fm10k_gstrings_pf_stats[] = {
 	FM10K_STAT("timeout", stats.timeout.count),
 	FM10K_STAT("ur", stats.ur.count),
@@ -100,14 +103,33 @@ static const struct fm10k_stats fm10k_gstrings_pf_stats[] = {
 	FM10K_STAT("nodesc_drop", stats.nodesc_drop.count),
 };
 
+#define FM10K_MBX_STAT(_name, _stat) { \
+	.stat_string = _name, \
+	.sizeof_stat = FIELD_SIZEOF(struct fm10k_mbx_info, _stat), \
+	.stat_offset = offsetof(struct fm10k_mbx_info, _stat) \
+}
+
+static const struct fm10k_stats fm10k_gstrings_mbx_stats[] = {
+	FM10K_MBX_STAT("mbx_tx_busy", tx_busy),
+	FM10K_MBX_STAT("mbx_tx_oversized", tx_dropped),
+	FM10K_MBX_STAT("mbx_tx_messages", tx_messages),
+	FM10K_MBX_STAT("mbx_tx_dwords", tx_dwords),
+	FM10K_MBX_STAT("mbx_rx_messages", rx_messages),
+	FM10K_MBX_STAT("mbx_rx_dwords", rx_dwords),
+	FM10K_MBX_STAT("mbx_rx_parse_err", rx_parse_err),
+};
+
 #define FM10K_GLOBAL_STATS_LEN ARRAY_SIZE(fm10k_gstrings_global_stats)
+#define FM10K_DEBUG_STATS_LEN ARRAY_SIZE(fm10k_gstrings_debug_stats)
 #define FM10K_PF_STATS_LEN ARRAY_SIZE(fm10k_gstrings_pf_stats)
+#define FM10K_MBX_STATS_LEN ARRAY_SIZE(fm10k_gstrings_mbx_stats)
 
 #define FM10K_QUEUE_STATS_LEN(_n) \
 	( (_n) * 2 * (sizeof(struct fm10k_queue_stats) / sizeof(u64)))
 
 #define FM10K_STATIC_STATS_LEN (FM10K_GLOBAL_STATS_LEN + \
-				FM10K_NETDEV_STATS_LEN)
+				FM10K_NETDEV_STATS_LEN + \
+				FM10K_MBX_STATS_LEN)
 
 static const char fm10k_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Mailbox test (on/offline)"
@@ -120,47 +142,97 @@ enum fm10k_self_test_types {
 	FM10K_TEST_MAX = FM10K_TEST_LEN
 };
 
-static void fm10k_get_strings(struct net_device *dev, u32 stringset, u8 *data)
+enum {
+	FM10K_PRV_FLAG_DEBUG_STATS,
+	FM10K_PRV_FLAG_LEN,
+};
+
+static const char fm10k_prv_flags[FM10K_PRV_FLAG_LEN][ETH_GSTRING_LEN] = {
+	"debug-statistics",
+};
+
+static void fm10k_get_stat_strings(struct net_device *dev, u8 *data)
 {
 	struct fm10k_intfc *interface = netdev_priv(dev);
+	struct fm10k_iov_data *iov_data = interface->iov_data;
 	char *p = (char *)data;
 	unsigned int i;
+	unsigned int j;
 
-	switch (stringset) {
-	case ETH_SS_TEST:
-		memcpy(data, *fm10k_gstrings_test,
-		       FM10K_TEST_LEN * ETH_GSTRING_LEN);
-		break;
-	case ETH_SS_STATS:
-		for (i = 0; i < FM10K_NETDEV_STATS_LEN; i++) {
-			memcpy(p, fm10k_gstrings_net_stats[i].stat_string,
+	for (i = 0; i < FM10K_NETDEV_STATS_LEN; i++) {
+		memcpy(p, fm10k_gstrings_net_stats[i].stat_string,
+		       ETH_GSTRING_LEN);
+		p += ETH_GSTRING_LEN;
+	}
+
+	for (i = 0; i < FM10K_GLOBAL_STATS_LEN; i++) {
+		memcpy(p, fm10k_gstrings_global_stats[i].stat_string,
+		       ETH_GSTRING_LEN);
+		p += ETH_GSTRING_LEN;
+	}
+
+	if (interface->flags & FM10K_FLAG_DEBUG_STATS) {
+		for (i = 0; i < FM10K_DEBUG_STATS_LEN; i++) {
+			memcpy(p, fm10k_gstrings_debug_stats[i].stat_string,
 			       ETH_GSTRING_LEN);
 			p += ETH_GSTRING_LEN;
 		}
-		for (i = 0; i < FM10K_GLOBAL_STATS_LEN; i++) {
-			memcpy(p, fm10k_gstrings_global_stats[i].stat_string,
+	}
+
+	for (i = 0; i < FM10K_MBX_STATS_LEN; i++) {
+		memcpy(p, fm10k_gstrings_mbx_stats[i].stat_string,
+		       ETH_GSTRING_LEN);
+		p += ETH_GSTRING_LEN;
+	}
+
+	if (interface->hw.mac.type != fm10k_mac_vf) {
+		for (i = 0; i < FM10K_PF_STATS_LEN; i++) {
+			memcpy(p, fm10k_gstrings_pf_stats[i].stat_string,
 			       ETH_GSTRING_LEN);
 			p += ETH_GSTRING_LEN;
 		}
+	}
 
-		if (interface->hw.mac.type != fm10k_mac_vf) {
-			for (i = 0; i < FM10K_PF_STATS_LEN; i++) {
-				memcpy(p, fm10k_gstrings_pf_stats[i].stat_string,
-				       ETH_GSTRING_LEN);
+	if ((interface->flags & FM10K_FLAG_DEBUG_STATS) && iov_data) {
+		for (i = 0; i < iov_data->num_vfs; i++) {
+			for (j = 0; j < FM10K_MBX_STATS_LEN; j++) {
+				snprintf(p,
+					 ETH_GSTRING_LEN,
+					 "vf_%u_%s", i,
+					 fm10k_gstrings_mbx_stats[j].stat_string);
 				p += ETH_GSTRING_LEN;
 			}
 		}
+	}
 
-		for (i = 0; i < interface->hw.mac.max_queues; i++) {
-			sprintf(p, "tx_queue_%u_packets", i);
-			p += ETH_GSTRING_LEN;
-			sprintf(p, "tx_queue_%u_bytes", i);
-			p += ETH_GSTRING_LEN;
-			sprintf(p, "rx_queue_%u_packets", i);
-			p += ETH_GSTRING_LEN;
-			sprintf(p, "rx_queue_%u_bytes", i);
-			p += ETH_GSTRING_LEN;
-		}
+	for (i = 0; i < interface->hw.mac.max_queues; i++) {
+		sprintf(p, "tx_queue_%u_packets", i);
+		p += ETH_GSTRING_LEN;
+		sprintf(p, "tx_queue_%u_bytes", i);
+		p += ETH_GSTRING_LEN;
+		sprintf(p, "rx_queue_%u_packets", i);
+		p += ETH_GSTRING_LEN;
+		sprintf(p, "rx_queue_%u_bytes", i);
+		p += ETH_GSTRING_LEN;
+	}
+}
+
+static void fm10k_get_strings(struct net_device *dev,
+			      u32 stringset, u8 *data)
+{
+	char *p = (char *)data;
+
+	switch (stringset) {
+	case ETH_SS_TEST:
+		memcpy(data, *fm10k_gstrings_test,
+		       FM10K_TEST_LEN * ETH_GSTRING_LEN);
+		break;
+	case ETH_SS_STATS:
+		fm10k_get_stat_strings(dev, data);
+		break;
+	case ETH_SS_PRIV_FLAGS:
+		memcpy(p, fm10k_prv_flags,
+		       FM10K_PRV_FLAG_LEN * ETH_GSTRING_LEN);
 		break;
 	}
 }
@@ -168,6 +240,7 @@ static void fm10k_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 static int fm10k_get_sset_count(struct net_device *dev, int sset)
 {
 	struct fm10k_intfc *interface = netdev_priv(dev);
+	struct fm10k_iov_data *iov_data = interface->iov_data;
 	struct fm10k_hw *hw = &interface->hw;
 	int stats_len = FM10K_STATIC_STATS_LEN;
 
@@ -180,7 +253,16 @@ static int fm10k_get_sset_count(struct net_device *dev, int sset)
 		if (hw->mac.type != fm10k_mac_vf)
 			stats_len += FM10K_PF_STATS_LEN;
 
+		if (interface->flags & FM10K_FLAG_DEBUG_STATS) {
+			stats_len += FM10K_DEBUG_STATS_LEN;
+
+			if (iov_data)
+				stats_len += FM10K_MBX_STATS_LEN * iov_data->num_vfs;
+		}
+
 		return stats_len;
+	case ETH_SS_PRIV_FLAGS:
+		return FM10K_PRV_FLAG_LEN;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -192,6 +274,7 @@ static void fm10k_get_ethtool_stats(struct net_device *netdev,
 {
 	const int stat_count = sizeof(struct fm10k_queue_stats) / sizeof(u64);
 	struct fm10k_intfc *interface = netdev_priv(netdev);
+	struct fm10k_iov_data *iov_data = interface->iov_data;
 	struct net_device_stats *net_stats = &netdev->stats;
 	char *p;
 	int i, j;
@@ -211,13 +294,47 @@ static void fm10k_get_ethtool_stats(struct net_device *netdev,
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 
-	if (interface->hw.mac.type != fm10k_mac_vf)
+	if (interface->flags & FM10K_FLAG_DEBUG_STATS) {
+		for (i = 0; i < FM10K_DEBUG_STATS_LEN; i++) {
+			p = (char *)interface + fm10k_gstrings_debug_stats[i].stat_offset;
+			*(data++) = (fm10k_gstrings_debug_stats[i].sizeof_stat ==
+				     sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
+		}
+	}
+
+	for (i = 0; i < FM10K_MBX_STATS_LEN; i++) {
+		p = (char *)&interface->hw.mbx + fm10k_gstrings_mbx_stats[i].stat_offset;
+		*(data++) = (fm10k_gstrings_mbx_stats[i].sizeof_stat ==
+			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
+	}
+
+	if (interface->hw.mac.type != fm10k_mac_vf) {
 		for (i = 0; i < FM10K_PF_STATS_LEN; i++) {
 			p = (char *)interface +
 			    fm10k_gstrings_pf_stats[i].stat_offset;
 			*(data++) = (fm10k_gstrings_pf_stats[i].sizeof_stat ==
 				     sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 		}
+	}
+
+	if ((interface->flags & FM10K_FLAG_DEBUG_STATS) && iov_data) {
+		for (i = 0; i < iov_data->num_vfs; i++) {
+			struct fm10k_vf_info *vf_info;
+			vf_info = &iov_data->vf_info[i];
+
+			/* skip stats if we don't have a vf info */
+			if (!vf_info) {
+				data += FM10K_MBX_STATS_LEN;
+				continue;
+			}
+
+			for (j = 0; j < FM10K_MBX_STATS_LEN; j++) {
+				p = (char *)&vf_info->mbx + fm10k_gstrings_mbx_stats[j].stat_offset;
+				*(data++) = (fm10k_gstrings_mbx_stats[j].sizeof_stat ==
+					     sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
+			}
+		}
+	}
 
 	for (i = 0; i < interface->hw.mac.max_queues; i++) {
 		struct fm10k_ring *ring;
@@ -881,6 +998,33 @@ static void fm10k_self_test(struct net_device *dev,
 		eth_test->flags |= ETH_TEST_FL_FAILED;
 }
 
+static u32 fm10k_get_priv_flags(struct net_device *netdev)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+	u32 priv_flags = 0;
+
+	if (interface->flags & FM10K_FLAG_DEBUG_STATS)
+		priv_flags |= 1 << FM10K_PRV_FLAG_DEBUG_STATS;
+
+	return priv_flags;
+}
+
+static int fm10k_set_priv_flags(struct net_device *netdev, u32 priv_flags)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+
+	if (priv_flags >= (1 << FM10K_PRV_FLAG_LEN))
+		return -EINVAL;
+
+	if (priv_flags & (1 << FM10K_PRV_FLAG_DEBUG_STATS))
+		interface->flags |= FM10K_FLAG_DEBUG_STATS;
+	else
+		interface->flags &= ~FM10K_FLAG_DEBUG_STATS;
+
+	return 0;
+}
+
+
 static u32 fm10k_get_reta_size(struct net_device __always_unused *netdev)
 {
 	return FM10K_RETA_SIZE * FM10K_RETA_ENTRIES_PER_REG;
@@ -1094,6 +1238,8 @@ static const struct ethtool_ops fm10k_ethtool_ops = {
 	.get_regs               = fm10k_get_regs,
 	.get_regs_len           = fm10k_get_regs_len,
 	.self_test		= fm10k_self_test,
+	.get_priv_flags		= fm10k_get_priv_flags,
+	.set_priv_flags		= fm10k_set_priv_flags,
 	.get_rxfh_indir_size	= fm10k_get_reta_size,
 	.get_rxfh_key_size	= fm10k_get_rssrk_size,
 	.get_rxfh		= fm10k_get_rssh,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
index 0e25a80..acfb8b1f 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -137,8 +137,11 @@ process_mbx:
 		}
 
 		/* guarantee we have free space in the SM mailbox */
-		if (!hw->mbx.ops.tx_ready(&hw->mbx, FM10K_VFMBX_MSG_MTU))
+		if (!hw->mbx.ops.tx_ready(&hw->mbx, FM10K_VFMBX_MSG_MTU)) {
+			/* keep track of how many times this occurs */
+			interface->hw_sm_mbx_full++;
 			break;
+		}
 
 		/* cleanup mailbox and process received messages */
 		mbx->ops.process(hw, mbx);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 92d4155..2f47bfe 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -398,6 +398,8 @@ static inline void fm10k_rx_checksum(struct fm10k_ring *ring,
 		return;
 
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	ring->rx_stats.csum_good++;
 }
 
 #define FM10K_RSS_L4_TYPES_MASK \
@@ -556,6 +558,18 @@ static bool fm10k_cleanup_headers(struct fm10k_ring *rx_ring,
 {
 	if (unlikely((fm10k_test_staterr(rx_desc,
 					 FM10K_RXD_STATUS_RXE)))) {
+#define FM10K_TEST_RXD_BIT(rxd, bit) \
+	((rxd)->w.csum_err & cpu_to_le16(bit))
+		if (FM10K_TEST_RXD_BIT(rx_desc, FM10K_RXD_ERR_SWITCH_ERROR))
+			rx_ring->rx_stats.switch_errors++;
+		if (FM10K_TEST_RXD_BIT(rx_desc, FM10K_RXD_ERR_NO_DESCRIPTOR))
+			rx_ring->rx_stats.drops++;
+		if (FM10K_TEST_RXD_BIT(rx_desc, FM10K_RXD_ERR_PP_ERROR))
+			rx_ring->rx_stats.pp_errors++;
+		if (FM10K_TEST_RXD_BIT(rx_desc, FM10K_RXD_ERR_SWITCH_READY))
+			rx_ring->rx_stats.link_errors++;
+		if (FM10K_TEST_RXD_BIT(rx_desc, FM10K_RXD_ERR_TOO_BIG))
+			rx_ring->rx_stats.length_errors++;
 		dev_kfree_skb_any(skb);
 		rx_ring->rx_stats.errors++;
 		return true;
@@ -881,6 +895,7 @@ static void fm10k_tx_csum(struct fm10k_ring *tx_ring,
 
 	/* update TX checksum flag */
 	first->tx_flags |= FM10K_TX_FLAGS_CSUM;
+	tx_ring->tx_stats.csum_good++;
 
 no_csum:
 	/* populate Tx descriptor header size and mss */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index dfefd06..74be792 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -328,6 +328,9 @@ void fm10k_update_stats(struct fm10k_intfc *interface)
 {
 	struct net_device_stats *net_stats = &interface->netdev->stats;
 	struct fm10k_hw *hw = &interface->hw;
+	u64 hw_csum_tx_good = 0, hw_csum_rx_good = 0, rx_length_errors = 0;
+	u64 rx_switch_errors = 0, rx_drops = 0, rx_pp_errors = 0;
+	u64 rx_link_errors = 0;
 	u64 rx_errors = 0, rx_csum_errors = 0, tx_csum_errors = 0;
 	u64 restart_queue = 0, tx_busy = 0, alloc_failed = 0;
 	u64 rx_bytes_nic = 0, rx_pkts_nic = 0, rx_drops_nic = 0;
@@ -347,6 +350,7 @@ void fm10k_update_stats(struct fm10k_intfc *interface)
 		tx_csum_errors += tx_ring->tx_stats.csum_err;
 		bytes += tx_ring->stats.bytes;
 		pkts += tx_ring->stats.packets;
+		hw_csum_tx_good += tx_ring->tx_stats.csum_good;
 	}
 
 	interface->restart_queue = restart_queue;
@@ -354,6 +358,8 @@ void fm10k_update_stats(struct fm10k_intfc *interface)
 	net_stats->tx_bytes = bytes;
 	net_stats->tx_packets = pkts;
 	interface->tx_csum_errors = tx_csum_errors;
+	interface->hw_csum_tx_good = hw_csum_tx_good;
+
 	/* gather some stats to the interface struct that are per queue */
 	for (bytes = 0, pkts = 0, i = 0; i < interface->num_rx_queues; i++) {
 		struct fm10k_ring *rx_ring = interface->rx_ring[i];
@@ -363,12 +369,24 @@ void fm10k_update_stats(struct fm10k_intfc *interface)
 		alloc_failed += rx_ring->rx_stats.alloc_failed;
 		rx_csum_errors += rx_ring->rx_stats.csum_err;
 		rx_errors += rx_ring->rx_stats.errors;
+		hw_csum_rx_good += rx_ring->rx_stats.csum_good;
+		rx_switch_errors += rx_ring->rx_stats.switch_errors;
+		rx_drops += rx_ring->rx_stats.drops;
+		rx_pp_errors += rx_ring->rx_stats.pp_errors;
+		rx_link_errors += rx_ring->rx_stats.link_errors;
+		rx_length_errors += rx_ring->rx_stats.length_errors;
 	}
 
 	net_stats->rx_bytes = bytes;
 	net_stats->rx_packets = pkts;
 	interface->alloc_failed = alloc_failed;
 	interface->rx_csum_errors = rx_csum_errors;
+	interface->hw_csum_rx_good = hw_csum_rx_good;
+	interface->rx_switch_errors = rx_switch_errors;
+	interface->rx_drops = rx_drops;
+	interface->rx_pp_errors = rx_pp_errors;
+	interface->rx_link_errors = rx_link_errors;
+	interface->rx_length_errors = rx_length_errors;
 
 	hw->mac.ops.update_hw_stats(hw, &interface->stats);
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index bac8d48..318a212 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -762,6 +762,12 @@ enum fm10k_rxdesc_xc {
 #define FM10K_RXD_STATUS_L4E		0x4000 /* L4 csum error */
 #define FM10K_RXD_STATUS_IPE		0x8000 /* IPv4 csum error */
 
+#define FM10K_RXD_ERR_SWITCH_ERROR	0x0001 /* Switch found bad packet */
+#define FM10K_RXD_ERR_NO_DESCRIPTOR	0x0002 /* No descriptor available */
+#define FM10K_RXD_ERR_PP_ERROR		0x0004 /* RAM error during processing */
+#define FM10K_RXD_ERR_SWITCH_READY	0x0008 /* Link transition mid-packet */
+#define FM10K_RXD_ERR_TOO_BIG		0x0010 /* Pkt too big for single buf */
+
 struct fm10k_ftag {
 	__be16 swpri_type_user;
 	__be16 vlan;
-- 
2.4.3
