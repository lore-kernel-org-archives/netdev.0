From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH v2 net-next 2/5] sunvnet: add stats to track ldom to ldom packets and bytes
Date: Tue, 14 Mar 2017 10:24:40 -0700
Message-ID: <1489512283-422140-3-git-send-email-shannon.nelson@oracle.com>
References: <1489512283-422140-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489512283-422140-1-git-send-email-shannon.nelson@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In this driver, there is a "port" created for the connection to each of
the other ldoms; a netdev queue is mapped to each port, and they are
collected under a single netdev.  The generic netdev statistics show
us all the traffic in and out of our network device, but don't show
individual queue/port stats.  This patch breaks out the traffic counts
for the individual ports and gives us a little view into the state of
those connections.

Orabug: 25190537

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c        |  116 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/sun/sunvnet_common.c |    6 ++
 drivers/net/ethernet/sun/sunvnet_common.h |   15 ++++
 3 files changed, 136 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 4cc2571..7543bdd 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1,7 +1,7 @@
 /* sunvnet.c: Sun LDOM Virtual Network Driver.
  *
  * Copyright (C) 2007, 2008 David S. Miller <davem@davemloft.net>
- * Copyright (C) 2016 Oracle. All rights reserved.
+ * Copyright (C) 2016-2017 Oracle. All rights reserved.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -77,11 +77,125 @@ static void vnet_set_msglevel(struct net_device *dev, u32 value)
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
+	{ "nports" },
+};
+
+static int vnet_get_sset_count(struct net_device *dev, int sset)
+{
+	struct vnet *vp = (struct vnet *)netdev_priv(dev);
+
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(ethtool_stats_keys)
+			+ (NUM_VNET_PORT_STATS * vp->nports);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void vnet_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
+{
+	struct vnet *vp = (struct vnet *)netdev_priv(dev);
+	struct vnet_port *port;
+	char *p = (char *)buf;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(buf, &ethtool_stats_keys, sizeof(ethtool_stats_keys));
+		p += sizeof(ethtool_stats_keys);
+
+		rcu_read_lock();
+		list_for_each_entry_rcu(port, &vp->port_list, list) {
+			snprintf(p, ETH_GSTRING_LEN, "p%u.%s-%pM",
+				 port->q_index, port->switch_port ? "s" : "q",
+				 port->raddr);
+			p += ETH_GSTRING_LEN;
+			snprintf(p, ETH_GSTRING_LEN, "p%u.rx_packets",
+				 port->q_index);
+			p += ETH_GSTRING_LEN;
+			snprintf(p, ETH_GSTRING_LEN, "p%u.tx_packets",
+				 port->q_index);
+			p += ETH_GSTRING_LEN;
+			snprintf(p, ETH_GSTRING_LEN, "p%u.rx_bytes",
+				 port->q_index);
+			p += ETH_GSTRING_LEN;
+			snprintf(p, ETH_GSTRING_LEN, "p%u.tx_bytes",
+				 port->q_index);
+			p += ETH_GSTRING_LEN;
+			snprintf(p, ETH_GSTRING_LEN, "p%u.event_up",
+				 port->q_index);
+			p += ETH_GSTRING_LEN;
+			snprintf(p, ETH_GSTRING_LEN, "p%u.event_reset",
+				 port->q_index);
+			p += ETH_GSTRING_LEN;
+		}
+		rcu_read_unlock();
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
+	struct vnet *vp = (struct vnet *)netdev_priv(dev);
+	struct vnet_port *port;
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
+	data[i++] = vp->nports;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(port, &vp->port_list, list) {
+		data[i++] = port->q_index;
+		data[i++] = port->stats.rx_packets;
+		data[i++] = port->stats.tx_packets;
+		data[i++] = port->stats.rx_bytes;
+		data[i++] = port->stats.tx_bytes;
+		data[i++] = port->stats.event_up;
+		data[i++] = port->stats.event_reset;
+	}
+	rcu_read_unlock();
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
index 1a65892..d3dc8ed 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -411,6 +411,8 @@ static int vnet_rx_one(struct vnet_port *port, struct vio_net_desc *desc)
 
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += len;
+	port->stats.rx_packets++;
+	port->stats.rx_bytes += len;
 	napi_gro_receive(&port->napi, skb);
 	return 0;
 
@@ -768,6 +770,7 @@ static int vnet_event_napi(struct vnet_port *port, int budget)
 			maybe_tx_wakeup(port);
 
 		port->rx_event = 0;
+		port->stats.event_reset++;
 		return 0;
 	}
 
@@ -781,6 +784,7 @@ static int vnet_event_napi(struct vnet_port *port, int budget)
 
 		vio_link_state_change(vio, LDC_EVENT_UP);
 		port->rx_event = 0;
+		port->stats.event_up++;
 		return 0;
 	}
 
@@ -1430,6 +1434,8 @@ int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev,
 
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += port->tx_bufs[txi].skb->len;
+	port->stats.tx_packets++;
+	port->stats.tx_bytes += port->tx_bufs[txi].skb->len;
 
 	dr->prod = (dr->prod + 1) & (VNET_TX_RING_SIZE - 1);
 	if (unlikely(vnet_tx_dring_avail(dr) < 1)) {
diff --git a/drivers/net/ethernet/sun/sunvnet_common.h b/drivers/net/ethernet/sun/sunvnet_common.h
index b21ef47..c0fac03 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.h
+++ b/drivers/net/ethernet/sun/sunvnet_common.h
@@ -35,6 +35,19 @@ struct vnet_tx_entry {
 
 struct vnet;
 
+struct vnet_port_stats {
+	/* keep them all the same size */
+	u32 rx_bytes;
+	u32 tx_bytes;
+	u32 rx_packets;
+	u32 tx_packets;
+	u32 event_up;
+	u32 event_reset;
+	u32 q_placeholder;
+};
+
+#define NUM_VNET_PORT_STATS  (sizeof(struct vnet_port_stats) / sizeof(u32))
+
 /* Structure to describe a vnet-port or vsw-port in the MD.
  * If the vsw bit is set, this structure represents a vswitch
  * port, and the net_device can be found from ->dev. If the
@@ -44,6 +57,8 @@ struct vnet_tx_entry {
 struct vnet_port {
 	struct vio_driver_state	vio;
 
+	struct vnet_port_stats stats;
+
 	struct hlist_node	hash;
 	u8			raddr[ETH_ALEN];
 	unsigned		switch_port:1;
-- 
1.7.1
