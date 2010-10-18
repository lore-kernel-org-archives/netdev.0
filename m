From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH] qlcnic: update ethtool stats
Date: Mon, 18 Oct 2010 04:47:48 -0700
Message-ID: <1287402468-10249-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:34306 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754772Ab0JRLrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 07:47:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added statistics for Nic Partition supported adapter.
These statistics are maintined in device.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |   73 +++++++++++++++++++++++++++++++++-
 1 files changed, 70 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 2568aa6..25e93a5 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -78,7 +78,25 @@ static const struct qlcnic_stats qlcnic_gstrings_stats[] = {
 
 };
 
+static const char qlcnic_device_gstrings_stats[][ETH_GSTRING_LEN] = {
+	"rx unicast frames",
+	"rx multicast frames",
+	"rx broadcast frames",
+	"rx dropped frames",
+	"rx errors",
+	"rx local frames",
+	"rx numbytes",
+	"tx unicast frames",
+	"tx multicast frames",
+	"tx broadcast frames",
+	"tx dropped frames",
+	"tx errors",
+	"tx local frames",
+	"tx numbytes",
+};
+
 #define QLCNIC_STATS_LEN	ARRAY_SIZE(qlcnic_gstrings_stats)
+#define QLCNIC_DEVICE_STATS_LEN	ARRAY_SIZE(qlcnic_device_gstrings_stats)
 
 static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Register_Test_on_offline",
@@ -625,10 +643,13 @@ static int qlcnic_reg_test(struct net_device *dev)
 
 static int qlcnic_get_sset_count(struct net_device *dev, int sset)
 {
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	switch (sset) {
 	case ETH_SS_TEST:
 		return QLCNIC_TEST_LEN;
 	case ETH_SS_STATS:
+		if (adapter->flags & QLCNIC_ESWITCH_ENABLED)
+			return QLCNIC_STATS_LEN + QLCNIC_DEVICE_STATS_LEN;
 		return QLCNIC_STATS_LEN;
 	default:
 		return -EOPNOTSUPP;
@@ -795,7 +816,8 @@ qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 static void
 qlcnic_get_strings(struct net_device *dev, u32 stringset, u8 * data)
 {
-	int index;
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+	int index, i;
 
 	switch (stringset) {
 	case ETH_SS_TEST:
@@ -808,16 +830,43 @@ qlcnic_get_strings(struct net_device *dev, u32 stringset, u8 * data)
 			       qlcnic_gstrings_stats[index].stat_string,
 			       ETH_GSTRING_LEN);
 		}
-		break;
+		if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
+			return;
+		for (i = 0; i < QLCNIC_DEVICE_STATS_LEN; index++, i++) {
+			memcpy(data + index * ETH_GSTRING_LEN,
+			       qlcnic_device_gstrings_stats[i],
+			       ETH_GSTRING_LEN);
+		}
 	}
 }
 
+#define QLCNIC_FILL_ESWITCH_STATS(VAL1) \
+	(((VAL1) == QLCNIC_ESW_STATS_NOT_AVAIL) ? 0 : VAL1)
+
+static void
+qlcnic_fill_device_stats(int *index, u64 *data,
+		struct __qlcnic_esw_statistics *stats)
+{
+	int ind = *index;
+
+	data[ind++] = QLCNIC_FILL_ESWITCH_STATS(stats->unicast_frames);
+	data[ind++] = QLCNIC_FILL_ESWITCH_STATS(stats->multicast_frames);
+	data[ind++] = QLCNIC_FILL_ESWITCH_STATS(stats->broadcast_frames);
+	data[ind++] = QLCNIC_FILL_ESWITCH_STATS(stats->dropped_frames);
+	data[ind++] = QLCNIC_FILL_ESWITCH_STATS(stats->errors);
+	data[ind++] = QLCNIC_FILL_ESWITCH_STATS(stats->local_frames);
+	data[ind++] = QLCNIC_FILL_ESWITCH_STATS(stats->numbytes);
+
+	*index = ind;
+}
+
 static void
 qlcnic_get_ethtool_stats(struct net_device *dev,
 			     struct ethtool_stats *stats, u64 * data)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
-	int index;
+	struct qlcnic_esw_statistics port_stats;
+	int index, ret;
 
 	for (index = 0; index < QLCNIC_STATS_LEN; index++) {
 		char *p =
@@ -827,6 +876,24 @@ qlcnic_get_ethtool_stats(struct net_device *dev,
 		    (qlcnic_gstrings_stats[index].sizeof_stat ==
 		     sizeof(u64)) ? *(u64 *)p:(*(u32 *)p);
 	}
+
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
+		return;
+
+	memset(&port_stats, 0, sizeof(struct qlcnic_esw_statistics));
+	ret = qlcnic_get_port_stats(adapter, adapter->ahw.pci_func,
+			QLCNIC_QUERY_RX_COUNTER, &port_stats.rx);
+	if (ret)
+		return;
+
+	qlcnic_fill_device_stats(&index, data, &port_stats.rx);
+
+	ret = qlcnic_get_port_stats(adapter, adapter->ahw.pci_func,
+			QLCNIC_QUERY_TX_COUNTER, &port_stats.tx);
+	if (ret)
+		return;
+
+	qlcnic_fill_device_stats(&index, data, &port_stats.tx);
 }
 
 static int qlcnic_set_tx_csum(struct net_device *dev, u32 data)
-- 
1.6.0.2

