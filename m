From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] i40e: fix link reporting
Date: Fri, 13 Oct 2017 14:52:48 -0700
Message-ID: <20171013215249.61286-9-jeffrey.t.kirsher@intel.com>
References: <20171013215249.61286-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:20274 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752779AbdJMVxS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Oct 2017 17:53:18 -0400
In-Reply-To: <20171013215249.61286-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

When querying the NVM for supported phy_types, on some firmware
versions, we were failing to actually fill out the phy_types which means
ethtool wouldn't report any link types.

Testing-hints:
Check 'ethtool <iface>' if you have the right (wrong?) firmware.
Without this patch, no link modes will be reported.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 53aad378d49c..aeb497258f20 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1611,8 +1611,13 @@ i40e_status i40e_aq_get_phy_capabilities(struct i40e_hw *hw,
 	if (report_init) {
 		if (hw->mac.type ==  I40E_MAC_XL710 &&
 		    hw->aq.api_maj_ver == I40E_FW_API_VERSION_MAJOR &&
-		    hw->aq.api_min_ver >= I40E_MINOR_VER_GET_LINK_INFO_XL710)
+		    hw->aq.api_min_ver >= I40E_MINOR_VER_GET_LINK_INFO_XL710) {
 			status = i40e_aq_get_link_info(hw, true, NULL, NULL);
+		} else {
+			hw->phy.phy_types = le32_to_cpu(abilities->phy_type);
+			hw->phy.phy_types |=
+					((u64)abilities->phy_type_ext << 32);
+		}
 	}
 
 	return status;
-- 
2.14.2
