From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  10/11] ixgbevf: Add zero_base handler to network statistics
Date: Tue, 29 Oct 2013 05:02:30 -0700
Message-ID: <1383048151-15002-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:25560 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754825Ab3J2MCm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 08:02:42 -0400
In-Reply-To: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch removes the need to keep a zero_base variable in the adapter
structure. Now we just use two different macros to set the non-zero and
zero base. This adds to readability and shortens some of the structure
initialization under 80 columns. The gathering of status for ethtool was
slightly modified to again better fit into 80 columns and become a bit
more readable.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c | 78 ++++++++++++++++------------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h |  1 -
 2 files changed, 45 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index 44f7c42..54d9ace 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -45,16 +45,27 @@
 
 struct ixgbe_stats {
 	char stat_string[ETH_GSTRING_LEN];
-	int sizeof_stat;
-	int stat_offset;
-	int base_stat_offset;
-	int saved_reset_offset;
+	struct {
+		int sizeof_stat;
+		int stat_offset;
+		int base_stat_offset;
+		int saved_reset_offset;
+	};
 };
 
-#define IXGBEVF_STAT(m, b, r)  sizeof(((struct ixgbevf_adapter *)0)->m), \
-			    offsetof(struct ixgbevf_adapter, m),         \
-			    offsetof(struct ixgbevf_adapter, b),         \
-			    offsetof(struct ixgbevf_adapter, r)
+#define IXGBEVF_STAT(m, b, r) { \
+	.sizeof_stat = FIELD_SIZEOF(struct ixgbevf_adapter, m), \
+	.stat_offset = offsetof(struct ixgbevf_adapter, m), \
+	.base_stat_offset = offsetof(struct ixgbevf_adapter, b), \
+	.saved_reset_offset = offsetof(struct ixgbevf_adapter, r) \
+}
+
+#define IXGBEVF_ZSTAT(m) { \
+	.sizeof_stat = FIELD_SIZEOF(struct ixgbevf_adapter, m), \
+	.stat_offset = offsetof(struct ixgbevf_adapter, m), \
+	.base_stat_offset = -1, \
+	.saved_reset_offset = -1 \
+}
 
 static const struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"rx_packets", IXGBEVF_STAT(stats.vfgprc, stats.base_vfgprc,
@@ -65,22 +76,19 @@ static const struct ixgbe_stats ixgbe_gstrings_stats[] = {
 				  stats.saved_reset_vfgorc)},
 	{"tx_bytes", IXGBEVF_STAT(stats.vfgotc, stats.base_vfgotc,
 				  stats.saved_reset_vfgotc)},
-	{"tx_busy", IXGBEVF_STAT(tx_busy, zero_base, zero_base)},
+	{"tx_busy", IXGBEVF_ZSTAT(tx_busy)},
 	{"multicast", IXGBEVF_STAT(stats.vfmprc, stats.base_vfmprc,
 				   stats.saved_reset_vfmprc)},
-	{"rx_csum_offload_good", IXGBEVF_STAT(hw_csum_rx_good, zero_base,
-					      zero_base)},
-	{"rx_csum_offload_errors", IXGBEVF_STAT(hw_csum_rx_error, zero_base,
-						zero_base)},
-	{"tx_csum_offload_ctxt", IXGBEVF_STAT(hw_csum_tx_good, zero_base,
-					      zero_base)},
+	{"rx_csum_offload_good", IXGBEVF_ZSTAT(hw_csum_rx_good)},
+	{"rx_csum_offload_errors", IXGBEVF_ZSTAT(hw_csum_rx_error)},
+	{"tx_csum_offload_ctxt", IXGBEVF_ZSTAT(hw_csum_tx_good)},
 #ifdef BP_EXTENDED_STATS
-	{"rx_bp_poll_yield", IXGBEVF_STAT(bp_rx_yields, zero_base, zero_base)},
-	{"rx_bp_cleaned", IXGBEVF_STAT(bp_rx_cleaned, zero_base, zero_base)},
-	{"rx_bp_misses", IXGBEVF_STAT(bp_rx_missed, zero_base, zero_base)},
-	{"tx_bp_napi_yield", IXGBEVF_STAT(bp_tx_yields, zero_base, zero_base)},
-	{"tx_bp_cleaned", IXGBEVF_STAT(bp_tx_cleaned, zero_base, zero_base)},
-	{"tx_bp_misses", IXGBEVF_STAT(bp_tx_missed, zero_base, zero_base)},
+	{"rx_bp_poll_yield", IXGBEVF_ZSTAT(bp_rx_yields)},
+	{"rx_bp_cleaned", IXGBEVF_ZSTAT(bp_rx_cleaned)},
+	{"rx_bp_misses", IXGBEVF_ZSTAT(bp_rx_missed)},
+	{"tx_bp_napi_yield", IXGBEVF_ZSTAT(bp_tx_yields)},
+	{"tx_bp_cleaned", IXGBEVF_ZSTAT(bp_tx_cleaned)},
+	{"tx_bp_misses", IXGBEVF_ZSTAT(bp_tx_missed)},
 #endif
 };
 
@@ -398,6 +406,7 @@ static void ixgbevf_get_ethtool_stats(struct net_device *netdev,
 				      struct ethtool_stats *stats, u64 *data)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+	char *base = (char *) adapter;
 	int i;
 #ifdef BP_EXTENDED_STATS
 	u64 rx_yields = 0, rx_cleaned = 0, rx_missed = 0,
@@ -426,18 +435,21 @@ static void ixgbevf_get_ethtool_stats(struct net_device *netdev,
 
 	ixgbevf_update_stats(adapter);
 	for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
-		char *p = (char *)adapter +
-			ixgbe_gstrings_stats[i].stat_offset;
-		char *b = (char *)adapter +
-			ixgbe_gstrings_stats[i].base_stat_offset;
-		char *r = (char *)adapter +
-			ixgbe_gstrings_stats[i].saved_reset_offset;
-		data[i] = ((ixgbe_gstrings_stats[i].sizeof_stat ==
-			    sizeof(u64)) ? *(u64 *)p : *(u32 *)p) -
-			  ((ixgbe_gstrings_stats[i].sizeof_stat ==
-			    sizeof(u64)) ? *(u64 *)b : *(u32 *)b) +
-			  ((ixgbe_gstrings_stats[i].sizeof_stat ==
-			    sizeof(u64)) ? *(u64 *)r : *(u32 *)r);
+		char *p = base + ixgbe_gstrings_stats[i].stat_offset;
+		char *b = base + ixgbe_gstrings_stats[i].base_stat_offset;
+		char *r = base + ixgbe_gstrings_stats[i].saved_reset_offset;
+
+		if (ixgbe_gstrings_stats[i].sizeof_stat == sizeof(u64)) {
+			if (ixgbe_gstrings_stats[i].base_stat_offset >= 0)
+				data[i] = *(u64 *)p - *(u64 *)b + *(u64 *)r;
+			else
+				data[i] = *(u64 *)p;
+		} else {
+			if (ixgbe_gstrings_stats[i].base_stat_offset >= 0)
+				data[i] = *(u32 *)p - *(u32 *)b + *(u32 *)r;
+			else
+				data[i] = *(u32 *)p;
+		}
 	}
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 78e4c51..acf3806 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -361,7 +361,6 @@ struct ixgbevf_adapter {
 	struct ixgbe_hw hw;
 	u16 msg_enable;
 	struct ixgbevf_hw_stats stats;
-	u64 zero_base;
 	/* Interrupt Throttle Rate */
 	u32 eitr_param;
 
-- 
1.8.3.1
