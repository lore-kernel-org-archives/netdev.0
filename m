From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/17] fm10k: remove debug-statistics support
Date: Wed, 20 Apr 2016 23:09:14 -0700
Message-ID: <1461218969-68578-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55438 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751417AbcDUGJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:33 -0400
In-Reply-To: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This change fixes an (ab)use of the ethtool stats API, which could
result in corrupt memory or misleading stat output. The ethtool stats
API is not robust enough to handle varying number of statistics due to
how it requests the size and allocates memory. Remove the poorly conceived
support originally added for extra debug statistics. In the future,
a new stats API may open up the ability to display these statistics.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 72 +-----------------------
 1 file changed, 1 insertion(+), 71 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index f331966..6ab9df5 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -81,17 +81,6 @@ static const struct fm10k_stats fm10k_gstrings_global_stats[] = {
 	FM10K_STAT("tx_hwtstamp_timeouts", tx_hwtstamp_timeouts),
 };
 
-static const struct fm10k_stats fm10k_gstrings_debug_stats[] = {
-	FM10K_STAT("hw_sm_mbx_full", hw_sm_mbx_full),
-	FM10K_STAT("hw_csum_tx_good", hw_csum_tx_good),
-	FM10K_STAT("hw_csum_rx_good", hw_csum_rx_good),
-	FM10K_STAT("rx_switch_errors", rx_switch_errors),
-	FM10K_STAT("rx_drops", rx_drops),
-	FM10K_STAT("rx_pp_errors", rx_pp_errors),
-	FM10K_STAT("rx_link_errors", rx_link_errors),
-	FM10K_STAT("rx_length_errors", rx_length_errors),
-};
-
 static const struct fm10k_stats fm10k_gstrings_pf_stats[] = {
 	FM10K_STAT("timeout", stats.timeout.count),
 	FM10K_STAT("ur", stats.ur.count),
@@ -133,7 +122,6 @@ static const struct fm10k_stats fm10k_gstrings_queue_stats[] = {
 };
 
 #define FM10K_GLOBAL_STATS_LEN ARRAY_SIZE(fm10k_gstrings_global_stats)
-#define FM10K_DEBUG_STATS_LEN ARRAY_SIZE(fm10k_gstrings_debug_stats)
 #define FM10K_PF_STATS_LEN ARRAY_SIZE(fm10k_gstrings_pf_stats)
 #define FM10K_MBX_STATS_LEN ARRAY_SIZE(fm10k_gstrings_mbx_stats)
 #define FM10K_QUEUE_STATS_LEN ARRAY_SIZE(fm10k_gstrings_queue_stats)
@@ -154,12 +142,10 @@ enum fm10k_self_test_types {
 };
 
 enum {
-	FM10K_PRV_FLAG_DEBUG_STATS,
 	FM10K_PRV_FLAG_LEN,
 };
 
 static const char fm10k_prv_flags[FM10K_PRV_FLAG_LEN][ETH_GSTRING_LEN] = {
-	"debug-statistics",
 };
 
 static void fm10k_add_stat_strings(char **p, const char *prefix,
@@ -178,7 +164,6 @@ static void fm10k_add_stat_strings(char **p, const char *prefix,
 static void fm10k_get_stat_strings(struct net_device *dev, u8 *data)
 {
 	struct fm10k_intfc *interface = netdev_priv(dev);
-	struct fm10k_iov_data *iov_data = interface->iov_data;
 	char *p = (char *)data;
 	unsigned int i;
 
@@ -188,10 +173,6 @@ static void fm10k_get_stat_strings(struct net_device *dev, u8 *data)
 	fm10k_add_stat_strings(&p, "", fm10k_gstrings_global_stats,
 			       FM10K_GLOBAL_STATS_LEN);
 
-	if (interface->flags & FM10K_FLAG_DEBUG_STATS)
-		fm10k_add_stat_strings(&p, "", fm10k_gstrings_debug_stats,
-				       FM10K_DEBUG_STATS_LEN);
-
 	fm10k_add_stat_strings(&p, "", fm10k_gstrings_mbx_stats,
 			       FM10K_MBX_STATS_LEN);
 
@@ -199,17 +180,6 @@ static void fm10k_get_stat_strings(struct net_device *dev, u8 *data)
 		fm10k_add_stat_strings(&p, "", fm10k_gstrings_pf_stats,
 				       FM10K_PF_STATS_LEN);
 
-	if ((interface->flags & FM10K_FLAG_DEBUG_STATS) && iov_data) {
-		for (i = 0; i < iov_data->num_vfs; i++) {
-			char prefix[ETH_GSTRING_LEN];
-
-			snprintf(prefix, ETH_GSTRING_LEN, "vf_%u_", i);
-			fm10k_add_stat_strings(&p, prefix,
-					       fm10k_gstrings_mbx_stats,
-					       FM10K_MBX_STATS_LEN);
-		}
-	}
-
 	for (i = 0; i < interface->hw.mac.max_queues; i++) {
 		char prefix[ETH_GSTRING_LEN];
 
@@ -248,7 +218,6 @@ static void fm10k_get_strings(struct net_device *dev,
 static int fm10k_get_sset_count(struct net_device *dev, int sset)
 {
 	struct fm10k_intfc *interface = netdev_priv(dev);
-	struct fm10k_iov_data *iov_data = interface->iov_data;
 	struct fm10k_hw *hw = &interface->hw;
 	int stats_len = FM10K_STATIC_STATS_LEN;
 
@@ -261,14 +230,6 @@ static int fm10k_get_sset_count(struct net_device *dev, int sset)
 		if (hw->mac.type != fm10k_mac_vf)
 			stats_len += FM10K_PF_STATS_LEN;
 
-		if (interface->flags & FM10K_FLAG_DEBUG_STATS) {
-			stats_len += FM10K_DEBUG_STATS_LEN;
-
-			if (iov_data)
-				stats_len += FM10K_MBX_STATS_LEN *
-					iov_data->num_vfs;
-		}
-
 		return stats_len;
 	case ETH_SS_PRIV_FLAGS:
 		return FM10K_PRV_FLAG_LEN;
@@ -318,7 +279,6 @@ static void fm10k_get_ethtool_stats(struct net_device *netdev,
 				    u64 *data)
 {
 	struct fm10k_intfc *interface = netdev_priv(netdev);
-	struct fm10k_iov_data *iov_data = interface->iov_data;
 	struct net_device_stats *net_stats = &netdev->stats;
 	int i;
 
@@ -330,11 +290,6 @@ static void fm10k_get_ethtool_stats(struct net_device *netdev,
 	fm10k_add_ethtool_stats(&data, interface, fm10k_gstrings_global_stats,
 				FM10K_GLOBAL_STATS_LEN);
 
-	if (interface->flags & FM10K_FLAG_DEBUG_STATS)
-		fm10k_add_ethtool_stats(&data, interface,
-					fm10k_gstrings_debug_stats,
-					FM10K_DEBUG_STATS_LEN);
-
 	fm10k_add_ethtool_stats(&data, &interface->hw.mbx,
 				fm10k_gstrings_mbx_stats,
 				FM10K_MBX_STATS_LEN);
@@ -345,18 +300,6 @@ static void fm10k_get_ethtool_stats(struct net_device *netdev,
 					FM10K_PF_STATS_LEN);
 	}
 
-	if ((interface->flags & FM10K_FLAG_DEBUG_STATS) && iov_data) {
-		for (i = 0; i < iov_data->num_vfs; i++) {
-			struct fm10k_vf_info *vf_info;
-
-			vf_info = &iov_data->vf_info[i];
-
-			fm10k_add_ethtool_stats(&data, &vf_info->mbx,
-						fm10k_gstrings_mbx_stats,
-						FM10K_MBX_STATS_LEN);
-		}
-	}
-
 	for (i = 0; i < interface->hw.mac.max_queues; i++) {
 		struct fm10k_ring *ring;
 
@@ -1012,27 +955,14 @@ static void fm10k_self_test(struct net_device *dev,
 
 static u32 fm10k_get_priv_flags(struct net_device *netdev)
 {
-	struct fm10k_intfc *interface = netdev_priv(netdev);
-	u32 priv_flags = 0;
-
-	if (interface->flags & FM10K_FLAG_DEBUG_STATS)
-		priv_flags |= BIT(FM10K_PRV_FLAG_DEBUG_STATS);
-
-	return priv_flags;
+	return 0;
 }
 
 static int fm10k_set_priv_flags(struct net_device *netdev, u32 priv_flags)
 {
-	struct fm10k_intfc *interface = netdev_priv(netdev);
-
 	if (priv_flags >= BIT(FM10K_PRV_FLAG_LEN))
 		return -EINVAL;
 
-	if (priv_flags & BIT(FM10K_PRV_FLAG_DEBUG_STATS))
-		interface->flags |= FM10K_FLAG_DEBUG_STATS;
-	else
-		interface->flags &= ~FM10K_FLAG_DEBUG_STATS;
-
 	return 0;
 }
 
-- 
2.5.5
