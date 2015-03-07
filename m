From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: FD filters flush policy changes
Date: Sat,  7 Mar 2015 07:03:18 -0800
Message-ID: <1425740603-11280-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52869 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452AbbCGPDa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Mar 2015 10:03:30 -0500
In-Reply-To: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Since GLQF_FDCNT_0 register now has the right offset, use it to simplify our
FD flush flow.
If the filter add error happens to be for SB we just auto disable SB.

If filter error happens to be for ATR, auto disable ATR and mark
the state to FD_FLUSH_REQUESTED. Which gets cleared when flush completes.

If we are entering flush too quickly (< 30 seconds) and we have quite
a few SB rules, its time to disable ATR for good. Since SB + ATR rules
is most likely making the FD table unstable.

ATR can be re-enabled by turning ntuple off (ethtool -K ntuple off)
and will remain off after turning ntuple on till it gets unstable again.

Change-ID: I2154a2e0a5d44851a2f0eb8731e2f1d4a4d1acbc
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  8 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c | 59 +++++++++++++++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 20 +++++++++-
 3 files changed, 67 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 4fb258a..f01cdbf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -175,6 +175,7 @@ struct i40e_lump_tracking {
 #define I40E_FDIR_MAX_RAW_PACKET_SIZE	512
 #define I40E_FDIR_BUFFER_FULL_MARGIN	10
 #define I40E_FDIR_BUFFER_HEAD_ROOM	32
+#define I40E_FDIR_BUFFER_HEAD_ROOM_FOR_ATR (I40E_FDIR_BUFFER_HEAD_ROOM * 4)
 
 enum i40e_fd_stat_idx {
 	I40E_FD_STAT_ATR,
@@ -636,9 +637,10 @@ int i40e_program_fdir_filter(struct i40e_fdir_filter *fdir_data, u8 *raw_packet,
 int i40e_add_del_fdir(struct i40e_vsi *vsi,
 		      struct i40e_fdir_filter *input, bool add);
 void i40e_fdir_check_and_reenable(struct i40e_pf *pf);
-int i40e_get_current_fd_count(struct i40e_pf *pf);
-int i40e_get_cur_guaranteed_fd_count(struct i40e_pf *pf);
-int i40e_get_current_atr_cnt(struct i40e_pf *pf);
+u32 i40e_get_current_fd_count(struct i40e_pf *pf);
+u32 i40e_get_cur_guaranteed_fd_count(struct i40e_pf *pf);
+u32 i40e_get_current_atr_cnt(struct i40e_pf *pf);
+u32 i40e_get_global_fd_count(struct i40e_pf *pf);
 bool i40e_set_ntuple(struct i40e_pf *pf, netdev_features_t features);
 void i40e_set_ethtool_ops(struct net_device *netdev);
 struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e765bb3..77099ed 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5345,9 +5345,9 @@ static void i40e_service_event_complete(struct i40e_pf *pf)
  * i40e_get_cur_guaranteed_fd_count - Get the consumed guaranteed FD filters
  * @pf: board private structure
  **/
-int i40e_get_cur_guaranteed_fd_count(struct i40e_pf *pf)
+u32 i40e_get_cur_guaranteed_fd_count(struct i40e_pf *pf)
 {
-	int val, fcnt_prog;
+	u32 val, fcnt_prog;
 
 	val = rd32(&pf->hw, I40E_PFQF_FDSTAT);
 	fcnt_prog = (val & I40E_PFQF_FDSTAT_GUARANT_CNT_MASK);
@@ -5355,12 +5355,13 @@ int i40e_get_cur_guaranteed_fd_count(struct i40e_pf *pf)
 }
 
 /**
- * i40e_get_current_fd_count - Get the count of total FD filters programmed
+ * i40e_get_current_fd_count - Get total FD filters programmed for this PF
  * @pf: board private structure
  **/
-int i40e_get_current_fd_count(struct i40e_pf *pf)
+u32 i40e_get_current_fd_count(struct i40e_pf *pf)
 {
-	int val, fcnt_prog;
+	u32 val, fcnt_prog;
+
 	val = rd32(&pf->hw, I40E_PFQF_FDSTAT);
 	fcnt_prog = (val & I40E_PFQF_FDSTAT_GUARANT_CNT_MASK) +
 		    ((val & I40E_PFQF_FDSTAT_BEST_CNT_MASK) >>
@@ -5369,6 +5370,21 @@ int i40e_get_current_fd_count(struct i40e_pf *pf)
 }
 
 /**
+ * i40e_get_global_fd_count - Get total FD filters programmed on device
+ * @pf: board private structure
+ **/
+u32 i40e_get_global_fd_count(struct i40e_pf *pf)
+{
+	u32 val, fcnt_prog;
+
+	val = rd32(&pf->hw, I40E_GLQF_FDCNT_0);
+	fcnt_prog = (val & I40E_GLQF_FDCNT_0_GUARANT_CNT_MASK) +
+		    ((val & I40E_GLQF_FDCNT_0_BESTCNT_MASK) >>
+		     I40E_GLQF_FDCNT_0_BESTCNT_SHIFT);
+	return fcnt_prog;
+}
+
+/**
  * i40e_fdir_check_and_reenable - Function to reenabe FD ATR or SB if disabled
  * @pf: board private structure
  **/
@@ -5382,7 +5398,7 @@ void i40e_fdir_check_and_reenable(struct i40e_pf *pf)
 	/* Check if, FD SB or ATR was auto disabled and if there is enough room
 	 * to re-enable
 	 */
-	fcnt_prog = i40e_get_cur_guaranteed_fd_count(pf);
+	fcnt_prog = i40e_get_global_fd_count(pf);
 	fcnt_avail = pf->fdir_pf_filter_count;
 	if ((fcnt_prog < (fcnt_avail - I40E_FDIR_BUFFER_HEAD_ROOM)) ||
 	    (pf->fd_add_err == 0) ||
@@ -5404,13 +5420,17 @@ void i40e_fdir_check_and_reenable(struct i40e_pf *pf)
 }
 
 #define I40E_MIN_FD_FLUSH_INTERVAL 10
+#define I40E_MIN_FD_FLUSH_SB_ATR_UNSTABLE 30
 /**
  * i40e_fdir_flush_and_replay - Function to flush all FD filters and replay SB
  * @pf: board private structure
  **/
 static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
 {
+	unsigned long min_flush_time;
 	int flush_wait_retry = 50;
+	bool disable_atr = false;
+	int fd_room;
 	int reg;
 
 	if (!(pf->flags & (I40E_FLAG_FD_SB_ENABLED | I40E_FLAG_FD_ATR_ENABLED)))
@@ -5418,9 +5438,20 @@ static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
 
 	if (time_after(jiffies, pf->fd_flush_timestamp +
 				(I40E_MIN_FD_FLUSH_INTERVAL * HZ))) {
-		set_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
+		/* If the flush is happening too quick and we have mostly
+		 * SB rules we should not re-enable ATR for some time.
+		 */
+		min_flush_time = pf->fd_flush_timestamp
+				+ (I40E_MIN_FD_FLUSH_SB_ATR_UNSTABLE * HZ);
+		fd_room = pf->fdir_pf_filter_count - pf->fdir_pf_active_filters;
+
+		if (!(time_after(jiffies, min_flush_time)) &&
+		    (fd_room < I40E_FDIR_BUFFER_HEAD_ROOM_FOR_ATR)) {
+			dev_info(&pf->pdev->dev, "ATR disabled, not enough FD filter space.\n");
+			disable_atr = true;
+		}
+
 		pf->fd_flush_timestamp = jiffies;
-		pf->auto_disable_flags |= I40E_FLAG_FD_SB_ENABLED;
 		pf->flags &= ~I40E_FLAG_FD_ATR_ENABLED;
 		/* flush all filters */
 		wr32(&pf->hw, I40E_PFQF_CTL_1,
@@ -5440,10 +5471,8 @@ static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
 		} else {
 			/* replay sideband filters */
 			i40e_fdir_filter_restore(pf->vsi[pf->lan_vsi]);
-
-			pf->flags |= I40E_FLAG_FD_ATR_ENABLED;
-			pf->auto_disable_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
-			pf->auto_disable_flags &= ~I40E_FLAG_FD_SB_ENABLED;
+			if (!disable_atr)
+				pf->flags |= I40E_FLAG_FD_ATR_ENABLED;
 			clear_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
 			dev_info(&pf->pdev->dev, "FD Filter table flushed and FD-SB replayed.\n");
 		}
@@ -5454,7 +5483,7 @@ static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
  * i40e_get_current_atr_count - Get the count of total FD ATR filters programmed
  * @pf: board private structure
  **/
-int i40e_get_current_atr_cnt(struct i40e_pf *pf)
+u32 i40e_get_current_atr_cnt(struct i40e_pf *pf)
 {
 	return i40e_get_current_fd_count(pf) - pf->fdir_pf_active_filters;
 }
@@ -5480,9 +5509,7 @@ static void i40e_fdir_reinit_subtask(struct i40e_pf *pf)
 	if (!(pf->flags & (I40E_FLAG_FD_SB_ENABLED | I40E_FLAG_FD_ATR_ENABLED)))
 		return;
 
-	if ((pf->fd_add_err >= I40E_MAX_FD_PROGRAM_ERROR) &&
-	    (i40e_get_current_atr_cnt(pf) >= pf->fd_atr_cnt) &&
-	    (i40e_get_current_atr_cnt(pf) > pf->fdir_pf_filter_count))
+	if (test_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state))
 		i40e_fdir_flush_and_replay(pf);
 
 	i40e_fdir_check_and_reenable(pf);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 64beea9..cdd5cc1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -471,12 +471,27 @@ static void i40e_fd_handle_status(struct i40e_ring *rx_ring,
 			dev_warn(&pdev->dev, "ntuple filter loc = %d, could not be added\n",
 				 rx_desc->wb.qword0.hi_dword.fd_id);
 
+		/* Check if the programming error is for ATR.
+		 * If so, auto disable ATR and set a state for
+		 * flush in progress. Next time we come here if flush is in
+		 * progress do nothing, once flush is complete the state will
+		 * be cleared.
+		 */
+		if (test_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state))
+			return;
+
 		pf->fd_add_err++;
 		/* store the current atr filter count */
 		pf->fd_atr_cnt = i40e_get_current_atr_cnt(pf);
 
+		if ((rx_desc->wb.qword0.hi_dword.fd_id == 0) &&
+		    (pf->auto_disable_flags & I40E_FLAG_FD_SB_ENABLED)) {
+			pf->auto_disable_flags |= I40E_FLAG_FD_ATR_ENABLED;
+			set_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
+		}
+
 		/* filter programming failed most likely due to table full */
-		fcnt_prog = i40e_get_cur_guaranteed_fd_count(pf);
+		fcnt_prog = i40e_get_global_fd_count(pf);
 		fcnt_avail = pf->fdir_pf_filter_count;
 		/* If ATR is running fcnt_prog can quickly change,
 		 * if we are very close to full, it makes sense to disable
@@ -1926,6 +1941,9 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	if (!(pf->flags & I40E_FLAG_FD_ATR_ENABLED))
 		return;
 
+	if ((pf->auto_disable_flags & I40E_FLAG_FD_ATR_ENABLED))
+		return;
+
 	/* if sampling is disabled do nothing */
 	if (!tx_ring->atr_sample_rate)
 		return;
-- 
1.9.3
