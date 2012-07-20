From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/6] igb: update to allow reading/setting MDI state
Date: Fri, 20 Jul 2012 14:43:51 -0700
Message-ID: <1342820631-19738-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342820631-19738-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3794 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750711Ab2GTVn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2012 17:43:57 -0400
In-Reply-To: <1342820631-19738-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This is the implementation for igb to allow forcing MDI state
via ethtool, allowing users to work around some improperly
behaving switches.

get_settings will now return the MDI state of the last link
because get_settings needs to succeed to allow the set to work even
when link is down.

Forcing in this driver is for now only allowed when auto-neg is
enabled.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   37 ++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/igb_main.c    |    4 +++
 2 files changed, 41 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index a19c84c..bc3c5b4 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -198,6 +198,14 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	}
 
 	ecmd->autoneg = hw->mac.autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+
+	/* MDI-X => 2; MDI =>1; Invalid =>0 */
+	if (hw->phy.media_type == e1000_media_type_copper)
+		ecmd->eth_tp_mdix = hw->phy.is_mdix ? ETH_TP_MDI_X :
+						      ETH_TP_MDI;
+	else
+		ecmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
+
 	return 0;
 }
 
@@ -214,6 +222,22 @@ static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		return -EINVAL;
 	}
 
+	/*
+	 * MDI setting is only allowed when autoneg enabled because
+	 * some hardware doesn't allow MDI setting when speed or
+	 * duplex is forced.
+	 */
+	if (ecmd->eth_tp_mdix_ctrl) {
+		if (hw->phy.media_type != e1000_media_type_copper)
+			return -EOPNOTSUPP;
+
+		if ((ecmd->eth_tp_mdix_ctrl != ETH_TP_MDI_AUTO) &&
+		    (ecmd->autoneg != AUTONEG_ENABLE)) {
+			dev_err(&adapter->pdev->dev, "forcing MDI/MDI-X state is not supported when link speed and/or duplex are forced\n");
+			return -EINVAL;
+		}
+	}
+
 	while (test_and_set_bit(__IGB_RESETTING, &adapter->state))
 		msleep(1);
 
@@ -227,12 +251,25 @@ static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 			hw->fc.requested_mode = e1000_fc_default;
 	} else {
 		u32 speed = ethtool_cmd_speed(ecmd);
+		/* calling this overrides forced MDI setting */
 		if (igb_set_spd_dplx(adapter, speed, ecmd->duplex)) {
 			clear_bit(__IGB_RESETTING, &adapter->state);
 			return -EINVAL;
 		}
 	}
 
+	/* MDI-X => 2; MDI => 1; Auto => 3 */
+	if (ecmd->eth_tp_mdix_ctrl) {
+		/*
+		 * fix up the value for auto (3 => 0) as zero is mapped
+		 * internally to auto
+		 */
+		if (ecmd->eth_tp_mdix_ctrl == ETH_TP_MDI_AUTO)
+			hw->phy.mdix = AUTO_ALL_MODES;
+		else
+			hw->phy.mdix = ecmd->eth_tp_mdix_ctrl;
+	}
+
 	/* reset the link */
 	if (netif_running(adapter->netdev)) {
 		igb_down(adapter);
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 8adeca9..4df7848 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6675,6 +6675,10 @@ int igb_set_spd_dplx(struct igb_adapter *adapter, u32 spd, u8 dplx)
 	default:
 		goto err_inval;
 	}
+
+	/* clear MDI, MDI(-X) override is only allowed when autoneg enabled */
+	adapter->hw.phy.mdix = AUTO_ALL_MODES;
+
 	return 0;
 
 err_inval:
-- 
1.7.10.4
