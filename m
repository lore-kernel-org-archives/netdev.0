From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/16] i40e/i40evf: Remove unused variable an_enable and function update_link_info
Date: Mon, 23 Feb 2015 18:11:16 -0800
Message-ID: <1424743881-30485-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424743881-30485-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:63799 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752475AbbBXCLs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2015 21:11:48 -0500
In-Reply-To: <1424743881-30485-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

An_enable was never used only set so lets remove it. The function
update_link_info only did two things, call get_link_info and set
an_enabled. Therefore we should also remove update_link_info and
change all references to it to get_link_info.

Change-ID: Ie3022680fa7a94bfd495a4f5fc76a73701d85569
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 33 ++----------------------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c   |  4 +--
 drivers/net/ethernet/intel/i40e/i40e_main.c      |  4 +--
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  1 -
 drivers/net/ethernet/intel/i40e/i40e_type.h      |  1 -
 drivers/net/ethernet/intel/i40evf/i40e_type.h    |  1 -
 6 files changed, 6 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 11a9ffe..8dbf7dd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1297,14 +1297,14 @@ enum i40e_status_code i40e_set_fc(struct i40e_hw *hw, u8 *aq_failures,
 			*aq_failures |= I40E_SET_FC_AQ_FAIL_SET;
 	}
 	/* Update the link info */
-	status = i40e_update_link_info(hw, true);
+	status = i40e_aq_get_link_info(hw, true, NULL, NULL);
 	if (status) {
 		/* Wait a little bit (on 40G cards it sometimes takes a really
 		 * long time for link to come back from the atomic reset)
 		 * and try once more
 		 */
 		msleep(1000);
-		status = i40e_update_link_info(hw, true);
+		status = i40e_aq_get_link_info(hw, true, NULL, NULL);
 	}
 	if (status)
 		*aq_failures |= I40E_SET_FC_AQ_FAIL_UPDATE;
@@ -1452,35 +1452,6 @@ aq_get_link_info_exit:
 }
 
 /**
- * i40e_update_link_info
- * @hw: pointer to the hw struct
- * @enable_lse: enable/disable LinkStatusEvent reporting
- *
- * Returns the link status of the adapter
- **/
-i40e_status i40e_update_link_info(struct i40e_hw *hw, bool enable_lse)
-{
-	struct i40e_aq_get_phy_abilities_resp abilities;
-	i40e_status status;
-
-	status = i40e_aq_get_link_info(hw, enable_lse, NULL, NULL);
-	if (status)
-		return status;
-
-	status = i40e_aq_get_phy_capabilities(hw, false, false,
-					      &abilities, NULL);
-	if (status)
-		return status;
-
-	if (abilities.abilities & I40E_AQ_PHY_AN_ENABLED)
-		hw->phy.link_info.an_enabled = true;
-	else
-		hw->phy.link_info.an_enabled = false;
-
-	return status;
-}
-
-/**
  * i40e_aq_set_phy_int_mask
  * @hw: pointer to the hw struct
  * @mask: interrupt mask to be set
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index cd5083e..8e69caf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -620,7 +620,7 @@ static int i40e_set_settings(struct net_device *netdev,
 			return -EAGAIN;
 		}
 
-		status = i40e_update_link_info(hw, true);
+		status = i40e_aq_get_link_info(hw, true, NULL, NULL);
 		if (status)
 			netdev_info(netdev, "Updating link info failed with error %d\n",
 				    status);
@@ -766,7 +766,7 @@ static int i40e_set_pauseparam(struct net_device *netdev,
 		err = -EAGAIN;
 	}
 	if (aq_failures & I40E_SET_FC_AQ_FAIL_UPDATE) {
-		netdev_info(netdev, "Set fc failed on the update_link_info call with error %d and status %d\n",
+		netdev_info(netdev, "Set fc failed on the get_link_info call with error %d and status %d\n",
 			    status, hw->aq.asq_last_status);
 		err = -EAGAIN;
 	}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 652cb4e..163cf2e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8885,7 +8885,7 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 		i40e_config_rss(pf);
 
 	/* fill in link information and enable LSE reporting */
-	i40e_update_link_info(&pf->hw, true);
+	i40e_aq_get_link_info(&pf->hw, true, NULL, NULL);
 	i40e_link_event(pf);
 
 	/* Initialize user-specific link properties */
@@ -8893,7 +8893,7 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 				  I40E_AQ_AN_COMPLETED) ? true : false);
 
 	/* fill in link information and enable LSE reporting */
-	i40e_update_link_info(&pf->hw, true);
+	i40e_aq_get_link_info(&pf->hw, true, NULL, NULL);
 	i40e_link_event(pf);
 
 	/* Initialize user-specific link properties */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index de80cb2..1247a45 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -97,7 +97,6 @@ i40e_status i40e_aq_set_link_restart_an(struct i40e_hw *hw,
 i40e_status i40e_aq_get_link_info(struct i40e_hw *hw,
 				bool enable_lse, struct i40e_link_status *link,
 				struct i40e_asq_cmd_details *cmd_details);
-i40e_status i40e_update_link_info(struct i40e_hw *hw, bool enable_lse);
 i40e_status i40e_aq_set_local_advt_reg(struct i40e_hw *hw,
 				u64 advt_reg,
 				struct i40e_asq_cmd_details *cmd_details);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index e9901ef..86a927b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -175,7 +175,6 @@ struct i40e_link_status {
 	u8 an_info;
 	u8 ext_info;
 	u8 loopback;
-	bool an_enabled;
 	/* is Link Status Event notification to SW enabled */
 	bool lse_enable;
 	u16 max_frame_size;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 3d0fdaa..c8cd8af 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -175,7 +175,6 @@ struct i40e_link_status {
 	u8 an_info;
 	u8 ext_info;
 	u8 loopback;
-	bool an_enabled;
 	/* is Link Status Event notification to SW enabled */
 	bool lse_enable;
 	u16 max_frame_size;
-- 
1.9.3
