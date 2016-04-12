From: Atish Patra <atish.patra@oracle.com>
Subject: [RFC PATCH net-next] sunvnet: Add ethtool support for netdev stastics
Date: Tue, 12 Apr 2016 09:19:19 -0700
Message-ID: <1460477959-185461-1-git-send-email-atish.patra@oracle.com>
Cc: aaron.young@oracle.com, sowmini.varadhan@oracle.com,
	atish.patra@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48608 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756426AbcDLQUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 12:20:16 -0400
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u3CGKETZ018396
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 16:20:15 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.13.8/8.13.8) with ESMTP id u3CGKEwr015406
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 16:20:14 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserv0122.oracle.com (8.13.8/8.13.8) with ESMTP id u3CGKBTb010579
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 16:20:13 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, sunvnet does not support statstics display
via sysfs entry using ethtool.

This patch enables the basic support in sunvnet that
displays the all the netdev stastics for the specific
interface using ethtool. Other sunvnet statstics and
support for ldmvsw will be added later.

Signed-off-by: Atish Patra <atish.patra@oracle.com>
Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c        |   26 +++++++++++++
 drivers/net/ethernet/sun/sunvnet_common.c |   47 ++++++++++++++++++++++++
 drivers/net/ethernet/sun/sunvnet_common.h |   57 +++++++++++++++++++++++++++++
 3 files changed, 130 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index a2f9b47..7c8aa98 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -77,10 +77,36 @@ static void vnet_set_msglevel(struct net_device *dev, u32 value)
 	vp->msg_enable = value;
 }
 
+static int vnet_get_sset_count(struct net_device *netdev, int sset)
+{
+	int scount;
+
+	scount = sunvnet_get_sset_count_common(netdev, sset,
+					       SUNVNET_ETHTOOL);
+	return scount;
+}
+
+static void vnet_get_ethtool_stats(struct net_device *netdev,
+				   struct ethtool_stats *stats, u64 *data)
+{
+	sunvnet_get_ethtool_stats_common(netdev, stats,
+					 data, SUNVNET_ETHTOOL);
+}
+
+static void vnet_get_strings(struct net_device *netdev,
+			     u32 stringset, u8 *data)
+{
+	sunvnet_get_strings_common(netdev, stringset,
+				   data, SUNVNET_ETHTOOL);
+}
+
 static const struct ethtool_ops vnet_ethtool_ops = {
 	.get_drvinfo		= vnet_get_drvinfo,
 	.get_msglevel		= vnet_get_msglevel,
 	.set_msglevel		= vnet_set_msglevel,
+	.get_strings            = vnet_get_strings,
+	.get_ethtool_stats      = vnet_get_ethtool_stats,
+	.get_sset_count         = vnet_get_sset_count,
 	.get_link		= ethtool_op_get_link,
 };
 
diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 904a5a1..2781740 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -1730,3 +1730,50 @@ void sunvnet_port_rm_txq_common(struct vnet_port *port)
 						port->q_index));
 }
 EXPORT_SYMBOL_GPL(sunvnet_port_rm_txq_common);
+
+int sunvnet_get_sset_count_common(struct net_device *netdev,
+				  int sset, unsigned int drv_type)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return VNET_NETDEV_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+EXPORT_SYMBOL_GPL(sunvnet_get_sset_count_common);
+
+void sunvnet_get_ethtool_stats_common(struct net_device *netdev,
+				      struct ethtool_stats *stats, u64 *data,
+				      unsigned int drv_type)
+{
+	int i = 0;
+	int j;
+	char *p;
+
+	for (j = 0; j < VNET_NETDEV_STATS_LEN; j++) {
+		p = (char *)netdev + vnet_gstrings_net_stats[j].stat_offset;
+		data[i++] = (vnet_gstrings_net_stats[j].sizeof_stat ==
+			     sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
+	}
+}
+EXPORT_SYMBOL_GPL(sunvnet_get_ethtool_stats_common);
+
+void sunvnet_get_strings_common(struct net_device *netdev,
+				u32 stringset, u8 *data,
+				unsigned int drv_type)
+{
+	u8 *p = data;
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < VNET_NETDEV_STATS_LEN; i++) {
+			snprintf(p, ETH_GSTRING_LEN, "%s",
+				 vnet_gstrings_net_stats[i].stat_string);
+			p += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+EXPORT_SYMBOL_GPL(sunvnet_get_strings_common);
diff --git a/drivers/net/ethernet/sun/sunvnet_common.h b/drivers/net/ethernet/sun/sunvnet_common.h
index bd36528..9618d42 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.h
+++ b/drivers/net/ethernet/sun/sunvnet_common.h
@@ -72,6 +72,55 @@ struct vnet_port {
 	u16			q_index;
 };
 
+/* Ethtool support strings and macros */
+enum {
+	SUNVNET_ETHTOOL,
+	VSW_ETHTOOL
+};
+
+struct vnet_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	u8 sizeof_stat;
+	u64 stat_offset;
+};
+
+#define VNET_STAT(_type, _name, _stat) { \
+	.stat_string = _name, \
+	.sizeof_stat = FIELD_SIZEOF(_type, _stat), \
+	.stat_offset = offsetof(_type, _stat) \
+}
+
+#define VNET_NETDEV_STAT(_name, _net_stat) \
+		VNET_STAT(struct net_device, _name, _net_stat)
+
+static const struct vnet_stats vnet_gstrings_net_stats[] = {
+	VNET_NETDEV_STAT("rx_packets", stats.rx_packets),
+	VNET_NETDEV_STAT("tx_packets", stats.tx_packets),
+	VNET_NETDEV_STAT("rx_bytes", stats.rx_bytes),
+	VNET_NETDEV_STAT("tx_bytes", stats.tx_bytes),
+	VNET_NETDEV_STAT("rx_errors", stats.rx_errors),
+	VNET_NETDEV_STAT("tx_errors", stats.tx_errors),
+	VNET_NETDEV_STAT("rx_dropped", stats.rx_dropped),
+	VNET_NETDEV_STAT("tx_dropped", stats.tx_dropped),
+	VNET_NETDEV_STAT("multicast", stats.multicast),
+	VNET_NETDEV_STAT("collisions", stats.collisions),
+	VNET_NETDEV_STAT("rx_length_errors", stats.rx_length_errors),
+	VNET_NETDEV_STAT("rx_over_errors", stats.rx_over_errors),
+	VNET_NETDEV_STAT("rx_crc_errors", stats.rx_crc_errors),
+	VNET_NETDEV_STAT("rx_frame_errors", stats.rx_frame_errors),
+	VNET_NETDEV_STAT("rx_fifo_errors", stats.rx_fifo_errors),
+	VNET_NETDEV_STAT("rx_missed_errors", stats.rx_missed_errors),
+	VNET_NETDEV_STAT("tx_aborted_errors", stats.tx_aborted_errors),
+	VNET_NETDEV_STAT("tx_carrier_errors", stats.tx_carrier_errors),
+	VNET_NETDEV_STAT("tx_fifo_errors", stats.tx_fifo_errors),
+	VNET_NETDEV_STAT("tx_heartbeat_errors", stats.tx_heartbeat_errors),
+	VNET_NETDEV_STAT("tx_window_errors", stats.tx_window_errors),
+	VNET_NETDEV_STAT("rx_compressed", stats.rx_compressed),
+	VNET_NETDEV_STAT("tx_compressed", stats.tx_compressed),
+};
+
+#define VNET_NETDEV_STATS_LEN ARRAY_SIZE(vnet_gstrings_net_stats)
+
 static inline struct vnet_port *to_vnet_port(struct vio_driver_state *vio)
 {
 	return container_of(vio, struct vnet_port, vio);
@@ -141,5 +190,13 @@ void sunvnet_port_free_tx_bufs_common(struct vnet_port *port);
 bool sunvnet_port_is_up_common(struct vnet_port *vnet);
 void sunvnet_port_add_txq_common(struct vnet_port *port);
 void sunvnet_port_rm_txq_common(struct vnet_port *port);
+int sunvnet_get_sset_count_common(struct net_device *netdev, int sset,
+				  unsigned int drv_type);
+void sunvnet_get_ethtool_stats_common(struct net_device *netdev,
+				      struct ethtool_stats *stats, u64 *data,
+				      unsigned int drv_type);
+void sunvnet_get_strings_common(struct net_device *netdev,
+				u32 stringset, u8 *data,
+				unsigned int drv_type);
 
 #endif /* _SUNVNETCOMMON_H */
-- 
1.7.1
