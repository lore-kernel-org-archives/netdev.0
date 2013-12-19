From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: add set settings and pauseparam
Date: Wed, 18 Dec 2013 22:34:41 -0800
Message-ID: <1387434891-19719-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387434891-19719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65348 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752467Ab3LSGe5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 01:34:57 -0500
In-Reply-To: <1387434891-19719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

This implements the set_settings and set_pauseparam ethtool
functionality.

Change-Id: I4634ee2c8bce00204edac7df9f0af4fb7bf33b75
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 97 ++++++++++++++++++++++++++
 1 file changed, 97 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 255a138..a12dd01 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -261,6 +261,61 @@ static int i40e_get_settings(struct net_device *netdev,
 }
 
 /**
+ * i40e_set_settings - Set Speed and Duplex
+ * @netdev: network interface device structure
+ * @ecmd: ethtool command
+ *
+ * Set speed/duplex per media_types advertised/forced
+ **/
+static int i40e_set_settings(struct net_device *netdev,
+			     struct ethtool_cmd *ecmd)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_pf *pf = np->vsi->back;
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_hw *hw = &pf->hw;
+	u32 old_link, advertised;
+	int err = 0;
+
+	if (vsi != pf->vsi[pf->lan_vsi])
+		return -EOPNOTSUPP;
+
+	while (test_and_set_bit(__I40E_CONFIG_BUSY, &vsi->state))
+		usleep_range(1000, 2000);
+
+	if ((hw->phy.media_type == I40E_MEDIA_TYPE_BASET) ||
+	    (hw->phy.media_type == I40E_MEDIA_TYPE_FIBER)) {
+		if (ecmd->autoneg == AUTONEG_DISABLE)
+			goto clear_reset;
+		if (ecmd->advertising & ~ecmd->supported)
+			goto clear_reset;
+		old_link = hw->phy.autoneg_advertised;
+		advertised = 0;
+
+		if (ecmd->advertising & (ADVERTISED_40000baseCR4_Full |
+					 ADVERTISED_40000baseKR4_Full |
+					 ADVERTISED_40000baseSR4_Full |
+					 ADVERTISED_40000baseLR4_Full))
+			advertised |= I40E_LINK_SPEED_40GB;
+		if (ecmd->advertising & (ADVERTISED_10000baseKX4_Full |
+					 ADVERTISED_10000baseKR_Full |
+					 ADVERTISED_10000baseT_Full))
+			advertised |= I40E_LINK_SPEED_10GB;
+		if (ecmd->advertising & ADVERTISED_1000baseT_Full)
+			advertised |= I40E_LINK_SPEED_1GB;
+		if (old_link == advertised) {
+			err = 0;
+			goto clear_reset;
+		}
+		hw->phy.get_link_info = true;
+	}
+clear_reset:
+	clear_bit(__I40E_CONFIG_BUSY, &vsi->state);
+
+	return err;
+}
+
+/**
  * i40e_get_pauseparam -  Get Flow Control status
  * Return tx/rx-pause status
  **/
@@ -286,6 +341,46 @@ static void i40e_get_pauseparam(struct net_device *netdev,
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
+	struct i40e_fc_info fc;
+
+	if (vsi != pf->vsi[pf->lan_vsi])
+		return -EOPNOTSUPP;
+
+	fc = hw->fc;
+	pf->fc_autoneg_status = pause->autoneg;
+
+	if ((pause->rx_pause && pause->tx_pause) || pause->autoneg)
+		fc.requested_mode = I40E_FC_FULL;
+	else if (pause->rx_pause && !pause->tx_pause)
+		fc.requested_mode = I40E_FC_RX_PAUSE;
+	else if (!pause->rx_pause && pause->tx_pause)
+		fc.requested_mode = I40E_FC_TX_PAUSE;
+	else if (!pause->rx_pause && !pause->tx_pause)
+		fc.requested_mode = I40E_FC_NONE;
+	else
+		 return -EINVAL;
+
+	fc.current_mode = fc.requested_mode;
+
+	/* if the status changed, then we will use updated autoneg*/
+	if (memcmp(&fc, &hw->fc, sizeof(struct i40e_fc_info)))
+		hw->fc = fc;
+
+	return 0;
+}
+
 static u32 i40e_get_msglevel(struct net_device *netdev)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
@@ -1599,6 +1694,7 @@ static int i40e_set_channels(struct net_device *dev,
 
 static const struct ethtool_ops i40e_ethtool_ops = {
 	.get_settings		= i40e_get_settings,
+	.set_settings		= i40e_set_settings,
 	.get_drvinfo		= i40e_get_drvinfo,
 	.get_regs_len		= i40e_get_regs_len,
 	.get_regs		= i40e_get_regs,
@@ -1611,6 +1707,7 @@ static const struct ethtool_ops i40e_ethtool_ops = {
 	.get_ringparam		= i40e_get_ringparam,
 	.set_ringparam		= i40e_set_ringparam,
 	.get_pauseparam		= i40e_get_pauseparam,
+	.set_pauseparam		= i40e_set_pauseparam,
 	.get_msglevel		= i40e_get_msglevel,
 	.set_msglevel		= i40e_set_msglevel,
 	.get_rxnfc		= i40e_get_rxnfc,
-- 
1.8.3.1
