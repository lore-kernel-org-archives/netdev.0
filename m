From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/17] i40e/i40evf: Add info to nvm info struct for OEM version data
Date: Mon, 12 Oct 2015 22:53:06 -0700
Message-ID: <1444715598-20970-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24922 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069AbbJMFx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 01:53:26 -0400
In-Reply-To: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds a member to the nvm_info struct for oem_ver info to be
output either by OID or ethtool.

Change-ID: I1e5d513ae67622e2af17042924fdb4b5d6d85366
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c | 9 ++++++++-
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 3 +++
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 2 ++
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index fa2e916..5c950e2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -553,8 +553,9 @@ shutdown_arq_out:
  **/
 i40e_status i40e_init_adminq(struct i40e_hw *hw)
 {
-	i40e_status ret_code;
+	u16 cfg_ptr, oem_hi, oem_lo;
 	u16 eetrack_lo, eetrack_hi;
+	i40e_status ret_code;
 	int retry = 0;
 
 	/* verify input for valid configuration */
@@ -613,6 +614,12 @@ i40e_status i40e_init_adminq(struct i40e_hw *hw)
 	i40e_read_nvm_word(hw, I40E_SR_NVM_EETRACK_LO, &eetrack_lo);
 	i40e_read_nvm_word(hw, I40E_SR_NVM_EETRACK_HI, &eetrack_hi);
 	hw->nvm.eetrack = (eetrack_hi << 16) | eetrack_lo;
+	i40e_read_nvm_word(hw, I40E_SR_BOOT_CONFIG_PTR, &cfg_ptr);
+	i40e_read_nvm_word(hw, (cfg_ptr + I40E_NVM_OEM_VER_OFF),
+			   &oem_hi);
+	i40e_read_nvm_word(hw, (cfg_ptr + (I40E_NVM_OEM_VER_OFF + 1)),
+			   &oem_lo);
+	hw->nvm.oem_ver = ((u32)oem_hi << 16) | oem_lo;
 
 	if (hw->aq.api_maj_ver > I40E_FW_API_VERSION_MAJOR) {
 		ret_code = I40E_ERR_FIRMWARE_API_VERSION;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index d1ec5a4..c8f7a52 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -289,6 +289,7 @@ struct i40e_nvm_info {
 	bool blank_nvm_mode;      /* is NVM empty (no FW present)*/
 	u16 version;              /* NVM package version */
 	u32 eetrack;              /* NVM data version */
+	u32 oem_ver;              /* OEM version info */
 };
 
 /* definitions used in NVM update support */
@@ -1204,6 +1205,8 @@ struct i40e_hw_port_stats {
 #define I40E_SR_EMP_MODULE_PTR			0x0F
 #define I40E_SR_PBA_FLAGS			0x15
 #define I40E_SR_PBA_BLOCK_PTR			0x16
+#define I40E_SR_BOOT_CONFIG_PTR			0x17
+#define I40E_NVM_OEM_VER_OFF			0x83
 #define I40E_SR_NVM_DEV_STARTER_VERSION		0x18
 #define I40E_SR_NVM_WAKE_ON_LAN			0x19
 #define I40E_SR_ALTERNATE_SAN_MAC_ADDRESS_PTR	0x27
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index a59b60f..b3c65dd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -288,6 +288,7 @@ struct i40e_nvm_info {
 	bool blank_nvm_mode;      /* is NVM empty (no FW present)*/
 	u16 version;              /* NVM package version */
 	u32 eetrack;              /* NVM data version */
+	u32 oem_ver;              /* OEM version info */
 };
 
 /* definitions used in NVM update support */
@@ -1173,6 +1174,7 @@ struct i40e_hw_port_stats {
 /* Checksum and Shadow RAM pointers */
 #define I40E_SR_NVM_CONTROL_WORD		0x00
 #define I40E_SR_EMP_MODULE_PTR			0x0F
+#define I40E_NVM_OEM_VER_OFF			0x83
 #define I40E_SR_NVM_DEV_STARTER_VERSION		0x18
 #define I40E_SR_NVM_WAKE_ON_LAN			0x19
 #define I40E_SR_ALTERNATE_SAN_MAC_ADDRESS_PTR	0x27
-- 
2.4.3
