From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/16] i40e/i40evf: Add capability to gather VEB per TC stats
Date: Wed, 19 Aug 2015 17:57:58 -0700
Message-ID: <1440032286-30054-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1440032286-30054-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25933 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691AbbHTA6K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 20:58:10 -0400
In-Reply-To: <1440032286-30054-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

This patch adds capability to update per VEB per TC statistics and dump
it via ethtool. It also adds a structure to hold VEB per TC statistics.
The fields can be filled by reading the GLVEBTC_* counters.

Change-ID: I28b4759b9ab6ad5a61f046a1bc9ef6b16fe31538
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 23 ++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 28 +++++++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_type.h    |  8 ++++++++
 drivers/net/ethernet/intel/i40evf/i40e_type.h  |  8 ++++++++
 5 files changed, 67 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 7a55bca..e746279 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -443,6 +443,8 @@ struct i40e_veb {
 	bool stat_offsets_loaded;
 	struct i40e_eth_stats stats;
 	struct i40e_eth_stats stats_offsets;
+	struct i40e_veb_tc_stats tc_stats;
+	struct i40e_veb_tc_stats tc_stats_offsets;
 };
 
 /* struct that defines a VSI, associated with a dev */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 230d127..74c16a1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -197,7 +197,14 @@ static const struct i40e_stats i40e_gstrings_fcoe_stats[] = {
 		 FIELD_SIZEOF(struct i40e_pf, stats.priority_xon_tx) + \
 		 FIELD_SIZEOF(struct i40e_pf, stats.priority_xon_2_xoff)) \
 		 / sizeof(u64))
+#define I40E_VEB_TC_STATS_LEN ( \
+		(FIELD_SIZEOF(struct i40e_veb, tc_stats.tc_rx_packets) + \
+		 FIELD_SIZEOF(struct i40e_veb, tc_stats.tc_rx_bytes) + \
+		 FIELD_SIZEOF(struct i40e_veb, tc_stats.tc_tx_packets) + \
+		 FIELD_SIZEOF(struct i40e_veb, tc_stats.tc_tx_bytes)) \
+		 / sizeof(u64))
 #define I40E_VEB_STATS_LEN	ARRAY_SIZE(i40e_gstrings_veb_stats)
+#define I40E_VEB_STATS_TOTAL	(I40E_VEB_STATS_LEN + I40E_VEB_TC_STATS_LEN)
 #define I40E_PF_STATS_LEN(n)	(I40E_GLOBAL_STATS_LEN + \
 				 I40E_PFC_STATS_LEN + \
 				 I40E_VSI_STATS_LEN((n)))
@@ -1257,7 +1264,7 @@ static int i40e_get_sset_count(struct net_device *netdev, int sset)
 			int len = I40E_PF_STATS_LEN(netdev);
 
 			if (pf->lan_veb != I40E_NO_VEB)
-				len += I40E_VEB_STATS_LEN;
+				len += I40E_VEB_STATS_TOTAL;
 			return len;
 		} else {
 			return I40E_VSI_STATS_LEN(netdev);
@@ -1408,6 +1415,20 @@ static void i40e_get_strings(struct net_device *netdev, u32 stringset,
 					i40e_gstrings_veb_stats[i].stat_string);
 				p += ETH_GSTRING_LEN;
 			}
+			for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
+				snprintf(p, ETH_GSTRING_LEN,
+					 "veb.tc_%u_tx_packets", i);
+				p += ETH_GSTRING_LEN;
+				snprintf(p, ETH_GSTRING_LEN,
+					 "veb.tc_%u_tx_bytes", i);
+				p += ETH_GSTRING_LEN;
+				snprintf(p, ETH_GSTRING_LEN,
+					 "veb.tc_%u_rx_packets", i);
+				p += ETH_GSTRING_LEN;
+				snprintf(p, ETH_GSTRING_LEN,
+					 "veb.tc_%u_rx_bytes", i);
+				p += ETH_GSTRING_LEN;
+			}
 		}
 		for (i = 0; i < I40E_GLOBAL_STATS_LEN; i++) {
 			snprintf(p, ETH_GSTRING_LEN, "port.%s",
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 81db94b..8422f8a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -554,11 +554,15 @@ static void i40e_update_veb_stats(struct i40e_veb *veb)
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
@@ -594,6 +598,28 @@ static void i40e_update_veb_stats(struct i40e_veb *veb)
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
index 61b6b11..acb2aad 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -1105,6 +1105,14 @@ struct i40e_eth_stats {
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
index e32dc0b..1ab2498 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -1095,6 +1095,14 @@ struct i40e_eth_stats {
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
2.4.3
