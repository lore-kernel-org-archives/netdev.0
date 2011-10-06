From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/9] ixgbe: X540 devices RX PFC frames pause traffic even if disabled
Date: Thu,  6 Oct 2011 04:02:36 -0700
Message-ID: <1317898959-16550-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30733 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754701Ab1JFLCp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 07:02:45 -0400
In-Reply-To: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Receiving PFC (priority flow control) frames while the feature
is off should not pause the traffic class. On the X540 devices
the traffic class react to frames if it was previously enabled
because the field is incorrectly cleared.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |   12 +++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |    2 +-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
index 45fe710..32cd97b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
@@ -271,13 +271,23 @@ s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw, u8 pfc_en, u8 *prio_tc)
 		reg |= IXGBE_MFLCN_RPFCE | IXGBE_MFLCN_DPF;
 
 		if (hw->mac.type == ixgbe_mac_X540) {
-			reg &= ~(IXGBE_MFLCN_RPFCE_MASK | 0x10);
+			reg &= ~IXGBE_MFLCN_RPFCE_MASK;
 			reg |= pfc_en << IXGBE_MFLCN_RPFCE_SHIFT;
 		}
 
 		IXGBE_WRITE_REG(hw, IXGBE_MFLCN, reg);
 
 	} else {
+		/* X540 devices have a RX bit that should be cleared
+		 * if PFC is disabled on all TCs but PFC features is
+		 * enabled.
+		 */
+		if (hw->mac.type == ixgbe_mac_X540) {
+			reg = IXGBE_READ_REG(hw, IXGBE_MFLCN);
+			reg &= ~IXGBE_MFLCN_RPFCE_MASK;
+			IXGBE_WRITE_REG(hw, IXGBE_MFLCN, reg);
+		}
+
 		for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
 			hw->mac.ops.fc_enable(hw, i);
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 4ea909c..d1d6894 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1850,7 +1850,7 @@ enum {
 #define IXGBE_MFLCN_DPF         0x00000002 /* Discard Pause Frame */
 #define IXGBE_MFLCN_RPFCE       0x00000004 /* Receive Priority FC Enable */
 #define IXGBE_MFLCN_RFCE        0x00000008 /* Receive FC Enable */
-#define IXGBE_MFLCN_RPFCE_MASK	0x00000FE0 /* Receive FC Mask */
+#define IXGBE_MFLCN_RPFCE_MASK	0x00000FF0 /* Receive FC Mask */
 
 #define IXGBE_MFLCN_RPFCE_SHIFT		 4
 
-- 
1.7.6.4
