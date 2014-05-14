From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] ixgbe: fix detection of SFP+ capable interfaces
Date: Wed, 14 May 2014 01:54:13 -0700
Message-ID: <1400057663-4578-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6717 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753306AbaENIye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 04:54:34 -0400
In-Reply-To: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

In cases where the driver is loaded while there are no SFP+ modules in
the cage the interface was not being detected as SFP capable. To account
for this the driver called identify_sfp in ixgbe_get_settings to make
sure the data is correct. However when there is no SFP+ module in the cage
the driver waits for the I2C reads to time out which can take more than a
second and will cause issues with tools (like net-snmp) that may poll
for that information.

This patch resolves the issue by identifying 82599 based NIC with no PHY
type set as SFP capable which allows the driver to detect the SFP module
when the interface is brought up. As result of this we can also remove the
identify_sfp call from ixgbe_get_settings.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 7 -------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 4 ++++
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 31d7268..1e701d3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -161,13 +161,6 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	bool autoneg = false;
 	bool link_up;
 
-	/* SFP type is needed for get_link_capabilities */
-	if (hw->phy.media_type & (ixgbe_media_type_fiber |
-				  ixgbe_media_type_fiber_qsfp)) {
-		if (hw->phy.sfp_type == ixgbe_sfp_type_not_present)
-				hw->phy.ops.identify_sfp(hw);
-	}
-
 	hw->mac.ops.get_link_capabilities(hw, &supported_link, &autoneg);
 
 	/* set the supported link speeds */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 8089ea9..e44c42a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4660,6 +4660,10 @@ static inline bool ixgbe_is_sfp(struct ixgbe_hw *hw)
 	case ixgbe_phy_nl:
 		if (hw->mac.type == ixgbe_mac_82598EB)
 			return true;
+	/* ixgbe_phy_none is set when no SFP module is present */
+	case ixgbe_phy_none:
+		if (hw->mac.type == ixgbe_mac_82599EB)
+			return true;
 	default:
 		return false;
 	}
-- 
1.9.0
