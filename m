From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 05/13] i40e: fix race in hang check
Date: Thu, 26 Feb 2015 07:03:41 -0800
Message-ID: <1424963029-4612-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36183 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754004AbbBZPEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 10:04:00 -0500
In-Reply-To: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver was having some issues with false Tx hang detection. This
makes the driver a little more direct with the checks for progress
forward by directly checking the head write back address and tail register
when determining progress.  This avoids Tx hangs where the software
gets behind, because we are directly checking hardware state when
determining hang state.

Change-ID: I774f0e861c9e8ab5ccb213634100fe15440ae24a
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 54 +++++++++++++++------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 54 +++++++++++++++------------
 2 files changed, 60 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 0aad611..bbf1b12 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -586,6 +586,20 @@ void i40e_free_tx_resources(struct i40e_ring *tx_ring)
 }
 
 /**
+ * i40e_get_head - Retrieve head from head writeback
+ * @tx_ring:  tx ring to fetch head of
+ *
+ * Returns value of Tx ring head based on value stored
+ * in head write-back location
+ **/
+static inline u32 i40e_get_head(struct i40e_ring *tx_ring)
+{
+	void *head = (struct i40e_tx_desc *)tx_ring->desc + tx_ring->count;
+
+	return le32_to_cpu(*(volatile __le32 *)head);
+}
+
+/**
  * i40e_get_tx_pending - how many tx descriptors not processed
  * @tx_ring: the ring of descriptors
  *
@@ -594,10 +608,16 @@ void i40e_free_tx_resources(struct i40e_ring *tx_ring)
  **/
 static u32 i40e_get_tx_pending(struct i40e_ring *ring)
 {
-	u32 ntu = ((ring->next_to_clean <= ring->next_to_use)
-			? ring->next_to_use
-			: ring->next_to_use + ring->count);
-	return ntu - ring->next_to_clean;
+	u32 head, tail;
+
+	head = i40e_get_head(ring);
+	tail = readl(ring->tail);
+
+	if (head != tail)
+		return (head < tail) ?
+			tail - head : (tail + ring->count - head);
+
+	return 0;
 }
 
 /**
@@ -606,6 +626,8 @@ static u32 i40e_get_tx_pending(struct i40e_ring *ring)
  **/
 static bool i40e_check_tx_hang(struct i40e_ring *tx_ring)
 {
+	u32 tx_done = tx_ring->stats.packets;
+	u32 tx_done_old = tx_ring->tx_stats.tx_done_old;
 	u32 tx_pending = i40e_get_tx_pending(tx_ring);
 	struct i40e_pf *pf = tx_ring->vsi->back;
 	bool ret = false;
@@ -623,41 +645,25 @@ static bool i40e_check_tx_hang(struct i40e_ring *tx_ring)
 	 * run the check_tx_hang logic with a transmit completion
 	 * pending but without time to complete it yet.
 	 */
-	if ((tx_ring->tx_stats.tx_done_old == tx_ring->stats.packets) &&
-	    (tx_pending >= I40E_MIN_DESC_PENDING)) {
+	if ((tx_done_old == tx_done) && tx_pending) {
 		/* make sure it is true for two checks in a row */
 		ret = test_and_set_bit(__I40E_HANG_CHECK_ARMED,
 				       &tx_ring->state);
-	} else if ((tx_ring->tx_stats.tx_done_old == tx_ring->stats.packets) &&
-		   (tx_pending < I40E_MIN_DESC_PENDING) &&
-		   (tx_pending > 0)) {
+	} else if (tx_done_old == tx_done &&
+		   (tx_pending < I40E_MIN_DESC_PENDING) && (tx_pending > 0)) {
 		if (I40E_DEBUG_FLOW & pf->hw.debug_mask)
 			dev_info(tx_ring->dev, "HW needs some more descs to do a cacheline flush. tx_pending %d, queue %d",
 				 tx_pending, tx_ring->queue_index);
 		pf->tx_sluggish_count++;
 	} else {
 		/* update completed stats and disarm the hang check */
-		tx_ring->tx_stats.tx_done_old = tx_ring->stats.packets;
+		tx_ring->tx_stats.tx_done_old = tx_done;
 		clear_bit(__I40E_HANG_CHECK_ARMED, &tx_ring->state);
 	}
 
 	return ret;
 }
 
-/**
- * i40e_get_head - Retrieve head from head writeback
- * @tx_ring:  tx ring to fetch head of
- *
- * Returns value of Tx ring head based on value stored
- * in head write-back location
- **/
-static inline u32 i40e_get_head(struct i40e_ring *tx_ring)
-{
-	void *head = (struct i40e_tx_desc *)tx_ring->desc + tx_ring->count;
-
-	return le32_to_cpu(*(volatile __le32 *)head);
-}
-
 #define WB_STRIDE 0x3
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 1320a43..be05829 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -126,6 +126,20 @@ void i40evf_free_tx_resources(struct i40e_ring *tx_ring)
 }
 
 /**
+ * i40e_get_head - Retrieve head from head writeback
+ * @tx_ring:  tx ring to fetch head of
+ *
+ * Returns value of Tx ring head based on value stored
+ * in head write-back location
+ **/
+static inline u32 i40e_get_head(struct i40e_ring *tx_ring)
+{
+	void *head = (struct i40e_tx_desc *)tx_ring->desc + tx_ring->count;
+
+	return le32_to_cpu(*(volatile __le32 *)head);
+}
+
+/**
  * i40e_get_tx_pending - how many tx descriptors not processed
  * @tx_ring: the ring of descriptors
  *
@@ -134,10 +148,16 @@ void i40evf_free_tx_resources(struct i40e_ring *tx_ring)
  **/
 static u32 i40e_get_tx_pending(struct i40e_ring *ring)
 {
-	u32 ntu = ((ring->next_to_clean <= ring->next_to_use)
-			? ring->next_to_use
-			: ring->next_to_use + ring->count);
-	return ntu - ring->next_to_clean;
+	u32 head, tail;
+
+	head = i40e_get_head(ring);
+	tail = readl(ring->tail);
+
+	if (head != tail)
+		return (head < tail) ?
+			tail - head : (tail + ring->count - head);
+
+	return 0;
 }
 
 /**
@@ -146,6 +166,8 @@ static u32 i40e_get_tx_pending(struct i40e_ring *ring)
  **/
 static bool i40e_check_tx_hang(struct i40e_ring *tx_ring)
 {
+	u32 tx_done = tx_ring->stats.packets;
+	u32 tx_done_old = tx_ring->tx_stats.tx_done_old;
 	u32 tx_pending = i40e_get_tx_pending(tx_ring);
 	bool ret = false;
 
@@ -162,36 +184,20 @@ static bool i40e_check_tx_hang(struct i40e_ring *tx_ring)
 	 * run the check_tx_hang logic with a transmit completion
 	 * pending but without time to complete it yet.
 	 */
-	if ((tx_ring->tx_stats.tx_done_old == tx_ring->stats.packets) &&
-	    (tx_pending >= I40E_MIN_DESC_PENDING)) {
+	if ((tx_done_old == tx_done) && tx_pending) {
 		/* make sure it is true for two checks in a row */
 		ret = test_and_set_bit(__I40E_HANG_CHECK_ARMED,
 				       &tx_ring->state);
-	} else if (!(tx_ring->tx_stats.tx_done_old == tx_ring->stats.packets) ||
-		   !(tx_pending < I40E_MIN_DESC_PENDING) ||
-		   !(tx_pending > 0)) {
+	} else if (tx_done_old == tx_done &&
+		   (tx_pending < I40E_MIN_DESC_PENDING) && (tx_pending > 0)) {
 		/* update completed stats and disarm the hang check */
-		tx_ring->tx_stats.tx_done_old = tx_ring->stats.packets;
+		tx_ring->tx_stats.tx_done_old = tx_done;
 		clear_bit(__I40E_HANG_CHECK_ARMED, &tx_ring->state);
 	}
 
 	return ret;
 }
 
-/**
- * i40e_get_head - Retrieve head from head writeback
- * @tx_ring:  tx ring to fetch head of
- *
- * Returns value of Tx ring head based on value stored
- * in head write-back location
- **/
-static inline u32 i40e_get_head(struct i40e_ring *tx_ring)
-{
-	void *head = (struct i40e_tx_desc *)tx_ring->desc + tx_ring->count;
-
-	return le32_to_cpu(*(volatile __le32 *)head);
-}
-
 #define WB_STRIDE 0x3
 
 /**
-- 
1.9.3
