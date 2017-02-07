From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: [RFC v3 05/11] IB/hfi-vnic: VNIC statistics support
Date: Tue,  7 Feb 2017 12:23:04 -0800
Message-ID: <1486498990-76562-6-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com, ira.weiny@intel.com,
        Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63728 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932245AbdBGUXt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 15:23:49 -0500
In-Reply-To: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HFI VNIC driver statistics support maintains various counters including
standard netdev counters and the Ethernet manager defined counters.
Add the Ethtool hook to read the counters.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
---
 drivers/infiniband/ulp/hfi_vnic/hfi_vnic_ethtool.c | 128 +++++++++++++++++++++
 .../infiniband/ulp/hfi_vnic/hfi_vnic_internal.h    |   4 +
 drivers/infiniband/ulp/hfi_vnic/hfi_vnic_netdev.c  |  20 ++++
 3 files changed, 152 insertions(+)

diff --git a/drivers/infiniband/ulp/hfi_vnic/hfi_vnic_ethtool.c b/drivers/infiniband/ulp/hfi_vnic/hfi_vnic_ethtool.c
index ca058a4..a9925df 100644
--- a/drivers/infiniband/ulp/hfi_vnic/hfi_vnic_ethtool.c
+++ b/drivers/infiniband/ulp/hfi_vnic/hfi_vnic_ethtool.c
@@ -53,9 +53,137 @@
 
 #include "hfi_vnic_internal.h"
 
+enum {NETDEV_STATS, VNIC_STATS};
+
+struct vnic_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	struct {
+		int type;
+		int sizeof_stat;
+		int stat_offset;
+	};
+};
+
+#define VNIC_STAT(m)            { VNIC_STATS,                               \
+				  FIELD_SIZEOF(struct hfi_vnic_stats, m),   \
+				  offsetof(struct hfi_vnic_stats, m) }
+#define VNIC_NETDEV_STAT(m)     { NETDEV_STATS,                             \
+				  FIELD_SIZEOF(struct net_device, m),       \
+				  offsetof(struct net_device, m) }
+
+static struct vnic_stats vnic_gstrings_stats[] = {
+	/* NETDEV stats */
+	{"rx_packets", VNIC_NETDEV_STAT(stats.rx_packets)},
+	{"tx_packets", VNIC_NETDEV_STAT(stats.tx_packets)},
+	{"rx_bytes", VNIC_NETDEV_STAT(stats.rx_bytes)},
+	{"tx_bytes", VNIC_NETDEV_STAT(stats.tx_bytes)},
+	{"rx_errors", VNIC_NETDEV_STAT(stats.rx_errors)},
+	{"tx_errors", VNIC_NETDEV_STAT(stats.tx_errors)},
+	{"rx_dropped", VNIC_NETDEV_STAT(stats.rx_dropped)},
+	{"tx_dropped", VNIC_NETDEV_STAT(stats.tx_dropped)},
+
+	/* SUMMARY counters */
+	{"tx_unicast", VNIC_STAT(tx_grp.unicast)},
+	{"tx_mcastbcast", VNIC_STAT(tx_grp.mcastbcast)},
+	{"tx_untagged", VNIC_STAT(tx_grp.untagged)},
+	{"tx_vlan", VNIC_STAT(tx_grp.vlan)},
+
+	{"tx_64_size", VNIC_STAT(tx_grp.s_64)},
+	{"tx_65_127", VNIC_STAT(tx_grp.s_65_127)},
+	{"tx_128_255", VNIC_STAT(tx_grp.s_128_255)},
+	{"tx_256_511", VNIC_STAT(tx_grp.s_256_511)},
+	{"tx_512_1023", VNIC_STAT(tx_grp.s_512_1023)},
+	{"tx_1024_1518", VNIC_STAT(tx_grp.s_1024_1518)},
+	{"tx_1519_max", VNIC_STAT(tx_grp.s_1519_max)},
+
+	{"rx_unicast", VNIC_STAT(rx_grp.unicast)},
+	{"rx_mcastbcast", VNIC_STAT(rx_grp.mcastbcast)},
+	{"rx_untagged", VNIC_STAT(rx_grp.untagged)},
+	{"rx_vlan", VNIC_STAT(rx_grp.vlan)},
+
+	{"rx_64_size", VNIC_STAT(rx_grp.s_64)},
+	{"rx_65_127", VNIC_STAT(rx_grp.s_65_127)},
+	{"rx_128_255", VNIC_STAT(rx_grp.s_128_255)},
+	{"rx_256_511", VNIC_STAT(rx_grp.s_256_511)},
+	{"rx_512_1023", VNIC_STAT(rx_grp.s_512_1023)},
+	{"rx_1024_1518", VNIC_STAT(rx_grp.s_1024_1518)},
+	{"rx_1519_max", VNIC_STAT(rx_grp.s_1519_max)},
+
+	/* ERROR counters */
+	{"rx_fifo_errors", VNIC_NETDEV_STAT(stats.rx_fifo_errors)},
+	{"rx_length_errors", VNIC_NETDEV_STAT(stats.rx_length_errors)},
+
+	{"tx_fifo_errors", VNIC_NETDEV_STAT(stats.tx_fifo_errors)},
+	{"tx_carrier_errors", VNIC_NETDEV_STAT(stats.tx_carrier_errors)},
+
+	{"tx_dlid_zero", VNIC_STAT(tx_dlid_zero)},
+	{"tx_drop_state", VNIC_STAT(tx_drop_state)},
+	{"rx_drop_state", VNIC_STAT(rx_drop_state)},
+	{"rx_oversize", VNIC_STAT(rx_oversize)},
+	{"rx_runt", VNIC_STAT(rx_runt)},
+};
+
+#define VNIC_STATS_LEN  ARRAY_SIZE(vnic_gstrings_stats)
+
+/* vnic_get_sset_count - get string set count */
+static int vnic_get_sset_count(struct net_device *netdev, int sset)
+{
+	return (sset == ETH_SS_STATS) ? VNIC_STATS_LEN : -EOPNOTSUPP;
+}
+
+/* vnic_get_ethtool_stats - get statistics */
+static void vnic_get_ethtool_stats(struct net_device *netdev,
+				   struct ethtool_stats *stats, u64 *data)
+{
+	struct hfi_vnic_adapter *adapter = hfi_vnic_priv(netdev);
+	struct hfi_vnic_stats vstats;
+	char *p = NULL;
+	int i;
+
+	memset(&vstats, 0, sizeof(vstats));
+	mutex_lock(&adapter->stats_lock);
+	adapter->rn_ops->ndo_get_stats64(netdev, &vstats.netstats);
+	for (i = 0; i < VNIC_STATS_LEN; i++) {
+		switch (vnic_gstrings_stats[i].type) {
+		case NETDEV_STATS:
+			p = (char *)netdev +
+			  vnic_gstrings_stats[i].stat_offset;
+			break;
+		case VNIC_STATS:
+			p = (char *)&vstats +
+			  vnic_gstrings_stats[i].stat_offset;
+			break;
+		default:
+			p = NULL;
+		}
+
+		if (p)
+			data[i] = (vnic_gstrings_stats[i].sizeof_stat ==
+			   sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
+	}
+	mutex_unlock(&adapter->stats_lock);
+}
+
+/* vnic_get_strings - get strings */
+static void vnic_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
+{
+	int i;
+
+	if (stringset != ETH_SS_STATS)
+		return;
+
+	for (i = 0; i < VNIC_STATS_LEN; i++)
+		memcpy(data + i * ETH_GSTRING_LEN,
+		       vnic_gstrings_stats[i].stat_string,
+		       ETH_GSTRING_LEN);
+}
+
 /* ethtool ops */
 static const struct ethtool_ops hfi_vnic_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
+	.get_strings = vnic_get_strings,
+	.get_sset_count = vnic_get_sset_count,
+	.get_ethtool_stats = vnic_get_ethtool_stats,
 };
 
 /* hfi_vnic_set_ethtool_ops - set ethtool ops */
diff --git a/drivers/infiniband/ulp/hfi_vnic/hfi_vnic_internal.h b/drivers/infiniband/ulp/hfi_vnic/hfi_vnic_internal.h
index 5ce925f..d4fcf3b 100644
--- a/drivers/infiniband/ulp/hfi_vnic/hfi_vnic_internal.h
+++ b/drivers/infiniband/ulp/hfi_vnic/hfi_vnic_internal.h
@@ -169,6 +169,7 @@ struct __hfi_veswport_trap {
  * @vport_num: vesw port number
  * @lock: adapter lock
  * @info: virtual ethernet switch port information
+ * @stats_lock: statistics lock
  * @flow_tbl: flow to default port redirection table
  */
 struct hfi_vnic_adapter {
@@ -184,6 +185,9 @@ struct hfi_vnic_adapter {
 
 	struct __hfi_veswport_info info;
 
+	/* Lock used to protect access to vnic counters */
+	struct mutex stats_lock;
+
 	u8 flow_tbl[HFI_VNIC_FLOW_TBL_SIZE];
 };
 
diff --git a/drivers/infiniband/ulp/hfi_vnic/hfi_vnic_netdev.c b/drivers/infiniband/ulp/hfi_vnic/hfi_vnic_netdev.c
index f04c8a834..ba045ac 100644
--- a/drivers/infiniband/ulp/hfi_vnic/hfi_vnic_netdev.c
+++ b/drivers/infiniband/ulp/hfi_vnic/hfi_vnic_netdev.c
@@ -59,6 +59,22 @@
 #define HFI_VNIC_SKB_HEADROOM  \
 			ALIGN((HFI_VNIC_HDR_LEN + HFI_VNIC_SKB_MDATA_LEN), 8)
 
+/* This function is overloaded for hfi_vnic specific implementation */
+static struct rtnl_link_stats64 *
+hfi_vnic_get_stats64(struct net_device *netdev,
+		     struct rtnl_link_stats64 *stats)
+{
+	struct hfi_vnic_adapter *adapter = hfi_vnic_priv(netdev);
+	struct hfi_vnic_stats vstats;
+
+	memset(&vstats, 0, sizeof(vstats));
+	mutex_lock(&adapter->stats_lock);
+	adapter->rn_ops->ndo_get_stats64(netdev, &vstats.netstats);
+	mutex_unlock(&adapter->stats_lock);
+	memcpy(stats, &vstats.netstats, sizeof(*stats));
+	return stats;
+}
+
 /* hfi_netdev_start_xmit - transmit function */
 static netdev_tx_t hfi_netdev_start_xmit(struct sk_buff *skb,
 					 struct net_device *netdev)
@@ -150,6 +166,7 @@ static int hfi_netdev_close(struct net_device *netdev)
 	.ndo_open = hfi_netdev_open,
 	.ndo_stop = hfi_netdev_close,
 	.ndo_start_xmit = hfi_netdev_start_xmit,
+	.ndo_get_stats64 = hfi_vnic_get_stats64,
 	.ndo_select_queue = hfi_vnic_select_queue,
 	.ndo_set_mac_address = hfi_vnic_set_mac_addr,
 };
@@ -188,6 +205,7 @@ struct hfi_vnic_adapter *hfi_vnic_add_netdev(struct ib_device *ibdev,
 	netdev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 	netdev->hard_header_len += HFI_VNIC_SKB_HEADROOM;
 	mutex_init(&adapter->lock);
+	mutex_init(&adapter->stats_lock);
 
 	SET_NETDEV_DEV(netdev, ibdev->dma_device);
 
@@ -203,6 +221,7 @@ struct hfi_vnic_adapter *hfi_vnic_add_netdev(struct ib_device *ibdev,
 	return adapter;
 netdev_err:
 	mutex_destroy(&adapter->lock);
+	mutex_destroy(&adapter->stats_lock);
 	kfree(adapter);
 adapter_err:
 	ibdev->free_rdma_netdev(netdev);
@@ -219,6 +238,7 @@ void hfi_vnic_rem_netdev(struct hfi_vnic_adapter *adapter)
 	v_info("removing\n");
 	unregister_netdev(netdev);
 	mutex_destroy(&adapter->lock);
+	mutex_destroy(&adapter->stats_lock);
 	kfree(adapter);
 	ibdev->free_rdma_netdev(netdev);
 }
-- 
1.8.3.1
