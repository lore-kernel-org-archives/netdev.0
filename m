From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 5/9] net/eipoib: Add ethtool file support
Date: Tue, 10 Jul 2012 15:16:05 +0300
Message-ID: <1341922569-4118-6-git-send-email-ogerlitz@mellanox.com>
References: <1341922569-4118-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:49009 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755396Ab2GJMQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 08:16:26 -0400
In-Reply-To: <1341922569-4118-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.co.il>

Via ethtool the driver describes its version, ABI version, on what PIF
interface it runs and various statistics.

Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/eipoib/eth_ipoib_ethtool.c |  147 ++++++++++++++++++++++++++++++++
 1 files changed, 147 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/eipoib/eth_ipoib_ethtool.c

diff --git a/drivers/net/eipoib/eth_ipoib_ethtool.c b/drivers/net/eipoib/eth_ipoib_ethtool.c
new file mode 100644
index 0000000..b5c20ec
--- /dev/null
+++ b/drivers/net/eipoib/eth_ipoib_ethtool.c
@@ -0,0 +1,147 @@
+/*
+ * Copyright (c) 2012 Mellanox Technologies. All rights reserved
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * openfabric.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include "eth_ipoib.h"
+
+static void parent_ethtool_get_drvinfo(struct net_device *parent_dev,
+				       struct ethtool_drvinfo *drvinfo)
+{
+	struct parent *parent = netdev_priv(parent_dev);
+
+	if (strlen(DRV_NAME) + strlen(parent->ipoib_main_interface) > 31)
+		strncpy(drvinfo->driver, "driver name is too long", 32);
+	else
+		sprintf(drvinfo->driver, "%s:%s",
+			DRV_NAME, parent->ipoib_main_interface);
+
+	strncpy(drvinfo->version, DRV_VERSION, 32);
+
+	/* indicates ABI version */
+	snprintf(drvinfo->fw_version, 32, "%d", EIPOIB_ABI_VER);
+}
+
+static const char parent_strings[][ETH_GSTRING_LEN] = {
+	/* public statistics */
+	"rx_packets", "tx_packets", "rx_bytes",
+	"tx_bytes", "rx_errors", "tx_errors",
+	"rx_dropped", "tx_dropped", "multicast",
+	"collisions", "rx_length_errors", "rx_over_errors",
+	"rx_crc_errors", "rx_frame_errors", "rx_fifo_errors",
+	"rx_missed_errors", "tx_aborted_errors", "tx_carrier_errors",
+	"tx_fifo_errors", "tx_heartbeat_errors", "tx_window_errors",
+#define PUB_STATS_LEN	21
+
+	/* private statistics */
+	"tx_parent_dropped",
+	"tx_vif_miss",
+	"tx_neigh_miss",
+	"tx_vlan",
+	"tx_shared",
+	"tx_proto_errors",
+	"tx_skb_errors",
+	"tx_slave_err",
+
+	"rx_parent_dropped",
+	"rx_vif_miss",
+	"rx_neigh_miss",
+	"rx_vlan",
+	"rx_shared",
+	"rx_proto_errors",
+	"rx_skb_errors",
+	"rx_slave_err",
+#define PORT_STATS_LEN	(8 * 2)
+
+};
+
+#define PARENT_STATS_LEN (sizeof(parent_strings) / ETH_GSTRING_LEN)
+
+static void parent_get_strings(struct net_device *parent_dev,
+			       uint32_t stringset, uint8_t *data)
+{
+	int index = 0, stats_off = 0, i;
+
+	if (stringset != ETH_SS_STATS)
+		return;
+
+	/* Add main counters */
+	for (i = 0; i < PUB_STATS_LEN; i++)
+		strcpy(data + (index++) * ETH_GSTRING_LEN,
+		       parent_strings[i + stats_off]);
+	stats_off += PUB_STATS_LEN;
+
+	for (i = 0; i < PORT_STATS_LEN; i++)
+		strcpy(data + (index++) * ETH_GSTRING_LEN,
+		       parent_strings[i + stats_off]);
+	stats_off += PORT_STATS_LEN;
+
+}
+
+static void parent_get_ethtool_stats(struct net_device *parent_dev,
+				     struct ethtool_stats *stats,
+				     uint64_t *data)
+{
+	struct parent *parent = netdev_priv(parent_dev);
+	int index = 0, i;
+
+	read_lock(&parent->lock);
+
+	for (i = 0; i < PUB_STATS_LEN; i++)
+		data[index++] = ((unsigned long *) &parent->stats)[i];
+
+	for (i = 0; i < PORT_STATS_LEN; i++)
+		data[index++] = ((unsigned long *) &parent->port_stats)[i];
+
+	read_unlock(&parent->lock);
+}
+
+static int parent_get_sset_count(struct net_device *parent_dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return PARENT_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static const struct ethtool_ops parent_ethtool_ops = {
+	.get_drvinfo		= parent_ethtool_get_drvinfo,
+	.get_strings		= parent_get_strings,
+	.get_ethtool_stats	= parent_get_ethtool_stats,
+	.get_sset_count		= parent_get_sset_count,
+	.get_link		= ethtool_op_get_link,
+};
+
+void parent_set_ethtool_ops(struct net_device *dev)
+{
+	SET_ETHTOOL_OPS(dev, &parent_ethtool_ops);
+}
-- 
1.7.1
