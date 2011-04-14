From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 24/24] ixgbe: DCB, X540 devices do not respond to pause frames
Date: Wed, 13 Apr 2011 18:02:20 -0700
Message-ID: <1302742940-22141-25-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2477 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754966Ab1DNBD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:03:27 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

DCB enabled X540 devices are not responding to pause frames
due to a missing register set that was added for these
devices that did not exist in other devices.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_82599.c |    9 +++++++--
 drivers/net/ixgbe/ixgbe_type.h      |    2 ++
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index 865ddd8..d50cf78 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -301,12 +301,17 @@ s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw, u8 pfc_en)
 		IXGBE_WRITE_REG(hw, IXGBE_FCCFG, reg);
 		/*
 		 * Enable Receive PFC
-		 * We will always honor XOFF frames we receive when
-		 * we are in PFC mode.
+		 * 82599 will always honor XOFF frames we receive when
+		 * we are in PFC mode however X540 only honors enabled
+		 * traffic classes.
 		 */
 		reg = IXGBE_READ_REG(hw, IXGBE_MFLCN);
 		reg &= ~IXGBE_MFLCN_RFCE;
 		reg |= IXGBE_MFLCN_RPFCE | IXGBE_MFLCN_DPF;
+
+		if (hw->mac.type == ixgbe_mac_X540)
+			reg |= pfc_en << IXGBE_MFLCN_RPFCE_SHIFT;
+
 		IXGBE_WRITE_REG(hw, IXGBE_MFLCN, reg);
 
 	} else {
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 7d0b37d..f5bec97 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1728,6 +1728,8 @@
 #define IXGBE_MFLCN_RPFCE       0x00000004 /* Receive Priority FC Enable */
 #define IXGBE_MFLCN_RFCE        0x00000008 /* Receive FC Enable */
 
+#define IXGBE_MFLCN_RPFCE_SHIFT		 4
+
 /* Multiple Receive Queue Control */
 #define IXGBE_MRQC_RSSEN                 0x00000001  /* RSS Enable */
 #define IXGBE_MRQC_MRQE_MASK                    0xF /* Bits 3:0 */
-- 
1.7.4.2

