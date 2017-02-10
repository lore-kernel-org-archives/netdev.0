From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH v3 net-next 4/9] sunvnet: add driver stats for ethtool support
Date: Fri, 10 Feb 2017 09:38:20 -0800
Message-ID: <1486748305-240339-5-git-send-email-shannon.nelson@oracle.com>
References: <1486748305-240339-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46783 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751734AbdBJRpL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 12:45:11 -0500
In-Reply-To: <1486748305-240339-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we're collecting some stats in the driver code, let's support use
of the ethtool driver stats facility in both sunvnet and ldmvsw.

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/ldmvsw.c         |   63 +++++++++++++++++++++++++++++
 drivers/net/ethernet/sun/sunvnet.c        |   63 +++++++++++++++++++++++++++++
 drivers/net/ethernet/sun/sunvnet_common.c |    2 +
 3 files changed, 128 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
index 335b876..3999fb7 100644
--- a/drivers/net/ethernet/sun/ldmvsw.c
+++ b/drivers/net/ethernet/sun/ldmvsw.c
@@ -80,11 +80,74 @@ static void vsw_set_msglevel(struct net_device *dev, u32 value)
 	port->vp->msg_enable = value;
 }
 
+static const struct {
+	const char string[ETH_GSTRING_LEN];
+} ethtool_stats_keys[] = {
+	{ "rx_packets" },
+	{ "tx_packets" },
+	{ "rx_bytes" },
+	{ "tx_bytes" },
+	{ "rx_errors" },
+	{ "tx_errors" },
+	{ "rx_dropped" },
+	{ "tx_dropped" },
+	{ "multicast" },
+	{ "rx_length_errors" },
+	{ "rx_frame_errors" },
+	{ "rx_missed_errors" },
+	{ "tx_carrier_errors" },
+};
+
+static int vsw_get_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(ethtool_stats_keys);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void vsw_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(buf, &ethtool_stats_keys, sizeof(ethtool_stats_keys));
+		break;
+	default:
+		WARN_ON(1);
+		break;
+	}
+}
+
+static void vsw_get_ethtool_stats(struct net_device *dev,
+				  struct ethtool_stats *estats, u64 *data)
+{
+	int i = 0;
+
+	data[i++] = dev->stats.rx_packets;
+	data[i++] = dev->stats.tx_packets;
+	data[i++] = dev->stats.rx_bytes;
+	data[i++] = dev->stats.tx_bytes;
+	data[i++] = dev->stats.rx_errors;
+	data[i++] = dev->stats.tx_errors;
+	data[i++] = dev->stats.rx_dropped;
+	data[i++] = dev->stats.tx_dropped;
+	data[i++] = dev->stats.multicast;
+	data[i++] = dev->stats.rx_length_errors;
+	data[i++] = dev->stats.rx_frame_errors;
+	data[i++] = dev->stats.rx_missed_errors;
+	data[i++] = dev->stats.tx_carrier_errors;
+}
+
 static const struct ethtool_ops vsw_ethtool_ops = {
 	.get_drvinfo		= vsw_get_drvinfo,
 	.get_msglevel		= vsw_get_msglevel,
 	.set_msglevel		= vsw_set_msglevel,
 	.get_link		= ethtool_op_get_link,
+	.get_sset_count		= vsw_get_sset_count,
+	.get_strings		= vsw_get_strings,
+	.get_ethtool_stats	= vsw_get_ethtool_stats,
 };
 
 static LIST_HEAD(vnet_list);
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 4cc2571..e225b27 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -77,11 +77,74 @@ static void vnet_set_msglevel(struct net_device *dev, u32 value)
 	vp->msg_enable = value;
 }
 
+static const struct {
+	const char string[ETH_GSTRING_LEN];
+} ethtool_stats_keys[] = {
+	{ "rx_packets" },
+	{ "tx_packets" },
+	{ "rx_bytes" },
+	{ "tx_bytes" },
+	{ "rx_errors" },
+	{ "tx_errors" },
+	{ "rx_dropped" },
+	{ "tx_dropped" },
+	{ "multicast" },
+	{ "rx_length_errors" },
+	{ "rx_frame_errors" },
+	{ "rx_missed_errors" },
+	{ "tx_carrier_errors" },
+};
+
+static int vnet_get_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(ethtool_stats_keys);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void vnet_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(buf, &ethtool_stats_keys, sizeof(ethtool_stats_keys));
+		break;
+	default:
+		WARN_ON(1);
+		break;
+	}
+}
+
+static void vnet_get_ethtool_stats(struct net_device *dev,
+				   struct ethtool_stats *estats, u64 *data)
+{
+	int i = 0;
+
+	data[i++] = dev->stats.rx_packets;
+	data[i++] = dev->stats.tx_packets;
+	data[i++] = dev->stats.rx_bytes;
+	data[i++] = dev->stats.tx_bytes;
+	data[i++] = dev->stats.rx_errors;
+	data[i++] = dev->stats.tx_errors;
+	data[i++] = dev->stats.rx_dropped;
+	data[i++] = dev->stats.tx_dropped;
+	data[i++] = dev->stats.multicast;
+	data[i++] = dev->stats.rx_length_errors;
+	data[i++] = dev->stats.rx_frame_errors;
+	data[i++] = dev->stats.rx_missed_errors;
+	data[i++] = dev->stats.tx_carrier_errors;
+}
+
 static const struct ethtool_ops vnet_ethtool_ops = {
 	.get_drvinfo		= vnet_get_drvinfo,
 	.get_msglevel		= vnet_get_msglevel,
 	.set_msglevel		= vnet_set_msglevel,
 	.get_link		= ethtool_op_get_link,
+	.get_sset_count		= vnet_get_sset_count,
+	.get_strings		= vnet_get_strings,
+	.get_ethtool_stats	= vnet_get_ethtool_stats,
 };
 
 static LIST_HEAD(vnet_list);
diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 0f940f0..624ad65 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -409,6 +409,8 @@ static int vnet_rx_one(struct vnet_port *port, struct vio_net_desc *desc)
 
 	skb->ip_summed = port->switch_port ? CHECKSUM_NONE : CHECKSUM_PARTIAL;
 
+	if (unlikely(is_multicast_ether_addr(eth_hdr(skb)->h_dest)))
+		dev->stats.multicast++;
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += len;
 	napi_gro_receive(&port->napi, skb);
-- 
1.7.1
