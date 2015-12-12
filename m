From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/11] i40e: Opcode and structures required by OEM Post Update AQ command and add new NVM arq message
Date: Sat, 12 Dec 2015 00:33:28 -0800
Message-ID: <1449909213-33795-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449909213-33795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Michal Kosiarz <michal.kosiarz@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52824 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229AbbLLIdm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 03:33:42 -0500
In-Reply-To: <1449909213-33795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kosiarz <michal.kosiarz@intel.com>

This is a part of implementation which contains data structures and
opcode for new AQ command. There's a new ARQ message that gets sent
near the end of the NVM update process that the driver should recognize
and ignore, rather than printing an Unknown Event error.

Change-ID: I04830a5bcae14823e16b9424cc4165e169336c1f
Signed-off-by: Michal Kosiarz <michal.kosiarz@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 21 +++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c         |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 21 +++++++++++++++++++++
 3 files changed, 43 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 61a4979..b22012a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -227,6 +227,7 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_nvm_update			= 0x0703,
 	i40e_aqc_opc_nvm_config_read		= 0x0704,
 	i40e_aqc_opc_nvm_config_write		= 0x0705,
+	i40e_aqc_opc_oem_post_update		= 0x0720,
 
 	/* virtualization commands */
 	i40e_aqc_opc_send_msg_to_pf		= 0x0801,
@@ -1891,6 +1892,26 @@ struct i40e_aqc_nvm_config_data_immediate_field {
 
 I40E_CHECK_STRUCT_LEN(0xc, i40e_aqc_nvm_config_data_immediate_field);
 
+/* OEM Post Update (indirect 0x0720)
+ * no command data struct used
+ */
+struct i40e_aqc_nvm_oem_post_update {
+#define I40E_AQ_NVM_OEM_POST_UPDATE_EXTERNAL_DATA	0x01
+	u8 sel_data;
+	u8 reserved[7];
+};
+
+I40E_CHECK_STRUCT_LEN(0x8, i40e_aqc_nvm_oem_post_update);
+
+struct i40e_aqc_nvm_oem_post_update_buffer {
+	u8 str_len;
+	u8 dev_addr;
+	__le16 eeprom_addr;
+	u8 data[36];
+};
+
+I40E_CHECK_STRUCT_LEN(0x28, i40e_aqc_nvm_oem_post_update_buffer);
+
 /* Send to PF command (indirect 0x0801) id is only used by PF
  * Send to VF command (indirect 0x0802) id is only used by PF
  * Send to Peer PF command (indirect 0x0803)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 36d1c2b..aff401f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6295,6 +6295,7 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 			break;
 		case i40e_aqc_opc_nvm_erase:
 		case i40e_aqc_opc_nvm_update:
+		case i40e_aqc_opc_oem_post_update:
 			i40e_debug(&pf->hw, I40E_DEBUG_NVM, "ARQ NVM operation completed\n");
 			break;
 		default:
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 1c76389..f5b2b36 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -227,6 +227,7 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_nvm_update			= 0x0703,
 	i40e_aqc_opc_nvm_config_read		= 0x0704,
 	i40e_aqc_opc_nvm_config_write		= 0x0705,
+	i40e_aqc_opc_oem_post_update		= 0x0720,
 
 	/* virtualization commands */
 	i40e_aqc_opc_send_msg_to_pf		= 0x0801,
@@ -1888,6 +1889,26 @@ struct i40e_aqc_nvm_config_data_immediate_field {
 
 I40E_CHECK_STRUCT_LEN(0xc, i40e_aqc_nvm_config_data_immediate_field);
 
+/* OEM Post Update (indirect 0x0720)
+ * no command data struct used
+ */
+ struct i40e_aqc_nvm_oem_post_update {
+#define I40E_AQ_NVM_OEM_POST_UPDATE_EXTERNAL_DATA	0x01
+	u8 sel_data;
+	u8 reserved[7];
+};
+
+I40E_CHECK_STRUCT_LEN(0x8, i40e_aqc_nvm_oem_post_update);
+
+struct i40e_aqc_nvm_oem_post_update_buffer {
+	u8 str_len;
+	u8 dev_addr;
+	__le16 eeprom_addr;
+	u8 data[36];
+};
+
+I40E_CHECK_STRUCT_LEN(0x28, i40e_aqc_nvm_oem_post_update_buffer);
+
 /* Send to PF command (indirect 0x0801) id is only used by PF
  * Send to VF command (indirect 0x0802) id is only used by PF
  * Send to Peer PF command (indirect 0x0803)
-- 
2.5.0
