From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [RFC NET-NEXT PATCH 4/6] e1000: configure and read MDI settings
Date: Wed, 25 Jul 2012 11:00:20 -0700
Message-ID: <20120725180020.9995.32923.stgit@jbrandeb-snb.jf.intel.com>
References: <20120725175430.9995.11370.stgit@jbrandeb-snb.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jesse.brandeburg@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57819 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751402Ab2GYUwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2012 16:52:04 -0400
In-Reply-To: <20120725175430.9995.11370.stgit@jbrandeb-snb.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this is the implementation in e1000 to allow ethtool to force
MDI state, allowing users to work around some improperly
behaving switches.

forcing in this driver is for now only allowed when auto-neg is enabled.

to use must have the matching version of ethtool app that supports
this functionality.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Tushar Dave <tushar.n.dave@intel.com>
---

 drivers/net/ethernet/intel/e1000/e1000_ethtool.c |   39 ++++++++++++++++++++++
 drivers/net/ethernet/intel/e1000/e1000_main.c    |    4 ++
 2 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 736a7d9..9089d00 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -174,6 +174,20 @@ static int e1000_get_settings(struct net_device *netdev,
 
 	ecmd->autoneg = ((hw->media_type == e1000_media_type_fiber) ||
 			 hw->autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+
+	/* MDI-X => 1; MDI => 0 */
+	if ((hw->media_type == e1000_media_type_copper) &&
+	    netif_carrier_ok(netdev))
+		ecmd->eth_tp_mdix = (!!adapter->phy_info.mdix_mode ?
+							ETH_TP_MDI_X :
+							ETH_TP_MDI);
+	else
+		ecmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
+
+	if (hw->mdix == AUTO_ALL_MODES)
+		ecmd->eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO;
+	else
+		ecmd->eth_tp_mdix_ctrl = hw->mdix;
 	return 0;
 }
 
@@ -183,6 +197,22 @@ static int e1000_set_settings(struct net_device *netdev,
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
+	/*
+	 * MDI setting is only allowed when autoneg enabled because
+	 * some hardware doesn't allow MDI setting when speed or
+	 * duplex is forced.
+	 */
+	if (ecmd->eth_tp_mdix_ctrl) {
+		if (hw->media_type != e1000_media_type_copper)
+			return -EOPNOTSUPP;
+
+		if ((ecmd->eth_tp_mdix_ctrl != ETH_TP_MDI_AUTO) &&
+		    (ecmd->autoneg != AUTONEG_ENABLE)) {
+			e_err(drv, "forcing MDI/MDI-X state is not supported when link speed and/or duplex are forced\n");
+			return -EINVAL;
+		}
+	}
+
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
 		msleep(1);
 
@@ -199,12 +229,21 @@ static int e1000_set_settings(struct net_device *netdev,
 		ecmd->advertising = hw->autoneg_advertised;
 	} else {
 		u32 speed = ethtool_cmd_speed(ecmd);
+		/* calling this overrides forced MDI setting */
 		if (e1000_set_spd_dplx(adapter, speed, ecmd->duplex)) {
 			clear_bit(__E1000_RESETTING, &adapter->flags);
 			return -EINVAL;
 		}
 	}
 
+	/* MDI-X => 2; MDI => 1; Auto => 3 */
+	if (ecmd->eth_tp_mdix_ctrl) {
+		if (ecmd->eth_tp_mdix_ctrl == ETH_TP_MDI_AUTO)
+			hw->mdix = AUTO_ALL_MODES;
+		else
+			hw->mdix = ecmd->eth_tp_mdix_ctrl;
+	}
+
 	/* reset the link */
 
 	if (netif_running(adapter->netdev)) {
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 3bfbb8d..0ae2fcf 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -4939,6 +4939,10 @@ int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx)
 	default:
 		goto err_inval;
 	}
+
+	/* clear MDI, MDI(-X) override is only allowed when autoneg enabled */
+	hw->mdix = AUTO_ALL_MODES;
+
 	return 0;
 
 err_inval:
