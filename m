From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] i40e: Fix the FD sideband logic to detect a FD table full condition
Date: Thu, 26 Jun 2014 05:13:51 -0700
Message-ID: <1403784834-23301-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10417 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757674AbaFZMOb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 08:14:31 -0400
In-Reply-To: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Hardware does not have a way of telling a PF how much of the global
shared FD table space is still available or is consumed.
Previously, every PF but PF0 would think there was still space available
when there wasn't. The PFs would continue to try to add filters and fail.
With this new logic if a filter programming error is detected we just
check if we are close to the guaranteed space full and that can be used
as a hint to say, there might not be space and we should turn off the
features. This way we can turn off the feature in SW for all PFs in
time.

Change-ID: I725cb2fab16c033f883056362b4542c1400503c5
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  3 ++-
 drivers/net/ethernet/intel/i40e/i40e_main.c | 20 ++++++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c |  4 ++--
 3 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 2ec6e8a..0fbb32a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -154,7 +154,7 @@ struct i40e_lump_tracking {
 #define I40E_DEFAULT_ATR_SAMPLE_RATE	20
 #define I40E_FDIR_MAX_RAW_PACKET_SIZE	512
 #define I40E_FDIR_BUFFER_FULL_MARGIN	10
-#define I40E_FDIR_BUFFER_HEAD_ROOM	200
+#define I40E_FDIR_BUFFER_HEAD_ROOM	32
 
 enum i40e_fd_stat_idx {
 	I40E_FD_STAT_ATR,
@@ -582,6 +582,7 @@ int i40e_add_del_fdir(struct i40e_vsi *vsi,
 		      struct i40e_fdir_filter *input, bool add);
 void i40e_fdir_check_and_reenable(struct i40e_pf *pf);
 int i40e_get_current_fd_count(struct i40e_pf *pf);
+int i40e_get_cur_guaranteed_fd_count(struct i40e_pf *pf);
 bool i40e_set_ntuple(struct i40e_pf *pf, netdev_features_t features);
 void i40e_set_ethtool_ops(struct net_device *netdev);
 struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5980d6b..17b1295 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4944,7 +4944,20 @@ static void i40e_service_event_complete(struct i40e_pf *pf)
 }
 
 /**
- * i40e_get_current_fd_count - Get the count of FD filters programmed in the HW
+ * i40e_get_cur_guaranteed_fd_count - Get the consumed guaranteed FD filters
+ * @pf: board private structure
+ **/
+int i40e_get_cur_guaranteed_fd_count(struct i40e_pf *pf)
+{
+	int val, fcnt_prog;
+
+	val = rd32(&pf->hw, I40E_PFQF_FDSTAT);
+	fcnt_prog = (val & I40E_PFQF_FDSTAT_GUARANT_CNT_MASK);
+	return fcnt_prog;
+}
+
+/**
+ * i40e_get_current_fd_count - Get the count of total FD filters programmed
  * @pf: board private structure
  **/
 int i40e_get_current_fd_count(struct i40e_pf *pf)
@@ -4956,7 +4969,6 @@ int i40e_get_current_fd_count(struct i40e_pf *pf)
 		      I40E_PFQF_FDSTAT_BEST_CNT_SHIFT);
 	return fcnt_prog;
 }
-
 /**
  * i40e_fdir_check_and_reenable - Function to reenabe FD ATR or SB if disabled
  * @pf: board private structure
@@ -4971,8 +4983,8 @@ void i40e_fdir_check_and_reenable(struct i40e_pf *pf)
 	if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
 	    (pf->flags & I40E_FLAG_FD_SB_ENABLED))
 		return;
-	fcnt_prog = i40e_get_current_fd_count(pf);
-	fcnt_avail = i40e_get_fd_cnt_all(pf);
+	fcnt_prog = i40e_get_cur_guaranteed_fd_count(pf);
+	fcnt_avail = pf->fdir_pf_filter_count;
 	if (fcnt_prog < (fcnt_avail - I40E_FDIR_BUFFER_HEAD_ROOM)) {
 		if ((pf->flags & I40E_FLAG_FD_SB_ENABLED) &&
 		    (pf->auto_disable_flags & I40E_FLAG_FD_SB_ENABLED)) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 4d96b74..c5749d6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -437,8 +437,8 @@ static void i40e_fd_handle_status(struct i40e_ring *rx_ring,
 			 rx_desc->wb.qword0.hi_dword.fd_id);
 
 		/* filter programming failed most likely due to table full */
-		fcnt_prog = i40e_get_current_fd_count(pf);
-		fcnt_avail = i40e_get_fd_cnt_all(pf);
+		fcnt_prog = i40e_get_cur_guaranteed_fd_count(pf);
+		fcnt_avail = pf->fdir_pf_filter_count;
 		/* If ATR is running fcnt_prog can quickly change,
 		 * if we are very close to full, it makes sense to disable
 		 * FD ATR/SB and then re-enable it when there is room.
-- 
1.9.3
