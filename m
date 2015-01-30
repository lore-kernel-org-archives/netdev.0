From: David Ahern <dsahern@gmail.com>
Subject: [PATCH] net: rocker: Add support for retrieving port level statistics
Date: Thu, 29 Jan 2015 20:59:33 -0700
Message-ID: <1422590373-22807-1-git-send-email-dsahern@gmail.com>
Cc: sfeldma@gmail.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:45385 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754553AbbA3EA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 23:00:26 -0500
Received: by mail-ie0-f173.google.com with SMTP id tr6so973534ieb.4
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 20:00:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for retrieving port level statistics from device.
Hook is added for ethtool's stats functionality. For example,

$ ethtool -S eth3
NIC statistics:
     rx_packets: 12
     rx_bytes: 2790
     rx_dropped: 0
     rx_errors: 0
     tx_packets: 8
     tx_bytes: 728
     tx_dropped: 0
     tx_errors: 0

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c | 134 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/rocker/rocker.h |  21 ++++++
 2 files changed, 155 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 11f4ffcc113d..e6f13f912fa2 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3833,11 +3833,145 @@ static void rocker_port_get_drvinfo(struct net_device *dev,
 	strlcpy(drvinfo->version, UTS_RELEASE, sizeof(drvinfo->version));
 }
 
+static struct rocker_port_stats {
+	char str[ETH_GSTRING_LEN];
+	int type;
+} rocker_port_stats[] = {
+	{ "rx_packets", ROCKER_TLV_CMD_PORT_STATS_RX_PKTS,    },
+	{ "rx_bytes",   ROCKER_TLV_CMD_PORT_STATS_RX_BYTES,   },
+	{ "rx_dropped", ROCKER_TLV_CMD_PORT_STATS_RX_DROPPED, },
+	{ "rx_errors",  ROCKER_TLV_CMD_PORT_STATS_RX_ERRORS,  },
+
+	{ "tx_packets", ROCKER_TLV_CMD_PORT_STATS_TX_PKTS,    },
+	{ "tx_bytes",   ROCKER_TLV_CMD_PORT_STATS_TX_BYTES,   },
+	{ "tx_dropped", ROCKER_TLV_CMD_PORT_STATS_TX_DROPPED, },
+	{ "tx_errors",  ROCKER_TLV_CMD_PORT_STATS_TX_ERRORS,  },
+};
+
+#define ROCKER_PORT_STATS_LEN  ARRAY_SIZE(rocker_port_stats)
+
+static void rocker_port_get_strings(struct net_device *netdev, u32 stringset,
+				    u8 *data)
+{
+	u8 *p = data;
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < ARRAY_SIZE(rocker_port_stats); i++) {
+			memcpy(p, rocker_port_stats[i].str, ETH_GSTRING_LEN);
+			p += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+
+static int
+rocker_cmd_get_port_stats_prep(struct rocker *rocker,
+			       struct rocker_port *rocker_port,
+			       struct rocker_desc_info *desc_info,
+			       void *priv)
+{
+	struct rocker_tlv *cmd_stats;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
+			       ROCKER_TLV_CMD_TYPE_GET_PORT_STATS))
+		return -EMSGSIZE;
+
+	cmd_stats = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
+	if (!cmd_stats)
+		return -EMSGSIZE;
+
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_STATS_LPORT,
+			       rocker_port->lport))
+		return -EMSGSIZE;
+
+	rocker_tlv_nest_end(desc_info, cmd_stats);
+
+	return 0;
+}
+
+static int
+rocker_cmd_get_port_stats_ethtool_proc(struct rocker *rocker,
+				       struct rocker_port *rocker_port,
+				       struct rocker_desc_info *desc_info,
+				       void *priv)
+{
+	struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
+	struct rocker_tlv *stats_attrs[ROCKER_TLV_CMD_PORT_STATS_MAX + 1];
+	struct rocker_tlv *pattr;
+	u32 lport;
+	u64 *data = priv;
+	int i;
+
+	rocker_tlv_parse_desc(attrs, ROCKER_TLV_CMD_MAX, desc_info);
+
+	if (!attrs[ROCKER_TLV_CMD_INFO])
+		return -EIO;
+
+	rocker_tlv_parse_nested(stats_attrs, ROCKER_TLV_CMD_PORT_STATS_MAX,
+				attrs[ROCKER_TLV_CMD_INFO]);
+
+	if (!stats_attrs[ROCKER_TLV_CMD_PORT_STATS_LPORT])
+		return -EIO;
+
+	lport = rocker_tlv_get_u32(stats_attrs[ROCKER_TLV_CMD_PORT_STATS_LPORT]);
+	if (lport != rocker_port->lport)
+		return -EIO;
+
+	for (i = 0; i < ARRAY_SIZE(rocker_port_stats); i++) {
+		pattr = stats_attrs[rocker_port_stats[i].type];
+		if (!pattr)
+			continue;
+
+		data[i] = rocker_tlv_get_u64(pattr);
+	}
+
+	return 0;
+}
+
+static int rocker_cmd_get_port_stats_ethtool(struct rocker_port *rocker_port,
+					     void *priv)
+{
+	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
+			       rocker_cmd_get_port_stats_prep, NULL,
+			       rocker_cmd_get_port_stats_ethtool_proc,
+			       priv, false);
+}
+
+static void rocker_port_get_stats(struct net_device *dev,
+				  struct ethtool_stats *stats, u64 *data)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+
+	if (rocker_cmd_get_port_stats_ethtool(rocker_port, data) != 0) {
+		int i;
+
+		for (i = 0; i < ARRAY_SIZE(rocker_port_stats); ++i)
+			data[i] = 0;
+	}
+
+	return;
+}
+
+static int rocker_port_get_sset_count(struct net_device *netdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ROCKER_PORT_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static const struct ethtool_ops rocker_port_ethtool_ops = {
 	.get_settings		= rocker_port_get_settings,
 	.set_settings		= rocker_port_set_settings,
 	.get_drvinfo		= rocker_port_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
+	.get_strings		= rocker_port_get_strings,
+	.get_ethtool_stats	= rocker_port_get_stats,
+	.get_sset_count		= rocker_port_get_sset_count,
 };
 
 /*****************
diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index 8d2865ba634c..a5bc432feada 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -127,6 +127,9 @@ enum {
 	ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_DEL,
 	ROCKER_TLV_CMD_TYPE_OF_DPA_GROUP_GET_STATS,
 
+	ROCKER_TLV_CMD_TYPE_CLEAR_PORT_STATS,
+	ROCKER_TLV_CMD_TYPE_GET_PORT_STATS,
+
 	__ROCKER_TLV_CMD_TYPE_MAX,
 	ROCKER_TLV_CMD_TYPE_MAX = __ROCKER_TLV_CMD_TYPE_MAX - 1,
 };
@@ -146,6 +149,24 @@ enum {
 			__ROCKER_TLV_CMD_PORT_SETTINGS_MAX - 1,
 };
 
+enum {
+	ROCKER_TLV_CMD_PORT_STATS_UNSPEC,
+	ROCKER_TLV_CMD_PORT_STATS_LPORT,            /* u32 */
+
+	ROCKER_TLV_CMD_PORT_STATS_RX_PKTS,          /* u64 */
+	ROCKER_TLV_CMD_PORT_STATS_RX_BYTES,         /* u64 */
+	ROCKER_TLV_CMD_PORT_STATS_RX_DROPPED,       /* u64 */
+	ROCKER_TLV_CMD_PORT_STATS_RX_ERRORS,        /* u64 */
+
+	ROCKER_TLV_CMD_PORT_STATS_TX_PKTS,          /* u64 */
+	ROCKER_TLV_CMD_PORT_STATS_TX_BYTES,         /* u64 */
+	ROCKER_TLV_CMD_PORT_STATS_TX_DROPPED,       /* u64 */
+	ROCKER_TLV_CMD_PORT_STATS_TX_ERRORS,        /* u64 */
+
+	__ROCKER_TLV_CMD_PORT_STATS_MAX,
+	ROCKER_TLV_CMD_PORT_STATS_MAX = __ROCKER_TLV_CMD_PORT_STATS_MAX - 1,
+};
+
 enum rocker_port_mode {
 	ROCKER_PORT_MODE_OF_DPA,
 };
-- 
1.9.3
