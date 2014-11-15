From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/12] i40e: Prevent link flow control settings when PFC is enabled
Date: Fri, 14 Nov 2014 22:08:34 -0800
Message-ID: <1416031715-32498-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35240 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754051AbaKOGIp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2014 01:08:45 -0500
In-Reply-To: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

When PFC is enabled we should not proceed with setting the link flow control
parameters.  Also, always report the link flow Tx/Rx settings as off when
PFC is enabled.

Change-ID: Ib09ec58afdf0b2e587ac9d8851a5c80ad58206c4
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-By: Jack Morgan <jack.morgan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index afad5aa..bb1698a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -644,11 +644,19 @@ static void i40e_get_pauseparam(struct net_device *netdev,
 	struct i40e_pf *pf = np->vsi->back;
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_link_status *hw_link_info = &hw->phy.link_info;
+	struct i40e_dcbx_config *dcbx_cfg = &hw->local_dcbx_config;
 
 	pause->autoneg =
 		((hw_link_info->an_info & I40E_AQ_AN_COMPLETED) ?
 		  AUTONEG_ENABLE : AUTONEG_DISABLE);
 
+	/* PFC enabled so report LFC as off */
+	if (dcbx_cfg->pfc.pfcenable) {
+		pause->rx_pause = 0;
+		pause->tx_pause = 0;
+		return;
+	}
+
 	if (hw->fc.current_mode == I40E_FC_RX_PAUSE) {
 		pause->rx_pause = 1;
 	} else if (hw->fc.current_mode == I40E_FC_TX_PAUSE) {
@@ -672,6 +680,7 @@ static int i40e_set_pauseparam(struct net_device *netdev,
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_link_status *hw_link_info = &hw->phy.link_info;
+	struct i40e_dcbx_config *dcbx_cfg = &hw->local_dcbx_config;
 	bool link_up = hw_link_info->link_info & I40E_AQ_LINK_UP;
 	i40e_status status;
 	u8 aq_failures;
@@ -693,8 +702,9 @@ static int i40e_set_pauseparam(struct net_device *netdev,
 		netdev_info(netdev, "Autoneg did not complete so changing settings may not result in an actual change.\n");
 	}
 
-	if (hw->fc.current_mode == I40E_FC_PFC) {
-		netdev_info(netdev, "Priority flow control enabled. Cannot set link flow control.\n");
+	if (dcbx_cfg->pfc.pfcenable) {
+		netdev_info(netdev,
+			    "Priority flow control enabled. Cannot set link flow control.\n");
 		return -EOPNOTSUPP;
 	}
 
-- 
1.9.3
