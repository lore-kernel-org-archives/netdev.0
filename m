From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: Remove separate functions gathering XOFF Rx stats
Date: Thu,  3 Dec 2015 05:25:56 -0800
Message-ID: <1449149160-105219-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53943 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750792AbbLCN0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 08:26:05 -0500
In-Reply-To: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

The separate functions to gather Flow control Rx XOFF stats was to
determine if the Tx for a queue was paused due to Link Flow Control(LFC)
or Priority Flow Control(PFC).

But, with recent change in the i40e driver the logic for checking th Tx
hang has been removed and these functions don't do anything meaningful.
Hence, there is no need to keep these separate functions to gather Rx
XOFF stats for LFC or PFC.

This patch removes these functions and moves the stat collection for
XOFF Rx to the i40e_update_pf_stats() that collects all the PF stats.

Change-ID: Iec1452dac3a6766f0d968e754cb407530d7c60cd
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 77 +++--------------------------
 1 file changed, 7 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b731a82..1c5c0fd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -792,75 +792,6 @@ static void i40e_update_fcoe_stats(struct i40e_vsi *vsi)
 
 #endif
 /**
- * i40e_update_link_xoff_rx - Update XOFF received in link flow control mode
- * @pf: the corresponding PF
- *
- * Update the Rx XOFF counter (PAUSE frames) in link flow control mode
- **/
-static void i40e_update_link_xoff_rx(struct i40e_pf *pf)
-{
-	struct i40e_hw_port_stats *osd = &pf->stats_offsets;
-	struct i40e_hw_port_stats *nsd = &pf->stats;
-	struct i40e_hw *hw = &pf->hw;
-	u64 xoff = 0;
-
-	if ((hw->fc.current_mode != I40E_FC_FULL) &&
-	    (hw->fc.current_mode != I40E_FC_RX_PAUSE))
-		return;
-
-	xoff = nsd->link_xoff_rx;
-	i40e_stat_update32(hw, I40E_GLPRT_LXOFFRXC(hw->port),
-			   pf->stat_offsets_loaded,
-			   &osd->link_xoff_rx, &nsd->link_xoff_rx);
-
-	/* No new LFC xoff rx */
-	if (!(nsd->link_xoff_rx - xoff))
-		return;
-
-}
-
-/**
- * i40e_update_prio_xoff_rx - Update XOFF received in PFC mode
- * @pf: the corresponding PF
- *
- * Update the Rx XOFF counter (PAUSE frames) in PFC mode
- **/
-static void i40e_update_prio_xoff_rx(struct i40e_pf *pf)
-{
-	struct i40e_hw_port_stats *osd = &pf->stats_offsets;
-	struct i40e_hw_port_stats *nsd = &pf->stats;
-	bool xoff[I40E_MAX_TRAFFIC_CLASS] = {false};
-	struct i40e_dcbx_config *dcb_cfg;
-	struct i40e_hw *hw = &pf->hw;
-	u16 i;
-	u8 tc;
-
-	dcb_cfg = &hw->local_dcbx_config;
-
-	/* Collect Link XOFF stats when PFC is disabled */
-	if (!dcb_cfg->pfc.pfcenable) {
-		i40e_update_link_xoff_rx(pf);
-		return;
-	}
-
-	for (i = 0; i < I40E_MAX_USER_PRIORITY; i++) {
-		u64 prio_xoff = nsd->priority_xoff_rx[i];
-
-		i40e_stat_update32(hw, I40E_GLPRT_PXOFFRXC(hw->port, i),
-				   pf->stat_offsets_loaded,
-				   &osd->priority_xoff_rx[i],
-				   &nsd->priority_xoff_rx[i]);
-
-		/* No new PFC xoff rx */
-		if (!(nsd->priority_xoff_rx[i] - prio_xoff))
-			continue;
-		/* Get the TC for given priority */
-		tc = dcb_cfg->etscfg.prioritytable[i];
-		xoff[tc] = true;
-	}
-}
-
-/**
  * i40e_update_vsi_stats - Update the vsi statistics counters.
  * @vsi: the VSI to be updated
  *
@@ -1054,12 +985,18 @@ static void i40e_update_pf_stats(struct i40e_pf *pf)
 	i40e_stat_update32(hw, I40E_GLPRT_LXONTXC(hw->port),
 			   pf->stat_offsets_loaded,
 			   &osd->link_xon_tx, &nsd->link_xon_tx);
-	i40e_update_prio_xoff_rx(pf);  /* handles I40E_GLPRT_LXOFFRXC */
+	i40e_stat_update32(hw, I40E_GLPRT_LXOFFRXC(hw->port),
+			   pf->stat_offsets_loaded,
+			   &osd->link_xoff_rx, &nsd->link_xoff_rx);
 	i40e_stat_update32(hw, I40E_GLPRT_LXOFFTXC(hw->port),
 			   pf->stat_offsets_loaded,
 			   &osd->link_xoff_tx, &nsd->link_xoff_tx);
 
 	for (i = 0; i < 8; i++) {
+		i40e_stat_update32(hw, I40E_GLPRT_PXOFFRXC(hw->port, i),
+				   pf->stat_offsets_loaded,
+				   &osd->priority_xoff_rx[i],
+				   &nsd->priority_xoff_rx[i]);
 		i40e_stat_update32(hw, I40E_GLPRT_PXONRXC(hw->port, i),
 				   pf->stat_offsets_loaded,
 				   &osd->priority_xon_rx[i],
-- 
2.5.0
