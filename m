From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/14] i40e: Add ablitity to enable/disable link from set_link_restart_an
Date: Tue, 24 Jun 2014 18:26:19 -0700
Message-ID: <1403659585-32055-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403659585-32055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35161 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754356AbaFYB0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 21:26:42 -0400
In-Reply-To: <1403659585-32055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

The ability is already there in the fw and this will make it easy
to toggle link without calling set_phy_config when no other link
settings need to change.

Change-ID: I185567ae81776382ac145247e4eb1ee95f22382c
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 8 +++++++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c   | 3 ++-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h | 3 ++-
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index a51bba6..bbace40 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -971,12 +971,14 @@ i40e_status i40e_aq_clear_pxe_mode(struct i40e_hw *hw,
 /**
  * i40e_aq_set_link_restart_an
  * @hw: pointer to the hw struct
+ * @enable_link: if true: enable link, if false: disable link
  * @cmd_details: pointer to command details structure or NULL
  *
  * Sets up the link and restarts the Auto-Negotiation over the link.
  **/
 i40e_status i40e_aq_set_link_restart_an(struct i40e_hw *hw,
-				struct i40e_asq_cmd_details *cmd_details)
+					bool enable_link,
+					struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_set_link_restart_an *cmd =
@@ -987,6 +989,10 @@ i40e_status i40e_aq_set_link_restart_an(struct i40e_hw *hw,
 					  i40e_aqc_opc_set_link_restart_an);
 
 	cmd->command = I40E_AQ_PHY_RESTART_AN;
+	if (enable_link)
+		cmd->command |= I40E_AQ_PHY_LINK_ENABLE;
+	else
+		cmd->command &= ~I40E_AQ_PHY_LINK_ENABLE;
 
 	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 7da3758..df89b6c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1027,9 +1027,10 @@ static int i40e_nway_reset(struct net_device *netdev)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_pf *pf = np->vsi->back;
 	struct i40e_hw *hw = &pf->hw;
+	bool link_up = hw->phy.link_info.link_info & I40E_AQ_LINK_UP;
 	i40e_status ret = 0;
 
-	ret = i40e_aq_set_link_restart_an(hw, NULL);
+	ret = i40e_aq_set_link_restart_an(hw, link_up, NULL);
 	if (ret) {
 		netdev_info(netdev, "link restart failed, aq_err=%d\n",
 			    pf->hw.aq.asq_last_status);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index a430699..3300b99 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -77,7 +77,8 @@ i40e_status i40e_aq_set_default_vsi(struct i40e_hw *hw, u16 vsi_id,
 i40e_status i40e_aq_clear_pxe_mode(struct i40e_hw *hw,
 				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_link_restart_an(struct i40e_hw *hw,
-				struct i40e_asq_cmd_details *cmd_details);
+					bool enable_link,
+					struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_get_link_info(struct i40e_hw *hw,
 				bool enable_lse, struct i40e_link_status *link,
 				struct i40e_asq_cmd_details *cmd_details);
-- 
1.9.3
