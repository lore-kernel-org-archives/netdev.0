From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: simplify aq head-tail-len setups
Date: Fri,  6 Dec 2013 00:06:17 -0800
Message-ID: <1386317188-13944-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42215 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624Ab3LFIGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 03:06:34 -0500
In-Reply-To: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Use more virtual registers to simplify code flows.

Change-Id: I32cff3818c5ca3a3792487ba4fed8f1d0ea6145a
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c | 50 ++++++++-------------------
 drivers/net/ethernet/intel/i40e/i40e_adminq.h |  1 +
 2 files changed, 15 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 2bf73dd..92c01ad 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -43,13 +43,17 @@ static void i40e_adminq_init_regs(struct i40e_hw *hw)
 	if (hw->mac.type == I40E_MAC_VF) {
 		hw->aq.asq.tail = I40E_VF_ATQT1;
 		hw->aq.asq.head = I40E_VF_ATQH1;
+		hw->aq.asq.len  = I40E_VF_ATQLEN1;
 		hw->aq.arq.tail = I40E_VF_ARQT1;
 		hw->aq.arq.head = I40E_VF_ARQH1;
+		hw->aq.arq.len  = I40E_VF_ARQLEN1;
 	} else {
 		hw->aq.asq.tail = I40E_PF_ATQT;
 		hw->aq.asq.head = I40E_PF_ATQH;
+		hw->aq.asq.len  = I40E_PF_ATQLEN;
 		hw->aq.arq.tail = I40E_PF_ARQT;
 		hw->aq.arq.head = I40E_PF_ARQH;
+		hw->aq.arq.len  = I40E_PF_ARQLEN;
 	}
 }
 
@@ -466,15 +470,9 @@ static i40e_status i40e_shutdown_asq(struct i40e_hw *hw)
 		return I40E_ERR_NOT_READY;
 
 	/* Stop firmware AdminQ processing */
-	if (hw->mac.type == I40E_MAC_VF) {
-		wr32(hw, I40E_VF_ATQLEN1, 0);
-		wr32(hw, I40E_VF_ATQH1, 0);
-		wr32(hw, I40E_VF_ATQT1, 0);
-	} else {
-		wr32(hw, I40E_PF_ATQLEN, 0);
-		wr32(hw, I40E_PF_ATQH, 0);
-		wr32(hw, I40E_PF_ATQT, 0);
-	}
+	wr32(hw, hw->aq.asq.head, 0);
+	wr32(hw, hw->aq.asq.tail, 0);
+	wr32(hw, hw->aq.asq.len, 0);
 
 	/* make sure lock is available */
 	mutex_lock(&hw->aq.asq_mutex);
@@ -505,15 +503,9 @@ static i40e_status i40e_shutdown_arq(struct i40e_hw *hw)
 		return I40E_ERR_NOT_READY;
 
 	/* Stop firmware AdminQ processing */
-	if (hw->mac.type == I40E_MAC_VF) {
-		wr32(hw, I40E_VF_ARQLEN1, 0);
-		wr32(hw, I40E_VF_ARQH1, 0);
-		wr32(hw, I40E_VF_ARQT1, 0);
-	} else {
-		wr32(hw, I40E_PF_ARQLEN, 0);
-		wr32(hw, I40E_PF_ARQH, 0);
-		wr32(hw, I40E_PF_ARQT, 0);
-	}
+	wr32(hw, hw->aq.arq.head, 0);
+	wr32(hw, hw->aq.arq.tail, 0);
+	wr32(hw, hw->aq.arq.len, 0);
 
 	/* make sure lock is available */
 	mutex_lock(&hw->aq.arq_mutex);
@@ -966,27 +958,13 @@ void i40e_resume_aq(struct i40e_hw *hw)
 	hw->aq.asq.next_to_clean = 0;
 
 	i40e_config_asq_regs(hw);
-	reg = hw->aq.num_asq_entries;
-
-	if (hw->mac.type == I40E_MAC_VF) {
-		reg |= I40E_VF_ATQLEN_ATQENABLE_MASK;
-		wr32(hw, I40E_VF_ATQLEN1, reg);
-	} else {
-		reg |= I40E_PF_ATQLEN_ATQENABLE_MASK;
-		wr32(hw, I40E_PF_ATQLEN, reg);
-	}
+	reg = hw->aq.num_asq_entries | I40E_PF_ATQLEN_ATQENABLE_MASK;
+	wr32(hw, hw->aq.asq.len, reg);
 
 	hw->aq.arq.next_to_use = 0;
 	hw->aq.arq.next_to_clean = 0;
 
 	i40e_config_arq_regs(hw);
-	reg = hw->aq.num_arq_entries;
-
-	if (hw->mac.type == I40E_MAC_VF) {
-		reg |= I40E_VF_ATQLEN_ATQENABLE_MASK;
-		wr32(hw, I40E_VF_ARQLEN1, reg);
-	} else {
-		reg |= I40E_PF_ATQLEN_ATQENABLE_MASK;
-		wr32(hw, I40E_PF_ARQLEN, reg);
-	}
+	reg = hw->aq.num_arq_entries | I40E_PF_ATQLEN_ATQENABLE_MASK;
+	wr32(hw, hw->aq.arq.len, reg);
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
index 22e5ed6..f8c2c44 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
@@ -56,6 +56,7 @@ struct i40e_adminq_ring {
 	/* used for queue tracking */
 	u32 head;
 	u32 tail;
+	u32 len;
 };
 
 /* ASQ transaction details */
-- 
1.8.3.1
