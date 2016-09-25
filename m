From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: cleanup ATR auto_disable_flags use
Date: Sat, 24 Sep 2016 23:42:38 -0700
Message-ID: <1474785769-54665-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:8819 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752727AbcIYGmx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 02:42:53 -0400
In-Reply-To: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Some locations that disable ATR accidentally used the "full" disable by
disabling the flag in the standard flags field. This incorrectly forces
ATR off permanently instead of temporarily disabling it. In addition,
some code locations accidentally set the ATR flag enabled when they only
meant to clear the auto_disable_flags. This results in ignoring the
user's ethtool private flag settings.

Additionally, when disabling ATR via ethtool, we did not perform a flush
of the FD table. This results in the previously assigned ATR rules still
functioning which was not expected.

Cleanup all these areas so that automatic disable uses only the
auto_disable_flag. Fix the flush code so that we can trigger a flush
even when we've disabled ATR and SB support, as otherwise the flush
doesn't work. Fix ethtool setting to actually request a flush. Fix
NETIF_F_NTUPLE flag to only clear the auto_disable setting and not
enable the full feature.

Change-ID: Ib2486111f8031bd16943e9308757b276305c03b5
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  3 +++
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 20 +++++++-------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 14 +++++++-------
 3 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index af28a8c..5cad80f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -3021,6 +3021,9 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 	} else {
 		pf->flags &= ~I40E_FLAG_FD_ATR_ENABLED;
 		pf->auto_disable_flags |= I40E_FLAG_FD_ATR_ENABLED;
+
+		/* flush current ATR settings */
+		set_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
 	}
 
 	if ((flags & I40E_PRIV_FLAGS_VEB_STATS) &&
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0841379..e1a2c9a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5242,7 +5242,7 @@ static int i40e_up_complete(struct i40e_vsi *vsi)
 		/* reset fd counters */
 		pf->fd_add_err = pf->fd_atr_cnt = 0;
 		if (pf->fd_tcp_rule > 0) {
-			pf->flags &= ~I40E_FLAG_FD_ATR_ENABLED;
+			pf->auto_disable_flags |= I40E_FLAG_FD_ATR_ENABLED;
 			if (I40E_DEBUG_FD & pf->hw.debug_mask)
 				dev_info(&pf->pdev->dev, "Forcing ATR off, sideband rules for TCP/IPv4 exist\n");
 			pf->fd_tcp_rule = 0;
@@ -5976,9 +5976,6 @@ static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
 	int fd_room;
 	int reg;
 
-	if (!(pf->flags & (I40E_FLAG_FD_SB_ENABLED | I40E_FLAG_FD_ATR_ENABLED)))
-		return;
-
 	if (!time_after(jiffies, pf->fd_flush_timestamp +
 				 (I40E_MIN_FD_FLUSH_INTERVAL * HZ)))
 		return;
@@ -5998,7 +5995,7 @@ static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
 	}
 
 	pf->fd_flush_timestamp = jiffies;
-	pf->flags &= ~I40E_FLAG_FD_ATR_ENABLED;
+	pf->auto_disable_flags |= I40E_FLAG_FD_ATR_ENABLED;
 	/* flush all filters */
 	wr32(&pf->hw, I40E_PFQF_CTL_1,
 	     I40E_PFQF_CTL_1_CLEARFDTABLE_MASK);
@@ -6018,7 +6015,7 @@ static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
 		/* replay sideband filters */
 		i40e_fdir_filter_restore(pf->vsi[pf->lan_vsi]);
 		if (!disable_atr)
-			pf->flags |= I40E_FLAG_FD_ATR_ENABLED;
+			pf->auto_disable_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
 		clear_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
 		if (I40E_DEBUG_FD & pf->hw.debug_mask)
 			dev_info(&pf->pdev->dev, "FD Filter table flushed and FD-SB replayed.\n");
@@ -6052,9 +6049,6 @@ static void i40e_fdir_reinit_subtask(struct i40e_pf *pf)
 	if (test_bit(__I40E_DOWN, &pf->state))
 		return;
 
-	if (!(pf->flags & (I40E_FLAG_FD_SB_ENABLED | I40E_FLAG_FD_ATR_ENABLED)))
-		return;
-
 	if (test_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state))
 		i40e_fdir_flush_and_replay(pf);
 
@@ -8682,13 +8676,13 @@ bool i40e_set_ntuple(struct i40e_pf *pf, netdev_features_t features)
 		/* reset fd counters */
 		pf->fd_add_err = pf->fd_atr_cnt = pf->fd_tcp_rule = 0;
 		pf->fdir_pf_active_filters = 0;
-		pf->flags |= I40E_FLAG_FD_ATR_ENABLED;
-		if (I40E_DEBUG_FD & pf->hw.debug_mask)
-			dev_info(&pf->pdev->dev, "ATR re-enabled.\n");
 		/* if ATR was auto disabled it can be re-enabled. */
 		if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
-		    (pf->auto_disable_flags & I40E_FLAG_FD_ATR_ENABLED))
+		    (pf->auto_disable_flags & I40E_FLAG_FD_ATR_ENABLED)) {
 			pf->auto_disable_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
+			if (I40E_DEBUG_FD & pf->hw.debug_mask)
+				dev_info(&pf->pdev->dev, "ATR re-enabled.\n");
+		}
 	}
 	return need_reset;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index bf7bb7c..7ada05e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -282,18 +282,18 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 
 	if (add) {
 		pf->fd_tcp_rule++;
-		if (pf->flags & I40E_FLAG_FD_ATR_ENABLED) {
-			if (I40E_DEBUG_FD & pf->hw.debug_mask)
-				dev_info(&pf->pdev->dev, "Forcing ATR off, sideband rules for TCP/IPv4 flow being applied\n");
-			pf->flags &= ~I40E_FLAG_FD_ATR_ENABLED;
-		}
+		if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
+		    I40E_DEBUG_FD & pf->hw.debug_mask)
+			dev_info(&pf->pdev->dev, "Forcing ATR off, sideband rules for TCP/IPv4 flow being applied\n");
+		pf->auto_disable_flags |= I40E_FLAG_FD_ATR_ENABLED;
 	} else {
 		pf->fd_tcp_rule = (pf->fd_tcp_rule > 0) ?
 				  (pf->fd_tcp_rule - 1) : 0;
 		if (pf->fd_tcp_rule == 0) {
-			pf->flags |= I40E_FLAG_FD_ATR_ENABLED;
-			if (I40E_DEBUG_FD & pf->hw.debug_mask)
+			if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
+			    I40E_DEBUG_FD & pf->hw.debug_mask)
 				dev_info(&pf->pdev->dev, "ATR re-enabled due to no sideband TCP/IPv4 rules\n");
+			pf->auto_disable_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
 		}
 	}
 
-- 
2.7.4
