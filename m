From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [RFC PATCH] net: mvneta: add ethtool statistics
Date: Sun, 04 Oct 2015 17:58:54 +0100
Message-ID: <E1Zimcg-0008HA-0y@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:38517 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbbJDQ66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 12:58:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the ethtool statistic interface, returning the full set
of statistics which both the Armada 370 and Armada XP can support.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
Is there any standard terminology for the ethtool statistics?  Are the
names given here satisfactory?

This patch is against net-next.git.

 drivers/net/ethernet/marvell/mvneta.c | 100 ++++++++++++++++++++++++++++++++++
 1 file changed, 100 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 514df76fc70f..2019fa6b52e0 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -278,6 +278,51 @@ struct mvneta_pcpu_stats {
 
 #define MVNETA_RX_BUF_SIZE(pkt_size)   ((pkt_size) + NET_SKB_PAD)
 
+struct mvneta_statistic {
+	unsigned short offset;
+	unsigned short type;
+	const char name[ETH_GSTRING_LEN];
+};
+
+#define T_REG_32	32
+#define T_REG_64	64
+#define T_SW		1
+
+static const struct mvneta_statistic mvneta_statistics[] = {
+	{ 0x3000, T_REG_64, "rx_good_bytes", },
+	{ 0x3010, T_REG_32, "rx_good_packets", },
+	{ 0x3008, T_REG_32, "rx_bad_bytes", },
+	{ 0x3014, T_REG_32, "rx_bad_packets", },
+	{ 0x3018, T_REG_32, "rx_broadcast_packets", },
+	{ 0x301c, T_REG_32, "rx_multicast_packets", },
+	{ 0x3050, T_REG_32, "rx_unrecog_mac_ctl", },
+	{ 0x3054, T_REG_32, "rx_good_fc_packets", },
+	{ 0x3058, T_REG_32, "rx_bad_fc_packets", },
+	{ 0x305c, T_REG_32, "rx_undersize_packets", },
+	{ 0x3064, T_REG_32, "rx_fragments", },
+	{ 0x3068, T_REG_32, "rx_oversize_packets", },
+	{ 0x306c, T_REG_32, "rx_jabber_packets", },
+	{ 0x3070, T_REG_32, "rx_mac_errors", },
+	{ 0x3074, T_REG_32, "rx_bad_crc", },
+	{ 0x3078, T_REG_32, "rx_collision_events", },
+	{ 0x307c, T_REG_32, "rx_late_collision_events", },
+	{ 0x2484, T_REG_32, "rx_discard_packets", },
+	{ 0x2488, T_REG_32, "rx_overrun_packets", },
+	{ 0x3020, T_REG_32, "packets_64bytes", },
+	{ 0x3024, T_REG_32, "packets_65to127bytes", },
+	{ 0x3028, T_REG_32, "packets_128to255bytes", },
+	{ 0x302c, T_REG_32, "packets_256to511bytes", },
+	{ 0x3030, T_REG_32, "packets_512to1023bytes", },
+	{ 0x3034, T_REG_32, "packets_1024tomaxbytes", },
+	{ 0x3038, T_REG_64, "tx_good_bytes", },
+	{ 0x3040, T_REG_32, "tx_good_packets", },
+	{ 0x3044, T_REG_32, "tx_excessive_collision", },
+	{ 0x3048, T_REG_32, "tx_multicast_packets", },
+	{ 0x304c, T_REG_32, "tx_broadcast_packets", },
+	{ 0x3060, T_REG_32, "tx_fc", },
+	{ 0x300c, T_REG_32, "tx_mac_error", },
+};
+
 struct mvneta_pcpu_stats {
 	struct	u64_stats_sync syncp;
 	u64	rx_packets;
@@ -324,6 +369,8 @@ struct mvneta_port {
 	unsigned int speed;
 	unsigned int tx_csum_limit;
 	int use_inband_status:1;
+
+	u64 ethtool_stats[ARRAY_SIZE(mvneta_statistics)];
 };
 
 /* The mvneta_tx_desc and mvneta_rx_desc structures describe the
@@ -2982,6 +3029,56 @@ static int mvneta_ethtool_set_ringparam(struct net_device *dev,
 	return 0;
 }
 
+static void mvneta_ethtool_get_strings(struct net_device *netdev, u32 sset,
+				       u8 *data)
+{
+	if (sset == ETH_SS_STATS) {
+		int i;
+
+		for (i = 0; i < ARRAY_SIZE(mvneta_statistics); i++)
+			memcpy(data + i * ETH_GSTRING_LEN,
+			       mvneta_statistics[i].name, ETH_GSTRING_LEN);
+	}
+}
+
+static void mvneta_ethtool_get_stats(struct net_device *dev,
+				     struct ethtool_stats *stats, u64 *data)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+	const struct mvneta_statistic *s;
+	void __iomem *base = pp->base;
+	u32 high, low, val;
+	int i;
+
+	for (i = 0, s = mvneta_statistics;
+	     s < mvneta_statistics + ARRAY_SIZE(mvneta_statistics);
+	     s++, i++) {
+		val = 0;
+
+		switch (s->type) {
+		case T_REG_32:
+			val = readl_relaxed(base + s->offset);
+			break;
+		case T_REG_64:
+			/* Docs say to read low 32-bit then high */
+			low = readl_relaxed(base + s->offset);
+			high = readl_relaxed(base + s->offset + 4);
+			val = (u64)high << 32 | low;
+			break;
+		}
+
+		pp->ethtool_stats[i] += val;
+		*data++ = pp->ethtool_stats[i];
+	}
+}
+
+static int mvneta_ethtool_get_sset_count(struct net_device *dev, int sset)
+{
+	if (sset == ETH_SS_STATS)
+		return ARRAY_SIZE(mvneta_statistics);
+	return -EOPNOTSUPP;
+}
+
 static const struct net_device_ops mvneta_netdev_ops = {
 	.ndo_open            = mvneta_open,
 	.ndo_stop            = mvneta_stop,
@@ -3003,6 +3100,9 @@ const struct ethtool_ops mvneta_eth_tool_ops = {
 	.get_drvinfo    = mvneta_ethtool_get_drvinfo,
 	.get_ringparam  = mvneta_ethtool_get_ringparam,
 	.set_ringparam	= mvneta_ethtool_set_ringparam,
+	.get_strings	= mvneta_ethtool_get_strings,
+	.get_ethtool_stats = mvneta_ethtool_get_stats,
+	.get_sset_count	= mvneta_ethtool_get_sset_count,
 };
 
 /* Initialize hw */
-- 
2.1.0
