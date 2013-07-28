From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/12] e1000e: iAMT connections drop on driver unload when jumbo frames enabled
Date: Sun, 28 Jul 2013 04:41:10 -0700
Message-ID: <1375011676-30739-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43491 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753500Ab3G1Ll2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jul 2013 07:41:28 -0400
In-Reply-To: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The jumbo frame configuration in the MAC/PHY should be reverted on 82579
and newer parts when the interface is brought down (not just when the MTU
is changed back to standard frame size) otherwise iAMT connections (e.g.
SoL, IDE-R) will be dropped and cannot be re-acquired until the MTU is
changed again.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 40e6232..99596a6 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2979,17 +2979,10 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	u32 pages = 0;
 
 	/* Workaround Si errata on PCHx - configure jumbo frame flow */
-	if (hw->mac.type >= e1000_pch2lan) {
-		s32 ret_val;
-
-		if (adapter->netdev->mtu > ETH_DATA_LEN)
-			ret_val = e1000_lv_jumbo_workaround_ich8lan(hw, true);
-		else
-			ret_val = e1000_lv_jumbo_workaround_ich8lan(hw, false);
-
-		if (ret_val)
-			e_dbg("failed to enable jumbo frame workaround mode\n");
-	}
+	if ((hw->mac.type >= e1000_pch2lan) &&
+	    (adapter->netdev->mtu > ETH_DATA_LEN) &&
+	    e1000_lv_jumbo_workaround_ich8lan(hw, true))
+		e_dbg("failed to enable jumbo frame workaround mode\n");
 
 	/* Program MC offset vector base */
 	rctl = er32(RCTL);
@@ -4034,6 +4027,12 @@ void e1000e_down(struct e1000_adapter *adapter)
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 
+	/* Disable Si errata workaround on PCHx for jumbo frame flow */
+	if ((hw->mac.type >= e1000_pch2lan) &&
+	    (adapter->netdev->mtu > ETH_DATA_LEN) &&
+	    e1000_lv_jumbo_workaround_ich8lan(hw, false))
+		e_dbg("failed to disable jumbo frame workaround mode\n");
+
 	if (!pci_channel_offline(adapter->pdev))
 		e1000e_reset(adapter);
 
-- 
1.7.11.7
