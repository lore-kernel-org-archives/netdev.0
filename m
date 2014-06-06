From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] i40e/i40evf: add Tx pre queue disable function
Date: Fri,  6 Jun 2014 02:04:15 -0700
Message-ID: <1402045462-10304-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matt Jared <matthew.a.jared@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47817 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134AbaFFJE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2014 05:04:56 -0400
In-Reply-To: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Jared <matthew.a.jared@intel.com>

Add a function which indicates our intention to enable or disable a particular
Tx queue. Also add a function to notify the device's Tx unit that we're about
to enable or disable a Tx queue.

Change-ID: I6adf3cbb5bb3e3c984d1ec969e06577c19ef296d
Signed-off-by: Matt Jared <matthew.a.jared@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c     | 31 +++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c       |  6 +++++
 drivers/net/ethernet/intel/i40e/i40e_prototype.h  |  1 +
 drivers/net/ethernet/intel/i40e/i40e_register.h   |  8 ++++++
 drivers/net/ethernet/intel/i40evf/i40e_register.h |  8 ++++++
 5 files changed, 54 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index a31e3d7..36607b0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -657,6 +657,37 @@ i40e_status i40e_get_mac_addr(struct i40e_hw *hw, u8 *mac_addr)
 }
 
 /**
+ * i40e_pre_tx_queue_cfg - pre tx queue configure
+ * @hw: pointer to the HW structure
+ * @queue: target pf queue index
+ * @enable: state change request
+ *
+ * Handles hw requirement to indicate intention to enable
+ * or disable target queue.
+ **/
+void i40e_pre_tx_queue_cfg(struct i40e_hw *hw, u32 queue, bool enable)
+{
+	u32 reg_val = rd32(hw, I40E_PFLAN_QALLOC);
+	u32 first_queue = (reg_val & I40E_PFLAN_QALLOC_FIRSTQ_MASK);
+	u32 abs_queue_idx = first_queue + queue;
+	u32 reg_block = 0;
+
+	if (abs_queue_idx >= 128)
+		reg_block = abs_queue_idx / 128;
+
+	reg_val = rd32(hw, I40E_GLLAN_TXPRE_QDIS(reg_block));
+	reg_val &= ~I40E_GLLAN_TXPRE_QDIS_QINDX_MASK;
+	reg_val |= (abs_queue_idx << I40E_GLLAN_TXPRE_QDIS_QINDX_SHIFT);
+
+	if (enable)
+		reg_val |= I40E_GLLAN_TXPRE_QDIS_CLEAR_QDIS_MASK;
+	else
+		reg_val |= I40E_GLLAN_TXPRE_QDIS_SET_QDIS_MASK;
+
+	wr32(hw, I40E_GLLAN_TXPRE_QDIS(reg_block), reg_val);
+}
+
+/**
  * i40e_get_media_type - Gets media type
  * @hw: pointer to the hardware structure
  **/
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 105d754..726eceb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3183,6 +3183,12 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 
 	pf_q = vsi->base_queue;
 	for (i = 0; i < vsi->num_queue_pairs; i++, pf_q++) {
+
+		/* warn the TX unit of coming changes */
+		i40e_pre_tx_queue_cfg(&pf->hw, pf_q, enable);
+		if (!enable)
+			udelay(10);
+
 		for (j = 0; j < 50; j++) {
 			tx_reg = rd32(hw, I40E_QTX_ENA(pf_q));
 			if (((tx_reg >> I40E_QTX_ENA_QENA_REQ_SHIFT) & 1) ==
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 57172f9..58c4e1e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -221,6 +221,7 @@ bool i40e_get_link_status(struct i40e_hw *hw);
 i40e_status i40e_get_mac_addr(struct i40e_hw *hw,
 						u8 *mac_addr);
 i40e_status i40e_validate_mac_addr(u8 *mac_addr);
+void i40e_pre_tx_queue_cfg(struct i40e_hw *hw, u32 queue, bool enable);
 /* prototype for functions used for NVM access */
 i40e_status i40e_init_nvm(struct i40e_hw *hw);
 i40e_status i40e_acquire_nvm(struct i40e_hw *hw,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_register.h b/drivers/net/ethernet/intel/i40e/i40e_register.h
index 25c9286..947de98 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_register.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_register.h
@@ -1585,6 +1585,14 @@
 #define I40E_GLLAN_TSOMSK_M 0x000442DC
 #define I40E_GLLAN_TSOMSK_M_TCPMSKM_SHIFT 0
 #define I40E_GLLAN_TSOMSK_M_TCPMSKM_MASK (0xFFF << I40E_GLLAN_TSOMSK_M_TCPMSKM_SHIFT)
+#define I40E_GLLAN_TXPRE_QDIS(_i) (0x000E6500 + ((_i) * 4)) /* i=0..11 */
+#define I40E_GLLAN_TXPRE_QDIS_QINDX_SHIFT 0
+#define I40E_GLLAN_TXPRE_QDIS_QINDX_MASK (0x7FF << I40E_GLLAN_TXPRE_QDIS_QINDX_SHIFT)
+#define I40E_GLLAN_TXPRE_QDIS_SET_QDIS_SHIFT 30
+#define I40E_GLLAN_TXPRE_QDIS_SET_QDIS_MASK (0x1 << I40E_GLLAN_TXPRE_QDIS_SET_QDIS_SHIFT)
+#define I40E_GLLAN_TXPRE_QDIS_CLEAR_QDIS_SHIFT 31
+#define I40E_GLLAN_TXPRE_QDIS_CLEAR_QDIS_MASK (0x1 << I40E_GLLAN_TXPRE_QDIS_CLEAR_QDIS_SHIFT)
+
 #define I40E_PFLAN_QALLOC 0x001C0400
 #define I40E_PFLAN_QALLOC_FIRSTQ_SHIFT 0
 #define I40E_PFLAN_QALLOC_FIRSTQ_MASK (0x7FF << I40E_PFLAN_QALLOC_FIRSTQ_SHIFT)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_register.h b/drivers/net/ethernet/intel/i40evf/i40e_register.h
index 7977205..3698396 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_register.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_register.h
@@ -1585,6 +1585,14 @@
 #define I40E_GLLAN_TSOMSK_M 0x000442DC
 #define I40E_GLLAN_TSOMSK_M_TCPMSKM_SHIFT 0
 #define I40E_GLLAN_TSOMSK_M_TCPMSKM_MASK (0xFFF << I40E_GLLAN_TSOMSK_M_TCPMSKM_SHIFT)
+#define I40E_GLLAN_TXPRE_QDIS(_i) (0x000E6500 + ((_i) * 4)) /* i=0..11 */
+#define I40E_GLLAN_TXPRE_QDIS_QINDX_SHIFT 0
+#define I40E_GLLAN_TXPRE_QDIS_QINDX_MASK (0x7FF << I40E_GLLAN_TXPRE_QDIS_QINDX_SHIFT)
+#define I40E_GLLAN_TXPRE_QDIS_SET_QDIS_SHIFT 30
+#define I40E_GLLAN_TXPRE_QDIS_SET_QDIS_MASK (0x1 << I40E_GLLAN_TXPRE_QDIS_SET_QDIS_SHIFT)
+#define I40E_GLLAN_TXPRE_QDIS_CLEAR_QDIS_SHIFT 31
+#define I40E_GLLAN_TXPRE_QDIS_CLEAR_QDIS_MASK (0x1 << I40E_GLLAN_TXPRE_QDIS_CLEAR_QDIS_SHIFT)
+
 #define I40E_PFLAN_QALLOC 0x001C0400
 #define I40E_PFLAN_QALLOC_FIRSTQ_SHIFT 0
 #define I40E_PFLAN_QALLOC_FIRSTQ_MASK (0x7FF << I40E_PFLAN_QALLOC_FIRSTQ_SHIFT)
-- 
1.9.3
