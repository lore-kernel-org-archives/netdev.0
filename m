From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] e1000e: implement MDI/MDI-X control
Date: Tue, 21 Aug 2012 01:37:54 -0700
Message-ID: <1345538275-1690-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1345538275-1690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	bruce.w.allan@intel.com, n.poppelier@xs4all.nl, bastien@durel.org,
	jsveiga@it.eng.br, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54114 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754037Ab2HUIiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 04:38:00 -0400
In-Reply-To: <1345538275-1690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Some users report issues with link failing when connected to certain
switches.  This gives the user the ability to control the MDI state
from the driver, allowing users to work around some improperly
behaving switches.

Forcing in this driver is for now only allowed when auto-neg is
enabled.

This is in regards to the related ethtool app patch and
bugzilla.kernel.org bug 11998

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: bruce.w.allan@intel.com
CC: n.poppelier@xs4all.nl
CC: bastien@durel.org
CC: jsveiga@it.eng.br
Tested-by: Aaron Brown aaron.f.brown@intel.com
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 41 +++++++++++++++++++++++++++--
 1 file changed, 39 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 0349e24..2e76f06 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -199,6 +199,11 @@ static int e1000_get_settings(struct net_device *netdev,
 	else
 		ecmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
 
+	if (hw->phy.mdix == AUTO_ALL_MODES)
+		ecmd->eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO;
+	else
+		ecmd->eth_tp_mdix_ctrl = hw->phy.mdix;
+
 	return 0;
 }
 
@@ -241,6 +246,10 @@ static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx)
 	default:
 		goto err_inval;
 	}
+
+	/* clear MDI, MDI(-X) override is only allowed when autoneg enabled */
+	adapter->hw.phy.mdix = AUTO_ALL_MODES;
+
 	return 0;
 
 err_inval:
@@ -264,6 +273,22 @@ static int e1000_set_settings(struct net_device *netdev,
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
+			e_err("forcing MDI/MDI-X state is not supported when link speed and/or duplex are forced\n");
+			return -EINVAL;
+		}
+	}
+
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
 		usleep_range(1000, 2000);
 
@@ -282,20 +307,32 @@ static int e1000_set_settings(struct net_device *netdev,
 			hw->fc.requested_mode = e1000_fc_default;
 	} else {
 		u32 speed = ethtool_cmd_speed(ecmd);
+		/* calling this overrides forced MDI setting */
 		if (e1000_set_spd_dplx(adapter, speed, ecmd->duplex)) {
 			clear_bit(__E1000_RESETTING, &adapter->state);
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
 		e1000e_down(adapter);
 		e1000e_up(adapter);
-	} else {
+	} else
 		e1000e_reset(adapter);
-	}
 
 	clear_bit(__E1000_RESETTING, &adapter->state);
 	return 0;
-- 
1.7.11.4
