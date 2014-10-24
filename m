From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] i40e: mask phy events
Date: Thu, 23 Oct 2014 21:09:58 -0700
Message-ID: <1414123806-20049-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:57054 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751473AbaJXEKP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2014 00:10:15 -0400
In-Reply-To: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Tell the firmware what kind of link related events the driver is
interested in.  In this case, just link up/down and qualified module
events are the ones the driver really cares about.

Change-ID: If132c812c340c8e1927c2caf6d55185296b66201
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 27 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c      | 18 ++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  2 ++
 3 files changed, 47 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 30056b2..c23e377 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1420,6 +1420,33 @@ i40e_status i40e_update_link_info(struct i40e_hw *hw, bool enable_lse)
 }
 
 /**
+ * i40e_aq_set_phy_int_mask
+ * @hw: pointer to the hw struct
+ * @mask: interrupt mask to be set
+ * @cmd_details: pointer to command details structure or NULL
+ *
+ * Set link interrupt mask.
+ **/
+i40e_status i40e_aq_set_phy_int_mask(struct i40e_hw *hw,
+				     u16 mask,
+				     struct i40e_asq_cmd_details *cmd_details)
+{
+	struct i40e_aq_desc desc;
+	struct i40e_aqc_set_phy_int_mask *cmd =
+		(struct i40e_aqc_set_phy_int_mask *)&desc.params.raw;
+	i40e_status status;
+
+	i40e_fill_default_direct_cmd_desc(&desc,
+					  i40e_aqc_opc_set_phy_int_mask);
+
+	cmd->event_mask = cpu_to_le16(mask);
+
+	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
+
+	return status;
+}
+
+/**
  * i40e_aq_add_vsi
  * @hw: pointer to the hw struct
  * @vsi_ctx: pointer to a vsi context struct
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ed5f1c1..8cb6469 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6038,6 +6038,15 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	if (ret)
 		goto end_core_reset;
 
+	/* driver is only interested in link up/down and module qualification
+	 * reports from firmware
+	 */
+	ret = i40e_aq_set_phy_int_mask(&pf->hw,
+				       I40E_AQ_EVENT_LINK_UPDOWN |
+				       I40E_AQ_EVENT_MODULE_QUAL_FAIL, NULL);
+	if (ret)
+		dev_info(&pf->pdev->dev, "set phy mask fail, aq_err %d\n", ret);
+
 	/* Rebuild the VSIs and VEBs that existed before reset.
 	 * They are still in our local switch element arrays, so only
 	 * need to rebuild the switch model in the HW.
@@ -9158,6 +9167,15 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 	}
 
+	/* driver is only interested in link up/down and module qualification
+	 * reports from firmware
+	 */
+	err = i40e_aq_set_phy_int_mask(&pf->hw,
+				       I40E_AQ_EVENT_LINK_UPDOWN |
+				       I40E_AQ_EVENT_MODULE_QUAL_FAIL, NULL);
+	if (err)
+		dev_info(&pf->pdev->dev, "set phy mask fail, aq_err %d\n", err);
+
 	/* The main driver is (mostly) up and happy. We need to set this state
 	 * before setting up the misc vector or we get a race and the vector
 	 * ends up disabled forever.
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 0988b5c..246c278 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -84,6 +84,8 @@ enum i40e_status_code i40e_aq_set_phy_config(struct i40e_hw *hw,
 				struct i40e_asq_cmd_details *cmd_details);
 enum i40e_status_code i40e_set_fc(struct i40e_hw *hw, u8 *aq_failures,
 				  bool atomic_reset);
+i40e_status i40e_aq_set_phy_int_mask(struct i40e_hw *hw, u16 mask,
+				     struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_clear_pxe_mode(struct i40e_hw *hw,
 				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_link_restart_an(struct i40e_hw *hw,
-- 
1.9.3
