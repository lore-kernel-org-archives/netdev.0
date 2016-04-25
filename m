From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] ixgbevf: refactor ethtool stats handling
Date: Mon, 25 Apr 2016 05:44:20 -0700
Message-ID: <1461588269-128728-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10855 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754635AbcDYMof (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 08:44:35 -0400
In-Reply-To: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This brings the logic closer to how we handle the stats in ixgbe and it
sets us up for introducing per-queue stats.

Use IXGBEVF_STAT and IXGBEVF_NETDEV_STAT for accessing the driver and
netdev stats respectively. This way we don't have to calculate the
stats based on register values which could lead to the counters not
being initialized properly when the interface is down.

IXGBEVF_QUEUE_STATS_LEN is set to include the number of queues.

Also some defines were renamed to use the IXGBEVF prefix.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c | 126 ++++++++++++++-------------
 1 file changed, 64 insertions(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index d7aa4b2..cd4d311 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -42,65 +42,62 @@
 
 #define IXGBE_ALL_RAR_ENTRIES 16
 
+enum {NETDEV_STATS, IXGBEVF_STATS};
+
 struct ixgbe_stats {
 	char stat_string[ETH_GSTRING_LEN];
-	struct {
-		int sizeof_stat;
-		int stat_offset;
-		int base_stat_offset;
-		int saved_reset_offset;
-	};
+	int type;
+	int sizeof_stat;
+	int stat_offset;
 };
 
-#define IXGBEVF_STAT(m, b, r) { \
-	.sizeof_stat = FIELD_SIZEOF(struct ixgbevf_adapter, m), \
-	.stat_offset = offsetof(struct ixgbevf_adapter, m), \
-	.base_stat_offset = offsetof(struct ixgbevf_adapter, b), \
-	.saved_reset_offset = offsetof(struct ixgbevf_adapter, r) \
+#define IXGBEVF_STAT(_name, _stat) { \
+	.stat_string = _name, \
+	.type = IXGBEVF_STATS, \
+	.sizeof_stat = FIELD_SIZEOF(struct ixgbevf_adapter, _stat), \
+	.stat_offset = offsetof(struct ixgbevf_adapter, _stat) \
 }
 
-#define IXGBEVF_ZSTAT(m) { \
-	.sizeof_stat = FIELD_SIZEOF(struct ixgbevf_adapter, m), \
-	.stat_offset = offsetof(struct ixgbevf_adapter, m), \
-	.base_stat_offset = -1, \
-	.saved_reset_offset = -1 \
+#define IXGBEVF_NETDEV_STAT(_net_stat) { \
+	.stat_string = #_net_stat, \
+	.type = NETDEV_STATS, \
+	.sizeof_stat = FIELD_SIZEOF(struct net_device_stats, _net_stat), \
+	.stat_offset = offsetof(struct net_device_stats, _net_stat) \
 }
 
-static const struct ixgbe_stats ixgbe_gstrings_stats[] = {
-	{"rx_packets", IXGBEVF_STAT(stats.vfgprc, stats.base_vfgprc,
-				    stats.saved_reset_vfgprc)},
-	{"tx_packets", IXGBEVF_STAT(stats.vfgptc, stats.base_vfgptc,
-				    stats.saved_reset_vfgptc)},
-	{"rx_bytes", IXGBEVF_STAT(stats.vfgorc, stats.base_vfgorc,
-				  stats.saved_reset_vfgorc)},
-	{"tx_bytes", IXGBEVF_STAT(stats.vfgotc, stats.base_vfgotc,
-				  stats.saved_reset_vfgotc)},
-	{"tx_busy", IXGBEVF_ZSTAT(tx_busy)},
-	{"tx_restart_queue", IXGBEVF_ZSTAT(restart_queue)},
-	{"tx_timeout_count", IXGBEVF_ZSTAT(tx_timeout_count)},
-	{"multicast", IXGBEVF_STAT(stats.vfmprc, stats.base_vfmprc,
-				   stats.saved_reset_vfmprc)},
-	{"rx_csum_offload_errors", IXGBEVF_ZSTAT(hw_csum_rx_error)},
+static struct ixgbe_stats ixgbevf_gstrings_stats[] = {
+	IXGBEVF_NETDEV_STAT(rx_packets),
+	IXGBEVF_NETDEV_STAT(tx_packets),
+	IXGBEVF_NETDEV_STAT(rx_bytes),
+	IXGBEVF_NETDEV_STAT(tx_bytes),
+	IXGBEVF_STAT("tx_busy", tx_busy),
+	IXGBEVF_STAT("tx_restart_queue", restart_queue),
+	IXGBEVF_STAT("tx_timeout_count", tx_timeout_count),
+	IXGBEVF_NETDEV_STAT(multicast),
+	IXGBEVF_STAT("rx_csum_offload_errors", hw_csum_rx_error),
 #ifdef BP_EXTENDED_STATS
-	{"rx_bp_poll_yield", IXGBEVF_ZSTAT(bp_rx_yields)},
-	{"rx_bp_cleaned", IXGBEVF_ZSTAT(bp_rx_cleaned)},
-	{"rx_bp_misses", IXGBEVF_ZSTAT(bp_rx_missed)},
-	{"tx_bp_napi_yield", IXGBEVF_ZSTAT(bp_tx_yields)},
-	{"tx_bp_cleaned", IXGBEVF_ZSTAT(bp_tx_cleaned)},
-	{"tx_bp_misses", IXGBEVF_ZSTAT(bp_tx_missed)},
+	IXGBEVF_STAT("rx_bp_poll_yield", bp_rx_yields),
+	IXGBEVF_STAT("rx_bp_cleaned", bp_rx_cleaned),
+	IXGBEVF_STAT("rx_bp_misses", bp_rx_missed),
+	IXGBEVF_STAT("tx_bp_napi_yield", bp_tx_yields),
+	IXGBEVF_STAT("tx_bp_cleaned", bp_tx_cleaned),
+	IXGBEVF_STAT("tx_bp_misses", bp_tx_missed),
 #endif
 };
 
-#define IXGBE_QUEUE_STATS_LEN 0
-#define IXGBE_GLOBAL_STATS_LEN	ARRAY_SIZE(ixgbe_gstrings_stats)
+#define IXGBEVF_QUEUE_STATS_LEN ( \
+	(((struct ixgbevf_adapter *)netdev_priv(netdev))->num_tx_queues + \
+	 ((struct ixgbevf_adapter *)netdev_priv(netdev))->num_rx_queues) * \
+	 (sizeof(struct ixgbe_stats) / sizeof(u64)))
+#define IXGBEVF_GLOBAL_STATS_LEN ARRAY_SIZE(ixgbevf_gstrings_stats)
 
-#define IXGBEVF_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
+#define IXGBEVF_STATS_LEN (IXGBEVF_GLOBAL_STATS_LEN + IXGBEVF_QUEUE_STATS_LEN)
 static const char ixgbe_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Register test  (offline)",
 	"Link test   (on/offline)"
 };
 
-#define IXGBE_TEST_LEN (sizeof(ixgbe_gstrings_test) / ETH_GSTRING_LEN)
+#define IXGBEVF_TEST_LEN (sizeof(ixgbe_gstrings_test) / ETH_GSTRING_LEN)
 
 static int ixgbevf_get_settings(struct net_device *netdev,
 				struct ethtool_cmd *ecmd)
@@ -396,9 +393,9 @@ static int ixgbevf_get_sset_count(struct net_device *dev, int stringset)
 {
 	switch (stringset) {
 	case ETH_SS_TEST:
-		return IXGBE_TEST_LEN;
+		return IXGBEVF_TEST_LEN;
 	case ETH_SS_STATS:
-		return IXGBE_GLOBAL_STATS_LEN;
+		return IXGBEVF_GLOBAL_STATS_LEN;
 	default:
 		return -EINVAL;
 	}
@@ -408,8 +405,11 @@ static void ixgbevf_get_ethtool_stats(struct net_device *netdev,
 				      struct ethtool_stats *stats, u64 *data)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
-	char *base = (char *)adapter;
+	struct rtnl_link_stats64 temp;
+	const struct rtnl_link_stats64 *net_stats;
 	int i;
+	char *p;
+
 #ifdef BP_EXTENDED_STATS
 	u64 rx_yields = 0, rx_cleaned = 0, rx_missed = 0,
 	    tx_yields = 0, tx_cleaned = 0, tx_missed = 0;
@@ -436,22 +436,24 @@ static void ixgbevf_get_ethtool_stats(struct net_device *netdev,
 #endif
 
 	ixgbevf_update_stats(adapter);
-	for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
-		char *p = base + ixgbe_gstrings_stats[i].stat_offset;
-		char *b = base + ixgbe_gstrings_stats[i].base_stat_offset;
-		char *r = base + ixgbe_gstrings_stats[i].saved_reset_offset;
-
-		if (ixgbe_gstrings_stats[i].sizeof_stat == sizeof(u64)) {
-			if (ixgbe_gstrings_stats[i].base_stat_offset >= 0)
-				data[i] = *(u64 *)p - *(u64 *)b + *(u64 *)r;
-			else
-				data[i] = *(u64 *)p;
-		} else {
-			if (ixgbe_gstrings_stats[i].base_stat_offset >= 0)
-				data[i] = *(u32 *)p - *(u32 *)b + *(u32 *)r;
-			else
-				data[i] = *(u32 *)p;
+	net_stats = dev_get_stats(netdev, &temp);
+	for (i = 0; i < IXGBEVF_GLOBAL_STATS_LEN; i++) {
+		switch (ixgbevf_gstrings_stats[i].type) {
+		case NETDEV_STATS:
+			p = (char *)net_stats +
+					ixgbevf_gstrings_stats[i].stat_offset;
+			break;
+		case IXGBEVF_STATS:
+			p = (char *)adapter +
+					ixgbevf_gstrings_stats[i].stat_offset;
+			break;
+		default:
+			data[i] = 0;
+			continue;
 		}
+
+		data[i] = (ixgbevf_gstrings_stats[i].sizeof_stat ==
+			   sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 }
 
@@ -464,11 +466,11 @@ static void ixgbevf_get_strings(struct net_device *netdev, u32 stringset,
 	switch (stringset) {
 	case ETH_SS_TEST:
 		memcpy(data, *ixgbe_gstrings_test,
-		       IXGBE_TEST_LEN * ETH_GSTRING_LEN);
+		       IXGBEVF_TEST_LEN * ETH_GSTRING_LEN);
 		break;
 	case ETH_SS_STATS:
-		for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
-			memcpy(p, ixgbe_gstrings_stats[i].stat_string,
+		for (i = 0; i < IXGBEVF_GLOBAL_STATS_LEN; i++) {
+			memcpy(p, ixgbevf_gstrings_stats[i].stat_string,
 			       ETH_GSTRING_LEN);
 			p += ETH_GSTRING_LEN;
 		}
-- 
2.5.5
