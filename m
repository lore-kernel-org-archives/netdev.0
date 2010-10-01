From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6] be2net: add multiple RX queue support
Date: Fri, 1 Oct 2010 16:11:33 +0530
Message-ID: <20101001104133.GA17206@emulex.com>
Reply-To: Sathya Perla <sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:57149 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756264Ab0JAKmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 06:42:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, incorporated your comment to discover the num of supported MSIx vectors
dynamically; thanks.

This patch adds multiple RX queue support to be2net. There are
upto 4 extra rx-queues per port into which TCP/UDP traffic can be hashed into.
Some of the ethtool stats are now displayed on a per queue basis.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be.h         |   82 +++---
 drivers/net/benet/be_cmds.c    |   40 +++-
 drivers/net/benet/be_cmds.h    |   32 ++-
 drivers/net/benet/be_ethtool.c |  174 ++++++++-----
 drivers/net/benet/be_main.c    |  561 ++++++++++++++++++++++------------------
 5 files changed, 526 insertions(+), 363 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 4faf696..1afabb1 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -78,6 +78,8 @@ static inline char *nic_name(struct pci_dev *pdev)
 #define MCC_Q_LEN		128	/* total size not to exceed 8 pages */
 #define MCC_CQ_LEN		256
 
+#define MAX_RSS_QS		4	/* BE limit is 4 queues/port */
+#define BE_MAX_MSIX_VECTORS	(MAX_RSS_QS + 1 + 1)/* RSS qs + 1 def Rx + Tx */
 #define BE_NAPI_WEIGHT		64
 #define MAX_RX_POST 		BE_NAPI_WEIGHT /* Frags posted at a time */
 #define RX_FRAGS_REFILL_WM	(RX_Q_LEN - MAX_RX_POST)
@@ -157,10 +159,9 @@ struct be_mcc_obj {
 	bool rearm_cq;
 };
 
-struct be_drvr_stats {
+struct be_tx_stats {
 	u32 be_tx_reqs;		/* number of TX requests initiated */
 	u32 be_tx_stops;	/* number of times TX Q was stopped */
-	u32 be_fwd_reqs;	/* number of send reqs through forwarding i/f */
 	u32 be_tx_wrbs;		/* number of tx WRBs used */
 	u32 be_tx_events;	/* number of tx completion events  */
 	u32 be_tx_compl;	/* number of tx completion entries processed */
@@ -169,35 +170,6 @@ struct be_drvr_stats {
 	u64 be_tx_bytes_prev;
 	u64 be_tx_pkts;
 	u32 be_tx_rate;
-
-	u32 cache_barrier[16];
-
-	u32 be_ethrx_post_fail;/* number of ethrx buffer alloc failures */
-	u32 be_rx_polls;	/* number of times NAPI called poll function */
-	u32 be_rx_events;	/* number of ucast rx completion events  */
-	u32 be_rx_compl;	/* number of rx completion entries processed */
-	ulong be_rx_jiffies;
-	u64 be_rx_bytes;
-	u64 be_rx_bytes_prev;
-	u64 be_rx_pkts;
-	u32 be_rx_rate;
-	u32 be_rx_mcast_pkt;
-	/* number of non ether type II frames dropped where
-	 * frame len > length field of Mac Hdr */
-	u32 be_802_3_dropped_frames;
-	/* number of non ether type II frames malformed where
-	 * in frame len < length field of Mac Hdr */
-	u32 be_802_3_malformed_frames;
-	u32 be_rxcp_err;	/* Num rx completion entries w/ err set. */
-	ulong rx_fps_jiffies;	/* jiffies at last FPS calc */
-	u32 be_rx_frags;
-	u32 be_prev_rx_frags;
-	u32 be_rx_fps;		/* Rx frags per second */
-};
-
-struct be_stats_obj {
-	struct be_drvr_stats drvr_stats;
-	struct be_dma_mem cmd;
 };
 
 struct be_tx_obj {
@@ -215,10 +187,34 @@ struct be_rx_page_info {
 	bool last_page_user;
 };
 
+struct be_rx_stats {
+	u32 rx_post_fail;/* number of ethrx buffer alloc failures */
+	u32 rx_polls;	/* number of times NAPI called poll function */
+	u32 rx_events;	/* number of ucast rx completion events  */
+	u32 rx_compl;	/* number of rx completion entries processed */
+	ulong rx_jiffies;
+	u64 rx_bytes;
+	u64 rx_bytes_prev;
+	u64 rx_pkts;
+	u32 rx_rate;
+	u32 rx_mcast_pkts;
+	u32 rxcp_err;	/* Num rx completion entries w/ err set. */
+	ulong rx_fps_jiffies;	/* jiffies at last FPS calc */
+	u32 rx_frags;
+	u32 prev_rx_frags;
+	u32 rx_fps;		/* Rx frags per second */
+};
+
 struct be_rx_obj {
+	struct be_adapter *adapter;
 	struct be_queue_info q;
 	struct be_queue_info cq;
 	struct be_rx_page_info page_info_tbl[RX_Q_LEN];
+	struct be_eq_obj rx_eq;
+	struct be_rx_stats stats;
+	u8 rss_id;
+	bool rx_post_starved;	/* Zero rx frags have been posted to BE */
+	u32 cache_line_barrier[16];
 };
 
 struct be_vf_cfg {
@@ -229,7 +225,6 @@ struct be_vf_cfg {
 	u32 vf_tx_rate;
 };
 
-#define BE_NUM_MSIX_VECTORS		2	/* 1 each for Tx and Rx */
 #define BE_INVALID_PMAC_ID		0xffffffff
 struct be_adapter {
 	struct pci_dev *pdev;
@@ -249,21 +244,21 @@ struct be_adapter {
 	spinlock_t mcc_lock;	/* For serializing mcc cmds to BE card */
 	spinlock_t mcc_cq_lock;
 
-	struct msix_entry msix_entries[BE_NUM_MSIX_VECTORS];
+	struct msix_entry msix_entries[BE_MAX_MSIX_VECTORS];
 	bool msix_enabled;
 	bool isr_registered;
 
 	/* TX Rings */
 	struct be_eq_obj tx_eq;
 	struct be_tx_obj tx_obj;
+	struct be_tx_stats tx_stats;
 
 	u32 cache_line_break[8];
 
 	/* Rx rings */
-	struct be_eq_obj rx_eq;
-	struct be_rx_obj rx_obj;
+	struct be_rx_obj rx_obj[MAX_RSS_QS + 1]; /* one default non-rss Q */
+	u32 num_rx_qs;
 	u32 big_page_size;	/* Compounded page size shared by rx wrbs */
-	bool rx_post_starved;	/* Zero rx frags have been posted to BE */
 
 	struct vlan_group *vlan_grp;
 	u16 vlans_added;
@@ -271,7 +266,7 @@ struct be_adapter {
 	u8 vlan_tag[VLAN_GROUP_ARRAY_LEN];
 	struct be_dma_mem mc_cmd_mem;
 
-	struct be_stats_obj stats;
+	struct be_dma_mem stats_cmd;
 	/* Work queue used to perform periodic tasks like getting statistics */
 	struct delayed_work work;
 
@@ -287,6 +282,7 @@ struct be_adapter {
 	bool promiscuous;
 	bool wol;
 	u32 function_mode;
+	u32 function_caps;
 	u32 rx_fc;		/* Rx flow control */
 	u32 tx_fc;		/* Tx flow control */
 	bool ue_detected;
@@ -313,10 +309,20 @@ struct be_adapter {
 
 extern const struct ethtool_ops be_ethtool_ops;
 
-#define drvr_stats(adapter)		(&adapter->stats.drvr_stats)
+#define tx_stats(adapter)		(&adapter->tx_stats)
+#define rx_stats(rxo)			(&rxo->stats)
 
 #define BE_SET_NETDEV_OPS(netdev, ops)	(netdev->netdev_ops = ops)
 
+#define for_all_rx_queues(adapter, rxo, i)				\
+	for (i = 0, rxo = &adapter->rx_obj[i]; i < adapter->num_rx_qs;	\
+		i++, rxo++)
+
+/* Just skip the first default non-rss queue */
+#define for_all_rss_queues(adapter, rxo, i)				\
+	for (i = 0, rxo = &adapter->rx_obj[i+1]; i < (adapter->num_rx_qs - 1);\
+		i++, rxo++)
+
 #define PAGE_SHIFT_4K		12
 #define PAGE_SIZE_4K		(1 << PAGE_SHIFT_4K)
 
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 0db28b4..bf2dc26 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -71,7 +71,7 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 	if (compl_status == MCC_STATUS_SUCCESS) {
 		if (compl->tag0 == OPCODE_ETH_GET_STATISTICS) {
 			struct be_cmd_resp_get_stats *resp =
-						adapter->stats.cmd.va;
+						adapter->stats_cmd.va;
 			be_dws_le_to_cpu(&resp->hw_stats,
 						sizeof(resp->hw_stats));
 			netdev_stats_update(adapter);
@@ -754,7 +754,7 @@ int be_cmd_txq_create(struct be_adapter *adapter,
 /* Uses mbox */
 int be_cmd_rxq_create(struct be_adapter *adapter,
 		struct be_queue_info *rxq, u16 cq_id, u16 frag_size,
-		u16 max_frame_size, u32 if_id, u32 rss)
+		u16 max_frame_size, u32 if_id, u32 rss, u8 *rss_id)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_eth_rx_create *req;
@@ -785,6 +785,7 @@ int be_cmd_rxq_create(struct be_adapter *adapter,
 		struct be_cmd_resp_eth_rx_create *resp = embedded_payload(wrb);
 		rxq->id = le16_to_cpu(resp->id);
 		rxq->created = true;
+		*rss_id = resp->rss_id;
 	}
 
 	spin_unlock(&adapter->mbox_lock);
@@ -1259,7 +1260,8 @@ err:
 }
 
 /* Uses mbox */
-int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num, u32 *mode)
+int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num,
+		u32 *mode, u32 *caps)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_query_fw_cfg *req;
@@ -1281,6 +1283,7 @@ int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num, u32 *mode)
 		struct be_cmd_resp_query_fw_cfg *resp = embedded_payload(wrb);
 		*port_num = le32_to_cpu(resp->phys_port);
 		*mode = le32_to_cpu(resp->function_mode);
+		*caps = le32_to_cpu(resp->function_caps);
 	}
 
 	spin_unlock(&adapter->mbox_lock);
@@ -1311,6 +1314,37 @@ int be_cmd_reset_function(struct be_adapter *adapter)
 	return status;
 }
 
+int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable, u16 table_size)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_rss_config *req;
+	u32 myhash[10];
+	int status;
+
+	spin_lock(&adapter->mbox_lock);
+
+	wrb = wrb_from_mbox(adapter);
+	req = embedded_payload(wrb);
+
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+		OPCODE_ETH_RSS_CONFIG);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
+		OPCODE_ETH_RSS_CONFIG, sizeof(*req));
+
+	req->if_id = cpu_to_le32(adapter->if_handle);
+	req->enable_rss = cpu_to_le16(RSS_ENABLE_TCP_IPV4 | RSS_ENABLE_IPV4);
+	req->cpu_table_size_log2 = cpu_to_le16(fls(table_size) - 1);
+	memcpy(req->cpu_table, rsstable, table_size);
+	memcpy(req->hash, myhash, sizeof(myhash));
+	be_dws_cpu_to_le(req->hash, sizeof(req->hash));
+
+	status = be_mbox_notify_wait(adapter);
+
+	spin_unlock(&adapter->mbox_lock);
+	return status;
+}
+
 /* Uses sync mcc */
 int be_cmd_set_beacon_state(struct be_adapter *adapter, u8 port_num,
 			u8 bcn, u8 sts, u8 state)
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index ad1e6fa..b7a40b1 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -147,6 +147,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_READ_TRANSRECV_DATA		73
 #define OPCODE_COMMON_GET_PHY_DETAILS			102
 
+#define OPCODE_ETH_RSS_CONFIG				1
 #define OPCODE_ETH_ACPI_CONFIG				2
 #define OPCODE_ETH_PROMISCUOUS				3
 #define OPCODE_ETH_GET_STATISTICS			4
@@ -409,7 +410,7 @@ struct be_cmd_req_eth_rx_create {
 struct be_cmd_resp_eth_rx_create {
 	struct be_cmd_resp_hdr hdr;
 	u16 id;
-	u8 cpu_id;
+	u8 rss_id;
 	u8 rsvd0;
 } __packed;
 
@@ -739,9 +740,10 @@ struct be_cmd_resp_modify_eq_delay {
 } __packed;
 
 /******************** Get FW Config *******************/
+#define BE_FUNCTION_CAPS_RSS			0x2
 struct be_cmd_req_query_fw_cfg {
 	struct be_cmd_req_hdr hdr;
-	u32 rsvd[30];
+	u32 rsvd[31];
 };
 
 struct be_cmd_resp_query_fw_cfg {
@@ -751,6 +753,26 @@ struct be_cmd_resp_query_fw_cfg {
 	u32 phys_port;
 	u32 function_mode;
 	u32 rsvd[26];
+	u32 function_caps;
+};
+
+/******************** RSS Config *******************/
+/* RSS types */
+#define RSS_ENABLE_NONE				0x0
+#define RSS_ENABLE_IPV4				0x1
+#define RSS_ENABLE_TCP_IPV4			0x2
+#define RSS_ENABLE_IPV6				0x4
+#define RSS_ENABLE_TCP_IPV6			0x8
+
+struct be_cmd_req_rss_config {
+	struct be_cmd_req_hdr hdr;
+	u32 if_id;
+	u16 enable_rss;
+	u16 cpu_table_size_log2;
+	u32 hash[10];
+	u8 cpu_table[128];
+	u8 flush;
+	u8 rsvd0[3];
 };
 
 /******************** Port Beacon ***************************/
@@ -937,7 +959,7 @@ extern int be_cmd_txq_create(struct be_adapter *adapter,
 extern int be_cmd_rxq_create(struct be_adapter *adapter,
 			struct be_queue_info *rxq, u16 cq_id,
 			u16 frag_size, u16 max_frame_size, u32 if_id,
-			u32 rss);
+			u32 rss, u8 *rss_id);
 extern int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 			int type);
 extern int be_cmd_link_status_query(struct be_adapter *adapter,
@@ -960,8 +982,10 @@ extern int be_cmd_set_flow_control(struct be_adapter *adapter,
 extern int be_cmd_get_flow_control(struct be_adapter *adapter,
 			u32 *tx_fc, u32 *rx_fc);
 extern int be_cmd_query_fw_cfg(struct be_adapter *adapter,
-			u32 *port_num, u32 *cap);
+			u32 *port_num, u32 *function_mode, u32 *function_caps);
 extern int be_cmd_reset_function(struct be_adapter *adapter);
+extern int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
+			u16 table_size);
 extern int be_process_mcc(struct be_adapter *adapter, int *status);
 extern int be_cmd_set_beacon_state(struct be_adapter *adapter,
 			u8 port_num, u8 beacon, u8 status, u8 state);
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index d920634..0f46366 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -26,14 +26,16 @@ struct be_ethtool_stat {
 	int offset;
 };
 
-enum {NETSTAT, PORTSTAT, MISCSTAT, DRVSTAT, ERXSTAT};
+enum {NETSTAT, PORTSTAT, MISCSTAT, DRVSTAT_TX, DRVSTAT_RX, ERXSTAT};
 #define FIELDINFO(_struct, field) FIELD_SIZEOF(_struct, field), \
 					offsetof(_struct, field)
 #define NETSTAT_INFO(field) 	#field, NETSTAT,\
 					FIELDINFO(struct net_device_stats,\
 						field)
-#define DRVSTAT_INFO(field) 	#field, DRVSTAT,\
-					FIELDINFO(struct be_drvr_stats, field)
+#define DRVSTAT_TX_INFO(field)	#field, DRVSTAT_TX,\
+					FIELDINFO(struct be_tx_stats, field)
+#define DRVSTAT_RX_INFO(field)	#field, DRVSTAT_RX,\
+					FIELDINFO(struct be_rx_stats, field)
 #define MISCSTAT_INFO(field) 	#field, MISCSTAT,\
 					FIELDINFO(struct be_rxf_stats, field)
 #define PORTSTAT_INFO(field) 	#field, PORTSTAT,\
@@ -51,21 +53,12 @@ static const struct be_ethtool_stat et_stats[] = {
 	{NETSTAT_INFO(tx_errors)},
 	{NETSTAT_INFO(rx_dropped)},
 	{NETSTAT_INFO(tx_dropped)},
-	{DRVSTAT_INFO(be_tx_reqs)},
-	{DRVSTAT_INFO(be_tx_stops)},
-	{DRVSTAT_INFO(be_fwd_reqs)},
-	{DRVSTAT_INFO(be_tx_wrbs)},
-	{DRVSTAT_INFO(be_rx_polls)},
-	{DRVSTAT_INFO(be_tx_events)},
-	{DRVSTAT_INFO(be_rx_events)},
-	{DRVSTAT_INFO(be_tx_compl)},
-	{DRVSTAT_INFO(be_rx_compl)},
-	{DRVSTAT_INFO(be_rx_mcast_pkt)},
-	{DRVSTAT_INFO(be_ethrx_post_fail)},
-	{DRVSTAT_INFO(be_802_3_dropped_frames)},
-	{DRVSTAT_INFO(be_802_3_malformed_frames)},
-	{DRVSTAT_INFO(be_tx_rate)},
-	{DRVSTAT_INFO(be_rx_rate)},
+	{DRVSTAT_TX_INFO(be_tx_rate)},
+	{DRVSTAT_TX_INFO(be_tx_reqs)},
+	{DRVSTAT_TX_INFO(be_tx_wrbs)},
+	{DRVSTAT_TX_INFO(be_tx_stops)},
+	{DRVSTAT_TX_INFO(be_tx_events)},
+	{DRVSTAT_TX_INFO(be_tx_compl)},
 	{PORTSTAT_INFO(rx_unicast_frames)},
 	{PORTSTAT_INFO(rx_multicast_frames)},
 	{PORTSTAT_INFO(rx_broadcast_frames)},
@@ -106,11 +99,24 @@ static const struct be_ethtool_stat et_stats[] = {
 	{MISCSTAT_INFO(rx_drops_too_many_frags)},
 	{MISCSTAT_INFO(rx_drops_invalid_ring)},
 	{MISCSTAT_INFO(forwarded_packets)},
-	{MISCSTAT_INFO(rx_drops_mtu)},
-	{ERXSTAT_INFO(rx_drops_no_fragments)},
+	{MISCSTAT_INFO(rx_drops_mtu)}
 };
 #define ETHTOOL_STATS_NUM ARRAY_SIZE(et_stats)
 
+/* Stats related to multi RX queues */
+static const struct be_ethtool_stat et_rx_stats[] = {
+	{DRVSTAT_RX_INFO(rx_bytes)},
+	{DRVSTAT_RX_INFO(rx_pkts)},
+	{DRVSTAT_RX_INFO(rx_rate)},
+	{DRVSTAT_RX_INFO(rx_polls)},
+	{DRVSTAT_RX_INFO(rx_events)},
+	{DRVSTAT_RX_INFO(rx_compl)},
+	{DRVSTAT_RX_INFO(rx_mcast_pkts)},
+	{DRVSTAT_RX_INFO(rx_post_fail)},
+	{ERXSTAT_INFO(rx_drops_no_fragments)}
+};
+#define ETHTOOL_RXSTATS_NUM (ARRAY_SIZE(et_rx_stats))
+
 static const char et_self_tests[][ETH_GSTRING_LEN] = {
 	"MAC Loopback test",
 	"PHY Loopback test",
@@ -143,7 +149,7 @@ static int
 be_get_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_eq_obj *rx_eq = &adapter->rx_eq;
+	struct be_eq_obj *rx_eq = &adapter->rx_obj[0].rx_eq;
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
 
 	coalesce->rx_coalesce_usecs = rx_eq->cur_eqd;
@@ -167,25 +173,49 @@ static int
 be_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_eq_obj *rx_eq = &adapter->rx_eq;
+	struct be_rx_obj *rxo;
+	struct be_eq_obj *rx_eq;
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
 	u32 tx_max, tx_min, tx_cur;
 	u32 rx_max, rx_min, rx_cur;
-	int status = 0;
+	int status = 0, i;
 
 	if (coalesce->use_adaptive_tx_coalesce == 1)
 		return -EINVAL;
 
-	/* if AIC is being turned on now, start with an EQD of 0 */
-	if (rx_eq->enable_aic == 0 &&
-		coalesce->use_adaptive_rx_coalesce == 1) {
-		rx_eq->cur_eqd = 0;
+	for_all_rx_queues(adapter, rxo, i) {
+		rx_eq = &rxo->rx_eq;
+
+		if (!rx_eq->enable_aic && coalesce->use_adaptive_rx_coalesce)
+			rx_eq->cur_eqd = 0;
+		rx_eq->enable_aic = coalesce->use_adaptive_rx_coalesce;
+
+		rx_max = coalesce->rx_coalesce_usecs_high;
+		rx_min = coalesce->rx_coalesce_usecs_low;
+		rx_cur = coalesce->rx_coalesce_usecs;
+
+		if (rx_eq->enable_aic) {
+			if (rx_max > BE_MAX_EQD)
+				rx_max = BE_MAX_EQD;
+			if (rx_min > rx_max)
+				rx_min = rx_max;
+			rx_eq->max_eqd = rx_max;
+			rx_eq->min_eqd = rx_min;
+			if (rx_eq->cur_eqd > rx_max)
+				rx_eq->cur_eqd = rx_max;
+			if (rx_eq->cur_eqd < rx_min)
+				rx_eq->cur_eqd = rx_min;
+		} else {
+			if (rx_cur > BE_MAX_EQD)
+				rx_cur = BE_MAX_EQD;
+			if (rx_eq->cur_eqd != rx_cur) {
+				status = be_cmd_modify_eqd(adapter, rx_eq->q.id,
+						rx_cur);
+				if (!status)
+					rx_eq->cur_eqd = rx_cur;
+			}
+		}
 	}
-	rx_eq->enable_aic = coalesce->use_adaptive_rx_coalesce;
-
-	rx_max = coalesce->rx_coalesce_usecs_high;
-	rx_min = coalesce->rx_coalesce_usecs_low;
-	rx_cur = coalesce->rx_coalesce_usecs;
 
 	tx_max = coalesce->tx_coalesce_usecs_high;
 	tx_min = coalesce->tx_coalesce_usecs_low;
@@ -199,27 +229,6 @@ be_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 			tx_eq->cur_eqd = tx_cur;
 	}
 
-	if (rx_eq->enable_aic) {
-		if (rx_max > BE_MAX_EQD)
-			rx_max = BE_MAX_EQD;
-		if (rx_min > rx_max)
-			rx_min = rx_max;
-		rx_eq->max_eqd = rx_max;
-		rx_eq->min_eqd = rx_min;
-		if (rx_eq->cur_eqd > rx_max)
-			rx_eq->cur_eqd = rx_max;
-		if (rx_eq->cur_eqd < rx_min)
-			rx_eq->cur_eqd = rx_min;
-	} else {
-		if (rx_cur > BE_MAX_EQD)
-			rx_cur = BE_MAX_EQD;
-		if (rx_eq->cur_eqd != rx_cur) {
-			status = be_cmd_modify_eqd(adapter, rx_eq->q.id,
-					rx_cur);
-			if (!status)
-				rx_eq->cur_eqd = rx_cur;
-		}
-	}
 	return 0;
 }
 
@@ -247,32 +256,25 @@ be_get_ethtool_stats(struct net_device *netdev,
 		struct ethtool_stats *stats, uint64_t *data)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_drvr_stats *drvr_stats = &adapter->stats.drvr_stats;
-	struct be_hw_stats *hw_stats = hw_stats_from_cmd(adapter->stats.cmd.va);
-	struct be_rxf_stats *rxf_stats = &hw_stats->rxf;
-	struct be_port_rxf_stats *port_stats =
-			&rxf_stats->port[adapter->port_num];
-	struct net_device_stats *net_stats = &netdev->stats;
+	struct be_hw_stats *hw_stats = hw_stats_from_cmd(adapter->stats_cmd.va);
 	struct be_erx_stats *erx_stats = &hw_stats->erx;
+	struct be_rx_obj *rxo;
 	void *p = NULL;
-	int i;
+	int i, j;
 
 	for (i = 0; i < ETHTOOL_STATS_NUM; i++) {
 		switch (et_stats[i].type) {
 		case NETSTAT:
-			p = net_stats;
+			p = &netdev->stats;
 			break;
-		case DRVSTAT:
-			p = drvr_stats;
+		case DRVSTAT_TX:
+			p = &adapter->tx_stats;
 			break;
 		case PORTSTAT:
-			p = port_stats;
+			p = &hw_stats->rxf.port[adapter->port_num];
 			break;
 		case MISCSTAT:
-			p = rxf_stats;
-			break;
-		case ERXSTAT: /* Currently only one ERX stat is provided */
-			p = (u32 *)erx_stats + adapter->rx_obj.q.id;
+			p = &hw_stats->rxf;
 			break;
 		}
 
@@ -280,19 +282,44 @@ be_get_ethtool_stats(struct net_device *netdev,
 		data[i] = (et_stats[i].size == sizeof(u64)) ?
 				*(u64 *)p: *(u32 *)p;
 	}
+
+	for_all_rx_queues(adapter, rxo, j) {
+		for (i = 0; i < ETHTOOL_RXSTATS_NUM; i++) {
+			switch (et_rx_stats[i].type) {
+			case DRVSTAT_RX:
+				p = (u8 *)&rxo->stats + et_rx_stats[i].offset;
+				break;
+			case ERXSTAT:
+				p = (u32 *)erx_stats + rxo->q.id;
+				break;
+			}
+			data[ETHTOOL_STATS_NUM + j * ETHTOOL_RXSTATS_NUM + i] =
+				(et_rx_stats[i].size == sizeof(u64)) ?
+					*(u64 *)p: *(u32 *)p;
+		}
+	}
 }
 
 static void
 be_get_stat_strings(struct net_device *netdev, uint32_t stringset,
 		uint8_t *data)
 {
-	int i;
+	struct be_adapter *adapter = netdev_priv(netdev);
+	int i, j;
+
 	switch (stringset) {
 	case ETH_SS_STATS:
 		for (i = 0; i < ETHTOOL_STATS_NUM; i++) {
 			memcpy(data, et_stats[i].desc, ETH_GSTRING_LEN);
 			data += ETH_GSTRING_LEN;
 		}
+		for (i = 0; i < adapter->num_rx_qs; i++) {
+			for (j = 0; j < ETHTOOL_RXSTATS_NUM; j++) {
+				sprintf(data, "rxq%d: %s", i,
+					et_rx_stats[j].desc);
+				data += ETH_GSTRING_LEN;
+			}
+		}
 		break;
 	case ETH_SS_TEST:
 		for (i = 0; i < ETHTOOL_TESTS_NUM; i++) {
@@ -305,11 +332,14 @@ be_get_stat_strings(struct net_device *netdev, uint32_t stringset,
 
 static int be_get_sset_count(struct net_device *netdev, int stringset)
 {
+	struct be_adapter *adapter = netdev_priv(netdev);
+
 	switch (stringset) {
 	case ETH_SS_TEST:
 		return ETHTOOL_TESTS_NUM;
 	case ETH_SS_STATS:
-		return ETHTOOL_STATS_NUM;
+		return ETHTOOL_STATS_NUM +
+			adapter->num_rx_qs * ETHTOOL_RXSTATS_NUM;
 	default:
 		return -EINVAL;
 	}
@@ -424,10 +454,10 @@ be_get_ringparam(struct net_device *netdev, struct ethtool_ringparam *ring)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
-	ring->rx_max_pending = adapter->rx_obj.q.len;
+	ring->rx_max_pending = adapter->rx_obj[0].q.len;
 	ring->tx_max_pending = adapter->tx_obj.q.len;
 
-	ring->rx_pending = atomic_read(&adapter->rx_obj.q.used);
+	ring->rx_pending = atomic_read(&adapter->rx_obj[0].q.used);
 	ring->tx_pending = atomic_read(&adapter->tx_obj.q.used);
 }
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 43a3a57..9a1cd28 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -32,6 +32,10 @@ module_param(num_vfs, uint, S_IRUGO);
 MODULE_PARM_DESC(rx_frag_size, "Size of a fragment that holds rcvd data.");
 MODULE_PARM_DESC(num_vfs, "Number of PCI VFs to initialize");
 
+static bool multi_rxq = true;
+module_param(multi_rxq, bool, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(multi_rxq, "Multi Rx Queue support. Enabled by default");
+
 static DEFINE_PCI_DEVICE_TABLE(be_dev_ids) = {
 	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID1) },
 	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID2) },
@@ -111,6 +115,11 @@ static char *ue_status_hi_desc[] = {
 	"Unknown"
 };
 
+static inline bool be_multi_rxq(struct be_adapter *adapter)
+{
+	return (adapter->num_rx_qs > 1);
+}
+
 static void be_queue_free(struct be_adapter *adapter, struct be_queue_info *q)
 {
 	struct be_dma_mem *mem = &q->dma_mem;
@@ -236,18 +245,27 @@ netdev_addr:
 
 void netdev_stats_update(struct be_adapter *adapter)
 {
-	struct be_hw_stats *hw_stats = hw_stats_from_cmd(adapter->stats.cmd.va);
+	struct be_hw_stats *hw_stats = hw_stats_from_cmd(adapter->stats_cmd.va);
 	struct be_rxf_stats *rxf_stats = &hw_stats->rxf;
 	struct be_port_rxf_stats *port_stats =
 			&rxf_stats->port[adapter->port_num];
 	struct net_device_stats *dev_stats = &adapter->netdev->stats;
 	struct be_erx_stats *erx_stats = &hw_stats->erx;
+	struct be_rx_obj *rxo;
+	int i;
 
-	dev_stats->rx_packets = drvr_stats(adapter)->be_rx_pkts;
-	dev_stats->tx_packets = drvr_stats(adapter)->be_tx_pkts;
-	dev_stats->rx_bytes = drvr_stats(adapter)->be_rx_bytes;
-	dev_stats->tx_bytes = drvr_stats(adapter)->be_tx_bytes;
-	dev_stats->multicast = drvr_stats(adapter)->be_rx_mcast_pkt;
+	memset(dev_stats, 0, sizeof(*dev_stats));
+	for_all_rx_queues(adapter, rxo, i) {
+		dev_stats->rx_packets += rx_stats(rxo)->rx_pkts;
+		dev_stats->rx_bytes += rx_stats(rxo)->rx_bytes;
+		dev_stats->multicast += rx_stats(rxo)->rx_mcast_pkts;
+		/*  no space in linux buffers: best possible approximation */
+		dev_stats->rx_dropped +=
+			erx_stats->rx_drops_no_fragments[rxo->q.id];
+	}
+
+	dev_stats->tx_packets = tx_stats(adapter)->be_tx_pkts;
+	dev_stats->tx_bytes = tx_stats(adapter)->be_tx_bytes;
 
 	/* bad pkts received */
 	dev_stats->rx_errors = port_stats->rx_crc_errors +
@@ -264,18 +282,11 @@ void netdev_stats_update(struct be_adapter *adapter)
 		port_stats->rx_ip_checksum_errs +
 		port_stats->rx_udp_checksum_errs;
 
-	/*  no space in linux buffers: best possible approximation */
-	dev_stats->rx_dropped =
-		erx_stats->rx_drops_no_fragments[adapter->rx_obj.q.id];
-
 	/* detailed rx errors */
 	dev_stats->rx_length_errors = port_stats->rx_in_range_errors +
 		port_stats->rx_out_range_errors +
 		port_stats->rx_frame_too_long;
 
-	/* receive ring buffer overflow */
-	dev_stats->rx_over_errors = 0;
-
 	dev_stats->rx_crc_errors = port_stats->rx_crc_errors;
 
 	/* frame alignment errors */
@@ -286,23 +297,6 @@ void netdev_stats_update(struct be_adapter *adapter)
 	dev_stats->rx_fifo_errors = port_stats->rx_fifo_overflow +
 					port_stats->rx_input_fifo_overflow +
 					rxf_stats->rx_drops_no_pbuf;
-	/* receiver missed packetd */
-	dev_stats->rx_missed_errors = 0;
-
-	/*  packet transmit problems */
-	dev_stats->tx_errors = 0;
-
-	/* no space available in linux */
-	dev_stats->tx_dropped = 0;
-
-	dev_stats->collisions = 0;
-
-	/* detailed tx_errors */
-	dev_stats->tx_aborted_errors = 0;
-	dev_stats->tx_carrier_errors = 0;
-	dev_stats->tx_fifo_errors = 0;
-	dev_stats->tx_heartbeat_errors = 0;
-	dev_stats->tx_window_errors = 0;
 }
 
 void be_link_status_update(struct be_adapter *adapter, bool link_up)
@@ -326,10 +320,10 @@ void be_link_status_update(struct be_adapter *adapter, bool link_up)
 }
 
 /* Update the EQ delay n BE based on the RX frags consumed / sec */
-static void be_rx_eqd_update(struct be_adapter *adapter)
+static void be_rx_eqd_update(struct be_adapter *adapter, struct be_rx_obj *rxo)
 {
-	struct be_eq_obj *rx_eq = &adapter->rx_eq;
-	struct be_drvr_stats *stats = &adapter->stats.drvr_stats;
+	struct be_eq_obj *rx_eq = &rxo->rx_eq;
+	struct be_rx_stats *stats = &rxo->stats;
 	ulong now = jiffies;
 	u32 eqd;
 
@@ -346,12 +340,12 @@ static void be_rx_eqd_update(struct be_adapter *adapter)
 	if ((now - stats->rx_fps_jiffies) < HZ)
 		return;
 
-	stats->be_rx_fps = (stats->be_rx_frags - stats->be_prev_rx_frags) /
+	stats->rx_fps = (stats->rx_frags - stats->prev_rx_frags) /
 			((now - stats->rx_fps_jiffies) / HZ);
 
 	stats->rx_fps_jiffies = now;
-	stats->be_prev_rx_frags = stats->be_rx_frags;
-	eqd = stats->be_rx_fps / 110000;
+	stats->prev_rx_frags = stats->rx_frags;
+	eqd = stats->rx_fps / 110000;
 	eqd = eqd << 3;
 	if (eqd > rx_eq->max_eqd)
 		eqd = rx_eq->max_eqd;
@@ -378,7 +372,7 @@ static u32 be_calc_rate(u64 bytes, unsigned long ticks)
 
 static void be_tx_rate_update(struct be_adapter *adapter)
 {
-	struct be_drvr_stats *stats = drvr_stats(adapter);
+	struct be_tx_stats *stats = tx_stats(adapter);
 	ulong now = jiffies;
 
 	/* Wrapped around? */
@@ -400,7 +394,7 @@ static void be_tx_rate_update(struct be_adapter *adapter)
 static void be_tx_stats_update(struct be_adapter *adapter,
 			u32 wrb_cnt, u32 copied, u32 gso_segs, bool stopped)
 {
-	struct be_drvr_stats *stats = drvr_stats(adapter);
+	struct be_tx_stats *stats = tx_stats(adapter);
 	stats->be_tx_reqs++;
 	stats->be_tx_wrbs += wrb_cnt;
 	stats->be_tx_bytes += copied;
@@ -651,14 +645,8 @@ static int be_vid_config(struct be_adapter *adapter, bool vf, u32 vf_num)
 static void be_vlan_register(struct net_device *netdev, struct vlan_group *grp)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_eq_obj *rx_eq = &adapter->rx_eq;
-	struct be_eq_obj *tx_eq = &adapter->tx_eq;
 
-	be_eq_notify(adapter, rx_eq->q.id, false, false, 0);
-	be_eq_notify(adapter, tx_eq->q.id, false, false, 0);
 	adapter->vlan_grp = grp;
-	be_eq_notify(adapter, rx_eq->q.id, true, false, 0);
-	be_eq_notify(adapter, tx_eq->q.id, true, false, 0);
 }
 
 static void be_vlan_add_vid(struct net_device *netdev, u16 vid)
@@ -820,40 +808,38 @@ static int be_set_vf_tx_rate(struct net_device *netdev,
 	return status;
 }
 
-static void be_rx_rate_update(struct be_adapter *adapter)
+static void be_rx_rate_update(struct be_rx_obj *rxo)
 {
-	struct be_drvr_stats *stats = drvr_stats(adapter);
+	struct be_rx_stats *stats = &rxo->stats;
 	ulong now = jiffies;
 
 	/* Wrapped around */
-	if (time_before(now, stats->be_rx_jiffies)) {
-		stats->be_rx_jiffies = now;
+	if (time_before(now, stats->rx_jiffies)) {
+		stats->rx_jiffies = now;
 		return;
 	}
 
 	/* Update the rate once in two seconds */
-	if ((now - stats->be_rx_jiffies) < 2 * HZ)
+	if ((now - stats->rx_jiffies) < 2 * HZ)
 		return;
 
-	stats->be_rx_rate = be_calc_rate(stats->be_rx_bytes
-					  - stats->be_rx_bytes_prev,
-					 now - stats->be_rx_jiffies);
-	stats->be_rx_jiffies = now;
-	stats->be_rx_bytes_prev = stats->be_rx_bytes;
+	stats->rx_rate = be_calc_rate(stats->rx_bytes - stats->rx_bytes_prev,
+				now - stats->rx_jiffies);
+	stats->rx_jiffies = now;
+	stats->rx_bytes_prev = stats->rx_bytes;
 }
 
-static void be_rx_stats_update(struct be_adapter *adapter,
+static void be_rx_stats_update(struct be_rx_obj *rxo,
 		u32 pktsize, u16 numfrags, u8 pkt_type)
 {
-	struct be_drvr_stats *stats = drvr_stats(adapter);
-
-	stats->be_rx_compl++;
-	stats->be_rx_frags += numfrags;
-	stats->be_rx_bytes += pktsize;
-	stats->be_rx_pkts++;
+	struct be_rx_stats *stats = &rxo->stats;
 
+	stats->rx_compl++;
+	stats->rx_frags += numfrags;
+	stats->rx_bytes += pktsize;
+	stats->rx_pkts++;
 	if (pkt_type == BE_MULTICAST_PACKET)
-		stats->be_rx_mcast_pkt++;
+		stats->rx_mcast_pkts++;
 }
 
 static inline bool do_pkt_csum(struct be_eth_rx_compl *rxcp, bool cso)
@@ -873,12 +859,14 @@ static inline bool do_pkt_csum(struct be_eth_rx_compl *rxcp, bool cso)
 }
 
 static struct be_rx_page_info *
-get_rx_page_info(struct be_adapter *adapter, u16 frag_idx)
+get_rx_page_info(struct be_adapter *adapter,
+		struct be_rx_obj *rxo,
+		u16 frag_idx)
 {
 	struct be_rx_page_info *rx_page_info;
-	struct be_queue_info *rxq = &adapter->rx_obj.q;
+	struct be_queue_info *rxq = &rxo->q;
 
-	rx_page_info = &adapter->rx_obj.page_info_tbl[frag_idx];
+	rx_page_info = &rxo->page_info_tbl[frag_idx];
 	BUG_ON(!rx_page_info->page);
 
 	if (rx_page_info->last_page_user) {
@@ -893,9 +881,10 @@ get_rx_page_info(struct be_adapter *adapter, u16 frag_idx)
 
 /* Throwaway the data in the Rx completion */
 static void be_rx_compl_discard(struct be_adapter *adapter,
-			struct be_eth_rx_compl *rxcp)
+		struct be_rx_obj *rxo,
+		struct be_eth_rx_compl *rxcp)
 {
-	struct be_queue_info *rxq = &adapter->rx_obj.q;
+	struct be_queue_info *rxq = &rxo->q;
 	struct be_rx_page_info *page_info;
 	u16 rxq_idx, i, num_rcvd;
 
@@ -903,7 +892,7 @@ static void be_rx_compl_discard(struct be_adapter *adapter,
 	num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags, rxcp);
 
 	for (i = 0; i < num_rcvd; i++) {
-		page_info = get_rx_page_info(adapter, rxq_idx);
+		page_info = get_rx_page_info(adapter, rxo, rxq_idx);
 		put_page(page_info->page);
 		memset(page_info, 0, sizeof(*page_info));
 		index_inc(&rxq_idx, rxq->len);
@@ -914,11 +903,11 @@ static void be_rx_compl_discard(struct be_adapter *adapter,
  * skb_fill_rx_data forms a complete skb for an ether frame
  * indicated by rxcp.
  */
-static void skb_fill_rx_data(struct be_adapter *adapter,
+static void skb_fill_rx_data(struct be_adapter *adapter, struct be_rx_obj *rxo,
 			struct sk_buff *skb, struct be_eth_rx_compl *rxcp,
 			u16 num_rcvd)
 {
-	struct be_queue_info *rxq = &adapter->rx_obj.q;
+	struct be_queue_info *rxq = &rxo->q;
 	struct be_rx_page_info *page_info;
 	u16 rxq_idx, i, j;
 	u32 pktsize, hdr_len, curr_frag_len, size;
@@ -929,7 +918,7 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 	pktsize = AMAP_GET_BITS(struct amap_eth_rx_compl, pktsize, rxcp);
 	pkt_type = AMAP_GET_BITS(struct amap_eth_rx_compl, cast_enc, rxcp);
 
-	page_info = get_rx_page_info(adapter, rxq_idx);
+	page_info = get_rx_page_info(adapter, rxo, rxq_idx);
 
 	start = page_address(page_info->page) + page_info->page_offset;
 	prefetch(start);
@@ -967,7 +956,7 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 	for (i = 1, j = 0; i < num_rcvd; i++) {
 		size -= curr_frag_len;
 		index_inc(&rxq_idx, rxq->len);
-		page_info = get_rx_page_info(adapter, rxq_idx);
+		page_info = get_rx_page_info(adapter, rxo, rxq_idx);
 
 		curr_frag_len = min(size, rx_frag_size);
 
@@ -993,11 +982,12 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 	BUG_ON(j > MAX_SKB_FRAGS);
 
 done:
-	be_rx_stats_update(adapter, pktsize, num_rcvd, pkt_type);
+	be_rx_stats_update(rxo, pktsize, num_rcvd, pkt_type);
 }
 
 /* Process the RX completion indicated by rxcp when GRO is disabled */
 static void be_rx_compl_process(struct be_adapter *adapter,
+			struct be_rx_obj *rxo,
 			struct be_eth_rx_compl *rxcp)
 {
 	struct sk_buff *skb;
@@ -1014,11 +1004,11 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 	if (unlikely(!skb)) {
 		if (net_ratelimit())
 			dev_warn(&adapter->pdev->dev, "skb alloc failed\n");
-		be_rx_compl_discard(adapter, rxcp);
+		be_rx_compl_discard(adapter, rxo, rxcp);
 		return;
 	}
 
-	skb_fill_rx_data(adapter, skb, rxcp, num_rcvd);
+	skb_fill_rx_data(adapter, rxo, skb, rxcp, num_rcvd);
 
 	if (do_pkt_csum(rxcp, adapter->rx_csum))
 		skb_checksum_none_assert(skb);
@@ -1051,12 +1041,13 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 
 /* Process the RX completion indicated by rxcp when GRO is enabled */
 static void be_rx_compl_process_gro(struct be_adapter *adapter,
-			struct be_eth_rx_compl *rxcp)
+		struct be_rx_obj *rxo,
+		struct be_eth_rx_compl *rxcp)
 {
 	struct be_rx_page_info *page_info;
 	struct sk_buff *skb = NULL;
-	struct be_queue_info *rxq = &adapter->rx_obj.q;
-	struct be_eq_obj *eq_obj =  &adapter->rx_eq;
+	struct be_queue_info *rxq = &rxo->q;
+	struct be_eq_obj *eq_obj =  &rxo->rx_eq;
 	u32 num_rcvd, pkt_size, remaining, vlanf, curr_frag_len;
 	u16 i, rxq_idx = 0, vid, j;
 	u8 vtm;
@@ -1080,13 +1071,13 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 
 	skb = napi_get_frags(&eq_obj->napi);
 	if (!skb) {
-		be_rx_compl_discard(adapter, rxcp);
+		be_rx_compl_discard(adapter, rxo, rxcp);
 		return;
 	}
 
 	remaining = pkt_size;
 	for (i = 0, j = -1; i < num_rcvd; i++) {
-		page_info = get_rx_page_info(adapter, rxq_idx);
+		page_info = get_rx_page_info(adapter, rxo, rxq_idx);
 
 		curr_frag_len = min(remaining, rx_frag_size);
 
@@ -1127,12 +1118,12 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 		vlan_gro_frags(&eq_obj->napi, adapter->vlan_grp, vid);
 	}
 
-	be_rx_stats_update(adapter, pkt_size, num_rcvd, pkt_type);
+	be_rx_stats_update(rxo, pkt_size, num_rcvd, pkt_type);
 }
 
-static struct be_eth_rx_compl *be_rx_compl_get(struct be_adapter *adapter)
+static struct be_eth_rx_compl *be_rx_compl_get(struct be_rx_obj *rxo)
 {
-	struct be_eth_rx_compl *rxcp = queue_tail_node(&adapter->rx_obj.cq);
+	struct be_eth_rx_compl *rxcp = queue_tail_node(&rxo->cq);
 
 	if (rxcp->dw[offsetof(struct amap_eth_rx_compl, valid) / 32] == 0)
 		return NULL;
@@ -1140,7 +1131,7 @@ static struct be_eth_rx_compl *be_rx_compl_get(struct be_adapter *adapter)
 	rmb();
 	be_dws_le_to_cpu(rxcp, sizeof(*rxcp));
 
-	queue_tail_inc(&adapter->rx_obj.cq);
+	queue_tail_inc(&rxo->cq);
 	return rxcp;
 }
 
@@ -1166,22 +1157,23 @@ static inline struct page *be_alloc_pages(u32 size)
  * Allocate a page, split it to fragments of size rx_frag_size and post as
  * receive buffers to BE
  */
-static void be_post_rx_frags(struct be_adapter *adapter)
+static void be_post_rx_frags(struct be_rx_obj *rxo)
 {
-	struct be_rx_page_info *page_info_tbl = adapter->rx_obj.page_info_tbl;
+	struct be_adapter *adapter = rxo->adapter;
+	struct be_rx_page_info *page_info_tbl = rxo->page_info_tbl;
 	struct be_rx_page_info *page_info = NULL, *prev_page_info = NULL;
-	struct be_queue_info *rxq = &adapter->rx_obj.q;
+	struct be_queue_info *rxq = &rxo->q;
 	struct page *pagep = NULL;
 	struct be_eth_rx_d *rxd;
 	u64 page_dmaaddr = 0, frag_dmaaddr;
 	u32 posted, page_offset = 0;
 
-	page_info = &page_info_tbl[rxq->head];
+	page_info = &rxo->page_info_tbl[rxq->head];
 	for (posted = 0; posted < MAX_RX_POST && !page_info->page; posted++) {
 		if (!pagep) {
 			pagep = be_alloc_pages(adapter->big_page_size);
 			if (unlikely(!pagep)) {
-				drvr_stats(adapter)->be_ethrx_post_fail++;
+				rxo->stats.rx_post_fail++;
 				break;
 			}
 			page_dmaaddr = pci_map_page(adapter->pdev, pagep, 0,
@@ -1220,7 +1212,7 @@ static void be_post_rx_frags(struct be_adapter *adapter)
 		be_rxq_notify(adapter, rxq->id, posted);
 	} else if (atomic_read(&rxq->used) == 0) {
 		/* Let be_worker replenish when memory is available */
-		adapter->rx_post_starved = true;
+		rxo->rx_post_starved = true;
 	}
 }
 
@@ -1323,17 +1315,17 @@ static void be_eq_clean(struct be_adapter *adapter,
 		be_eq_notify(adapter, eq_obj->q.id, false, true, num);
 }
 
-static void be_rx_q_clean(struct be_adapter *adapter)
+static void be_rx_q_clean(struct be_adapter *adapter, struct be_rx_obj *rxo)
 {
 	struct be_rx_page_info *page_info;
-	struct be_queue_info *rxq = &adapter->rx_obj.q;
-	struct be_queue_info *rx_cq = &adapter->rx_obj.cq;
+	struct be_queue_info *rxq = &rxo->q;
+	struct be_queue_info *rx_cq = &rxo->cq;
 	struct be_eth_rx_compl *rxcp;
 	u16 tail;
 
 	/* First cleanup pending rx completions */
-	while ((rxcp = be_rx_compl_get(adapter)) != NULL) {
-		be_rx_compl_discard(adapter, rxcp);
+	while ((rxcp = be_rx_compl_get(rxo)) != NULL) {
+		be_rx_compl_discard(adapter, rxo, rxcp);
 		be_rx_compl_reset(rxcp);
 		be_cq_notify(adapter, rx_cq->id, true, 1);
 	}
@@ -1341,7 +1333,7 @@ static void be_rx_q_clean(struct be_adapter *adapter)
 	/* Then free posted rx buffer that were not used */
 	tail = (rxq->head + rxq->len - atomic_read(&rxq->used)) % rxq->len;
 	for (; atomic_read(&rxq->used) > 0; index_inc(&tail, rxq->len)) {
-		page_info = get_rx_page_info(adapter, tail);
+		page_info = get_rx_page_info(adapter, rxo, tail);
 		put_page(page_info->page);
 		memset(page_info, 0, sizeof(*page_info));
 	}
@@ -1519,92 +1511,101 @@ tx_eq_free:
 static void be_rx_queues_destroy(struct be_adapter *adapter)
 {
 	struct be_queue_info *q;
-
-	q = &adapter->rx_obj.q;
-	if (q->created) {
-		be_cmd_q_destroy(adapter, q, QTYPE_RXQ);
-
-		/* After the rxq is invalidated, wait for a grace time
-		 * of 1ms for all dma to end and the flush compl to arrive
-		 */
-		mdelay(1);
-		be_rx_q_clean(adapter);
+	struct be_rx_obj *rxo;
+	int i;
+
+	for_all_rx_queues(adapter, rxo, i) {
+		q = &rxo->q;
+		if (q->created) {
+			be_cmd_q_destroy(adapter, q, QTYPE_RXQ);
+			/* After the rxq is invalidated, wait for a grace time
+			 * of 1ms for all dma to end and the flush compl to
+			 * arrive
+			 */
+			mdelay(1);
+			be_rx_q_clean(adapter, rxo);
+		}
+		be_queue_free(adapter, q);
+
+		q = &rxo->cq;
+		if (q->created)
+			be_cmd_q_destroy(adapter, q, QTYPE_CQ);
+		be_queue_free(adapter, q);
+
+		/* Clear any residual events */
+		q = &rxo->rx_eq.q;
+		if (q->created) {
+			be_eq_clean(adapter, &rxo->rx_eq);
+			be_cmd_q_destroy(adapter, q, QTYPE_EQ);
+		}
+		be_queue_free(adapter, q);
 	}
-	be_queue_free(adapter, q);
-
-	q = &adapter->rx_obj.cq;
-	if (q->created)
-		be_cmd_q_destroy(adapter, q, QTYPE_CQ);
-	be_queue_free(adapter, q);
-
-	/* Clear any residual events */
-	be_eq_clean(adapter, &adapter->rx_eq);
-
-	q = &adapter->rx_eq.q;
-	if (q->created)
-		be_cmd_q_destroy(adapter, q, QTYPE_EQ);
-	be_queue_free(adapter, q);
 }
 
 static int be_rx_queues_create(struct be_adapter *adapter)
 {
 	struct be_queue_info *eq, *q, *cq;
-	int rc;
+	struct be_rx_obj *rxo;
+	int rc, i;
 
 	adapter->big_page_size = (1 << get_order(rx_frag_size)) * PAGE_SIZE;
-	adapter->rx_eq.max_eqd = BE_MAX_EQD;
-	adapter->rx_eq.min_eqd = 0;
-	adapter->rx_eq.cur_eqd = 0;
-	adapter->rx_eq.enable_aic = true;
-
-	/* Alloc Rx Event queue */
-	eq = &adapter->rx_eq.q;
-	rc = be_queue_alloc(adapter, eq, EVNT_Q_LEN,
-				sizeof(struct be_eq_entry));
-	if (rc)
-		return rc;
-
-	/* Ask BE to create Rx Event queue */
-	rc = be_cmd_eq_create(adapter, eq, adapter->rx_eq.cur_eqd);
-	if (rc)
-		goto rx_eq_free;
-
-	/* Alloc RX eth compl queue */
-	cq = &adapter->rx_obj.cq;
-	rc = be_queue_alloc(adapter, cq, RX_CQ_LEN,
-			sizeof(struct be_eth_rx_compl));
-	if (rc)
-		goto rx_eq_destroy;
-
-	/* Ask BE to create Rx eth compl queue */
-	rc = be_cmd_cq_create(adapter, cq, eq, false, false, 3);
-	if (rc)
-		goto rx_cq_free;
-
-	/* Alloc RX eth queue */
-	q = &adapter->rx_obj.q;
-	rc = be_queue_alloc(adapter, q, RX_Q_LEN, sizeof(struct be_eth_rx_d));
-	if (rc)
-		goto rx_cq_destroy;
-
-	/* Ask BE to create Rx eth queue */
-	rc = be_cmd_rxq_create(adapter, q, cq->id, rx_frag_size,
-		BE_MAX_JUMBO_FRAME_SIZE, adapter->if_handle, false);
-	if (rc)
-		goto rx_q_free;
+	for_all_rx_queues(adapter, rxo, i) {
+		rxo->adapter = adapter;
+		rxo->rx_eq.max_eqd = BE_MAX_EQD;
+		rxo->rx_eq.enable_aic = true;
+
+		/* EQ */
+		eq = &rxo->rx_eq.q;
+		rc = be_queue_alloc(adapter, eq, EVNT_Q_LEN,
+					sizeof(struct be_eq_entry));
+		if (rc)
+			goto err;
+
+		rc = be_cmd_eq_create(adapter, eq, rxo->rx_eq.cur_eqd);
+		if (rc)
+			goto err;
+
+		/* CQ */
+		cq = &rxo->cq;
+		rc = be_queue_alloc(adapter, cq, RX_CQ_LEN,
+				sizeof(struct be_eth_rx_compl));
+		if (rc)
+			goto err;
+
+		rc = be_cmd_cq_create(adapter, cq, eq, false, false, 3);
+		if (rc)
+			goto err;
+
+		/* Rx Q */
+		q = &rxo->q;
+		rc = be_queue_alloc(adapter, q, RX_Q_LEN,
+				sizeof(struct be_eth_rx_d));
+		if (rc)
+			goto err;
+
+		rc = be_cmd_rxq_create(adapter, q, cq->id, rx_frag_size,
+			BE_MAX_JUMBO_FRAME_SIZE, adapter->if_handle,
+			(i > 0) ? 1 : 0/* rss enable */, &rxo->rss_id);
+		if (rc)
+			goto err;
+	}
+
+	if (be_multi_rxq(adapter)) {
+		u8 rsstable[MAX_RSS_QS];
+
+		for_all_rss_queues(adapter, rxo, i)
+			rsstable[i] = rxo->rss_id;
+
+		rc = be_cmd_rss_config(adapter, rsstable,
+			adapter->num_rx_qs - 1);
+		if (rc)
+			goto err;
+	}
 
 	return 0;
-rx_q_free:
-	be_queue_free(adapter, q);
-rx_cq_destroy:
-	be_cmd_q_destroy(adapter, cq, QTYPE_CQ);
-rx_cq_free:
-	be_queue_free(adapter, cq);
-rx_eq_destroy:
-	be_cmd_q_destroy(adapter, eq, QTYPE_EQ);
-rx_eq_free:
-	be_queue_free(adapter, eq);
-	return rc;
+err:
+	be_rx_queues_destroy(adapter);
+	return -1;
 }
 
 /* There are 8 evt ids per func. Retruns the evt id's bit number */
@@ -1616,24 +1617,31 @@ static inline int be_evt_bit_get(struct be_adapter *adapter, u32 eq_id)
 static irqreturn_t be_intx(int irq, void *dev)
 {
 	struct be_adapter *adapter = dev;
-	int isr;
+	struct be_rx_obj *rxo;
+	int isr, i;
 
 	isr = ioread32(adapter->csr + CEV_ISR0_OFFSET +
 		(adapter->tx_eq.q.id/ 8) * CEV_ISR_SIZE);
 	if (!isr)
 		return IRQ_NONE;
 
-	event_handle(adapter, &adapter->tx_eq);
-	event_handle(adapter, &adapter->rx_eq);
+	if ((1 << be_evt_bit_get(adapter, adapter->tx_eq.q.id) & isr))
+		event_handle(adapter, &adapter->tx_eq);
+
+	for_all_rx_queues(adapter, rxo, i) {
+		if ((1 << be_evt_bit_get(adapter, rxo->rx_eq.q.id) & isr))
+			event_handle(adapter, &rxo->rx_eq);
+	}
 
 	return IRQ_HANDLED;
 }
 
 static irqreturn_t be_msix_rx(int irq, void *dev)
 {
-	struct be_adapter *adapter = dev;
+	struct be_rx_obj *rxo = dev;
+	struct be_adapter *adapter = rxo->adapter;
 
-	event_handle(adapter, &adapter->rx_eq);
+	event_handle(adapter, &rxo->rx_eq);
 
 	return IRQ_HANDLED;
 }
@@ -1647,14 +1655,14 @@ static irqreturn_t be_msix_tx_mcc(int irq, void *dev)
 	return IRQ_HANDLED;
 }
 
-static inline bool do_gro(struct be_adapter *adapter,
+static inline bool do_gro(struct be_adapter *adapter, struct be_rx_obj *rxo,
 			struct be_eth_rx_compl *rxcp)
 {
 	int err = AMAP_GET_BITS(struct amap_eth_rx_compl, err, rxcp);
 	int tcp_frame = AMAP_GET_BITS(struct amap_eth_rx_compl, tcpf, rxcp);
 
 	if (err)
-		drvr_stats(adapter)->be_rxcp_err++;
+		rxo->stats.rxcp_err++;
 
 	return (tcp_frame && !err) ? true : false;
 }
@@ -1662,29 +1670,29 @@ static inline bool do_gro(struct be_adapter *adapter,
 int be_poll_rx(struct napi_struct *napi, int budget)
 {
 	struct be_eq_obj *rx_eq = container_of(napi, struct be_eq_obj, napi);
-	struct be_adapter *adapter =
-		container_of(rx_eq, struct be_adapter, rx_eq);
-	struct be_queue_info *rx_cq = &adapter->rx_obj.cq;
+	struct be_rx_obj *rxo = container_of(rx_eq, struct be_rx_obj, rx_eq);
+	struct be_adapter *adapter = rxo->adapter;
+	struct be_queue_info *rx_cq = &rxo->cq;
 	struct be_eth_rx_compl *rxcp;
 	u32 work_done;
 
-	adapter->stats.drvr_stats.be_rx_polls++;
+	rxo->stats.rx_polls++;
 	for (work_done = 0; work_done < budget; work_done++) {
-		rxcp = be_rx_compl_get(adapter);
+		rxcp = be_rx_compl_get(rxo);
 		if (!rxcp)
 			break;
 
-		if (do_gro(adapter, rxcp))
-			be_rx_compl_process_gro(adapter, rxcp);
+		if (do_gro(adapter, rxo, rxcp))
+			be_rx_compl_process_gro(adapter, rxo, rxcp);
 		else
-			be_rx_compl_process(adapter, rxcp);
+			be_rx_compl_process(adapter, rxo, rxcp);
 
 		be_rx_compl_reset(rxcp);
 	}
 
 	/* Refill the queue */
-	if (atomic_read(&adapter->rx_obj.q.used) < RX_FRAGS_REFILL_WM)
-		be_post_rx_frags(adapter);
+	if (atomic_read(&rxo->q.used) < RX_FRAGS_REFILL_WM)
+		be_post_rx_frags(rxo);
 
 	/* All consumed */
 	if (work_done < budget) {
@@ -1738,8 +1746,8 @@ static int be_poll_tx_mcc(struct napi_struct *napi, int budget)
 			netif_wake_queue(adapter->netdev);
 		}
 
-		drvr_stats(adapter)->be_tx_events++;
-		drvr_stats(adapter)->be_tx_compl += tx_compl;
+		tx_stats(adapter)->be_tx_events++;
+		tx_stats(adapter)->be_tx_compl += tx_compl;
 	}
 
 	return 1;
@@ -1788,20 +1796,24 @@ static void be_worker(struct work_struct *work)
 {
 	struct be_adapter *adapter =
 		container_of(work, struct be_adapter, work.work);
+	struct be_rx_obj *rxo;
+	int i;
 
 	if (!adapter->stats_ioctl_sent)
-		be_cmd_get_stats(adapter, &adapter->stats.cmd);
-
-	/* Set EQ delay */
-	be_rx_eqd_update(adapter);
+		be_cmd_get_stats(adapter, &adapter->stats_cmd);
 
 	be_tx_rate_update(adapter);
-	be_rx_rate_update(adapter);
 
-	if (adapter->rx_post_starved) {
-		adapter->rx_post_starved = false;
-		be_post_rx_frags(adapter);
+	for_all_rx_queues(adapter, rxo, i) {
+		be_rx_rate_update(rxo);
+		be_rx_eqd_update(adapter, rxo);
+
+		if (rxo->rx_post_starved) {
+			rxo->rx_post_starved = false;
+			be_post_rx_frags(rxo);
+		}
 	}
+
 	if (!adapter->ue_detected)
 		be_detect_dump_ue(adapter);
 
@@ -1816,17 +1828,45 @@ static void be_msix_disable(struct be_adapter *adapter)
 	}
 }
 
+static int be_num_rxqs_get(struct be_adapter *adapter)
+{
+	if (multi_rxq && (adapter->function_caps & BE_FUNCTION_CAPS_RSS) &&
+		!adapter->sriov_enabled && !(adapter->function_mode & 0x400)) {
+		return 1 + MAX_RSS_QS; /* one default non-RSS queue */
+	} else {
+		dev_warn(&adapter->pdev->dev,
+			"No support for multiple RX queues\n");
+		return 1;
+	}
+}
+
 static void be_msix_enable(struct be_adapter *adapter)
 {
+#define BE_MIN_MSIX_VECTORS	(1 + 1) /* Rx + Tx */
 	int i, status;
 
-	for (i = 0; i < BE_NUM_MSIX_VECTORS; i++)
+	adapter->num_rx_qs = be_num_rxqs_get(adapter);
+
+	for (i = 0; i < (adapter->num_rx_qs + 1); i++)
 		adapter->msix_entries[i].entry = i;
 
 	status = pci_enable_msix(adapter->pdev, adapter->msix_entries,
-		BE_NUM_MSIX_VECTORS);
-	if (status == 0)
-		adapter->msix_enabled = true;
+			adapter->num_rx_qs + 1);
+	if (status == 0) {
+		goto done;
+	} else if (status >= BE_MIN_MSIX_VECTORS) {
+		if (pci_enable_msix(adapter->pdev, adapter->msix_entries,
+				status) == 0) {
+			adapter->num_rx_qs = status - 1;
+			dev_warn(&adapter->pdev->dev,
+				"Could alloc only %d MSIx vectors. "
+				"Using %d RX Qs\n", status, adapter->num_rx_qs);
+			goto done;
+		}
+	}
+	return;
+done:
+	adapter->msix_enabled = true;
 }
 
 static void be_sriov_enable(struct be_adapter *adapter)
@@ -1860,38 +1900,50 @@ static inline int be_msix_vec_get(struct be_adapter *adapter, u32 eq_id)
 
 static int be_request_irq(struct be_adapter *adapter,
 		struct be_eq_obj *eq_obj,
-		void *handler, char *desc)
+		void *handler, char *desc, void *context)
 {
 	struct net_device *netdev = adapter->netdev;
 	int vec;
 
 	sprintf(eq_obj->desc, "%s-%s", netdev->name, desc);
 	vec = be_msix_vec_get(adapter, eq_obj->q.id);
-	return request_irq(vec, handler, 0, eq_obj->desc, adapter);
+	return request_irq(vec, handler, 0, eq_obj->desc, context);
 }
 
-static void be_free_irq(struct be_adapter *adapter, struct be_eq_obj *eq_obj)
+static void be_free_irq(struct be_adapter *adapter, struct be_eq_obj *eq_obj,
+			void *context)
 {
 	int vec = be_msix_vec_get(adapter, eq_obj->q.id);
-	free_irq(vec, adapter);
+	free_irq(vec, context);
 }
 
 static int be_msix_register(struct be_adapter *adapter)
 {
-	int status;
+	struct be_rx_obj *rxo;
+	int status, i;
+	char qname[10];
 
-	status = be_request_irq(adapter, &adapter->tx_eq, be_msix_tx_mcc, "tx");
+	status = be_request_irq(adapter, &adapter->tx_eq, be_msix_tx_mcc, "tx",
+				adapter);
 	if (status)
 		goto err;
 
-	status = be_request_irq(adapter, &adapter->rx_eq, be_msix_rx, "rx");
-	if (status)
-		goto free_tx_irq;
+	for_all_rx_queues(adapter, rxo, i) {
+		sprintf(qname, "rxq%d", i);
+		status = be_request_irq(adapter, &rxo->rx_eq, be_msix_rx,
+				qname, rxo);
+		if (status)
+			goto err_msix;
+	}
 
 	return 0;
 
-free_tx_irq:
-	be_free_irq(adapter, &adapter->tx_eq);
+err_msix:
+	be_free_irq(adapter, &adapter->tx_eq, adapter);
+
+	for (i--, rxo = &adapter->rx_obj[i]; i >= 0; i--, rxo--)
+		be_free_irq(adapter, &rxo->rx_eq, rxo);
+
 err:
 	dev_warn(&adapter->pdev->dev,
 		"MSIX Request IRQ failed - err %d\n", status);
@@ -1931,6 +1983,8 @@ done:
 static void be_irq_unregister(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
+	struct be_rx_obj *rxo;
+	int i;
 
 	if (!adapter->isr_registered)
 		return;
@@ -1942,8 +1996,11 @@ static void be_irq_unregister(struct be_adapter *adapter)
 	}
 
 	/* MSIx */
-	be_free_irq(adapter, &adapter->tx_eq);
-	be_free_irq(adapter, &adapter->rx_eq);
+	be_free_irq(adapter, &adapter->tx_eq, adapter);
+
+	for_all_rx_queues(adapter, rxo, i)
+		be_free_irq(adapter, &rxo->rx_eq, rxo);
+
 done:
 	adapter->isr_registered = false;
 }
@@ -1951,9 +2008,9 @@ done:
 static int be_close(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_eq_obj *rx_eq = &adapter->rx_eq;
+	struct be_rx_obj *rxo;
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
-	int vec;
+	int vec, i;
 
 	cancel_delayed_work_sync(&adapter->work);
 
@@ -1968,14 +2025,19 @@ static int be_close(struct net_device *netdev)
 	if (adapter->msix_enabled) {
 		vec = be_msix_vec_get(adapter, tx_eq->q.id);
 		synchronize_irq(vec);
-		vec = be_msix_vec_get(adapter, rx_eq->q.id);
-		synchronize_irq(vec);
+
+		for_all_rx_queues(adapter, rxo, i) {
+			vec = be_msix_vec_get(adapter, rxo->rx_eq.q.id);
+			synchronize_irq(vec);
+		}
 	} else {
 		synchronize_irq(netdev->irq);
 	}
 	be_irq_unregister(adapter);
 
-	napi_disable(&rx_eq->napi);
+	for_all_rx_queues(adapter, rxo, i)
+		napi_disable(&rxo->rx_eq.napi);
+
 	napi_disable(&tx_eq->napi);
 
 	/* Wait for all pending tx completions to arrive so that
@@ -1989,17 +2051,17 @@ static int be_close(struct net_device *netdev)
 static int be_open(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_eq_obj *rx_eq = &adapter->rx_eq;
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
+	struct be_rx_obj *rxo;
 	bool link_up;
-	int status;
+	int status, i;
 	u8 mac_speed;
 	u16 link_speed;
 
-	/* First time posting */
-	be_post_rx_frags(adapter);
-
-	napi_enable(&rx_eq->napi);
+	for_all_rx_queues(adapter, rxo, i) {
+		be_post_rx_frags(rxo);
+		napi_enable(&rxo->rx_eq.napi);
+	}
 	napi_enable(&tx_eq->napi);
 
 	be_irq_register(adapter);
@@ -2007,12 +2069,12 @@ static int be_open(struct net_device *netdev)
 	be_intr_set(adapter, true);
 
 	/* The evt queues are created in unarmed state; arm them */
-	be_eq_notify(adapter, rx_eq->q.id, true, false, 0);
+	for_all_rx_queues(adapter, rxo, i) {
+		be_eq_notify(adapter, rxo->rx_eq.q.id, true, false, 0);
+		be_cq_notify(adapter, rxo->cq.id, true, 0);
+	}
 	be_eq_notify(adapter, tx_eq->q.id, true, false, 0);
 
-	/* Rx compl queue may be in unarmed state; rearm it */
-	be_cq_notify(adapter, adapter->rx_obj.cq.id, true, 0);
-
 	/* Now that interrupts are on we can process async mcc */
 	be_async_mcc_enable(adapter);
 
@@ -2088,7 +2150,7 @@ static int be_setup_wol(struct be_adapter *adapter, bool enable)
 static inline int be_vf_eth_addr_config(struct be_adapter *adapter)
 {
 	u32 vf = 0;
-	int status;
+	int status = 0;
 	u8 mac[ETH_ALEN];
 
 	be_vf_eth_addr_generate(adapter, mac);
@@ -2134,6 +2196,11 @@ static int be_setup(struct be_adapter *adapter)
 				BE_IF_FLAGS_PROMISCUOUS |
 				BE_IF_FLAGS_PASS_L3L4_ERRORS;
 		en_flags |= BE_IF_FLAGS_PASS_L3L4_ERRORS;
+
+		if (be_multi_rxq(adapter)) {
+			cap_flags |= BE_IF_FLAGS_RSS;
+			en_flags |= BE_IF_FLAGS_RSS;
+		}
 	}
 
 	status = be_cmd_if_create(adapter, cap_flags, en_flags,
@@ -2455,6 +2522,8 @@ static struct net_device_ops be_netdev_ops = {
 static void be_netdev_init(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_rx_obj *rxo;
+	int i;
 
 	netdev->features |= NETIF_F_SG | NETIF_F_HW_VLAN_RX | NETIF_F_TSO |
 		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER | NETIF_F_HW_CSUM |
@@ -2476,8 +2545,10 @@ static void be_netdev_init(struct net_device *netdev)
 
 	SET_ETHTOOL_OPS(netdev, &be_ethtool_ops);
 
-	netif_napi_add(netdev, &adapter->rx_eq.napi, be_poll_rx,
-		BE_NAPI_WEIGHT);
+	for_all_rx_queues(adapter, rxo, i)
+		netif_napi_add(netdev, &rxo->rx_eq.napi, be_poll_rx,
+				BE_NAPI_WEIGHT);
+
 	netif_napi_add(netdev, &adapter->tx_eq.napi, be_poll_tx_mcc,
 		BE_NAPI_WEIGHT);
 
@@ -2611,8 +2682,7 @@ done:
 
 static void be_stats_cleanup(struct be_adapter *adapter)
 {
-	struct be_stats_obj *stats = &adapter->stats;
-	struct be_dma_mem *cmd = &stats->cmd;
+	struct be_dma_mem *cmd = &adapter->stats_cmd;
 
 	if (cmd->va)
 		pci_free_consistent(adapter->pdev, cmd->size,
@@ -2621,8 +2691,7 @@ static void be_stats_cleanup(struct be_adapter *adapter)
 
 static int be_stats_init(struct be_adapter *adapter)
 {
-	struct be_stats_obj *stats = &adapter->stats;
-	struct be_dma_mem *cmd = &stats->cmd;
+	struct be_dma_mem *cmd = &adapter->stats_cmd;
 
 	cmd->size = sizeof(struct be_cmd_req_get_stats);
 	cmd->va = pci_alloc_consistent(adapter->pdev, cmd->size, &cmd->dma);
@@ -2667,8 +2736,8 @@ static int be_get_config(struct be_adapter *adapter)
 	if (status)
 		return status;
 
-	status = be_cmd_query_fw_cfg(adapter,
-				&adapter->port_num, &adapter->function_mode);
+	status = be_cmd_query_fw_cfg(adapter, &adapter->port_num,
+			&adapter->function_mode, &adapter->function_caps);
 	if (status)
 		return status;
 
@@ -2703,7 +2772,6 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	struct be_adapter *adapter;
 	struct net_device *netdev;
 
-
 	status = pci_enable_device(pdev);
 	if (status)
 		goto do_none;
@@ -2736,11 +2804,8 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	adapter->pdev = pdev;
 	pci_set_drvdata(pdev, adapter);
 	adapter->netdev = netdev;
-	be_netdev_init(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
-	be_msix_enable(adapter);
-
 	status = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (!status) {
 		netdev->features |= NETIF_F_HIGHDMA;
@@ -2784,12 +2849,15 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	if (status)
 		goto stats_clean;
 
+	be_msix_enable(adapter);
+
 	INIT_DELAYED_WORK(&adapter->work, be_worker);
 
 	status = be_setup(adapter);
 	if (status)
-		goto stats_clean;
+		goto msix_disable;
 
+	be_netdev_init(netdev);
 	status = register_netdev(netdev);
 	if (status != 0)
 		goto unsetup;
@@ -2799,12 +2867,13 @@ static int __devinit be_probe(struct pci_dev *pdev,
 
 unsetup:
 	be_clear(adapter);
+msix_disable:
+	be_msix_disable(adapter);
 stats_clean:
 	be_stats_cleanup(adapter);
 ctrl_clean:
 	be_ctrl_cleanup(adapter);
 free_netdev:
-	be_msix_disable(adapter);
 	be_sriov_disable(adapter);
 	free_netdev(adapter->netdev);
 	pci_set_drvdata(pdev, NULL);
-- 
1.6.5.2

