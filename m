From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/16] i40e: add adminq commands for Rx CTL registers
Date: Fri, 19 Feb 2016 01:54:06 -0800
Message-ID: <1455875651-21696-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8261 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1427422AbcBSJyY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 04:54:24 -0500
In-Reply-To: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add the new opcodes and struct used for asking the firmware to update Rx
control registers that need extra care when being accessed while under
heavy traffic - e.g. sustained 64byte packets at line rate on all ports.
The firmware will take extra steps to be sure the register accesses
are successful.

The registers involved are:
	PFQF_CTL_0
	PFQF_HENA
	PFQF_FDALLOC
	PFQF_HREGION
	PFLAN_QALLOC
	VPQF_CTL
	VFQF_HENA
	VFQF_HREGION
	VSIQF_CTL
	VSILAN_QBASE
	VSILAN_QTABLE
	VSIQF_TCREGION
	PFQF_HKEY
	VFQF_HKEY
	PRTQF_CTL_0
	GLFCOE_RCTL
	GLFCOE_RSOF
	GLQF_CTL
	GLQF_SWAP
	GLQF_HASH_MSK
	GLQF_HASH_INSET
	GLQF_HSYM
	GLQF_FC_MSK
	GLQF_FC_INSET
	GLQF_FD_MSK
	PRTQF_FD_INSET
	PRTQF_FD_FLXINSET
	PRTQF_FD_MSK

Change-ID: I56c8144000da66ad99f68948d8a184b2ec2aeb3e
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 16 ++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 16 ++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index bb7ecbb..8d5c65a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -146,6 +146,8 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_set_port_parameters	= 0x0203,
 	i40e_aqc_opc_get_switch_resource_alloc	= 0x0204,
 	i40e_aqc_opc_set_switch_config		= 0x0205,
+	i40e_aqc_opc_rx_ctl_reg_read		= 0x0206,
+	i40e_aqc_opc_rx_ctl_reg_write		= 0x0207,
 
 	i40e_aqc_opc_add_vsi			= 0x0210,
 	i40e_aqc_opc_update_vsi_parameters	= 0x0211,
@@ -696,6 +698,20 @@ struct i40e_aqc_set_switch_config {
 
 I40E_CHECK_CMD_LENGTH(i40e_aqc_set_switch_config);
 
+/* Read Receive control registers  (direct 0x0206)
+ * Write Receive control registers (direct 0x0207)
+ *     used for accessing Rx control registers that can be
+ *     slow and need special handling when under high Rx load
+ */
+struct i40e_aqc_rx_ctl_reg_read_write {
+	__le32 reserved1;
+	__le32 address;
+	__le32 reserved2;
+	__le32 value;
+};
+
+I40E_CHECK_CMD_LENGTH(i40e_aqc_rx_ctl_reg_read_write);
+
 /* Add VSI (indirect 0x0210)
  *    this indirect command uses struct i40e_aqc_vsi_properties_data
  *    as the indirect buffer (128 bytes)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 815e481..aad8d62 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -146,6 +146,8 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_set_port_parameters	= 0x0203,
 	i40e_aqc_opc_get_switch_resource_alloc	= 0x0204,
 	i40e_aqc_opc_set_switch_config		= 0x0205,
+	i40e_aqc_opc_rx_ctl_reg_read		= 0x0206,
+	i40e_aqc_opc_rx_ctl_reg_write		= 0x0207,
 
 	i40e_aqc_opc_add_vsi			= 0x0210,
 	i40e_aqc_opc_update_vsi_parameters	= 0x0211,
@@ -693,6 +695,20 @@ struct i40e_aqc_set_switch_config {
 
 I40E_CHECK_CMD_LENGTH(i40e_aqc_set_switch_config);
 
+/* Read Receive control registers  (direct 0x0206)
+ * Write Receive control registers (direct 0x0207)
+ *     used for accessing Rx control registers that can be
+ *     slow and need special handling when under high Rx load
+ */
+struct i40e_aqc_rx_ctl_reg_read_write {
+	__le32 reserved1;
+	__le32 address;
+	__le32 reserved2;
+	__le32 value;
+};
+
+I40E_CHECK_CMD_LENGTH(i40e_aqc_rx_ctl_reg_read_write);
+
 /* Add VSI (indirect 0x0210)
  *    this indirect command uses struct i40e_aqc_vsi_properties_data
  *    as the indirect buffer (128 bytes)
-- 
2.5.0
