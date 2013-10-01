From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH next 5/6] be2net: fix adaptive interrupt coalescing
Date: Tue, 1 Oct 2013 16:00:00 +0530
Message-ID: <1380623401-15630-6-git-send-email-sathya.perla@emulex.com>
References: <1380623401-15630-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:8679 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115Ab3JAK0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 06:26:35 -0400
In-Reply-To: <1380623401-15630-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current EQ delay calculation for AIC is based only on RX packet rate.
This fails to be effective when there's only TX and no RX.
This patch inclues:
- Calculating EQ-delay based on both RX and TX pps.
- Modifying EQ-delay of all EQs via one cmd, instead of issuing a separate
  cmd for each EQ.
- A new structure to store interrupt coalescing parameters, in a separate
  cache-line from the EQ-obj.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |   17 +++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   17 ++--
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   15 ++--
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   29 ++++---
 drivers/net/ethernet/emulex/benet/be_main.c    |  110 +++++++++++++++---------
 5 files changed, 115 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 4a540af..e7cbc56 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -88,7 +88,7 @@ static inline char *nic_name(struct pci_dev *pdev)
 #define BE_MIN_MTU		256
 
 #define BE_NUM_VLANS_SUPPORTED	64
-#define BE_MAX_EQD		96u
+#define BE_MAX_EQD		128u
 #define	BE_MAX_TX_FRAG_COUNT	30
 
 #define EVNT_Q_LEN		1024
@@ -200,6 +200,17 @@ struct be_eq_obj {
 	struct be_adapter *adapter;
 } ____cacheline_aligned_in_smp;
 
+struct be_aic_obj {		/* Adaptive interrupt coalescing (AIC) info */
+	bool enable;
+	u32 min_eqd;		/* in usecs */
+	u32 max_eqd;		/* in usecs */
+	u32 prev_eqd;		/* in usecs */
+	u32 et_eqd;		/* configured val when aic is off */
+	ulong jiffies;
+	u64 rx_pkts_prev;	/* Used to calculate RX pps */
+	u64 tx_reqs_prev;	/* Used to calculate TX pps */
+};
+
 struct be_mcc_obj {
 	struct be_queue_info q;
 	struct be_queue_info cq;
@@ -238,15 +249,12 @@ struct be_rx_page_info {
 struct be_rx_stats {
 	u64 rx_bytes;
 	u64 rx_pkts;
-	u64 rx_pkts_prev;
-	ulong rx_jiffies;
 	u32 rx_drops_no_skbs;	/* skb allocation errors */
 	u32 rx_drops_no_frags;	/* HW has no fetched frags */
 	u32 rx_post_fail;	/* page post alloc failures */
 	u32 rx_compl;
 	u32 rx_mcast_pkts;
 	u32 rx_compl_err;	/* completions with err set */
-	u32 rx_pps;		/* pkts per second */
 	struct u64_stats_sync sync;
 };
 
@@ -403,6 +411,7 @@ struct be_adapter {
 	u32 big_page_size;	/* Compounded page size shared by rx wrbs */
 
 	struct be_drv_stats drv_stats;
+	struct be_aic_obj aic_obj[MAX_EVT_QS];
 	u16 vlans_added;
 	u8 vlan_tag[VLAN_N_VID];
 	u8 vlan_prio_bmap;	/* Available Priority BitMap */
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 8610530..b282487 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1716,11 +1716,12 @@ err:
 /* set the EQ delay interval of an EQ to specified value
  * Uses async mcc
  */
-int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd)
+int be_cmd_modify_eqd(struct be_adapter *adapter, struct be_set_eqd *set_eqd,
+		      int num)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_modify_eq_delay *req;
-	int status = 0;
+	int status = 0, i;
 
 	spin_lock_bh(&adapter->mcc_lock);
 
@@ -1734,13 +1735,15 @@ int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd)
 	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_MODIFY_EQ_DELAY, sizeof(*req), wrb, NULL);
 
-	req->num_eq = cpu_to_le32(1);
-	req->delay[0].eq_id = cpu_to_le32(eq_id);
-	req->delay[0].phase = 0;
-	req->delay[0].delay_multiplier = cpu_to_le32(eqd);
+	req->num_eq = cpu_to_le32(num);
+	for (i = 0; i < num; i++) {
+		req->set_eqd[i].eq_id = cpu_to_le32(set_eqd[i].eq_id);
+		req->set_eqd[i].phase = 0;
+		req->set_eqd[i].delay_multiplier =
+				cpu_to_le32(set_eqd[i].delay_multiplier);
+	}
 
 	be_mcc_notify(adapter);
-
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 84f8c52..70c3017 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1055,14 +1055,16 @@ struct be_cmd_resp_get_flow_control {
 } __packed;
 
 /******************** Modify EQ Delay *******************/
+struct be_set_eqd {
+	u32 eq_id;
+	u32 phase;
+	u32 delay_multiplier;
+};
+
 struct be_cmd_req_modify_eq_delay {
 	struct be_cmd_req_hdr hdr;
 	u32 num_eq;
-	struct {
-		u32 eq_id;
-		u32 phase;
-		u32 delay_multiplier;
-	} delay[8];
+	struct be_set_eqd set_eqd[MAX_EVT_QS];
 } __packed;
 
 struct be_cmd_resp_modify_eq_delay {
@@ -1894,8 +1896,7 @@ int lancer_cmd_get_pport_stats(struct be_adapter *adapter,
 			       struct be_dma_mem *nonemb_cmd);
 int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver,
 		      char *fw_on_flash);
-
-int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd);
+int be_cmd_modify_eqd(struct be_adapter *adapter, struct be_set_eqd *, int num);
 int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 		       u32 num, bool untagged, bool promiscuous);
 int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 status);
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index b440a1f..a08783c 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -290,19 +290,19 @@ static int be_get_coalesce(struct net_device *netdev,
 			   struct ethtool_coalesce *et)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_eq_obj *eqo = &adapter->eq_obj[0];
+	struct be_aic_obj *aic = &adapter->aic_obj[0];
 
 
-	et->rx_coalesce_usecs = eqo->cur_eqd;
-	et->rx_coalesce_usecs_high = eqo->max_eqd;
-	et->rx_coalesce_usecs_low = eqo->min_eqd;
+	et->rx_coalesce_usecs = aic->prev_eqd;
+	et->rx_coalesce_usecs_high = aic->max_eqd;
+	et->rx_coalesce_usecs_low = aic->min_eqd;
 
-	et->tx_coalesce_usecs = eqo->cur_eqd;
-	et->tx_coalesce_usecs_high = eqo->max_eqd;
-	et->tx_coalesce_usecs_low = eqo->min_eqd;
+	et->tx_coalesce_usecs = aic->prev_eqd;
+	et->tx_coalesce_usecs_high = aic->max_eqd;
+	et->tx_coalesce_usecs_low = aic->min_eqd;
 
-	et->use_adaptive_rx_coalesce = eqo->enable_aic;
-	et->use_adaptive_tx_coalesce = eqo->enable_aic;
+	et->use_adaptive_rx_coalesce = aic->enable;
+	et->use_adaptive_tx_coalesce = aic->enable;
 
 	return 0;
 }
@@ -314,14 +314,17 @@ static int be_set_coalesce(struct net_device *netdev,
 			   struct ethtool_coalesce *et)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_aic_obj *aic = &adapter->aic_obj[0];
 	struct be_eq_obj *eqo;
 	int i;
 
 	for_all_evt_queues(adapter, eqo, i) {
-		eqo->enable_aic = et->use_adaptive_rx_coalesce;
-		eqo->max_eqd = min(et->rx_coalesce_usecs_high, BE_MAX_EQD);
-		eqo->min_eqd = min(et->rx_coalesce_usecs_low, eqo->max_eqd);
-		eqo->eqd = et->rx_coalesce_usecs;
+		aic->enable = et->use_adaptive_rx_coalesce;
+		aic->max_eqd = min(et->rx_coalesce_usecs_high, BE_MAX_EQD);
+		aic->min_eqd = min(et->rx_coalesce_usecs_low, aic->max_eqd);
+		aic->et_eqd = min(et->rx_coalesce_usecs, aic->max_eqd);
+		aic->et_eqd = max(aic->et_eqd, aic->min_eqd);
+		aic++;
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 961e9f0..6691d75 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1261,53 +1261,79 @@ static int be_set_vf_tx_rate(struct net_device *netdev,
 	return status;
 }
 
-static void be_eqd_update(struct be_adapter *adapter, struct be_eq_obj *eqo)
+static void be_aic_update(struct be_aic_obj *aic, u64 rx_pkts, u64 tx_pkts,
+			  ulong now)
 {
-	struct be_rx_stats *stats = rx_stats(&adapter->rx_obj[eqo->idx]);
-	ulong now = jiffies;
-	ulong delta = now - stats->rx_jiffies;
-	u64 pkts;
-	unsigned int start, eqd;
+	aic->rx_pkts_prev = rx_pkts;
+	aic->tx_reqs_prev = tx_pkts;
+	aic->jiffies = now;
+}
 
-	if (!eqo->enable_aic) {
-		eqd = eqo->eqd;
-		goto modify_eqd;
-	}
+static void be_eqd_update(struct be_adapter *adapter)
+{
+	struct be_set_eqd set_eqd[MAX_EVT_QS];
+	int eqd, i, num = 0, start;
+	struct be_aic_obj *aic;
+	struct be_eq_obj *eqo;
+	struct be_rx_obj *rxo;
+	struct be_tx_obj *txo;
+	u64 rx_pkts, tx_pkts;
+	ulong now;
+	u32 pps, delta;
 
-	if (eqo->idx >= adapter->num_rx_qs)
-		return;
+	for_all_evt_queues(adapter, eqo, i) {
+		aic = &adapter->aic_obj[eqo->idx];
+		if (!aic->enable) {
+			if (aic->jiffies)
+				aic->jiffies = 0;
+			eqd = aic->et_eqd;
+			goto modify_eqd;
+		}
 
-	stats = rx_stats(&adapter->rx_obj[eqo->idx]);
+		rxo = &adapter->rx_obj[eqo->idx];
+		do {
+			start = u64_stats_fetch_begin_bh(&rxo->stats.sync);
+			rx_pkts = rxo->stats.rx_pkts;
+		} while (u64_stats_fetch_retry_bh(&rxo->stats.sync, start));
 
-	/* Wrapped around */
-	if (time_before(now, stats->rx_jiffies)) {
-		stats->rx_jiffies = now;
-		return;
-	}
+		txo = &adapter->tx_obj[eqo->idx];
+		do {
+			start = u64_stats_fetch_begin_bh(&txo->stats.sync);
+			tx_pkts = txo->stats.tx_reqs;
+		} while (u64_stats_fetch_retry_bh(&txo->stats.sync, start));
 
-	/* Update once a second */
-	if (delta < HZ)
-		return;
 
-	do {
-		start = u64_stats_fetch_begin_bh(&stats->sync);
-		pkts = stats->rx_pkts;
-	} while (u64_stats_fetch_retry_bh(&stats->sync, start));
-
-	stats->rx_pps = (unsigned long)(pkts - stats->rx_pkts_prev) / (delta / HZ);
-	stats->rx_pkts_prev = pkts;
-	stats->rx_jiffies = now;
-	eqd = (stats->rx_pps / 110000) << 3;
-	eqd = min(eqd, eqo->max_eqd);
-	eqd = max(eqd, eqo->min_eqd);
-	if (eqd < 10)
-		eqd = 0;
+		/* Skip, if wrapped around or first calculation */
+		now = jiffies;
+		if (!aic->jiffies || time_before(now, aic->jiffies) ||
+		    rx_pkts < aic->rx_pkts_prev ||
+		    tx_pkts < aic->tx_reqs_prev) {
+			be_aic_update(aic, rx_pkts, tx_pkts, now);
+			continue;
+		}
+
+		delta = jiffies_to_msecs(now - aic->jiffies);
+		pps = (((u32)(rx_pkts - aic->rx_pkts_prev) * 1000) / delta) +
+			(((u32)(tx_pkts - aic->tx_reqs_prev) * 1000) / delta);
+		eqd = (pps / 15000) << 2;
 
+		if (eqd < 8)
+			eqd = 0;
+		eqd = min_t(u32, eqd, aic->max_eqd);
+		eqd = max_t(u32, eqd, aic->min_eqd);
+
+		be_aic_update(aic, rx_pkts, tx_pkts, now);
 modify_eqd:
-	if (eqd != eqo->cur_eqd) {
-		be_cmd_modify_eqd(adapter, eqo->q.id, eqd);
-		eqo->cur_eqd = eqd;
+		if (eqd != aic->prev_eqd) {
+			set_eqd[num].delay_multiplier = (eqd * 65)/100;
+			set_eqd[num].eq_id = eqo->q.id;
+			aic->prev_eqd = eqd;
+			num++;
+		}
 	}
+
+	if (num)
+		be_cmd_modify_eqd(adapter, set_eqd, num);
 }
 
 static void be_rx_stats_update(struct be_rx_obj *rxo,
@@ -1924,6 +1950,7 @@ static int be_evt_queues_create(struct be_adapter *adapter)
 {
 	struct be_queue_info *eq;
 	struct be_eq_obj *eqo;
+	struct be_aic_obj *aic;
 	int i, rc;
 
 	adapter->num_evt_qs = min_t(u16, num_irqs(adapter),
@@ -1932,11 +1959,12 @@ static int be_evt_queues_create(struct be_adapter *adapter)
 	for_all_evt_queues(adapter, eqo, i) {
 		netif_napi_add(adapter->netdev, &eqo->napi, be_poll,
 			       BE_NAPI_WEIGHT);
+		aic = &adapter->aic_obj[i];
 		eqo->adapter = adapter;
 		eqo->tx_budget = BE_TX_BUDGET;
 		eqo->idx = i;
-		eqo->max_eqd = BE_MAX_EQD;
-		eqo->enable_aic = true;
+		aic->max_eqd = BE_MAX_EQD;
+		aic->enable = true;
 
 		eq = &eqo->q;
 		rc = be_queue_alloc(adapter, eq, EVNT_Q_LEN,
@@ -4240,7 +4268,6 @@ static void be_worker(struct work_struct *work)
 	struct be_adapter *adapter =
 		container_of(work, struct be_adapter, work.work);
 	struct be_rx_obj *rxo;
-	struct be_eq_obj *eqo;
 	int i;
 
 	/* when interrupts are not yet enabled, just reap any pending
@@ -4271,8 +4298,7 @@ static void be_worker(struct work_struct *work)
 		}
 	}
 
-	for_all_evt_queues(adapter, eqo, i)
-		be_eqd_update(adapter, eqo);
+	be_eqd_update(adapter);
 
 reschedule:
 	adapter->work_counter++;
-- 
1.7.1
