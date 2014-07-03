From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] i40e: Add set_pauseparam to ethtool
Date: Wed,  2 Jul 2014 19:40:31 -0700
Message-ID: <1404355233-30123-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40790 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754983AbaGCClU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 22:41:20 -0400
In-Reply-To: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Add i40e implementation of setpauseparam to ethtool.

Change-ID: Ie7766b2091ec8f934737573c9ffd426081966718
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 76 ++++++++++++++++++++++++++
 1 file changed, 76 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 6508a1b..fc86761 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -457,6 +457,81 @@ static void i40e_get_pauseparam(struct net_device *netdev,
 	}
 }
 
+/**
+ * i40e_set_pauseparam - Set Flow Control parameter
+ * @netdev: network interface device structure
+ * @pause: return tx/rx flow control status
+ **/
+static int i40e_set_pauseparam(struct net_device *netdev,
+			       struct ethtool_pauseparam *pause)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_pf *pf = np->vsi->back;
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_hw *hw = &pf->hw;
+	struct i40e_link_status *hw_link_info = &hw->phy.link_info;
+	bool link_up = hw_link_info->link_info & I40E_AQ_LINK_UP;
+	i40e_status status;
+	u8 aq_failures;
+	int err;
+
+	if (vsi != pf->vsi[pf->lan_vsi])
+		return -EOPNOTSUPP;
+
+	if (pause->autoneg != ((hw_link_info->an_info & I40E_AQ_AN_COMPLETED) ?
+	    AUTONEG_ENABLE : AUTONEG_DISABLE)) {
+		netdev_info(netdev, "To change autoneg please use: ethtool -s <dev> autoneg <on|off>\n");
+		return -EOPNOTSUPP;
+	}
+
+	/* If we have link and don't have autoneg */
+	if (!test_bit(__I40E_DOWN, &pf->state) &&
+	    !(hw_link_info->an_info & I40E_AQ_AN_COMPLETED)) {
+		/* Send message that it might not necessarily work*/
+		netdev_info(netdev, "Autoneg did not complete so changing settings may not result in an actual change.\n");
+	}
+
+	if (hw->fc.current_mode == I40E_FC_PFC) {
+		netdev_info(netdev, "Priority flow control enabled. Cannot set link flow control.\n");
+		return -EOPNOTSUPP;
+	}
+
+	if (pause->rx_pause && pause->tx_pause)
+		hw->fc.requested_mode = I40E_FC_FULL;
+	else if (pause->rx_pause && !pause->tx_pause)
+		hw->fc.requested_mode = I40E_FC_RX_PAUSE;
+	else if (!pause->rx_pause && pause->tx_pause)
+		hw->fc.requested_mode = I40E_FC_TX_PAUSE;
+	else if (!pause->rx_pause && !pause->tx_pause)
+		hw->fc.requested_mode = I40E_FC_NONE;
+	else
+		 return -EINVAL;
+
+	/* Set the fc mode and only restart an if link is up*/
+	status = i40e_set_fc(hw, &aq_failures, link_up);
+
+	if (aq_failures & I40E_SET_FC_AQ_FAIL_GET) {
+		netdev_info(netdev, "Set fc failed on the get_phy_capabilities call with error %d and status %d\n",
+			    status, hw->aq.asq_last_status);
+		err = -EAGAIN;
+	}
+	if (aq_failures & I40E_SET_FC_AQ_FAIL_SET) {
+		netdev_info(netdev, "Set fc failed on the set_phy_config call with error %d and status %d\n",
+			    status, hw->aq.asq_last_status);
+		err = -EAGAIN;
+	}
+	if (aq_failures & I40E_SET_FC_AQ_FAIL_UPDATE) {
+		netdev_info(netdev, "Set fc failed on the update_link_info call with error %d and status %d\n",
+			    status, hw->aq.asq_last_status);
+		err = -EAGAIN;
+	}
+
+	if (!test_bit(__I40E_DOWN, &pf->state))
+		return i40e_nway_reset(netdev);
+
+	return err;
+}
+
 static u32 i40e_get_msglevel(struct net_device *netdev)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
@@ -1866,6 +1941,7 @@ static const struct ethtool_ops i40e_ethtool_ops = {
 	.get_ringparam		= i40e_get_ringparam,
 	.set_ringparam		= i40e_set_ringparam,
 	.get_pauseparam		= i40e_get_pauseparam,
+	.set_pauseparam		= i40e_set_pauseparam,
 	.get_msglevel		= i40e_get_msglevel,
 	.set_msglevel		= i40e_set_msglevel,
 	.get_rxnfc		= i40e_get_rxnfc,
-- 
1.9.3
