From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/12] i40e: rtnl_lock in reset path fixes
Date: Mon, 16 Dec 2013 01:38:56 -0800
Message-ID: <1387186738-13666-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387186738-13666-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:39292 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752958Ab3LPJjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 04:39:09 -0500
In-Reply-To: <1387186738-13666-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Any user-initiated path which eventually calls reset needs
to hold the rtnl_lock, so add functionality to do that.

Be careful not to use the safe reset when cleaning up
from the diagnostic tests, which avoids rtnl_lock
recursion from ethtool.

Protect the reset_task with rtnl_lock, since it runs from a work item.

Change-Id: Ib6e7a3fb2966809db2daf35fd5a123ccdf6f6f0f
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  1 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c |  8 ++++----
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 19 ++++++++++++++++++-
 3 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index eb1a3aa..24a47ee 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -502,6 +502,7 @@ int i40e_up(struct i40e_vsi *vsi);
 void i40e_down(struct i40e_vsi *vsi);
 extern const char i40e_driver_name[];
 extern const char i40e_driver_version_str[];
+void i40e_do_reset_safe(struct i40e_pf *pf, u32 reset_flags);
 void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags);
 void i40e_update_stats(struct i40e_vsi *vsi);
 void i40e_update_eth_stats(struct i40e_vsi *vsi);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 9c675b5..9a59dda 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1462,19 +1462,19 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		}
 	} else if (strncmp(cmd_buf, "pfr", 3) == 0) {
 		dev_info(&pf->pdev->dev, "forcing PFR\n");
-		i40e_do_reset(pf, (1 << __I40E_PF_RESET_REQUESTED));
+		i40e_do_reset_safe(pf, (1 << __I40E_PF_RESET_REQUESTED));
 
 	} else if (strncmp(cmd_buf, "corer", 5) == 0) {
 		dev_info(&pf->pdev->dev, "forcing CoreR\n");
-		i40e_do_reset(pf, (1 << __I40E_CORE_RESET_REQUESTED));
+		i40e_do_reset_safe(pf, (1 << __I40E_CORE_RESET_REQUESTED));
 
 	} else if (strncmp(cmd_buf, "globr", 5) == 0) {
 		dev_info(&pf->pdev->dev, "forcing GlobR\n");
-		i40e_do_reset(pf, (1 << __I40E_GLOBAL_RESET_REQUESTED));
+		i40e_do_reset_safe(pf, (1 << __I40E_GLOBAL_RESET_REQUESTED));
 
 	} else if (strncmp(cmd_buf, "empr", 4) == 0) {
 		dev_info(&pf->pdev->dev, "forcing EMPR\n");
-		i40e_do_reset(pf, (1 << __I40E_EMP_RESET_REQUESTED));
+		i40e_do_reset_safe(pf, (1 << __I40E_EMP_RESET_REQUESTED));
 
 	} else if (strncmp(cmd_buf, "read", 4) == 0) {
 		u32 address;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 73c9a20..19ad3c0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4132,6 +4132,19 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 }
 
 /**
+ * i40e_do_reset_safe - Protected reset path for userland calls.
+ * @pf: board private structure
+ * @reset_flags: which reset is requested
+ *
+ **/
+void i40e_do_reset_safe(struct i40e_pf *pf, u32 reset_flags)
+{
+	rtnl_lock();
+	i40e_do_reset(pf, reset_flags);
+	rtnl_unlock();
+}
+
+/**
  * i40e_handle_lan_overflow_event - Handler for LAN queue overflow event
  * @pf: board private structure
  * @e: event info posted on ARQ
@@ -4376,6 +4389,7 @@ static void i40e_reset_subtask(struct i40e_pf *pf)
 {
 	u32 reset_flags = 0;
 
+	rtnl_lock();
 	if (test_bit(__I40E_REINIT_REQUESTED, &pf->state)) {
 		reset_flags |= (1 << __I40E_REINIT_REQUESTED);
 		clear_bit(__I40E_REINIT_REQUESTED, &pf->state);
@@ -4398,7 +4412,7 @@ static void i40e_reset_subtask(struct i40e_pf *pf)
 	 */
 	if (test_bit(__I40E_RESET_INTR_RECEIVED, &pf->state)) {
 		i40e_handle_reset_warning(pf);
-		return;
+		goto unlock;
 	}
 
 	/* If we're already down or resetting, just bail */
@@ -4406,6 +4420,9 @@ static void i40e_reset_subtask(struct i40e_pf *pf)
 	    !test_bit(__I40E_DOWN, &pf->state) &&
 	    !test_bit(__I40E_CONFIG_BUSY, &pf->state))
 		i40e_do_reset(pf, reset_flags);
+
+unlock:
+	rtnl_unlock();
 }
 
 /**
-- 
1.8.3.1
