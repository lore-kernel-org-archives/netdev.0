From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/3] ixgbe: fix setting of promisc mode when
	using mac-vlans
Date: Thu, 13 May 2010 20:33:00 -0700
Message-ID: <20100514033233.30716.30144.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:36660
	"EHLO qmta14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751575Ab0ENDdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 23:33:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Introduce uc_set_promisc flag to fix enabling of promisc mode
when exceeding the number of supported RAR entries.

Issue discovered by Ben Greear when using mac-vlans.

Reported-by: Ben Greear <greearb@candelatech.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_common.c |    5 ++++-
 drivers/net/ixgbe/ixgbe_main.c   |    6 +++---
 drivers/net/ixgbe/ixgbe_type.h   |    1 +
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 6eb5814..753f2ab 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1392,14 +1392,17 @@ s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw,
 			fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
 			fctrl |= IXGBE_FCTRL_UPE;
 			IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
+			hw->addr_ctrl.uc_set_promisc = true;
 		}
 	} else {
 		/* only disable if set by overflow, not by user */
-		if (old_promisc_setting && !hw->addr_ctrl.user_set_promisc) {
+		if ((old_promisc_setting && hw->addr_ctrl.uc_set_promisc) &&
+		   !(hw->addr_ctrl.user_set_promisc)) {
 			hw_dbg(hw, " Leaving address overflow promisc mode\n");
 			fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
 			fctrl &= ~IXGBE_FCTRL_UPE;
 			IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
+			hw->addr_ctrl.uc_set_promisc = false;
 		}
 	}
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d1a1868..15032c7 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2952,7 +2952,7 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 	fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
 
 	if (netdev->flags & IFF_PROMISC) {
-		hw->addr_ctrl.user_set_promisc = 1;
+		hw->addr_ctrl.user_set_promisc = true;
 		fctrl |= (IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
 		/* don't hardware filter vlans in promisc mode */
 		ixgbe_vlan_filter_disable(adapter);
@@ -2960,11 +2960,11 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		if (netdev->flags & IFF_ALLMULTI) {
 			fctrl |= IXGBE_FCTRL_MPE;
 			fctrl &= ~IXGBE_FCTRL_UPE;
-		} else {
+		} else if (!hw->addr_ctrl.uc_set_promisc) {
 			fctrl &= ~(IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
 		}
 		ixgbe_vlan_filter_enable(adapter);
-		hw->addr_ctrl.user_set_promisc = 0;
+		hw->addr_ctrl.user_set_promisc = false;
 	}
 
 	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 4277cbb..8fc59ac 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2268,6 +2268,7 @@ struct ixgbe_addr_filter_info {
 	u32 mc_addr_in_rar_count;
 	u32 mta_in_use;
 	u32 overflow_promisc;
+	bool uc_set_promisc;
 	bool user_set_promisc;
 };
 

