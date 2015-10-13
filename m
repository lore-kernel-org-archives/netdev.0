From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/17] i40e: Add promiscuous on VLAN support
Date: Mon, 12 Oct 2015 22:53:12 -0700
Message-ID: <1444715598-20970-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47881 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752121AbbJMFx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 01:53:28 -0400
In-Reply-To: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

NFV use cases require the ability to steer packets to VSIs by VLAN tag
alone while being in promiscuous mode for multicast and unicast MAC
addresses.  These two new functions support that ability.

Change-ID: Ifef704b07e0ee8a39d3c351dbd5dc83bb2f63c45
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 68 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  6 +++
 2 files changed, 74 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 2d012d9..d9519ce 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2013,6 +2013,74 @@ i40e_status i40e_aq_set_vsi_multicast_promiscuous(struct i40e_hw *hw,
 }
 
 /**
+ * i40e_aq_set_vsi_mc_promisc_on_vlan
+ * @hw: pointer to the hw struct
+ * @seid: vsi number
+ * @enable: set MAC L2 layer unicast promiscuous enable/disable for a given VLAN
+ * @vid: The VLAN tag filter - capture any multicast packet with this VLAN tag
+ * @cmd_details: pointer to command details structure or NULL
+ **/
+i40e_status i40e_aq_set_vsi_mc_promisc_on_vlan(struct i40e_hw *hw,
+				u16 seid, bool enable, u16 vid,
+				struct i40e_asq_cmd_details *cmd_details)
+{
+	struct i40e_aq_desc desc;
+	struct i40e_aqc_set_vsi_promiscuous_modes *cmd =
+		(struct i40e_aqc_set_vsi_promiscuous_modes *)&desc.params.raw;
+	i40e_status status;
+	u16 flags = 0;
+
+	i40e_fill_default_direct_cmd_desc(&desc,
+					i40e_aqc_opc_set_vsi_promiscuous_modes);
+
+	if (enable)
+		flags |= I40E_AQC_SET_VSI_PROMISC_MULTICAST;
+
+	cmd->promiscuous_flags = cpu_to_le16(flags);
+	cmd->valid_flags = cpu_to_le16(I40E_AQC_SET_VSI_PROMISC_MULTICAST);
+	cmd->seid = cpu_to_le16(seid);
+	cmd->vlan_tag = cpu_to_le16(vid | I40E_AQC_SET_VSI_VLAN_VALID);
+
+	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
+
+	return status;
+}
+
+/**
+ * i40e_aq_set_vsi_uc_promisc_on_vlan
+ * @hw: pointer to the hw struct
+ * @seid: vsi number
+ * @enable: set MAC L2 layer unicast promiscuous enable/disable for a given VLAN
+ * @vid: The VLAN tag filter - capture any unicast packet with this VLAN tag
+ * @cmd_details: pointer to command details structure or NULL
+ **/
+i40e_status i40e_aq_set_vsi_uc_promisc_on_vlan(struct i40e_hw *hw,
+				u16 seid, bool enable, u16 vid,
+				struct i40e_asq_cmd_details *cmd_details)
+{
+	struct i40e_aq_desc desc;
+	struct i40e_aqc_set_vsi_promiscuous_modes *cmd =
+		(struct i40e_aqc_set_vsi_promiscuous_modes *)&desc.params.raw;
+	i40e_status status;
+	u16 flags = 0;
+
+	i40e_fill_default_direct_cmd_desc(&desc,
+					i40e_aqc_opc_set_vsi_promiscuous_modes);
+
+	if (enable)
+		flags |= I40E_AQC_SET_VSI_PROMISC_UNICAST;
+
+	cmd->promiscuous_flags = cpu_to_le16(flags);
+	cmd->valid_flags = cpu_to_le16(I40E_AQC_SET_VSI_PROMISC_UNICAST);
+	cmd->seid = cpu_to_le16(seid);
+	cmd->vlan_tag = cpu_to_le16(vid | I40E_AQC_SET_VSI_VLAN_VALID);
+
+	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
+
+	return status;
+}
+
+/**
  * i40e_aq_set_vsi_broadcast
  * @hw: pointer to the hw struct
  * @seid: vsi number
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index e51e156..757bf2c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -127,6 +127,12 @@ i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
 		u16 vsi_id, bool set, struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_vsi_multicast_promiscuous(struct i40e_hw *hw,
 		u16 vsi_id, bool set, struct i40e_asq_cmd_details *cmd_details);
+i40e_status i40e_aq_set_vsi_mc_promisc_on_vlan(struct i40e_hw *hw,
+				u16 seid, bool enable, u16 vid,
+				struct i40e_asq_cmd_details *cmd_details);
+i40e_status i40e_aq_set_vsi_uc_promisc_on_vlan(struct i40e_hw *hw,
+				u16 seid, bool enable, u16 vid,
+				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_get_vsi_params(struct i40e_hw *hw,
 				struct i40e_vsi_context *vsi_ctx,
 				struct i40e_asq_cmd_details *cmd_details);
-- 
2.4.3
