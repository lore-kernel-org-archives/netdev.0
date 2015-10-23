From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/17] i40e/i40evf: Add a workaround to drop all flow control frames
Date: Fri, 23 Oct 2015 06:17:43 -0700
Message-ID: <1445606279-19345-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61352 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751802AbbJWNSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 09:18:17 -0400
In-Reply-To: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This patch adds a workaround to drop any flow control frames from being
transmitted from any VSI. FW can still send flow control frames if flow
control is enabled.

With this patch in place a malicious VF cannot send flow control or PFC
packets out on the wire.

Change-ID: I4303b24e98b93066d2767fec24dfe78be591c277
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 22 ++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 18 ++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  2 ++
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |  2 ++
 4 files changed, 44 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index c51f2fb..5d533d1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -3829,6 +3829,28 @@ i40e_status i40e_aq_add_rem_control_packet_filter(struct i40e_hw *hw,
 }
 
 /**
+ * i40e_add_filter_to_drop_tx_flow_control_frames- filter to drop flow control
+ * @hw: pointer to the hw struct
+ * @seid: VSI seid to add ethertype filter from
+ **/
+#define I40E_FLOW_CONTROL_ETHTYPE 0x8808
+void i40e_add_filter_to_drop_tx_flow_control_frames(struct i40e_hw *hw,
+						    u16 seid)
+{
+	u16 flag = I40E_AQC_ADD_CONTROL_PACKET_FLAGS_IGNORE_MAC |
+		   I40E_AQC_ADD_CONTROL_PACKET_FLAGS_DROP |
+		   I40E_AQC_ADD_CONTROL_PACKET_FLAGS_TX;
+	u16 ethtype = I40E_FLOW_CONTROL_ETHTYPE;
+	i40e_status status;
+
+	status = i40e_aq_add_rem_control_packet_filter(hw, NULL, ethtype, flag,
+						       seid, 0, true, NULL,
+						       NULL);
+	if (status)
+		hw_dbg(hw, "Ethtype Filter Add failed: Error pruning Tx flow control frames\n");
+}
+
+/**
  * i40e_aq_alternate_read
  * @hw: pointer to the hardware structure
  * @reg_addr0: address of first dword to be read
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index cc8c0ae..d05254c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6837,6 +6837,15 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	if (pf->flags & I40E_FLAG_MSIX_ENABLED)
 		ret = i40e_setup_misc_vector(pf);
 
+	/* Add a filter to drop all Flow control frames from any VSI from being
+	 * transmitted. By doing so we stop a malicious VF from sending out
+	 * PAUSE or PFC frames and potentially controlling traffic for other
+	 * PF/VF VSIs.
+	 * The FW can still send Flow control frames if enabled.
+	 */
+	i40e_add_filter_to_drop_tx_flow_control_frames(&pf->hw,
+						       pf->main_vsi_seid);
+
 	/* restart the VSIs that were rebuilt and running before the reset */
 	i40e_pf_unquiesce_all_vsi(pf);
 
@@ -10585,6 +10594,15 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
 	pf->hw.phy.phy_types = le32_to_cpu(abilities.phy_type);
 
+	/* Add a filter to drop all Flow control frames from any VSI from being
+	 * transmitted. By doing so we stop a malicious VF from sending out
+	 * PAUSE or PFC frames and potentially controlling traffic for other
+	 * PF/VF VSIs.
+	 * The FW can still send Flow control frames if enabled.
+	 */
+	i40e_add_filter_to_drop_tx_flow_control_frames(&pf->hw,
+						       pf->main_vsi_seid);
+
 	/* print a string summarizing features */
 	i40e_print_features(pf);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 10bf2ba..bb9d583 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -322,4 +322,6 @@ i40e_status i40e_aq_debug_dump(struct i40e_hw *hw, u8 cluster_id,
 			       void *buff, u16 *ret_buff_size,
 			       u8 *ret_next_table, u32 *ret_next_index,
 			       struct i40e_asq_cmd_details *cmd_details);
+void i40e_add_filter_to_drop_tx_flow_control_frames(struct i40e_hw *hw,
+						    u16 vsi_seid);
 #endif /* _I40E_PROTOTYPE_H_ */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
index 8ed0edf..cbd9a1b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
@@ -101,4 +101,6 @@ i40e_status i40e_aq_add_rem_control_packet_filter(struct i40e_hw *hw,
 				u16 vsi_seid, u16 queue, bool is_add,
 				struct i40e_control_filter_stats *stats,
 				struct i40e_asq_cmd_details *cmd_details);
+void i40e_add_filter_to_drop_tx_flow_control_frames(struct i40e_hw *hw,
+						    u16 vsi_seid);
 #endif /* _I40E_PROTOTYPE_H_ */
-- 
2.4.3
