From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/5] i40e/i40evf: grab the AQ spinlocks before clearing registers
Date: Sat,  3 Oct 2015 19:54:42 -0700
Message-ID: <1443927283-18456-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443927283-18456-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19539 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098AbbJDCyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Oct 2015 22:54:46 -0400
In-Reply-To: <1443927283-18456-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Make sure we have the spinlocks before we clear the ARQ and ASQ management
registers.  Also, widen the locked portion and make a sanity check earlier
in the send function to be sure we're working with safe register values.

Change-ID: I34b56044b33461ed780f3d2de8d62826cdf933f9
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 45 +++++++++++++------------
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 45 +++++++++++++------------
 2 files changed, 46 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index e59ffb2..34a64e0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -482,8 +482,12 @@ static i40e_status i40e_shutdown_asq(struct i40e_hw *hw)
 {
 	i40e_status ret_code = 0;
 
-	if (hw->aq.asq.count == 0)
-		return I40E_ERR_NOT_READY;
+	mutex_lock(&hw->aq.asq_mutex);
+
+	if (hw->aq.asq.count == 0) {
+		ret_code = I40E_ERR_NOT_READY;
+		goto shutdown_asq_out;
+	}
 
 	/* Stop firmware AdminQ processing */
 	wr32(hw, hw->aq.asq.head, 0);
@@ -492,16 +496,13 @@ static i40e_status i40e_shutdown_asq(struct i40e_hw *hw)
 	wr32(hw, hw->aq.asq.bal, 0);
 	wr32(hw, hw->aq.asq.bah, 0);
 
-	/* make sure lock is available */
-	mutex_lock(&hw->aq.asq_mutex);
-
 	hw->aq.asq.count = 0; /* to indicate uninitialized queue */
 
 	/* free ring buffers */
 	i40e_free_asq_bufs(hw);
 
+shutdown_asq_out:
 	mutex_unlock(&hw->aq.asq_mutex);
-
 	return ret_code;
 }
 
@@ -515,8 +516,12 @@ static i40e_status i40e_shutdown_arq(struct i40e_hw *hw)
 {
 	i40e_status ret_code = 0;
 
-	if (hw->aq.arq.count == 0)
-		return I40E_ERR_NOT_READY;
+	mutex_lock(&hw->aq.arq_mutex);
+
+	if (hw->aq.arq.count == 0) {
+		ret_code = I40E_ERR_NOT_READY;
+		goto shutdown_arq_out;
+	}
 
 	/* Stop firmware AdminQ processing */
 	wr32(hw, hw->aq.arq.head, 0);
@@ -525,16 +530,13 @@ static i40e_status i40e_shutdown_arq(struct i40e_hw *hw)
 	wr32(hw, hw->aq.arq.bal, 0);
 	wr32(hw, hw->aq.arq.bah, 0);
 
-	/* make sure lock is available */
-	mutex_lock(&hw->aq.arq_mutex);
-
 	hw->aq.arq.count = 0; /* to indicate uninitialized queue */
 
 	/* free ring buffers */
 	i40e_free_arq_bufs(hw);
 
+shutdown_arq_out:
 	mutex_unlock(&hw->aq.arq_mutex);
-
 	return ret_code;
 }
 
@@ -745,19 +747,21 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 	u16  retval = 0;
 	u32  val = 0;
 
-	val = rd32(hw, hw->aq.asq.head);
-	if (val >= hw->aq.num_asq_entries) {
+	mutex_lock(&hw->aq.asq_mutex);
+
+	if (hw->aq.asq.count == 0) {
 		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
-			   "AQTX: head overrun at %d\n", val);
+			   "AQTX: Admin queue not initialized.\n");
 		status = I40E_ERR_QUEUE_EMPTY;
-		goto asq_send_command_exit;
+		goto asq_send_command_error;
 	}
 
-	if (hw->aq.asq.count == 0) {
+	val = rd32(hw, hw->aq.asq.head);
+	if (val >= hw->aq.num_asq_entries) {
 		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
-			   "AQTX: Admin queue not initialized.\n");
+			   "AQTX: head overrun at %d\n", val);
 		status = I40E_ERR_QUEUE_EMPTY;
-		goto asq_send_command_exit;
+		goto asq_send_command_error;
 	}
 
 	details = I40E_ADMINQ_DETAILS(hw->aq.asq, hw->aq.asq.next_to_use);
@@ -782,8 +786,6 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 	desc->flags &= ~cpu_to_le16(details->flags_dis);
 	desc->flags |= cpu_to_le16(details->flags_ena);
 
-	mutex_lock(&hw->aq.asq_mutex);
-
 	if (buff_size > hw->aq.asq_buf_size) {
 		i40e_debug(hw,
 			   I40E_DEBUG_AQ_MESSAGE,
@@ -907,7 +909,6 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 
 asq_send_command_error:
 	mutex_unlock(&hw->aq.asq_mutex);
-asq_send_command_exit:
 	return status;
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index 5026773..c7f59e0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -469,8 +469,12 @@ static i40e_status i40e_shutdown_asq(struct i40e_hw *hw)
 {
 	i40e_status ret_code = 0;
 
-	if (hw->aq.asq.count == 0)
-		return I40E_ERR_NOT_READY;
+	mutex_lock(&hw->aq.asq_mutex);
+
+	if (hw->aq.asq.count == 0) {
+		ret_code = I40E_ERR_NOT_READY;
+		goto shutdown_asq_out;
+	}
 
 	/* Stop firmware AdminQ processing */
 	wr32(hw, hw->aq.asq.head, 0);
@@ -479,16 +483,13 @@ static i40e_status i40e_shutdown_asq(struct i40e_hw *hw)
 	wr32(hw, hw->aq.asq.bal, 0);
 	wr32(hw, hw->aq.asq.bah, 0);
 
-	/* make sure lock is available */
-	mutex_lock(&hw->aq.asq_mutex);
-
 	hw->aq.asq.count = 0; /* to indicate uninitialized queue */
 
 	/* free ring buffers */
 	i40e_free_asq_bufs(hw);
 
+shutdown_asq_out:
 	mutex_unlock(&hw->aq.asq_mutex);
-
 	return ret_code;
 }
 
@@ -502,8 +503,12 @@ static i40e_status i40e_shutdown_arq(struct i40e_hw *hw)
 {
 	i40e_status ret_code = 0;
 
-	if (hw->aq.arq.count == 0)
-		return I40E_ERR_NOT_READY;
+	mutex_lock(&hw->aq.arq_mutex);
+
+	if (hw->aq.arq.count == 0) {
+		ret_code = I40E_ERR_NOT_READY;
+		goto shutdown_arq_out;
+	}
 
 	/* Stop firmware AdminQ processing */
 	wr32(hw, hw->aq.arq.head, 0);
@@ -512,16 +517,13 @@ static i40e_status i40e_shutdown_arq(struct i40e_hw *hw)
 	wr32(hw, hw->aq.arq.bal, 0);
 	wr32(hw, hw->aq.arq.bah, 0);
 
-	/* make sure lock is available */
-	mutex_lock(&hw->aq.arq_mutex);
-
 	hw->aq.arq.count = 0; /* to indicate uninitialized queue */
 
 	/* free ring buffers */
 	i40e_free_arq_bufs(hw);
 
+shutdown_arq_out:
 	mutex_unlock(&hw->aq.arq_mutex);
-
 	return ret_code;
 }
 
@@ -685,19 +687,21 @@ i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
 	u16  retval = 0;
 	u32  val = 0;
 
-	val = rd32(hw, hw->aq.asq.head);
-	if (val >= hw->aq.num_asq_entries) {
+	mutex_lock(&hw->aq.asq_mutex);
+
+	if (hw->aq.asq.count == 0) {
 		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
-			   "AQTX: head overrun at %d\n", val);
+			   "AQTX: Admin queue not initialized.\n");
 		status = I40E_ERR_QUEUE_EMPTY;
-		goto asq_send_command_exit;
+		goto asq_send_command_error;
 	}
 
-	if (hw->aq.asq.count == 0) {
+	val = rd32(hw, hw->aq.asq.head);
+	if (val >= hw->aq.num_asq_entries) {
 		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
-			   "AQTX: Admin queue not initialized.\n");
+			   "AQTX: head overrun at %d\n", val);
 		status = I40E_ERR_QUEUE_EMPTY;
-		goto asq_send_command_exit;
+		goto asq_send_command_error;
 	}
 
 	details = I40E_ADMINQ_DETAILS(hw->aq.asq, hw->aq.asq.next_to_use);
@@ -722,8 +726,6 @@ i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
 	desc->flags &= ~cpu_to_le16(details->flags_dis);
 	desc->flags |= cpu_to_le16(details->flags_ena);
 
-	mutex_lock(&hw->aq.asq_mutex);
-
 	if (buff_size > hw->aq.asq_buf_size) {
 		i40e_debug(hw,
 			   I40E_DEBUG_AQ_MESSAGE,
@@ -848,7 +850,6 @@ i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
 
 asq_send_command_error:
 	mutex_unlock(&hw->aq.asq_mutex);
-asq_send_command_exit:
 	return status;
 }
 
-- 
2.4.3
