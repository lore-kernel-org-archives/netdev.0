From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/6] ixgbe: limit setting speed to only one at a time for QSFP modules
Date: Fri, 13 Sep 2013 14:12:07 -0700
Message-ID: <1379106730-14994-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1379106730-14994-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38706 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753708Ab3IMVMT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Sep 2013 17:12:19 -0400
In-Reply-To: <1379106730-14994-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

QSFP+ modules do not support auto negotiation and should advertise only
one speed at a time.

This patch adds logic in ethtool to allow setting and reporting the
advertised speed at either 1Gbps or 10Gbps, but not both. Also limits
the speed set in ixgbe_sfp_link_config_subtask() to highest supported.
Previously the link was set to whatever the supported speeds were.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 13 +++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 10 +++++++++-
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 08efc253..b41db3b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -186,6 +186,11 @@ static int ixgbe_get_settings(struct net_device *netdev,
 			ecmd->advertising |= ADVERTISED_1000baseT_Full;
 		if (supported_link & IXGBE_LINK_SPEED_100_FULL)
 			ecmd->advertising |= ADVERTISED_100baseT_Full;
+
+		if (hw->phy.multispeed_fiber && !autoneg) {
+			if (supported_link & IXGBE_LINK_SPEED_10GB_FULL)
+				ecmd->advertising = ADVERTISED_10000baseT_Full;
+		}
 	}
 
 	if (autoneg) {
@@ -314,6 +319,14 @@ static int ixgbe_set_settings(struct net_device *netdev,
 		if (ecmd->advertising & ~ecmd->supported)
 			return -EINVAL;
 
+		/* only allow one speed at a time if no autoneg */
+		if (!ecmd->autoneg && hw->phy.multispeed_fiber) {
+			if (ecmd->advertising ==
+			    (ADVERTISED_10000baseT_Full |
+			     ADVERTISED_1000baseT_Full))
+				return -EINVAL;
+		}
+
 		old = hw->phy.autoneg_advertised;
 		advertised = 0;
 		if (ecmd->advertising & ADVERTISED_10000baseT_Full)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ae26786..0ade0cd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6000,8 +6000,16 @@ static void ixgbe_sfp_link_config_subtask(struct ixgbe_adapter *adapter)
 	adapter->flags &= ~IXGBE_FLAG_NEED_LINK_CONFIG;
 
 	speed = hw->phy.autoneg_advertised;
-	if ((!speed) && (hw->mac.ops.get_link_capabilities))
+	if ((!speed) && (hw->mac.ops.get_link_capabilities)) {
 		hw->mac.ops.get_link_capabilities(hw, &speed, &autoneg);
+
+		/* setup the highest link when no autoneg */
+		if (!autoneg) {
+			if (speed & IXGBE_LINK_SPEED_10GB_FULL)
+				speed = IXGBE_LINK_SPEED_10GB_FULL;
+		}
+	}
+
 	if (hw->mac.ops.setup_link)
 		hw->mac.ops.setup_link(hw, speed, true);
 
-- 
1.8.3.1
