From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/25] fm10k: separate PF only stats so that VF does not display them
Date: Tue, 14 Apr 2015 16:50:56 -0700
Message-ID: <1429055471-401-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51346 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754566AbbDNXvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:22 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch resolves an issue with ethtool stats displaying useless
values on the VF, because some stats simply have no meaning to the VF.
Resolve this by splitting these out into PF_STATS and only showing them
if we aren't the VF.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 51 +++++++++++++++++-------
 1 file changed, 37 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index cbfaf94..4687f37 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -57,7 +57,7 @@ static const struct fm10k_stats fm10k_gstrings_net_stats[] = {
 	.stat_offset = offsetof(struct fm10k_intfc, _stat) \
 }
 
-static const struct fm10k_stats fm10k_gstrings_stats[] = {
+static const struct fm10k_stats fm10k_gstrings_global_stats[] = {
 	FM10K_STAT("tx_restart_queue", restart_queue),
 	FM10K_STAT("tx_busy", tx_busy),
 	FM10K_STAT("tx_csum_errors", tx_csum_errors),
@@ -72,15 +72,6 @@ static const struct fm10k_stats fm10k_gstrings_stats[] = {
 	FM10K_STAT("rx_overrun_pf", rx_overrun_pf),
 	FM10K_STAT("rx_overrun_vf", rx_overrun_vf),
 
-	FM10K_STAT("timeout", stats.timeout.count),
-	FM10K_STAT("ur", stats.ur.count),
-	FM10K_STAT("ca", stats.ca.count),
-	FM10K_STAT("um", stats.um.count),
-	FM10K_STAT("xec", stats.xec.count),
-	FM10K_STAT("vlan_drop", stats.vlan_drop.count),
-	FM10K_STAT("loopback_drop", stats.loopback_drop.count),
-	FM10K_STAT("nodesc_drop", stats.nodesc_drop.count),
-
 	FM10K_STAT("swapi_status", hw.swapi.status),
 	FM10K_STAT("mac_rules_used", hw.swapi.mac.used),
 	FM10K_STAT("mac_rules_avail", hw.swapi.mac.avail),
@@ -96,7 +87,19 @@ static const struct fm10k_stats fm10k_gstrings_stats[] = {
 	FM10K_STAT("tx_hwtstamp_timeouts", tx_hwtstamp_timeouts),
 };
 
-#define FM10K_GLOBAL_STATS_LEN ARRAY_SIZE(fm10k_gstrings_stats)
+static const struct fm10k_stats fm10k_gstrings_pf_stats[] = {
+	FM10K_STAT("timeout", stats.timeout.count),
+	FM10K_STAT("ur", stats.ur.count),
+	FM10K_STAT("ca", stats.ca.count),
+	FM10K_STAT("um", stats.um.count),
+	FM10K_STAT("xec", stats.xec.count),
+	FM10K_STAT("vlan_drop", stats.vlan_drop.count),
+	FM10K_STAT("loopback_drop", stats.loopback_drop.count),
+	FM10K_STAT("nodesc_drop", stats.nodesc_drop.count),
+};
+
+#define FM10K_GLOBAL_STATS_LEN ARRAY_SIZE(fm10k_gstrings_global_stats)
+#define FM10K_PF_STATS_LEN ARRAY_SIZE(fm10k_gstrings_pf_stats)
 
 #define FM10K_QUEUE_STATS_LEN(_n) \
 	( (_n) * 2 * (sizeof(struct fm10k_queue_stats) / sizeof(u64)))
@@ -133,11 +136,18 @@ static void fm10k_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 			p += ETH_GSTRING_LEN;
 		}
 		for (i = 0; i < FM10K_GLOBAL_STATS_LEN; i++) {
-			memcpy(p, fm10k_gstrings_stats[i].stat_string,
+			memcpy(p, fm10k_gstrings_global_stats[i].stat_string,
 			       ETH_GSTRING_LEN);
 			p += ETH_GSTRING_LEN;
 		}
 
+		if (interface->hw.mac.type != fm10k_mac_vf)
+			for (i = 0; i < FM10K_PF_STATS_LEN; i++) {
+				memcpy(p, fm10k_gstrings_pf_stats[i].stat_string,
+				       ETH_GSTRING_LEN);
+				p += ETH_GSTRING_LEN;
+			}
+
 		for (i = 0; i < interface->hw.mac.max_queues; i++) {
 			sprintf(p, "tx_queue_%u_packets", i);
 			p += ETH_GSTRING_LEN;
@@ -163,6 +173,10 @@ static int fm10k_get_sset_count(struct net_device *dev, int sset)
 		return FM10K_TEST_LEN;
 	case ETH_SS_STATS:
 		stats_len += FM10K_QUEUE_STATS_LEN(hw->mac.max_queues);
+
+		if (hw->mac.type != fm10k_mac_vf)
+			stats_len += FM10K_PF_STATS_LEN;
+
 		return stats_len;
 	default:
 		return -EOPNOTSUPP;
@@ -188,11 +202,20 @@ static void fm10k_get_ethtool_stats(struct net_device *netdev,
 	}
 
 	for (i = 0; i < FM10K_GLOBAL_STATS_LEN; i++) {
-		p = (char *)interface + fm10k_gstrings_stats[i].stat_offset;
-		*(data++) = (fm10k_gstrings_stats[i].sizeof_stat ==
+		p = (char *)interface +
+		    fm10k_gstrings_global_stats[i].stat_offset;
+		*(data++) = (fm10k_gstrings_global_stats[i].sizeof_stat ==
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 
+	if (interface->hw.mac.type != fm10k_mac_vf)
+		for (i = 0; i < FM10K_PF_STATS_LEN; i++) {
+			p = (char *)interface +
+			    fm10k_gstrings_pf_stats[i].stat_offset;
+			*(data++) = (fm10k_gstrings_pf_stats[i].sizeof_stat ==
+				     sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
+		}
+
 	for (i = 0; i < interface->hw.mac.max_queues; i++) {
 		struct fm10k_ring *ring;
 		u64 *queue_stat;
-- 
1.9.3
