From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: [RFC v2 05/10] IB/hfi-vnic: VNIC statistics support
Date: Wed, 14 Dec 2016 23:59:37 -0800
Message-ID: <1481788782-89964-6-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com, ira.weiny@intel.com,
        Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:39678 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757595AbcLOIA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 03:00:26 -0500
In-Reply-To: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HFI VNIC driver statistics support maintains various counters including
standard netdev counters and the Ethernet manager defined counters.
Add the Ethtool hook to read the counters.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
---
 .../infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c  |  19 +-
 .../sw/intel/hfi_vnic/hfi_vnic_ethtool.c           | 131 +++++++++++
 .../sw/intel/hfi_vnic/hfi_vnic_internal.h          |  84 +++++++
 .../infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c | 260 ++++++++++++++++++++-
 4 files changed, 486 insertions(+), 8 deletions(-)

diff --git a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c
index 093df67..3fdfb7b 100644
--- a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c
+++ b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c
@@ -209,8 +209,10 @@ int hfi_vnic_encap_skb(struct hfi_vnic_adapter *adapter, struct sk_buff *skb)
 	hdr->slid_high = info->vport.encap_slid >> 20;
 
 	dlid = hfi_vnic_get_dlid(adapter, skb, def_port);
-	if (unlikely(!dlid))
+	if (unlikely(!dlid)) {
+		adapter->q_err_cntrs[skb->queue_mapping].tx_dlid_zero++;
 		return -EFAULT;
+	}
 
 	hdr->dlid = dlid;
 	hdr->dlid_high = dlid >> 20;
@@ -233,6 +235,19 @@ int hfi_vnic_encap_skb(struct hfi_vnic_adapter *adapter, struct sk_buff *skb)
 /* hfi_vnic_decap_skb - strip OPA header from the skb (ethernet) packet */
 int hfi_vnic_decap_skb(struct hfi_vnic_rx_queue *rxq, struct sk_buff *skb)
 {
+	struct hfi_vnic_adapter *adapter = rxq->adapter;
+	int max_len = adapter->netdev->mtu + VLAN_ETH_HLEN;
+	int rc = -EFAULT;
+
 	skb_pull(skb, HFI_VNIC_HDR_LEN);
-	return 0;
+
+	/* Validate Packet length */
+	if (skb->len > max_len)
+		adapter->q_err_cntrs[rxq->idx].rx_oversize++;
+	else if (skb->len < ETH_ZLEN)
+		adapter->q_err_cntrs[rxq->idx].rx_runt++;
+	else
+		rc = 0;
+
+	return rc;
 }
diff --git a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_ethtool.c b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_ethtool.c
index 0b4da5e..9289ab2 100644
--- a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_ethtool.c
+++ b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_ethtool.c
@@ -53,9 +53,140 @@
 
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
+				  FIELD_SIZEOF(struct hfi_vnic_adapter, m), \
+				  offsetof(struct hfi_vnic_adapter, m) }
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
+	{"rx_fifo_errors", VNIC_NETDEV_STAT(stats.rx_fifo_errors)},
+	{"rx_missed_errors", VNIC_NETDEV_STAT(stats.rx_missed_errors)},
+	{"tx_carrier_errors", VNIC_NETDEV_STAT(stats.tx_carrier_errors)},
+	{"tx_fifo_errors", VNIC_NETDEV_STAT(stats.tx_fifo_errors)},
+
+	/* SUMMARY counters */
+	{"tx_unicast", VNIC_STAT(sum_cntrs.tx_grp.unicast)},
+	{"tx_mcastbcast", VNIC_STAT(sum_cntrs.tx_grp.mcastbcast)},
+	{"tx_untagged", VNIC_STAT(sum_cntrs.tx_grp.untagged)},
+	{"tx_vlan", VNIC_STAT(sum_cntrs.tx_grp.vlan)},
+
+	{"tx_64_size", VNIC_STAT(sum_cntrs.tx_grp.xx_64_size)},
+	{"tx_65_127", VNIC_STAT(sum_cntrs.tx_grp.xx_65_127)},
+	{"tx_128_255", VNIC_STAT(sum_cntrs.tx_grp.xx_128_255)},
+	{"tx_256_511", VNIC_STAT(sum_cntrs.tx_grp.xx_256_511)},
+	{"tx_512_1023", VNIC_STAT(sum_cntrs.tx_grp.xx_512_1023)},
+	{"tx_1024_1518", VNIC_STAT(sum_cntrs.tx_grp.xx_1024_1518)},
+	{"tx_1519_max", VNIC_STAT(sum_cntrs.tx_grp.xx_1519_max)},
+
+	{"rx_unicast", VNIC_STAT(sum_cntrs.rx_grp.unicast)},
+	{"rx_mcastbcast", VNIC_STAT(sum_cntrs.rx_grp.mcastbcast)},
+	{"rx_untagged", VNIC_STAT(sum_cntrs.rx_grp.untagged)},
+	{"rx_vlan", VNIC_STAT(sum_cntrs.rx_grp.vlan)},
+
+	{"rx_64_size", VNIC_STAT(sum_cntrs.rx_grp.xx_64_size)},
+	{"rx_65_127", VNIC_STAT(sum_cntrs.rx_grp.xx_65_127)},
+	{"rx_128_255", VNIC_STAT(sum_cntrs.rx_grp.xx_128_255)},
+	{"rx_256_511", VNIC_STAT(sum_cntrs.rx_grp.xx_256_511)},
+	{"rx_512_1023", VNIC_STAT(sum_cntrs.rx_grp.xx_512_1023)},
+	{"rx_1024_1518", VNIC_STAT(sum_cntrs.rx_grp.xx_1024_1518)},
+	{"rx_1519_max", VNIC_STAT(sum_cntrs.rx_grp.xx_1519_max)},
+
+	/* ERROR counters */
+	{"tx_smac_filt", VNIC_STAT(err_cntrs.tx_smac_filt)},
+	{"tx_dlid_zero", VNIC_STAT(err_cntrs.tx_dlid_zero)},
+	{"tx_logic", VNIC_STAT(err_cntrs.tx_logic)},
+	{"tx_drop_state", VNIC_STAT(err_cntrs.tx_drop_state)},
+
+	{"rx_bad_veswid", VNIC_STAT(err_cntrs.rx_bad_veswid)},
+	{"rx_runt", VNIC_STAT(err_cntrs.rx_runt)},
+	{"rx_oversize", VNIC_STAT(err_cntrs.rx_oversize)},
+	{"rx_eth_down", VNIC_STAT(err_cntrs.rx_eth_down)},
+	{"rx_drop_state", VNIC_STAT(err_cntrs.rx_drop_state)},
+	{"rx_logic", VNIC_STAT(err_cntrs.rx_logic)},
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
+	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
+	int i;
+	char *p = NULL;
+
+	mutex_lock(&adapter->stats_lock);
+	hfi_vnic_update_stats(netdev);
+	for (i = 0; i < VNIC_STATS_LEN; i++) {
+		switch (vnic_gstrings_stats[i].type) {
+		case NETDEV_STATS:
+			p = (char *)netdev +
+			  vnic_gstrings_stats[i].stat_offset;
+			break;
+		case VNIC_STATS:
+			p = (char *)adapter +
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
diff --git a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_internal.h b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_internal.h
index 63d6db6..af3ff0e 100644
--- a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_internal.h
+++ b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_internal.h
@@ -95,6 +95,64 @@ enum hfi_vnic_flags_t {
 struct hfi_vnic_adapter;
 
 /**
+ * struct __hfi_vnic_summary_counters - HFI summary counters
+ *
+ * Same as __hfi_veswport_summary_counters without bitwise
+ * attribute and reserved fields.
+ */
+struct __hfi_vnic_summary_counters {
+	u64  tx_errors;
+	u64  rx_errors;
+	u64  tx_packets;
+	u64  rx_packets;
+	u64  tx_bytes;
+	u64  rx_bytes;
+
+	/* Group of histogram statistic counters */
+	struct __hfi_vnic_group_scs {
+		u64  unicast;
+		u64  mcastbcast;
+
+		u64  untagged;
+		u64  vlan;
+
+		u64  xx_64_size;
+		u64  xx_65_127;
+		u64  xx_128_255;
+		u64  xx_256_511;
+		u64  xx_512_1023;
+		u64  xx_1024_1518;
+		u64  xx_1519_max;
+	} tx_grp;
+
+	struct __hfi_vnic_group_scs rx_grp;
+
+} __packed;
+
+/**
+ * struct __hfi_vnic_error_counters - HFI error counters
+ *
+ * Same as hfi_veswport_error_counters without bitwise
+ * attribute and reserved fields.
+ */
+struct __hfi_vnic_error_counters {
+	u64  tx_errors;
+	u64  rx_errors;
+
+	u64  tx_smac_filt;
+	u64  tx_dlid_zero;
+	u64  tx_logic;
+	u64  tx_drop_state;
+
+	u64  rx_bad_veswid;
+	u64  rx_runt;
+	u64  rx_oversize;
+	u64  rx_eth_down;
+	u64  rx_drop_state;
+	u64  rx_logic;
+} __packed;
+
+/**
  * struct __hfi_vesw_info - HFI vnic virtual switch info
  *
  * Same as hfi_vesw_info without bitwise attribute.
@@ -204,7 +262,17 @@ struct hfi_vnic_rx_queue {
  * @lock: adapter lock
  * @rxq: receive queue array
  * @info: virtual ethernet switch port information
+ * @stats_lock: statistics lock
  * @flow_tbl: flow to default port redirection table
+ * @q_sum_cntrs: per queue EM summary counters
+ * @q_err_cntrs: per queue EM error counters
+ * @q_rx_logic_errors: per queue rx logic (default) errors
+ * @q_tx_logic_errors: per queue tx logic (default) errors
+ * @q_tx_halt: per queue tx halt counts
+ * @q_tx_restart: per queue tx restart counts
+ * @q_tx_wakeup: per queue tx wakeup counts
+ * @sum_cntrs: Total EM summary counters (from all queues)
+ * @err_cntrs: Total EM error counters (from all queues)
  */
 struct hfi_vnic_adapter {
 	struct net_device             *netdev;
@@ -218,7 +286,22 @@ struct hfi_vnic_adapter {
 
 	struct __hfi_veswport_info info;
 
+	/* Lock used to protect access to vnic counters */
+	struct mutex stats_lock;
+
 	u8 flow_tbl[HFI_VNIC_FLOW_TBL_SIZE];
+
+	struct __hfi_vnic_summary_counters  q_sum_cntrs[HFI_VNIC_MAX_QUEUE];
+	struct __hfi_vnic_error_counters    q_err_cntrs[HFI_VNIC_MAX_QUEUE];
+	u64 q_rx_logic_errors[HFI_VNIC_MAX_QUEUE];
+	u64 q_tx_logic_errors[HFI_VNIC_MAX_QUEUE];
+
+	u64 q_tx_halt[HFI_VNIC_MAX_QUEUE];
+	u64 q_tx_restart[HFI_VNIC_MAX_QUEUE];
+	u64 q_tx_wakeup[HFI_VNIC_MAX_QUEUE];
+
+	struct __hfi_vnic_summary_counters  sum_cntrs;
+	struct __hfi_vnic_error_counters    err_cntrs;
 };
 
 #define v_dbg(format, arg...) \
@@ -248,6 +331,7 @@ struct hfi_vnic_adapter *hfi_vnic_add_netdev(struct hfi_vnic_port *vport,
 int hfi_vnic_encap_skb(struct hfi_vnic_adapter *adapter, struct sk_buff *skb);
 int hfi_vnic_decap_skb(struct hfi_vnic_rx_queue *rxq, struct sk_buff *skb);
 u8 hfi_vnic_calc_entropy(struct hfi_vnic_adapter *adapter, struct sk_buff *skb);
+void hfi_vnic_update_stats(struct net_device *netdev);
 void hfi_vnic_set_ethtool_ops(struct net_device *netdev);
 
 #endif /* _HFI_VNIC_INTERNAL_H */
diff --git a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c
index 6360d37..1626e44 100644
--- a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c
+++ b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c
@@ -58,6 +58,235 @@
 
 #define HFI_VNIC_MIN_ETH_MTU (ETH_ZLEN - ETH_HLEN)
 
+#define SUM_GRP_COUNTERS(adpt, summary, x_grp) do {                     \
+		u64 *src64, *dst64;                                     \
+		for (src64 = &summary->x_grp.unicast,                   \
+			dst64 = &adpt->sum_cntrs.x_grp.unicast;         \
+			dst64 <= &adpt->sum_cntrs.x_grp.xx_1519_max;) { \
+			*dst64++ += *src64++;                           \
+		}                                                       \
+	} while (0)
+
+/* hfi_vnic_update_stats - update statistics */
+void hfi_vnic_update_stats(struct net_device *netdev)
+{
+	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
+	struct hfi_vnic_port *vport = adapter->vport;
+	struct hfi_vnic_stats h_stats = { 0 };
+	u64 tx_logic_errors = 0;
+	u64 rx_logic_errors = 0;
+	u8 i;
+
+	/* first clear the total counters */
+	memset(&adapter->sum_cntrs, 0, sizeof(adapter->sum_cntrs));
+	memset(&adapter->err_cntrs, 0, sizeof(adapter->err_cntrs));
+
+	/* add tx counters on different queues */
+	for (i = 0; i < vport->hfi_info.num_tx_q; i++) {
+		struct hfi_vnic_stats *hfi_stats = &vport->hfi_stats[i];
+		struct __hfi_vnic_summary_counters *sum_cntrs =
+						&adapter->q_sum_cntrs[i];
+		struct __hfi_vnic_error_counters *err_cntrs =
+						&adapter->q_err_cntrs[i];
+
+		h_stats.tx_fifo_errors += hfi_stats->tx_fifo_errors;
+		h_stats.tx_carrier_errors += hfi_stats->tx_carrier_errors;
+		h_stats.tx_logic_errors += hfi_stats->tx_logic_errors;
+
+		SUM_GRP_COUNTERS(adapter, sum_cntrs, tx_grp);
+		adapter->sum_cntrs.tx_packets += sum_cntrs->tx_packets;
+		adapter->sum_cntrs.tx_bytes += sum_cntrs->tx_bytes;
+
+		adapter->err_cntrs.tx_smac_filt += err_cntrs->tx_smac_filt;
+		adapter->err_cntrs.tx_dlid_zero += err_cntrs->tx_dlid_zero;
+		adapter->err_cntrs.tx_drop_state += err_cntrs->tx_drop_state;
+
+		tx_logic_errors += adapter->q_tx_logic_errors[i];
+	}
+
+	/* add rx counters on different queues */
+	for (i = 0; i < vport->hfi_info.num_rx_q; i++) {
+		struct hfi_vnic_stats *hfi_stats = &vport->hfi_stats[i];
+		struct __hfi_vnic_summary_counters *sum_cntrs =
+						&adapter->q_sum_cntrs[i];
+		struct __hfi_vnic_error_counters *err_cntrs =
+						&adapter->q_err_cntrs[i];
+
+		h_stats.rx_fifo_errors += hfi_stats->rx_fifo_errors;
+		h_stats.rx_missed_errors += hfi_stats->rx_missed_errors;
+		h_stats.rx_bad_veswid += hfi_stats->rx_bad_veswid;
+		h_stats.rx_logic_errors += hfi_stats->rx_logic_errors;
+
+		SUM_GRP_COUNTERS(adapter, sum_cntrs, rx_grp);
+		adapter->sum_cntrs.rx_packets += sum_cntrs->rx_packets;
+		adapter->sum_cntrs.rx_bytes += sum_cntrs->rx_bytes;
+
+		adapter->err_cntrs.rx_drop_state += err_cntrs->rx_drop_state;
+		adapter->err_cntrs.rx_runt += err_cntrs->rx_runt;
+		adapter->err_cntrs.rx_oversize += err_cntrs->rx_oversize;
+
+		rx_logic_errors += adapter->q_rx_logic_errors[i];
+	}
+
+	/* update hfi errors */
+	netdev->stats.rx_fifo_errors = h_stats.rx_fifo_errors;
+	netdev->stats.tx_fifo_errors = h_stats.tx_fifo_errors;
+	netdev->stats.rx_missed_errors = h_stats.rx_missed_errors;
+	netdev->stats.tx_carrier_errors = h_stats.tx_carrier_errors;
+	adapter->err_cntrs.rx_bad_veswid = h_stats.rx_bad_veswid;
+
+	/* update tx counters */
+	netdev->stats.tx_packets = adapter->sum_cntrs.tx_packets;
+	netdev->stats.tx_bytes = adapter->sum_cntrs.tx_bytes;
+
+	adapter->err_cntrs.tx_logic = netdev->stats.tx_carrier_errors +
+				      netdev->stats.tx_fifo_errors +
+				      h_stats.tx_logic_errors +
+				      tx_logic_errors;
+
+	netdev->stats.tx_errors = adapter->err_cntrs.tx_smac_filt +
+				  adapter->err_cntrs.tx_dlid_zero +
+				  adapter->err_cntrs.tx_drop_state +
+				  adapter->err_cntrs.tx_logic;
+
+	netdev->stats.tx_dropped = netdev->stats.tx_errors;
+	adapter->sum_cntrs.tx_errors = netdev->stats.tx_errors;
+	adapter->err_cntrs.tx_errors = netdev->stats.tx_errors;
+
+	/* update rx counters */
+	netdev->stats.rx_packets = adapter->sum_cntrs.rx_packets;
+	netdev->stats.rx_bytes = adapter->sum_cntrs.rx_bytes;
+	netdev->stats.multicast = adapter->sum_cntrs.rx_grp.mcastbcast;
+	netdev->stats.rx_over_errors = adapter->err_cntrs.rx_oversize;
+	netdev->stats.rx_length_errors = adapter->err_cntrs.rx_oversize +
+					 adapter->err_cntrs.rx_runt;
+
+	adapter->err_cntrs.rx_logic = netdev->stats.rx_missed_errors +
+				      netdev->stats.rx_fifo_errors +
+				      h_stats.rx_logic_errors +
+				      rx_logic_errors;
+
+	netdev->stats.rx_errors = adapter->err_cntrs.rx_bad_veswid +
+				  adapter->err_cntrs.rx_runt +
+				  adapter->err_cntrs.rx_oversize +
+				  adapter->err_cntrs.rx_eth_down +
+				  adapter->err_cntrs.rx_drop_state +
+				  adapter->err_cntrs.rx_logic;
+
+	netdev->stats.rx_dropped = netdev->stats.rx_errors;
+	adapter->sum_cntrs.rx_errors = netdev->stats.rx_errors;
+	adapter->err_cntrs.rx_errors = netdev->stats.rx_errors;
+}
+
+/* update_len_counters - update pkt's len histogram counters */
+static inline void update_len_counters(struct __hfi_vnic_group_scs *grp,
+				       int len)
+{
+	/* account for 4 byte FCS */
+	if (len >= 1515)
+		grp->xx_1519_max++;
+	else if (len >= 1020)
+		grp->xx_1024_1518++;
+	else if (len >= 508)
+		grp->xx_512_1023++;
+	else if (len >= 252)
+		grp->xx_256_511++;
+	else if (len >= 124)
+		grp->xx_128_255++;
+	else if (len >= 61)
+		grp->xx_65_127++;
+	else
+		grp->xx_64_size++;
+}
+
+/* hfi_vnic_update_tx_counters - update transmit counters */
+static void hfi_vnic_update_tx_counters(struct net_device *netdev, u8 q_idx,
+					struct sk_buff *skb, int err)
+{
+	struct ethhdr *mac_hdr = (struct ethhdr *)skb_mac_header(skb);
+	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
+	struct __hfi_vnic_group_scs *grp_cntrs =
+			&adapter->q_sum_cntrs[q_idx].tx_grp;
+	u16 vlan_tci;
+
+	adapter->q_sum_cntrs[q_idx].tx_packets++;
+	adapter->q_sum_cntrs[q_idx].tx_bytes += skb->len + ETH_FCS_LEN;
+
+	update_len_counters(grp_cntrs, skb->len);
+
+	/* rest of the counts are for good packets only */
+	if (err)
+		return;
+
+	if (is_multicast_ether_addr(mac_hdr->h_dest))
+		grp_cntrs->mcastbcast++;
+	else
+		grp_cntrs->unicast++;
+
+	if (!__vlan_get_tag(skb, &vlan_tci))
+		grp_cntrs->vlan++;
+	else
+		grp_cntrs->untagged++;
+}
+
+/* hfi_vnic_update_rx_counters - update receive counters */
+static void hfi_vnic_update_rx_counters(struct net_device *netdev, u8 q_idx,
+					struct sk_buff *skb, int err)
+{
+	struct ethhdr *mac_hdr = (struct ethhdr *)skb->data;
+	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
+	struct __hfi_vnic_group_scs *grp_cntrs =
+			&adapter->q_sum_cntrs[q_idx].rx_grp;
+	u16 vlan_tci;
+
+	adapter->q_sum_cntrs[q_idx].rx_packets++;
+	adapter->q_sum_cntrs[q_idx].rx_bytes += skb->len + ETH_FCS_LEN;
+
+	update_len_counters(grp_cntrs, skb->len);
+
+	/* rest of the counts are for good packets only */
+	if (err)
+		return;
+
+	if (is_multicast_ether_addr(mac_hdr->h_dest))
+		grp_cntrs->mcastbcast++;
+	else
+		grp_cntrs->unicast++;
+
+	if (!__vlan_get_tag(skb, &vlan_tci))
+		grp_cntrs->vlan++;
+	else
+		grp_cntrs->untagged++;
+}
+
+static struct rtnl_link_stats64 *
+hfi_vnic_get_stats64(struct net_device *netdev,
+		     struct rtnl_link_stats64 *stats)
+{
+	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
+
+	mutex_lock(&adapter->stats_lock);
+	hfi_vnic_update_stats(netdev);
+
+	stats->rx_packets = netdev->stats.rx_packets;
+	stats->tx_packets = netdev->stats.tx_packets;
+	stats->rx_bytes = netdev->stats.rx_bytes;
+	stats->tx_bytes = netdev->stats.tx_bytes;
+	stats->rx_errors = netdev->stats.rx_errors;
+	stats->tx_errors = netdev->stats.tx_errors;
+	stats->rx_dropped = netdev->stats.rx_dropped;
+	stats->tx_dropped = netdev->stats.tx_dropped;
+	stats->multicast = netdev->stats.multicast;
+	stats->rx_length_errors = netdev->stats.rx_length_errors;
+	stats->rx_over_errors = netdev->stats.rx_over_errors;
+	stats->rx_fifo_errors = netdev->stats.rx_fifo_errors;
+	stats->rx_missed_errors = netdev->stats.rx_missed_errors;
+	stats->tx_carrier_errors = netdev->stats.tx_carrier_errors;
+	stats->tx_fifo_errors = netdev->stats.tx_fifo_errors;
+	mutex_unlock(&adapter->stats_lock);
+	return stats;
+}
+
 /* hfi_vnic_maybe_stop_tx - stop tx queue if required */
 static void hfi_vnic_maybe_stop_tx(struct hfi_vnic_adapter *adapter, u8 q_idx)
 {
@@ -67,6 +296,7 @@ static void hfi_vnic_maybe_stop_tx(struct hfi_vnic_adapter *adapter, u8 q_idx)
 	if (!vport->ops->get_write_avail(vport, q_idx))
 		return;
 
+	adapter->q_tx_restart[q_idx]++;
 	netif_start_subqueue(vport->netdev, q_idx);
 }
 
@@ -82,12 +312,15 @@ static netdev_tx_t hfi_netdev_start_xmit(struct sk_buff *skb,
 
 	v_dbg("xmit: queue %d skb len %d\n", q_idx, skb->len);
 	if (unlikely(adapter->info.vport.oper_state !=
-		     HFI_VNIC_STATE_FORWARDING))
+		     HFI_VNIC_STATE_FORWARDING)) {
+		adapter->q_err_cntrs[q_idx].tx_drop_state++;
 		goto tx_finish;
+	}
 
 	/* pad to ensure mininum ethernet packet length */
 	if (unlikely(skb->len < ETH_ZLEN)) {
 		if (skb_padto(skb, ETH_ZLEN)) {
+			adapter->q_tx_logic_errors[q_idx]++;
 			skip_skb_free = true;
 			goto tx_finish;
 		}
@@ -101,16 +334,19 @@ static netdev_tx_t hfi_netdev_start_xmit(struct sk_buff *skb,
 	/* Get reference to skb as hfi driver might release it */
 	skb_get(skb);
 	rc = vport->ops->put_skb(vport, q_idx, skb);
-	/* remove the header */
+	/* remove the header before updating tx counters */
 	skb_pull(skb, HFI_VNIC_HDR_LEN);
 
 tx_finish:
 	if (unlikely(rc == -EBUSY)) {
 		hfi_vnic_maybe_stop_tx(adapter, q_idx);
+		adapter->q_tx_halt[q_idx]++;
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_BUSY;
 	}
 
+	/* update tx counters */
+	hfi_vnic_update_tx_counters(netdev, q_idx, skb, rc);
 	if (!skip_skb_free)
 		dev_kfree_skb_any(skb);
 	return NETDEV_TX_OK;
@@ -123,6 +359,7 @@ static void vnic_handle_rx(struct hfi_vnic_rx_queue *rxq,
 	struct hfi_vnic_adapter *adapter = rxq->adapter;
 	struct hfi_vnic_port *vport = adapter->vport;
 	struct sk_buff *skb;
+	int rc;
 
 	while (1) {
 		if (*work_done >= work_to_do)
@@ -132,7 +369,11 @@ static void vnic_handle_rx(struct hfi_vnic_rx_queue *rxq,
 		if (!skb)
 			break;
 
-		if (hfi_vnic_decap_skb(rxq, skb)) {
+		rc = hfi_vnic_decap_skb(rxq, skb);
+
+		/* update rx counters */
+		hfi_vnic_update_rx_counters(adapter->netdev, rxq->idx, skb, rc);
+		if (rc) {
 			dev_kfree_skb_any(skb);
 			continue;
 		}
@@ -178,8 +419,10 @@ static void vnic_event_cb(struct hfi_vnic_port *vport, u8 evt)
 	if (evt < vport->hfi_info.num_rx_q) {
 		q_idx = evt;
 		if (unlikely(adapter->info.vport.oper_state !=
-			     HFI_VNIC_STATE_FORWARDING))
+			     HFI_VNIC_STATE_FORWARDING)) {
+			adapter->q_err_cntrs[q_idx].rx_drop_state++;
 			return;
+		}
 
 		rxq = &adapter->rxq[q_idx];
 		if (napi_schedule_prep(&rxq->napi)) {
@@ -193,9 +436,10 @@ static void vnic_event_cb(struct hfi_vnic_port *vport, u8 evt)
 	    (evt < (HFI_VNIC_EVT_TX0 + vport->hfi_info.num_tx_q))) {
 		q_idx = evt - HFI_VNIC_EVT_TX0;
 
-		if (__netif_subqueue_stopped(vport->netdev, q_idx))
+		if (__netif_subqueue_stopped(vport->netdev, q_idx)) {
 			netif_wake_subqueue(vport->netdev, q_idx);
-
+			adapter->q_tx_wakeup[q_idx]++;
+		}
 		return;
 	}
 	v_err("Invalid event\n");
@@ -340,6 +584,7 @@ static int hfi_netdev_close(struct net_device *netdev)
 	.ndo_stop = hfi_netdev_close,
 	.ndo_start_xmit = hfi_netdev_start_xmit,
 	.ndo_change_mtu = hfi_netdev_change_mtu,
+	.ndo_get_stats64 = hfi_vnic_get_stats64,
 	.ndo_select_queue = hfi_vnic_select_queue,
 	.ndo_set_mac_address = hfi_vnic_set_mac_addr,
 };
@@ -371,6 +616,7 @@ struct hfi_vnic_adapter *hfi_vnic_add_netdev(struct hfi_vnic_port *vport,
 	netdev->netdev_ops = &hfi_netdev_ops;
 	netdev->hard_header_len += HFI_VNIC_SKB_HEADROOM;
 	mutex_init(&adapter->lock);
+	mutex_init(&adapter->stats_lock);
 	strcpy(netdev->name, "veth%d");
 
 	SET_NETDEV_DEV(netdev, parent);
@@ -392,6 +638,7 @@ struct hfi_vnic_adapter *hfi_vnic_add_netdev(struct hfi_vnic_port *vport,
 	return adapter;
 netdev_err:
 	mutex_destroy(&adapter->lock);
+	mutex_destroy(&adapter->stats_lock);
 	free_netdev(netdev);
 
 	return ERR_PTR(rc);
@@ -405,5 +652,6 @@ void hfi_vnic_rem_netdev(struct hfi_vnic_port *vport)
 	v_info("removing\n");
 	unregister_netdev(vport->netdev);
 	mutex_destroy(&adapter->lock);
+	mutex_destroy(&adapter->stats_lock);
 	free_netdev(vport->netdev);
 }
-- 
1.8.3.1
