From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH net-next] team: add ethtool support
Date: Sat, 29 Dec 2012 23:19:26 -0200
Message-ID: <1356830366-991-1-git-send-email-fbl@redhat.com>
Cc: Jiri Pirko <jiri@resnulli.us>, Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22328 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753587Ab2L3BTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Dec 2012 20:19:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds few ethtool operations to team driver.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/team/team.c | 71 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 71 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index ad86660..f711039 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -28,6 +28,7 @@
 #include <net/genetlink.h>
 #include <net/netlink.h>
 #include <net/sch_generic.h>
+#include <generated/utsrelease.h>
 #include <linux/if_team.h>
 
 #define DRV_NAME "team"
@@ -1731,6 +1732,75 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_fix_features	= team_fix_features,
 };
 
+/***********************
+ * ethtool interface
+ ***********************/
+
+static const char ethtool_stats_keys[][ETH_GSTRING_LEN] = {
+	"rx_packets",
+	"rx_bytes",
+	"rx_dropped",
+	"tx_packets",
+	"tx_bytes",
+	"tx_dropped",
+	"multicast",
+};
+
+#define TEAM_NUM_STATS   ARRAY_SIZE(ethtool_stats_keys)
+
+static int team_get_sset_count(struct net_device *netdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return TEAM_NUM_STATS;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void team_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(data, *ethtool_stats_keys, sizeof(ethtool_stats_keys));
+		break;
+	}
+}
+
+static void team_get_ethtool_stats(struct net_device *netdev,
+				   struct ethtool_stats *stats,
+				   u64 *data)
+{
+	struct rtnl_link_stats64 net_stats;
+	int i;
+
+	memset(&net_stats, 0, sizeof(struct rtnl_link_stats64));
+	team_get_stats64(netdev, &net_stats);
+	i = 0;
+	/* ordering based on ethtool_stats_keys */
+	data[i++] = net_stats.rx_packets;
+	data[i++] = net_stats.rx_bytes;
+	data[i++] = net_stats.rx_dropped;
+	data[i++] = net_stats.tx_packets;
+	data[i++] = net_stats.tx_bytes;
+	data[i++] = net_stats.tx_dropped;
+	data[i++] = net_stats.multicast;
+}
+
+static void team_ethtool_get_drvinfo(struct net_device *dev,
+				     struct ethtool_drvinfo *drvinfo)
+{
+	strncpy(drvinfo->driver, DRV_NAME, 32);
+	strncpy(drvinfo->version, UTS_RELEASE, 32);
+}
+
+static const struct ethtool_ops team_ethtool_ops = {
+	.get_drvinfo		= team_ethtool_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+	.get_strings		= team_get_strings,
+	.get_ethtool_stats	= team_get_ethtool_stats,
+	.get_sset_count		= team_get_sset_count,
+};
 
 /***********************
  * rt netlink interface
@@ -1780,6 +1850,7 @@ static void team_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	dev->netdev_ops = &team_netdev_ops;
+	dev->ethtool_ops = &team_ethtool_ops;
 	dev->destructor	= team_destructor;
 	dev->tx_queue_len = 0;
 	dev->flags |= IFF_MULTICAST;
-- 
1.8.0.1
