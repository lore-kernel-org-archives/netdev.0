From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH -next] sundance: Add initial ethtool stats support
Date: Sat, 9 Oct 2010 09:53:46 +0000
Message-ID: <20101009095346.GA12951@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:41844 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754497Ab0JIJxs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Oct 2010 05:53:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add initial ethtool statistics support 

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/sundance.c |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 27d69aa..685845b 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -1564,6 +1564,18 @@ static int __set_mac_addr(struct net_device *dev)
 	return 0;
 }
 
+static const struct {
+	const char name[ETH_GSTRING_LEN];
+} sundance_stats[] = {
+	{ "tx_packets" },
+	{ "tx_bytes" },
+	{ "rx_packets" },
+	{ "rx_bytes" },
+	{ "tx_errors" },
+	{ "tx_dropped" },
+	{ "rx_errors" },
+};
+
 static int check_if_running(struct net_device *dev)
 {
 	if (!netif_running(dev))
@@ -1622,6 +1634,37 @@ static void set_msglevel(struct net_device *dev, u32 val)
 	np->msg_enable = val;
 }
 
+static void get_strings(struct net_device *dev, u32 stringset,
+		u8 *data)
+{
+	memcpy(data, sundance_stats, sizeof(sundance_stats));
+}
+
+static int get_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(sundance_stats);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void get_ethtool_stats(struct net_device *dev,
+		struct ethtool_stats *stats, u64 *data)
+{
+	struct net_device_stats *netdev_stats = get_stats(dev);
+	int i = 0;
+
+	data[i++] = netdev_stats->tx_packets;
+	data[i++] = netdev_stats->tx_bytes;
+	data[i++] = netdev_stats->rx_packets;
+	data[i++] = netdev_stats->rx_bytes;
+	data[i++] = netdev_stats->tx_errors;
+	data[i++] = netdev_stats->tx_dropped;
+	data[i++] = netdev_stats->rx_errors;
+}
+
 static const struct ethtool_ops ethtool_ops = {
 	.begin = check_if_running,
 	.get_drvinfo = get_drvinfo,
@@ -1631,6 +1674,9 @@ static const struct ethtool_ops ethtool_ops = {
 	.get_link = get_link,
 	.get_msglevel = get_msglevel,
 	.set_msglevel = set_msglevel,
+	.get_strings = get_strings,
+	.get_sset_count = get_sset_count,
+	.get_ethtool_stats = get_ethtool_stats,
 };
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.0

