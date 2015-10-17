From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/17] i40e: Fix order of checks when enabling/disabling autoneg in ethtool
Date: Fri, 16 Oct 2015 22:28:27 -0700
Message-ID: <1445059711-45992-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32353 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124AbbJQF2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 01:28:43 -0400
In-Reply-To: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

We were previously checking if autoneg was allowed to change before
checking if autoneg was changing. We need to do this in the other order
or else we will erroneously return EINVAL when autoneg is not changing.

Change-ID: Iff9f7d1c9bddc1ad1e5d227d4f42754f90155410
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 29 ++++++++++++++------------
 1 file changed, 16 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 767b1db..6e5f931 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -661,28 +661,31 @@ static int i40e_set_settings(struct net_device *netdev,
 
 	/* Check autoneg */
 	if (autoneg == AUTONEG_ENABLE) {
-		/* If autoneg is not supported, return error */
-		if (!(safe_ecmd.supported & SUPPORTED_Autoneg)) {
-			netdev_info(netdev, "Autoneg not supported on this phy\n");
-			return -EINVAL;
-		}
 		/* If autoneg was not already enabled */
 		if (!(hw->phy.link_info.an_info & I40E_AQ_AN_COMPLETED)) {
+			/* If autoneg is not supported, return error */
+			if (!(safe_ecmd.supported & SUPPORTED_Autoneg)) {
+				netdev_info(netdev, "Autoneg not supported on this phy\n");
+				return -EINVAL;
+			}
+			/* Autoneg is allowed to change */
 			config.abilities = abilities.abilities |
 					   I40E_AQ_PHY_ENABLE_AN;
 			change = true;
 		}
 	} else {
-		/* If autoneg is supported 10GBASE_T is the only phy that
-		 * can disable it, so otherwise return error
-		 */
-		if (safe_ecmd.supported & SUPPORTED_Autoneg &&
-		    hw->phy.link_info.phy_type != I40E_PHY_TYPE_10GBASE_T) {
-			netdev_info(netdev, "Autoneg cannot be disabled on this phy\n");
-			return -EINVAL;
-		}
 		/* If autoneg is currently enabled */
 		if (hw->phy.link_info.an_info & I40E_AQ_AN_COMPLETED) {
+			/* If autoneg is supported 10GBASE_T is the only PHY
+			 * that can disable it, so otherwise return error
+			 */
+			if (safe_ecmd.supported & SUPPORTED_Autoneg &&
+			    hw->phy.link_info.phy_type !=
+			    I40E_PHY_TYPE_10GBASE_T) {
+				netdev_info(netdev, "Autoneg cannot be disabled on this phy\n");
+				return -EINVAL;
+			}
+			/* Autoneg is allowed to change */
 			config.abilities = abilities.abilities &
 					   ~I40E_AQ_PHY_ENABLE_AN;
 			change = true;
-- 
2.4.3
