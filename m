From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 06/10] ixgbe: fix smatch splat due to missing NULL check
Date: Wed,  2 Nov 2011 17:19:57 -0700
Message-ID: <1320279601-1276-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64280 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754281Ab1KCAUI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 20:20:08 -0400
In-Reply-To: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

ixgbe_ieee_ets and ixgbe_ieee_pfc are intialized at
the same time. Do a check for both before configuring
IEEE802.1Qaz. Also max_frame was causing a sparse
warning resolved here as well.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   33 +++++++++----------------
 1 files changed, 12 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2e9fd9d..8ef92d1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3345,34 +3345,25 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 
 	hw->mac.ops.set_vfta(&adapter->hw, 0, 0, true);
 
-	/* reconfigure the hardware */
-	if (adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE) {
 #ifdef IXGBE_FCOE
-		if (adapter->netdev->features & NETIF_F_FCOE_MTU)
-			max_frame = max(max_frame, IXGBE_FCOE_JUMBO_FRAME_SIZE);
+	if (adapter->netdev->features & NETIF_F_FCOE_MTU)
+		max_frame = max(max_frame, IXGBE_FCOE_JUMBO_FRAME_SIZE);
 #endif
+
+	/* reconfigure the hardware */
+	if (adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE) {
 		ixgbe_dcb_calculate_tc_credits(hw, &adapter->dcb_cfg, max_frame,
 						DCB_TX_CONFIG);
 		ixgbe_dcb_calculate_tc_credits(hw, &adapter->dcb_cfg, max_frame,
 						DCB_RX_CONFIG);
 		ixgbe_dcb_hw_config(hw, &adapter->dcb_cfg);
-	} else {
-		struct net_device *dev = adapter->netdev;
-
-		if (adapter->ixgbe_ieee_ets) {
-			struct ieee_ets *ets = adapter->ixgbe_ieee_ets;
-			int max_frame = dev->mtu + ETH_HLEN + ETH_FCS_LEN;
-
-			ixgbe_dcb_hw_ets(&adapter->hw, ets, max_frame);
-		}
-
-		if (adapter->ixgbe_ieee_pfc) {
-			struct ieee_pfc *pfc = adapter->ixgbe_ieee_pfc;
-			u8 *prio_tc = adapter->ixgbe_ieee_ets->prio_tc;
-
-			ixgbe_dcb_hw_pfc_config(&adapter->hw, pfc->pfc_en,
-						prio_tc);
-		}
+	} else if (adapter->ixgbe_ieee_ets && adapter->ixgbe_ieee_pfc) {
+		ixgbe_dcb_hw_ets(&adapter->hw,
+				 adapter->ixgbe_ieee_ets,
+				 max_frame);
+		ixgbe_dcb_hw_pfc_config(&adapter->hw,
+					adapter->ixgbe_ieee_pfc->pfc_en,
+					adapter->ixgbe_ieee_ets->prio_tc);
 	}
 
 	/* Enable RSS Hash per TC */
-- 
1.7.6.4
