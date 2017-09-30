From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: fix for flow director counters not wrapping as expected
Date: Fri, 29 Sep 2017 17:44:58 -0700
Message-ID: <20170930004507.20072-7-jeffrey.t.kirsher@intel.com>
References: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Cc: Mariusz Stachura <mariusz.stachura@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:34215 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752660AbdI3Apv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:45:51 -0400
In-Reply-To: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mariusz Stachura <mariusz.stachura@intel.com>

An errata with GLQF_PCNT causes it to not wrap as expected. This
can cause an error in flow director statistics. This patch resets
affected counters just after reading.

Signed-off-by: Mariusz Stachura <mariusz.stachura@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 35 +++++++++++++++++++----------
 1 file changed, 23 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a887087d08cd..638f5bad0bd7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -599,6 +599,20 @@ static void i40e_stat_update32(struct i40e_hw *hw, u32 reg,
 		*stat = (u32)((new_data + BIT_ULL(32)) - *offset);
 }
 
+/**
+ * i40e_stat_update_and_clear32 - read and clear hw reg, update a 32 bit stat
+ * @hw: ptr to the hardware info
+ * @reg: the hw reg to read and clear
+ * @stat: ptr to the stat
+ **/
+static void i40e_stat_update_and_clear32(struct i40e_hw *hw, u32 reg, u64 *stat)
+{
+	u32 new_data = rd32(hw, reg);
+
+	wr32(hw, reg, 1); /* must write a nonzero value to clear register */
+	*stat += new_data;
+}
+
 /**
  * i40e_update_eth_stats - Update VSI-specific ethernet statistics counters.
  * @vsi: the VSI to be updated
@@ -1040,18 +1054,15 @@ static void i40e_update_pf_stats(struct i40e_pf *pf)
 			   &osd->rx_jabber, &nsd->rx_jabber);
 
 	/* FDIR stats */
-	i40e_stat_update32(hw,
-			   I40E_GLQF_PCNT(I40E_FD_ATR_STAT_IDX(pf->hw.pf_id)),
-			   pf->stat_offsets_loaded,
-			   &osd->fd_atr_match, &nsd->fd_atr_match);
-	i40e_stat_update32(hw,
-			   I40E_GLQF_PCNT(I40E_FD_SB_STAT_IDX(pf->hw.pf_id)),
-			   pf->stat_offsets_loaded,
-			   &osd->fd_sb_match, &nsd->fd_sb_match);
-	i40e_stat_update32(hw,
-		      I40E_GLQF_PCNT(I40E_FD_ATR_TUNNEL_STAT_IDX(pf->hw.pf_id)),
-		      pf->stat_offsets_loaded,
-		      &osd->fd_atr_tunnel_match, &nsd->fd_atr_tunnel_match);
+	i40e_stat_update_and_clear32(hw,
+			I40E_GLQF_PCNT(I40E_FD_ATR_STAT_IDX(hw->pf_id)),
+			&nsd->fd_atr_match);
+	i40e_stat_update_and_clear32(hw,
+			I40E_GLQF_PCNT(I40E_FD_SB_STAT_IDX(hw->pf_id)),
+			&nsd->fd_sb_match);
+	i40e_stat_update_and_clear32(hw,
+			I40E_GLQF_PCNT(I40E_FD_ATR_TUNNEL_STAT_IDX(hw->pf_id)),
+			&nsd->fd_atr_tunnel_match);
 
 	val = rd32(hw, I40E_PRTPM_EEE_STAT);
 	nsd->tx_lpi_status =
-- 
2.14.1
