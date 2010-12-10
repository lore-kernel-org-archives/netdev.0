From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 18/27] e1000e: 82577/8 must acquire h/w semaphore before workaround
Date: Fri, 10 Dec 2010 02:03:25 -0800
Message-ID: <1291975414-30487-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1291975414-30487-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:38073
	"EHLO qmta13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753507Ab0LJKEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 05:04:08 -0500
To: davem@davemloft.net
In-Reply-To: <1291975414-30487-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemleft.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The workaround function e1000_configure_k1_pchlan() assumes the h/w
semaphore is already acquired.  This was originally missed when setting up
the part for the ethtool loopback test.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ethtool.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 26d4f3b..29b09113 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1263,6 +1263,7 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 	u32 ctrl_reg = 0;
 	u32 stat_reg = 0;
 	u16 phy_reg = 0;
+	s32 ret_val = 0;
 
 	hw->mac.autoneg = 0;
 
@@ -1322,7 +1323,13 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 	case e1000_phy_82577:
 	case e1000_phy_82578:
 		/* Workaround: K1 must be disabled for stable 1Gbps operation */
+		ret_val = hw->phy.ops.acquire(hw);
+		if (ret_val) {
+			e_err("Cannot setup 1Gbps loopback.\n");
+			return ret_val;
+		}
 		e1000_configure_k1_ich8lan(hw, false);
+		hw->phy.ops.release(hw);
 		break;
 	case e1000_phy_82579:
 		/* Disable PHY energy detect power down */
-- 
1.7.3.2

