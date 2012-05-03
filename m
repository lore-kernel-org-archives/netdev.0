From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] ixgbevf: Add support to recognize 100mb link speed
Date: Thu,  3 May 2012 02:56:30 -0700
Message-ID: <1336038992-3144-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49879 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754720Ab2ECJ4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 05:56:36 -0400
In-Reply-To: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The X540 10Gig controller is capable of linking at 100Mbits - add
support for reporting that link speed.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/defines.h |    2 ++
 drivers/net/ethernet/intel/ixgbevf/ethtool.c |   18 ++++++++++++++----
 drivers/net/ethernet/intel/ixgbevf/vf.c      |   12 +++++++++---
 3 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/defines.h b/drivers/net/ethernet/intel/ixgbevf/defines.h
index 947b5c8..e09a6cc 100644
--- a/drivers/net/ethernet/intel/ixgbevf/defines.h
+++ b/drivers/net/ethernet/intel/ixgbevf/defines.h
@@ -40,6 +40,7 @@
 typedef u32 ixgbe_link_speed;
 #define IXGBE_LINK_SPEED_1GB_FULL       0x0020
 #define IXGBE_LINK_SPEED_10GB_FULL      0x0080
+#define IXGBE_LINK_SPEED_100_FULL	0x0008
 
 #define IXGBE_CTRL_RST              0x04000000 /* Reset (SW) */
 #define IXGBE_RXDCTL_ENABLE         0x02000000 /* Enable specific Rx Queue */
@@ -48,6 +49,7 @@ typedef u32 ixgbe_link_speed;
 #define IXGBE_LINKS_SPEED_82599     0x30000000
 #define IXGBE_LINKS_SPEED_10G_82599 0x30000000
 #define IXGBE_LINKS_SPEED_1G_82599  0x20000000
+#define IXGBE_LINKS_SPEED_100_82599 0x10000000
 
 /* Number of Transmit and Receive Descriptors must be a multiple of 8 */
 #define IXGBE_REQ_TX_DESCRIPTOR_MULTIPLE  8
diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index 2bfe0d1..e8dddf5 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -107,10 +107,20 @@ static int ixgbevf_get_settings(struct net_device *netdev,
 	hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
 
 	if (link_up) {
-		ethtool_cmd_speed_set(
-			ecmd,
-			(link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
-			SPEED_10000 : SPEED_1000);
+		__u32 speed = SPEED_10000;
+		switch (link_speed) {
+		case IXGBE_LINK_SPEED_10GB_FULL:
+			speed = SPEED_10000;
+			break;
+		case IXGBE_LINK_SPEED_1GB_FULL:
+			speed = SPEED_1000;
+			break;
+		case IXGBE_LINK_SPEED_100_FULL:
+			speed = SPEED_100;
+			break;
+		}
+
+		ethtool_cmd_speed_set(ecmd, speed);
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
 		ethtool_cmd_speed_set(ecmd, -1);
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 74be741..ec89b86 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -404,11 +404,17 @@ static s32 ixgbevf_check_mac_link_vf(struct ixgbe_hw *hw,
 	else
 		*link_up = false;
 
-	if ((links_reg & IXGBE_LINKS_SPEED_82599) ==
-	    IXGBE_LINKS_SPEED_10G_82599)
+	switch (links_reg & IXGBE_LINKS_SPEED_82599) {
+	case IXGBE_LINKS_SPEED_10G_82599:
 		*speed = IXGBE_LINK_SPEED_10GB_FULL;
-	else
+		break;
+	case IXGBE_LINKS_SPEED_1G_82599:
 		*speed = IXGBE_LINK_SPEED_1GB_FULL;
+		break;
+	case IXGBE_LINKS_SPEED_100_82599:
+		*speed = IXGBE_LINK_SPEED_100_FULL;
+		break;
+	}
 
 	return 0;
 }
-- 
1.7.7.6
