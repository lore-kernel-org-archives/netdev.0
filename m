From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 14/14] ixgbe: fix setting and reporting of advertised speeds
Date: Mon,  7 Mar 2011 18:25:08 -0800
Message-ID: <1299551108-23663-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14586 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756078Ab1CHC0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 21:26:08 -0500
In-Reply-To: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Add the ability to set 100/F on x540.
Fix reporting of advertised modes by adding check for phy.autoneg_advertised

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |   41 ++++++++++++++++++-------------------
 1 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 83511c0..76380a2 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -161,29 +161,25 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		}
 
 		ecmd->advertising = ADVERTISED_Autoneg;
-		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_100_FULL)
-			ecmd->advertising |= ADVERTISED_100baseT_Full;
-		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
-			ecmd->advertising |= ADVERTISED_10000baseT_Full;
-		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL)
-			ecmd->advertising |= ADVERTISED_1000baseT_Full;
-		/*
-		 * It's possible that phy.autoneg_advertised may not be
-		 * set yet.  If so display what the default would be -
-		 * both 1G and 10G supported.
-		 */
-		if (!(ecmd->advertising & (ADVERTISED_1000baseT_Full |
-					   ADVERTISED_10000baseT_Full)))
+		if (hw->phy.autoneg_advertised) {
+			if (hw->phy.autoneg_advertised &
+			    IXGBE_LINK_SPEED_100_FULL)
+				ecmd->advertising |= ADVERTISED_100baseT_Full;
+			if (hw->phy.autoneg_advertised &
+			    IXGBE_LINK_SPEED_10GB_FULL)
+				ecmd->advertising |= ADVERTISED_10000baseT_Full;
+			if (hw->phy.autoneg_advertised &
+			    IXGBE_LINK_SPEED_1GB_FULL)
+				ecmd->advertising |= ADVERTISED_1000baseT_Full;
+		} else {
+			/*
+			 * Default advertised modes in case
+			 * phy.autoneg_advertised isn't set.
+			 */
 			ecmd->advertising |= (ADVERTISED_10000baseT_Full |
 					      ADVERTISED_1000baseT_Full);
-
-		switch (hw->mac.type) {
-		case ixgbe_mac_X540:
-			if (!(ecmd->advertising & ADVERTISED_100baseT_Full))
-				ecmd->advertising |= (ADVERTISED_100baseT_Full);
-			break;
-		default:
-			break;
+			if (hw->mac.type == ixgbe_mac_X540)
+				ecmd->advertising |= ADVERTISED_100baseT_Full;
 		}
 
 		if (hw->phy.media_type == ixgbe_media_type_copper) {
@@ -336,6 +332,9 @@ static int ixgbe_set_settings(struct net_device *netdev,
 		if (ecmd->advertising & ADVERTISED_1000baseT_Full)
 			advertised |= IXGBE_LINK_SPEED_1GB_FULL;
 
+		if (ecmd->advertising & ADVERTISED_100baseT_Full)
+			advertised |= IXGBE_LINK_SPEED_100_FULL;
+
 		if (old == advertised)
 			return err;
 		/* this sets the link speed and restarts auto-neg */
-- 
1.7.4

