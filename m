From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e: Admin queue shutdown fixes
Date: Mon,  6 Jan 2014 04:30:34 -0800
Message-ID: <1389011436-18424-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22497 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753917AbaAFMap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 07:30:45 -0500
In-Reply-To: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Always call the AQ call to shutdown the queue in the shutdown path.

Check ASQ is alive before issuing the AQ command since we might be
resetting to recover from a bad state in which case we should not
issue the AQ command.

Use the register variable for length so it can be used by PF, VF
and GL AQ commands.

Change-Id: Ic3d305687ea3f1a6afa84e864b7a27bd38a9af32
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c    |  3 ++
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 63 ++++++++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_main.c      |  1 -
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  5 +-
 4 files changed, 44 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index d04ad3b..f75b573 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -609,6 +609,9 @@ i40e_status i40e_shutdown_adminq(struct i40e_hw *hw)
 {
 	i40e_status ret_code = 0;
 
+	if (i40e_check_asq_alive(hw))
+		i40e_aq_queue_shutdown(hw, true);
+
 	i40e_shutdown_asq(hw);
 	i40e_shutdown_arq(hw);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 161d6ff..7cd59ce 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -126,6 +126,44 @@ void i40e_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 }
 
 /**
+ * i40e_check_asq_alive
+ * @hw: pointer to the hw struct
+ *
+ * Returns true if Queue is enabled else false.
+ **/
+bool i40e_check_asq_alive(struct i40e_hw *hw)
+{
+	return !!(rd32(hw, hw->aq.asq.len) & I40E_PF_ATQLEN_ATQENABLE_MASK);
+}
+
+/**
+ * i40e_aq_queue_shutdown
+ * @hw: pointer to the hw struct
+ * @unloading: is the driver unloading itself
+ *
+ * Tell the Firmware that we're shutting down the AdminQ and whether
+ * or not the driver is unloading as well.
+ **/
+i40e_status i40e_aq_queue_shutdown(struct i40e_hw *hw,
+					     bool unloading)
+{
+	struct i40e_aq_desc desc;
+	struct i40e_aqc_queue_shutdown *cmd =
+		(struct i40e_aqc_queue_shutdown *)&desc.params.raw;
+	i40e_status status;
+
+	i40e_fill_default_direct_cmd_desc(&desc,
+					  i40e_aqc_opc_queue_shutdown);
+
+	if (unloading)
+		cmd->driver_unloading = cpu_to_le32(I40E_AQ_DRIVER_UNLOADING);
+	status = i40e_asq_send_command(hw, &desc, NULL, 0, NULL);
+
+	return status;
+}
+
+
+/**
  * i40e_init_shared_code - Initialize the shared code
  * @hw: pointer to hardware structure
  *
@@ -478,31 +516,6 @@ void i40e_led_set(struct i40e_hw *hw, u32 mode, bool blink)
 }
 
 /* Admin command wrappers */
-/**
- * i40e_aq_queue_shutdown
- * @hw: pointer to the hw struct
- * @unloading: is the driver unloading itself
- *
- * Tell the Firmware that we're shutting down the AdminQ and whether
- * or not the driver is unloading as well.
- **/
-i40e_status i40e_aq_queue_shutdown(struct i40e_hw *hw,
-					     bool unloading)
-{
-	struct i40e_aq_desc desc;
-	struct i40e_aqc_queue_shutdown *cmd =
-		(struct i40e_aqc_queue_shutdown *)&desc.params.raw;
-	i40e_status status;
-
-	i40e_fill_default_direct_cmd_desc(&desc,
-					  i40e_aqc_opc_queue_shutdown);
-
-	if (unloading)
-		cmd->driver_unloading = cpu_to_le32(I40E_AQ_DRIVER_UNLOADING);
-	status = i40e_asq_send_command(hw, &desc, NULL, 0, NULL);
-
-	return status;
-}
 
 /**
  * i40e_aq_set_link_restart_an
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 9c16aa8..c97fc0c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7854,7 +7854,6 @@ static void i40e_remove(struct pci_dev *pdev)
 			 "Failed to destroy the HMC resources: %d\n", ret_code);
 
 	/* shutdown the adminq */
-	i40e_aq_queue_shutdown(&pf->hw, true);
 	ret_code = i40e_shutdown_adminq(&pf->hw);
 	if (ret_code)
 		dev_warn(&pdev->dev,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 800f3c8..e05d303 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -59,6 +59,9 @@ void i40e_debug_aq(struct i40e_hw *hw,
 		   void *buffer);
 
 void i40e_idle_aq(struct i40e_hw *hw);
+bool i40e_check_asq_alive(struct i40e_hw *hw);
+i40e_status i40e_aq_queue_shutdown(struct i40e_hw *hw,
+				   bool unloading);
 
 u32 i40e_led_get(struct i40e_hw *hw);
 void i40e_led_set(struct i40e_hw *hw, u32 mode, bool blink);
@@ -69,8 +72,6 @@ i40e_status i40e_aq_get_firmware_version(struct i40e_hw *hw,
 				u16 *fw_major_version, u16 *fw_minor_version,
 				u16 *api_major_version, u16 *api_minor_version,
 				struct i40e_asq_cmd_details *cmd_details);
-i40e_status i40e_aq_queue_shutdown(struct i40e_hw *hw,
-					     bool unloading);
 i40e_status i40e_aq_set_phy_reset(struct i40e_hw *hw,
 				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_default_vsi(struct i40e_hw *hw, u16 vsi_id,
-- 
1.8.3.1
