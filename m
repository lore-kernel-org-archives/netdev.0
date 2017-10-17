From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: fix clearing link masks in i40e_get_link_ksettings
Date: Tue, 17 Oct 2017 11:21:08 -0700
Message-ID: <20171017182119.71989-5-jeffrey.t.kirsher@intel.com>
References: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17770 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934588AbdJQSVn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 14:21:43 -0400
In-Reply-To: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

This fixes two issues in i40e_get_link_ksettings.  It adds calls to
ethtool_link_ksettings_zero_link_mode to make sure advertising and
supported link masks are cleared before we start setting bits in them.

This also replaces some funky bit manipulations with a much nicer call
to ethtool_link_ksettings_del_link_mode when removing link modes.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index f4a70ef3f2e0..fe0b2327de5b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -600,7 +600,9 @@ static int i40e_get_link_ksettings(struct net_device *netdev,
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_link_status *hw_link_info = &hw->phy.link_info;
 	bool link_up = hw_link_info->link_info & I40E_AQ_LINK_UP;
-	u32 advertising;
+
+	ethtool_link_ksettings_zero_link_mode(ks, supported);
+	ethtool_link_ksettings_zero_link_mode(ks, advertising);
 
 	if (link_up)
 		i40e_get_settings_link_up(hw, ks, netdev, pf);
@@ -664,13 +666,9 @@ static int i40e_get_link_ksettings(struct net_device *netdev,
 						     Asym_Pause);
 		break;
 	default:
-		ethtool_convert_link_mode_to_legacy_u32(
-			&advertising, ks->link_modes.advertising);
-
-		advertising &= ~(ADVERTISED_Pause | ADVERTISED_Asym_Pause);
-
-		ethtool_convert_legacy_u32_to_link_mode(
-			ks->link_modes.advertising, advertising);
+		ethtool_link_ksettings_del_link_mode(ks, advertising, Pause);
+		ethtool_link_ksettings_del_link_mode(ks, advertising,
+						     Asym_Pause);
 		break;
 	}
 
-- 
2.14.2
