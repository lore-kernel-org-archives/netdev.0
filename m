From: Daniel Walker <danielwa@cisco.com>
Subject: [PATCH-RFC] drivers: net: ethernet: intel: e1000e: fix ethtool autoneg off for fiber
Date: Fri, 25 Mar 2016 14:58:46 -0700
Message-ID: <1458943126-32258-1-git-send-email-danielwa@cisco.com>
Cc: Steve Shih <sshih@cisco.com>, danielwa@fifo99.com,
	xe-kernel@external.cisco.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-8.cisco.com ([173.37.86.79]:11857 "EHLO
	rcdn-iport-8.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595AbcCYWI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 18:08:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Shih <sshih@cisco.com>

This patch fixes the issues for disabling auto-negotiation and forcing
speed and duplex settings for the fiber media.

For fiber media, e1000_get_settings should return ETH_TP_MDI_INVALID for
eth_tp_mdix_ctrl instead of ETH_TP_MDI_AUTO so subsequent e1000_set_settings
call would not fail with -EOPNOTSUPP.

e1000_set_spd_dplx should not automatically turn autoneg back on for forced
1000 Mbps full duplex settings.

Cc: danielwa@fifo99.com
Cc: xe-kernel@external.cisco.com
Signed-off-by: Steve Shih <sshih@cisco.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 6cab1f3..cd03dcd 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -201,6 +201,9 @@ static int e1000_get_settings(struct net_device *netdev,
 	else
 		ecmd->eth_tp_mdix_ctrl = hw->phy.mdix;
 
+	if (hw->phy.media_type != e1000_media_type_copper)
+		ecmd->eth_tp_mdix_ctrl = ETH_TP_MDI_INVALID;
+
 	return 0;
 }
 
@@ -236,8 +239,7 @@ static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx)
 		mac->forced_speed_duplex = ADVERTISE_100_FULL;
 		break;
 	case SPEED_1000 + DUPLEX_FULL:
-		mac->autoneg = 1;
-		adapter->hw.phy.autoneg_advertised = ADVERTISE_1000_FULL;
+		mac->forced_speed_duplex = ADVERTISE_1000_FULL;
 		break;
 	case SPEED_1000 + DUPLEX_HALF:	/* not supported */
 	default:
-- 
2.5.0
