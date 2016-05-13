From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] e1000e: fix ethtool autoneg off for non-copper
Date: Fri, 13 May 2016 16:43:42 -0700
Message-ID: <1463183035-31888-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Steve Shih <sshih@cisco.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	xe-kernel@external.cisco.com, Daniel Walker <dwalker@fifo99.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:13874 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753196AbcEMXn6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 19:43:58 -0400
In-Reply-To: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Shih <sshih@cisco.com>

This patch fixes the issues for disabling auto-negotiation and forcing
speed and duplex settings for the non-copper media.

For non-copper media, e1000_get_settings should return ETH_TP_MDI_INVALID for
eth_tp_mdix_ctrl instead of ETH_TP_MDI_AUTO so subsequent e1000_set_settings
call would not fail with -EOPNOTSUPP.

e1000_set_spd_dplx should not automatically turn autoneg back on for forced
1000 Mbps full duplex settings for non-copper media.

Cc: xe-kernel@external.cisco.com
Cc: Daniel Walker <dwalker@fifo99.com>
Signed-off-by: Steve Shih <sshih@cisco.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 1e3973a..83a815b 100644
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
 
@@ -236,8 +239,13 @@ static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx)
 		mac->forced_speed_duplex = ADVERTISE_100_FULL;
 		break;
 	case SPEED_1000 + DUPLEX_FULL:
-		mac->autoneg = 1;
-		adapter->hw.phy.autoneg_advertised = ADVERTISE_1000_FULL;
+		if (adapter->hw.phy.media_type == e1000_media_type_copper) {
+			mac->autoneg = 1;
+			adapter->hw.phy.autoneg_advertised =
+				ADVERTISE_1000_FULL;
+		} else {
+			mac->forced_speed_duplex = ADVERTISE_1000_FULL;
+		}
 		break;
 	case SPEED_1000 + DUPLEX_HALF:	/* not supported */
 	default:
-- 
2.5.5
