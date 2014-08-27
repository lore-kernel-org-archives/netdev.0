From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] i40e/i40evf: Ignore a driver perceived Tx hang if the number of desc pending < 4
Date: Wed, 27 Aug 2014 02:26:45 -0700
Message-ID: <1409131606-15011-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409131606-15011-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64393 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932981AbaH0J0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 05:26:55 -0400
In-Reply-To: <1409131606-15011-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

We are seeing situations where the driver sees a hang with less than 4
desc pending, if the driver chooses to ignore it the queue progresses
forward and the stack never experiences a real hang.
With this patch we will log a stat when this situation happens
"tx_sluggish" will increment and we can see some more details
at a higher debug level. Other than that we will ignore this
particular case of Tx hang.

Change-ID: I7d1d1666d990e2b12f4f6bed0d17d22e1b6410d5
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  1 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c |  3 +++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 10 +++++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c  |  6 ++++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h  |  1 +
 6 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 8526950..4e97ba1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -316,6 +316,7 @@ struct i40e_pf {
 	u32 tx_timeout_count;
 	u32 tx_timeout_recovery_level;
 	unsigned long tx_timeout_last_recovery;
+	u32 tx_sluggish_count;
 	u32 hw_csum_rx_error;
 	u32 led_status;
 	u16 corer_count; /* Core reset count */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 5a0cabe..7067f4b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1356,6 +1356,9 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				 "emp reset count: %d\n", pf->empr_count);
 			dev_info(&pf->pdev->dev,
 				 "pf reset count: %d\n", pf->pfr_count);
+			dev_info(&pf->pdev->dev,
+				 "pf tx sluggish count: %d\n",
+				 pf->tx_sluggish_count);
 		} else if (strncmp(&cmd_buf[5], "port", 4) == 0) {
 			struct i40e_aqc_query_port_ets_config_resp *bw_data;
 			struct i40e_dcbx_config *cfg =
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 366624a..4bf49d2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -607,6 +607,7 @@ static u32 i40e_get_tx_pending(struct i40e_ring *ring)
 static bool i40e_check_tx_hang(struct i40e_ring *tx_ring)
 {
 	u32 tx_pending = i40e_get_tx_pending(tx_ring);
+	struct i40e_pf *pf = tx_ring->vsi->back;
 	bool ret = false;
 
 	clear_check_for_tx_hang(tx_ring);
@@ -623,10 +624,17 @@ static bool i40e_check_tx_hang(struct i40e_ring *tx_ring)
 	 * pending but without time to complete it yet.
 	 */
 	if ((tx_ring->tx_stats.tx_done_old == tx_ring->stats.packets) &&
-	    tx_pending) {
+	    (tx_pending >= I40E_MIN_DESC_PENDING)) {
 		/* make sure it is true for two checks in a row */
 		ret = test_and_set_bit(__I40E_HANG_CHECK_ARMED,
 				       &tx_ring->state);
+	} else if ((tx_ring->tx_stats.tx_done_old == tx_ring->stats.packets) &&
+		   (tx_pending < I40E_MIN_DESC_PENDING) &&
+		   (tx_pending > 0)) {
+		if (I40E_DEBUG_FLOW & pf->hw.debug_mask)
+			dev_info(tx_ring->dev, "HW needs some more descs to do a cacheline flush. tx_pending %d, queue %d",
+				 tx_pending, tx_ring->queue_index);
+		pf->tx_sluggish_count++;
 	} else {
 		/* update completed stats and disarm the hang check */
 		tx_ring->tx_stats.tx_done_old = tx_ring->stats.packets;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 73f4fa4..d7a625a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -121,6 +121,7 @@ enum i40e_dyn_idx_t {
 /* Tx Descriptors needed, worst case */
 #define TXD_USE_COUNT(S) DIV_ROUND_UP((S), I40E_MAX_DATA_PER_TXD)
 #define DESC_NEEDED (MAX_SKB_FRAGS + 4)
+#define I40E_MIN_DESC_PENDING	4
 
 #define I40E_TX_FLAGS_CSUM		(u32)(1)
 #define I40E_TX_FLAGS_HW_VLAN		(u32)(1 << 1)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 79bf96c..64b0891 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -163,11 +163,13 @@ static bool i40e_check_tx_hang(struct i40e_ring *tx_ring)
 	 * pending but without time to complete it yet.
 	 */
 	if ((tx_ring->tx_stats.tx_done_old == tx_ring->stats.packets) &&
-	    tx_pending) {
+	    (tx_pending >= I40E_MIN_DESC_PENDING)) {
 		/* make sure it is true for two checks in a row */
 		ret = test_and_set_bit(__I40E_HANG_CHECK_ARMED,
 				       &tx_ring->state);
-	} else {
+	} else if (!(tx_ring->tx_stats.tx_done_old == tx_ring->stats.packets) ||
+		   !(tx_pending < I40E_MIN_DESC_PENDING) ||
+		   !(tx_pending > 0)) {
 		/* update completed stats and disarm the hang check */
 		tx_ring->tx_stats.tx_done_old = tx_ring->stats.packets;
 		clear_bit(__I40E_HANG_CHECK_ARMED, &tx_ring->state);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 8bc6858..f6dcf9d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -121,6 +121,7 @@ enum i40e_dyn_idx_t {
 /* Tx Descriptors needed, worst case */
 #define TXD_USE_COUNT(S) DIV_ROUND_UP((S), I40E_MAX_DATA_PER_TXD)
 #define DESC_NEEDED (MAX_SKB_FRAGS + 4)
+#define I40E_MIN_DESC_PENDING	4
 
 #define I40E_TX_FLAGS_CSUM		(u32)(1)
 #define I40E_TX_FLAGS_HW_VLAN		(u32)(1 << 1)
-- 
1.9.3
