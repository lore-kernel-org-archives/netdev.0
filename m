From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] i40e/i40evf: Add stats to count Tunnel ATR hits
Date: Thu, 28 May 2015 04:25:31 -0700
Message-ID: <1432812339-17129-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56315 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753981AbbE1LZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 07:25:47 -0400
In-Reply-To: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Add a 3rd dynamic filter counter to track Tunneled ATR hits separately.
Ethtool port stat "fdir_atr_tunnel_match"

Change-ID: Idd978b6db2a462b5722397cd2ffd04ef055f8655
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  3 +++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  4 ++++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 13 ++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_type.h    |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h  |  1 +
 6 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 33c35d3..0bfa5a0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -182,6 +182,7 @@ struct i40e_lump_tracking {
 enum i40e_fd_stat_idx {
 	I40E_FD_STAT_ATR,
 	I40E_FD_STAT_SB,
+	I40E_FD_STAT_ATR_TUNNEL,
 	I40E_FD_STAT_PF_COUNT
 };
 #define I40E_FD_STAT_PF_IDX(pf_id) ((pf_id) * I40E_FD_STAT_PF_COUNT)
@@ -189,6 +190,8 @@ enum i40e_fd_stat_idx {
 			(I40E_FD_STAT_PF_IDX(pf_id) + I40E_FD_STAT_ATR)
 #define I40E_FD_SB_STAT_IDX(pf_id)  \
 			(I40E_FD_STAT_PF_IDX(pf_id) + I40E_FD_STAT_SB)
+#define I40E_FD_ATR_TUNNEL_STAT_IDX(pf_id) \
+			(I40E_FD_STAT_PF_IDX(pf_id) + I40E_FD_STAT_ATR_TUNNEL)
 
 struct i40e_fdir_filter {
 	struct hlist_node fdir_node;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index e77b6bd..c568c90 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -147,6 +147,7 @@ static struct i40e_stats i40e_gstrings_stats[] = {
 	I40E_PF_STAT("rx_hwtstamp_cleared", rx_hwtstamp_cleared),
 	I40E_PF_STAT("fdir_flush_cnt", fd_flush_cnt),
 	I40E_PF_STAT("fdir_atr_match", stats.fd_atr_match),
+	I40E_PF_STAT("fdir_atr_tunnel_match", stats.fd_atr_tunnel_match),
 	I40E_PF_STAT("fdir_sb_match", stats.fd_sb_match),
 
 	/* LPI stats */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f1a8c4c..e70a616 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1102,6 +1102,10 @@ static void i40e_update_pf_stats(struct i40e_pf *pf)
 	i40e_stat_update32(hw, I40E_GLQF_PCNT(pf->fd_sb_cnt_idx),
 			   pf->stat_offsets_loaded,
 			   &osd->fd_sb_match, &nsd->fd_sb_match);
+	i40e_stat_update32(hw,
+		      I40E_GLQF_PCNT(I40E_FD_ATR_TUNNEL_STAT_IDX(pf->hw.pf_id)),
+		      pf->stat_offsets_loaded,
+		      &osd->fd_atr_tunnel_match, &nsd->fd_atr_tunnel_match);
 
 	val = rd32(hw, I40E_PRTPM_EEE_STAT);
 	nsd->tx_lpi_status =
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 8565495..fc4ec82 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2033,9 +2033,16 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		     I40E_TXD_FLTR_QW1_FD_STATUS_SHIFT;
 
 	dtype_cmd |= I40E_TXD_FLTR_QW1_CNT_ENA_MASK;
-	dtype_cmd |=
-		((u32)pf->fd_atr_cnt_idx << I40E_TXD_FLTR_QW1_CNTINDEX_SHIFT) &
-		I40E_TXD_FLTR_QW1_CNTINDEX_MASK;
+	if (!(tx_flags & I40E_TX_FLAGS_VXLAN_TUNNEL))
+		dtype_cmd |=
+			((u32)I40E_FD_ATR_STAT_IDX(pf->hw.pf_id) <<
+			I40E_TXD_FLTR_QW1_CNTINDEX_SHIFT) &
+			I40E_TXD_FLTR_QW1_CNTINDEX_MASK;
+	else
+		dtype_cmd |=
+			((u32)I40E_FD_ATR_TUNNEL_STAT_IDX(pf->hw.pf_id) <<
+			I40E_TXD_FLTR_QW1_CNTINDEX_SHIFT) &
+			I40E_TXD_FLTR_QW1_CNTINDEX_MASK;
 
 	fdir_desc->qindex_flex_ptype_vsi = cpu_to_le32(flex_ptype);
 	fdir_desc->rsvd = cpu_to_le32(0);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 568e855..9a5a75b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -1133,6 +1133,7 @@ struct i40e_hw_port_stats {
 	/* flow director stats */
 	u64 fd_atr_match;
 	u64 fd_sb_match;
+	u64 fd_atr_tunnel_match;
 	/* EEE LPI */
 	u32 tx_lpi_status;
 	u32 rx_lpi_status;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index ec9d83a..c463ec4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -1108,6 +1108,7 @@ struct i40e_hw_port_stats {
 	/* flow director stats */
 	u64 fd_atr_match;
 	u64 fd_sb_match;
+	u64 fd_atr_tunnel_match;
 	/* EEE LPI */
 	u32 tx_lpi_status;
 	u32 rx_lpi_status;
-- 
2.1.0
