From: Daniel Walker <danielwa@cisco.com>
Subject: [PATCH -v2] drivers: net: ethernet: intel: e1000e: fix ethtool autoneg off for non-copper
Date: Tue,  5 Apr 2016 11:30:03 -0700
Message-ID: <1459881004-13992-1-git-send-email-danielwa@cisco.com>
Cc: Steve Shih <sshih@cisco.com>, xe-kernel@external.cisco.com,
	Daniel Walker <dwalker@fifo99.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dima.ruinskiy@intel.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 6cab1f3..b6b8290 100644
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
 
@@ -236,8 +239,12 @@ static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx)
 		mac->forced_speed_duplex = ADVERTISE_100_FULL;
 		break;
 	case SPEED_1000 + DUPLEX_FULL:
-		mac->autoneg = 1;
-		adapter->hw.phy.autoneg_advertised = ADVERTISE_1000_FULL;
+		if (adapter->hw.phy.media_type == e1000_media_type_copper) {
+			mac->autoneg = 1;
+			adapter->hw.phy.autoneg_advertised =
+				ADVERTISE_1000_FULL;
+		} else
+			mac->forced_speed_duplex = ADVERTISE_1000_FULL;
 		break;
 	case SPEED_1000 + DUPLEX_HALF:	/* not supported */
 	default:
-- 
2.5.0
