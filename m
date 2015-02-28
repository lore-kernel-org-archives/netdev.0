From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/18] i40e/i40evf: print FW build number in version string
Date: Sat, 28 Feb 2015 03:29:36 -0800
Message-ID: <1425122989-354-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50492 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750990AbbB1L3z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:29:55 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Include the FW build number in the formatted FW version string.  In order
to fit within ethtool's 32 character limit, the etrack's unused high order
bits are trimmed as is the leading 0 for the NVM version.  This leaves
us with 2 character left for if/when the etrack id goes to 5 hex chars
and the NVM major number goes to 2 chars.

Change-ID: Icb004c4b9b14a2f54dd200b467fcc1d7b9297308
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h           |  6 +++---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c    |  1 +
 drivers/net/ethernet/intel/i40e/i40e_adminq.h    |  1 +
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 12 ++++++++----
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h  |  1 +
 6 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 1e9576b..5fa4eab 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -557,14 +557,14 @@ static inline char *i40e_fw_version_str(struct i40e_hw *hw)
 	static char buf[32];
 
 	snprintf(buf, sizeof(buf),
-		 "f%d.%d a%d.%d n%02x.%02x e%08x",
-		 hw->aq.fw_maj_ver, hw->aq.fw_min_ver,
+		 "f%d.%d.%05d a%d.%d n%x.%02x e%x",
+		 hw->aq.fw_maj_ver, hw->aq.fw_min_ver, hw->aq.fw_build,
 		 hw->aq.api_maj_ver, hw->aq.api_min_ver,
 		 (hw->nvm.version & I40E_NVM_VERSION_HI_MASK) >>
 			I40E_NVM_VERSION_HI_SHIFT,
 		 (hw->nvm.version & I40E_NVM_VERSION_LO_MASK) >>
 			I40E_NVM_VERSION_LO_SHIFT,
-		 hw->nvm.eetrack);
+		 (hw->nvm.eetrack & 0xffffff));
 
 	return buf;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 77f6254..dc2ed35 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -592,6 +592,7 @@ i40e_status i40e_init_adminq(struct i40e_hw *hw)
 		ret_code = i40e_aq_get_firmware_version(hw,
 							&hw->aq.fw_maj_ver,
 							&hw->aq.fw_min_ver,
+							&hw->aq.fw_build,
 							&hw->aq.api_maj_ver,
 							&hw->aq.api_min_ver,
 							NULL);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
index de17b6f..28e519a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
@@ -93,6 +93,7 @@ struct i40e_adminq_info {
 	u16 asq_buf_size;               /* send queue buffer size */
 	u16 fw_maj_ver;                 /* firmware major version */
 	u16 fw_min_ver;                 /* firmware minor version */
+	u32 fw_build;                   /* firmware build number */
 	u16 api_maj_ver;                /* api major version */
 	u16 api_min_ver;                /* api minor version */
 	bool nvm_release_on_done;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 88b2d45..cb19c37 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1737,6 +1737,7 @@ i40e_status i40e_aq_get_switch_config(struct i40e_hw *hw,
  * @hw: pointer to the hw struct
  * @fw_major_version: firmware major version
  * @fw_minor_version: firmware minor version
+ * @fw_build: firmware build number
  * @api_major_version: major queue version
  * @api_minor_version: minor queue version
  * @cmd_details: pointer to command details structure or NULL
@@ -1745,6 +1746,7 @@ i40e_status i40e_aq_get_switch_config(struct i40e_hw *hw,
  **/
 i40e_status i40e_aq_get_firmware_version(struct i40e_hw *hw,
 				u16 *fw_major_version, u16 *fw_minor_version,
+				u32 *fw_build,
 				u16 *api_major_version, u16 *api_minor_version,
 				struct i40e_asq_cmd_details *cmd_details)
 {
@@ -1758,13 +1760,15 @@ i40e_status i40e_aq_get_firmware_version(struct i40e_hw *hw,
 	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
 
 	if (!status) {
-		if (fw_major_version != NULL)
+		if (fw_major_version)
 			*fw_major_version = le16_to_cpu(resp->fw_major);
-		if (fw_minor_version != NULL)
+		if (fw_minor_version)
 			*fw_minor_version = le16_to_cpu(resp->fw_minor);
-		if (api_major_version != NULL)
+		if (fw_build)
+			*fw_build = le32_to_cpu(resp->fw_build);
+		if (api_major_version)
 			*api_major_version = le16_to_cpu(resp->api_major);
-		if (api_minor_version != NULL)
+		if (api_minor_version)
 			*api_minor_version = le16_to_cpu(resp->api_minor);
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 8cab460..fea0d37 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -66,6 +66,7 @@ void i40e_led_set(struct i40e_hw *hw, u32 mode, bool blink);
 
 i40e_status i40e_aq_get_firmware_version(struct i40e_hw *hw,
 				u16 *fw_major_version, u16 *fw_minor_version,
+				u32 *fw_build,
 				u16 *api_major_version, u16 *api_minor_version,
 				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_debug_write_register(struct i40e_hw *hw,
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
index 60f04e9..ef43d68 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
@@ -93,6 +93,7 @@ struct i40e_adminq_info {
 	u16 asq_buf_size;               /* send queue buffer size */
 	u16 fw_maj_ver;                 /* firmware major version */
 	u16 fw_min_ver;                 /* firmware minor version */
+	u32 fw_build;                   /* firmware build number */
 	u16 api_maj_ver;                /* api major version */
 	u16 api_min_ver;                /* api minor version */
 	bool nvm_release_on_done;
-- 
1.9.3
