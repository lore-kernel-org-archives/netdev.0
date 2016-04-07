From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] i40e: Move NVM variable out of AQ struct
Date: Wed,  6 Apr 2016 20:29:34 -0700
Message-ID: <1459999779-22254-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9491 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754627AbcDGD3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 23:29:45 -0400
In-Reply-To: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The NVM update status info should stay collected together, not
spread across different structs.

Change-ID: Ic16f9e9fd79945d865bb7226184c889884585025
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   |  6 +++---
 drivers/net/ethernet/intel/i40e/i40e_adminq.h   |  1 -
 drivers/net/ethernet/intel/i40e/i40e_nvm.c      | 12 ++++++------
 drivers/net/ethernet/intel/i40e/i40e_type.h     |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h |  1 -
 drivers/net/ethernet/intel/i40evf/i40e_type.h   |  1 +
 6 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index df8e2fd..e8278e1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -624,7 +624,7 @@ i40e_status i40e_init_adminq(struct i40e_hw *hw)
 
 	/* pre-emptive resource lock release */
 	i40e_aq_release_resource(hw, I40E_NVM_RESOURCE_ID, 0, NULL);
-	hw->aq.nvm_release_on_done = false;
+	hw->nvm_release_on_done = false;
 	hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
 
 	ret_code = i40e_aq_set_hmc_resource_profile(hw,
@@ -1024,9 +1024,9 @@ i40e_status i40e_clean_arq_element(struct i40e_hw *hw,
 	hw->aq.arq.next_to_use = ntu;
 
 	if (i40e_is_nvm_update_op(&e->desc)) {
-		if (hw->aq.nvm_release_on_done) {
+		if (hw->nvm_release_on_done) {
 			i40e_release_nvm(hw);
-			hw->aq.nvm_release_on_done = false;
+			hw->nvm_release_on_done = false;
 		}
 
 		switch (hw->nvmupd_state) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
index 12fbbdd..d92aad3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
@@ -97,7 +97,6 @@ struct i40e_adminq_info {
 	u32 fw_build;                   /* firmware build number */
 	u16 api_maj_ver;                /* api major version */
 	u16 api_min_ver;                /* api minor version */
-	bool nvm_release_on_done;
 
 	struct mutex asq_mutex; /* Send queue lock */
 	struct mutex arq_mutex; /* Receive queue lock */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 5730f80..1ae29ac 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -696,7 +696,7 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
 	i40e_debug(hw, I40E_DEBUG_NVM, "%s state %d nvm_release_on_hold %d cmd 0x%08x config 0x%08x offset 0x%08x data_size 0x%08x\n",
 		   i40e_nvm_update_state_str[upd_cmd],
 		   hw->nvmupd_state,
-		   hw->aq.nvm_release_on_done,
+		   hw->nvm_release_on_done,
 		   cmd->command, cmd->config, cmd->offset, cmd->data_size);
 
 	if (upd_cmd == I40E_NVMUPD_INVALID) {
@@ -799,7 +799,7 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 			if (status) {
 				i40e_release_nvm(hw);
 			} else {
-				hw->aq.nvm_release_on_done = true;
+				hw->nvm_release_on_done = true;
 				hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
 			}
 		}
@@ -815,7 +815,7 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 			if (status) {
 				i40e_release_nvm(hw);
 			} else {
-				hw->aq.nvm_release_on_done = true;
+				hw->nvm_release_on_done = true;
 				hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
 			}
 		}
@@ -849,7 +849,7 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 				   -EIO;
 				i40e_release_nvm(hw);
 			} else {
-				hw->aq.nvm_release_on_done = true;
+				hw->nvm_release_on_done = true;
 				hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
 			}
 		}
@@ -953,7 +953,7 @@ retry:
 				   -EIO;
 			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
 		} else {
-			hw->aq.nvm_release_on_done = true;
+			hw->nvm_release_on_done = true;
 			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
 		}
 		break;
@@ -980,7 +980,7 @@ retry:
 				   -EIO;
 			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
 		} else {
-			hw->aq.nvm_release_on_done = true;
+			hw->nvm_release_on_done = true;
 			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
 		}
 		break;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 3335f9d..bf693580 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -549,6 +549,7 @@ struct i40e_hw {
 	enum i40e_nvmupd_state nvmupd_state;
 	struct i40e_aq_desc nvm_wb_desc;
 	struct i40e_virt_mem nvm_buff;
+	bool nvm_release_on_done;
 
 	/* HMC info */
 	struct i40e_hmc_info hmc; /* HMC info struct */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
index a3eae5d..1f9b3b5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
@@ -97,7 +97,6 @@ struct i40e_adminq_info {
 	u32 fw_build;                   /* firmware build number */
 	u16 api_maj_ver;                /* api major version */
 	u16 api_min_ver;                /* api minor version */
-	bool nvm_release_on_done;
 
 	struct mutex asq_mutex; /* Send queue lock */
 	struct mutex arq_mutex; /* Receive queue lock */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 301fe2b..d68e017 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -522,6 +522,7 @@ struct i40e_hw {
 	enum i40e_nvmupd_state nvmupd_state;
 	struct i40e_aq_desc nvm_wb_desc;
 	struct i40e_virt_mem nvm_buff;
+	bool nvm_release_on_done;
 
 	/* HMC info */
 	struct i40e_hmc_info hmc; /* HMC info struct */
-- 
2.5.5
