From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/13] i40e/i40evf: Reset Head and Tail on AQ initialization
Date: Fri, 20 Jun 2014 00:49:38 -0700
Message-ID: <1403250588-14356-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Michal Kosiarz <michal.kosiarz@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62062 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752794AbaFTHtz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2014 03:49:55 -0400
In-Reply-To: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kosiarz <michal.kosiarz@intel.com>

Reset head and tail on admin queue initialization where H/T are
not reset by HW.

Change-ID: I6db8a2dd3f05ce66410a92cce016191add04760e
Signed-off-by: Michal Kosiarz <michal.kosiarz@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 21 +++++++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 21 +++++++++++++++++++++
 2 files changed, 42 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 7a02749..40381ab 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -296,6 +296,10 @@ static i40e_status i40e_config_asq_regs(struct i40e_hw *hw)
 	i40e_status ret_code = 0;
 	u32 reg = 0;
 
+	/* Clear Head and Tail */
+	wr32(hw, hw->aq.asq.head, 0);
+	wr32(hw, hw->aq.asq.tail, 0);
+
 	if (hw->mac.type == I40E_MAC_VF) {
 		/* configure the transmit queue */
 		wr32(hw, I40E_VF_ATQBAH1,
@@ -334,6 +338,10 @@ static i40e_status i40e_config_arq_regs(struct i40e_hw *hw)
 	i40e_status ret_code = 0;
 	u32 reg = 0;
 
+	/* Clear Head and Tail */
+	wr32(hw, hw->aq.arq.head, 0);
+	wr32(hw, hw->aq.arq.tail, 0);
+
 	if (hw->mac.type == I40E_MAC_VF) {
 		/* configure the receive queue */
 		wr32(hw, I40E_VF_ARQBAH1,
@@ -677,6 +685,10 @@ static u16 i40e_clean_asq(struct i40e_hw *hw)
 	desc = I40E_ADMINQ_DESC(*asq, ntc);
 	details = I40E_ADMINQ_DETAILS(*asq, ntc);
 	while (rd32(hw, hw->aq.asq.head) != ntc) {
+		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
+			   "%s: ntc %d head %d.\n", __func__, ntc,
+			   rd32(hw, hw->aq.asq.head));
+
 		if (details->callback) {
 			I40E_ADMINQ_CALLBACK cb_func =
 					(I40E_ADMINQ_CALLBACK)details->callback;
@@ -736,6 +748,15 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 	struct i40e_aq_desc *desc_on_ring;
 	bool cmd_completed = false;
 	u16  retval = 0;
+	u32  val = 0;
+
+	val = rd32(hw, hw->aq.asq.head);
+	if (val >= hw->aq.num_asq_entries) {
+		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
+			   "AQTX: head overrun at %d\n", val);
+		status = I40E_ERR_QUEUE_EMPTY;
+		goto asq_send_command_exit;
+	}
 
 	if (hw->aq.asq.count == 0) {
 		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index eb67cce..4a90a85 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -294,6 +294,10 @@ static i40e_status i40e_config_asq_regs(struct i40e_hw *hw)
 	i40e_status ret_code = 0;
 	u32 reg = 0;
 
+	/* Clear Head and Tail */
+	wr32(hw, hw->aq.asq.head, 0);
+	wr32(hw, hw->aq.asq.tail, 0);
+
 	if (hw->mac.type == I40E_MAC_VF) {
 		/* configure the transmit queue */
 		wr32(hw, I40E_VF_ATQBAH1,
@@ -332,6 +336,10 @@ static i40e_status i40e_config_arq_regs(struct i40e_hw *hw)
 	i40e_status ret_code = 0;
 	u32 reg = 0;
 
+	/* Clear Head and Tail */
+	wr32(hw, hw->aq.arq.head, 0);
+	wr32(hw, hw->aq.arq.tail, 0);
+
 	if (hw->mac.type == I40E_MAC_VF) {
 		/* configure the receive queue */
 		wr32(hw, I40E_VF_ARQBAH1,
@@ -630,6 +638,10 @@ static u16 i40e_clean_asq(struct i40e_hw *hw)
 	desc = I40E_ADMINQ_DESC(*asq, ntc);
 	details = I40E_ADMINQ_DETAILS(*asq, ntc);
 	while (rd32(hw, hw->aq.asq.head) != ntc) {
+		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
+			   "%s: ntc %d head %d.\n", __func__, ntc,
+			   rd32(hw, hw->aq.asq.head));
+
 		if (details->callback) {
 			I40E_ADMINQ_CALLBACK cb_func =
 					(I40E_ADMINQ_CALLBACK)details->callback;
@@ -690,6 +702,15 @@ i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
 	struct i40e_aq_desc *desc_on_ring;
 	bool cmd_completed = false;
 	u16  retval = 0;
+	u32  val = 0;
+
+	val = rd32(hw, hw->aq.asq.head);
+	if (val >= hw->aq.num_asq_entries) {
+		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
+			   "AQTX: head overrun at %d\n", val);
+		status = I40E_ERR_QUEUE_EMPTY;
+		goto asq_send_command_exit;
+	}
 
 	if (hw->aq.asq.count == 0) {
 		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
-- 
1.9.3
