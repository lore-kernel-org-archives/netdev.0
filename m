From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] i40e/i40evf: Add base address registers to aq struct
Date: Tue,  1 Jul 2014 04:34:58 -0700
Message-ID: <1404214511-26868-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7330 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756815AbaGALfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2014 07:35:15 -0400
In-Reply-To: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add the Base Address High and Low to the admin queue struct to simplify
another bit of "which context" logic in the config routines.

Change-ID: Iae195a7da3baffc1a9d522119e1e2b427068ad07
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 58 +++++++++----------------
 drivers/net/ethernet/intel/i40e/i40e_adminq.h   |  2 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 58 +++++++++----------------
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h |  2 +
 4 files changed, 44 insertions(+), 76 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 95aab70..87f1d8b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -55,16 +55,24 @@ static void i40e_adminq_init_regs(struct i40e_hw *hw)
 		hw->aq.asq.tail = I40E_VF_ATQT1;
 		hw->aq.asq.head = I40E_VF_ATQH1;
 		hw->aq.asq.len  = I40E_VF_ATQLEN1;
+		hw->aq.asq.bal  = I40E_VF_ATQBAL1;
+		hw->aq.asq.bah  = I40E_VF_ATQBAH1;
 		hw->aq.arq.tail = I40E_VF_ARQT1;
 		hw->aq.arq.head = I40E_VF_ARQH1;
 		hw->aq.arq.len  = I40E_VF_ARQLEN1;
+		hw->aq.arq.bal  = I40E_VF_ARQBAL1;
+		hw->aq.arq.bah  = I40E_VF_ARQBAH1;
 	} else {
 		hw->aq.asq.tail = I40E_PF_ATQT;
 		hw->aq.asq.head = I40E_PF_ATQH;
 		hw->aq.asq.len  = I40E_PF_ATQLEN;
+		hw->aq.asq.bal  = I40E_PF_ATQBAL;
+		hw->aq.asq.bah  = I40E_PF_ATQBAH;
 		hw->aq.arq.tail = I40E_PF_ARQT;
 		hw->aq.arq.head = I40E_PF_ARQH;
 		hw->aq.arq.len  = I40E_PF_ARQLEN;
+		hw->aq.arq.bal  = I40E_PF_ARQBAL;
+		hw->aq.arq.bah  = I40E_PF_ARQBAH;
 	}
 }
 
@@ -300,27 +308,14 @@ static i40e_status i40e_config_asq_regs(struct i40e_hw *hw)
 	wr32(hw, hw->aq.asq.head, 0);
 	wr32(hw, hw->aq.asq.tail, 0);
 
-	if (hw->mac.type == I40E_MAC_VF) {
-		/* configure the transmit queue */
-		wr32(hw, I40E_VF_ATQBAH1,
-		    upper_32_bits(hw->aq.asq.desc_buf.pa));
-		wr32(hw, I40E_VF_ATQBAL1,
-		    lower_32_bits(hw->aq.asq.desc_buf.pa));
-		wr32(hw, I40E_VF_ATQLEN1, (hw->aq.num_asq_entries |
-					  I40E_VF_ATQLEN1_ATQENABLE_MASK));
-		reg = rd32(hw, I40E_VF_ATQBAL1);
-	} else {
-		/* configure the transmit queue */
-		wr32(hw, I40E_PF_ATQBAH,
-		    upper_32_bits(hw->aq.asq.desc_buf.pa));
-		wr32(hw, I40E_PF_ATQBAL,
-		    lower_32_bits(hw->aq.asq.desc_buf.pa));
-		wr32(hw, I40E_PF_ATQLEN, (hw->aq.num_asq_entries |
-					  I40E_PF_ATQLEN_ATQENABLE_MASK));
-		reg = rd32(hw, I40E_PF_ATQBAL);
-	}
+	/* set starting point */
+	wr32(hw, hw->aq.asq.len, (hw->aq.num_asq_entries |
+				  I40E_PF_ATQLEN_ATQENABLE_MASK));
+	wr32(hw, hw->aq.asq.bal, lower_32_bits(hw->aq.asq.desc_buf.pa));
+	wr32(hw, hw->aq.asq.bah, upper_32_bits(hw->aq.asq.desc_buf.pa));
 
 	/* Check one register to verify that config was applied */
+	reg = rd32(hw, hw->aq.asq.bal);
 	if (reg != lower_32_bits(hw->aq.asq.desc_buf.pa))
 		ret_code = I40E_ERR_ADMIN_QUEUE_ERROR;
 
@@ -342,30 +337,17 @@ static i40e_status i40e_config_arq_regs(struct i40e_hw *hw)
 	wr32(hw, hw->aq.arq.head, 0);
 	wr32(hw, hw->aq.arq.tail, 0);
 
-	if (hw->mac.type == I40E_MAC_VF) {
-		/* configure the receive queue */
-		wr32(hw, I40E_VF_ARQBAH1,
-		    upper_32_bits(hw->aq.arq.desc_buf.pa));
-		wr32(hw, I40E_VF_ARQBAL1,
-		    lower_32_bits(hw->aq.arq.desc_buf.pa));
-		wr32(hw, I40E_VF_ARQLEN1, (hw->aq.num_arq_entries |
-					  I40E_VF_ARQLEN1_ARQENABLE_MASK));
-		reg = rd32(hw, I40E_VF_ARQBAL1);
-	} else {
-		/* configure the receive queue */
-		wr32(hw, I40E_PF_ARQBAH,
-		    upper_32_bits(hw->aq.arq.desc_buf.pa));
-		wr32(hw, I40E_PF_ARQBAL,
-		    lower_32_bits(hw->aq.arq.desc_buf.pa));
-		wr32(hw, I40E_PF_ARQLEN, (hw->aq.num_arq_entries |
-					  I40E_PF_ARQLEN_ARQENABLE_MASK));
-		reg = rd32(hw, I40E_PF_ARQBAL);
-	}
+	/* set starting point */
+	wr32(hw, hw->aq.arq.len, (hw->aq.num_arq_entries |
+				  I40E_PF_ARQLEN_ARQENABLE_MASK));
+	wr32(hw, hw->aq.arq.bal, lower_32_bits(hw->aq.arq.desc_buf.pa));
+	wr32(hw, hw->aq.arq.bah, upper_32_bits(hw->aq.arq.desc_buf.pa));
 
 	/* Update tail in the HW to post pre-allocated buffers */
 	wr32(hw, hw->aq.arq.tail, hw->aq.num_arq_entries - 1);
 
 	/* Check one register to verify that config was applied */
+	reg = rd32(hw, hw->aq.arq.bal);
 	if (reg != lower_32_bits(hw->aq.arq.desc_buf.pa))
 		ret_code = I40E_ERR_ADMIN_QUEUE_ERROR;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
index b1552fb..c6142ba 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
@@ -56,6 +56,8 @@ struct i40e_adminq_ring {
 	u32 head;
 	u32 tail;
 	u32 len;
+	u32 bah;
+	u32 bal;
 };
 
 /* ASQ transaction details */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index 15853fd..79a30dd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -53,16 +53,24 @@ static void i40e_adminq_init_regs(struct i40e_hw *hw)
 		hw->aq.asq.tail = I40E_VF_ATQT1;
 		hw->aq.asq.head = I40E_VF_ATQH1;
 		hw->aq.asq.len  = I40E_VF_ATQLEN1;
+		hw->aq.asq.bal  = I40E_VF_ATQBAL1;
+		hw->aq.asq.bah  = I40E_VF_ATQBAH1;
 		hw->aq.arq.tail = I40E_VF_ARQT1;
 		hw->aq.arq.head = I40E_VF_ARQH1;
 		hw->aq.arq.len  = I40E_VF_ARQLEN1;
+		hw->aq.arq.bal  = I40E_VF_ARQBAL1;
+		hw->aq.arq.bah  = I40E_VF_ARQBAH1;
 	} else {
 		hw->aq.asq.tail = I40E_PF_ATQT;
 		hw->aq.asq.head = I40E_PF_ATQH;
 		hw->aq.asq.len  = I40E_PF_ATQLEN;
+		hw->aq.asq.bal  = I40E_PF_ATQBAL;
+		hw->aq.asq.bah  = I40E_PF_ATQBAH;
 		hw->aq.arq.tail = I40E_PF_ARQT;
 		hw->aq.arq.head = I40E_PF_ARQH;
 		hw->aq.arq.len  = I40E_PF_ARQLEN;
+		hw->aq.arq.bal  = I40E_PF_ARQBAL;
+		hw->aq.arq.bah  = I40E_PF_ARQBAH;
 	}
 }
 
@@ -298,27 +306,14 @@ static i40e_status i40e_config_asq_regs(struct i40e_hw *hw)
 	wr32(hw, hw->aq.asq.head, 0);
 	wr32(hw, hw->aq.asq.tail, 0);
 
-	if (hw->mac.type == I40E_MAC_VF) {
-		/* configure the transmit queue */
-		wr32(hw, I40E_VF_ATQBAH1,
-		    upper_32_bits(hw->aq.asq.desc_buf.pa));
-		wr32(hw, I40E_VF_ATQBAL1,
-		    lower_32_bits(hw->aq.asq.desc_buf.pa));
-		wr32(hw, I40E_VF_ATQLEN1, (hw->aq.num_asq_entries |
-					  I40E_VF_ATQLEN1_ATQENABLE_MASK));
-		reg = rd32(hw, I40E_VF_ATQBAL1);
-	} else {
-		/* configure the transmit queue */
-		wr32(hw, I40E_PF_ATQBAH,
-		    upper_32_bits(hw->aq.asq.desc_buf.pa));
-		wr32(hw, I40E_PF_ATQBAL,
-		    lower_32_bits(hw->aq.asq.desc_buf.pa));
-		wr32(hw, I40E_PF_ATQLEN, (hw->aq.num_asq_entries |
-					  I40E_PF_ATQLEN_ATQENABLE_MASK));
-		reg = rd32(hw, I40E_PF_ATQBAL);
-	}
+	/* set starting point */
+	wr32(hw, hw->aq.asq.len, (hw->aq.num_asq_entries |
+				  I40E_PF_ATQLEN_ATQENABLE_MASK));
+	wr32(hw, hw->aq.asq.bal, lower_32_bits(hw->aq.asq.desc_buf.pa));
+	wr32(hw, hw->aq.asq.bah, upper_32_bits(hw->aq.asq.desc_buf.pa));
 
 	/* Check one register to verify that config was applied */
+	reg = rd32(hw, hw->aq.asq.bal);
 	if (reg != lower_32_bits(hw->aq.asq.desc_buf.pa))
 		ret_code = I40E_ERR_ADMIN_QUEUE_ERROR;
 
@@ -340,30 +335,17 @@ static i40e_status i40e_config_arq_regs(struct i40e_hw *hw)
 	wr32(hw, hw->aq.arq.head, 0);
 	wr32(hw, hw->aq.arq.tail, 0);
 
-	if (hw->mac.type == I40E_MAC_VF) {
-		/* configure the receive queue */
-		wr32(hw, I40E_VF_ARQBAH1,
-		    upper_32_bits(hw->aq.arq.desc_buf.pa));
-		wr32(hw, I40E_VF_ARQBAL1,
-		    lower_32_bits(hw->aq.arq.desc_buf.pa));
-		wr32(hw, I40E_VF_ARQLEN1, (hw->aq.num_arq_entries |
-					  I40E_VF_ARQLEN1_ARQENABLE_MASK));
-		reg = rd32(hw, I40E_VF_ARQBAL1);
-	} else {
-		/* configure the receive queue */
-		wr32(hw, I40E_PF_ARQBAH,
-		    upper_32_bits(hw->aq.arq.desc_buf.pa));
-		wr32(hw, I40E_PF_ARQBAL,
-		    lower_32_bits(hw->aq.arq.desc_buf.pa));
-		wr32(hw, I40E_PF_ARQLEN, (hw->aq.num_arq_entries |
-					  I40E_PF_ARQLEN_ARQENABLE_MASK));
-		reg = rd32(hw, I40E_PF_ARQBAL);
-	}
+	/* set starting point */
+	wr32(hw, hw->aq.arq.len, (hw->aq.num_arq_entries |
+				  I40E_PF_ARQLEN_ARQENABLE_MASK));
+	wr32(hw, hw->aq.arq.bal, lower_32_bits(hw->aq.arq.desc_buf.pa));
+	wr32(hw, hw->aq.arq.bah, upper_32_bits(hw->aq.arq.desc_buf.pa));
 
 	/* Update tail in the HW to post pre-allocated buffers */
 	wr32(hw, hw->aq.arq.tail, hw->aq.num_arq_entries - 1);
 
 	/* Check one register to verify that config was applied */
+	reg = rd32(hw, hw->aq.arq.bal);
 	if (reg != lower_32_bits(hw->aq.arq.desc_buf.pa))
 		ret_code = I40E_ERR_ADMIN_QUEUE_ERROR;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
index e3472c6..9335375 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
@@ -56,6 +56,8 @@ struct i40e_adminq_ring {
 	u32 head;
 	u32 tail;
 	u32 len;
+	u32 bah;
+	u32 bal;
 };
 
 /* ASQ transaction details */
-- 
1.9.3
