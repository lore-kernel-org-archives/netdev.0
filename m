From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/18] i40e/i40evf: Add capability to gather VEB per TC stats
Date: Sat, 28 Feb 2015 03:29:40 -0800
Message-ID: <1425122989-354-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:52432 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341AbbB1L36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:29:58 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

This patch adds capability to update per VEB per TC statistics and dump
it via debugfs. It also adds a structure to hold VEB per TC statistics.
The fields can be filled by reading the GLVEBTC_* counters.

Change-ID: I45cca003d8b12d96951a67f50d5dd7a789e09218
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 24 ++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 28 +++++++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_type.h    |  8 ++++++++
 drivers/net/ethernet/intel/i40evf/i40e_type.h  |  8 ++++++++
 5 files changed, 69 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index e4e963a..9af4456 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -426,6 +426,8 @@ struct i40e_veb {
 	bool stat_offsets_loaded;
 	struct i40e_eth_stats stats;
 	struct i40e_eth_stats stats_offsets;
+	struct i40e_veb_tc_stats tc_stats;
+	struct i40e_veb_tc_stats tc_stats_offsets;
 };
 
 /* struct that defines a VSI, associated with a dev */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 30cf0be..485a43d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -901,6 +901,29 @@ static void i40e_dbg_dump_eth_stats(struct i40e_pf *pf,
 }
 
 /**
+ * i40e_dbg_dump_veb_stats - dump extra veb stats
+ * @pf: the i40e_pf created in command write
+ * @tc_stats: the veb TC stats structure to be dumped
+ **/
+static void i40e_dbg_dump_veb_stats(struct i40e_pf *pf,
+				    struct i40e_veb_tc_stats *tc_stats)
+{
+	int i;
+
+	dev_info(&pf->pdev->dev, "  vebstats:\n");
+	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
+		dev_info(&pf->pdev->dev,
+			 "    tc_rx_packets[%d] = \t%lld \ttc_rx_bytes[%d] = \t%lld\n",
+			 i, tc_stats->tc_rx_packets[i],
+			 i, tc_stats->tc_rx_bytes[i]);
+		dev_info(&pf->pdev->dev,
+			 "    tc_tx_packets[%d] = \t%lld \ttc_tx_bytes[%d] = \t%lld\n",
+			 i, tc_stats->tc_tx_packets[i],
+			 i, tc_stats->tc_tx_bytes[i]);
+	}
+}
+
+/**
  * i40e_dbg_dump_veb_seid - handles dump stats of a single given veb
  * @pf: the i40e_pf created in command write
  * @seid: the seid the user put in
@@ -926,6 +949,7 @@ static void i40e_dbg_dump_veb_seid(struct i40e_pf *pf, int seid)
 		 veb->uplink_seid,
 		 veb->bridge_mode == BRIDGE_MODE_VEPA ? "VEPA" : "VEB");
 	i40e_dbg_dump_eth_stats(pf, &veb->stats);
+	i40e_dbg_dump_veb_stats(pf, &veb->tc_stats);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 849fec7..7509048 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -604,11 +604,15 @@ static void i40e_update_veb_stats(struct i40e_veb *veb)
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_eth_stats *oes;
 	struct i40e_eth_stats *es;     /* device's eth stats */
-	int idx = 0;
+	struct i40e_veb_tc_stats *veb_oes;
+	struct i40e_veb_tc_stats *veb_es;
+	int i, idx = 0;
 
 	idx = veb->stats_idx;
 	es = &veb->stats;
 	oes = &veb->stats_offsets;
+	veb_es = &veb->tc_stats;
+	veb_oes = &veb->tc_stats_offsets;
 
 	/* Gather up the stats that the hw collects */
 	i40e_stat_update32(hw, I40E_GLSW_TDPC(idx),
@@ -644,6 +648,28 @@ static void i40e_update_veb_stats(struct i40e_veb *veb)
 	i40e_stat_update48(hw, I40E_GLSW_BPTCH(idx), I40E_GLSW_BPTCL(idx),
 			   veb->stat_offsets_loaded,
 			   &oes->tx_broadcast, &es->tx_broadcast);
+	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
+		i40e_stat_update48(hw, I40E_GLVEBTC_RPCH(i, idx),
+				   I40E_GLVEBTC_RPCL(i, idx),
+				   veb->stat_offsets_loaded,
+				   &veb_oes->tc_rx_packets[i],
+				   &veb_es->tc_rx_packets[i]);
+		i40e_stat_update48(hw, I40E_GLVEBTC_RBCH(i, idx),
+				   I40E_GLVEBTC_RBCL(i, idx),
+				   veb->stat_offsets_loaded,
+				   &veb_oes->tc_rx_bytes[i],
+				   &veb_es->tc_rx_bytes[i]);
+		i40e_stat_update48(hw, I40E_GLVEBTC_TPCH(i, idx),
+				   I40E_GLVEBTC_TPCL(i, idx),
+				   veb->stat_offsets_loaded,
+				   &veb_oes->tc_tx_packets[i],
+				   &veb_es->tc_tx_packets[i]);
+		i40e_stat_update48(hw, I40E_GLVEBTC_TBCH(i, idx),
+				   I40E_GLVEBTC_TBCL(i, idx),
+				   veb->stat_offsets_loaded,
+				   &veb_oes->tc_tx_bytes[i],
+				   &veb_es->tc_tx_bytes[i]);
+	}
 	veb->stat_offsets_loaded = true;
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 9006939..572b2ef 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -1067,6 +1067,14 @@ struct i40e_eth_stats {
 	u64 tx_errors;			/* tepc */
 };
 
+/* Statistics collected per VEB per TC */
+struct i40e_veb_tc_stats {
+	u64 tc_rx_packets[I40E_MAX_TRAFFIC_CLASS];
+	u64 tc_rx_bytes[I40E_MAX_TRAFFIC_CLASS];
+	u64 tc_tx_packets[I40E_MAX_TRAFFIC_CLASS];
+	u64 tc_tx_bytes[I40E_MAX_TRAFFIC_CLASS];
+};
+
 #ifdef I40E_FCOE
 /* Statistics collected per function for FCoE */
 struct i40e_fcoe_stats {
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index a269386..3f8b5f5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -1061,6 +1061,14 @@ struct i40e_eth_stats {
 	u64 tx_errors;			/* tepc */
 };
 
+/* Statistics collected per VEB per TC */
+struct i40e_veb_tc_stats {
+	u64 tc_rx_packets[I40E_MAX_TRAFFIC_CLASS];
+	u64 tc_rx_bytes[I40E_MAX_TRAFFIC_CLASS];
+	u64 tc_tx_packets[I40E_MAX_TRAFFIC_CLASS];
+	u64 tc_tx_bytes[I40E_MAX_TRAFFIC_CLASS];
+};
+
 /* Statistics collected by the MAC */
 struct i40e_hw_port_stats {
 	/* eth stats collected by the port */
-- 
1.9.3
