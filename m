From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/13] i40e: add counters for UDP/IPv4 and IPv4 filters
Date: Mon, 20 Mar 2017 16:47:10 -0700
Message-ID: <20170320234712.84157-12-jeffrey.t.kirsher@intel.com>
References: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:49349 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932141AbdCTXrV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 19:47:21 -0400
In-Reply-To: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

In preparation for adding code to properly check the mask values, we
will need to know the number of active filters for each type. Add
counters for each filter type. Rename the already existing fd_tcp_rule
to fd_tcp4_filter_cnt to match the style of other names. To avoid style
warnings, avoid assigning multiple parameters at once, and fix up one
other case where we did so previously.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  9 ++++++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c | 19 +++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 17 +++++++++++++----
 3 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 55ea1c0221e6..c0f2286c2b72 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -286,7 +286,14 @@ struct i40e_pf {
 	u32 fd_flush_cnt;
 	u32 fd_add_err;
 	u32 fd_atr_cnt;
-	u32 fd_tcp_rule;
+
+	/* Book-keeping of side-band filter count per flow-type.
+	 * This is used to detect and handle input set changes for
+	 * respective flow-type.
+	 */
+	u16 fd_tcp4_filter_cnt;
+	u16 fd_udp4_filter_cnt;
+	u16 fd_ip4_filter_cnt;
 
 	struct i40e_udp_port_config udp_ports[I40E_MAX_PF_UDP_OFFLOAD_PORTS];
 	u16 pending_udp_bitmap;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index cc33ac835181..caccb8e97f1b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3284,7 +3284,9 @@ static void i40e_fdir_filter_restore(struct i40e_vsi *vsi)
 		return;
 
 	/* Reset FDir counters as we're replaying all existing filters */
-	pf->fd_tcp_rule = 0;
+	pf->fd_tcp4_filter_cnt = 0;
+	pf->fd_udp4_filter_cnt = 0;
+	pf->fd_ip4_filter_cnt = 0;
 
 	hlist_for_each_entry_safe(filter, node,
 				  &pf->fdir_filter_list, fdir_node) {
@@ -5468,7 +5470,8 @@ static int i40e_up_complete(struct i40e_vsi *vsi)
 	/* replay FDIR SB filters */
 	if (vsi->type == I40E_VSI_FDIR) {
 		/* reset fd counters */
-		pf->fd_add_err = pf->fd_atr_cnt = 0;
+		pf->fd_add_err = 0;
+		pf->fd_atr_cnt = 0;
 		i40e_fdir_filter_restore(vsi);
 	}
 
@@ -5751,7 +5754,11 @@ static void i40e_fdir_filter_exit(struct i40e_pf *pf)
 		hlist_del(&filter->fdir_node);
 		kfree(filter);
 	}
+
 	pf->fdir_pf_active_filters = 0;
+	pf->fd_tcp4_filter_cnt = 0;
+	pf->fd_udp4_filter_cnt = 0;
+	pf->fd_ip4_filter_cnt = 0;
 }
 
 /**
@@ -6156,7 +6163,7 @@ void i40e_fdir_check_and_reenable(struct i40e_pf *pf)
 	if (fcnt_prog < (fcnt_avail - I40E_FDIR_BUFFER_HEAD_ROOM * 2)) {
 		if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
 		    (pf->hw_disabled_flags & I40E_FLAG_FD_ATR_ENABLED) &&
-		    (pf->fd_tcp_rule == 0)) {
+		    (pf->fd_tcp4_filter_cnt == 0)) {
 			pf->hw_disabled_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
 			if (I40E_DEBUG_FD & pf->hw.debug_mask)
 				dev_info(&pf->pdev->dev, "ATR is being enabled since we have space in the table and there are no conflicting ntuple rules\n");
@@ -6228,7 +6235,7 @@ static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
 	} else {
 		/* replay sideband filters */
 		i40e_fdir_filter_restore(pf->vsi[pf->lan_vsi]);
-		if (!disable_atr && !pf->fd_tcp_rule)
+		if (!disable_atr && !pf->fd_tcp4_filter_cnt)
 			pf->hw_disabled_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
 		clear_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
 		if (I40E_DEBUG_FD & pf->hw.debug_mask)
@@ -8937,8 +8944,8 @@ bool i40e_set_ntuple(struct i40e_pf *pf, netdev_features_t features)
 		pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
 		pf->hw_disabled_flags &= ~I40E_FLAG_FD_SB_ENABLED;
 		/* reset fd counters */
-		pf->fd_add_err = pf->fd_atr_cnt = pf->fd_tcp_rule = 0;
-		pf->fdir_pf_active_filters = 0;
+		pf->fd_add_err = 0;
+		pf->fd_atr_cnt = 0;
 		/* if ATR was auto disabled it can be re-enabled. */
 		if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
 		    (pf->hw_disabled_flags & I40E_FLAG_FD_ATR_ENABLED)) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 05f3d0d5a004..3880e417f167 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -243,6 +243,11 @@ static int i40e_add_del_fdir_udpv4(struct i40e_vsi *vsi,
 				 fd_data->pctype, fd_data->fd_id);
 	}
 
+	if (add)
+		pf->fd_udp4_filter_cnt++;
+	else
+		pf->fd_udp4_filter_cnt--;
+
 	return 0;
 }
 
@@ -304,15 +309,14 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 	}
 
 	if (add) {
-		pf->fd_tcp_rule++;
+		pf->fd_tcp4_filter_cnt++;
 		if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
 		    I40E_DEBUG_FD & pf->hw.debug_mask)
 			dev_info(&pf->pdev->dev, "Forcing ATR off, sideband rules for TCP/IPv4 flow being applied\n");
 		pf->hw_disabled_flags |= I40E_FLAG_FD_ATR_ENABLED;
 	} else {
-		pf->fd_tcp_rule = (pf->fd_tcp_rule > 0) ?
-				  (pf->fd_tcp_rule - 1) : 0;
-		if (pf->fd_tcp_rule == 0) {
+		pf->fd_tcp4_filter_cnt--;
+		if (pf->fd_tcp4_filter_cnt == 0) {
 			if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
 			    I40E_DEBUG_FD & pf->hw.debug_mask)
 				dev_info(&pf->pdev->dev, "ATR re-enabled due to no sideband TCP/IPv4 rules\n");
@@ -381,6 +385,11 @@ static int i40e_add_del_fdir_ipv4(struct i40e_vsi *vsi,
 		}
 	}
 
+	if (add)
+		pf->fd_ip4_filter_cnt++;
+	else
+		pf->fd_ip4_filter_cnt--;
+
 	return 0;
 }
 
-- 
2.12.0
