From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: do not enter PHY debug mode while setting LEDs behaviour
Date: Fri,  6 Oct 2017 10:57:24 -0700
Message-ID: <20171006175727.868-13-jeffrey.t.kirsher@intel.com>
References: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Cc: Mariusz Stachura <mariusz.stachura@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12575 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752618AbdJFR5w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 13:57:52 -0400
In-Reply-To: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mariusz Stachura <mariusz.stachura@intel.com>

Previous implementation of LED set/get functions required to enter
PHY debug mode, in order to prevent access to it from FW and SW at
the same time. Reset of all ports was a unwanted side effect.

Signed-off-by: Mariusz Stachura <mariusz.stachura@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 6203d362438c..de0dfe340494 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2010,7 +2010,9 @@ static int i40e_set_phys_id(struct net_device *netdev,
 		if (!(pf->hw_features & I40E_HW_PHY_CONTROLS_LEDS)) {
 			pf->led_status = i40e_led_get(hw);
 		} else {
-			i40e_aq_set_phy_debug(hw, I40E_PHY_DEBUG_ALL, NULL);
+			if (!(hw->flags & I40E_HW_FLAG_AQ_PHY_ACCESS_CAPABLE))
+				i40e_aq_set_phy_debug(hw, I40E_PHY_DEBUG_ALL,
+						      NULL);
 			ret = i40e_led_get_phy(hw, &temp_status,
 					       &pf->phy_led_val);
 			pf->led_status = temp_status;
@@ -2035,7 +2037,8 @@ static int i40e_set_phys_id(struct net_device *netdev,
 			ret = i40e_led_set_phy(hw, false, pf->led_status,
 					       (pf->phy_led_val |
 					       I40E_PHY_LED_MODE_ORIG));
-			i40e_aq_set_phy_debug(hw, 0, NULL);
+			if (!(hw->flags & I40E_HW_FLAG_AQ_PHY_ACCESS_CAPABLE))
+				i40e_aq_set_phy_debug(hw, 0, NULL);
 		}
 		break;
 	default:
-- 
2.14.2
