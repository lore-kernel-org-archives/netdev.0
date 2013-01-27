From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] e1000e: fix flow-control thresholds for jumbo frames on 82579/I217/I218
Date: Sun, 27 Jan 2013 02:39:41 -0800
Message-ID: <1359283193-2043-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35700 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756426Ab3A0Kj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 05:39:57 -0500
In-Reply-To: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The previous static flow-control thresholds were causing unnecessary pause
packets to be transmitted when jumbo frames are configured reducing the
throughput.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index c15b7e4..8bb5d28 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3724,14 +3724,17 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		break;
 	case e1000_pch2lan:
 	case e1000_pch_lpt:
-		fc->high_water = 0x05C20;
-		fc->low_water = 0x05048;
-		fc->pause_time = 0x0650;
 		fc->refresh_time = 0x0400;
-		if (adapter->netdev->mtu > ETH_DATA_LEN) {
-			pba = 14;
-			ew32(PBA, pba);
+
+		if (adapter->netdev->mtu <= ETH_DATA_LEN) {
+			fc->high_water = 0x05C20;
+			fc->low_water = 0x05048;
+			fc->pause_time = 0x0650;
+			break;
 		}
+
+		fc->high_water = ((pba << 10) * 9 / 10) & E1000_FCRTH_RTH;
+		fc->low_water = ((pba << 10) * 8 / 10) & E1000_FCRTL_RTL;
 		break;
 	}
 
-- 
1.7.11.7
