From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/13] i40e/i40evf: modify debug prints to avoid seg faults
Date: Fri, 20 Jun 2014 00:49:47 -0700
Message-ID: <1403250588-14356-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kamil Krawczyk <kamil.krawczyk@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62079 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934740AbaFTHuA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2014 03:50:00 -0400
In-Reply-To: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamil Krawczyk <kamil.krawczyk@intel.com>

Some AQ debug prints needs be moved around or do additional checks so they
will not cause our tool applications to cause segmentation faults.
The tools run in user space and we need to correctly reference kernel
space memory.

Change-ID: Ia2ac4076f576b805f350453fd50ad69c2a91ab9a
Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 15 +++++++++++----
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 15 +++++++++++----
 2 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 40381ab..95aab70 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -850,6 +850,7 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 	}
 
 	/* bump the tail */
+	i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE, "AQTX: desc and buffer:\n");
 	i40e_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc_on_ring, buff);
 	(hw->aq.asq.next_to_use)++;
 	if (hw->aq.asq.next_to_use == hw->aq.asq.count)
@@ -887,6 +888,7 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 				   I40E_DEBUG_AQ_MESSAGE,
 				   "AQTX: Command completed with error 0x%X.\n",
 				   retval);
+
 			/* strip off FW internal code */
 			retval &= 0xff;
 		}
@@ -901,6 +903,12 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 	if (i40e_is_nvm_update_op(desc))
 		hw->aq.nvm_busy = true;
 
+	if (le16_to_cpu(desc->datalen) == buff_size) {
+		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
+			   "AQTX: desc and buffer writeback:\n");
+		i40e_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, buff);
+	}
+
 	/* update the error if time out occurred */
 	if ((!cmd_completed) &&
 	    (!details->async && !details->postpone)) {
@@ -972,10 +980,6 @@ i40e_status i40e_clean_arq_element(struct i40e_hw *hw,
 	/* now clean the next descriptor */
 	desc = I40E_ADMINQ_DESC(hw->aq.arq, ntc);
 	desc_idx = ntc;
-	i40e_debug_aq(hw,
-		      I40E_DEBUG_AQ_COMMAND,
-		      (void *)desc,
-		      hw->aq.arq.r.arq_bi[desc_idx].va);
 
 	flags = le16_to_cpu(desc->flags);
 	if (flags & I40E_AQ_FLAG_ERR) {
@@ -998,6 +1002,9 @@ i40e_status i40e_clean_arq_element(struct i40e_hw *hw,
 	if (i40e_is_nvm_update_op(&e->desc))
 		hw->aq.nvm_busy = false;
 
+	i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE, "AQRX: desc and buffer:\n");
+	i40e_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, e->msg_buf);
+
 	/* Restore the original datalen and buffer address in the desc,
 	 * FW updates datalen to indicate the event message
 	 * size
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index 4a90a85..15853fd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -804,6 +804,7 @@ i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
 	}
 
 	/* bump the tail */
+	i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE, "AQTX: desc and buffer:\n");
 	i40evf_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc_on_ring, buff);
 	(hw->aq.asq.next_to_use)++;
 	if (hw->aq.asq.next_to_use == hw->aq.asq.count)
@@ -841,6 +842,7 @@ i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
 				   I40E_DEBUG_AQ_MESSAGE,
 				   "AQTX: Command completed with error 0x%X.\n",
 				   retval);
+
 			/* strip off FW internal code */
 			retval &= 0xff;
 		}
@@ -855,6 +857,12 @@ i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
 	if (i40e_is_nvm_update_op(desc))
 		hw->aq.nvm_busy = true;
 
+	if (le16_to_cpu(desc->datalen) == buff_size) {
+		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
+			   "AQTX: desc and buffer writeback:\n");
+		i40evf_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, buff);
+	}
+
 	/* update the error if time out occurred */
 	if ((!cmd_completed) &&
 	    (!details->async && !details->postpone)) {
@@ -926,10 +934,6 @@ i40e_status i40evf_clean_arq_element(struct i40e_hw *hw,
 	/* now clean the next descriptor */
 	desc = I40E_ADMINQ_DESC(hw->aq.arq, ntc);
 	desc_idx = ntc;
-	i40evf_debug_aq(hw,
-		      I40E_DEBUG_AQ_COMMAND,
-		      (void *)desc,
-		      hw->aq.arq.r.arq_bi[desc_idx].va);
 
 	flags = le16_to_cpu(desc->flags);
 	if (flags & I40E_AQ_FLAG_ERR) {
@@ -952,6 +956,9 @@ i40e_status i40evf_clean_arq_element(struct i40e_hw *hw,
 	if (i40e_is_nvm_update_op(&e->desc))
 		hw->aq.nvm_busy = false;
 
+	i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE, "AQRX: desc and buffer:\n");
+	i40evf_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, e->msg_buf);
+
 	/* Restore the original datalen and buffer address in the desc,
 	 * FW updates datalen to indicate the event message
 	 * size
-- 
1.9.3
