From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/12] igb: SerDes flow control setting
Date: Tue, 21 May 2013 15:03:15 -0700
Message-ID: <1369173800-20326-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:24090 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753341Ab3EUWDb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 18:03:31 -0400
In-Reply-To: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This path allows users to get appropriate flow control setting on SerDes
devices, based on original implementation for Copper devices.
Also, since 100baseFX does not support setting flow control, so exclude
it from the setting mechanism.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 34 ++++++++++++++++------------
 1 file changed, 19 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 4e54f84..7b25ee2 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -164,21 +164,6 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 			ecmd->advertising |= hw->phy.autoneg_advertised;
 		}
 
-		if (hw->mac.autoneg != 1)
-			ecmd->advertising &= ~(ADVERTISED_Pause |
-					       ADVERTISED_Asym_Pause);
-
-		if (hw->fc.requested_mode == e1000_fc_full)
-			ecmd->advertising |= ADVERTISED_Pause;
-		else if (hw->fc.requested_mode == e1000_fc_rx_pause)
-			ecmd->advertising |= (ADVERTISED_Pause |
-					      ADVERTISED_Asym_Pause);
-		else if (hw->fc.requested_mode == e1000_fc_tx_pause)
-			ecmd->advertising |=  ADVERTISED_Asym_Pause;
-		else
-			ecmd->advertising &= ~(ADVERTISED_Pause |
-					       ADVERTISED_Asym_Pause);
-
 		ecmd->port = PORT_TP;
 		ecmd->phy_address = hw->phy.addr;
 		ecmd->transceiver = XCVR_INTERNAL;
@@ -206,6 +191,21 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		ecmd->transceiver = XCVR_EXTERNAL;
 	}
 
+	if (hw->mac.autoneg != 1)
+		ecmd->advertising &= ~(ADVERTISED_Pause |
+				       ADVERTISED_Asym_Pause);
+
+	if (hw->fc.requested_mode == e1000_fc_full)
+		ecmd->advertising |= ADVERTISED_Pause;
+	else if (hw->fc.requested_mode == e1000_fc_rx_pause)
+		ecmd->advertising |= (ADVERTISED_Pause |
+				      ADVERTISED_Asym_Pause);
+	else if (hw->fc.requested_mode == e1000_fc_tx_pause)
+		ecmd->advertising |=  ADVERTISED_Asym_Pause;
+	else
+		ecmd->advertising &= ~(ADVERTISED_Pause |
+				       ADVERTISED_Asym_Pause);
+
 	status = rd32(E1000_STATUS);
 
 	if (status & E1000_STATUS_LU) {
@@ -386,6 +386,10 @@ static int igb_set_pauseparam(struct net_device *netdev,
 	struct e1000_hw *hw = &adapter->hw;
 	int retval = 0;
 
+	/* 100basefx does not support setting link flow control */
+	if (hw->dev_spec._82575.eth_flags.e100_base_fx)
+		return -EINVAL;
+
 	adapter->fc_autoneg = pause->autoneg;
 
 	while (test_and_set_bit(__IGB_RESETTING, &adapter->state))
-- 
1.7.11.7
