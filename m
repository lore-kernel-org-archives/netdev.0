From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/13] i40e: rename auto_disable_flags to hw_disabled_flags
Date: Tue, 14 Mar 2017 15:33:08 -0700
Message-ID: <20170314223308.53451-14-jeffrey.t.kirsher@intel.com>
References: <20170314223308.53451-1-jeffrey.t.kirsher@intel.com>
Cc: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:12644 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752450AbdCNWdd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 18:33:33 -0400
In-Reply-To: <20170314223308.53451-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>

A previous commit introduced a field that tracks the features
that are disabled due to HW resource limitations as opposed
to the featured disabled by the user. This patch changes the
name of the field to make it more readable since it might get
confusing when looking at code containing both the flags
field and the auto_disable_features field together.

Change-ID: Idcc9888659698f6fe3ccff17c8c3f09b5026f708
Signed-off-by: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  8 ++++++--
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 10 ++++-----
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 28 +++++++++++++-------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 20 +++++++++---------
 4 files changed, 35 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 9b2bb8d971cc..a5cf5d11d0e7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -353,8 +353,12 @@ struct i40e_pf {
 #define I40E_FLAG_CLIENT_L2_CHANGE		BIT_ULL(56)
 #define I40E_FLAG_WOL_MC_MAGIC_PKT_WAKE		BIT_ULL(57)
 
-	/* tracks features that get auto disabled by errors */
-	u64 auto_disable_flags;
+	/* Tracks features that are disabled due to hw limitations.
+	 * If a bit is set here, it means that the corresponding
+	 * bit in the 'flags' field is cleared i.e that feature
+	 * is disabled
+	 */
+	u64 hw_disabled_flags;
 
 #ifdef I40E_FCOE
 	struct i40e_fcoe fcoe;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 3aefc9e20439..a933c6c2aff8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2717,7 +2717,7 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 	if (!(pf->flags & I40E_FLAG_FD_SB_ENABLED))
 		return -EOPNOTSUPP;
 
-	if (pf->auto_disable_flags & I40E_FLAG_FD_SB_ENABLED)
+	if (pf->hw_disabled_flags & I40E_FLAG_FD_SB_ENABLED)
 		return -ENOSPC;
 
 	if (test_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state) ||
@@ -3059,7 +3059,7 @@ static u32 i40e_get_priv_flags(struct net_device *dev)
 		I40E_PRIV_FLAGS_FD_ATR : 0;
 	ret_flags |= pf->flags & I40E_FLAG_VEB_STATS_ENABLED ?
 		I40E_PRIV_FLAGS_VEB_STATS : 0;
-	ret_flags |= pf->auto_disable_flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE ?
+	ret_flags |= pf->hw_disabled_flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE ?
 		0 : I40E_PRIV_FLAGS_HW_ATR_EVICT;
 	if (pf->hw.pf_id == 0) {
 		ret_flags |= pf->flags & I40E_FLAG_TRUE_PROMISC_SUPPORT ?
@@ -3099,7 +3099,7 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 		pf->flags |= I40E_FLAG_FD_ATR_ENABLED;
 	} else {
 		pf->flags &= ~I40E_FLAG_FD_ATR_ENABLED;
-		pf->auto_disable_flags |= I40E_FLAG_FD_ATR_ENABLED;
+		pf->hw_disabled_flags |= I40E_FLAG_FD_ATR_ENABLED;
 
 		/* flush current ATR settings */
 		set_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
@@ -3144,9 +3144,9 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 
 	if ((flags & I40E_PRIV_FLAGS_HW_ATR_EVICT) &&
 	    (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE))
-		pf->auto_disable_flags &= ~I40E_FLAG_HW_ATR_EVICT_CAPABLE;
+		pf->hw_disabled_flags &= ~I40E_FLAG_HW_ATR_EVICT_CAPABLE;
 	else
-		pf->auto_disable_flags |= I40E_FLAG_HW_ATR_EVICT_CAPABLE;
+		pf->hw_disabled_flags |= I40E_FLAG_HW_ATR_EVICT_CAPABLE;
 
 	/* if needed, issue reset to cause things to take effect */
 	if (reset_required)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4d305fb1f188..113b32911f1b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1101,13 +1101,13 @@ static void i40e_update_pf_stats(struct i40e_pf *pf)
 			   &osd->rx_lpi_count, &nsd->rx_lpi_count);
 
 	if (pf->flags & I40E_FLAG_FD_SB_ENABLED &&
-	    !(pf->auto_disable_flags & I40E_FLAG_FD_SB_ENABLED))
+	    !(pf->hw_disabled_flags & I40E_FLAG_FD_SB_ENABLED))
 		nsd->fd_sb_status = true;
 	else
 		nsd->fd_sb_status = false;
 
 	if (pf->flags & I40E_FLAG_FD_ATR_ENABLED &&
-	    !(pf->auto_disable_flags & I40E_FLAG_FD_ATR_ENABLED))
+	    !(pf->hw_disabled_flags & I40E_FLAG_FD_ATR_ENABLED))
 		nsd->fd_atr_status = true;
 	else
 		nsd->fd_atr_status = false;
@@ -5467,7 +5467,7 @@ static int i40e_up_complete(struct i40e_vsi *vsi)
 		/* reset fd counters */
 		pf->fd_add_err = pf->fd_atr_cnt = 0;
 		if (pf->fd_tcp_rule > 0) {
-			pf->auto_disable_flags |= I40E_FLAG_FD_ATR_ENABLED;
+			pf->hw_disabled_flags |= I40E_FLAG_FD_ATR_ENABLED;
 			if (I40E_DEBUG_FD & pf->hw.debug_mask)
 				dev_info(&pf->pdev->dev, "Forcing ATR off, sideband rules for TCP/IPv4 exist\n");
 			pf->fd_tcp_rule = 0;
@@ -6143,8 +6143,8 @@ void i40e_fdir_check_and_reenable(struct i40e_pf *pf)
 	    (pf->fd_add_err == 0) ||
 	    (i40e_get_current_atr_cnt(pf) < pf->fd_atr_cnt)) {
 		if ((pf->flags & I40E_FLAG_FD_SB_ENABLED) &&
-		    (pf->auto_disable_flags & I40E_FLAG_FD_SB_ENABLED)) {
-			pf->auto_disable_flags &= ~I40E_FLAG_FD_SB_ENABLED;
+		    (pf->hw_disabled_flags & I40E_FLAG_FD_SB_ENABLED)) {
+			pf->hw_disabled_flags &= ~I40E_FLAG_FD_SB_ENABLED;
 			if (I40E_DEBUG_FD & pf->hw.debug_mask)
 				dev_info(&pf->pdev->dev, "FD Sideband/ntuple is being enabled since we have space in the table now\n");
 		}
@@ -6155,9 +6155,9 @@ void i40e_fdir_check_and_reenable(struct i40e_pf *pf)
 	 */
 	if (fcnt_prog < (fcnt_avail - I40E_FDIR_BUFFER_HEAD_ROOM * 2)) {
 		if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
-		    (pf->auto_disable_flags & I40E_FLAG_FD_ATR_ENABLED) &&
+		    (pf->hw_disabled_flags & I40E_FLAG_FD_ATR_ENABLED) &&
 		    (pf->fd_tcp_rule == 0)) {
-			pf->auto_disable_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
+			pf->hw_disabled_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
 			if (I40E_DEBUG_FD & pf->hw.debug_mask)
 				dev_info(&pf->pdev->dev, "ATR is being enabled since we have space in the table and there are no conflicting ntuple rules\n");
 		}
@@ -6209,7 +6209,7 @@ static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
 	}
 
 	pf->fd_flush_timestamp = jiffies;
-	pf->auto_disable_flags |= I40E_FLAG_FD_ATR_ENABLED;
+	pf->hw_disabled_flags |= I40E_FLAG_FD_ATR_ENABLED;
 	/* flush all filters */
 	wr32(&pf->hw, I40E_PFQF_CTL_1,
 	     I40E_PFQF_CTL_1_CLEARFDTABLE_MASK);
@@ -6229,7 +6229,7 @@ static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
 		/* replay sideband filters */
 		i40e_fdir_filter_restore(pf->vsi[pf->lan_vsi]);
 		if (!disable_atr)
-			pf->auto_disable_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
+			pf->hw_disabled_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
 		clear_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
 		if (I40E_DEBUG_FD & pf->hw.debug_mask)
 			dev_info(&pf->pdev->dev, "FD Filter table flushed and FD-SB replayed.\n");
@@ -8872,9 +8872,9 @@ static int i40e_sw_init(struct i40e_pf *pf)
 		    (pf->hw.aq.api_min_ver > 4))) {
 		/* Supported in FW API version higher than 1.4 */
 		pf->flags |= I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
-		pf->auto_disable_flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
+		pf->hw_disabled_flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
 	} else {
-		pf->auto_disable_flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
+		pf->hw_disabled_flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
 	}
 
 	pf->eeprom_version = 0xDEAD;
@@ -8935,14 +8935,14 @@ bool i40e_set_ntuple(struct i40e_pf *pf, netdev_features_t features)
 			i40e_fdir_filter_exit(pf);
 		}
 		pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
-		pf->auto_disable_flags &= ~I40E_FLAG_FD_SB_ENABLED;
+		pf->hw_disabled_flags &= ~I40E_FLAG_FD_SB_ENABLED;
 		/* reset fd counters */
 		pf->fd_add_err = pf->fd_atr_cnt = pf->fd_tcp_rule = 0;
 		pf->fdir_pf_active_filters = 0;
 		/* if ATR was auto disabled it can be re-enabled. */
 		if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
-		    (pf->auto_disable_flags & I40E_FLAG_FD_ATR_ENABLED)) {
-			pf->auto_disable_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
+		    (pf->hw_disabled_flags & I40E_FLAG_FD_ATR_ENABLED)) {
+			pf->hw_disabled_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
 			if (I40E_DEBUG_FD & pf->hw.debug_mask)
 				dev_info(&pf->pdev->dev, "ATR re-enabled.\n");
 		}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 86e4991a03a7..6eb5dc4168f3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -291,7 +291,7 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 		if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
 		    I40E_DEBUG_FD & pf->hw.debug_mask)
 			dev_info(&pf->pdev->dev, "Forcing ATR off, sideband rules for TCP/IPv4 flow being applied\n");
-		pf->auto_disable_flags |= I40E_FLAG_FD_ATR_ENABLED;
+		pf->hw_disabled_flags |= I40E_FLAG_FD_ATR_ENABLED;
 	} else {
 		pf->fd_tcp_rule = (pf->fd_tcp_rule > 0) ?
 				  (pf->fd_tcp_rule - 1) : 0;
@@ -299,7 +299,7 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 			if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
 			    I40E_DEBUG_FD & pf->hw.debug_mask)
 				dev_info(&pf->pdev->dev, "ATR re-enabled due to no sideband TCP/IPv4 rules\n");
-			pf->auto_disable_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
+			pf->hw_disabled_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
 		}
 	}
 
@@ -484,8 +484,8 @@ static void i40e_fd_handle_status(struct i40e_ring *rx_ring,
 		pf->fd_atr_cnt = i40e_get_current_atr_cnt(pf);
 
 		if ((rx_desc->wb.qword0.hi_dword.fd_id == 0) &&
-		    (pf->auto_disable_flags & I40E_FLAG_FD_SB_ENABLED)) {
-			pf->auto_disable_flags |= I40E_FLAG_FD_ATR_ENABLED;
+		    (pf->hw_disabled_flags & I40E_FLAG_FD_SB_ENABLED)) {
+			pf->hw_disabled_flags |= I40E_FLAG_FD_ATR_ENABLED;
 			set_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
 		}
 
@@ -498,11 +498,11 @@ static void i40e_fd_handle_status(struct i40e_ring *rx_ring,
 		 */
 		if (fcnt_prog >= (fcnt_avail - I40E_FDIR_BUFFER_FULL_MARGIN)) {
 			if ((pf->flags & I40E_FLAG_FD_SB_ENABLED) &&
-			    !(pf->auto_disable_flags &
+			    !(pf->hw_disabled_flags &
 				     I40E_FLAG_FD_SB_ENABLED)) {
 				if (I40E_DEBUG_FD & pf->hw.debug_mask)
 					dev_warn(&pdev->dev, "FD filter space full, new ntuple rules will not be added\n");
-				pf->auto_disable_flags |=
+				pf->hw_disabled_flags |=
 							I40E_FLAG_FD_SB_ENABLED;
 			}
 		}
@@ -2100,7 +2100,7 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	if (!(pf->flags & I40E_FLAG_FD_ATR_ENABLED))
 		return;
 
-	if ((pf->auto_disable_flags & I40E_FLAG_FD_ATR_ENABLED))
+	if ((pf->hw_disabled_flags & I40E_FLAG_FD_ATR_ENABLED))
 		return;
 
 	/* if sampling is disabled do nothing */
@@ -2134,10 +2134,10 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	th = (struct tcphdr *)(hdr.network + hlen);
 
 	/* Due to lack of space, no more new filters can be programmed */
-	if (th->syn && (pf->auto_disable_flags & I40E_FLAG_FD_ATR_ENABLED))
+	if (th->syn && (pf->hw_disabled_flags & I40E_FLAG_FD_ATR_ENABLED))
 		return;
 	if ((pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE) &&
-	    (!(pf->auto_disable_flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE))) {
+	    (!(pf->hw_disabled_flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE))) {
 		/* HW ATR eviction will take care of removing filters on FIN
 		 * and RST packets.
 		 */
@@ -2200,7 +2200,7 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 			I40E_TXD_FLTR_QW1_CNTINDEX_MASK;
 
 	if ((pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE) &&
-	    (!(pf->auto_disable_flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE)))
+	    (!(pf->hw_disabled_flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE)))
 		dtype_cmd |= I40E_TXD_FLTR_QW1_ATR_MASK;
 
 	fdir_desc->qindex_flex_ptype_vsi = cpu_to_le32(flex_ptype);
-- 
2.12.0
